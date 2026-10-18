/*
======================================================
Create Database and Schemas
======================================================

Script purpose: 
    This scripts create a new database named 'DataWarehouse' after checking it already exits.
    If the database exits, it is droped and recreated. Additionally, the script set up three schemas 
    within the database: 'bronze', 'silver' and 'gold'.

Warning: 
    Running this script will drop the entire 'DataWarehouse' database if it exits.
    All the data in the database will be permanently deleted. Proceed with caution and 
    ensure you have proper backups before running this scirpts.
*/



USE master;
GO

-- Drop and recreate the 'DataWarehous' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehous SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END
GO

-- Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
