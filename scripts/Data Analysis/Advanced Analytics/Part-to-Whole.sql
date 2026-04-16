/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Analyze how an individual part is performing compared to the overall, 
allowing us to understand which category has the greatet impact on business.

([Measure]/Total[Measure]) * 100 BY [Dimention]
Purpose:
    - To compare performance or metrics across dimensions or time periods.
    - To evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/

-- Which categories contribute the most to overall sales?

/*WITH category_sales AS (
	SELECT
		category,
		SUM(sales_amount) AS Total_Sales
	FROM Gold.fact_sales AS f
	LEFT JOIN Gold.dim_products AS p
	ON f.product_key = p.product_key
	GROUP BY category
	)

	SELECT 
		category,
		Total_Sales,
	SUM(Total_Sales) OVER() AS Overall_Sales,
	CONCAT(ROUND((CAST(Total_Sales AS FLOAT) / SUM(Total_Sales) OVER()) * 100, 2),'%') AS Percentage_of_Total
	FROM category_sales
	ORDER BY Total_Sales DESC*/


	WITH category_sales AS (
	SELECT
		category,
		SUM(sales_amount) AS Total_Sales -- aggregate total sales per category
	FROM Gold.fact_sales AS f
	LEFT JOIN Gold.dim_products AS p
	ON f.product_key = p.product_key -- join to get category from product table
	GROUP BY category
)

SELECT 
	category,
	Total_Sales,

	SUM(Total_Sales) OVER() AS Overall_Sales, -- window function: calculates total sales across all categories
	CONCAT(
		ROUND(                                      -- round result to 2 decimal places
			(CAST(Total_Sales AS FLOAT)              -- convert to float to avoid integer division
			/ SUM(Total_Sales) OVER()) * 100,        -- calculate percentage of total
		2),
	'%') AS Percentage_of_Total                  -- append % symbol for readability

FROM category_sales
ORDER BY Total_Sales DESC; -- sort categories by highest sales