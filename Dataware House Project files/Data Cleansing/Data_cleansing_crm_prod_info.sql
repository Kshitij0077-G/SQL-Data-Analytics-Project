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



CREATE OR ALTER PROCEDURE silver.load_crm_prd_info
AS
BEGIN

    DECLARE @start_time DATETIME, @end_time DATETIME;

    BEGIN TRY
        SET @start_time = GETDATE();

        PRINT '==========================================';
        PRINT 'Loading: Silver.crm_prd_info';
        PRINT '==========================================';

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