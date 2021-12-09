USE Hurtownia
SET LANGUAGE Polish

CREATE TABLE TMP_Naprawa(
	ID int,
	start_date date,
	end_date date,
	opis varchar(100),
	Koszt float(2),
	Samochod varchar(17)
)

bulk insert TMP_Naprawa from 'C:\Users\t-ja1\OneDrive\Pulpit\etl\repairs_data_t1'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	TABLOCK
)

GO
CREATE VIEW Naprawa_temp AS
SELECT
	[Koszt] = TMP.Koszt,
	[ID_Samochod] = (SELECT TOP 1 Samochod.Samochod_ID FROM Samochod WHERE Samochod.Nr_VIN = TMP.Samochod AND Samochod.Czy_aktywny = 1 ORDER BY Samochod.Czy_aktywny desc),
	[start_date] = (SELECT Termin_ID FROM Termin WHERE CAST(DAY(TMP.start_date) as int) = Termin.Dzien AND CAST(DATENAME(MONTH, TMP.start_date) as varchar(11)) = Termin.Miesiac AND CAST(YEAR(TMP.start_date) as int) = Termin.Rok),
	[end_date] = (SELECT Termin_ID FROM Termin WHERE CAST(DAY(TMP.end_date) as int) = Termin.Dzien AND CAST(DATENAME(MONTH, TMP.end_date) as varchar(11)) = Termin.Miesiac AND CAST(YEAR(TMP.end_date) as int) = Termin.Rok)
FROM TMP_Naprawa AS TMP
GO

-- select * from Naprawa_temp

MERGE INTO Naprawa as N USING Naprawa_temp as TMP ON N.ID_Samochod = TMP.ID_Samochod AND N.ID_termin_rozpoczecia = TMP.start_date AND N.ID_termin_zakonczenia = TMP.end_date
	WHEN NOT MATCHED
	THEN
		INSERT VALUES (
			TMP.Koszt,
			TMP.ID_Samochod,
			TMP.start_date,
			TMP.end_date
		)
;

SELECT * FROM Naprawa

drop table TMP_Naprawa
drop view Naprawa_temp