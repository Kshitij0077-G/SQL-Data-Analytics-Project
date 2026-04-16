-----------------------------------------------------------------
--GOLD
--Check which column come under 'Dimension' or 'Measure'
	--Value check for numeric
		--1 is it Numeric?
		--2 Does it make sense to aggregate? (If yes it goes under 'Measure')
-----------------------------------------------------------------
SELECT DISTINCT
birthdate
FROM gold.dim_customers --This is a 'Dimension'

SELECT DISTINCT
DATEDIFF(year, birthdate, GETDATE()) AS Age
FROM gold.dim_customers --This is a 'Measure'

SELECT DISTINCT
customer_id
FROM gold.dim_customers --This is a 'Dimention'


SELECT DISTINCT
category
FROM Gold.dim_products --This is a 'Dimension'

SELECT DISTINCT
product_name
FROM Gold.dim_products --This is a 'Dimension'

SELECT DISTINCT
sales_amount
FROM Gold.fact_sales --This is a 'Measure'


SELECT DISTINCT
quantity
FROM Gold.fact_sales --This is a 'Measure'