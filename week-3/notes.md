# Week 3 Notes

## Window function reference

| Type | Functions | What it does |
|---|---|---|
| Aggregate | `SUM`, `AVG`, `COUNT`, `MIN`, `MAX` | Calculates across a window and keeps every row |
| Ranking | `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `NTILE`, `CUME_DIST`, `PERCENT_RANK` | Gives each row a position within its window |
| Value | `LAG`, `LEAD`, `FIRST_VALUE`, `LAST_VALUE` | Pulls a value from another row in the window |

| Part of `OVER (...)` | Purpose |
|---|---|
| `PARTITION BY` | Splits rows into separate windows (optional) |
| `ORDER BY` | Sorts rows inside each window (required for ranking and value functions) |
| Frame (`ROWS` or `RANGE`) | Limits which rows in the window are used, such as a rolling 3 rows |

## GROUP BY vs window functions

| | `GROUP BY` | Window function |
|---|---|---|
| Rows returned | One row per group | Every row is kept |
| Level | Group-level calculation | Row-level calculation |
| Use it for | Summaries and totals | Running totals, ranks, comparisons next to each row |

## Ranking functions on ties

| Function | Behaviour on a tie |
|---|---|
| `ROW_NUMBER` | Never repeats, ties get different numbers |
| `RANK` | Ties share a rank and the next rank is skipped |
| `DENSE_RANK` | Ties share a rank and no rank is skipped |

## Subqueries

| Where it sits | What it must return |
|---|---|
| `FROM` | A table of rows (needs an alias) |
| `SELECT` | One value (scalar) |
| `WHERE` with `=`, `>`, `<` | One value (scalar) |
| `WHERE` with `IN`, `ANY`, `ALL` | A list of values |
| `WHERE` with `EXISTS` | Whether any row comes back |

A correlated subquery depends on the outer query and runs again for each row.
A non-correlated subquery runs once.

## CTE types

| Type | Purpose |
|---|---|
| Standalone | One named query used by the main query |
| Multiple | Several CTEs in one `WITH`, joined together |
| Nested | A CTE that builds on an earlier CTE |
| Recursive | A CTE that references itself, with an anchor query, a recursive query and a break condition |

## SQL Server vs PostgreSQL

| Task | SQL Server | PostgreSQL |
|---|---|---|
| Recursive CTE | `WITH cte AS (...)` | `WITH RECURSIVE cte AS (...)` |
| Recursion limit | Stops at 100 levels by default | No default limit, so the break condition matters |
| Generate a series | Recursive CTE or a numbers table | `GENERATE_SERIES(start, stop, step)` |
| Add a day to a date | `DATEADD(day, 1, d)` | `d + 1` or `d + INTERVAL '1 day'` |
| Cast in a recursive anchor | `CAST(x AS VARCHAR(100))` | `x::text` |

## What I found tricky

A window function can't be used in `WHERE`. The ranking has to be calculated in a CTE or subquery first, and then filtered in the outer query.

`GROUP BY` collapses rows, while a window function keeps every row and adds the calculation alongside. That makes it possible to show a total or a percentage of total next to each order.

`RANK` leaves gaps after a tie, `DENSE_RANK` does not, and `ROW_NUMBER` never repeats.

`ORDER BY` inside `OVER` changes the frame. With ties in the sort column, the default frame includes all the tied rows together, so two orders with the same sales showed the same running total. An explicit `ROWS` frame counts one row at a time.

`LAST_VALUE` looks wrong by default because the default frame ends at the current row. It needs `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`.

`NOT IN` fails silently when the subquery contains a `NULL`. Finding employees who are not managers returned no rows because Frank's `managerid` is `NULL`. `NOT EXISTS`, or filtering the `NULL` out, avoids it.

A correlated subquery runs once per row of the outer query, so it can be slow on large tables. A join or a window function often does the same job faster.

A CTE only exists for the one query that follows it. It is not saved in the database, unlike a view.

A recursive CTE needs a break condition. Without `WHERE n < 10`, the number series would never stop in PostgreSQL.

## Next up

Week 4 will start with views and CTAS, which save query results as reusable database objects and tables.
