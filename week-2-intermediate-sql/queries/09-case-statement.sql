-- CASE statement | salesdb

-- Label each order as High (over 50), Medium (21 to 50) or Low (20 or less) by sales amount
SELECT orderid, sales,
       CASE
           WHEN sales > 50 THEN 'High'
           WHEN sales > 20 THEN 'Medium'
           ELSE 'Low'
       END AS sales_category
FROM sales.orders
ORDER BY sales DESC;

-- Show gender codes M and F as Male and Female
SELECT employeeid, firstname, gender,
       CASE gender
           WHEN 'M' THEN 'Male'
           WHEN 'F' THEN 'Female'
           ELSE 'Unknown'
       END AS gender_label
FROM sales.employees;

-- Group customers into Gold, Silver and Bronze tiers by score; missing scores get their own label
SELECT customerid, firstname, score,
       CASE
           WHEN score IS NULL THEN 'No score'
           WHEN score >= 750 THEN 'Gold'
           WHEN score >= 500 THEN 'Silver'
           ELSE 'Bronze'
       END AS tier
FROM sales.customers;

-- Total sales in each category (High, Medium, Low)
SELECT category_label, SUM(sales) AS total_sales
FROM (
    SELECT sales,
           CASE WHEN sales > 50 THEN 'High' WHEN sales > 20 THEN 'Medium' ELSE 'Low' END AS category_label
    FROM sales.orders
) AS t
GROUP BY category_label
ORDER BY total_sales DESC;

-- For each customer: total orders, how many were delivered and how many were shipped
SELECT
    customerid,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN orderstatus = 'Delivered' THEN 1 ELSE 0 END) AS delivered_orders,
    SUM(CASE WHEN orderstatus = 'Shipped' THEN 1 ELSE 0 END) AS shipped_orders
FROM sales.orders
GROUP BY customerid
ORDER BY customerid;

-- The same counts using FILTER, plus each customer's total from orders over 30
SELECT
    customerid,
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (WHERE orderstatus = 'Delivered') AS delivered_orders,
    SUM(sales) FILTER (WHERE sales > 30) AS big_sales
FROM sales.orders
GROUP BY customerid
ORDER BY customerid;

-- Customers with the German ones first, then by highest score
SELECT * FROM sales.customers
ORDER BY CASE WHEN country = 'Germany' THEN 0 ELSE 1 END, score DESC NULLS LAST;
