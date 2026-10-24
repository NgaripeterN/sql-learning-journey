-- Views | salesdb

-- Save the monthly sales summary as a view so it can be queried like a table
DROP VIEW IF EXISTS sales.v_monthly_summary CASCADE;
CREATE OR REPLACE VIEW sales.v_monthly_summary AS
SELECT
    DATE_TRUNC('month', orderdate)::date AS month,
    SUM(sales) AS total_sales,
    COUNT(orderid) AS total_orders,
    SUM(quantity) AS total_quantity
FROM sales.orders
GROUP BY DATE_TRUNC('month', orderdate);

-- Read the monthly summary view, newest month first
SELECT * FROM sales.v_monthly_summary ORDER BY month DESC;

-- Build on the view: running total of monthly sales without repeating the grouping logic
SELECT month, total_sales,
       SUM(total_sales) OVER (ORDER BY month) AS running_total
FROM sales.v_monthly_summary
ORDER BY month;

-- Hide the complexity of four joins behind one view of order details
CREATE OR REPLACE VIEW sales.v_order_details AS
SELECT
    o.orderid,
    o.orderdate,
    c.firstname AS customer,
    c.country,
    p.product,
    p.category,
    e.firstname AS salesperson,
    o.quantity,
    o.sales
FROM sales.orders AS o
LEFT JOIN sales.customers AS c ON o.customerid = c.customerid
LEFT JOIN sales.products AS p ON o.productid = p.productid
LEFT JOIN sales.employees AS e ON o.salespersonid = e.employeeid;

-- Use the order details view: clothing orders by customer, without writing any joins
SELECT orderid, customer, product, sales
FROM sales.v_order_details
WHERE category = 'Clothing'
ORDER BY orderid;

-- Share only part of the data: orders from non-US customers, without addresses or customer ids
CREATE OR REPLACE VIEW sales.v_orders_non_us AS
SELECT o.orderid, o.orderdate, o.productid, o.quantity, o.sales
FROM sales.orders AS o
INNER JOIN sales.customers AS c ON o.customerid = c.customerid
WHERE c.country <> 'USA';

-- Read the restricted view: only the German customers' orders appear
SELECT * FROM sales.v_orders_non_us ORDER BY orderid;

-- Change an existing view by adding a column at the end: average order value per month
CREATE OR REPLACE VIEW sales.v_monthly_summary AS
SELECT
    DATE_TRUNC('month', orderdate)::date AS month,
    SUM(sales) AS total_sales,
    COUNT(orderid) AS total_orders,
    SUM(quantity) AS total_quantity,
    ROUND(AVG(sales), 2) AS avg_order_value
FROM sales.orders
GROUP BY DATE_TRUNC('month', orderdate);

-- Check the updated view, now with average order value
SELECT * FROM sales.v_monthly_summary ORDER BY month;

-- Store the monthly summary physically as a materialized view (a snapshot that is refreshed on demand)
DROP MATERIALIZED VIEW IF EXISTS sales.mv_monthly_summary;
CREATE MATERIALIZED VIEW sales.mv_monthly_summary AS
SELECT
    DATE_TRUNC('month', orderdate)::date AS month,
    SUM(sales) AS total_sales,
    COUNT(orderid) AS total_orders
FROM sales.orders
GROUP BY DATE_TRUNC('month', orderdate);

-- Read the materialized view
SELECT * FROM sales.mv_monthly_summary ORDER BY month;

-- Refresh the materialized view after the underlying data changes
REFRESH MATERIALIZED VIEW sales.mv_monthly_summary;

-- List the views in the sales schema
SELECT table_name AS view_name
FROM information_schema.views
WHERE table_schema = 'sales'
ORDER BY table_name;

-- Show the query stored inside a view
SELECT pg_get_viewdef('sales.v_monthly_summary'::regclass, true) AS view_definition;
