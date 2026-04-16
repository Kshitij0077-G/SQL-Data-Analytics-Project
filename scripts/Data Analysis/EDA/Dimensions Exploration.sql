/*	

===============================================================================
Dimensions Exploration
===============================================================================

	PURPOSE:-
		-Identifying the unique values(or categories) in each dimension.
		-Recognizing how data might be grouped or segmented, which is useful for later analysis
	SQL Functions Used:
    - DISTINCT
    - ORDER BY

	===============================================================================
*/

--Explore All Countries our customers come from

SELECT DISTINCT -- get unique countries
country 
FROM gold.dim_customers

-- Retrieve a list of unique countries from which customers originate
SELECT DISTINCT -- get unique countries
    country 
FROM gold.dim_customers
ORDER BY country;

--Explore All categories "The Major Division"

SELECT DISTINCT category FROM gold.dim_products

-- Retrieve a list of unique categories, subcategories, and products
SELECT DISTINCT -- get unique selected data
    category,
    subcategory, 
    product_name 
FROM gold.dim_products
ORDER BY category, subcategory, product_name;  -- sort hierarchy