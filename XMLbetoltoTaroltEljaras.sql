DROP PROCEDURE IF EXISTS ImportVideojatekokFromXML;
/* 
   ImportVideojatekokFromXML elj�r�s

   Ez az elj�r�s bet�lti az adatokat egy XML f�jlb�l a Videojatek t�bl�ba.

   Param�terek:
      Nincsenek param�terek.
   V�ltoz�k:
   - @xmlData: XML t�pus� v�ltoz�, amely t�rolja az import�lt XML adatokat.
   - @filePath: NVARCHAR t�pus� v�ltoz�, amely az XML f�jl el�r�si �tvonal�t tartalmazza.
   - @sql: NVARCHAR(MAX) t�pus� v�ltoz�, amelyben a dinamikus SQL lek�rdez�s t�rol�dik.

   M�k�d�s:
   - El�sz�r deklar�ljuk a @xmlData v�ltoz�t, amelyben t�roljuk az XML adatokat.
   - A @filePath v�ltoz�ban megadjuk az XML f�jl el�r�si �tvonal�t.
   - A @sql v�ltoz�ban �ssze�ll�tjuk a dinamikus SQL utas�t�st, amely beolvassa az XML f�jlt a @xmlData v�ltoz�ba.
   - Az EXEC sp_executesql utas�t�ssal v�grehajtjuk a dinamikus SQL-t, �s a @xmlData v�ltoz�ba olvassuk az XML adatokat.
   - Ellen�rizz�k, hogy a Kiado t�bl�b�l minden KiadoNev szerepel-e az XML adatokban.
   - Ha nem tal�lunk minden KiadoNevet, hib�t dobunk.
   - A Videojatek t�bl�ba besz�rjuk az XML adatok alapj�n a megfelel� mez�ket.
   - Az elj�r�s befejez�dik.

   Megjegyz�sek:
   - Az elj�r�s egy XML f�jlt v�r, amelynek az el�r�si �tvonal�t a @filePath v�ltoz�ban kell megadni.
   - Az XML f�jl strukt�r�j�nak meg kell felelnie a dokument�ci�ban bemutatott p�ld�nak.
   - Az elj�r�s bet�lti az XML adatokat a Videojatek t�bl�ba, felt�ve hogy minden KiadoNev �rv�nyes.
   - Ha az import�lt XML adatokban olyan KiadoNev tal�lhat�, amely nem szerepel a Kiado t�bl�ban, akkor hib�t dob.
   - Az elj�r�s a besz�r�st v�gzi a Videojatek t�bl�ba az XML adatok alapj�n.
*/

go
CREATE PROCEDURE ImportVideojatekokFromXML
AS
BEGIN
	/*
	Deklar�ljuk a sz�ks�ges v�ltoz�kat, k�zt�k az `@xmlData` v�ltoz�t, amely t�rolja az import�lt XML adatokat,
	valamint az `@filePath` v�ltoz�t, amelyben megadjuk az XML f�jl el�r�si �tvonal�t.
	*/
    DECLARE @xmlData XML;

    DECLARE @filePath NVARCHAR(255) = 'C:\Users\36303\jatek.xml';
    DECLARE @sql NVARCHAR(MAX);
	/*
	Az `@sql` v�ltoz�ba �ssze�ll�tjuk a dinamikus SQL utas�t�st, 
	amely a `OPENROWSET` funkci� seg�ts�g�vel beolvassa az XML f�jlt �s elhelyezi az adatokat az `@xmlData` v�ltoz�ban.
	*/
    SET @sql = 'SELECT @xmlData = BulkColumn
                FROM OPENROWSET(BULK ''' + @filePath + ''', SINGLE_BLOB) AS x;';
	/*
	A dinamikus SQL lek�rdez�st a `sp_executesql` elj�r�ssal hajtjuk v�gre, �s az eredm�nyt az `@xmlData` v�ltoz�ba olvassuk.
	*/
    EXEC sp_executesql @sql, N'@xmlData XML OUTPUT', @xmlData OUTPUT;
	/*
	Ellen�rizz�k, hogy minden KiadoNev �rv�nyes-e a Kiado t�bl�ban. 
	Ehhez �sszekapcsoljuk az `@xmlData` v�ltoz�t a Kiado t�bl�val a megfelel� mez�k alapj�n, 
	�s ellen�rizz�k, hogy minden KiadoNev megtal�lhat�-e a t�bl�ban. Ha tal�lunk olyan KiadoNeveket, 
	amelyek nem szerepelnek a t�bl�ban, hib�t dobunk.
	*/
    IF EXISTS (
        SELECT T.JatekData.value('(kiado/text())[1]', 'nvarchar(100)')
    FROM @xmlData.nodes('/Jatekok/Jatek') AS T(JatekData)
    LEFT JOIN Kiado ON T.JatekData.value('(kiado/text())[1]', 'nvarchar(100)') = Kiado.nev
    WHERE Kiado.nev IS NULL
    )
    BEGIN
        RAISERROR('Hib�s adatok a f�jlban. A Kiado t�bl�ban nem l�tezik az �sszes KiadoNev.', 16, 1);
        RETURN;
    END;
	/*
	XML adatok besz�r�sa a Videojatek t�bl�ba
	*/
	/*
	Ha minden KiadoNev �rv�nyes, akkor besz�rjuk az XML adatokat a Videojatek t�bl�ba a megfelel� mez�k alapj�n.
	Az `INSERT INTO` utas�t�ssal az XML adatokb�l kinyerj�k a nev, kategoria, fejleszto �s kiadoNev mez�ket, 
	valamint �sszekapcsoljuk a Kiado t�bl�val a kiadoID megszerz�s�hez.
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