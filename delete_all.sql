/* Drop all non-system stored procs */ 
    DECLARE @name VARCHAR(128) 
    DECLARE @SQL VARCHAR(254)
    DECLARE @schema VARCHAR(128)

    SELECT @name = (SELECT TOP 1 [name] FROM sysobjects WHERE [type] = 'P' AND category = 0 ORDER BY [name]) 
    SELECT @schema = (SELECT TOP 1 schema_name(schema_id) FROM sys.procedures WHERE [name] = @name)

    WHILE @name is not null 
    BEGIN 
        SELECT @SQL = 'DROP PROCEDURE [' + @schema + '].[' + RTRIM(@name) +']' 
        --PRINT (@SQL)
        EXEC (@SQL) 
        PRINT 'Dropped Procedure: ' + @name 

        SELECT @name = (SELECT TOP 1 [name] FROM sysobjects WHERE [type] = 'P' AND category = 0 ORDER BY [name])
        SELECT @schema = (SELECT TOP 1 schema_name(schema_id) FROM sys.procedures WHERE [name] = @name) 
    END 
    GO 

    /* Drop all database triggers */
    DECLARE @name VARCHAR(128) 
    DECLARE @SQL VARCHAR(254)

    SELECT @name = (SELECT TOP 1 T.name FROM sys.triggers AS T WHERE T.parent_id = 0 /* database trigger */ ORDER BY [name])

    WHILE @name is not null 
    BEGIN 
        SELECT @SQL = 'DROP TRIGGER [' + RTRIM(@name) +'] ON DATABASE' 
        EXEC (@SQL) 
        PRINT 'Dropped TRIGGER: ' + @name 

        SELECT @name = (SELECT TOP 1 T.name FROM sys.triggers AS T WHERE T.parent_id = 0 /* database trigger */ AND [name] > @name ORDER BY [name])
    END 
    GO 

    /* Drop all views */ 
    DECLARE @name VARCHAR(128) 
    DECLARE @SQL VARCHAR(254)
    DECLARE @schema VARCHAR(128)

    SELECT @name = (SELECT TOP 1 [name] FROM sysobjects WHERE [type] = 'V' AND category = 0 ORDER BY [name]) 
    SELECT @schema = (SELECT TOP 1 schema_name(schema_id) FROM sys.views WHERE [name] = @name)

    WHILE @name IS NOT NULL 
    BEGIN 
        SELECT @SQL = 'DROP VIEW [' + @schema + '].[' + RTRIM(@name) +']' 
        EXEC (@SQL) 
        PRINT 'Dropped View: ' + @name 
        SELECT @name = (SELECT TOP 1 [name] FROM sysobjects WHERE [type] = 'V' AND category = 0 AND [name] > @name ORDER BY [name]) 
        SELECT @schema = (SELECT TOP 1 schema_name(schema_id) FROM sys.views WHERE [name] = @name)
    END 
    GO 

    /* Drop all Foreign Key constraints */ 
    DECLARE @name VARCHAR(128) 
    DECLARE @constraint VARCHAR(254) 
    DECLARE @SQL VARCHAR(254) 
    DECLARE @schema VARCHAR(128)

    SELECT @name = (SELECT TOP 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'FOREIGN KEY' ORDER BY TABLE_NAME) 
    SELECT @schema = (SELECT TOP 1 CONSTRAINT_SCHEMA FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'FOREIGN KEY' ORDER BY TABLE_NAME)

    WHILE @name is not null 
    BEGIN 
        SELECT @constraint = (SELECT TOP 1 CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'FOREIGN KEY' AND TABLE_NAME = @name AND CONSTRAINT_SCHEMA = @schema ORDER BY CONSTRAINT_NAME) 
        WHILE @constraint IS NOT NULL 
        BEGIN 
            SELECT @SQL = 'ALTER TABLE [' + @schema + '].[' + RTRIM(@name) +'] DROP CONSTRAINT [' + RTRIM(@constraint) +']' 
            BEGIN TRY
                EXEC (@SQL)
                PRINT 'Dropped FK Constraint: ' + @constraint + ' on ' + @name
            END TRY
            BEGIN CATCH
                PRINT (@SQL)
            END CATCH
            SELECT @constraint = (SELECT TOP 1 CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'FOREIGN KEY' AND CONSTRAINT_NAME <> @constraint AND TABLE_NAME = @name AND CONSTRAINT_SCHEMA = @schema ORDER BY CONSTRAINT_NAME) 
        END 
    SELECT @name = (SELECT TOP 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'FOREIGN KEY' ORDER BY TABLE_NAME) 
    SELECT @schema = (SELECT TOP 1 CONSTRAINT_SCHEMA FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'FOREIGN KEY' ORDER BY TABLE_NAME)
    END 
    GO 

    /* Drop all Primary Key constraints */ 
    DECLARE @name VARCHAR(128) 
    DECLARE @constraint VARCHAR(254) 
    DECLARE @SQL VARCHAR(254) 
    DECLARE @schema VARCHAR(128)

    SELECT @name = (SELECT TOP 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'PRIMARY KEY' ORDER BY TABLE_NAME) 
    SELECT @schema = (SELECT TOP 1 CONSTRAINT_SCHEMA FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'PRIMARY KEY' ORDER BY TABLE_NAME)

    WHILE @name IS NOT NULL 
    BEGIN 
        SELECT @constraint = (SELECT TOP 1 CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'PRIMARY KEY' AND TABLE_NAME = @name AND CONSTRAINT_SCHEMA = @schema ORDER BY CONSTRAINT_NAME) 
        WHILE @constraint is not null 
        BEGIN 
            SELECT @SQL = 'ALTER TABLE [' + @schema + '].[' + RTRIM(@name) +'] DROP CONSTRAINT [' + RTRIM(@constraint)+']' 
            --PRINT @SQL
            EXEC (@SQL)
            PRINT 'Dropped PK Constraint: ' + @constraint + ' on ' + @name 
            SELECT @constraint = (SELECT TOP 1 CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'PRIMARY KEY' AND CONSTRAINT_NAME <> @constraint AND TABLE_NAME = @name AND CONSTRAINT_SCHEMA = @schema ORDER BY CONSTRAINT_NAME) 
        END 
    SELECT @name = (SELECT TOP 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'PRIMARY KEY' ORDER BY TABLE_NAME) 
    SELECT @schema = (SELECT TOP 1 CONSTRAINT_SCHEMA FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE constraint_catalog=DB_NAME() AND CONSTRAINT_TYPE = 'PRIMARY KEY' ORDER BY TABLE_NAME)
    END 
    GO 

    /* Drop all tables */ 
    DECLARE @name VARCHAR(128) 
    DECLARE @SQL VARCHAR(254) 
    DECLARE @schema VARCHAR(128)

    SELECT @name = (SELECT TOP 1 [name] FROM sysobjects WHERE [type] = 'U' AND category = 0 ORDER BY [name]) 
    SELECT @schema = (SELECT TOP 1 schema_name(schema_id) FROM sys.tables WHERE [name] = @name)

    WHILE @name IS NOT NULL 
    BEGIN 
        SELECT @SQL = 'DROP TABLE [' + @schema + '].[' + RTRIM(@name) +']' 
        EXEC (@SQL) 
        PRINT 'Dropped Table: ' + @name 
        SELECT @name = (SELECT TOP 1 [name] FROM sysobjects WHERE [type] = 'U' AND category = 0 ORDER BY [name]) 
        SELECT @schema = (SELECT TOP 1 schema_name(schema_id) FROM sys.tables WHERE [name] = @name)
    END 
    GO 

    /* Drop all functions */ 
    DECLARE @name VARCHAR(128) 
    DECLARE @SQL VARCHAR(254) 
    DECLARE @schema VARCHAR(128)

    SELECT @name = (SELECT TOP 1 [name] FROM sysobjects WHERE [type] IN (N'FN', N'IF', N'TF', N'FS', N'FT') AND category = 0 ORDER BY [name]) 
    SELECT @schema = (SELECT TOP 1 schema_name(schema_id) FROM sys.objects WHERE [name] = @name)

    WHILE @name IS NOT NULL 
    BEGIN 
        SELECT @SQL = 'DROP FUNCTION [' + @schema + '].[' + RTRIM(@name) +']' 
        EXEC (@SQL) 
        PRINT 'Dropped Function: ' + @name 
        SELECT @name = (SELECT TOP 1 [name] FROM sysobjects WHERE [type] IN (N'FN', N'IF', N'TF', N'FS', N'FT') AND category = 0 AND [name] > @name ORDER BY [name]) 
        SELECT @schema = (SELECT TOP 1 schema_name(schema_id) FROM sys.objects WHERE [name] = @name)
    END 
    GO 

    /* Drop all types */ 
    DECLARE @name VARCHAR(128) 
    DECLARE @SQL VARCHAR(254) 
    DECLARE @schema VARCHAR(128)

    SELECT @name = (SELECT TOP 1 [name] FROM sys.types WHERE is_user_defined = 1 ORDER BY [name]) 
    SELECT @schema = (SELECT TOP 1 schema_name(schema_id) FROM sys.types WHERE [name] = @name)

    WHILE @name IS NOT NULL 
    BEGIN 
        SELECT @SQL = 'DROP TYPE [' + @schema + '].[' + RTRIM(@name) +']' 
        EXEC (@SQL) 
        PRINT 'Dropped type: ' + @name 
        SELECT @name = (SELECT TOP 1 [name] FROM sys.types WHERE is_user_defined = 1 AND [name] > @name ORDER BY [name]) 
        SELECT @schema = (SELECT TOP 1 schema_name(schema_id) FROM sys.types WHERE [name] = @name)
    END 
    GO 