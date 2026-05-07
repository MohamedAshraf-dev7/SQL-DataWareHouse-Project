
CREATE OR ALTER PROCEDURE bronze.load_bronze AS

BEGIN
DECLARE @start_time DATETIME , @end_time DATETIME,@start_total_time DATETIME,@end_total_time DATETIME;
BEGIN TRY
SET @start_total_time = GETDATE();
    PRINT '=============================';
	PRINT 'LOADING BRONZE LAYER';
	PRINT '=============================';

	PRINT '-----------------------------';
	PRINT 'LOADING CRM TABLES'
	PRINT '-----------------------------';


	SET @start_time = GETDATE();
	TRUNCATE TABLE bronze.crm_cust_info;
	BULK INSERT bronze.crm_cust_info
	FROM 'C:\Users\user\Downloads\SQL\source_crm\cust_info.csv'
	WITH
	(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
	SET @end_time = GETDATE();
	PRINT 'Time taken to load : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
	PRINT '-----------------------------';
	SET @start_time = GETDATE();
	TRUNCATE TABLE bronze.crm_sales_details;
	BULK INSERT bronze.crm_sales_details
	FROM 'C:\Users\user\Downloads\SQL\source_crm\sales_details.csv'
	WITH
	(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
    SET @end_time = GETDATE();
	PRINT 'Time taken to load : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
	PRINT '-----------------------------';
	SET @start_time = GETDATE();
	TRUNCATE TABLE bronze.crm_prd_info;
	BULK INSERT bronze.crm_prd_info
	FROM 'C:\Users\user\Downloads\SQL\source_crm\prd_info.csv'
	WITH
	(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
	SET @end_time = GETDATE();
	PRINT 'Time taken to load : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
	PRINT '-----------------------------';
	PRINT 'LOADING ERP TABLES';
	PRINT '-----------------------------';
	SET @start_time = GETDATE();
	TRUNCATE TABLE bronze.erp_cust_az12;
	BULK INSERT bronze.erp_cust_az12
	FROM 'C:\Users\user\Downloads\SQL\source_erp\cust_az12.csv'
	WITH
	(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
	SET @end_time = GETDATE();
	PRINT 'Time taken to load : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
	PRINT '-----------------------------';
	SET @start_time = GETDATE();
	TRUNCATE TABLE bronze.erp_loc_a101;
	BULK INSERT bronze.erp_loc_a101
	FROM 'C:\Users\user\Downloads\SQL\source_erp\loc_a101.csv'
	WITH
	(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
	SET @end_time = GETDATE();
	PRINT 'Time taken to load : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
	PRINT '-----------------------------';
	SET @start_time = GETDATE();
	TRUNCATE TABLE bronze.erp_px_cat_g1v2;
	BULK INSERT bronze.erp_px_cat_g1v2
	FROM 'C:\Users\user\Downloads\SQL\source_erp\px_cat_g1v2.csv'
	WITH
	(
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		TABLOCK
	);
	SET @end_time = GETDATE();
	PRINT 'Time taken to load : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
	PRINT '-----------------------------';
	SET @end_total_time = GETDATE();
	PRINT 'Time taken to load bronze layer: ' + CAST(DATEDIFF(SECOND, @start_total_time, @end_total_time) AS VARCHAR) + ' seconds';
	END TRY
	BEGIN CATCH
		PRINT 'Error occurred while loading bronze layer: ' + ERROR_MESSAGE();
	END CATCH
	
END
