-- ================================================
-- SQL Query Reference & Examples
-- Useful queries for testing and demonstration
-- ================================================

-- ================================================
-- 1. BASIC QUERIES
-- ================================================

-- View all employees with their departments
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.email,
    d.department_name,
    e.designation,
    e.base_salary
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id
WHERE e.is_active = TRUE
ORDER BY e.employee_id;

-- View all attendance for a specific employee
SELECT 
    attendance_date,
    status,
    check_in_time,
    check_out_time,
    remarks
FROM attendance
WHERE employee_id = 1
ORDER BY attendance_date DESC;

-- ================================================
-- 2. AGGREGATE QUERIES
-- ================================================

-- Department-wise employee count
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS employee_count,
    AVG(e.base_salary) AS avg_salary,
    MIN(e.base_salary) AS min_salary,
    MAX(e.base_salary) AS max_salary
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id AND e.is_active = TRUE
GROUP BY d.department_name
ORDER BY employee_count DESC;

-- Monthly attendance statistics
SELECT 
    EXTRACT(YEAR FROM attendance_date) AS year,
    EXTRACT(MONTH FROM attendance_date) AS month,
    COUNT(*) AS total_records,
    COUNT(CASE WHEN status = 'Present' THEN 1 END) AS present_count,
    COUNT(CASE WHEN status = 'Late' THEN 1 END) AS late_count,
    COUNT(CASE WHEN status = 'Absent' THEN 1 END) AS absent_count,
    ROUND(
        (COUNT(CASE WHEN status = 'Present' THEN 1 END)::NUMERIC / COUNT(*)::NUMERIC) * 100, 
        2
    ) AS present_percentage
FROM attendance
GROUP BY year, month
ORDER BY year DESC, month DESC;

-- ================================================
-- 3. SUBQUERIES
-- ================================================

-- Employees with above-average salary
SELECT 
    employee_id,
    CONCAT(first_name, ' ', last_name) AS name,
    base_salary,
    (SELECT AVG(base_salary) FROM employees) AS avg_salary
FROM employees
WHERE base_salary > (SELECT AVG(base_salary) FROM employees)
ORDER BY base_salary DESC;

-- Employees with perfect attendance in January 2026
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS name,
    d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id
WHERE e.employee_id NOT IN (
    SELECT employee_id 
    FROM attendance 
    WHERE EXTRACT(MONTH FROM attendance_date) = 1 
      AND EXTRACT(YEAR FROM attendance_date) = 2026
      AND status IN ('Late', 'Absent')
)
AND e.is_active = TRUE;

-- ================================================
-- 4. WINDOW FUNCTIONS
-- ================================================

-- Rank employees by salary within each department
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS name,
    d.department_name,
    e.base_salary,
    RANK() OVER (PARTITION BY d.department_id ORDER BY e.base_salary DESC) AS salary_rank
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id
WHERE e.is_active = TRUE;

-- Running total of payroll by month
SELECT 
    year,
    month,
    SUM(net_salary) AS monthly_total,
    SUM(SUM(net_salary)) OVER (ORDER BY year, month) AS running_total
FROM payroll
GROUP BY year, month
ORDER BY year, month;

-- ================================================
-- 5. USING VIEWS
-- ================================================

-- Monthly attendance summary for January 2026
SELECT * FROM view_monthly_attendance_summary
WHERE month = 1 AND year = 2026
ORDER BY attendance_percentage DESC;

-- Monthly payroll report
SELECT * FROM view_monthly_payroll_report
WHERE month = 1 AND year = 2026
ORDER BY net_salary DESC;

-- Department payroll summary
SELECT * FROM view_department_payroll_summary
WHERE month = 1 AND year = 2026;

-- Top performers
SELECT * FROM view_top_performers_attendance
LIMIT 10;

-- Attendance defaulters
SELECT * FROM view_attendance_defaulters
ORDER BY issue_percentage DESC;

-- ================================================
-- 6. CALLING STORED PROCEDURES
-- ================================================

-- Generate payroll for January 2026
CALL sp_generate_monthly_payroll(1, 2026);

-- Generate payroll for a specific employee
CALL sp_generate_employee_payroll(3, 1, 2026);

-- ================================================
-- 7. CALLING FUNCTIONS
-- ================================================

-- Calculate expected salary for employee 3
SELECT * FROM fn_calculate_expected_salary(3, 1, 2026);

-- Get department payroll summary
SELECT * FROM fn_get_department_payroll_summary(2, 1, 2026);

-- Delete payroll for a month (use with caution)
-- SELECT fn_delete_monthly_payroll(1, 2026);

-- ================================================
-- 8. ADVANCED JOINS
-- ================================================

-- Get employees with their attendance and payroll info
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS name,
    d.department_name,
    COUNT(DISTINCT a.attendance_id) AS total_attendance,
    COUNT(DISTINCT p.payroll_id) AS payroll_records,
    SUM(p.net_salary) AS total_earnings
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id
LEFT JOIN attendance a ON e.employee_id = a.employee_id
LEFT JOIN payroll p ON e.employee_id = p.employee_id
WHERE e.is_active = TRUE
GROUP BY e.employee_id, e.first_name, e.last_name, d.department_name
ORDER BY total_earnings DESC NULLS LAST;

-- ================================================
-- 9. CONDITIONAL AGGREGATES
-- ================================================

-- Attendance summary with status breakdown
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS name,
    COUNT(a.attendance_id) AS total_days,
    COUNT(CASE WHEN a.status = 'Present' THEN 1 END) AS present,
    COUNT(CASE WHEN a.status = 'Late' THEN 1 END) AS late,
    COUNT(CASE WHEN a.status = 'Absent' THEN 1 END) AS absent,
    CONCAT(
        ROUND(
            (COUNT(CASE WHEN a.status = 'Present' THEN 1 END)::NUMERIC / 
             NULLIF(COUNT(a.attendance_id)::NUMERIC, 0)) * 100, 
            2
        ),
        '%'
    ) AS attendance_rate
FROM employees e
LEFT JOIN attendance a ON e.employee_id = a.employee_id
    AND EXTRACT(MONTH FROM a.attendance_date) = 1
    AND EXTRACT(YEAR FROM a.attendance_date) = 2026
WHERE e.is_active = TRUE
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY present DESC;

-- ================================================
-- 10. DATA VALIDATION QUERIES
-- ================================================

-- Check for employees without any attendance
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS name,
    e.date_of_joining
FROM employees e
WHERE e.is_active = TRUE
AND NOT EXISTS (
    SELECT 1 FROM attendance a 
    WHERE a.employee_id = e.employee_id
);

-- Check for attendance records without corresponding employees
SELECT 
    a.attendance_id,
    a.employee_id,
    a.attendance_date
FROM attendance a
WHERE NOT EXISTS (
    SELECT 1 FROM employees e 
    WHERE e.employee_id = a.employee_id
);

-- Verify payroll calculations
SELECT 
    p.payroll_id,
    p.employee_id,
    p.base_salary,
    p.late_days,
    p.absent_days,
    p.late_deduction,
    p.absent_deduction,
    p.total_deduction,
    p.net_salary,
    -- Verify calculation
    (p.late_days * 200 + p.absent_days * 500) AS expected_deduction,
    (p.base_salary - (p.late_days * 200 + p.absent_days * 500)) AS expected_net_salary,
    CASE 
        WHEN p.total_deduction = (p.late_days * 200 + p.absent_days * 500) THEN '✓ Correct'
        ELSE '✗ Incorrect'
    END AS deduction_check
FROM payroll p;

-- ================================================
-- 11. PERFORMANCE ANALYSIS
-- ================================================

-- Explain query execution plan
EXPLAIN ANALYZE
SELECT 
    e.employee_id,
    COUNT(a.attendance_id)
FROM employees e
LEFT JOIN attendance a ON e.employee_id = a.employee_id
GROUP BY e.employee_id;

-- Index usage statistics
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;

-- ================================================
-- 12. AUDIT QUERIES
-- ================================================

-- View payroll audit trail
SELECT 
    pa.audit_id,
    pa.payroll_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    pa.month,
    pa.year,
    pa.old_net_salary,
    pa.new_net_salary,
    pa.operation,
    pa.changed_by,
    pa.changed_at
FROM payroll_audit pa
LEFT JOIN employees e ON pa.employee_id = e.employee_id
ORDER BY pa.changed_at DESC;

-- ================================================
-- 13. DATE-BASED QUERIES
-- ================================================

-- Get current month's attendance
SELECT * FROM attendance
WHERE attendance_date >= DATE_TRUNC('month', CURRENT_DATE)
  AND attendance_date < DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
ORDER BY attendance_date DESC;

-- Get last 7 days attendance
SELECT * FROM attendance
WHERE attendance_date >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY attendance_date DESC;

-- ================================================
-- 14. USEFUL UTILITY QUERIES
-- ================================================

-- List all tables
SELECT tablename 
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

-- List all views
SELECT viewname 
FROM pg_views 
WHERE schemaname = 'public'
ORDER BY viewname;

-- List all triggers
SELECT 
    trigger_name,
    event_object_table,
    action_timing,
    event_manipulation
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- List all stored procedures and functions
SELECT 
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
ORDER BY routine_type, routine_name;

-- ================================================
-- 15. SAMPLE TEST DATA INSERTION
-- ================================================

-- Mark attendance for today
INSERT INTO attendance (employee_id, attendance_date, status, check_in_time, check_out_time)
VALUES 
    (1, CURRENT_DATE, 'Present', '09:00:00', '18:00:00'),
    (2, CURRENT_DATE, 'Late', '10:30:00', '18:30:00'),
    (3, CURRENT_DATE, 'Absent', NULL, NULL);

-- Add a new employee
INSERT INTO employees (
    first_name, last_name, email, phone, 
    department_id, designation, base_salary
) VALUES (
    'Test', 'Employee', 'test.employee@company.com', '9999999999',
    1, 'Test Designation', 45000.00
);

-- ================================================
-- END OF QUERY REFERENCE
-- ================================================
