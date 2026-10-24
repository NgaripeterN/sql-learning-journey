# Week 4 Notes

## Saving queries and results

| Object | Stores data? | Lives for | Stays up to date? |
|---|---|---|---|
| Subquery | No | One query | Yes |
| CTE | No | One query | Yes |
| View | No, stores the query | Until dropped | Yes, runs every time |
| Materialized view | Yes | Until dropped | No, needs `REFRESH MATERIALIZED VIEW` |
| CTAS table | Yes | Until dropped | No, a snapshot |
| Temp table | Yes | The session (or transaction) | No, a snapshot |

| Use it when | Pick |
|---|---|
| The logic is used once | Subquery or CTE |
| The logic is reused by many queries and must be current | View |
| The query is slow and slightly old data is fine | Materialized view or CTAS |
| An intermediate result is needed for several steps in one session | Temp table |

## Views, CTAS and temp tables

| Task | Syntax |
|---|---|
| Create or change a view | `CREATE OR REPLACE VIEW name AS ...` |
| Remove a view | `DROP VIEW IF EXISTS name` |
| Materialized view | `CREATE MATERIALIZED VIEW name AS ...` then `REFRESH MATERIALIZED VIEW name` |
| Copy a query result into a table | `CREATE TABLE name AS SELECT ...` |
| Copy only the structure | `CREATE TABLE name AS SELECT ... WITH NO DATA` |
| Temp table | `CREATE TEMP TABLE name AS SELECT ...` |
| Temp table that drops at commit | `CREATE TEMP TABLE name ON COMMIT DROP AS ...` |

## Stored procedures and functions

| | Function | Procedure |
|---|---|---|
| Run with | `SELECT fn()` or `FROM fn()` | `CALL proc()` |
| Returns rows | Yes (`RETURNS TABLE`) | No, only `INOUT` values |
| Controls transactions | No | Yes (`COMMIT`, `ROLLBACK`) |
| Use it for | Calculations and result sets | Actions that change data |

| Piece | PL/pgSQL |
|---|---|
| Variables | `DECLARE v_total int;` |
| Store a query result | `SELECT ... INTO v_total` |
| Print a message | `RAISE NOTICE 'text %', value` |
| Condition | `IF ... THEN ... ELSE ... END IF;` |
| Handle errors | `EXCEPTION WHEN division_by_zero THEN ...` |
| Rows affected | `GET DIAGNOSTICS v_rows = ROW_COUNT` |

## Triggers

| Part | Purpose |
|---|---|
| Trigger function | Holds the logic and returns `trigger` |
| `CREATE TRIGGER` | Attaches the function to a table and an event |
| `BEFORE` | Runs before the row is saved, can change or reject it |
| `AFTER` | Runs after the row is saved, good for logging |
| `NEW` | The row being inserted or updated |
| `OLD` | The row being updated or deleted |
| `TG_OP` | Which event fired: `INSERT`, `UPDATE` or `DELETE` |

## SQL Server vs PostgreSQL

| Task | SQL Server | PostgreSQL |
|---|---|---|
| Copy a query into a new table | `SELECT ... INTO new_table` | `CREATE TABLE new_table AS SELECT ...` |
| Temp table | `#temp` | `CREATE TEMP TABLE temp` |
| Change a view | `ALTER VIEW` | `CREATE OR REPLACE VIEW` |
| Run a procedure | `EXEC proc` | `CALL proc()` |
| Return rows from reusable code | Procedure ending in `SELECT` | Function with `RETURNS TABLE` |
| Print a message | `PRINT` | `RAISE NOTICE` |
| Error handling | `TRY ... CATCH` | `EXCEPTION WHEN ... THEN` |
| Trigger | One `CREATE TRIGGER` with the logic inside | Trigger function plus `CREATE TRIGGER` |
| Changed rows in a trigger | `inserted` and `deleted` tables | `NEW` and `OLD` row variables |
| Trigger timing | `AFTER` and `INSTEAD OF` | `BEFORE`, `AFTER` and `INSTEAD OF` (views) |
| Per row or per statement | Per statement | `FOR EACH ROW` or `FOR EACH STATEMENT` |

## What I found tricky

`CREATE OR REPLACE VIEW` can add columns at the end, but it can't remove or reorder them. Re-running a script that creates the short version of a view after the longer version failed with "cannot drop columns from view", so the script drops the view first.

CTAS copies the data but not the primary key, so it has to be added afterwards with `ALTER TABLE ... ADD PRIMARY KEY`.

A view always shows current data, a CTAS table doesn't. After adding one order to the copy, the view counted 11 orders and the snapshot still counted 10.

A temp table is only visible in the session that created it. In DBeaver the SQL editor needs to keep the same connection, otherwise the table seems to vanish.

A PostgreSQL procedure can't return a result set. The summary query had to be a function to show its rows, while the procedure versions print notices or return `INOUT` values.

A trigger needs two statements, the function first and then `CREATE TRIGGER`. Dropping the table with `CASCADE` removes the trigger but not the function.

A `BEFORE` trigger can change the row before it is saved, which is how the messy department `'  fINANCE '` was saved as `Finance`. An error raised in it cancels the insert.

Triggers fire silently, so a table can change in ways the `INSERT` or `UPDATE` statement doesn't show. The audit log was the only place the salary change appeared.

## Next up

Not decided yet.
