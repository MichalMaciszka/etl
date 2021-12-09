USE Hurtownia
SET LANGUAGE Polish
GO

/*drop table dbo.cars_db
drop table dbo.cars_excel
drop view tmp_view*/

CREATE TABLE dbo.cars_db(
	Nr_vin VARCHAR(17) PRIMARY KEY,
	Marka VARCHAR(30),
	Model VARCHAR(30),
	Rocznik INTEGER
)
go


CREATE TABLE dbo.cars_excel (
	id integer,
	marka varchar(30),
	model varchar(30),
	nr_vin varchar(17) primary key,
	rejestracja varchar(9),
	rocznik integer,
	silnik varchar(5),
	data_zakupu date,
	licznik_poczatkowy float(2),
	licznik_obecny float(2),
	data_ostatniego_przegladu date,
	czy_powypadkowy bit,
	ostatnia_trasa float(2)
)
go

bulk insert dbo.cars_excel from 'C:\Users\t-ja1\OneDrive\Pulpit\etl\cars_EXCEL_data_t1'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	TABLOCK
)
go

bulk insert dbo.cars_db from 'C:\Users\t-ja1\OneDrive\Pulpit\etl\cars_DB_data_t1'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	TABLOCK
)
GO

CREATE VIEW tmpCars_view 
AS
SELECT cars_db.*, cars_excel.rejestracja, cars_excel.data_zakupu, cars_excel.data_ostatniego_przegladu,
CASE
	WHEN TRY_CONVERT(float, SUBSTRING(cars_excel.silnik, 1, CHARINDEX(' ', cars_excel.silnik) - 1)) < 1.6 AND SUBSTRING(cars_excel.silnik, CHARINDEX(' ', cars_excel.silnik) + 1, len(cars_excel.silnik)) = 'B' THEN 'ma³y benzyna'
	WHEN TRY_CONVERT(float, SUBSTRING(cars_excel.silnik, 1, CHARINDEX(' ', cars_excel.silnik) - 1)) BETWEEN 1.6 AND 2.49 AND SUBSTRING(cars_excel.silnik, CHARINDEX(' ', cars_excel.silnik) + 1, len(cars_excel.silnik)) = 'B' THEN 'œredni benzyna'
	WHEN TRY_CONVERT(float, SUBSTRING(cars_excel.silnik, 1, CHARINDEX(' ', cars_excel.silnik) - 1)) >= 2.5 AND SUBSTRING(cars_excel.silnik, CHARINDEX(' ', cars_excel.silnik) + 1, len(cars_excel.silnik)) = 'B' THEN 'du¿y benzyna'
	WHEN TRY_CONVERT(float, SUBSTRING(cars_excel.silnik, 1, CHARINDEX(' ', cars_excel.silnik) - 1)) < 1.6 AND SUBSTRING(cars_excel.silnik, CHARINDEX(' ', cars_excel.silnik) + 1, len(cars_excel.silnik)) = 'D' THEN 'ma³y diesel'
	WHEN TRY_CONVERT(float, SUBSTRING(cars_excel.silnik, 1, CHARINDEX(' ', cars_excel.silnik) - 1)) BETWEEN 1.6 AND 2.49 AND SUBSTRING(cars_excel.silnik, CHARINDEX(' ', cars_excel.silnik) + 1, len(cars_excel.silnik)) = 'D' THEN 'œredni diesel'
	WHEN TRY_CONVERT(float, SUBSTRING(cars_excel.silnik, 1, CHARINDEX(' ', cars_excel.silnik) - 1)) >= 2.5 AND SUBSTRING(cars_excel.silnik, CHARINDEX(' ', cars_excel.silnik) + 1, len(cars_excel.silnik)) = 'D' THEN 'du¿y diesel'
END AS 'Rodzaj pojemnosc silnika',
CASE
	WHEN licznik_obecny < 100000.0 THEN 'ma³y'
	WHEN licznik_obecny BETWEEN 100000.0 AND 200000.0 THEN 'œredni'
	WHEN licznik_obecny > 200000.0 THEN 'du¿y'
END AS 'Stan licznika',
CASE
	WHEN cars_excel.czy_powypadkowy = 0 THEN 'bezwypadkowy'
	WHEN cars_excel.czy_powypadkowy = 1 THEN 'powypadkowy'
END AS 'Czy powypadkowy'
FROM cars_db join cars_excel ON cars_db.Nr_vin = cars_excel.nr_vin
GO

-- select * from tmp_view where Nr_vin = '1B3ED46T8TRYVTLMW'

------------------------------------------
go

set language Polish


MERGE INTO Samochod as SD USING tmpCars_view as TMP ON SD.Nr_vin = TMP.Nr_vin
	WHEN NOT MATCHED
	THEN
		INSERT VALUES (
			TMP.[Nr_vin],
			TMP.[Marka],
			TMP.[Model],
			TMP.[Rocznik],
			TMP.[rejestracja],
			TMP.[Rodzaj pojemnosc silnika],
			TMP.[Stan licznika],
			TMP.[Czy powypadkowy],
			(SELECT Termin.Termin_ID FROM Termin WHERE CAST(Day(TMP.[data_zakupu]) AS int) = Termin.Dzien AND CAST(Datename(month, TMP.[data_zakupu]) as varchar(11)) = Termin.Miesiac AND CAST(Year(TMP.[data_zakupu]) AS int) = Termin.Rok),
			(SELECT Termin.Termin_ID FROM Termin WHERE CAST(Day(TMP.[data_ostatniego_przegladu]) AS int) = Termin.Dzien AND CAST(Datename(month, TMP.[data_ostatniego_przegladu]) as varchar(11)) = Termin.Miesiac AND CAST(Year(TMP.[data_ostatniego_przegladu]) AS int) = Termin.Rok),
			1
		)
	WHEN MATCHED AND ((SD.Stan_licznika <> TMP.[Stan licznika]) OR (SD.Rodzaj_pojemnosc_silnika <> TMP.[Rodzaj pojemnosc silnika]) OR (SD.Czy_powypadkowy <> TMP.[Czy powypadkowy]))
	THEN
		UPDATE SET SD.Czy_aktywny = 0
	WHEN NOT MATCHED BY SOURCE
	THEN
		UPDATE SET SD.Czy_aktywny = 0
;

INSERT INTO Samochod (
	Nr_vin,
	Marka,
	Model,
	Rocznik,
	Nr_rejestracyjny,
	Rodzaj_pojemnosc_silnika,
	Stan_licznika,
	Czy_powypadkowy,
	ID_termin_zakupu,
	ID_termin_przegladu,
	Czy_aktywny
)
SELECT
	TMP.Nr_vin, TMP.Marka, TMP.Model, TMP.Rocznik, TMP.rejestracja, TMP.[Rodzaj pojemnosc silnika], TMP.[Stan licznika], TMP.[Czy powypadkowy], 
	(SELECT Termin.Termin_ID FROM Termin WHERE CAST(Day(TMP.[data_zakupu]) AS int) = Termin.Dzien AND CAST(Datename(month, TMP.[data_zakupu]) as varchar(11)) = Termin.Miesiac AND CAST(Year(TMP.[data_zakupu]) AS int) = Termin.Rok),
	(SELECT Termin.Termin_ID FROM Termin WHERE CAST(Day(TMP.[data_ostatniego_przegladu]) AS int) = Termin.Dzien AND CAST(Datename(month, TMP.[data_ostatniego_przegladu]) as varchar(11)) = Termin.Miesiac AND CAST(Year(TMP.[data_ostatniego_przegladu]) AS int) = Termin.Rok),
	1
FROM tmpCars_view as TMP
EXCEPT
SELECT
SD.Nr_vin, SD.Marka, SD.Model, SD.Rocznik, SD.Nr_rejestracyjny, SD.[Rodzaj_pojemnosc_silnika], SD.[Stan_licznika], SD.[Czy_powypadkowy], SD.ID_termin_zakupu, SD.ID_termin_przegladu, 1
FROM Samochod as SD

DROP TABLE dbo.cars_db;
DROP TABLE dbo.cars_excel;
DROP VIEW tmpCars_view ;


-- select * from dbo.Klient

-- select * from Samochod where Nr_vin = '1B3ED46T8TRYVTLMW'

-- select * from Samochod where ID_termin_przegladu is null
-- drop table Samochod


-- SELECT * FROM Termin WHERE CAST(Day('2009-1-31') AS int) = Termin.Dzien AND CAST(Datename(month, '2009-1-31') as varchar(11)) = Termin.Miesiac and CAST(Year('2009-1-31') AS int) = Termin.Rok