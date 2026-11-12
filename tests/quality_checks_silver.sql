/*
===============================================================================
Quality Checks
===============================================================================
Script purposes: 
    This script performs various qulity checks for data consistency, accuracy and standardization accross the silver layer. It includes checks for: 
    - Null or duplicate primary keys
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/
USE DataWarehouse;
GO

-- =========================================================================
-- 1. Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
-- =========================================================================
-- Checking 'silver.crm_cust_info'
SELECT
    cst_id,
    COUNT(*) AS [Number of Appearances]
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;

-- Checking 'silver.crm_prd_info'
SELECT
    prd_id,
    COUNT(*) AS [Number of Appearances]
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;


-- =========================================================================
-- 2. Inspect a specific duplicated customer ID (Ordered by date descending)
-- =========================================================================
-- Checking 'silver.crm_cust_info'
SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
WHERE cst_id = 29466;

-- =========================================================================
-- 3. Extract the latest record for each duplicated customer ID
-- =========================================================================
-- Checking 'silver.crm_cust_info'
SELECT *
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM silver.crm_cust_info
) t
WHERE flag_last = 1;

-- =========================================================================
-- 4. Check for unwanted spaces (Leading/Trailing spaces)
--    Expectation: No results
-- =========================================================================
-- Checking 'silver.crm_cust_info'
SELECT cst_marital_status
FROM silver.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status);

-- Checking 'silver.crm_prd_info'
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- =========================================================================
-- 5. Check for Data Standardization and Consistency
-- =========================================================================
-- Checking 'silver.crm_cust_info'
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

-- Checking 'silver.crm_prd_info'
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

-- Checking 'silver.erp_cust_az12'
SELECT DISTINCT gen
FROM silver.erp_cust_az12

-- Checking 'silver.erp_loc_a101'
SELECT DISTINCT cntry
FROM silver.erp_loc_a101

-- Checking 'silver.erp_px_cat_g1v2'
SELECT DISTINCT cat
FROM silver.erp_px_cat_g1v2

SELECT DISTINCT subcat
FROM silver.erp_px_cat_g1v2

SELECT DISTINCT maintanence
FROM silver.erp_px_cat_g1v2


-- =========================================================================
-- 6. Check for Null or Negative number
-- Expectation: No results
-- =========================================================================
-- Checking 'silver.crm_prd_info'
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 or prd_cost IS NULL


-- =========================================================================
-- 7. Check for the invalid date oder
-- Expectation: The shipping date and the due date should greater than the order date
-- =========================================================================
-- Checking 'silver.crm_sales_details'
SELECT *
FROM [DataWarehouse].[silver].[crm_sales_details]
WHERE sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt


-- =========================================================================
-- 8. Check the data  consistency: Between sales, quantity and price
-- Expectation: >> Sales = Quantity * Price
--              >> Values must not be Zero, Null or negative
-- =========================================================================
-- Checking 'silver.crm_sales_details'
SELECT DISTINCT
    *
FROM [DataWarehouse].[silver].[crm_sales_details]
WHERE sls_sales != sls_quantity * sls_price
    OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
    OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales


-- =========================================================================
-- 9. Check the data  consistency: Between sales, quantity and price
-- Expectation: >> Sales = Quantity * Price
--              >> Values must not be Zero, Null or negative
-- =========================================================================
-- Checking 'silver.crm_sales_details'
SELECT DISTINCT
    *
FROM [DataWarehouse].[silver].[crm_sales_details]
WHERE sls_sales != sls_quantity * sls_price
    OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
    OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales


-- =========================================================================
-- 10. Check Index out of range for the data bdate
-- Expectation: bdate must smaller than the current date and greater than the date 01-01-1924
-- =========================================================================
-- Checking 'silver.erp_cust_az12'
SELECT DISTINCT
    bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- =========================================================================
-- 11. (SERVING FOR GOLD LAYER) Check for Uniqueness of Customer Key in gold.dim_customers 
-- after LEFT JOIN three tables (silver.erp_cust_az12, silver.erp_loc_a101, silver.dim_customers)
-- Expectation: No Results
-- =========================================================================
-- Checking 'gold.dim_customers'
SELECT
    ci.cst_id,
    COUNT(*) AS total_number_of_id
FROM silver.crm_cust_info ci
    LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
    LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cide
GROUP BY ci.cst_id
HAVING COUNT(*) > 1

-- =========================================================================
-- 11. (SERVING FOR GOLD LAYER) Check for the integrity of 2 columns gender in gold.dim_customers 
-- after LEFT JOIN three tables (silver.erp_cust_az12, silver.erp_loc_a101, silver.dim_customers)
-- Expectation: the gen must be integrity, if 2 values is unmatched, then select the gen of the first column (From crm_cust_info)
-- =========================================================================
-- Checking 'gold.dim_customers'
SELECT
    ci.cst_gndr,
    ca.gen,
    CASE 
        WHEN ci.cst_gndr != ca.gen OR ca.gen IS NULL THEN 'ERROR'
        ELSE 'MATCH' -- Added to handle correct rows clearly
    END AS error_column,
    COUNT(*) AS total_error
FROM silver.crm_cust_info ci
    LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
    LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cide
GROUP BY 
    ci.cst_gndr,
    ca.gen;
GO

-- =========================================================================
-- 12. (SERVING FOR GOLD LAYER) Check for Uniqueness of Product Key in gold.dim_products
-- after LEFT JOIN with table (silver.erp_px_cat_g1v2)
-- Expectation: No Results
-- =========================================================================
-- Checking 'gold.dim_products'

SELECT
    subt.prd_key,
    COUNT(*) AS total_number_of_id
FROM
    (
SELECT
        pn.prd_id,
        pn.cat_id,
        pn.prd_key,
        pn.prd_nm,
        pn.prd_cost,
        pn.prd_line,
        pn.prd_start_dt,
        pc.cat,
        pc.subcat,
        pc.maintanence
    FROM silver.crm_prd_info pn
        LEFT JOIN silver.erp_px_cat_g1v2 pc
        ON pn.cat_id = pc.id
    WHERE pn.prd_end_dt IS NULL -- Filter out all historical data 
) subt
GROUP BY subt.prd_key
HAVING COUNT(*) > 1
GO




