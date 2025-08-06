create database retail

use retail;

select top 10 * from data;

										/* Analysis to do in SQL */

-- Finding Categories with Highest Average Rating Across Products

SELECT category, round(AVG(rating),2) AS avg_rating
FROM data
GROUP BY category
ORDER BY avg_rating DESC;


-- Find the Most Reviewed Product in Each Warehouse

with cte as
(SELECT *,
ROW_NUMBER() OVER (PARTITION BY warehouse ORDER BY reviews DESC) AS rn
FROM data
)
SELECT warehouse,SKU,category,[Product Name],reviews
FROM cte
WHERE rn = 1;

--Find Products with Higher-than-Average Prices within Their Category, Along with Discount and Supplier

 with avg_price as
 (select t1.category,round(AVG(t1.Price),2) AS avg_price
 from data t1
 group by t1.category)

SELECT p.category,p.Brand,p.[Product Name],p.supplier,round(p.price,2)as price,round(p.discount,2)as discount
FROM data p
INNER JOIN avg_price a
ON p.category = a.category
WHERE p.price > a.avg_price;


-- Top 2 Products with the Highest Average Rating in Each Category

with cte as
(SELECT *,
dense_rank() OVER (PARTITION BY category ORDER BY rating DESC) AS rn  /*row_number() also same output as decimals change*/
FROM data)

SELECT category,[Product Name],Brand,round(rating,3)as rating
FROM cte
WHERE rn <= 2;


-- Analysis Across All Return Policy Categories (Count, AvgStock, Total Stock, Weighted Avg Rating, etc.)

SELECT
    [Return Policy] AS return_policy_days,
    COUNT(*) AS product_count,
	SUM([Stock Quantity]) AS total_stock,
    round(AVG([Stock Quantity]),0) AS avg_stock, /*stock cant be decimal*/
	    
    -- Weighted average rating: (sum of rating * stock) / total stock ; means more importance to highly stocked products
    round(SUM(rating * [Stock Quantity]*1.0) / NULLIF(SUM([Stock Quantity]), 0),3) AS weighted_avg_rating
FROM data
GROUP BY [Return Policy]
ORDER BY return_policy_days;

							