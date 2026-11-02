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
