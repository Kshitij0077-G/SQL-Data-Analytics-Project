
/* =====================================================================================
   SILVER LAYER : CUSTOMER TRANSFORMATION (CRM)
   =====================================================================================

   PURPOSE:
   - Clean and standardize customer data from Bronze layer
   - Deduplicate records (latest per customer)
   - Normalize categorical fields (Gender, Marital Status)

   TRANSFORMATIONS APPLIED:
   - Remove NULL customer IDs
   - Trim string fields (first name, last name)
   - Standardize gender (M/F ? Male/Female)
   - Standardize marital status (S/M ? Single/Married)
   - Deduplicate using latest record logic (ROW_NUMBER)

===================================================================================== */
 
 
/* =========================================================
   SILVER LAYER : CRM CUSTOMER TRANSFORMATION
   - Clean data
   - Normalize values
   - Keep latest record per customer
========================================================= */

CREATE OR ALTER PROCEDURE silver.load_crm_cust_info AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;

    BEGIN TRY
        SET @start_time = GETDATE();

        PRINT '==========================================';
        PRINT 'Loading: Silver.crm_cust_info';
        PRINT '==========================================';

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

EXEC silver.load_crm_cust_info;