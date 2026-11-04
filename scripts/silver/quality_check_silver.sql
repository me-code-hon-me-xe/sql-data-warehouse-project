USE DataWarehouse;
GO

-- =========================================================================
-- 1. Check for NULLs or Duplicates in Primary Key
--    Expectation: No results
-- =========================================================================
-- Check from crm_cust_info table
SELECT 
    cst_id, 
    COUNT(*) AS [Number of Appearances]
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 
   OR cst_id IS NULL;

-- Check from crm_prd_info
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
SELECT 
    *, 
    ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM silver.crm_cust_info
WHERE cst_id = 29466;

-- =========================================================================
-- 3. Extract the latest record for each duplicated customer ID
-- =========================================================================
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
-- Check crm_cust_info
SELECT cst_marital_status
FROM silver.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status);

-- Check crm_prd_info
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- =========================================================================
-- 5. Check for Data Standardization and Consistency
-- =========================================================================
-- Check crm_cust_info
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;

-- Check crm_prd_info
SELECT DISTINCT prd_line
FROM silver.crm_prd_info


-- =========================================================================
-- 6. Check for Null or Negative number
-- Expectation: No results
-- =========================================================================
-- Check crm_prd_info
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 or prd_cost IS NULL 


-- =========================================================================
-- 7. Check for the invalid date oder
-- Expectation: The shipping date and the due date should greater than the order date
-- =========================================================================
SELECT *
FROM [DataWarehouse].[silver].[crm_sales_details]
WHERE sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt


-- =========================================================================
-- 8. Check the data  consistency: Between sales, quantity and price
-- Expectation: >> Sales = Quantity * Price
--              >> Values must not be Zero, Null or negative
-- =========================================================================
SELECT DISTINCT
*
FROM [DataWarehouse].[silver].[crm_sales_details]
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales


