USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '=====================================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '=====================================================================';

        PRINT '---------------------------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '---------------------------------------------------------------------';

        
        -- =====================================================================
        -- 1. LOAD: crm_cust_info
        -- =====================================================================
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: DataWarehouse.bronze.crm_cust_info';
        TRUNCATE TABLE DataWarehouse.bronze.crm_cust_info;

        PRINT '>> Inserting Data into: DataWarehouse.bronze.crm_cust_info';
        BULK INSERT DataWarehouse.bronze.crm_cust_info
        FROM '/var/opt/mssql/datasets/source_crm/cust_info.csv'  
        WITH (
            FIRSTROW = 2,         
            FIELDTERMINATOR = ',', 
            ROWTERMINATOR = '\n',  
            TABLOCK                
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' secconds';
        PRINT '------------------------------';
        
        -- =====================================================================
        -- 2. LOAD: crm_prd_info
        -- =====================================================================
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: DataWarehouse.bronze.crm_prd_info';
        TRUNCATE TABLE DataWarehouse.bronze.crm_prd_info;

        PRINT '>> Inserting Data into: DataWarehouse.bronze.crm_prd_info';
        BULK INSERT DataWarehouse.bronze.crm_prd_info
        FROM '/var/opt/mssql/datasets/source_crm/prd_info.csv'  
        WITH (
            FIRSTROW = 2,         
            FIELDTERMINATOR = ',', 
            ROWTERMINATOR = '\n',  
            TABLOCK                
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' secconds';
        PRINT '------------------------------';  

        -- =====================================================================
        -- 3. LOAD: crm_sales_details
        -- =====================================================================
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: DataWarehouse.bronze.crm_sales_details';
        TRUNCATE TABLE DataWarehouse.bronze.crm_sales_details;

        PRINT '>> Inserting Data into: DataWarehouse.bronze.crm_sales_details';
        BULK INSERT DataWarehouse.bronze.crm_sales_details
        FROM '/var/opt/mssql/datasets/source_crm/sales_details.csv'  
        WITH (
            FIRSTROW = 2,         
            FIELDTERMINATOR = ',', 
            ROWTERMINATOR = '\n',  
            TABLOCK                
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' secconds';
        PRINT '------------------------------';



        PRINT '---------------------------------------------------------------------'
        PRINT 'Loading ERP Tables'
        PRINT '---------------------------------------------------------------------'

        -- =====================================================================
        -- 4. LOAD: erp_cust_az12
        -- =====================================================================
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: DataWarehouse.bronze.erp_cust_az12';
        TRUNCATE TABLE DataWarehouse.bronze.erp_cust_az12;

        PRINT '>> Inserting Data into: DataWarehouse.bronze.erp_cust_az12';
        BULK INSERT DataWarehouse.bronze.erp_cust_az12
        FROM '/var/opt/mssql/datasets/source_erp/CUST_AZ12.csv'  
        WITH (
            FIRSTROW = 2,         
            FIELDTERMINATOR = ',', 
            ROWTERMINATOR = '\n',  -- Added for Mac-to-Docker compatibility
            TABLOCK                
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' secconds';
        PRINT '------------------------------';


        -- =====================================================================
        -- 5. LOAD: erp_loc_a101
        -- =====================================================================
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: DataWarehouse.bronze.erp_loc_a101';
        TRUNCATE TABLE DataWarehouse.bronze.erp_loc_a101;

        PRINT '>> Inserting Data into: DataWarehouse.bronze.erp_loc_a101';
        BULK INSERT DataWarehouse.bronze.erp_loc_a101
        FROM '/var/opt/mssql/datasets/source_erp/LOC_A101.csv'  
        WITH (
            FIRSTROW = 2,         
            FIELDTERMINATOR = ',', 
            ROWTERMINATOR = '\n',  -- Added for Mac-to-Docker compatibility
            TABLOCK                
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' secconds';
        PRINT '------------------------------';

        -- =====================================================================
        -- 6. LOAD: erp_px_cat_g1v2
        -- =====================================================================
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: DataWarehouse.bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE DataWarehouse.bronze.erp_px_cat_g1v2;

        PRINT '>> Inserting Data into: DataWarehouse.bronze.erp_px_cat_g1v2';
        BULK INSERT DataWarehouse.bronze.erp_px_cat_g1v2
        FROM '/var/opt/mssql/datasets/source_erp/PX_CAT_G1V2.csv'  
        WITH (
            FIRSTROW = 2,         
            FIELDTERMINATOR = ',', 
            ROWTERMINATOR = '\n',  -- Added for Mac-to-Docker compatibility
            TABLOCK                
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' secconds';
        PRINT '------------------------------';
        SET @batch_end_time = GETDATE();
        PRINT '=====================================================================';
        PRINT 'Loading Bronze Layer is Completed'
        PRINT '     - Total Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' secconds';
        PRINT '=====================================================================';

    END TRY
    BEGIN CATCH
        PRINT '=========================================';
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
        PRINT 'ERROR MESSAGE' + CAST (ERROR_NUMBER() AS NVARCHAR);
        PRINT 'ERROR MESSAGE' + CAST (ERROR_STATE() AS NVARCHAR);
        PRINT '=========================================';
    END CATCH
END;
GO
