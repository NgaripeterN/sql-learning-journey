-- CTAS and temporary tables | salesdb

-- Save a snapshot of monthly sales as a real table (CTAS: Create Table As Select)
DROP TABLE IF EXISTS sales.monthly_orders;
CREATE TABLE sales.monthly_orders AS
SELECT
    DATE_TRUNC('month', orderdate)::date AS month,
    COUNT(*) AS total_orders,
    SUM(sales) AS total_sales
FROM sales.orders
GROUP BY DATE_TRUNC('month', orderdate);

-- Read the snapshot table
SELECT * FROM sales.monthly_orders ORDER BY month;

-- Save only the delivered orders as their own table
DROP TABLE IF EXISTS sales.orders_delivered;
CREATE TABLE sales.orders_delivered AS
SELECT orderid, customerid, productid, orderdate, sales
FROM sales.orders
WHERE orderstatus = 'Delivered';

-- Count the rows saved in the delivered orders table
SELECT COUNT(*) AS delivered_orders FROM sales.orders_delivered;

-- Copy only the structure of the orders table, with no rows
DROP TABLE IF EXISTS sales.orders_empty;
CREATE TABLE sales.orders_empty AS
SELECT * FROM sales.orders
WITH NO DATA;

-- Confirm the structure copy is empty
SELECT COUNT(*) AS rows_in_empty_table FROM sales.orders_empty;

-- CTAS does not copy constraints, so add the primary key to the new table afterwards
ALTER TABLE sales.orders_delivered ADD PRIMARY KEY (orderid);

-- Check which constraints the new table has
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'sales' AND table_name = 'orders_delivered';

-- Create a temporary table of delivered orders; it disappears when the session ends
DROP TABLE IF EXISTS tmp_delivered;
CREATE TEMP TABLE tmp_delivered AS
SELECT orderid, customerid, sales
FROM sales.orders
WHERE orderstatus = 'Delivered';

-- Query the temporary table like any other table
SELECT * FROM tmp_delivered ORDER BY orderid;

-- Remove small orders from the temporary table only (the real orders table is untouched)
DELETE FROM tmp_delivered WHERE sales < 20;

-- Compare the temporary table with the real table: fewer rows in the temp copy
SELECT
    (SELECT COUNT(*) FROM tmp_delivered) AS temp_rows,
    (SELECT COUNT(*) FROM sales.orders WHERE orderstatus = 'Delivered') AS real_rows;

-- Use a temporary table that drops itself at the end of the transaction
BEGIN;
CREATE TEMP TABLE tmp_one_shot ON COMMIT DROP AS
SELECT customerid, SUM(sales) AS total_sales
FROM sales.orders
GROUP BY customerid;
SELECT * FROM tmp_one_shot ORDER BY customerid;
COMMIT;

-- Confirm the one-shot temporary table is gone after the commit
SELECT to_regclass('pg_temp.tmp_one_shot') IS NULL AS table_is_gone;

-- Staging pattern step 1: put the cleaned archive (latest row per order) into a temporary table
DROP TABLE IF EXISTS tmp_archive_clean;
CREATE TEMP TABLE tmp_archive_clean AS
SELECT orderid, productid, customerid, salespersonid, orderdate, shipdate, orderstatus, quantity, sales, creationtime
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY orderid ORDER BY creationtime DESC) AS rn
    FROM sales.ordersarchive
) AS t
WHERE rn = 1;

-- Staging pattern step 2: save the cleaned result as a permanent table
DROP TABLE IF EXISTS sales.ordersarchive_clean;
CREATE TABLE sales.ordersarchive_clean AS
SELECT * FROM tmp_archive_clean;

-- Compare row counts: the raw archive has duplicates, the cleaned table does not
SELECT
    (SELECT COUNT(*) FROM sales.ordersarchive) AS raw_rows,
    (SELECT COUNT(*) FROM sales.ordersarchive_clean) AS clean_rows;

-- Drop a temporary table early without waiting for the session to end
DROP TABLE IF EXISTS tmp_delivered;
