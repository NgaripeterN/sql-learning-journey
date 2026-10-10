-- Set operators | salesdb

-- Every distinct person we know, customers and employees combined (UNION removes duplicates)
SELECT firstname, lastname FROM sales.customers
UNION
SELECT firstname, lastname FROM sales.employees
ORDER BY firstname;

-- The same list with duplicates kept, so shared names appear twice (UNION ALL)
SELECT firstname, lastname FROM sales.customers
UNION ALL
SELECT firstname, lastname FROM sales.employees
ORDER BY firstname;

-- Employees who are not also customers (EXCEPT)
SELECT firstname, lastname FROM sales.employees
EXCEPT
SELECT firstname, lastname FROM sales.customers;

-- People who are both an employee and a customer (INTERSECT)
SELECT firstname, lastname FROM sales.employees
INTERSECT
SELECT firstname, lastname FROM sales.customers;

-- Current and archived orders in one list, with a column showing which table each came from
SELECT 'orders' AS source_table, orderid, productid, customerid, orderdate, orderstatus, sales
FROM sales.orders
UNION ALL
SELECT 'ordersarchive', orderid, productid, customerid, orderdate, orderstatus, sales
FROM sales.ordersarchive
ORDER BY orderdate;

-- Order ids that appear in both the current and the archive table
SELECT orderid FROM sales.orders
INTERSECT
SELECT orderid FROM sales.ordersarchive
ORDER BY orderid;

-- Order ids that exist only in the archive
SELECT orderid FROM sales.ordersarchive
EXCEPT
SELECT orderid FROM sales.orders;
