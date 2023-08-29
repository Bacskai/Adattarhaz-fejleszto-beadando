/*
A "Kiado" t�bla a kiad�k adatait t�rolja, m�g a "Videojatek" t�bla a videoj�t�kok adatait tartalmazza.
A "Kiado" t�bla a "kiadoID" oszloppal rendelkezik, amely egyedi azonos�t�t t�rol �s a kiad� nev�t, c�m�t �s alap�t�s d�tum�t.
A "Videojatek" t�bla pedig a j�t�kok adatait t�rolja: nevet, kateg�ri�t, fejleszt�t, valamint a kiad� azonos�t�j�t �s nev�t.
*/
CREATE TABLE Kiado (
    kiadoID INT PRIMARY KEY IDENTITY(1,1),
    nev NVARCHAR(100) NOT NULL UNIQUE,
    cim NVARCHAR(100) NOT NULL,
    alapitasDate DATE NOT NULL
);
/*
T�bla: Kiado

oszlopok: kiadoID, nev, cim, alapitasDate
A "kiadoID" azonos�t�k�nt szolg�l, �s az INT t�pus� PRIMARY KEY-k�nt van defini�lva. 
Ez az oszlop automatikusan n�vekszik az IDENTITY(1,1) be�ll�t�snak k�sz�nhet�en.
A "nev" oszlop az NVARCHAR t�pus� �s egyedi �rt�keket tartalmaz.
A "cim" oszlop az NVARCHAR t�pus� �s nem lehet NULL �rt�k.
Az "alapitasDate" oszlop a kiad� alap�t�s�nak d�tum�t t�rolja a DATE t�pusban, �s nem lehet NULL �rt�k.
*/

INSERT INTO Kiado (nev, cim, alapitasDate)
VALUES
    ('Riot Games', 'Los Angeles', '2006-09-01'),
    ('Valve', 'Bellevue', '1996-08-24'),
    ('Rockstar Games', 'New York', '1998-12-01');
/*
H�rom �j rekordot sz�r be a Kiado t�bl�ba.
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
T�bla: Videojatek

oszlopok: jatekID, nev, kategoria, fejleszto, kiadoID, kiadoNev
A "jatekID" azonos�t�k�nt szolg�l, �s az INT t�pus� PRIMARY KEY-k�nt van defini�lva.
Ez az oszlop automatikusan n�vekszik az IDENTITY(1,1) be�ll�t�snak k�sz�nhet�en.
A "nev" oszlop az NVARCHAR t�pus� �s egyedi �rt�keket tartalmaz.
A "kategoria" oszlop NVARCHAR t�pus� �s nem lehet NULL �rt�k.
A "fejleszto" oszlop NVARCHAR t�pus� �s nem lehet NULL �rt�k.
A "kiadoID" oszlop INT t�pus� �s a Kiado t�bla "kiadoID" oszlop�ra mutat� FOREIGN KEY-k�nt van defini�lva.
A "kiadoNev" oszlop NVARCHAR t�pus� �s a Kiado t�bla "nev" oszlop�ra mutat� FOREIGN KEY-k�nt van defini�lva.
*/