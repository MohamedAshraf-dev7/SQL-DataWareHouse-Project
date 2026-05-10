CREATE VIEW gold.dim_customers AS
select 
ROW_NUMBER() OVER ( ORDER BY ci.cst_id ) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_first_name AS first_name,
	ci.cst_last_name AS last_name,
	cl.cntry AS country,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
	     ELSE COALESCE(ca.gen, 'n/a') END AS gender,
	ci.cst_matrial_status AS marital_status,
    ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
	from silver.crm_cust_info ci
	LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 cl ON ci.cst_key = cl.cid 

  
	CREATE VIEW gold.dim_products AS
	select 
	ROW_NUMBER() OVER ( ORDER BY ci.prd_start_dt ) AS product_key,
	ci.prd_id AS product_id,
	ci.prd_key AS product_number,
	ci.prd_nm AS product_name,
	ci.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance AS maintenance,
	ci.prd_cost AS product_cost,
	ci.prd_line AS product_line,
	ci.prd_start_dt AS product_start_date
	from silver.crm_prd_info ci
	LEFT JOIN silver.erp_px_cat_g1v2 pc ON ci.cat_id = pc.id
	WHERE ci.prd_end_dt IS NULL 


  
	CREATE VIEW gold.facts_sales AS
	select 
	sd.sls_ord_num AS order_number,
	pr.product_key ,
	cu.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS ship_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
	from silver.crm_sales_details sd 
	LEFT JOIN gold.dim_customers cu 
	ON sd.sls_cust_id = cu.customer_id
	LEFT JOIN gold.dim_products pr 
	ON sd.sls_prd_key = pr.product_number  
