USE Hurtownia
SET LANGUAGE Polish
GO

CREATE TABLE dbo.Tmp_workers (
	Imie varchar(50),
	Nazwisko varchar(50),
	Pesel varchar(11) primary key,
	Pensja float(2)
)

CREATE TABLE dbo.ObecnaData(
	dzis date
)
insert into dbo.ObecnaData (dzis) values ('2012-01-10')

bulk insert dbo.Tmp_workers from 'C:\Users\t-ja1\OneDrive\Pulpit\etl\workers_data_t1' with (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	TABLOCK
)

if(OBJECT_ID('tmp_view') is not null) Drop view tmp_view;

go
create view tmp_view
as
select
	[Name]  = CAST(TMP.Imie + ' ' + TMP.Nazwisko as varchar(80)),
	[Pesel] = TMP.Pesel,
	CASE
		WHEN TMP.Pensja < 3000 THEN 'niska'
		WHEN TMP.Pensja BETWEEN 3000 AND 6000 THEN 'œrednia'
		WHEN TMP.Pensja > 6000 THEN 'wysoka'
	END AS [Pensja]
from dbo.Tmp_workers as TMP
go

-- select * from tmp_view


MERGE INTO Mechanik as M USING tmp_view as TMP ON M.Pesel = TMP.Pesel
	WHEN NOT MATCHED
	THEN
		INSERT Values(
			TMP.[Name],
			TMP.[Pesel],
			TMP.[Pensja]
		)
;
GO
CREATE VIEW x as
SELECT
	[M_ID] = (SELECT TOP 1 Mechanik.Mechanik_ID FROM Mechanik WHERE Mechanik.Pesel = TMP.Pesel ORDER BY Mechanik_ID desc),
	[Date] = (SELECT dzis FROM ObecnaData),
	[Termin_ID] = (SELECT Termin_ID FROM Termin WHERE
		-- Termin.Dzien = CAST(DAY((select dzis from ObecnaData)) as int) AND
		Termin.Dzien = 28 AND
		Termin.Miesiac = CAST(DATENAME(month, (select dzis from ObecnaData)) as varchar(11)) AND
		Termin.Rok = CAST(YEAR((select dzis from ObecnaData)) AS int)
	),
	[Kwota] = TMP.Pensja
FROM dbo.Tmp_workers as TMP
GO

-- drop view x

MERGE INTO Wyplata as W using x on x.M_ID = W.ID_Mechanik AND x.Termin_ID = W.ID_termin_wyplaty
	WHEN MATCHED
	THEN
		UPDATE SET W.Kwota = x.Kwota
	WHEN NOT MATCHED
	THEN
		INSERT VALUES(
			x.Kwota,
			x.M_ID,
			x.Termin_ID
		)
;

drop table Tmp_workers
drop table ObecnaData
drop view x
drop view tmp_view