

--SELECT * FROM Silver.erp_cust_az12
BEGIN
    

    DECLARE @start_time DATETIME, @end_time DATETIME;

    BEGIN TRY
        SET @start_time = GETDATE();
		PRINT '==========================================';
        PRINT 'Loading: Silver.erp_cust_az12';
        PRINT '==========================================';
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
    
		PRINT '------------------------------------------';
        PRINT 'Load Completed: Silver.erp_cust_az12';
        PRINT '------------------------------------------';
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

