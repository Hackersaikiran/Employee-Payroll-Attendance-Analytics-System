-- ================================================
-- SQL Views for Reporting
-- Demonstrates: Complex Joins, Aggregate Functions, Subqueries
-- ================================================

-- ================================================
-- VIEW 1: Monthly Attendance Summary
-- Purpose: Get attendance statistics per employee per month
-- ================================================
CREATE OR REPLACE VIEW view_monthly_attendance_summary AS
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.email,
    d.department_name,
    EXTRACT(YEAR FROM a.attendance_date) AS year,
    EXTRACT(MONTH FROM a.attendance_date) AS month,
    TO_CHAR(TO_DATE(EXTRACT(MONTH FROM a.attendance_date)::TEXT, 'MM'), 'Month') AS month_name,
    COUNT(*) AS total_days,
    COUNT(CASE WHEN a.status = 'Present' THEN 1 END) AS present_days,
    COUNT(CASE WHEN a.status = 'Late' THEN 1 END) AS late_days,
    COUNT(CASE WHEN a.status = 'Absent' THEN 1 END) AS absent_days,
    ROUND(
        (COUNT(CASE WHEN a.status = 'Present' THEN 1 END)::NUMERIC / 
        NULLIF(COUNT(*)::NUMERIC, 0)) * 100, 
        2
    ) AS attendance_percentage
FROM 
    employees e
INNER JOIN 
    attendance a ON e.employee_id = a.employee_id
INNER JOIN 
    departments d ON e.department_id = d.department_id
WHERE 
    e.is_active = TRUE
GROUP BY 
    e.employee_id, 
    e.first_name, 
    e.last_name, 
    e.email,
    d.department_name, 
    EXTRACT(YEAR FROM a.attendance_date), 
    EXTRACT(MONTH FROM a.attendance_date)
ORDER BY 
    year DESC, 
    month DESC, 
    employee_name;

-- ================================================
-- VIEW 2: Monthly Payroll Report
-- Purpose: Complete payroll details with employee and department info
-- ================================================
CREATE OR REPLACE VIEW view_monthly_payroll_report AS
SELECT 
    p.payroll_id,
    p.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.email,
    d.department_name,
    e.designation,
    p.year,
    p.month,
    TO_CHAR(TO_DATE(p.month::TEXT, 'MM'), 'Month') AS month_name,
    p.base_salary,
    p.total_days,
    p.present_days,
    p.late_days,
    p.absent_days,
    p.late_deduction,
    p.absent_deduction,
    p.total_deduction,
    p.net_salary,
    ROUND(
        (p.present_days::NUMERIC / NULLIF(p.total_days::NUMERIC, 0)) * 100, 
        2
    ) AS attendance_percentage,
    p.generated_at
FROM 
    payroll p
INNER JOIN 
    employees e ON p.employee_id = e.employee_id
INNER JOIN 
    departments d ON e.department_id = d.department_id
ORDER BY 
    p.year DESC, 
    p.month DESC, 
    employee_name;

-- ================================================
-- VIEW 3: Department-wise Payroll Summary
-- Purpose: Aggregate payroll data by department
-- ================================================
CREATE OR REPLACE VIEW view_department_payroll_summary AS
SELECT 
    d.department_id,
    d.department_name,
    p.year,
    p.month,
    TO_CHAR(TO_DATE(p.month::TEXT, 'MM'), 'Month') AS month_name,
    COUNT(DISTINCT p.employee_id) AS total_employees,
    SUM(p.base_salary) AS total_base_salary,
    SUM(p.total_deduction) AS total_deductions,
    SUM(p.net_salary) AS total_net_salary,
    ROUND(AVG(p.present_days), 2) AS avg_present_days,
    ROUND(AVG(p.late_days), 2) AS avg_late_days,
    ROUND(AVG(p.absent_days), 2) AS avg_absent_days,
    ROUND(
        AVG((p.present_days::NUMERIC / NULLIF(p.total_days::NUMERIC, 0)) * 100), 
        2
    ) AS avg_attendance_percentage
FROM 
    departments d
INNER JOIN 
    employees e ON d.department_id = e.department_id
INNER JOIN 
    payroll p ON e.employee_id = p.employee_id
WHERE 
    e.is_active = TRUE
GROUP BY 
    d.department_id, 
    d.department_name, 
    p.year, 
    p.month
ORDER BY 
    p.year DESC, 
    p.month DESC, 
    d.department_name;

-- ================================================
-- VIEW 4: Employee Details with Latest Attendance
-- Purpose: Quick lookup of employee info with recent attendance
-- ================================================
CREATE OR REPLACE VIEW view_employee_attendance_status AS
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.email,
    e.phone,
    d.department_name,
    e.designation,
    e.base_salary,
    e.date_of_joining,
    e.is_active,
    latest.latest_attendance_date,
    latest.latest_status,
    latest.check_in_time,
    latest.check_out_time,
    -- Subquery to get attendance stats for current month
    (SELECT COUNT(*) 
     FROM attendance a 
     WHERE a.employee_id = e.employee_id 
       AND EXTRACT(MONTH FROM a.attendance_date) = EXTRACT(MONTH FROM CURRENT_DATE)
       AND EXTRACT(YEAR FROM a.attendance_date) = EXTRACT(YEAR FROM CURRENT_DATE)
    ) AS current_month_days,
    (SELECT COUNT(*) 
     FROM attendance a 
     WHERE a.employee_id = e.employee_id 
       AND a.status = 'Present'
       AND EXTRACT(MONTH FROM a.attendance_date) = EXTRACT(MONTH FROM CURRENT_DATE)
       AND EXTRACT(YEAR FROM a.attendance_date) = EXTRACT(YEAR FROM CURRENT_DATE)
    ) AS current_month_present
FROM 
    employees e
INNER JOIN 
    departments d ON e.department_id = d.department_id
LEFT JOIN LATERAL (
    SELECT 
        a.attendance_date AS latest_attendance_date,
        a.status AS latest_status,
        a.check_in_time,
        a.check_out_time
    FROM 
        attendance a
    WHERE 
        a.employee_id = e.employee_id
    ORDER BY 
        a.attendance_date DESC
    LIMIT 1
) latest ON TRUE
ORDER BY 
    e.employee_id;

-- ================================================
-- VIEW 5: Top Performers by Attendance
-- Purpose: Identify employees with best attendance
-- ================================================
CREATE OR REPLACE VIEW view_top_performers_attendance AS
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.department_name,
    e.designation,
    COUNT(CASE WHEN a.status = 'Present' THEN 1 END) AS total_present_days,
    COUNT(CASE WHEN a.status = 'Late' THEN 1 END) AS total_late_days,
    COUNT(CASE WHEN a.status = 'Absent' THEN 1 END) AS total_absent_days,
    ROUND(
        (COUNT(CASE WHEN a.status = 'Present' THEN 1 END)::NUMERIC / 
        NULLIF(COUNT(*)::NUMERIC, 0)) * 100, 
        2
    ) AS overall_attendance_percentage
FROM 
    employees e
INNER JOIN 
    departments d ON e.department_id = d.department_id
INNER JOIN 
    attendance a ON e.employee_id = a.employee_id
WHERE 
    e.is_active = TRUE
GROUP BY 
    e.employee_id, 
    e.first_name, 
    e.last_name, 
    d.department_name,
    e.designation
HAVING 
    COUNT(*) >= 10  -- Minimum 10 days of attendance records
ORDER BY 
    overall_attendance_percentage DESC,
    total_present_days DESC;

-- ================================================
-- VIEW 6: Attendance Defaulters
-- Purpose: Identify employees with poor attendance
-- ================================================
CREATE OR REPLACE VIEW view_attendance_defaulters AS
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.email,
    d.department_name,
    EXTRACT(YEAR FROM a.attendance_date) AS year,
    EXTRACT(MONTH FROM a.attendance_date) AS month,
    COUNT(*) AS total_days,
    COUNT(CASE WHEN a.status = 'Absent' THEN 1 END) AS absent_days,
    COUNT(CASE WHEN a.status = 'Late' THEN 1 END) AS late_days,
    ROUND(
        (COUNT(CASE WHEN a.status IN ('Absent', 'Late') THEN 1 END)::NUMERIC / 
        NULLIF(COUNT(*)::NUMERIC, 0)) * 100, 
        2
    ) AS issue_percentage
FROM 
    employees e
INNER JOIN 
    departments d ON e.department_id = d.department_id
INNER JOIN 
    attendance a ON e.employee_id = a.employee_id
WHERE 
    e.is_active = TRUE
GROUP BY 
    e.employee_id, 
    e.first_name, 
    e.last_name, 
    e.email,
    d.department_name,
    EXTRACT(YEAR FROM a.attendance_date),
    EXTRACT(MONTH FROM a.attendance_date)
HAVING 
    COUNT(CASE WHEN a.status IN ('Absent', 'Late') THEN 1 END) >= 3
ORDER BY 
    issue_percentage DESC,
    absent_days DESC;

-- Display confirmation
SELECT 'All views created successfully!' AS status;
