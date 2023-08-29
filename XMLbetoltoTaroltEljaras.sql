DROP PROCEDURE IF EXISTS ImportVideojatekokFromXML;
/* 
   ImportVideojatekokFromXML eljárás

   Ez az eljárás betölti az adatokat egy XML fájlból a Videojatek táblába.

   Paraméterek:
      Nincsenek paraméterek.
   Változók:
   - @xmlData: XML típusú változó, amely tárolja az importált XML adatokat.
   - @filePath: NVARCHAR típusú változó, amely az XML fájl elérési útvonalát tartalmazza.
   - @sql: NVARCHAR(MAX) típusú változó, amelyben a dinamikus SQL lekérdezés tárolódik.

   Mûködés:
   - Elõször deklaráljuk a @xmlData változót, amelyben tároljuk az XML adatokat.
   - A @filePath változóban megadjuk az XML fájl elérési útvonalát.
   - A @sql változóban összeállítjuk a dinamikus SQL utasítást, amely beolvassa az XML fájlt a @xmlData változóba.
   - Az EXEC sp_executesql utasítással végrehajtjuk a dinamikus SQL-t, és a @xmlData változóba olvassuk az XML adatokat.
   - Ellenõrizzük, hogy a Kiado táblából minden KiadoNev szerepel-e az XML adatokban.
   - Ha nem találunk minden KiadoNevet, hibát dobunk.
   - A Videojatek táblába beszúrjuk az XML adatok alapján a megfelelõ mezõket.
   - Az eljárás befejezõdik.

   Megjegyzések:
   - Az eljárás egy XML fájlt vár, amelynek az elérési útvonalát a @filePath változóban kell megadni.
   - Az XML fájl struktúrájának meg kell felelnie a dokumentációban bemutatott példának.
   - Az eljárás betölti az XML adatokat a Videojatek táblába, feltéve hogy minden KiadoNev érvényes.
   - Ha az importált XML adatokban olyan KiadoNev található, amely nem szerepel a Kiado táblában, akkor hibát dob.
   - Az eljárás a beszúrást végzi a Videojatek táblába az XML adatok alapján.
*/

go
CREATE PROCEDURE ImportVideojatekokFromXML
AS
BEGIN
	/*
	Deklaráljuk a szükséges változókat, köztük az `@xmlData` változót, amely tárolja az importált XML adatokat,
	valamint az `@filePath` változót, amelyben megadjuk az XML fájl elérési útvonalát.
	*/
    DECLARE @xmlData XML;

    DECLARE @filePath NVARCHAR(255) = 'C:\Users\36303\jatek.xml';
    DECLARE @sql NVARCHAR(MAX);
	/*
	Az `@sql` változóba összeállítjuk a dinamikus SQL utasítást, 
	amely a `OPENROWSET` funkció segítségével beolvassa az XML fájlt és elhelyezi az adatokat az `@xmlData` változóban.
	*/
    SET @sql = 'SELECT @xmlData = BulkColumn
                FROM OPENROWSET(BULK ''' + @filePath + ''', SINGLE_BLOB) AS x;';
	/*
	A dinamikus SQL lekérdezést a `sp_executesql` eljárással hajtjuk végre, és az eredményt az `@xmlData` változóba olvassuk.
	*/
    EXEC sp_executesql @sql, N'@xmlData XML OUTPUT', @xmlData OUTPUT;
	/*
	Ellenõrizzük, hogy minden KiadoNev érvényes-e a Kiado táblában. 
	Ehhez összekapcsoljuk az `@xmlData` változót a Kiado táblával a megfelelõ mezõk alapján, 
	és ellenõrizzük, hogy minden KiadoNev megtalálható-e a táblában. Ha találunk olyan KiadoNeveket, 
	amelyek nem szerepelnek a táblában, hibát dobunk.
	*/
    IF EXISTS (
        SELECT T.JatekData.value('(kiado/text())[1]', 'nvarchar(100)')
    FROM @xmlData.nodes('/Jatekok/Jatek') AS T(JatekData)
    LEFT JOIN Kiado ON T.JatekData.value('(kiado/text())[1]', 'nvarchar(100)') = Kiado.nev
    WHERE Kiado.nev IS NULL
    )
    BEGIN
        RAISERROR('Hibás adatok a fájlban. A Kiado táblában nem létezik az összes KiadoNev.', 16, 1);
        RETURN;
    END;
	/*
	XML adatok beszúrása a Videojatek táblába
	*/
	/*
	Ha minden KiadoNev érvényes, akkor beszúrjuk az XML adatokat a Videojatek táblába a megfelelõ mezõk alapján.
	Az `INSERT INTO` utasítással az XML adatokból kinyerjük a nev, kategoria, fejleszto és kiadoNev mezõket, 
	valamint összekapcsoljuk a Kiado táblával a kiadoID megszerzéséhez.
	*/
    INSERT INTO Videojatek (nev, kategoria, fejleszto, kiadoNev, kiadoID)
    SELECT
        JatekData.value('(nev/text())[1]', 'nvarchar(100)') AS nev,
        JatekData.value('(kategoria/text())[1]', 'nvarchar(50)') AS kategoria,
        JatekData.value('(fejleszto/text())[1]', 'nvarchar(100)') AS fejleszto,
        JatekData.value('(kiado/text())[1]', 'nvarchar(100)') AS kiadoNev,
        Kiado.kiadoID
    FROM
        @xmlData.nodes('/Jatekok/Jatek') AS T(JatekData)
    JOIN
        Kiado ON JatekData.value('(kiado/text())[1]', 'nvarchar(100)') = Kiado.nev;
END;

--EXEC ImportVideojatekokFromXML;