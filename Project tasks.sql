-- Monday Coffee project tasks --

-- Disply all tables --

SELECT * FROM city;
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM sales;

------------------------------
------- Project Tasks --------
------------------------------

-- Task 1. Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT 
	city_name,
	ROUND(
		(0.25 * population)/1000000,
		2) as coffee_consumers_count_in_millions
FROM
	city;

-- Task 2. Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

SELECT
	ct.city_name,
	SUM(s.total) as total_revenue
FROM
	sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ct
ON ct.city_id = c.city_id
WHERE	
	EXTRACT(YEAR FROM s.sale_date) = 2023
	AND
	EXTRACT(QUARTER FROM s.sale_date) = 4
GROUP BY 1
ORDER BY 2 DESC;

-- Task 3. Sales Count for Each Product
-- How many units of each coffee product have been sold?

SELECT 
	p.product_name,
	COUNT(sale_id) as total_orders
FROM
	products as p
LEFT JOIN sales as s
ON p.product_id = s.product_id
GROUP BY 1
ORDER BY 2 DESC;

-- Task 4. Average Sales Amount per City
-- What is the average sales amount per customer in each city?

SELECT
	ct.city_name,
	COUNT(DISTINCT c.customer_id) as total_cx,
	ROUND(
			SUM(s.total) ::numeric/COUNT(DISTINCT c.customer_id) ::numeric
			,2) as average_revenue
FROM
	sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ct
ON ct.city_id = c.city_id

GROUP BY 1
ORDER BY 3 DESC;

-- Task 5. City Population and Coffee Consumers
-- Provide a list of cities along with their populations and estimated coffee consumers.

WITH city_table
AS
(
	SELECT 
		city_name,
		ROUND(
			(0.25 * population)/1000000,
			2) as coffee_consumers_count_in_millions
	FROM
		city
),
customer_table
AS 
(
	SELECT
		ci.city_name,
		COUNT(DISTINCT c.customer_id) as unique_cx
	FROM sales as s
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1
)

SELECT 
	city_table.city_name,
	city_table.coffee_consumers_count_in_millions,
	customer_table.unique_cx
FROM city_table 
JOIN customer_table 
on customer_table.city_name = city_table.city_name;

-- Task 6. Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

SELECT 
	*
FROM
(
		SELECT
			ci.city_name,
			p.product_name,
			COUNT(sale_id) as total_orders,
			DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(sale_id) DESC) as rank
		FROM 
			sales as s
		JOIN products as p
		ON 
			p.product_id = s.product_id
		JOIN customers as c
		ON
			c.customer_id = s.customer_id
		JOIN city as ci
		ON
			ci.city_id = c.city_id
		GROUP BY 1,2
)
WHERE rank <= 3;


-- Task 7. Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

SELECT 
	ci.city_name,
	COUNT(DISTINCT c.customer_id) as unique_cx
FROM
	city as ci
LEFT JOIN customers as c
ON 
	c.city_id = ci.city_id
JOIN sales as s
ON
	s.customer_id = c.customer_id
WHERE 
	s.product_id <= 14
GROUP BY 1;

-- Task 8. Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

SELECT
	ci.city_name,
	ci.estimated_rent,
	ROUND (ci.estimated_rent ::numeric / COUNT(DISTINCT c.customer_id) ::numeric, 2) as average_rent,
	COUNT(DISTINCT c.customer_id),
	ROUND (SUM(s.total) ::numeric / COUNT(DISTINCT c.customer_id) ::numeric, 2) as average_sale
	
FROM
	city as ci
LEFT JOIN customers as c
ON 
	c.city_id = ci.city_id
JOIN sales as s
ON
	s.customer_id = c.customer_id
GROUP BY 1,2
ORDER BY 5 DESC;

-- Task 9. Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).

SELECT 
	ci.city_name,
	EXTRACT(YEAR FROM s.sale_date) as year,
	EXTRACT(MONTH FROM s.sale_date) as month,
	SUM(s.total)
FROM 
	sales as s
JOIN customers as c
ON
	c.customer_id = s.customer_id
JOIN city as ci
ON
	ci.city_id = c.city_id
GROUP BY 1,2,3
ORDER BY 2, 3
	
-- Task 10. Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer











