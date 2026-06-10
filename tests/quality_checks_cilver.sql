/*
=======================================
Quality Checks
======================================
Script Pirpose:
    This script is used to perform various quality checks on the data in silver layer
    - NULL or duplicate primary keys
    - Unwanted spaces in string files
    - Data Standardisation and Consistency
    - Invalid date range and orders
    - Data consistency between related fields
Usage Notes:
    - Run these checks for all the tables in 'Silver Layer'
    - Investigate and resolve if any standards are not met
*/

/*
======================================
Checking the quality of data in 'silver.crm_cust_info' table
======================================
*/
-- Checking for Duplicate Primary keys
SELECT 
cst_id,
count(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*)>1 OR cst_id IS NULL

--Checking for unwanted spaces
--Expectation: No results
SELECT cst_firstname FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT cst_lastname FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

SELECT cst_gender FROM silver.crm_cust_info
WHERE cst_gender != TRIM(cst_gender)

--Data Standardization and Consistency
SELECT DISTINCT cst_gender FROM silver.crm_cust_info

SELECT DISTINCT cst_marital_status FROM silver.crm_cust_info

/*
===========================================
Checking for data quality in 'silver.crm_prd_info' table
===========================================
*/
-- Checking for the duplicates in the primary key
SELECT prd_id,COUNT(*) FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

--Check if prd_name has unwanted spaces
SELECT prd_nm FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

--Check if prd_cost has any NULLS or -ve
SELECT prd_cost FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

--Data Standardisation & Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

--Check data consistency for dates
SELECT * FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

/*
===========================================
Checking for data quality in 'silver.erp_cust_az12' table
===========================================
*/
-- Identifying out of range dates
SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Data Standardisation & Consistency
SELECT DISTINCT gen 
FROM silver.erp_cust_az12

/*
===========================================
Cheeckung for data quality in 'silver.erp_loc_a101' table
==========================================
*/
-- Data Standardisation & Consistency
SELECT DISTINCT cntry 
FROM silver.erp_loc_a101

/*
=============================================
Checking for data quality in 'silver.erp_px_cat_g1v2' table
=============================================
*/
-- Checking for unwated spaces
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR
	subcat != TRIM(subcat) OR
	maintenance != TRIM(maintenance)

-- Data Standardisation & Consistency
SELECT DISTINCT
cat
FROM silver.erp_px_cat_g1v2
