-- =========================================================
-- Week 1: SQL Fundamentals — traditional SQL (PostgreSQL)
-- Dataset: MyDatabase (customers, orders)
-- Simple to complex, one clause building on the last.
-- =========================================================

-- 1. See everything in the table
FROM customers;

-- 2. Only look at the columns that matter, not every column.
SELECT first_name, country, score
FROM customers;

-- 3. Just the first few rows, to sample the data without scrolling.
SELECT *
FROM customers
LIMIT 3;

-- 4. Which countries do we have customers in? (unique values only)
SELECT DISTINCT country
FROM customers;

-- 5. Find one specific customer's country.
SELECT first_name, country
FROM customers
WHERE first_name = 'Maria';

-- 6. Who has an active score (excluding anyone at 0)?
SELECT first_name, country, score
FROM customers
WHERE score > 0;

-- 7. Same as above, but sorted so the highest scorers appear first.
SELECT first_name, country, score
FROM customers
WHERE score > 0
ORDER BY score DESC;

-- 8. Just the top 3 scorers, excluding inactive customers.
SELECT first_name, country, score
FROM customers
WHERE score > 0
ORDER BY score DESC
LIMIT 3;

-- 9. How many customers do we have per country?
SELECT country, COUNT(*) AS customer_count
FROM customers
GROUP BY country;

-- 10. Which countries have more than one customer?
-- (filters out groups of size 1, since a "group" of one customer
--  isn't interesting for this kind of comparison)
SELECT country, COUNT(*) AS customer_count
FROM customers
GROUP BY country
HAVING COUNT(*) > 1;

-- 11. Which country brings in the most total score, and how many
-- customers does it have? The most complex query this week —
-- combines GROUP BY, an aggregate, sorting, and a row cap.
SELECT country, COUNT(*) AS customer_count, SUM(score) AS total_score
FROM customers
GROUP BY country
ORDER BY total_score DESC
LIMIT 3;

-- 12. Bonus: which orders belong to a customer that doesn't exist in
-- the customers table? (orders.customer_id = 6 has no matching row)
-- A first taste of why joins matter — coming in week 2.
SELECT *
FROM orders
WHERE customer_id NOT IN (SELECT id FROM customers);
