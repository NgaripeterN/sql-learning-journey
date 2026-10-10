-- Numeric functions | salesdb

-- One number rounded, rounded up, rounded down and cut off at different precisions
SELECT
    3.516 AS value,
    ROUND(3.516, 2) AS round_2,
    ROUND(3.516, 1) AS round_1,
    ROUND(3.516, 0) AS round_0,
    CEIL(3.2) AS ceil_value,
    FLOOR(3.8) AS floor_value,
    TRUNC(3.999, 1) AS trunc_1;

-- Absolute value of a negative and a positive number
SELECT ABS(-10) AS abs_negative, ABS(10) AS abs_positive;

-- Why 5 / 2 gives 2, and two ways to get 2.5
SELECT 5 / 2 AS integer_division, 5 / 2.0 AS decimal_division, 5::numeric / 2 AS cast_division;

-- Price per unit for each order; order 10 has quantity 0, so NULLIF avoids a divide by zero error
SELECT orderid, sales, quantity,
       ROUND(sales::numeric / NULLIF(quantity, 0), 2) AS unit_price
FROM sales.orders;

-- Remainder, power and square root examples
SELECT MOD(10, 3) AS mod_value, 10 % 3 AS mod_operator, POWER(2, 5) AS power_value, SQRT(144) AS sqrt_value;

-- Whether each order id is even or odd
SELECT orderid, CASE WHEN orderid % 2 = 0 THEN 'even' ELSE 'odd' END AS parity
FROM sales.orders;

-- The larger and smaller of sales and quantity for each order
SELECT orderid, sales, quantity, GREATEST(sales, quantity) AS bigger, LEAST(sales, quantity) AS smaller
FROM sales.orders;

-- Each product's price after a 10 percent discount
SELECT product, price, ROUND(price * 0.9, 2) AS discounted_price FROM sales.products;
