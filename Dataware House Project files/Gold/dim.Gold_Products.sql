

--Tip
-- After Joining table, Check if any duplicates were introduced by the join logic
--IMP
	--Decision-> Dimension or Fact
	--Its a dimension as dimension holds discriptive information about an objects.
-- Surrogate Key
	--Create surrogate key


CREATE VIEW Gold.dim_products AS
	--SELECT prd_key, COUNT(*) FROM (
		SELECT
			ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
				pn.prd_id AS product_id,
				pn.prd_key AS product_number,
				pn.prd_nm AS product_name,
				pn.cat_id AS category_id,
				pc.cat AS category,
				pc.subcat AS subcategory,
				pc.maintenance,
				pn.prd_cost AS cost,
				pn.prd_line AS product_line,
				pn.prd_start_dt AS start_date
			FROM Silver.crm_prd_info AS pn
			LEFT JOIN Silver.erp_px_cat_g1v2 AS pc
			ON pn.cat_id = pc.id
			WHERE  prd_end_dt IS NULL --If End Date is NULL then it is current info of the product!
	 /*)t GROUP BY prd_key
	HAVING COUNT(*) > */