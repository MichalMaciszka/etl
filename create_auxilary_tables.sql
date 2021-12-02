USE master;
drop database auxiliary;

CREATE DATABASE auxiliary  collate Latin1_General_CI_AS;
GO

USE auxiliary;

CREATE TABLE holidays(date DATETIME PRIMARY KEY, holiday VARCHAR(500), bank_holiday BIT);

USE master;
GO

select * from auxiliary.dbo.holidays