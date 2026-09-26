-- =========================================================
-- Week 1: DDL & DML basics
-- Practiced on a throwaway table, kept separate from the real
-- dataset so I could break things safely.
-- =========================================================

-- DDL: define a table to practice on.
CREATE TABLE practice_customers (
    customer_id SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    country     VARCHAR(50),
    signup_date DATE DEFAULT CURRENT_DATE
);

-- DDL: add a column I forgot to include the first time.
ALTER TABLE practice_customers
ADD COLUMN email VARCHAR(255);

-- DDL: widen a column that turned out to be too small.
ALTER TABLE practice_customers
ALTER COLUMN name TYPE VARCHAR(150);

-- DML: add a row.
INSERT INTO practice_customers (name, country, email)
VALUES ('Wanjiru Kamau', 'Kenya', 'wanjiru@example.com');

-- DML: fix a value in an existing row.
UPDATE practice_customers
SET country = 'Uganda'
WHERE customer_id = 1;

-- DML: remove a row I no longer need.
DELETE FROM practice_customers
WHERE customer_id = 1;

-- DDL: clean up the practice table entirely.
DROP TABLE IF EXISTS practice_customers;
