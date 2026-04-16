/*
	-- Measures Exploration

	Calculate the key metric of the business (Big Numbers)
	-Highest Level of Aggregation | Lowest Level of Details-
*/

-- Find the Total Sales
   SELECT SUM(sales_amount) AS Total_Sales FROM gold.fact_sales

-- Find how many items are sold 
   SELECT SUM(quantity) AS Total_quantity FROM gold.fact_sales

-- Find the average selling price
   SELECT AVG(price) AS AVD_price FROM gold.fact_sales

-- Find the Total number of Orders
   SELECT COUNT(order_number) AS Total_order FROM gold.fact_sales
   SELECT COUNT(DISTINCT order_number) AS Total_order FROM gold.fact_sales

-- Find the Total number of products
   SELECT COUNT(product_key) AS Total_products FROM gold.dim_products
   SELECT COUNT(DISTINCT product_key) AS Total_products FROM gold.dim_products
   
-- Find the total number of customers
   SELECT COUNT(customer_key) AS Total_customer FROM gold.dim_customers

-- Find the total number of customers that has placed an order
   SELECT COUNT(customer_key) AS Total_customer FROM gold.fact_sales
   SELECT COUNT(DISTINCT customer_key) AS Total_customer FROM gold.fact_sales


   -- Generate a Report that shows all key metrics of the business

   SELECT 
		'Total_Sales' AS measure_name, 
		 SUM(sales_amount) AS measure_value 
   FROM gold.fact_sales

   UNION ALL

   SELECT 
		'Total_Quantity' AS measure_name, 
		 SUM(quantity) AS measure_value 
   FROM gold.fact_sales

   UNION ALL

   SELECT 
		'Average Price',
		 AVG(price) 
	FROM gold.fact_sales

	UNION ALL

	SELECT 
		 'Total Nr.Orders',
		  COUNT(DISTINCT order_number) 
	FROM gold.fact_sales

	UNION ALL

	SELECT 
		 'Total Nr.Products',
		  COUNT(product_name)
	FROM gold.dim_products

	UNION ALL

	SELECT 
		 'Total Nr.Customers',
		  COUNT(customer_key)
	FROM gold.dim_customers




