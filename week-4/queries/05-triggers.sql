-- Triggers | salesdb
-- In PostgreSQL a trigger has two parts: a trigger function that holds the logic, and a CREATE TRIGGER that attaches it to a table.
-- Inside the function, NEW is the row being inserted or updated and OLD is the row being updated or deleted.

-- Make a copy of employees to attach triggers to, so the real table stays untouched
DROP TABLE IF EXISTS sales.employees_copy CASCADE;
CREATE TABLE sales.employees_copy AS
SELECT * FROM sales.employees;
ALTER TABLE sales.employees_copy ADD PRIMARY KEY (employeeid);

-- A log table that the triggers will write to
DROP TABLE IF EXISTS sales.employee_logs;
CREATE TABLE sales.employee_logs (
    logid int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employeeid int,
    logmessage text,
    logdate timestamp DEFAULT NOW()
);

-- Trigger function: record a log row whenever a new employee is added
CREATE OR REPLACE FUNCTION sales.trg_log_new_employee()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO sales.employee_logs (employeeid, logmessage)
    VALUES (NEW.employeeid, 'New employee added: ' || NEW.firstname);
    RETURN NEW;
END;
$$;

-- Attach the function so it runs after every insert on the employee copy
DROP TRIGGER IF EXISTS trg_after_insert_employee ON sales.employees_copy;
CREATE TRIGGER trg_after_insert_employee
AFTER INSERT ON sales.employees_copy
FOR EACH ROW
EXECUTE FUNCTION sales.trg_log_new_employee();

-- Fire the trigger by adding a new employee
INSERT INTO sales.employees_copy (employeeid, firstname, lastname, department, birthdate, gender, salary, managerid)
VALUES (6, 'Maria', 'Doe', 'HR', '1988-01-12', 'F', 80000, 3);

-- The log now has a row for the new employee, written by the trigger
SELECT * FROM sales.employee_logs ORDER BY logid;

-- Replace it with a single trigger that logs inserts, updates and deletes (TG_OP tells us which happened)
CREATE OR REPLACE FUNCTION sales.trg_audit_employee()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO sales.employee_logs (employeeid, logmessage)
        VALUES (NEW.employeeid, 'Added ' || NEW.firstname);
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO sales.employee_logs (employeeid, logmessage)
        VALUES (NEW.employeeid, format('Salary changed from %s to %s', OLD.salary, NEW.salary));
        RETURN NEW;
    ELSE
        INSERT INTO sales.employee_logs (employeeid, logmessage)
        VALUES (OLD.employeeid, 'Deleted ' || OLD.firstname);
        RETURN OLD;
    END IF;
END;
$$;

-- Swap the insert-only trigger for the audit trigger
DROP TRIGGER IF EXISTS trg_after_insert_employee ON sales.employees_copy;
DROP TRIGGER IF EXISTS trg_audit_employee ON sales.employees_copy;
CREATE TRIGGER trg_audit_employee
AFTER INSERT OR UPDATE OR DELETE ON sales.employees_copy
FOR EACH ROW
EXECUTE FUNCTION sales.trg_audit_employee();

-- Give employee 6 a raise: the trigger logs the old and new salary
UPDATE sales.employees_copy SET salary = 85000 WHERE employeeid = 6;

-- Remove employee 6: the trigger logs the deletion
DELETE FROM sales.employees_copy WHERE employeeid = 6;

-- Read the full audit log, oldest first
SELECT logid, employeeid, logmessage FROM sales.employee_logs ORDER BY logid;

-- Trigger function that blocks bad data and tidies the department name before a row is saved
CREATE OR REPLACE FUNCTION sales.trg_validate_employee()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.salary < 0 THEN
        RAISE EXCEPTION 'Salary cannot be negative (got %)', NEW.salary;
    END IF;
    NEW.department := INITCAP(TRIM(NEW.department));
    RETURN NEW;
END;
$$;

-- Attach the validation function so it runs before every insert or update
DROP TRIGGER IF EXISTS trg_before_employee ON sales.employees_copy;
CREATE TRIGGER trg_before_employee
BEFORE INSERT OR UPDATE ON sales.employees_copy
FOR EACH ROW
EXECUTE FUNCTION sales.trg_validate_employee();

-- Add an employee with a messy department name: the trigger tidies it to 'Finance'
INSERT INTO sales.employees_copy (employeeid, firstname, lastname, department, birthdate, gender, salary, managerid)
VALUES (7, 'Sam', 'Okoye', '  fINANCE ', '1990-05-20', 'M', 60000, 1);

-- Check the department that was actually saved
SELECT employeeid, firstname, department FROM sales.employees_copy WHERE employeeid = 7;

-- Try to add an employee with a negative salary: the trigger rejects it and the error is caught and printed
DO $$
BEGIN
    INSERT INTO sales.employees_copy (employeeid, firstname, lastname, department, birthdate, gender, salary, managerid)
    VALUES (8, 'Bad', 'Data', 'Sales', '1990-01-01', 'M', -500, 1);
EXCEPTION
    WHEN raise_exception THEN
        RAISE NOTICE 'Rejected: %', SQLERRM;
END;
$$;

-- Confirm the rejected employee was not saved
SELECT COUNT(*) AS employee_8_rows FROM sales.employees_copy WHERE employeeid = 8;

-- List the triggers on the employee copy
SELECT trigger_name, event_manipulation, action_timing
FROM information_schema.triggers
WHERE event_object_schema = 'sales' AND event_object_table = 'employees_copy'
ORDER BY trigger_name, event_manipulation;
