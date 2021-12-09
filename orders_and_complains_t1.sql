USE Hurtownia
SET LANGUAGE Polish
GO

CREATE TABLE TMP_Skarga(
	ID int,
	Tresc varchar(500),
	Data_zlozenia date,
	ID_Zlecenie int
)

CREATE TABLE TMP_Zlecenie(
	ID int,
	start_termin date,
	end_termin date,
	wartosc float(2),
	Klient varchar(11),
	Samochod varchar(17),
	Mechanik varchar(11)
)

ALTER TABLE Skarga ADD old_order_id int

bulk insert dbo.TMP_Zlecenie from 'C:\Users\t-ja1\OneDrive\Pulpit\etl\orders_data_t1' WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	TABLOCK
)

bulk insert dbo.TMP_Skarga from 'C:\Users\t-ja1\OneDrive\Pulpit\etl\complaints_data_t1' WITH  (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	TABLOCK
)

GO
CREATE VIEW skargi_temp AS
SELECT
	[ID_Termin] = (SELECT Termin.Termin_ID FROM Termin WHERE CAST(DAY(TMP.Data_zlozenia) as int) = Termin.Dzien AND CAST(DATENAME(month, TMP.Data_zlozenia) as varchar(11)) = Termin.Miesiac AND CAST(YEAR(TMP.Data_zlozenia) as int) = Termin.Rok),
	[x] = (SELECT ABS(CHECKSUM(NEWID())) % 5),
	[old_id] = TMP.ID_Zlecenie
FROM TMP_Skarga AS TMP
GO
-- drop view skargi_temp

select * from skargi_temp

go
CREATE VIEW Proper_TMP AS
SELECT
	[ID_Termin] = A.ID_Termin,
	CASE
		when A.x = 0 THEN 'obs³uga'
		when A.x = 1 THEN 'zepsuty samochód'
		when A.x = 2 THEN 'samochód niezgodny z opisem'
		when A.x = 3 THEN 'kontakt'
		when A.x = 4 THEN 'czas oczekiwania'
	END AS [Tresc],
	[old_id] = A.old_id
FROM skargi_temp AS A
go

-- drop view Proper_TMP

select * from Proper_TMP
-- select * from Skarga join Proper_TMP on Skarga.ID_termin_zlozenia = Proper_TMP.ID_Termin AND Skarga.Tresc = Proper_TMP.Tresc

MERGE INTO Skarga as S USING Proper_TMP as TMP ON S.ID_termin_zlozenia = TMP.ID_Termin AND S.Tresc = TMP.Tresc
	WHEN NOT MATCHED
	THEN
		INSERT VALUES (
			TMP.Tresc,
			TMP.ID_Termin,
			TMP.old_id
		)
;

select * from Skarga

drop view Proper_TMP
drop view skargi_temp

insert into Skarga VALUES(NULL, (SELECT Termin.Termin_ID FROM Termin WHERE CAST(DAY('1980-1-1') as int) = Termin.Dzien AND CAST(DATENAME(month, '1980-1-1') as varchar(11)) = Termin.Miesiac AND CAST(YEAR('1980-1-1') as int) = Termin.Rok), NULL)

go
CREATE VIEW tmpV_zlecenie AS
SELECT
	[wartosc] = TMP_Z.wartosc,
	[ID_start_date] = (SELECT Termin.Termin_ID FROM Termin WHERE CAST(DAY(TMP_Z.start_termin) as int) = Termin.Dzien AND CAST(DATENAME(month, TMP_Z.start_termin) as varchar(11)) = Termin.Miesiac AND CAST(YEAR(TMP_Z.start_termin) as int) = Termin.Rok),
	[ID_end_date] = (SELECT Termin.Termin_ID FROM Termin WHERE CAST(DAY(TMP_Z.end_termin) as int) = Termin.Dzien AND CAST(DATENAME(month, TMP_Z.end_termin) as varchar(11)) = Termin.Miesiac AND CAST(YEAR(TMP_Z.end_termin) as int) = Termin.Rok),
	[ID_Samochod] = (SELECT Samochod.Samochod_ID FROM Samochod WHERE TMP_Z.Samochod = Samochod.Nr_vin AND Samochod.Czy_aktywny = 1),
	[ID_Klient] = (SELECT Klient.Klient_ID FROM Klient WHERE Klient.Pesel = TMP_Z.Klient),
	[ID_Mechanik] = (SELECT Mechanik.Mechanik_ID FROM Mechanik WHERE Mechanik.Pesel = TMP_Z.Mechanik),
	CASE
		WHEN (SELECT Skarga.Skarga_ID FROM Skarga WHERE Skarga.old_order_id = TMP_Z.ID) IS NULL THEN (SELECT Skarga.Skarga_ID FROM Skarga WHERE Tresc IS NULL)
		WHEN (SELECT Skarga.Skarga_ID FROM Skarga WHERE Skarga.old_order_id = TMP_Z.ID) IS NOT NULL THEN 
			(SELECT Skarga.Skarga_ID FROM Skarga WHERE Skarga.old_order_id = TMP_Z.ID)
	END AS [Skarga],
	[old] = TMP_Z.ID
FROM TMP_Zlecenie as TMP_Z
go

-- drop view tmpV_zlecenie
select * from tmpV_zlecenie



MERGE INTO Zlecenie AS Z USING tmpV_Zlecenie AS TMP ON 
	Z.ID_termin_rozpoczecia = TMP.ID_start_date AND
	Z.ID_termin_zakonczenia = TMP.ID_end_date AND
	Z.ID_samochod = TMP.ID_Samochod AND
	Z.ID_klient = TMP.ID_Klient AND
	Z.ID_skarga = TMP.Skarga AND
	Z.ID_mechanik = TMP.ID_Mechanik
WHEN NOT MATCHED
THEN
	INSERT VALUES(
		TMP.wartosc,
		TMP.ID_start_date,
		TMP.ID_end_date,
		TMP.ID_Samochod,
		TMP.ID_Klient,
		TMP.Skarga,
		TMP.ID_Mechanik
	)
;

drop view tmpV_zlecenie
drop table TMP_Skarga
drop table TMP_Zlecenie
-- ALTER TABLE Skarga DROP COLUMN old_order_id