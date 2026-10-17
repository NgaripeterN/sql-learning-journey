-- Window functions: aggregates | salesdb

-- Total sales per product, one row per product (GROUP BY collapses the rows)
SELECT productid, SUM(sales) AS total_sales
FROM sales.orders
GROUP BY productid;

-- Every order with the overall total and its product's total beside it (rows are kept)
SELECT orderid, productid, sales,
       SUM(sales) OVER () AS total_sales,
       SUM(sales) OVER (PARTITION BY productid) AS sales_by_product
FROM sales.orders;

-- Every order with the total for its product and order status combination
SELECT orderid, productid, orderstatus, sales,
       SUM(sales) OVER (PARTITION BY productid, orderstatus) AS sales_by_product_status
FROM sales.orders;

-- Every order with its product's order count, average, lowest and highest sale
SELECT orderid, productid, sales,
       COUNT(*) OVER (PARTITION BY productid) AS orders_for_product,
       AVG(sales) OVER (PARTITION BY productid) AS avg_for_product,
       MIN(sales) OVER (PARTITION BY productid) AS min_for_product,
       MAX(sales) OVER (PARTITION BY productid) AS max_for_product
FROM sales.orders;

-- What share of total sales each order makes up, largest first
SELECT orderid, sales,
       ROUND(100.0 * sales / SUM(sales) OVER (), 2) AS pct_of_total
FROM sales.orders
ORDER BY sales DESC;

-- How far each order is above or below the average order
SELECT orderid, sales,
       ROUND(AVG(sales) OVER (), 2) AS avg_sales,
       sales - ROUND(AVG(sales) OVER (), 2) AS diff_from_avg
FROM sales.orders;

-- Whether each order is the biggest sale for its product
SELECT orderid, productid, sales,
       sales = MAX(sales) OVER (PARTITION BY productid) AS is_product_max
FROM sales.orders;

-- Running total of sales over time
SELECT orderid, orderdate, sales,
       SUM(sales) OVER (ORDER BY orderdate, orderid) AS running_total
FROM sales.orders;

-- Running total of sales over time, restarting for each product
SELECT orderid, productid, orderdate, sales,
       SUM(sales) OVER (PARTITION BY productid ORDER BY orderdate, orderid) AS running_total_by_product
FROM sales.orders;

-- Rolling total of the current order and the two before it
SELECT orderid, orderdate, sales,
       SUM(sales) OVER (ORDER BY orderdate, orderid ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_3
FROM sales.orders;

-- Moving average of the current order and the two before it
SELECT orderid, orderdate, sales,
       ROUND(AVG(sales) OVER (ORDER BY orderdate, orderid ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3
FROM sales.orders;

-- Average customer score with missing scores ignored versus counted as 0
SELECT customerid, score,
       AVG(score) OVER () AS avg_ignoring_nulls,
       AVG(COALESCE(score, 0)) OVER () AS avg_nulls_as_zero
FROM sales.customers;

-- Running total of sales by amount, comparing the default frame with an explicit ROWS frame (they differ when sales values tie)
SELECT orderid, sales,
       SUM(sales) OVER (ORDER BY sales) AS default_range_total,
       SUM(sales) OVER (ORDER BY sales ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS rows_total
FROM sales.orders
ORDER BY sales, orderid;
