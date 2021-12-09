USE Hurtownia
SET LANGUAGE Polish
GO

CREATE TABLE dbo.client_db(
	Imie VARCHAR(20),
	Nazwisko VARCHAR(30),
	Nr_telefonu VARCHAR(20),
	PESEL VARCHAR(11) PRIMARY KEY
)
go

bulk insert dbo.client_db from 'C:\Users\t-ja1\OneDrive\Pulpit\etl\clients_data_t1'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	TABLOCK
)
go

CREATE VIEW tmp_view2 
AS
SELECT ImieNazwisko = Cast(Imie + ' ' + Nazwisko as nvarchar(80)),
		Nr_telefonu, 
		PESEL as Pesel

FROM client_db

go 
select * from tmp_view2

------------------------------------------
go

MERGE INTO Klient USING tmp_view2 as TMP ON Klient.[Pesel] = TMP.[PESEL]
	WHEN NOT MATCHED
	THEN
		INSERT VALUES (
			TMP.[ImieNazwisko],
			TMP.[Nr_telefonu],
			TMP.[Pesel]
		);

SELECT
	*
FROM Klient as K



DROP TABLE dbo.client_db;
DROP VIEW tmp_view2;