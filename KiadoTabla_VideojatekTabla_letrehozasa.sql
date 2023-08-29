/*
A "Kiado" tábla a kiadók adatait tárolja, míg a "Videojatek" tábla a videojátékok adatait tartalmazza.
A "Kiado" tábla a "kiadoID" oszloppal rendelkezik, amely egyedi azonosítót tárol és a kiadó nevét, címét és alapítás dátumát.
A "Videojatek" tábla pedig a játékok adatait tárolja: nevet, kategóriát, fejlesztõt, valamint a kiadó azonosítóját és nevét.
*/
CREATE TABLE Kiado (
    kiadoID INT PRIMARY KEY IDENTITY(1,1),
    nev NVARCHAR(100) NOT NULL UNIQUE,
    cim NVARCHAR(100) NOT NULL,
    alapitasDate DATE NOT NULL
);
/*
Tábla: Kiado

oszlopok: kiadoID, nev, cim, alapitasDate
A "kiadoID" azonosítóként szolgál, és az INT típusú PRIMARY KEY-ként van definiálva. 
Ez az oszlop automatikusan növekszik az IDENTITY(1,1) beállításnak köszönhetõen.
A "nev" oszlop az NVARCHAR típusú és egyedi értékeket tartalmaz.
A "cim" oszlop az NVARCHAR típusú és nem lehet NULL érték.
Az "alapitasDate" oszlop a kiadó alapításának dátumát tárolja a DATE típusban, és nem lehet NULL érték.
*/

INSERT INTO Kiado (nev, cim, alapitasDate)
VALUES
    ('Riot Games', 'Los Angeles', '2006-09-01'),
    ('Valve', 'Bellevue', '1996-08-24'),
    ('Rockstar Games', 'New York', '1998-12-01');
/*
Három új rekordot szúr be a Kiado táblába.
*/

CREATE TABLE Videojatek (
    jatekID INT PRIMARY KEY IDENTITY(1,1),
    nev NVARCHAR(100) NOT NULL UNIQUE,
    kategoria NVARCHAR(50) NOT NULL,
    fejleszto NVARCHAR(100) NOT NULL,
    kiadoID INT FOREIGN KEY REFERENCES Kiado(kiadoID),
    kiadoNev NVARCHAR(100) NOT NULL FOREIGN KEY REFERENCES Kiado(nev)
);

/*
Tábla: Videojatek

oszlopok: jatekID, nev, kategoria, fejleszto, kiadoID, kiadoNev
A "jatekID" azonosítóként szolgál, és az INT típusú PRIMARY KEY-ként van definiálva.
Ez az oszlop automatikusan növekszik az IDENTITY(1,1) beállításnak köszönhetõen.
A "nev" oszlop az NVARCHAR típusú és egyedi értékeket tartalmaz.
A "kategoria" oszlop NVARCHAR típusú és nem lehet NULL érték.
A "fejleszto" oszlop NVARCHAR típusú és nem lehet NULL érték.
A "kiadoID" oszlop INT típusú és a Kiado tábla "kiadoID" oszlopára mutató FOREIGN KEY-ként van definiálva.
A "kiadoNev" oszlop NVARCHAR típusú és a Kiado tábla "nev" oszlopára mutató FOREIGN KEY-ként van definiálva.
*/