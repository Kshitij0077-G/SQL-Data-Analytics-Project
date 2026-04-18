

--Tip
-- After Joining table, Check if any duplicates were introduced by the join logic

--key point
		-- NULLs Often come from joined tables!
		-- NULL will appear if SQL finds no match
	--Mismatch for 'Female' and 'Male'
		-- Which source is the master for these values?
		--(A) The master source of customer data is CRM
--IMP
	--Decision-> Dimension or Fact
	--Its a dimension as dimension holds discriptive information about an objects.
-- Surrogate Key
	--Create surrogate key

/*SELECT 
cst_id,
COUNT(*) FROM
(*/

CREATE VIEW Gold.dim_customers AS
	SELECT
		ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
		ci.cst_id AS customer_id,
		ci.cst_key AS customer_number,
		ci.cst_firstname AS first_name,
		ci.cst_lastname AS last_name,
		lo.cntry AS country,
		ci.cst_marital_status AS marital_status,

		CASE 
			WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr  --CRM is the Master for gender info
			ELSE COALESCE(ca.gen, 'N/A') -- if ca.gen -> NULL= 'N/A', and if cst_gndr -> 'N/A' = use gen Value for cst_gndr for final output
		END AS gender,
		ca.bdate AS birthdate,
		ci.cst_create_date AS create_date

	FROM Silver.crm_cust_info AS ci
	LEFT JOIN Silver.erp_cust_az12 AS ca
	ON ci.cst_key = ca.cid
	LEFT JOIN Silver.erp_loc_a101 AS lo
	ON ci.cst_key = lo.cid
/*)t
GROUP BY cst_id
HAVING COUNT(*) > 1*/

