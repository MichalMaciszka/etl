USE Hurtownia
GO


CREATE TABLE Klient 
(
	Klient_ID INTEGER IDENTITY(1, 1) PRIMARY KEY,
	ImieNazwisko VARCHAR(80),
	Nr_telefonu VARCHAR(20),
	Pesel VARCHAR(11)
)

CREATE TABLE Termin
(
	Termin_ID INTEGER IDENTITY(1, 1) PRIMARY KEY,
	Dzien INTEGER CHECK(Dzien >= 1 AND Dzien <= 31),
	Miesiac VARCHAR(11) CHECK(Miesiac IN 
		('styczeñ', 'luty', 'marzec', 'kwiecieñ', 'maj', 'czerwiec',
			'lipiec', 'sierpieñ', 'wrzesieñ', 'paŸdziernik', 'listopad', 'grudzieñ')),
	Rok INTEGER CHECK (Rok >= 1950 AND Rok <= 2100),
	Dzien_tygodnia VARCHAR(12) CHECK(Dzien_tygodnia IN 
		('poniedzia³ek', 'wtorek', 'œroda', 'czwartek', 'pi¹tek', 'sobota', 'niedziela')),
	DzienWolny VARCHAR(15) CHECK (DzienWolny IN ('dzieñ wolny', 'dzieñ pracuj¹cy'))
)

CREATE TABLE Samochod 
(
	Samochod_ID INTEGER IDENTITY(1, 1) PRIMARY KEY,
	Nr_vin VARCHAR(17),
	Marka VARCHAR(30),
	Model VARCHAR(30),
	Rocznik INTEGER CHECK (Rocznik >= 1950 AND Rocznik <= 2100),
	Nr_rejestracyjny VARCHAR(9),
	Rodzaj_pojemnosc_silnika VARCHAR(14) CHECK (Rodzaj_pojemnosc_silnika IN (
			'ma³y benzyna', 'œredni benzyna', 'du¿y benzyna', 
			'ma³y diesel', 'œredni diesel', 'du¿y diesel')),
	Stan_licznika VARCHAR(10) CHECK (Stan_licznika IN (
		'ma³y', 'œredni', 'du¿y')),
	Czy_powypadkowy VARCHAR(12) CHECK (Czy_powypadkowy IN (
		'powypadkowy', 'bezwypadkowy')),
	ID_termin_zakupu INTEGER FOREIGN KEY REFERENCES Termin,
	ID_termin_przegladu INTEGER FOREIGN KEY REFERENCES Termin,
	Czy_aktywny BIT
)

CREATE TABLE Mechanik
(
	Mechanik_ID INTEGER IDENTITY(1, 1) PRIMARY KEY,
	ImieNazwisko VARCHAR(80),
	Pesel VARCHAR(11),
	Pensja VARCHAR(8) CHECK (Pensja IN ('wysoka', 'œrednia', 'niska'))
)

CREATE TABLE Skarga
(
	Skarga_ID INTEGER IDENTITY(1, 1) PRIMARY KEY,
	Tresc VARCHAR(27) CHECK (Tresc IN ('obs³uga', 'zepsuty samochód', 'samochód niezgodny z opisem',
		'kontakt', 'czas oczekiwania')),
	ID_termin_zlozenia INTEGER FOREIGN KEY REFERENCES Termin
)

CREATE TABLE Wyplata
(
	Kwota FLOAT(2),
	ID_mechanik INTEGER FOREIGN KEY REFERENCES Mechanik,
	ID_termin_wyplaty INTEGER FOREIGN KEY REFERENCES Termin
)

GO
ALTER TABLE Wyplata ALTER COLUMN ID_mechanik INTEGER NOT NULL
ALTER TABLE Wyplata ALTER COLUMN ID_termin_wyplaty INTEGER NOT NULL
GO

ALTER TABLE Wyplata ADD CONSTRAINT PK
	PRIMARY KEY (ID_mechanik, ID_termin_wyplaty)
GO

CREATE TABLE Naprawa
(
	Koszt FLOAT(2),
	ID_samochod INTEGER FOREIGN KEY REFERENCES Samochod,
	ID_termin_rozpoczecia INTEGER FOREIGN KEY REFERENCES Termin,
	ID_termin_zakonczenia INTEGER FOREIGN KEY REFERENCES Termin
)

ALTER TABLE Naprawa ALTER COLUMN ID_samochod INTEGER NOT NULL
ALTER TABLE Naprawa ALTER COLUMN ID_termin_rozpoczecia INTEGER NOT NULL
ALTER TABLE Naprawa ALTER COLUMN ID_termin_zakonczenia INTEGER NOT NULL
GO

ALTER TABLE Naprawa ADD CONSTRAINT PK2
	PRIMARY KEY (ID_samochod, ID_termin_rozpoczecia, ID_termin_zakonczenia)
GO

CREATE TABLE Zlecenie
(
	Wartosc FLOAT(2),
	ID_termin_rozpoczecia INTEGER FOREIGN KEY REFERENCES Termin,
	ID_termin_zakonczenia INTEGER FOREIGN KEY REFERENCES Termin,
	ID_samochod INTEGER FOREIGN KEY REFERENCES Samochod,
	ID_klient INTEGER FOREIGN KEY REFERENCES Klient,
	ID_skarga INTEGER FOREIGN KEY REFERENCES Skarga,
	ID_mechanik INTEGER FOREIGN KEY REFERENCES Mechanik
)

ALTER TABLE Zlecenie ALTER COLUMN ID_mechanik INTEGER NOT NULL
ALTER TABLE Zlecenie ALTER COLUMN ID_samochod INTEGER NOT NULL
ALTER TABLE Zlecenie ALTER COLUMN ID_klient INTEGER NOT NULL
ALTER TABLE Zlecenie ALTER COLUMN ID_skarga INTEGER NOT NULL
ALTER TABLE Zlecenie ALTER COLUMN ID_termin_rozpoczecia INTEGER NOT NULL
ALTER TABLE Zlecenie ALTER COLUMN ID_termin_zakonczenia INTEGER NOT NULL

ALTER TABLE Zlecenie ADD CONSTRAINT PK3
	PRIMARY KEY (ID_termin_rozpoczecia, ID_termin_zakonczenia, ID_samochod,
	ID_klient, ID_skarga, ID_mechanik)
