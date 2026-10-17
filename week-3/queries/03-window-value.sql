-- Window functions: value | salesdb

-- Each order next to the sales of the order before it and the order after it
SELECT orderid, orderdate, sales,
       LAG(sales) OVER (ORDER BY orderdate, orderid) AS prev_sales,
       LEAD(sales) OVER (ORDER BY orderdate, orderid) AS next_sales
FROM sales.orders;

-- Sales from two orders back and two orders ahead, with 0 where no such order exists
SELECT orderid, sales,
       LAG(sales, 2, 0) OVER (ORDER BY orderdate, orderid) AS two_back,
       LEAD(sales, 2, 0) OVER (ORDER BY orderdate, orderid) AS two_ahead
FROM sales.orders;

-- Monthly sales with the previous month's total and the change between them
WITH monthly AS (
    SELECT DATE_TRUNC('month', orderdate)::date AS month, SUM(sales) AS total_sales
    FROM sales.orders
    GROUP BY DATE_TRUNC('month', orderdate)
)
SELECT month, total_sales,
       LAG(total_sales) OVER (ORDER BY month) AS prev_month,
       total_sales - LAG(total_sales) OVER (ORDER BY month) AS change,
       ROUND(100.0 * (total_sales - LAG(total_sales) OVER (ORDER BY month))
             / NULLIF(LAG(total_sales) OVER (ORDER BY month), 0), 1) AS pct_change
FROM monthly;

-- Days since each customer's previous order
SELECT customerid, orderid, orderdate,
       orderdate - LAG(orderdate) OVER (PARTITION BY customerid ORDER BY orderdate) AS days_since_prev
FROM sales.orders
ORDER BY customerid, orderdate;

-- Average days between orders for each customer who has ordered more than once
SELECT customerid, ROUND(AVG(days_since_prev), 1) AS avg_days_between_orders
FROM (
    SELECT customerid,
           orderdate - LAG(orderdate) OVER (PARTITION BY customerid ORDER BY orderdate) AS days_since_prev
    FROM sales.orders
) AS t
GROUP BY customerid
HAVING COUNT(days_since_prev) > 0;

-- Each order next to the first and the most recent sale overall (LAST_VALUE needs the full frame)
SELECT orderid, orderdate, sales,
       FIRST_VALUE(sales) OVER (ORDER BY orderdate, orderid) AS first_sales,
       LAST_VALUE(sales) OVER (
           ORDER BY orderdate, orderid
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS last_sales
FROM sales.orders;

-- Each order next to the lowest and highest sale for its product, and how far it is above the lowest
SELECT orderid, productid, sales,
       FIRST_VALUE(sales) OVER (PARTITION BY productid ORDER BY sales) AS lowest,
       LAST_VALUE(sales) OVER (
           PARTITION BY productid ORDER BY sales
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS highest,
       sales - FIRST_VALUE(sales) OVER (PARTITION BY productid ORDER BY sales) AS above_lowest
FROM sales.orders;
