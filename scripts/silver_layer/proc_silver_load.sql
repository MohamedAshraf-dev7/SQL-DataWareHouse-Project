
CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
DECLARE @start_time DATETIME , @end_time DATETIME,@start_total_time DATETIME,@end_total_time DATETIME;
BEGIN TRY
    SET @start_total_time = GETDATE();
     PRINT '=============================';
	PRINT 'LOADING SILVER LAYER';
	PRINT '=============================';

	PRINT '-----------------------------';
	PRINT 'LOADING CRM TABLES'
	PRINT '-----------------------------';
    SET @start_time = GETDATE();
TRUNCATE TABLE silver.crm_cust_info
INSERT INTO silver.crm_cust_info 
(cst_id, cst_key, cst_first_name, cst_last_name, cst_matrial_status, cst_gndr, cst_create_date)
select 
cst_id,
cst_key,
TRIM(cst_first_name) as cst_first_name,
TRIM(cst_last_name) as cst_last_name,
case when UPPER(TRIM(cst_matrial_status)) = 'M' then 'Married'
     when UPPER(TRIM(cst_matrial_status)) = 'S' then 'Single'
     else 'N/A' 
     end as cst_matrial_status,
case when UPPER(TRIM(cst_gndr)) = 'M' then 'Male'
     when UPPER(TRIM(cst_gndr)) = 'F' then 'Female'
     else 'N/A' 
     end as cst_gndr,
cst_create_date
from(
select 
*,
ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as flag
from bronze.crm_cust_info 
where cst_id is not null
)t where flag = 1 
SET @end_time = GETDATE();
	PRINT 'Time taken to load : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
PRINT '-----------------------------';
	SET @start_time = GETDATE();
TRUNCATE TABLE silver.crm_prd_info
INSERT INTO silver.crm_prd_info (prd_id, cat_id, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
select
prd_id,
REPLACE(SUBSTRING(prd_key,1,5),'-','_')  as cat_id,
prd_nm,
ISNULL(prd_cost,0) as prd_cost,
case  UPPER(TRIM(prd_line)) 
     when 'M' then 'Mountain'
     when 'S' then 'Other Sales'
     when 'R' then 'Road'
     when 'T' then 'Touring'
     else 'N/A'
     end as prd_line,
prd_start_dt,
CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) AS datetime)-1 as prd_end_dt
from bronze.crm_prd_info 
SET @end_time = GETDATE();
	PRINT 'Time taken to load : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
PRINT '-----------------------------';

SET @start_time = GETDATE();
TRUNCATE TABLE silver.crm_sales_details
INSERT INTO silver.crm_sales_details (sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)

SELECT 
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
     ELSE CAST(CAST(sls_order_dt AS varchar)AS DATE)
     END AS sls_order_dt,
   
CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
     ELSE CAST(CAST(sls_ship_dt AS varchar)AS DATE)
     END AS sls_ship_dt,
CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
     ELSE CAST(CAST(sls_due_dt AS varchar)AS DATE)
     END AS sls_due_dt,
CASE WHEN sls_sales <= 0 or sls_sales is null or sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
     ELSE sls_sales
     END AS sls_sales,
     sls_quantity,
CASE WHEN sls_price <= 0 or sls_price is null THEN sls_sales / NULLIF(sls_quantity, 0)     
     ELSE sls_price
     END AS sls_price
FROM bronze.crm_sales_details 
SET @end_time = GETDATE();
	PRINT 'Time taken to load : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
PRINT '-----------------------------';


	SET @start_time = GETDATE();
TRUNCATE TABLE silver.erp_cust_az12
INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
     ELSE cid
     END AS cid,
CASE WHEN bdate > GETDATE() THEN NULL
ELSE bdate END AS bdate,
CASE WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
     WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
     ELSE 'N/A'
     END AS gen
FROM bronze.erp_cust_az12 
SET @end_time = GETDATE();
	PRINT 'Time taken to load : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
PRINT '-----------------------------';


SET @start_time = GETDATE();

TRUNCATE TABLE silver.erp_loc_a101
INSERT INTO silver.erp_loc_a101 (cid, cntry)
select  
 REPLACE(cid,'-','') AS cid,
CASE WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
     WHEN TRIM(cntry) IN ('DE') THEN 'Germany'
     WHEN TRIM(cntry) IN ('') OR cntry IS NULL THEN 'N/A'
     ELSE  TRIM(cntry) END AS cntry
from bronze.erp_loc_a101 
SET @end_time = GETDATE();
	PRINT 'Time taken to load : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
PRINT '-----------------------------';

SET @start_time = GETDATE();
TRUNCATE TABLE silver.erp_px_cat_g1v2
INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
SELECT 
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2
SET @end_time = GETDATE();
	PRINT 'Time taken to load : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
PRINT '-----------------------------';
SET @end_total_time = GETDATE();
	PRINT 'Time taken to load silver layer: ' + CAST(DATEDIFF(SECOND, @start_total_time, @end_total_time) AS VARCHAR) + ' seconds';
	
END TRY
BEGIN CATCH
   PRINT 'Error occurred while loading silver layer: ' + ERROR_MESSAGE();
END CATCH

END
