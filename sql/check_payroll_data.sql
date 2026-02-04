-- ================================================
-- Check Payroll Data Status
-- Run this in pgAdmin to verify payroll records
-- ================================================

-- Check total payroll records
SELECT 'Total Payroll Records:' as info, COUNT(*) as count FROM payroll;

-- Check payroll by month/year
SELECT 
    year, 
    month, 
    COUNT(*) as employee_count,
    SUM(total_deduction) as total_deductions,
    SUM(net_salary) as total_net_salaries
FROM payroll
GROUP BY year, month
ORDER BY year DESC, month DESC;

-- Check which employees have payroll for which months
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    COUNT(p.payroll_id) as payroll_records_count,
    STRING_AGG(CONCAT(p.month, '/', p.year), ', ' ORDER BY p.year DESC, p.month DESC) as months_recorded
FROM employees e
LEFT JOIN payroll p ON e.employee_id = p.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY e.employee_id;

-- Check if there are any missing payroll records
SELECT 
    'Employees with incomplete payroll data (should have 4 months):' as info,
    COUNT(*) as count
FROM (
    SELECT e.employee_id, COUNT(p.payroll_id) as payroll_count
    FROM employees e
    LEFT JOIN payroll p ON e.employee_id = p.employee_id
    GROUP BY e.employee_id
    HAVING COUNT(p.payroll_id) < 4
) incomplete;
