--SELECT * FROM Silver.erp_loc_a101

BEGIN
    
    DECLARE @start_time DATETIME, @end_time DATETIME;

    BEGIN TRY
        SET @start_time = GETDATE();

        PRINT '==========================================';
        PRINT 'Loading: Silver.erp_loc_a101';
        PRINT '==========================================';
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
    
        PRINT '------------------------------------------';
        PRINT 'Load Completed: Silver.erp_loc_a101';
        PRINT '------------------------------------------';

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
