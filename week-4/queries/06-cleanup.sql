-- Cleanup | salesdb
-- Removes everything created in week 4 so the database goes back to the original five tables.

-- Drop the views and materialized view
DROP VIEW IF EXISTS sales.v_monthly_summary;
DROP VIEW IF EXISTS sales.v_order_details;
DROP VIEW IF EXISTS sales.v_orders_non_us;
DROP VIEW IF EXISTS sales.v_customer_totals;
DROP VIEW IF EXISTS sales.v_copy_totals;
DROP MATERIALIZED VIEW IF EXISTS sales.mv_monthly_summary;

-- Drop the tables created with CTAS and the copies used for experiments
DROP TABLE IF EXISTS sales.monthly_orders;
DROP TABLE IF EXISTS sales.orders_delivered;
DROP TABLE IF EXISTS sales.orders_empty;
DROP TABLE IF EXISTS sales.ordersarchive_clean;
DROP TABLE IF EXISTS sales.customer_totals_snapshot;
DROP TABLE IF EXISTS sales.copy_totals_snapshot;
DROP TABLE IF EXISTS sales.orders_copy CASCADE;
DROP TABLE IF EXISTS sales.customers_copy;
DROP TABLE IF EXISTS sales.employees_copy CASCADE;
DROP TABLE IF EXISTS sales.employee_logs;
DROP TABLE IF EXISTS sales.monthly_sales_report;

-- Drop the temporary tables (they would also disappear when the session ends)
DROP TABLE IF EXISTS tmp_delivered;
DROP TABLE IF EXISTS tmp_customer_totals;
DROP TABLE IF EXISTS tmp_archive_clean;

-- Drop the functions and procedures
DROP FUNCTION IF EXISTS sales.get_customer_summary(text);
DROP PROCEDURE IF EXISTS sales.print_customer_summary(text);
DROP PROCEDURE IF EXISTS sales.customer_stats(text, bigint, numeric);
DROP PROCEDURE IF EXISTS sales.fix_null_scores();
DROP PROCEDURE IF EXISTS sales.show_unit_price(int);
DROP PROCEDURE IF EXISTS sales.refresh_monthly_sales_report();

-- Drop the trigger functions
DROP FUNCTION IF EXISTS sales.trg_log_new_employee();
DROP FUNCTION IF EXISTS sales.trg_audit_employee();
DROP FUNCTION IF EXISTS sales.trg_validate_employee();

-- Confirm only the original five tables remain in the sales schema
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'sales'
ORDER BY table_name;
