-- Date and time functions | salesdb

-- The current date and time
SELECT NOW() AS now, CURRENT_DATE AS today, CURRENT_TIMESTAMP AS ts;

-- Year, month, day, quarter and weekday number of each order (weekday: 0 is Sunday)
SELECT
    orderid,
    orderdate,
    EXTRACT(YEAR FROM orderdate) AS year,
    EXTRACT(MONTH FROM orderdate) AS month,
    EXTRACT(DAY FROM orderdate) AS day,
    EXTRACT(QUARTER FROM orderdate) AS quarter,
    EXTRACT(DOW FROM orderdate) AS weekday_number
FROM sales.orders;

-- The first day of the month and year that each order falls in
SELECT orderid, orderdate,
       DATE_TRUNC('month', orderdate)::date AS month_start,
       DATE_TRUNC('year', orderdate)::date AS year_start
FROM sales.orders;

-- Each order date formatted as year-month, month name and weekday name
SELECT orderid, orderdate,
       TO_CHAR(orderdate, 'YYYY-MM') AS year_month,
       TO_CHAR(orderdate, 'FMMonth YYYY') AS month_name,
       TO_CHAR(orderdate, 'FMDay') AS day_name
FROM sales.orders;

-- How many orders were placed in each month
SELECT TO_CHAR(orderdate, 'YYYY-MM') AS year_month, COUNT(*) AS total_orders
FROM sales.orders
GROUP BY TO_CHAR(orderdate, 'YYYY-MM')
ORDER BY year_month;

-- Days taken to ship each order, plus the order date moved 7 days forward and 1 month back
SELECT orderid, orderdate, shipdate,
       shipdate - orderdate AS days_to_ship,
       orderdate + INTERVAL '7 days' AS plus_7_days,
       orderdate - INTERVAL '1 month' AS minus_1_month
FROM sales.orders;

-- Average days to ship for delivered and shipped orders
SELECT orderstatus, ROUND(AVG(shipdate - orderdate), 1) AS avg_days_to_ship
FROM sales.orders
GROUP BY orderstatus;

-- Each employee's age as an interval and in whole years
SELECT firstname, birthdate, AGE(CURRENT_DATE, birthdate) AS age_interval,
       EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate))::int AS age_years
FROM sales.employees;

-- Turning text into dates, and a timestamp into a plain date
SELECT TO_DATE('20/08/2025', 'DD/MM/YYYY') AS parsed_date,
       '2025-08-20'::date AS cast_date,
       creationtime::date AS creation_date
FROM sales.orders
LIMIT 3;

-- Orders placed in February 2025 (start of month up to, but not including, the next month)
SELECT * FROM sales.orders
WHERE orderdate >= '2025-02-01' AND orderdate < '2025-03-01';
