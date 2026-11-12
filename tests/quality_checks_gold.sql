/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency,
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/
USE DataWarehouse;
GO

-- =========================================================================
-- 1. Check for Uniqueness of Customer Key in gold.dim_customers 
--    after LEFT JOIN
-- Expectation: No Results
-- =========================================================================
SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;
GO

-- =========================================================================
-- 2. Check for Uniqueness of gender
-- Expectation: No Results
-- =========================================================================
SELECT Distinct
    gender
FROM DataWarehouse.gold.dim_customers;
GO


-- =========================================================================
-- 3. Check for Uniqueness of Product Key in gold.dim_products 
--    after LEFT JOIN
-- Expectation: No Results
-- =========================================================================
SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;
GO


-- =========================================================================
-- 4. Check the Foreign Key Integrity in gold.dim_products 
--    after LEFT JOIN
-- Expectation: No Results
-- =========================================================================
SELECT 
    *
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
    ON fs.customer_key = dc.customer_key
WHERE fs.customer_key IS NULL;
GO

SELECT 
    *
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp
    ON fs.product_key = dp.product_key
WHERE fs.product_key IS NULL;
GO
