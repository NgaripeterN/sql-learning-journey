# Week 2 Notes

## Join reference

| Join | What it returns |
|---|---|
| `INNER JOIN` | Only rows that match on both sides |
| `LEFT JOIN` | Every row from the left table, matches from the right (or `NULL`) |
| `RIGHT JOIN` | Every row from the right table, matches from the left (or `NULL`) |
| `FULL JOIN` | Every row from both tables, matched where possible |
| `CROSS JOIN` | Every combination of rows from both tables |
| Anti join | Rows with no match: `LEFT JOIN` plus `WHERE right.id IS NULL` |
| Self join | A table joined to itself, such as employee and manager |

## Set operators

| Operator | Purpose |
|---|---|
| `UNION` | Combine results and remove duplicates |
| `UNION ALL` | Combine results and keep duplicates |
| `EXCEPT` | Rows in the first result that are not in the second |
| `INTERSECT` | Rows that appear in both results |

## Function reference

| Group | Functions I used |
|---|---|
| String | `UPPER`, `LOWER`, `TRIM`, `REPLACE`, `LENGTH`, `LEFT`, `RIGHT`, `SUBSTRING`, `CONCAT_WS`, `LPAD` |
| Numeric | `ROUND`, `CEIL`, `FLOOR`, `ABS`, `MOD`, `POWER` |
| Date and time | `NOW`, `EXTRACT`, `DATE_TRUNC`, `TO_CHAR`, `AGE`, interval arithmetic |
| `NULL` | `COALESCE`, `NULLIF`, `IS DISTINCT FROM` |
| Conditional | `CASE WHEN` |
| Aggregate | `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `STRING_AGG` |
| Window | `OVER`, `PARTITION BY`, `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `NTILE`, `LAG`, `LEAD`, `FIRST_VALUE`, `LAST_VALUE` |

## SQL Server vs PostgreSQL

The course uses SQL Server, so these are the swaps I had to make.

| Task | SQL Server | PostgreSQL |
|---|---|---|
| Limit rows | `TOP 3` | `LIMIT 3` |
| Replace `NULL` | `ISNULL(x, 0)` | `COALESCE(x, 0)` |
| String length | `LEN(x)` | `LENGTH(x)` |
| Join text | `'a' + 'b'` | `'a' \|\| 'b'` or `CONCAT` |
| Current time | `GETDATE()` | `NOW()` |
| Date part | `DATEPART(year, d)` | `EXTRACT(YEAR FROM d)` |
| Add to a date | `DATEADD(day, 7, d)` | `d + INTERVAL '7 days'` |
| Date difference | `DATEDIFF(day, a, b)` | `b - a` |
| Format a date | `FORMAT(d, 'yyyy-MM')` | `TO_CHAR(d, 'YYYY-MM')` |
| Cast | `CONVERT(INT, x)` | `x::INT` or `CAST(x AS INT)` |
| If else | `IIF(a, b, c)` | `CASE WHEN a THEN b ELSE c END` |

## What I found tricky

`LEFT JOIN` filters can change the join. A condition in `WHERE` on the right table removes the unmatched rows and turns the query into an inner join. Putting the condition in `ON` keeps them.

`UNION` and `UNION ALL` behave differently on duplicates. `UNION` removes them, which costs extra work, so `UNION ALL` is the better choice when I know there are none.

`NULL` is not a value, so `= NULL` never matches. I need `IS NULL`. Blank text is also not `NULL`, so `billaddress` had both `''` and `NULL` and needed `NULLIF` and `COALESCE` together.

`||` returns `NULL` if any part is `NULL`. `CONCAT` and `CONCAT_WS` skip `NULL` values.

Integer division is easy to miss. `5 / 2` gives `2` in PostgreSQL. Casting one side to `numeric` fixes it, and `NULLIF(quantity, 0)` stops a divide by zero error.

`GROUP BY` collapses rows, while a window function keeps every row and adds the calculation alongside. That makes it possible to show a total or a percentage of total next to each order.

A window function cannot go in `WHERE`. The query has to be wrapped in a CTE or subquery first, which is how top N per group and de-duplication work.

`RANK` leaves gaps after a tie, `DENSE_RANK` does not, and `ROW_NUMBER` never repeats.

`LAST_VALUE` looks wrong by default because the default frame ends at the current row. It needs `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`.

`AVG` ignores `NULL`. The average score was 625 with `NULL` ignored and 500 when `NULL` became 0, so the choice changes the answer.

## Next up

Week 3 will build on these queries with subqueries and CTEs, and use window functions on larger, more realistic datasets.
