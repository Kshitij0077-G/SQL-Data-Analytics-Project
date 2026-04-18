
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;

    BEGIN TRY
        SET @start_time = GETDATE();

		PRINT '==========================================';
        PRINT 'Loading: Silver.erp_px_cat_g1v2';
        PRINT '==========================================';

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