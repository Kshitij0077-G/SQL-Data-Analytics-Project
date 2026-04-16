/*
Order the values of dimensions by measure.
Top N performers | Bottom N Performers

RANK[Dimension] BY [Measure]
*/

-- Which 5 products Generating the Highest Revenue?

	SELECT TOP 5
		p.product_name,                         
		SUM(f.sales_amount) AS Total_Revenue    -- total revenue
	FROM Gold.fact_sales AS f
	LEFT JOIN Gold.dim_products AS p
	ON p.product_key = f.product_key            -- join sales with product
	GROUP BY p.product_name
	ORDER BY Total_Revenue DESC;               -- highest first


	SELECT TOP 5
		p.subcategory,                        
		SUM(f.sales_amount) AS Total_Revenue    -- total revenue
	FROM Gold.fact_sales AS f
	LEFT JOIN Gold.dim_products AS p
	ON p.product_key = f.product_key            -- join sales with product
	GROUP BY p.subcategory
	ORDER BY Total_Revenue DESC;               -- highest first


	-- USING WINDOW FUNCTION

	SELECT * FROM
	(
		SELECT
			p.product_name,
			SUM(f.sales_amount) AS Total_Revenue,   -- total revenue
			RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS Rank_Products -- rank by revenue
		FROM Gold.fact_sales AS f
		LEFT JOIN Gold.dim_products AS p
		ON p.product_key = f.product_key            -- join sales with product
		GROUP BY p.product_name
	) t
	WHERE Rank_Products <= 5;                       -- top 5 ranks


	-- What are the 5 worst-performing products in terms of sales?

	SELECT TOP 5
		p.product_name,
		SUM(f.sales_amount) AS Total_Revenue
	FROM Gold.fact_sales AS f
	LEFT JOIN Gold.dim_products AS p
	ON p.product_key = f.product_key
	GROUP BY p.product_name
	ORDER BY Total_Revenue ASC;                    -- lowest first


	-- Find the top 10 customers who have generated the highest revenue

	SELECT TOP 10
		c.customer_key,                            
		c.first_name,
		c.last_name,
		SUM(f.sales_amount) AS Total_revenue       -- total revenue
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers AS c
		ON c.customer_key = f.customer_key         -- join sales with customer
	GROUP BY 
		c.customer_key,
		c.first_name,
		c.last_name
	ORDER BY Total_revenue DESC;                  -- highest first


	-- USING WINDOW FUNCTION

	SELECT * FROM
	(
		SELECT
			c.customer_key,
			c.first_name,
			c.last_name,
			SUM(f.sales_amount) AS Total_revenue,  -- total revenue
			RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS Rank_customer -- rank by revenue
		FROM Gold.fact_sales AS f
		LEFT JOIN Gold.dim_customers AS c
		ON c.customer_key = f.customer_key         -- join sales with customer
		GROUP BY
			c.customer_key,
			c.first_name,
			c.last_name
	) t
	WHERE Rank_customer <= 10;                     -- top 10 ranks


	-- The 3 customers with the fewest orders placed

	SELECT TOP 3
		c.customer_key,
		c.first_name,
		c.last_name,
		COUNT(DISTINCT order_number) AS Total_Orders -- total orders
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_customers AS c
		ON c.customer_key = f.customer_key         -- join sales with customer
	GROUP BY 
		c.customer_key,
		c.first_name,
		c.last_name
	ORDER BY Total_Orders ASC;                    -- lowest first

	-- USING WINDOW FUNCTION
	-- Complex but Flexibly Ranking Using Window Functions

		SELECT *
		FROM (
			SELECT
				c.customer_key,
				c.first_name,
				c.last_name,
				COUNT(DISTINCT order_number) AS Total_Orders,
				ROW_NUMBER() OVER (
					ORDER BY 
						COUNT(DISTINCT order_number) ASC,
						c.customer_key ASC   --same tie-breaker
				) AS Rank_Customers
			FROM gold.fact_sales AS f
			LEFT JOIN gold.dim_customers AS c
				ON c.customer_key = f.customer_key
			GROUP BY 
				c.customer_key,
				c.first_name,
				c.last_name
		) t
		WHERE Rank_Customers <= 3;
		