-- ================================================
-- SQL Triggers for Automated Payroll Deductions
-- Demonstrates: Triggers, BEFORE/AFTER events, Audit trails
-- ================================================

-- ================================================
-- DEDUCTION CONSTANTS
-- Late Day Deduction: ₹200 per late day
-- Absent Day Deduction: ₹500 per absent day
-- ================================================

-- Note: These values are used in the stored procedure.
-- Triggers are used for validation and auditing.

-- ================================================
-- TRIGGER 1: Validate Attendance Before Insert
-- Purpose: Ensure attendance rules are followed
-- ================================================
CREATE OR REPLACE FUNCTION fn_validate_attendance()
RETURNS TRIGGER AS $$
BEGIN
    -- Rule 1: Cannot mark future attendance
    IF NEW.attendance_date > CURRENT_DATE THEN
        RAISE EXCEPTION 'Cannot mark attendance for future dates';
    END IF;
    
    -- Rule 2: If status is 'Absent', check_in and check_out must be NULL
    IF NEW.status = 'Absent' AND (NEW.check_in_time IS NOT NULL OR NEW.check_out_time IS NOT NULL) THEN
        RAISE EXCEPTION 'Absent employees cannot have check-in/check-out times';
    END IF;
    
    -- Rule 3: If status is 'Present' or 'Late', check_in must not be NULL
    IF NEW.status IN ('Present', 'Late') AND NEW.check_in_time IS NULL THEN
        RAISE EXCEPTION 'Present or Late employees must have check-in time';
    END IF;
    
    -- Rule 4: Cannot mark attendance for inactive employees
    IF NOT EXISTS (SELECT 1 FROM employees WHERE employee_id = NEW.employee_id AND is_active = TRUE) THEN
        RAISE EXCEPTION 'Cannot mark attendance for inactive employees';
    END IF;
    
    -- Rule 5: Attendance date must be after employee joining date
    IF NEW.attendance_date < (SELECT date_of_joining FROM employees WHERE employee_id = NEW.employee_id) THEN
        RAISE EXCEPTION 'Attendance date cannot be before employee joining date';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_attendance
BEFORE INSERT OR UPDATE ON attendance
FOR EACH ROW
EXECUTE FUNCTION fn_validate_attendance();

-- ================================================
-- TRIGGER 2: Prevent Duplicate Payroll Generation
-- Purpose: Ensure one payroll record per employee per month
-- ================================================
CREATE OR REPLACE FUNCTION fn_prevent_duplicate_payroll()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if payroll already exists for this employee and month
    IF TG_OP = 'INSERT' THEN
        IF EXISTS (
            SELECT 1 
            FROM payroll 
            WHERE employee_id = NEW.employee_id 
              AND month = NEW.month 
              AND year = NEW.year
        ) THEN
            RAISE EXCEPTION 'Payroll already exists for employee % for %/%', 
                NEW.employee_id, NEW.month, NEW.year;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_duplicate_payroll
BEFORE INSERT ON payroll
FOR EACH ROW
EXECUTE FUNCTION fn_prevent_duplicate_payroll();

-- ================================================
-- TRIGGER 3: Auto-calculate Net Salary
-- Purpose: Automatically calculate net salary before insert/update
-- ================================================
CREATE OR REPLACE FUNCTION fn_calculate_net_salary()
RETURNS TRIGGER AS $$
BEGIN
    -- Calculate total deduction
    NEW.total_deduction := NEW.late_deduction + NEW.absent_deduction;
    
    -- Calculate net salary
    NEW.net_salary := NEW.base_salary - NEW.total_deduction;
    
    -- Ensure net salary is not negative
    IF NEW.net_salary < 0 THEN
        NEW.net_salary := 0;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calculate_net_salary
BEFORE INSERT OR UPDATE ON payroll
FOR EACH ROW
EXECUTE FUNCTION fn_calculate_net_salary();

-- ================================================
-- TRIGGER 4: Update Employee Status on Termination
-- Purpose: Prevent operations on terminated employees
-- ================================================
CREATE OR REPLACE FUNCTION fn_check_employee_status()
RETURNS TRIGGER AS $$
BEGIN
    -- Prevent marking attendance for inactive employees
    IF NOT EXISTS (
        SELECT 1 
        FROM employees 
        WHERE employee_id = NEW.employee_id 
          AND is_active = TRUE
    ) THEN
        RAISE EXCEPTION 'Employee % is inactive. Cannot perform this operation.', NEW.employee_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_employee_status_attendance
BEFORE INSERT OR UPDATE ON attendance
FOR EACH ROW
EXECUTE FUNCTION fn_check_employee_status();

-- ================================================
-- TRIGGER 5: Audit Log for Payroll Changes
-- Purpose: Track all payroll modifications for audit trail
-- ================================================

-- Create audit table first
CREATE TABLE IF NOT EXISTS payroll_audit (
    audit_id SERIAL PRIMARY KEY,
    payroll_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    month INTEGER NOT NULL,
    year INTEGER NOT NULL,
    old_net_salary DECIMAL(10, 2),
    new_net_salary DECIMAL(10, 2),
    old_deduction DECIMAL(10, 2),
    new_deduction DECIMAL(10, 2),
    operation VARCHAR(10) NOT NULL,
    changed_by VARCHAR(100) DEFAULT CURRENT_USER,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION fn_audit_payroll_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO payroll_audit (
            payroll_id, 
            employee_id, 
            month, 
            year,
            old_net_salary, 
            new_net_salary,
            old_deduction,
            new_deduction,
            operation
        ) VALUES (
            NEW.payroll_id,
            NEW.employee_id,
            NEW.month,
            NEW.year,
            OLD.net_salary,
            NEW.net_salary,
            OLD.total_deduction,
            NEW.total_deduction,
            'UPDATE'
        );
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO payroll_audit (
            payroll_id, 
            employee_id, 
            month, 
            year,
            old_net_salary, 
            new_net_salary,
            old_deduction,
            new_deduction,
            operation
        ) VALUES (
            OLD.payroll_id,
            OLD.employee_id,
            OLD.month,
            OLD.year,
            OLD.net_salary,
            NULL,
            OLD.total_deduction,
            NULL,
            'DELETE'
        );
        RETURN OLD;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_payroll_changes
AFTER UPDATE OR DELETE ON payroll
FOR EACH ROW
EXECUTE FUNCTION fn_audit_payroll_changes();

-- ================================================
-- TRIGGER 6: Validate Payroll Data Integrity
-- Purpose: Ensure payroll calculations are within acceptable ranges
-- ================================================
CREATE OR REPLACE FUNCTION fn_validate_payroll_integrity()
RETURNS TRIGGER AS $$
BEGIN
    -- Validate that present days + late days + absent days <= total days
    IF (NEW.present_days + NEW.late_days + NEW.absent_days) > NEW.total_days THEN
        RAISE EXCEPTION 'Sum of attendance days cannot exceed total working days';
    END IF;
    
    -- Validate that deductions don't exceed base salary
    IF (NEW.late_deduction + NEW.absent_deduction) > NEW.base_salary THEN
        RAISE EXCEPTION 'Total deductions cannot exceed base salary';
    END IF;
    
    -- Validate month and year are reasonable
    IF NEW.month < 1 OR NEW.month > 12 THEN
        RAISE EXCEPTION 'Invalid month value';
    END IF;
    
    IF NEW.year < 2020 OR NEW.year > 2100 THEN
        RAISE EXCEPTION 'Invalid year value';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_payroll_integrity
BEFORE INSERT OR UPDATE ON payroll
FOR EACH ROW
EXECUTE FUNCTION fn_validate_payroll_integrity();

-- ================================================
-- Display confirmation
-- ================================================
SELECT 'All triggers created successfully!' AS status;

-- List all triggers
SELECT 
    trigger_name, 
    event_manipulation, 
    event_object_table,
    action_timing,
    action_orientation
FROM 
    information_schema.triggers
WHERE 
    trigger_schema = 'public'
ORDER BY 
    event_object_table, 
    trigger_name;
