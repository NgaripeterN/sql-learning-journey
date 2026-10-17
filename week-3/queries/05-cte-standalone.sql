-- CTE: standalone | salesdb

-- Every customer with their total sales, with 0 for customers who never ordered
WITH customer_sales AS (
    SELECT customerid, SUM(sales) AS total_sales
    FROM sales.orders
    GROUP BY customerid
)
SELECT c.customerid, c.firstname, COALESCE(cs.total_sales, 0) AS total_sales
FROM sales.customers AS c
LEFT JOIN customer_sales AS cs ON c.customerid = cs.customerid;

-- Orders with sales above the overall average, using a CTE to hold the average
WITH avg_sales AS (
    SELECT AVG(sales) AS avg_value FROM sales.orders
)
SELECT o.orderid, o.sales, a.avg_value
FROM sales.orders AS o
CROSS JOIN avg_sales AS a
WHERE o.sales > a.avg_value;

-- Customers ranked by total sales, building the totals in a CTE and ranking them afterwards
WITH customer_sales AS (
    SELECT customerid, SUM(sales) AS total_sales
    FROM sales.orders
    GROUP BY customerid
)
SELECT customerid, total_sales,
       RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM customer_sales;

-- The 2 biggest orders for each product (a CTE lets us filter on the window result)
WITH ranked AS (
    SELECT orderid, productid, sales,
           ROW_NUMBER() OVER (PARTITION BY productid ORDER BY sales DESC) AS rn
    FROM sales.orders
)
SELECT orderid, productid, sales
FROM ranked
WHERE rn <= 2
ORDER BY productid, rn;

-- The archive cleaned up: only the latest row for each order id
WITH ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY orderid ORDER BY creationtime DESC) AS rn
    FROM sales.ordersarchive
)
SELECT orderid, productid, customerid, orderdate, orderstatus, sales, creationtime
FROM ranked
WHERE rn = 1
ORDER BY orderid;

-- Month over month sales change, with the monthly totals prepared in a CTE
WITH monthly AS (
    SELECT DATE_TRUNC('month', orderdate)::date AS month, SUM(sales) AS total_sales
    FROM sales.orders
    GROUP BY DATE_TRUNC('month', orderdate)
)
SELECT month, total_sales,
       total_sales - LAG(total_sales) OVER (ORDER BY month) AS change
FROM monthly;
