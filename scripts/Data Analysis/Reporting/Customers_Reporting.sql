/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/


/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
CREATE VIEW Gold.report_customers AS
WITH base_query AS (
	SELECT
		f.order_number,
		f.product_key,
		f.order_date,
		f.sales_amount,
		f.quantity,
		c.customer_key,
		c.customer_number,
		CONCAT(c.first_name,' ',c.last_name) AS customer_name,
		DATEDIFF(YEAR, c.birthdate, GETDATE()) AS Age
	FROM Gold.fact_sales AS f
	LEFT JOIN Gold.dim_customers AS c
	ON c.customer_key = f.customer_key
	WHERE order_date IS NOT NULL
	)
	

/*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
	, customer_aggregations AS (
	SELECT 
		 customer_key,
		 customer_number,
		 customer_name,
		 Age,
		 COUNT(DISTINCT order_number) AS Total_Orders,
		 SUM(sales_amount) AS Total_Sales,
		 SUM(quantity) AS Total_quantity,
		 COUNT(DISTINCT product_key) AS Total_Products,
		 MAX(order_date) AS Last_Order_Date,
		 DATEDIFF(MONTH, MIN(order_date),MAX(order_date)) AS Lifespan
	FROM base_query
	--WHERE customer_number = 'AW00011013'
	GROUP BY 
	 customer_key,
	 customer_number,
	 customer_name,
	 Age
	 
	 )

	 SELECT
		customer_key,
		customer_number,
		customer_name,
		Age,
		CASE
			WHEN Age < 20 THEN 'Under 20'
			WHEN Age BETWEEN 20 AND 29 THEN '20-29'
			WHEN Age BETWEEN 30 AND 39 THEN '30-39'
			WHEN Age BETWEEN 40 AND 49 THEN '40-49'
			ELSE '50 & Above'
		END AS Age_Group,
		CASE 
			WHEN Lifespan >= 12 AND Total_Sales > 5000 THEN 'VIP'
			WHEN Lifespan >= 12 AND Total_Sales <= 5000 THEN 'Regular'
			ELSE 'New'
		END customer_segment,
		Last_Order_Date,
		DATEDIFF(MONTH, Last_Order_Date, GETDATE()) AS Recency,
		Total_Orders,
		Total_Sales,
		Total_quantity,
		Total_Products,
		Lifespan,

		--Compute Average Order Value (AVO)
		--i.e Average Order Value = Total Sales / Total Nr. of Orders

		CASE 
			WHEN Total_Sales = 0 THEN 0
			ELSE Total_Sales / Total_Orders
		END AS Avg_Order_Value,

		--Compute average monthly spend

		CASE 
			WHEN Lifespan = 0 THEN Total_Sales
			ELSE Total_Sales / Lifespan
		END AS Avg_Monthly_spend

		FROM customer_aggregations

		SELECT * FROM Gold.report_customers
		