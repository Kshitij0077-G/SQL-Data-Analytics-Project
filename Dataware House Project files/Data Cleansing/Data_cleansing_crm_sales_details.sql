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

CREATE OR ALTER PROCEDURE silver.load_crm_sales_details
AS
BEGIN

    DECLARE @start_time DATETIME, @end_time DATETIME;

    BEGIN TRY
        SET @start_time = GETDATE();

        PRINT '==========================================';
        PRINT 'Loading: Silver.crm_sales_details';
        PRINT '==========================================';

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

EXEC silver.load_crm_sales_details