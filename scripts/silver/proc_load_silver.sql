/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to
    populate the 'silver' schema tables from the 'bronze' schema.
    Actions Performed:
        - Truncates Silver tables.
        - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None.
      This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/
USE DataWarehouse
GO

-- Loading silver.crm_cust_info
INSERT INTO silver.crm_cust_info
    (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
    )
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE 
    WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
    WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
    ELSE 'n/a'
END AS cst_marital_status, -- Normalize marital status values to readable format (Transformation)
    CASE 
    WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
    WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
    ELSE 'n/a' -- Handle missing data
END AS cst_gndr, -- Normalize gender values to readable format (Transformation)
    cst_create_date 
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id is not NULL
)t
WHERE flag_last = 1 -- Select the most recent record per customer


-- Loading silver.crm_prd_info
INSERT INTO silver.crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Extract category ID (Extract)
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,        -- Extract product key (Extract)
    prd_nm,
    ISNULL(prd_cost, 0) AS prd_cost,
    CASE UPPER(TRIM(prd_line))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'n/a'       -- Handle missing data                       
    END AS prd_line,     -- Normalize product line code to readable format (Transformation)
    CAST(prd_start_dt AS DATE), -- Cast the data type (Transformation)
    CAST(
        LEAD(prd_start_dt, 1) OVER (PARTITION BY prd_key ORDER BY prd_start_dt ASC)-1 
        AS DATE
    ) AS prd_end_dt -- Calculate end date as one day before the next start date (Data Enrichment)
FROM bronze.crm_prd_info

-- Loading silver.crm_sales_details