-- ================================================
-- Stored Procedures for Business Logic
-- Demonstrates: Procedures, Functions, Complex Logic in SQL
-- ================================================

-- ================================================
-- CONFIGURATION: Deduction Rates
-- ================================================
-- Late Day Deduction: ₹200 per late day
-- Absent Day Deduction: ₹500 per absent day
-- ================================================

-- ================================================
-- PROCEDURE 1: Generate Monthly Payroll
-- Purpose: Generate payroll for all active employees for a given month
-- Core Business Logic - Calculates deductions based on attendance
-- ================================================
CREATE OR REPLACE PROCEDURE sp_generate_monthly_payroll(
    p_month INTEGER,
    p_year INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_employee_record RECORD;
    v_total_days INTEGER;
    v_present_days INTEGER;
    v_late_days INTEGER;
    v_absent_days INTEGER;
    v_late_deduction DECIMAL(10, 2);
    v_absent_deduction DECIMAL(10, 2);
    v_total_deduction DECIMAL(10, 2);
    v_net_salary DECIMAL(10, 2);
    v_employees_processed INTEGER := 0;
    
    -- Deduction constants
    c_late_deduction_rate CONSTANT DECIMAL(10, 2) := 200.00;
    c_absent_deduction_rate CONSTANT DECIMAL(10, 2) := 500.00;
BEGIN
    -- Validate input parameters
    IF p_month < 1 OR p_month > 12 THEN
        RAISE EXCEPTION 'Invalid month. Must be between 1 and 12.';
    END IF;
    
    IF p_year < 2020 OR p_year > 2100 THEN
        RAISE EXCEPTION 'Invalid year. Must be between 2020 and 2100.';
    END IF;
    
    -- Check if future month
    IF (p_year > EXTRACT(YEAR FROM CURRENT_DATE)) OR 
       (p_year = EXTRACT(YEAR FROM CURRENT_DATE) AND p_month > EXTRACT(MONTH FROM CURRENT_DATE)) THEN
        RAISE EXCEPTION 'Cannot generate payroll for future months';
    END IF;
    
    RAISE NOTICE 'Starting payroll generation for %/%...', p_month, p_year;
    
    -- Loop through all active employees
    FOR v_employee_record IN 
        SELECT 
            e.employee_id,
            e.first_name,
            e.last_name,
            e.base_salary
        FROM 
            employees e
        WHERE 
            e.is_active = TRUE
            -- Employee must have joined before or during the payroll month
            AND DATE_TRUNC('month', e.date_of_joining) <= 
                MAKE_DATE(p_year, p_month, 1)
    LOOP
        -- Check if payroll already exists for this employee
        IF EXISTS (
            SELECT 1 
            FROM payroll 
            WHERE employee_id = v_employee_record.employee_id 
              AND month = p_month 
              AND year = p_year
        ) THEN
            RAISE NOTICE 'Payroll already exists for employee % (% %). Skipping...', 
                v_employee_record.employee_id,
                v_employee_record.first_name,
                v_employee_record.last_name;
            CONTINUE;
        END IF;
        
        -- Calculate attendance statistics for the month
        SELECT 
            COUNT(*) AS total_days,
            COUNT(CASE WHEN status = 'Present' THEN 1 END) AS present_days,
            COUNT(CASE WHEN status = 'Late' THEN 1 END) AS late_days,
            COUNT(CASE WHEN status = 'Absent' THEN 1 END) AS absent_days
        INTO 
            v_total_days,
            v_present_days,
            v_late_days,
            v_absent_days
        FROM 
            attendance
        WHERE 
            employee_id = v_employee_record.employee_id
            AND EXTRACT(MONTH FROM attendance_date) = p_month
            AND EXTRACT(YEAR FROM attendance_date) = p_year;
        
        -- If no attendance records exist, set to 0
        v_total_days := COALESCE(v_total_days, 0);
        v_present_days := COALESCE(v_present_days, 0);
        v_late_days := COALESCE(v_late_days, 0);
        v_absent_days := COALESCE(v_absent_days, 0);
        
        -- Calculate deductions
        v_late_deduction := v_late_days * c_late_deduction_rate;
        v_absent_deduction := v_absent_days * c_absent_deduction_rate;
        v_total_deduction := v_late_deduction + v_absent_deduction;
        
        -- Ensure deductions don't exceed base salary
        IF v_total_deduction > v_employee_record.base_salary THEN
            v_total_deduction := v_employee_record.base_salary;
        END IF;
        
        -- Calculate net salary
        v_net_salary := v_employee_record.base_salary - v_total_deduction;
        
        -- Insert payroll record
        INSERT INTO payroll (
            employee_id,
            month,
            year,
            base_salary,
            total_days,
            present_days,
            late_days,
            absent_days,
            late_deduction,
            absent_deduction,
            total_deduction,
            net_salary
        ) VALUES (
            v_employee_record.employee_id,
            p_month,
            p_year,
            v_employee_record.base_salary,
            v_total_days,
            v_present_days,
            v_late_days,
            v_absent_days,
            v_late_deduction,
            v_absent_deduction,
            v_total_deduction,
            v_net_salary
        );
        
        v_employees_processed := v_employees_processed + 1;
        
        RAISE NOTICE 'Processed: % % (ID: %) - Net Salary: ₹%', 
            v_employee_record.first_name,
            v_employee_record.last_name,
            v_employee_record.employee_id,
            v_net_salary;
    END LOOP;
    
    RAISE NOTICE 'Payroll generation completed. Total employees processed: %', v_employees_processed;
    
    -- Return summary
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Payroll Summary for %/%', p_month, p_year;
    RAISE NOTICE 'Total Employees: %', v_employees_processed;
    RAISE NOTICE '========================================';
    
END;
$$;

-- ================================================
-- PROCEDURE 2: Generate Payroll for Single Employee
-- Purpose: Generate payroll for a specific employee for a given month
-- ================================================
CREATE OR REPLACE PROCEDURE sp_generate_employee_payroll(
    p_employee_id INTEGER,
    p_month INTEGER,
    p_year INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_base_salary DECIMAL(10, 2);
    v_total_days INTEGER;
    v_present_days INTEGER;
    v_late_days INTEGER;
    v_absent_days INTEGER;
    v_late_deduction DECIMAL(10, 2);
    v_absent_deduction DECIMAL(10, 2);
    v_total_deduction DECIMAL(10, 2);
    v_net_salary DECIMAL(10, 2);
    
    -- Deduction constants
    c_late_deduction_rate CONSTANT DECIMAL(10, 2) := 200.00;
    c_absent_deduction_rate CONSTANT DECIMAL(10, 2) := 500.00;
BEGIN
    -- Check if employee exists and is active
    SELECT base_salary INTO v_base_salary
    FROM employees
    WHERE employee_id = p_employee_id AND is_active = TRUE;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Employee % not found or is inactive', p_employee_id;
    END IF;
    
    -- Check if payroll already exists
    IF EXISTS (
        SELECT 1 FROM payroll 
        WHERE employee_id = p_employee_id 
          AND month = p_month 
          AND year = p_year
    ) THEN
        RAISE EXCEPTION 'Payroll already exists for employee % for %/%', 
            p_employee_id, p_month, p_year;
    END IF;
    
    -- Calculate attendance statistics
    SELECT 
        COUNT(*),
        COUNT(CASE WHEN status = 'Present' THEN 1 END),
        COUNT(CASE WHEN status = 'Late' THEN 1 END),
        COUNT(CASE WHEN status = 'Absent' THEN 1 END)
    INTO 
        v_total_days, v_present_days, v_late_days, v_absent_days
    FROM 
        attendance
    WHERE 
        employee_id = p_employee_id
        AND EXTRACT(MONTH FROM attendance_date) = p_month
        AND EXTRACT(YEAR FROM attendance_date) = p_year;
    
    -- Calculate deductions
    v_late_deduction := COALESCE(v_late_days, 0) * c_late_deduction_rate;
    v_absent_deduction := COALESCE(v_absent_days, 0) * c_absent_deduction_rate;
    v_total_deduction := v_late_deduction + v_absent_deduction;
    
    -- Calculate net salary
    v_net_salary := v_base_salary - v_total_deduction;
    IF v_net_salary < 0 THEN v_net_salary := 0; END IF;
    
    -- Insert payroll record
    INSERT INTO payroll (
        employee_id, month, year, base_salary, total_days,
        present_days, late_days, absent_days,
        late_deduction, absent_deduction, total_deduction, net_salary
    ) VALUES (
        p_employee_id, p_month, p_year, v_base_salary, COALESCE(v_total_days, 0),
        COALESCE(v_present_days, 0), COALESCE(v_late_days, 0), COALESCE(v_absent_days, 0),
        v_late_deduction, v_absent_deduction, v_total_deduction, v_net_salary
    );
    
    RAISE NOTICE 'Payroll generated successfully for employee %', p_employee_id;
END;
$$;

-- ================================================
-- FUNCTION 1: Calculate Expected Salary
-- Purpose: Calculate what an employee's salary would be based on current attendance
-- (Without inserting into payroll table)
-- ================================================
CREATE OR REPLACE FUNCTION fn_calculate_expected_salary(
    p_employee_id INTEGER,
    p_month INTEGER,
    p_year INTEGER
)
RETURNS TABLE (
    employee_id INTEGER,
    employee_name TEXT,
    base_salary DECIMAL(10, 2),
    present_days BIGINT,
    late_days BIGINT,
    absent_days BIGINT,
    late_deduction DECIMAL(10, 2),
    absent_deduction DECIMAL(10, 2),
    total_deduction DECIMAL(10, 2),
    expected_net_salary DECIMAL(10, 2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    c_late_deduction_rate CONSTANT DECIMAL(10, 2) := 200.00;
    c_absent_deduction_rate CONSTANT DECIMAL(10, 2) := 500.00;
BEGIN
    RETURN QUERY
    SELECT 
        e.employee_id,
        CONCAT(e.first_name, ' ', e.last_name)::TEXT AS employee_name,
        e.base_salary,
        COUNT(CASE WHEN a.status = 'Present' THEN 1 END) AS present_days,
        COUNT(CASE WHEN a.status = 'Late' THEN 1 END) AS late_days,
        COUNT(CASE WHEN a.status = 'Absent' THEN 1 END) AS absent_days,
        (COUNT(CASE WHEN a.status = 'Late' THEN 1 END) * c_late_deduction_rate) AS late_deduction,
        (COUNT(CASE WHEN a.status = 'Absent' THEN 1 END) * c_absent_deduction_rate) AS absent_deduction,
        (COUNT(CASE WHEN a.status = 'Late' THEN 1 END) * c_late_deduction_rate + 
         COUNT(CASE WHEN a.status = 'Absent' THEN 1 END) * c_absent_deduction_rate) AS total_deduction,
        (e.base_salary - 
         (COUNT(CASE WHEN a.status = 'Late' THEN 1 END) * c_late_deduction_rate + 
          COUNT(CASE WHEN a.status = 'Absent' THEN 1 END) * c_absent_deduction_rate)) AS expected_net_salary
    FROM 
        employees e
    LEFT JOIN 
        attendance a ON e.employee_id = a.employee_id 
        AND EXTRACT(MONTH FROM a.attendance_date) = p_month
        AND EXTRACT(YEAR FROM a.attendance_date) = p_year
    WHERE 
        e.employee_id = p_employee_id
        AND e.is_active = TRUE
    GROUP BY 
        e.employee_id, e.first_name, e.last_name, e.base_salary;
END;
$$;

-- ================================================
-- FUNCTION 2: Get Department Payroll Summary
-- Purpose: Get aggregated payroll data for a department
-- ================================================
CREATE OR REPLACE FUNCTION fn_get_department_payroll_summary(
    p_department_id INTEGER,
    p_month INTEGER,
    p_year INTEGER
)
RETURNS TABLE (
    department_name VARCHAR(100),
    total_employees BIGINT,
    total_base_salary DECIMAL(10, 2),
    total_deductions DECIMAL(10, 2),
    total_net_salary DECIMAL(10, 2),
    avg_attendance_percentage NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.department_name,
        COUNT(DISTINCT p.employee_id) AS total_employees,
        SUM(p.base_salary)::DECIMAL(10, 2) AS total_base_salary,
        SUM(p.total_deduction)::DECIMAL(10, 2) AS total_deductions,
        SUM(p.net_salary)::DECIMAL(10, 2) AS total_net_salary,
        ROUND(AVG(
            (p.present_days::NUMERIC / NULLIF(p.total_days::NUMERIC, 0)) * 100
        ), 2) AS avg_attendance_percentage
    FROM 
        departments d
    INNER JOIN 
        employees e ON d.department_id = e.department_id
    INNER JOIN 
        payroll p ON e.employee_id = p.employee_id
    WHERE 
        d.department_id = p_department_id
        AND p.month = p_month
        AND p.year = p_year
    GROUP BY 
        d.department_name;
END;
$$;

-- ================================================
-- FUNCTION 3: Delete Payroll for a Month (Rollback)
-- Purpose: Delete payroll records for a specific month (for corrections)
-- ================================================
CREATE OR REPLACE FUNCTION fn_delete_monthly_payroll(
    p_month INTEGER,
    p_year INTEGER
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_deleted_count INTEGER;
BEGIN
    DELETE FROM payroll
    WHERE month = p_month AND year = p_year;
    
    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
    
    RAISE NOTICE 'Deleted % payroll records for %/%', v_deleted_count, p_month, p_year;
    
    RETURN v_deleted_count;
END;
$$;

-- ================================================
-- Display confirmation
-- ================================================
SELECT 'All stored procedures and functions created successfully!' AS status;

-- List all procedures and functions
SELECT 
    routine_name,
    routine_type,
    data_type AS return_type
FROM 
    information_schema.routines
WHERE 
    routine_schema = 'public'
    AND routine_name LIKE 'sp_%' OR routine_name LIKE 'fn_%'
ORDER BY 
    routine_type,
    routine_name;
