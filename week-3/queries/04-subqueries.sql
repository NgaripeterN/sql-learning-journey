-- Subqueries | salesdb

-- Customers whose total sales are above 100 (subquery in FROM builds the totals first)
SELECT t.customerid, t.total_sales
FROM (
    SELECT customerid, SUM(sales) AS total_sales
    FROM sales.orders
    GROUP BY customerid
) AS t
WHERE t.total_sales > 100;

-- Every product with its total sales; Socks shows NULL because it has never been ordered (subquery in FROM, then joined)
SELECT p.product, s.total_sales
FROM sales.products AS p
LEFT JOIN (
    SELECT productid, SUM(sales) AS total_sales
    FROM sales.orders
    GROUP BY productid
) AS s ON p.productid = s.productid
ORDER BY p.productid;

-- Each order next to the overall average order value (scalar subquery in SELECT)
SELECT orderid, sales,
       (SELECT AVG(sales) FROM sales.orders) AS avg_sales
FROM sales.orders;

-- Each order with its product name looked up by a correlated scalar subquery (the same result as a join)
SELECT o.orderid, o.productid,
       (SELECT p.product FROM sales.products AS p WHERE p.productid = o.productid) AS product
FROM sales.orders AS o;

-- Orders with sales above the overall average (subquery in WHERE with a comparison operator)
SELECT orderid, sales
FROM sales.orders
WHERE sales > (SELECT AVG(sales) FROM sales.orders);

-- Orders placed by German customers (subquery with IN)
SELECT *
FROM sales.orders
WHERE customerid IN (
    SELECT customerid FROM sales.customers WHERE country = 'Germany'
);

-- The same German orders written as a join; a join can return duplicates if the match is not unique
SELECT o.*
FROM sales.orders AS o
INNER JOIN sales.customers AS c ON o.customerid = c.customerid
WHERE c.country = 'Germany';

-- Employees who are not managers, attempted with NOT IN: returns no rows because managerid contains a NULL
SELECT employeeid, firstname
FROM sales.employees
WHERE employeeid NOT IN (SELECT managerid FROM sales.employees);

-- Employees who are not managers, fixed by removing the NULL from the subquery
SELECT employeeid, firstname
FROM sales.employees
WHERE employeeid NOT IN (SELECT managerid FROM sales.employees WHERE managerid IS NOT NULL);

-- Employees who earn more than at least one Marketing employee (ANY)
SELECT employeeid, firstname, department, salary
FROM sales.employees
WHERE salary > ANY (SELECT salary FROM sales.employees WHERE department = 'Marketing');

-- Employees who earn more than every Marketing employee (ALL)
SELECT employeeid, firstname, department, salary
FROM sales.employees
WHERE salary > ALL (SELECT salary FROM sales.employees WHERE department = 'Marketing');

-- Customers who have at least one delivered order (correlated subquery with EXISTS)
SELECT c.customerid, c.firstname
FROM sales.customers AS c
WHERE EXISTS (
    SELECT 1
    FROM sales.orders AS o
    WHERE o.customerid = c.customerid AND o.orderstatus = 'Delivered'
);

-- Customers with no orders at all (correlated subquery with NOT EXISTS, safe with NULLs)
SELECT c.customerid, c.firstname
FROM sales.customers AS c
WHERE NOT EXISTS (
    SELECT 1 FROM sales.orders AS o WHERE o.customerid = c.customerid
);

-- Orders that are above the average for their own product (correlated: the subquery reruns for each order)
SELECT o.orderid, o.productid, o.sales
FROM sales.orders AS o
WHERE o.sales > (
    SELECT AVG(o2.sales)
    FROM sales.orders AS o2
    WHERE o2.productid = o.productid
);
