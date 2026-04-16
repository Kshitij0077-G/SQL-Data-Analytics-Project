
/*
===============================================================================
Cumulative Analysis
===============================================================================

	Aggregate the data progressively over time.
	Help to understand whether our business is growing or declining

Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

	Formula->
		-[Cumulative Measure] BY [Date Dimension]

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- Calculate the total sales per month
-- and the running total of sales over time

--BY MONTH

--USING CTE

-- Step 1: Prepare monthly aggregated data using CTE

	WITH monthly_sales AS
	(
		SELECT
			DATETRUNC(MONTH, order_date) AS order_date, -- monthly aggregation
			SUM(sales_amount) AS total_sales,           -- total monthly sales
			AVG(price) AS avg_price                     -- avg monthly price
		FROM Gold.fact_sales
		WHERE order_date IS NOT NULL
		GROUP BY DATETRUNC(MONTH, order_date)
	)

	-- Step 2: Apply window functions
	SELECT
		order_date,
		total_sales,

		/* Default Window Frame made explicit
		   BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW */

		-- Running total (cumulative sum)
		SUM(total_sales) OVER (
			ORDER BY order_date
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		) AS Running_Total_Sales,

		-- Moving average (cumulative average)
		AVG(avg_price) OVER (
			ORDER BY order_date
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		) AS Moving_Average

	FROM monthly_sales;




-- BY YEAR

--USING CTE

-- Step 1: Yearly aggregation using CTE
WITH yearly_sales AS
(
    SELECT
        DATETRUNC(YEAR, order_date) AS order_date, -- yearly aggregation
        YEAR(order_date) AS order_year,            -- explicit year column
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM Gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(YEAR, order_date), YEAR(order_date)
)

-- Step 2: Apply window functions
SELECT
    order_year,        -- cleaner for reporting
    order_date,
    total_sales,

    /* Default Window Frame
       BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW */

    -- Running total across years
    SUM(total_sales) OVER (
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS Running_Total_Sales,

    -- Moving average across years
    AVG(avg_price) OVER (
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS Moving_Average

FROM yearly_sales
ORDER BY order_date;