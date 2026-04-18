/*
	--Use the dimension's surrogate keys instead of IDs to easily connect facts with dimension
	-- Check if all dimension tables can successfully join to the fact table

		--Foreign Key Intergrity (Dimensions)

		SELECT * 
		FROM Gold.fact_sales AS fk
		LEFT JOIN gold.dim_customers AS c
		ON c.customer_key = fk.customer_key
		LEFT JOIN gold.dim_products AS p
		ON c.product_key = fk.product_key
		WHERE p.product_key IS NULL
*/

CREATE VIEW Gold.fact_sales AS
	SELECT
		sd.sls_ord_num AS order_number,
		pr.product_key,
		cu.customer_key,
		sd.sls_order_dt AS order_date,
		sd.sls_ship_dt AS shipping_date,
		sd.sls_due_dt AS due_date,
		sd.sls_sales AS sales_amount,
		sd.sls_quantity AS quantity,
		sd.sls_price AS price
	FROM Silver.crm_sales_details AS sd
	LEFT JOIN Gold.dim_products AS pr
	ON sd.sls_prd_key = pr.product_number
	LEFT JOIN Gold.dim_customers AS cu
	ON sd.sls_cust_id = cu.customer_id


