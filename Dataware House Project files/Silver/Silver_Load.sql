/*
===============================================================================
SILVER LAYER – MODULAR STORED PROCEDURES + MASTER PROCEDURE
===============================================================================
Purpose:
- Clean, transform and load data from Bronze → Silver
- Modular execution per table
- Master orchestration for full load

Execution:
1. Run entire script (creates all procedures)
2. Execute:
   EXEC Silver.load_silver;
===============================================================================
*/

EXEC Silver.load_silver;

-- ============================================================
-- 1. CRM CUSTOMER
-- ============================================================
CREATE OR ALTER PROCEDURE Silver.load_crm_cust_info
AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;

    BEGIN TRY
        SET @start_time = GETDATE();

		
       
        PRINT 'Loading: Silver.crm_cust_info';
        PRINT '------------------------------------------';
       

        PRINT '>> Truncating Table: Silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>> Inserting Data Into: Silver.crm_cust_info';

        INSERT INTO silver.crm_cust_info (
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

            TRIM(cst_firstname) AS cst_firstname,   -- remove extra spaces
            TRIM(cst_lastname)  AS cst_lastname,	-- remove extra spaces

            -- Standardize marital status
            CASE 
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'N/A'
            END AS cst_marital_status,

            -- Standardize gender
            CASE 
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'N/A'
            END AS cst_gndr,

            cst_create_date

        FROM (
            -- Get latest record per customer
            SELECT *,
                   ROW_NUMBER() OVER (
                       PARTITION BY cst_id 
                       ORDER BY cst_create_date DESC
                   ) AS flag_last
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) src

        -- Keep only latest record
        WHERE flag_last = 1;

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: ' + 
              CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        PRINT '==========================================';
        PRINT 'Load Completed: Silver.crm_cust_info';
        PRINT '==========================================';

        

    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR IN Silver.crm_prd_info';
        PRINT 'Error Message  : ' + ERROR_MESSAGE();
        PRINT 'Error Number   : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State    : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT 'Error Severity : ' + CAST(ERROR_SEVERITY() AS NVARCHAR);
        PRINT 'Error Line     : ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT '==========================================';
        THROW;
    END CATCH
END;
GO

-- ============================================================
-- 2. CRM PRODUCT
-- ============================================================

/* 
===============================================================================
IMPORTANT PRE-EXECUTION INSTRUCTION
===============================================================================

This script involves transformations that require changes in the target table 
structure (e.g., adding new columns, modifying column names, or changing data types).

Therefore, BEFORE executing the below SELECT / INSERT logic:

1. Ensure the target table is recreated with the updated schema.
2. Run the DDL (DROP + CREATE) script provided below.
3. Only after successful execution of the table creation, proceed with the data transformation query.

! WARNING:
- Do NOT run the entire script at once.
- Execute in sequence:
    Step 1 → Table Creation (DDL)
    Step 2 → Data Transformation (SELECT / INSERT)

===============================================================================
*/




/*IF OBJECT_ID('Silver.crm.prd_info', 'U') IS NOT NULL
	DROP TABLE Silver.crm_prd_info;
CREATE TABLE Silver.crm_prd_info(
    prd_id             INT,
    cat_id             NVARCHAR(50),
    prd_key            NVARCHAR(50),
    prd_nm             NVARCHAR(50),
    prd_cost           INT,
    prd_line           NVARCHAR(50),
    prd_start_dt       DATE,
    prd_end_dt         DATE,
    dwh_create_date    DATETIME2 DEFAULT GETDATE()
);*/

CREATE OR ALTER PROCEDURE Silver.load_crm_prd_info
AS
BEGIN

    DECLARE @start_time DATETIME, @end_time DATETIME;

    BEGIN TRY
        SET @start_time = GETDATE();

		PRINT '                                           '
        PRINT '------------------------------------------';
        PRINT 'Loading: Silver.crm_prd_info';
        PRINT '------------------------------------------';

        -- Step 1: Truncate target table
        PRINT '>> Truncating Table: Silver.crm_prd_info';
        TRUNCATE TABLE Silver.crm_prd_info;

        -- Step 2: Insert transformed data
        PRINT '>> Inserting Data Into: Silver.crm_prd_info';

        INSERT INTO Silver.crm_prd_info (
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

            -- Extract category ID from product key
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,

            -- Extract product key from prd_key column
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,

            -- Check if IDs from 'erp_px_cat_g1v2' and prd_id from 'crm_prd_info' match
            -- This can be used later for joining if required
            -- SELECT DISTINCT ID FROM Bronze.erp_px_cat_g1v2

            prd_nm,

            -- Replace NULL cost with 0
            ISNULL(prd_cost, 0) AS prd_cost,

            -- Map product line codes to descriptive values
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'N/A'
            END AS prd_line,

            -- Convert start date to DATE format
            CAST(prd_start_dt AS DATE) AS prd_start_dt,

            -- 1) Derive End Date from Start Date
            -- Rule: End Date = (Next Record Start Date - 1)
            CAST(
                LEAD(prd_start_dt) OVER (
                    PARTITION BY prd_key 
                    ORDER BY prd_start_dt
                ) - 1 
            AS DATE) AS prd_end_dt

        FROM Bronze.crm_prd_info;

        -- Validation Checks (for data quality)

        -- To check if 'cat_id' does not exist in erp_px_cat_g1v2
        -- WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN
        -- (SELECT DISTINCT ID FROM Bronze.erp_px_cat_g1v2)

        -- To check if product keys are missing in crm_sales_details
        -- WHERE SUBSTRING(prd_key, 7, LEN(prd_key)) NOT IN
        -- (SELECT sls_prd_key FROM Bronze.crm_sales_details)


        -- Step 3: Load duration
        SET @end_time = GETDATE();

        PRINT '>> Load Duration: ' + 
              CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        PRINT '==========================================';
        PRINT 'Load Completed: Silver.crm_prd_info';
        PRINT '==========================================';

    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR IN: Silver.crm_prd_info';

        PRINT 'Message  : ' + ERROR_MESSAGE();
        PRINT 'Number   : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'State    : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT 'Severity : ' + CAST(ERROR_SEVERITY() AS NVARCHAR);
        PRINT 'Line     : ' + CAST(ERROR_LINE() AS NVARCHAR);

        PRINT '==========================================';

        THROW;
    END CATCH

END;
GO

/* 
===============================================================================
	IMPORTANT PRE-EXECUTION INSTRUCTION
===============================================================================

This transformation converts integer-based date columns into DATE format 
and applies business rule corrections on sales and price.

BEFORE running this script:
	1. Ensure the target table (Silver.crm_sales_details) is created with correct structure.
	2. If any column datatype is modified (e.g., INT → DATE), recreate the table.
	3. Execute table creation script first, then run this data load script.

 WARNING:
- Do NOT run the entire script at once.
- Execute in sequence:
    Step 1 → Table Creation (DDL)
    Step 2 → Data Transformation (SELECT / INSERT)

===============================================================================
*/

/*===============================================================================
   --TARGET TABLE (DDL) – RUN FIRST
===============================================================================*/
/*IF OBJECT_ID('Silver.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE Silver.crm_sales_details

CREATE TABLE Silver.crm_sales_details(
	sls_ord_num			NVARCHAR(50),
	sls_prd_key			NVARCHAR(50),
	sls_cust_id			INT,
	sls_order_dt		DATE,
	sls_ship_dt			DATE,
	sls_due_dt			DATE,
	sls_sales			INT,
	sls_quantity		INT,
	sls_price			INT,
	dwh_create_date		DATETIME2 DEFAULT GETDATE()
	)*/
/*===============================================================================*/
CREATE OR ALTER PROCEDURE Silver.load_crm_sales_details
AS
BEGIN

    DECLARE @start_time DATETIME, @end_time DATETIME;

    BEGIN TRY
        SET @start_time = GETDATE();

		PRINT '                                          '
        PRINT '------------------------------------------';
        PRINT 'Loading: Silver.crm_sales_details';
        PRINT '------------------------------------------';

        -- Step 1: Truncate target table
        PRINT '>> Truncating Table: Silver.crm_sales_details';
        TRUNCATE TABLE Silver.crm_sales_details;

        -- Step 2: Insert transformed data
        PRINT '>> Inserting Data Into: Silver.crm_sales_details';

        INSERT INTO Silver.crm_sales_details (
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

        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,

            -- Convert Order Date (INT → DATE)
            CASE 
                WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL  
                    -- treat invalid values (0 or not in YYYYMMDD format) as NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)  
                    -- step 1: INT → VARCHAR (20110105 → '20110105')
                    -- step 2: VARCHAR → DATE ('20110105' → 2011-01-05)
            END AS sls_order_dt,

            -- Convert Ship Date (INT → DATE)
            CASE 
                WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL  
                    -- treat invalid values (0 or incorrect format) as NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)  
                    -- convert INT → VARCHAR → DATE
            END AS sls_ship_dt,

            -- Convert Due Date (INT → DATE)
            CASE 
                WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL  
                    -- treat invalid values (0 or incorrect format) as NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)  
                    -- convert INT → VARCHAR → DATE
            END AS sls_due_dt,


            -- Fix invalid sales values
            CASE 
                WHEN sls_sales IS NULL 
                     OR sls_sales <= 0 
                     OR sls_sales != sls_quantity * ABS(sls_price) 
                     -- if sales is NULL, negative, or not matching (qty * price)
                THEN sls_quantity * ABS(sls_price)  
                     -- recalculate correct sales using quantity * price (ensure positive price)
                ELSE sls_sales  
                     -- keep original value if already valid
            END AS sls_sales,


            sls_quantity,


            -- Derive missing/invalid price
            CASE 
                WHEN sls_price IS NULL 
                     OR sls_price <= 0  
                     -- if price is missing or invalid (zero/negative)
                THEN sls_sales / NULLIF(sls_quantity, 0)  
                     -- derive price = sales / quantity
                     -- NULLIF avoids division by zero error
                ELSE sls_price  
                     -- keep original price if valid
            END AS sls_price

        FROM Bronze.crm_sales_details;


        -- Validation Checks (for data quality)

        -- Check missing product keys
        -- WHERE sls_prd_key NOT IN (SELECT prd_key FROM Silver.crm_prd_info)

        -- Check missing customer IDs
        -- WHERE sls_cust_id NOT IN (SELECT cst_id FROM Silver.crm_cust_info)


        -- Step 3: Load duration
        SET @end_time = GETDATE();

        PRINT '>> Load Duration: ' + 
              CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        PRINT '==========================================';
        PRINT 'Load Completed: Silver.crm_sales_details';
        PRINT '==========================================';

    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR IN: Silver.crm_sales_details';

        PRINT 'Message  : ' + ERROR_MESSAGE();
        PRINT 'Number   : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'State    : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT 'Severity : ' + CAST(ERROR_SEVERITY() AS NVARCHAR);
        PRINT 'Line     : ' + CAST(ERROR_LINE() AS NVARCHAR);

        PRINT '==========================================';

        THROW;
    END CATCH

END;
GO

-- ============================================================
-- ERP CUSTOMER
-- ============================================================
CREATE OR ALTER PROCEDURE Silver.load_erp_cust_az12
AS
BEGIN
    

    DECLARE @start_time DATETIME, @end_time DATETIME;

    BEGIN TRY
        SET @start_time = GETDATE();
		PRINT '------------------------------------------';
        PRINT 'Loading: Silver.erp_cust_az12';
        PRINT '------------------------------------------';
		PRINT '                                          '

        PRINT '>> Truncating Table: Silver.erp_cust_az12';
        TRUNCATE TABLE Silver.erp_cust_az12;

        PRINT '>> Inserting Data Into: Silver.erp_cust_az12';

        INSERT INTO Silver.erp_cust_az12(
            cid,
            bdate,
            gen
        )
		   SELECT

            -- Remove 'NAS' prefix from customer ID if present
            CASE
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))  -- Remove first 3 characters
                ELSE cid  -- Keep original value if no prefix
            END AS cid,

            -- Replace future birthdates with NULL (data quality fix)
            CASE
                WHEN bdate > GETDATE() THEN NULL  -- Invalid future date
                ELSE bdate  -- Keep valid date
            END AS bdate,

            -- Standardize gender values to consistent format
            CASE
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'  -- Normalize female values
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'      -- Normalize male values
                ELSE 'N/A'  -- Handle unknown or missing values
            END AS gen

        FROM Bronze.erp_cust_az12;

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
    
		PRINT '==========================================';
        PRINT 'Load Completed: Silver.erp_cust_az12';
        PRINT '==========================================';
    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR IN Silver.erp_cust_az12';
        PRINT 'Error Message  : ' + ERROR_MESSAGE();
        PRINT 'Error Number   : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State    : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT 'Error Severity : ' + CAST(ERROR_SEVERITY() AS NVARCHAR);
        PRINT 'Error Line     : ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT '==========================================';
        THROW;
    END CATCH
END;
GO 

-- ============================================================
-- 5. ERP LOCATION
-- ============================================================
CREATE OR ALTER PROCEDURE Silver.load_erp_loc_a101
AS
	BEGIN
    
		DECLARE @start_time DATETIME, @end_time DATETIME;

		BEGIN TRY
			SET @start_time = GETDATE();

			PRINT '                                          ' 
			PRINT '------------------------------------------'
			PRINT 'Loading: Silver.erp_loc_a101';
			PRINT '------------------------------------------'
			PRINT '                                          '

			PRINT '>> Truncating Table: Silver.erp_loc_a101';
			TRUNCATE TABLE Silver.erp_loc_a101;

			PRINT '>> Inserting Data Into: Silver.erp_loc_a101';

			INSERT INTO Silver.erp_loc_a101(
				cid,
				cntry
			)

			SELECT
				REPLACE(cid, '-', '') AS cid,

				CASE
					WHEN TRIM(cntry) = 'DE' THEN 'Germany'  -- Standardize country
					WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'  -- Normalize values
					WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'  -- Handle missing values
					ELSE TRIM(cntry)  -- Clean spaces
				END AS cntry

			FROM Bronze.erp_loc_a101;

			SET @end_time = GETDATE();

			PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
    
			PRINT '==========================================';
			PRINT 'Load Completed: Silver.erp_loc_a101';
			PRINT '==========================================';

		END TRY
		BEGIN CATCH
			PRINT '==========================================';
			PRINT 'ERROR IN Silver.erp_loc_a101';
			PRINT 'Error Message  : ' + ERROR_MESSAGE();
			PRINT 'Error Number   : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
			PRINT 'Error State    : ' + CAST(ERROR_STATE() AS NVARCHAR);
			PRINT 'Error Severity : ' + CAST(ERROR_SEVERITY() AS NVARCHAR);
			PRINT 'Error Line     : ' + CAST(ERROR_LINE() AS NVARCHAR);
			PRINT '==========================================';

			THROW;
		END CATCH
	END;
GO

-- ============================================================
-- 6. ERP PRODUCT CATEGORY
-- ============================================================

CREATE OR ALTER PROCEDURE Silver.load_erp_px_cat_g1v2
AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;

    BEGIN TRY
        SET @start_time = GETDATE();

		PRINT '                                          ' 
		PRINT '------------------------------------------';
        PRINT 'Loading: Silver.erp_px_cat_g1v2';
        PRINT '------------------------------------------';

        PRINT '>> Truncating Table: Silver.erp_px_cat_g1v2';
        TRUNCATE TABLE Silver.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into: Silver.erp_px_cat_g1v2';
        INSERT INTO Silver.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
            id,          -- Product ID (no transformation)
            cat,         -- Category (as-is)
            subcat,      -- Subcategory (as-is)
            maintenance  -- Maintenance flag (as-is)
        FROM Bronze.erp_px_cat_g1v2; 

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: ' + 
              CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		PRINT '==========================================';
        PRINT 'Load Completed: Silver.erp_px_cat_g1v2';
        PRINT '==========================================';

    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR IN Silver.erp_px_cat_g1v2';
        PRINT 'Error Message  : ' + ERROR_MESSAGE();
        PRINT 'Error Number   : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State    : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT 'Error Severity : ' + CAST(ERROR_SEVERITY() AS NVARCHAR);
        PRINT 'Error Line     : ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT '==========================================';

        THROW;
    END CATCH
END;
GO
-- ============================================================
-- MASTER PROCEDURE
-- ============================================================
CREATE OR ALTER PROCEDURE Silver.load_silver
AS
BEGIN
    

    DECLARE @batch_start_time DATETIME, @batch_end_time DATETIME;

    BEGIN TRY
        SET @batch_start_time = GETDATE();
		PRINT '                                                '
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

        PRINT '                                                '
        PRINT 'Loading CRM Tables';
        PRINT '------------------------------------------------';

        EXEC Silver.load_crm_cust_info;
        EXEC Silver.load_crm_prd_info;
        EXEC Silver.load_crm_sales_details;

        PRINT '                                                '
        PRINT 'Loading ERP Tables';
        PRINT '------------------------------------------------';

        EXEC Silver.load_erp_cust_az12;
        EXEC Silver.load_erp_loc_a101;
        EXEC Silver.load_erp_px_cat_g1v2;

        SET @batch_end_time = GETDATE();

        PRINT '******************************************';
        PRINT 'Loading Silver Layer is Completed';
        PRINT 'Total Load Duration: ' + 
              CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '******************************************';

    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
        PRINT 'Error Message  : ' + ERROR_MESSAGE();
        PRINT 'Error Number   : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State    : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT 'Error Severity : ' + CAST(ERROR_SEVERITY() AS NVARCHAR);
        PRINT 'Error Line     : ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT '==========================================';

        THROW;
    END CATCH
END;
GO