# Week 1 Notes

## Clause reference

| Clause | Purpose |
|---|---|
| `SELECT` | Choose which columns appear in the result |
| `DISTINCT` | Remove duplicate rows from the result |
| `FROM` | The table to read from |
| `WHERE` | Filter rows before grouping |
| `GROUP BY` | Group rows so aggregate functions run per group |
| `HAVING` | Filter groups after aggregation |
| `ORDER BY` | Sort the final result |
| `LIMIT` | Cap the number of rows returned |

## DDL vs DML

- DDL is for structure: CREATE, ALTER, DROP.
- DML is for data: INSERT, UPDATE, DELETE.
- I practiced both on a simple throwaway table so I could test ideas without affecting the main dataset.

## What I found tricky

`TOP` is not universal. PostgreSQL and Dune both use `LIMIT`.

`WHERE` and `HAVING` happen at different stages. `WHERE` filters rows before grouping, while `HAVING` filters the grouped result after aggregation.

`DISTINCT` is not the same as `GROUP BY`. `DISTINCT` removes duplicate rows. `GROUP BY` is used when I want to calculate something like a count or total per category.

The order of writing a query is not the same as the order it runs. SQL usually reads from `FROM`, applies `WHERE`, then `GROUP BY`, then `HAVING`, then `SELECT`, and finally `ORDER BY`.

Dune is query-only. I can read and analyse public blockchain data there, but I cannot create or edit the database in the same way I can in PostgreSQL.

Onchain data also needs careful handling. Transaction values are often stored in raw units, and large datasets need time filters so the query stays focused.

## Next up

Week 2 will focus on joins and subqueries, using a richer dataset so the queries can answer more layered questions.
