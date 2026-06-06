/*
===================================================================
Script for Stored Procedure of the 'Bronze Layer'

Script purpose:
          This stored procedure loads the data into the bronze layer from external csv files
          It performs the following actions:
          - Truncates the tables every single time
          - Loads the data using `BULK INSERT` command
Parameters:
          None
          This stored procedure does not accpet any parameters or return any values.

Usage Example:
          Exec bronze.load_bronze;
=====================================================================
*/

CREATE OR ALTER  PROCEDURE bronze.load_bronze 
AS
BEGIN 
    DECLARE @start_time DATETIME, @end_time DATETIME,@batch_start DATETIME,@batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start = GETDATE();
        PRINT '==============================================';
        PRINT 'Loading Bronze Layer';
        PRINT '==============================================';
    
        PRINT '----------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '----------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info

        PRINT '>> Insterting Data Into: bronze_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\udvek\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '---------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info

        PRINT '>> Inserting Data Into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\udvek\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '---------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details

        PRINT '>> Inserting Data Into: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\udvek\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '---------------------------';

        PRINT '----------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '----------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12

        PRINT 'Insert Data Into: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\udvek\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '---------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101

        PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\udvek\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.CSV'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '---------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2

        PRINT '>> Inserting Data Into: bronze.erp_px_cat_pg1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\udvek\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH(
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '---------------------------';

        SET @batch_end_time = GETDATE();
        PRINT 'Loading Bronze Layer is completed.';
        PRINT '  - Total time duration to load the bronze layer is: ' + CAST(DATEDIFF(SECOND,@batch_start,@batch_end_time) AS NVARCHAR)+' seconds';
        PRINT '======================================================================';
    END TRY
    BEGIN CATCH
        PRINT '=======================================';
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message' + ERROR_MESSAGE();
        PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error message' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '=======================================';
    END CATCH
END;

