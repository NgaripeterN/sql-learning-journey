-- CTE: multiple and nested | salesdb

-- Each customer's total sales and most recent order date, from two independent CTEs joined together
WITH customer_sales AS (
    SELECT customerid, SUM(sales) AS total_sales
    FROM sales.orders
    GROUP BY customerid
),
last_order AS (
    SELECT customerid, MAX(orderdate) AS last_order_date
    FROM sales.orders
    GROUP BY customerid
)
SELECT c.firstname, cs.total_sales, lo.last_order_date
FROM sales.customers AS c
LEFT JOIN customer_sales AS cs ON c.customerid = cs.customerid
LEFT JOIN last_order AS lo ON c.customerid = lo.customerid
ORDER BY cs.total_sales DESC NULLS LAST;

-- Customer summary: total sales, order count and average order value, from three CTEs
WITH totals AS (
    SELECT customerid, SUM(sales) AS total_sales FROM sales.orders GROUP BY customerid
),
counts AS (
    SELECT customerid, COUNT(*) AS order_count FROM sales.orders GROUP BY customerid
),
averages AS (
    SELECT customerid, ROUND(AVG(sales), 2) AS avg_order FROM sales.orders GROUP BY customerid
)
SELECT c.firstname, t.total_sales, n.order_count, a.avg_order
FROM sales.customers AS c
LEFT JOIN totals AS t ON c.customerid = t.customerid
LEFT JOIN counts AS n ON c.customerid = n.customerid
LEFT JOIN averages AS a ON c.customerid = a.customerid
ORDER BY t.total_sales DESC NULLS LAST;

-- How many customers fall in each sales segment, where the second CTE builds on the first (nested CTE)
WITH customer_sales AS (
    SELECT customerid, SUM(sales) AS total_sales
    FROM sales.orders
    GROUP BY customerid
),
customer_segment AS (
    SELECT customerid, total_sales,
           CASE
               WHEN total_sales > 100 THEN 'High'
               WHEN total_sales > 50 THEN 'Medium'
               ELSE 'Low'
           END AS segment
    FROM customer_sales
)
SELECT segment, COUNT(*) AS customers, SUM(total_sales) AS segment_sales
FROM customer_segment
GROUP BY segment
ORDER BY segment_sales DESC;

-- Each customer's segment next to their name, including customers with no orders (nested CTE joined back)
WITH customer_sales AS (
    SELECT customerid, SUM(sales) AS total_sales
    FROM sales.orders
    GROUP BY customerid
),
customer_segment AS (
    SELECT customerid,
           CASE
               WHEN total_sales > 100 THEN 'High'
               WHEN total_sales > 50 THEN 'Medium'
               ELSE 'Low'
           END AS segment
    FROM customer_sales
)
SELECT c.firstname, COALESCE(cs.segment, 'No orders') AS segment
FROM sales.customers AS c
LEFT JOIN customer_segment AS cs ON c.customerid = cs.customerid;

-- Each salesperson's total sales as a share of all sales, with a CTE for the per-person totals and another for the grand total
WITH person_sales AS (
    SELECT salespersonid, SUM(sales) AS total_sales
    FROM sales.orders
    GROUP BY salespersonid
),
grand_total AS (
    SELECT SUM(sales) AS all_sales FROM sales.orders
)
SELECT e.firstname, ps.total_sales,
       ROUND(100.0 * ps.total_sales / g.all_sales, 1) AS pct_of_all_sales
FROM person_sales AS ps
INNER JOIN sales.employees AS e ON ps.salespersonid = e.employeeid
CROSS JOIN grand_total AS g
ORDER BY ps.total_sales DESC;
