-- Joins (advanced) | salesdb

-- Each order with the customer, product and salesperson names (joining four tables)
SELECT
    o.orderid,
    c.firstname AS customer,
    p.product,
    e.firstname AS salesperson,
    o.sales
FROM sales.orders AS o
LEFT JOIN sales.customers AS c ON o.customerid = c.customerid
LEFT JOIN sales.products AS p ON o.productid = p.productid
LEFT JOIN sales.employees AS e ON o.salespersonid = e.employeeid;

-- Each employee with the name of their manager (self join on the employees table)
SELECT
    e.employeeid,
    e.firstname AS employee,
    m.firstname AS manager
FROM sales.employees AS e
LEFT JOIN sales.employees AS m ON e.managerid = m.employeeid;

-- All customers, showing only their delivered orders; customers with none still appear
SELECT c.firstname, o.orderid, o.orderstatus
FROM sales.customers AS c
LEFT JOIN sales.orders AS o
    ON c.customerid = o.customerid
   AND o.orderstatus = 'Delivered';

-- Customers who have never placed an order (same answer as the LEFT ANTI JOIN, using NOT EXISTS)
SELECT c.*
FROM sales.customers AS c
WHERE NOT EXISTS (
    SELECT 1 FROM sales.orders AS o WHERE o.customerid = c.customerid
);

-- Customer and product pairs where that customer has never bought that product
SELECT c.firstname, p.product
FROM sales.customers AS c
CROSS JOIN sales.products AS p
WHERE NOT EXISTS (
    SELECT 1
    FROM sales.orders AS o
    WHERE o.customerid = c.customerid AND o.productid = p.productid
);

-- Total sales per customer, highest first; customers with no orders show 0
SELECT
    c.customerid,
    c.firstname,
    COALESCE(SUM(o.sales), 0) AS total_sales
FROM sales.customers AS c
LEFT JOIN sales.orders AS o ON c.customerid = o.customerid
GROUP BY c.customerid, c.firstname
ORDER BY total_sales DESC;
