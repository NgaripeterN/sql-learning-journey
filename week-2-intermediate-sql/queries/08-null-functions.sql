-- NULL functions | salesdb

-- Customers with no score
SELECT * FROM sales.customers WHERE score IS NULL;

-- Customers who do have a score
SELECT * FROM sales.customers WHERE score IS NOT NULL;

-- Customer scores with a missing score shown as 0
SELECT customerid, firstname, score, COALESCE(score, 0) AS score_clean
FROM sales.customers;

-- Last names with a missing one shown as n/a
SELECT firstname, lastname, COALESCE(lastname, 'n/a') AS lastname_clean
FROM sales.customers;

-- Average score ignoring missing scores (625) versus treating them as 0 (500)
SELECT
    AVG(score) AS avg_ignoring_nulls,
    AVG(COALESCE(score, 0)) AS avg_nulls_as_zero
FROM sales.customers;

-- Total customers versus customers with a score (COUNT(*) counts NULLs, COUNT(column) does not)
SELECT COUNT(*) AS all_rows, COUNT(score) AS rows_with_score FROM sales.customers;

-- Billing addresses with blank text converted to NULL
SELECT orderid, billaddress, NULLIF(billaddress, '') AS billaddress_null_if_blank
FROM sales.orders;

-- Billing addresses cleaned up: both blank and NULL become 'unknown'
SELECT orderid, COALESCE(NULLIF(TRIM(billaddress), ''), 'unknown') AS billaddress_clean
FROM sales.orders;

-- Orders with a billing address that is missing or blank
SELECT orderid, billaddress
FROM sales.orders
WHERE billaddress IS NULL OR TRIM(billaddress) = '';

-- Customers sorted by score: NULLs last by default when ascending
SELECT firstname, score FROM sales.customers ORDER BY score;

-- Customers sorted by score with NULLs forced to the top
SELECT firstname, score FROM sales.customers ORDER BY score NULLS FIRST;

-- Customers sorted by highest score, with NULLs forced to the bottom
SELECT firstname, score FROM sales.customers ORDER BY score DESC NULLS LAST;

-- Customers who share a first and last name with an employee; a missing last name counts as a match
SELECT c.firstname, c.lastname
FROM sales.customers AS c
INNER JOIN sales.employees AS e
    ON c.firstname = e.firstname
   AND c.lastname IS NOT DISTINCT FROM e.lastname;

-- Why NULL breaks math: score plus 10 is NULL when the score is missing
SELECT customerid, score, score + 10 AS plus_10, COALESCE(score, 0) + 10 AS plus_10_clean
FROM sales.customers;
