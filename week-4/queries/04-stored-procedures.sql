-- Stored procedures and functions | salesdb
-- In PostgreSQL a procedure is run with CALL and cannot return rows with a plain SELECT.
-- To return a result set, the equivalent is a function used in a FROM clause.

-- Make a copy of customers so the procedures can change data without touching the real table
DROP TABLE IF EXISTS sales.customers_copy;
CREATE TABLE sales.customers_copy AS
SELECT * FROM sales.customers;

-- A function that returns the customer count and average score for a country (default USA)
CREATE OR REPLACE FUNCTION sales.get_customer_summary(p_country text DEFAULT 'USA')
RETURNS TABLE (total_customers bigint, avg_score numeric)
LANGUAGE sql
AS $$
    SELECT COUNT(*), ROUND(AVG(score), 2)
    FROM sales.customers
    WHERE country = p_country;
$$;

-- Run the function for Germany
SELECT * FROM sales.get_customer_summary('Germany');

-- Run the function with no argument, so it uses the default country, USA
SELECT * FROM sales.get_customer_summary();

-- A procedure with variables that prints the summary for a country as notices (PostgreSQL's PRINT)
CREATE OR REPLACE PROCEDURE sales.print_customer_summary(p_country text DEFAULT 'USA')
LANGUAGE plpgsql
AS $$
DECLARE
    v_total int;
    v_avg numeric;
BEGIN
    SELECT COUNT(*), ROUND(AVG(score), 2)
    INTO v_total, v_avg
    FROM sales.customers
    WHERE country = p_country;

    RAISE NOTICE 'Total customers from %: %', p_country, v_total;
    RAISE NOTICE 'Average score from %: %', p_country, COALESCE(v_avg, 0);
END;
$$;

-- Run the procedure for Germany
CALL sales.print_customer_summary('Germany');

-- A procedure that hands its results back through INOUT parameters
CREATE OR REPLACE PROCEDURE sales.customer_stats(IN p_country text, INOUT p_total bigint, INOUT p_avg numeric)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT COUNT(*), ROUND(AVG(score), 2)
    INTO p_total, p_avg
    FROM sales.customers
    WHERE country = p_country;
END;
$$;

-- Run it for the USA: the INOUT values come back as a result row
CALL sales.customer_stats('USA', NULL, NULL);

-- A procedure with flow control: set missing scores to 0 in the customer copy, but only if there are any
CREATE OR REPLACE PROCEDURE sales.fix_null_scores()
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM sales.customers_copy WHERE score IS NULL) THEN
        RAISE NOTICE 'Updating NULL scores to 0';
        UPDATE sales.customers_copy SET score = 0 WHERE score IS NULL;
    ELSE
        RAISE NOTICE 'No NULL scores found';
    END IF;
END;
$$;

-- First run: finds Anna's missing score and updates it
CALL sales.fix_null_scores();

-- Second run: nothing left to fix
CALL sales.fix_null_scores();

-- Check the customer copy after the fix
SELECT customerid, firstname, score FROM sales.customers_copy ORDER BY customerid;

-- A procedure with error handling: unit price for an order, catching the divide by zero case
CREATE OR REPLACE PROCEDURE sales.show_unit_price(p_orderid int)
LANGUAGE plpgsql
AS $$
DECLARE
    v_price numeric;
BEGIN
    SELECT sales / quantity INTO v_price
    FROM sales.orders
    WHERE orderid = p_orderid;

    RAISE NOTICE 'Order % unit price: %', p_orderid, v_price;
EXCEPTION
    WHEN division_by_zero THEN
        RAISE NOTICE 'Order % has quantity 0, so the unit price cannot be calculated', p_orderid;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected problem: %', SQLERRM;
END;
$$;

-- Order 3 works normally
CALL sales.show_unit_price(3);

-- Order 10 has quantity 0, so the error is caught instead of stopping the script
CALL sales.show_unit_price(10);

-- A reporting table that a procedure will reload
CREATE TABLE IF NOT EXISTS sales.monthly_sales_report (
    month date PRIMARY KEY,
    total_sales bigint,
    total_orders bigint
);

-- A procedure that empties and reloads the monthly sales report, then says how many months it loaded
CREATE OR REPLACE PROCEDURE sales.refresh_monthly_sales_report()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows int;
BEGIN
    TRUNCATE sales.monthly_sales_report;

    INSERT INTO sales.monthly_sales_report (month, total_sales, total_orders)
    SELECT DATE_TRUNC('month', orderdate)::date, SUM(sales), COUNT(*)
    FROM sales.orders
    GROUP BY DATE_TRUNC('month', orderdate);

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    RAISE NOTICE 'Loaded % months into monthly_sales_report', v_rows;
END;
$$;

-- Run the reload procedure
CALL sales.refresh_monthly_sales_report();

-- Read the report the procedure just built
SELECT * FROM sales.monthly_sales_report ORDER BY month;

-- List the functions and procedures in the sales schema (f = function, p = procedure)
SELECT p.proname AS name, p.prokind AS kind
FROM pg_proc AS p
INNER JOIN pg_namespace AS n ON p.pronamespace = n.oid
WHERE n.nspname = 'sales'
ORDER BY p.proname;
