

/*
===============================================================================
Date Range Exploration 
===============================================================================

Identify the earliest and latst dates(boundaries).
Understand the scope of data and the timespan.

Purpose:
    - To determine the temporal boundaries of key data points.
    - To understand the range of historical data.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

-- Determine the first and last order date and the total duration in months
SELECT 
    MIN(order_date) AS first_order_date,   -- earliest order
    MAX(order_date) AS last_order_date,    -- latest order

    DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS order_range_years,   -- duration in years
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months, -- duration in months
    DATEDIFF(DAY, MIN(order_date), MAX(order_date)) AS order_range_days      -- duration in days
FROM gold.fact_sales;

-- Find the youngest and oldest customer based on birthdate
SELECT
    MIN(birthdate) AS oldest_birthdate,    -- oldest customer DOB
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,   -- oldest age

    MAX(birthdate) AS youngest_birthdate,  -- youngest customer DOB
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age  -- youngest age
FROM gold.dim_customers;
