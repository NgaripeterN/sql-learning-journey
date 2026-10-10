-- Aggregate functions | salesdb

-- Overall order summary: number of orders, total, average, smallest and largest sale
SELECT
    COUNT(*) AS total_orders,
    SUM(sales) AS total_sales,
    AVG(sales) AS avg_sales,
    MIN(sales) AS min_sales,
    MAX(sales) AS max_sales
FROM sales.orders;

-- Total customers, customers with a score, and number of different countries
SELECT COUNT(*) AS all_rows, COUNT(score) AS non_null_scores, COUNT(DISTINCT country) AS countries
FROM sales.customers;

-- Number of customers and average score in each country
SELECT country, COUNT(*) AS customers, AVG(score) AS avg_score
FROM sales.customers
GROUP BY country;

-- Number of orders and total sales for each order status
SELECT orderstatus, COUNT(*) AS orders, SUM(sales) AS total_sales
FROM sales.orders
GROUP BY orderstatus;

-- Customers whose total sales are above 50, highest first
SELECT customerid, SUM(sales) AS total_sales
FROM sales.orders
GROUP BY customerid
HAVING SUM(sales) > 50
ORDER BY total_sales DESC;

-- Customers whose delivered orders add up to more than 20 (WHERE filters rows first, HAVING filters totals)
SELECT customerid, SUM(sales) AS total_sales
FROM sales.orders
WHERE orderstatus = 'Delivered'
GROUP BY customerid
HAVING SUM(sales) > 20;

-- Total sales and units sold for each product, best seller first
SELECT p.category, p.product, SUM(o.sales) AS total_sales, SUM(o.quantity) AS units
FROM sales.orders AS o
INNER JOIN sales.products AS p ON o.productid = p.productid
GROUP BY p.category, p.product
ORDER BY total_sales DESC;

-- Orders handled and total sales for each salesperson
SELECT e.firstname, e.department, COUNT(*) AS orders, SUM(o.sales) AS total_sales
FROM sales.orders AS o
INNER JOIN sales.employees AS e ON o.salespersonid = e.employeeid
GROUP BY e.firstname, e.department
ORDER BY total_sales DESC;

-- Customer names listed together on one line for each country
SELECT country, STRING_AGG(firstname, ', ' ORDER BY firstname) AS customer_names
FROM sales.customers
GROUP BY country;

-- Total sales for each month
SELECT DATE_TRUNC('month', orderdate)::date AS month, SUM(sales) AS total_sales
FROM sales.orders
GROUP BY DATE_TRUNC('month', orderdate)
ORDER BY month;

-- Average order value for each customer, highest first
SELECT customerid, ROUND(AVG(sales), 2) AS avg_sales
FROM sales.orders
GROUP BY customerid
ORDER BY avg_sales DESC;
