/* =====================================================================================
   BRONZE LAYER : DATA INGESTION PIPELINE
   =====================================================================================

   PURPOSE:
   - Load raw CSV data into Bronze tables
   - Apply minimal transformation (as-is ingestion)
   - Implement error handling & execution time tracking

   FEATURES:
   - Modular stored procedures (per table)
   - Centralized master procedure
   - Execution logging (start/end time)
   - Robust error handling

===================================================================================== */


-- =====================================================================================
-- EXECUTION ENTRY POINT
-- =====================================================================================
EXEC Bronze.load_Bronze;
--GO


/* =========================================================
   CRM CUSTOMER
========================================================= */
CREATE OR ALTER PROCEDURE Bronze.load_crm_cust_info
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start_time DATETIME = GETDATE();
    DECLARE @end_time DATETIME;

    PRINT'                                           '
    PRINT 'Loading CRM CUSTOMER TABLE';
    PRINT 'Start Time: ' + CAST(@start_time AS VARCHAR);
    PRINT'-------------------------------------------'

    PRINT '>> Truncating Table: Bronze.crm_cust_info';
    TRUNCATE TABLE Bronze.crm_cust_info;

    PRINT '>> Inserting Data Into | Table: Bronze.crm_cust_info';
    BULK INSERT Bronze.crm_cust_info
    FROM 'C:\Users\Xitij.G\Desktop\SQL DATAWARE HOUSE PROJECT\datasets\source_crm\cust_info.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );

    SET @end_time = GETDATE();

    PRINT 'End Time: ' + CAST(@end_time AS VARCHAR);
    PRINT 'Duration (sec): ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR);
END;
GO


/* =========================================================
   CRM PRODUCT
========================================================= */
CREATE OR ALTER PROCEDURE Bronze.load_crm_prd_info
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start_time DATETIME = GETDATE();
    DECLARE @end_time DATETIME;

	PRINT'                                           '
    PRINT 'Loading CRM PRODUCT TABLE';
    PRINT 'Start Time: ' + CAST(@start_time AS VARCHAR);
    PRINT '-------------------------------------------'

    PRINT '>> Truncating Table: Bronze.crm_prd_info';
    TRUNCATE TABLE Bronze.crm_prd_info;

    PRINT '>> Inserting Data Into | Table: Bronze.crm_prd_info';
    BULK INSERT Bronze.crm_prd_info
    FROM 'C:\Users\Xitij.G\Desktop\SQL DATAWARE HOUSE PROJECT\datasets\source_crm\prd_info.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );

    SET @end_time = GETDATE();

    PRINT 'End Time: ' + CAST(@end_time AS VARCHAR);
    PRINT 'Duration (sec): ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR);
END;
GO


/* =========================================================
   CRM SALES
========================================================= */
CREATE OR ALTER PROCEDURE Bronze.load_crm_sales_details
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start_time DATETIME = GETDATE();
    DECLARE @end_time DATETIME;

    PRINT'                                           '
    PRINT 'Loading CRM SALES TABLE';
    PRINT 'Start Time: ' + CAST(@start_time AS VARCHAR);
    PRINT '-------------------------------------------'

    PRINT '>> Truncating Table: Bronze.crm_sales_details';
    TRUNCATE TABLE Bronze.crm_sales_details;

    PRINT '>> Inserting Data Into | Table: Bronze.crm_sales_details';
    BULK INSERT Bronze.crm_sales_details
    FROM 'C:\Users\Xitij.G\Desktop\SQL DATAWARE HOUSE PROJECT\datasets\source_crm\sales_details.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );

    SET @end_time = GETDATE();

    PRINT 'End Time: ' + CAST(@end_time AS VARCHAR);
    PRINT 'Duration (sec): ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR);
END;
GO


/* =========================================================
   ERP CUSTOMER
========================================================= */
CREATE OR ALTER PROCEDURE Bronze.load_erp_cust_az12
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start_time DATETIME = GETDATE();
    DECLARE @end_time DATETIME;

    PRINT'                                           '
    PRINT 'Loading ERP CUSTOMER TABLE';
    PRINT 'Start Time: ' + CAST(@start_time AS VARCHAR);
    PRINT '------------------------------------------';

    PRINT '>> Truncating Table: Bronze.erp_cust_az12';
    TRUNCATE TABLE Bronze.erp_cust_az12;

    PRINT '>> Inserting Data Into | Table: Bronze.erp_cust_az12';
    BULK INSERT Bronze.erp_cust_az12
    FROM 'C:\Users\Xitij.G\Desktop\SQL DATAWARE HOUSE PROJECT\datasets\source_erp\cust_az12.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );

    SET @end_time = GETDATE();

    PRINT 'End Time: ' + CAST(@end_time AS VARCHAR);
    PRINT 'Duration (sec): ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR);
END;
GO


/* =========================================================
   ERP LOCATION
========================================================= */
CREATE OR ALTER PROCEDURE Bronze.load_erp_loc_a101
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start_time DATETIME = GETDATE();
    DECLARE @end_time DATETIME;

    PRINT'                                           '
    PRINT 'Loading ERP LOCATION TABLE';
    PRINT 'Start Time: ' + CAST(@start_time AS VARCHAR);
    PRINT '-------------------------------------------'

    PRINT '>> Truncating Table: Bronze.erp_loc_a101';
    TRUNCATE TABLE Bronze.erp_loc_a101;

    PRINT '>> Inserting Data Into | Table: Bronze.erp_loc_a101';
    BULK INSERT Bronze.erp_loc_a101
    FROM 'C:\Users\Xitij.G\Desktop\SQL DATAWARE HOUSE PROJECT\datasets\source_erp\loc_a101.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );

    SET @end_time = GETDATE();

    PRINT 'End Time: ' + CAST(@end_time AS VARCHAR);
    PRINT 'Duration (sec): ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR);
END;
GO


/* =========================================================
   ERP CATEGORY
========================================================= */
CREATE OR ALTER PROCEDURE Bronze.load_erp_px_cat_g1v2
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start_time DATETIME = GETDATE();
    DECLARE @end_time DATETIME;

    PRINT'                                           '
    PRINT 'Loading ERP CATEGORY TABLE';
    PRINT 'Start Time: ' + CAST(@start_time AS VARCHAR);
    PRINT '-------------------------------------------'

    PRINT '>> Truncating Table: Bronze.erp_px_cat_g1v2';
    TRUNCATE TABLE Bronze.erp_px_cat_g1v2;

    PRINT '>> Inserting Data Into | Table: Bronze.erp_px_cat_g1v2';
    BULK INSERT Bronze.erp_px_cat_g1v2
    FROM 'C:\Users\Xitij.G\Desktop\SQL DATAWARE HOUSE PROJECT\datasets\source_erp\px_cat_g1v2.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );

    SET @end_time = GETDATE();

    PRINT 'End Time: ' + CAST(@end_time AS VARCHAR);
    PRINT 'Duration (sec): ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR);
	PRINT'                                           '
END;
GO


/* =========================================================
   MASTER ORCHESTRATION PROCEDURE
========================================================= */
CREATE OR ALTER PROCEDURE Bronze.load_Bronze
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start_time DATETIME = GETDATE();
    DECLARE @end_time DATETIME;

    BEGIN TRY

        PRINT'                                           '
        PRINT 'BRONZE LOAD STARTED';
        PRINT 'Start Time: ' + CAST(@start_time AS VARCHAR);
        PRINT '==========================================';

		PRINT'-------------------------------------------'
        PRINT '>> Executing CRM LOADS';
		PRINT'-------------------------------------------'
        EXEC Bronze.load_crm_cust_info;
        EXEC Bronze.load_crm_prd_info;
        EXEC Bronze.load_crm_sales_details;

		PRINT'                                           '
		PRINT'================================================================'
		PRINT'                                           '

		PRINT'-------------------------------------------'
        PRINT '>> Executing ERP LOADS';
		PRINT'-------------------------------------------'
        EXEC Bronze.load_erp_cust_az12;
        EXEC Bronze.load_erp_loc_a101;
        EXEC Bronze.load_erp_px_cat_g1v2;


        SET @end_time = GETDATE();

        PRINT '==========================================';
        PRINT 'BRONZE LOAD COMPLETED';
        PRINT 'End Time: ' + CAST(@end_time AS VARCHAR);
        PRINT 'Total Duration (sec): ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR);
        PRINT '==========================================';

    END TRY
    BEGIN CATCH
        PRINT 'DATA LOADING FAILED';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO