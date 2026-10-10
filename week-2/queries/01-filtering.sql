-- Filtering data | salesdb

-- Customers based in Germany
SELECT * FROM sales.customers WHERE country = 'Germany';

-- Customers based anywhere except Germany
SELECT * FROM sales.customers WHERE country <> 'Germany';

-- Customers with a score of 500 or more
SELECT * FROM sales.customers WHERE score >= 500;

-- US customers with a score above 500 (both conditions must be true)
SELECT * FROM sales.customers WHERE country = 'USA' AND score > 500;

-- Customers who are in the US or have a score above 500 (either condition)
SELECT * FROM sales.customers WHERE country = 'USA' OR score > 500;

-- Customers outside the US
SELECT * FROM sales.customers WHERE NOT country = 'USA';

-- Customers with a score from 100 to 500, inclusive
SELECT * FROM sales.customers WHERE score BETWEEN 100 AND 500;

-- Orders placed in January 2025
SELECT * FROM sales.orders WHERE orderdate BETWEEN '2025-01-01' AND '2025-01-31';

-- Customers from Germany or the USA
SELECT * FROM sales.customers WHERE country IN ('Germany', 'USA');

-- Orders for the Bottle (101) and Tire (102) products
SELECT * FROM sales.orders WHERE productid IN (101, 102);

-- Customers whose first name starts with M
SELECT * FROM sales.customers WHERE firstname LIKE 'M%';

-- Customers whose first name ends with n
SELECT * FROM sales.customers WHERE firstname LIKE '%n';

-- Customers whose first name contains an r
SELECT * FROM sales.customers WHERE firstname LIKE '%r%';

-- Customers whose first name has r as the third letter
SELECT * FROM sales.customers WHERE firstname LIKE '__r%';

-- Customers whose first name starts with m or M (ILIKE ignores case)
SELECT * FROM sales.customers WHERE firstname ILIKE 'm%';

-- Customers with no score recorded
SELECT * FROM sales.customers WHERE score IS NULL;

-- Customers who have a last name on file
SELECT * FROM sales.customers WHERE lastname IS NOT NULL;

-- The countries our customers come from, each listed once
SELECT DISTINCT country FROM sales.customers;

-- The order statuses in use, each listed once
SELECT DISTINCT orderstatus FROM sales.orders;

-- Top 3 customers by score, with missing scores last
SELECT * FROM sales.customers ORDER BY score DESC NULLS LAST LIMIT 3;

-- The 2 most recent orders
SELECT * FROM sales.orders ORDER BY orderdate DESC LIMIT 2;

-- Orders 4 to 6: skip the first 3 rows, then take 3 (paging)
SELECT * FROM sales.orders ORDER BY orderid LIMIT 3 OFFSET 3;
