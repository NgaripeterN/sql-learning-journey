-- Window functions: ranking | salesdb

-- Rank orders by sales, showing how each ranking function treats ties
SELECT orderid, sales,
       ROW_NUMBER() OVER (ORDER BY sales DESC) AS row_num,
       RANK() OVER (ORDER BY sales DESC) AS rnk,
       DENSE_RANK() OVER (ORDER BY sales DESC) AS dense_rnk
FROM sales.orders;

-- The 2 biggest orders for each product (a CTE is needed because windows cannot go in WHERE)
WITH ranked AS (
    SELECT orderid, productid, sales,
           ROW_NUMBER() OVER (PARTITION BY productid ORDER BY sales DESC) AS rn
    FROM sales.orders
)
SELECT * FROM ranked WHERE rn <= 2 ORDER BY productid, rn;

-- The smallest order for each customer
WITH ranked AS (
    SELECT orderid, customerid, sales,
           ROW_NUMBER() OVER (PARTITION BY customerid ORDER BY sales) AS rn
    FROM sales.orders
)
SELECT * FROM ranked WHERE rn = 1;

-- Customers ranked by their total sales
SELECT customerid, SUM(sales) AS total_sales,
       RANK() OVER (ORDER BY SUM(sales) DESC) AS sales_rank
FROM sales.orders
GROUP BY customerid;

-- A unique row number added to every order
SELECT ROW_NUMBER() OVER (ORDER BY orderid) AS row_id, *
FROM sales.orders;

-- Duplicate rows in the archive: older copies of an order id that appears more than once
SELECT * FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY orderid ORDER BY creationtime DESC) AS rn
    FROM sales.ordersarchive
) AS t
WHERE rn > 1;

-- The archive cleaned up: only the latest row for each order id
SELECT * FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY orderid ORDER BY creationtime DESC) AS rn
    FROM sales.ordersarchive
) AS t
WHERE rn = 1
ORDER BY orderid;

-- Split orders by sales into 1, 2 and 3 equal-sized groups
SELECT orderid, sales,
       NTILE(1) OVER (ORDER BY sales DESC) AS one_bucket,
       NTILE(2) OVER (ORDER BY sales DESC) AS two_buckets,
       NTILE(3) OVER (ORDER BY sales DESC) AS three_buckets
FROM sales.orders;

-- Label orders High, Medium or Low by splitting them into three groups of sales
SELECT orderid, sales,
       CASE NTILE(3) OVER (ORDER BY sales DESC)
           WHEN 1 THEN 'High'
           WHEN 2 THEN 'Medium'
           ELSE 'Low'
       END AS segment
FROM sales.orders;

-- Each order's position as a fraction of all orders, from the top by sales
SELECT orderid, sales,
       CUME_DIST() OVER (ORDER BY sales DESC) AS cume_dist,
       PERCENT_RANK() OVER (ORDER BY sales DESC) AS percent_rank
FROM sales.orders;

-- Products in the top 40 percent by price
SELECT * FROM (
    SELECT product, price, CUME_DIST() OVER (ORDER BY price DESC) AS dist_rank
    FROM sales.products
) AS t
WHERE dist_rank <= 0.4;
