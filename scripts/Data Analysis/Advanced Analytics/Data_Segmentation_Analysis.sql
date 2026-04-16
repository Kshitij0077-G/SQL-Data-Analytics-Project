/*
===============================================================================
Data Segmentation Analysis
===============================================================================

Group the data based on a specific range.
Help understand the correlation beteen two measures.

[Measure] BY [Measure]

Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/
WITH product_segment AS (
	SELECT
	product_key,
	product_name,
	cost,
	CASE 
		WHEN cost < 100 THEN 'Below 100'
		WHEN cost BETWEEN 100 AND 500 THEN '100-500'
		WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
		ELSE 'Above 1000'
	END cost_range
	FROM Gold.dim_products)

	SELECT
		cost_range,
		COUNT(product_key) AS Total_products
	FROM product_segment
	GROUP BY cost_range
	ORDER BY Total_products DESC


/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/
	WITH customer_spending AS (
		SELECT
			c.customer_key,
			SUM(f.sales_amount) AS Total_Spending,
			MIN(order_date) AS First_Order,
			MAX(order_date) AS Last_Order,
			DATEDIFF(month, MIN(order_date), MAX(order_date)) AS Lifespan
		FROM Gold.fact_sales AS f
		LEFT JOIN Gold.dim_customers AS c
		ON f.customer_key = c.customer_key
		--WHERE c.customer_key = 2349
		GROUP BY c.customer_key)

		SELECT 
		customer_segment,
		COUNT(customer_key) AS Total_customer
		FROM(
			SELECT
				customer_key,
				CASE 
					WHEN Lifespan >= 12 AND Total_Spending > 5000 THEN 'VIP'
					WHEN Lifespan >= 12 AND Total_Spending <= 5000 THEN 'Regular'
					ELSE 'New'
				END customer_segment
			FROM customer_spending)t
		GROUP BY customer_segment
		ORDER BY Total_customer

	

