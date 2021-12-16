use Hurtownia
go

Declare @StartDate date; 
Declare @EndDate date;
SELECT @StartDate = '1980-01-01', @EndDate = '2015-12-31';
Declare @DateInProcess datetime = @StartDate;
SET LANGUAGE Polish

While @DateInProcess <= @EndDate
	Begin
		if @DateInProcess in (select date from auxiliary.dbo.holidays where bank_holiday = 1) OR DATENAME(dw, @DateInProcess) = 'niedziela'
			INSERT INTO Termin VALUES (
				CAST(Day(@DateInProcess) as int),
				CAST(DATENAME(month, @DateInProcess) as varchar(11)),
				CAST (Year(@DateInProcess) as int),
				CAST (DATENAME(dw, @DateInProcess) as varchar(12)),
				'dzieñ wolny',
				MONTH(@DateInProcess)
			)
		else
			INSERT INTO Termin VALUES (
				CAST(Day(@DateInProcess) as int),
				CAST(DATENAME(month, @DateInProcess) as varchar(11)),
				CAST (Year(@DateInProcess) as int),
				CAST (DATENAME(dw, @DateInProcess) as varchar(12)),
				'dzieñ pracuj¹cy',
				MONTH(@DateInProcess)
			)
		set @DateInProcess = DATEADD(d, 1, @DateInProcess);
	End
Go

-- usuwanie bazy pomocniczej
/*USE auxiliary;
DROP TABLE holidays;

USE master;
DROP DATABASE auxiliary;
GO*/

use Hurtownia
select * from Termin