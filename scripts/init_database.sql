/*
===========================================================
Create Databases and Schemas
===========================================================
Scripts Purpose:
  This script new database named "DataWareHouse". Additionally , the scripts sets up 3 schemas called 
  'bronze','silver','gold'
  within the database.
*/

-- Create a database in master 
USE master;

CREATE DATABASE DataWareHouse;

-- Use the created database to create schemas and tables
USE DataWareHouse;

--Create schemas bronze, silver, gold
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
