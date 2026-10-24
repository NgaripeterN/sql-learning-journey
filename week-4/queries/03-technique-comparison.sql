-- Technique comparison | salesdb
-- The problem: which customers have total sales above the average customer total?
-- Customer totals are 110, 55, 125 and 90, so the average is 95 and customers 1 and 3 qualify.

-- Method 1, subquery: works, but the customer totals logic has to be written twice
SELECT customerid, total_sales
FROM (
    SELECT customerid, SUM(sales) AS total_sales
    FROM sales.orders
    GROUP BY customerid
) AS t
WHERE total_sales > (
    SELECT AVG(total_sales)
    FROM (
        SELECT SUM(sales) AS total_sales
        FROM sales.orders
        GROUP BY customerid
    ) AS x
)
ORDER BY customerid;

-- Method 2, CTE: the totals are written once and reused inside this one query
WITH customer_totals AS (
    SELECT customerid, SUM(sales) AS total_sales
    FROM sales.orders
    GROUP BY customerid
)
SELECT customerid, total_sales
FROM customer_totals
WHERE total_sales > (SELECT AVG(total_sales) FROM customer_totals)
ORDER BY customerid;

-- Method 3, temporary table: the totals are stored for the rest of the session
DROP TABLE IF EXISTS tmp_customer_totals;
CREATE TEMP TABLE tmp_customer_totals AS
SELECT customerid, SUM(sales) AS total_sales
FROM sales.orders
GROUP BY customerid;

-- Use the temporary table to find customers above the average
SELECT customerid, total_sales
FROM tmp_customer_totals
WHERE total_sales > (SELECT AVG(total_sales) FROM tmp_customer_totals)
ORDER BY customerid;

-- Method 4, view: the totals logic is saved permanently and always reads current data
CREATE OR REPLACE VIEW sales.v_customer_totals AS
SELECT customerid, SUM(sales) AS total_sales
FROM sales.orders
GROUP BY customerid;

-- Use the view to find customers above the average
SELECT customerid, total_sales
FROM sales.v_customer_totals
WHERE total_sales > (SELECT AVG(total_sales) FROM sales.v_customer_totals)
ORDER BY customerid;

-- Method 5, CTAS: the totals are saved as a permanent table that does not update by itself
DROP TABLE IF EXISTS sales.customer_totals_snapshot;
CREATE TABLE sales.customer_totals_snapshot AS
SELECT customerid, SUM(sales) AS total_sales
FROM sales.orders
GROUP BY customerid;

-- Use the snapshot table to find customers above the average
SELECT customerid, total_sales
FROM sales.customer_totals_snapshot
WHERE total_sales > (SELECT AVG(total_sales) FROM sales.customer_totals_snapshot)
ORDER BY customerid;

-- Live versus snapshot, step 1: make a copy of orders to experiment on without touching the real table
DROP TABLE IF EXISTS sales.orders_copy CASCADE;
CREATE TABLE sales.orders_copy AS
SELECT * FROM sales.orders;

-- Live versus snapshot, step 2: a view over the copy
CREATE OR REPLACE VIEW sales.v_copy_totals AS
SELECT COUNT(*) AS orders, SUM(sales) AS total_sales
FROM sales.orders_copy;

-- Live versus snapshot, step 3: a CTAS snapshot of the same totals
DROP TABLE IF EXISTS sales.copy_totals_snapshot;
CREATE TABLE sales.copy_totals_snapshot AS
SELECT COUNT(*) AS orders, SUM(sales) AS total_sales
FROM sales.orders_copy;

-- Live versus snapshot, step 4: add a new order to the copy only
INSERT INTO sales.orders_copy (orderid, productid, customerid, salespersonid, orderdate, orderstatus, quantity, sales)
VALUES (11, 101, 1, 3, '2025-04-01', 'Shipped', 1, 100);

-- Live versus snapshot, step 5: the view shows the new order, the snapshot still shows the old totals
SELECT 'view' AS source, orders, total_sales FROM sales.v_copy_totals
UNION ALL
SELECT 'snapshot', orders, total_sales FROM sales.copy_totals_snapshot;
