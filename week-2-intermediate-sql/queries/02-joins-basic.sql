-- Joins (basics) | salesdb

-- Look at each table on its own before joining
SELECT * FROM sales.customers;
SELECT * FROM sales.orders;

-- Orders with their customer details; customers without orders are left out (INNER JOIN)
SELECT c.customerid, c.firstname, o.orderid, o.sales
FROM sales.customers AS c
INNER JOIN sales.orders AS o ON c.customerid = o.customerid;

-- All customers, with their orders if they have any (LEFT JOIN)
SELECT c.customerid, c.firstname, o.orderid, o.sales
FROM sales.customers AS c
LEFT JOIN sales.orders AS o ON c.customerid = o.customerid;

-- All orders, with the customer if one exists (RIGHT JOIN)
SELECT c.customerid, c.firstname, o.orderid, o.sales
FROM sales.customers AS c
RIGHT JOIN sales.orders AS o ON c.customerid = o.customerid;

-- Same result as the RIGHT JOIN above, written as a LEFT JOIN by swapping the tables
SELECT c.customerid, c.firstname, o.orderid, o.sales
FROM sales.orders AS o
LEFT JOIN sales.customers AS c ON c.customerid = o.customerid;

-- Every customer and every order together, matched where possible (FULL JOIN)
SELECT c.customerid, c.firstname, o.orderid, o.sales
FROM sales.customers AS c
FULL JOIN sales.orders AS o ON c.customerid = o.customerid;

-- Customers who have never placed an order (LEFT ANTI JOIN)
SELECT c.*
FROM sales.customers AS c
LEFT JOIN sales.orders AS o ON c.customerid = o.customerid
WHERE o.customerid IS NULL;

-- Orders that belong to no known customer (RIGHT ANTI JOIN)
SELECT o.*
FROM sales.customers AS c
RIGHT JOIN sales.orders AS o ON c.customerid = o.customerid
WHERE c.customerid IS NULL;

-- Customers with no orders and orders with no customer, in one result (FULL ANTI JOIN)
SELECT c.customerid, c.firstname, o.orderid, o.customerid AS order_customerid
FROM sales.customers AS c
FULL JOIN sales.orders AS o ON c.customerid = o.customerid
WHERE c.customerid IS NULL OR o.customerid IS NULL;

-- Every customer paired with every product (CROSS JOIN)
SELECT c.firstname, p.product
FROM sales.customers AS c
CROSS JOIN sales.products AS p;
