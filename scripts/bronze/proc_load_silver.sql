/*
===========================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver) 
    This stored procedure performs the ETL (Extract,Transform and Load) process
    to populate the 'silver tables from bronze layer'
Actions Performed:
    - Truncate Silver tables
    - inserts transformed and cleaned data from Bronze layer to Silver layer
Parameters:
    None
    This stored procedure does not accept any parameters or return no values
Usage Examples:
    EXEC silver.load_silver;
===========================================================================================
*/


CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME,@batch_start DATETIME,@batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start = GETDATE();
        PRINT '==============================================';
        PRINT 'Loading Silver Layer';
        PRINT '==============================================';
    
        PRINT '----------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '----------------------------------------------';

        SET @start_time = GETDATE();
        PRINT'>> INserting Data Into : silver.crm_cust_info';

        TRUNCATE TABLE silver.crm_cust_info

        INSERT INTO silver.crm_cust_info(
	        cst_id,
	        cst_key,
	        cst_firstname,
	        cst_lastname,
	        cst_marital_status,
	        cst_gender,
	        cst_create_date)

        SELECT 
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_first_name, -- trims the extra spaces in the column first name
        TRIM(cst_lastname) AS cst_lastname,    -- trims the extra spaces in the column last name
        CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'  -- converts every 's' value to 'single'
	        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'  -- converts every 'm' value to 'married'
	        ELSE 'n/a'
        END cst_marital_status,
        CASE WHEN UPPER(TRIM(cst_gender)) = 'F' THEN 'Female'  -- converts every 'F' value to 'Female'
	        WHEN UPPER(TRIM(cst_gender)) = 'M' THEN 'Male'     -- c
	        ELSE 'n/a'
        END cst_gender,
        cst_create_date

        FROM(

        SELECT *,
        ROW_NUMBER()OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
        FROM bronze.crm_cust_info
        )t
        WHERE flag_last = 1
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '---------------------------';

        SET @start_time = GETDATE();
        PRINT'>>Inserting Data Into: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details

        INSERT INTO silver.crm_sales_details(
               sls_ord_num,
               sls_prd_key,
               sls_cust_id,
               sls_order_dt,
               sls_ship_dt,
               sls_due_dt,
               sls_sales,
               sls_quantity,
               sls_price
        )
        SELECT [sls_ord_num],
              [sls_prd_key],
              [sls_cust_id],
              CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                    ELSE CAST(CAST(sls_order_dt AS VARCHAR)AS DATE)
              END AS sls_order_dt,

              CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                    ELSE CAST(CAST(sls_ship_dt AS VARCHAR)AS DATE)
              END AS sls_ship_dt,

              CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                    ELSE CAST(CAST(sls_due_dt AS VARCHAR)AS DATE)
              END AS sls_due_dt, 

              CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
               ELSE sls_sales
              END AS sls_sales, -- Recalculate sales if the original value is missing or incorrect

              [sls_quantity],
              CASE WHEN sls_price IS NULL OR sls_price <= 0
                THEN sls_sales / NULLIF(sls_quantity,0)
                ELSE sls_price
              END AS sls_price  -- Derive price if original value is missing or incorrect
    
          FROM [DataWareHouse].[bronze].[crm_sales_details]
          WHERE sls_sales != sls_quantity * sls_price
          OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
          SET @end_time = GETDATE();
          PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
          PRINT '---------------------------'; 

        SET @start_time = GETDATE();
        PRINT'>>Inserting Data Into: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12

        INSERT INTO silver.erp_cust_az12(
	        cid,
	        bdate,
	        gen
        )

        SELECT * FROM bronze.erp_cust_az12

        PRINT'>>Inserting Data Into: silver.erp_loc_a101';

        TRUNCATE TABLE silver.erp_loc_a101

        INSERT INTO silver.erp_loc_a101(cid,cntry)

        SELECT 
	        REPLACE(cid,'-','') AS cid,
	        CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		        WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
		        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
		        ELSE cntry
	        END AS cntry
        FROM bronze.erp_loc_a101
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '---------------------------';
    
        SET @start_time = GETDATE();
        PRINT'>>Inserting Data Into: silver.erp_px_cat_g1v2';

        TRUNCATE TABLE silver.erp_px_cat_g1v2

        INSERT INTO silver.erp_px_cat_g1v2(
            id,
            cat,
            subcat,
            maintenance)
        SELECT 
            id,
            cat,
            subcat,
            maintenance
        FROM bronze.erp_px_cat_g1v2
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
        PRINT '---------------------------';

        SET @batch_end_time = GETDATE();
            PRINT 'Loading Silver Layer is completed.';
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
END
