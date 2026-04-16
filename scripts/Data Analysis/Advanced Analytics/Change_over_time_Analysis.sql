/*===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.

	[Measure] BY [Date Dimension]

SQL Functions Used:
    - Date Functions: DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()

Key Points->
		-Changes Over Year 
		-> A High-level overview insights that with strategic decision-making

		-Changes Over Months
		-> Detailed insight to discover seasonality in your data

===============================================================================
*/

-- Analyse sales performance over time
-- Quick Date Functions

-- Analyse sales performance over time (year & month level)

	SELECT
		YEAR(order_date) AS Order_year,          -- extract year
		MONTH(order_date) AS Order_months,       -- extract month
		SUM(sales_amount) AS Total_sales,        -- total sales
		COUNT(DISTINCT customer_key) AS Total_customers, -- unique customers
		SUM(quantity) AS Total_quantity          -- total items sold
	FROM Gold.fact_sales
	WHERE order_date IS NOT NULL                 -- exclude invalid dates
	GROUP BY YEAR(order_date), MONTH(order_date)
	ORDER BY YEAR(order_date), MONTH(order_date); -- chronological order


	-- Using DATETRUNC for cleaner date grouping

	SELECT
		DATETRUNC(MONTH, order_date) AS Order_Date, -- truncate to month level
		--DATETRUNC(YEAR, order_date) AS Order_Date,
		SUM(sales_amount) AS Total_sales,
		COUNT(DISTINCT customer_key) AS Total_customers,
		SUM(quantity) AS Total_quantity
	FROM Gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date)
	ORDER BY DATETRUNC(MONTH, order_date);        -- ordered by month


	-- Using FORMAT for readable date output (presentation purpose)

	SELECT
		FORMAT(order_date, 'yyyy-MMM') AS Order_Date, -- formatted as 2023-Jan
		--DATETRUNC(YEAR, order_date) AS Order_Date,
		SUM(sales_amount) AS Total_sales,
		COUNT(DISTINCT customer_key) AS Total_customers,
		SUM(quantity) AS Total_quantity
	FROM Gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY FORMAT(order_date, 'yyyy-MMM')
	ORDER BY FORMAT(order_date, 'yyyy-MMM');       -- formatted order (not ideal for sorting)


	-- How many new customers were added each year

	SELECT
		DATETRUNC(YEAR, create_date) AS Create_Year, -- group by year
		COUNT(customer_key) AS Total_Customer        -- total new customers
	FROM Gold.dim_customers
	GROUP BY DATETRUNC(YEAR, create_date)
	ORDER BY DATETRUNC(YEAR, create_date);          -- chronological order
