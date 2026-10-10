-- String functions | salesdb

-- Customer first names in upper case, lower case and proper case
SELECT firstname, UPPER(firstname) AS upper_name, LOWER(firstname) AS lower_name, INITCAP('jOSSEF') AS proper
FROM sales.customers;

-- Customers whose first name has leading or trailing spaces (no rows means the data is clean)
SELECT firstname FROM sales.customers WHERE firstname <> TRIM(firstname);

-- Strip the dashes from a phone number
SELECT REPLACE('123-456-7890', '-', '') AS phone_digits;

-- Change a file extension from .txt to .csv
SELECT REPLACE('report.txt', '.txt', '.csv') AS new_file;

-- Number of characters in each first name
SELECT firstname, LENGTH(firstname) AS name_length FROM sales.customers;

-- First two and last two characters of each first name
SELECT firstname, LEFT(TRIM(firstname), 2) AS first_two, RIGHT(TRIM(firstname), 2) AS last_two
FROM sales.customers;

-- Each first name without its first letter
SELECT firstname, SUBSTRING(TRIM(firstname) FROM 2) AS without_first_letter
FROM sales.customers;

-- Three characters of each first name, starting at the second letter
SELECT firstname, SUBSTRING(firstname, 2, 3) AS three_chars
FROM sales.customers;

-- Where the letter e first appears in each first name (0 if it does not)
SELECT firstname, POSITION('e' IN firstname) AS pos_e FROM sales.customers;

-- Full name with ||; Mary shows NULL because her last name is missing
SELECT firstname, lastname, firstname || ' ' || lastname AS full_name
FROM sales.customers;

-- Full name with CONCAT and CONCAT_WS, which cope with the missing last name
SELECT firstname, lastname,
       CONCAT(firstname, ' ', lastname) AS concat_name,
       CONCAT_WS(' ', firstname, lastname) AS concat_ws_name
FROM sales.customers;

-- A label for each customer showing their name and country
SELECT customerid, firstname || ' - ' || country AS customer_label
FROM sales.customers;

-- Order ids padded with zeros to a 5-digit code
SELECT orderid, LPAD(orderid::text, 5, '0') AS order_code FROM sales.orders;
