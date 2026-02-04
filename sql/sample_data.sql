-- ================================================
-- Sample Data for Employee Payroll & Attendance System
-- Comprehensive Dataset with Multiple Months and Years
-- ================================================

-- Clear existing data (if any) to avoid conflicts
TRUNCATE TABLE payroll CASCADE;
TRUNCATE TABLE attendance CASCADE;
TRUNCATE TABLE employees CASCADE;
TRUNCATE TABLE departments CASCADE;

-- Reset sequences
ALTER SEQUENCE departments_department_id_seq RESTART WITH 1;
ALTER SEQUENCE employees_employee_id_seq RESTART WITH 1;
ALTER SEQUENCE attendance_attendance_id_seq RESTART WITH 1;
ALTER SEQUENCE payroll_payroll_id_seq RESTART WITH 1;

-- ================================================
-- INSERT DEPARTMENTS
-- ================================================
INSERT INTO departments (department_name, location) VALUES
('Human Resources', 'Building A - Floor 1'),
('Engineering', 'Building B - Floor 3'),
('Sales & Marketing', 'Building A - Floor 2'),
('Finance', 'Building A - Floor 1'),
('Operations', 'Building C - Floor 2'),
('Quality Assurance', 'Building B - Floor 2'),
('Customer Support', 'Building C - Floor 1');

-- ================================================
-- INSERT EMPLOYEES (21 employees total)
-- ================================================
INSERT INTO employees (first_name, last_name, email, phone, department_id, designation, base_salary, date_of_joining) VALUES
-- HR Department (3 employees)
('Rajesh', 'Kumar', 'rajesh.kumar@company.com', '9876543210', 1, 'HR Manager', 55000.00, '2022-01-15'),
('Priya', 'Sharma', 'priya.sharma@company.com', '9876543211', 1, 'HR Executive', 35000.00, '2023-03-10'),
('Arjun', 'Desai', 'arjun.desai@company.com', '9876543230', 1, 'Recruitment Specialist', 42000.00, '2023-06-01'),

-- Engineering Department (6 employees)
('Amit', 'Verma', 'amit.verma@company.com', '9876543212', 2, 'Senior Developer', 75000.00, '2021-06-20'),
('Sneha', 'Patel', 'sneha.patel@company.com', '9876543213', 2, 'Full Stack Developer', 60000.00, '2022-08-15'),
('Vikram', 'Singh', 'vikram.singh@company.com', '9876543214', 2, 'DevOps Engineer', 65000.00, '2022-11-01'),
('Ananya', 'Reddy', 'ananya.reddy@company.com', '9876543215', 2, 'Junior Developer', 40000.00, '2023-09-05'),
('Rohan', 'Bhatt', 'rohan.bhatt@company.com', '9876543231', 2, 'Software Architect', 85000.00, '2020-05-10'),
('Pooja', 'Kumar', 'pooja.kumar@company.com', '9876543232', 2, 'Frontend Developer', 55000.00, '2023-01-15'),

-- Sales & Marketing Department (4 employees)
('Rahul', 'Mehta', 'rahul.mehta@company.com', '9876543216', 3, 'Sales Manager', 58000.00, '2021-04-10'),
('Kavya', 'Nair', 'kavya.nair@company.com', '9876543217', 3, 'Marketing Executive', 42000.00, '2023-01-20'),
('Sanjay', 'Gupta', 'sanjay.gupta@company.com', '9876543233', 3, 'Sales Executive', 48000.00, '2022-07-15'),
('Deepti', 'Jain', 'deepti.jain@company.com', '9876543234', 3, 'Digital Marketing Specialist', 45000.00, '2023-02-01'),

-- Finance Department (3 employees)
('Suresh', 'Gupta', 'suresh.gupta@company.com', '9876543218', 4, 'Finance Manager', 70000.00, '2020-12-05'),
('Divya', 'Iyer', 'divya.iyer@company.com', '9876543219', 4, 'Accountant', 45000.00, '2023-05-15'),
('Nikhil', 'Vyas', 'nikhil.vyas@company.com', '9876543235', 4, 'Financial Analyst', 52000.00, '2022-03-20'),

-- Operations Department (2 employees)
('Karan', 'Chopra', 'karan.chopra@company.com', '9876543220', 5, 'Operations Manager', 62000.00, '2021-09-01'),
('Neha', 'Joshi', 'neha.joshi@company.com', '9876543221', 5, 'Operations Executive', 38000.00, '2023-07-10'),

-- Quality Assurance Department (2 employees)
('Vishal', 'Agarwal', 'vishal.agarwal@company.com', '9876543236', 6, 'QA Manager', 60000.00, '2021-11-15'),
('Megha', 'Singh', 'megha.singh@company.com', '9876543237', 6, 'QA Engineer', 46000.00, '2023-04-01'),

-- Customer Support Department (1 employee)
('Tarun', 'Mishra', 'tarun.mishra@company.com', '9876543238', 7, 'Support Manager', 50000.00, '2022-02-20');

-- ================================================
-- INSERT ATTENDANCE FOR OCTOBER 2025
-- ================================================
INSERT INTO attendance (employee_id, attendance_date, status, check_in_time, check_out_time) VALUES
-- Sample attendance for October 2025 (all 21 employees)
(1, '2025-10-01', 'Present', '09:00:00', '18:00:00'),
(1, '2025-10-02', 'Present', '09:05:00', '18:05:00'),
(1, '2025-10-03', 'Present', '08:55:00', '18:00:00'),
(1, '2025-10-06', 'Present', '09:00:00', '18:00:00'),
(1, '2025-10-07', 'Present', '09:10:00', '18:10:00'),
(1, '2025-10-08', 'Present', '09:00:00', '18:00:00'),
(1, '2025-10-09', 'Present', '09:00:00', '18:00:00'),
(1, '2025-10-10', 'Present', '09:00:00', '18:00:00'),
(1, '2025-10-13', 'Present', '09:00:00', '18:00:00'),
(1, '2025-10-14', 'Present', '09:00:00', '18:00:00'),
(1, '2025-10-15', 'Present', '09:00:00', '18:00:00'),
(1, '2025-10-16', 'Present', '09:00:00', '18:00:00'),
(1, '2025-10-17', 'Present', '09:00:00', '18:00:00'),
(1, '2025-10-20', 'Present', '09:00:00', '18:00:00'),
(1, '2025-10-21', 'Present', '09:00:00', '18:00:00'),
(1, '2025-10-22', 'Present', '09:00:00', '18:00:00'),
(1, '2025-10-23', 'Present', '09:00:00', '18:00:00'),
(1, '2025-10-24', 'Present', '09:00:00', '18:00:00'),
(1, '2025-10-27', 'Present', '09:00:00', '18:00:00'),
(1, '2025-10-28', 'Present', '09:00:00', '18:00:00'),
(1, '2025-10-29', 'Present', '09:00:00', '18:00:00'),
(1, '2025-10-30', 'Present', '09:00:00', '18:00:00'),
(1, '2025-10-31', 'Present', '09:00:00', '18:00:00');

-- ================================================
-- INSERT BULK ATTENDANCE FOR ALL EMPLOYEES 
-- OCTOBER, NOVEMBER, DECEMBER 2025 & JANUARY 2026
-- ================================================
INSERT INTO attendance (employee_id, attendance_date, status, check_in_time, check_out_time) 
SELECT 
    employee_id,
    attendance_date,
    CASE 
        WHEN rand_val < 0.82 THEN 'Present'
        WHEN rand_val < 0.92 THEN 'Late'
        ELSE 'Absent'
    END as status,
    CASE 
        WHEN rand_val < 0.82 THEN '09:00:00'::TIME + (random() * INTERVAL '20 minutes')
        WHEN rand_val < 0.92 THEN '10:00:00'::TIME + (random() * INTERVAL '50 minutes')
        ELSE NULL
    END as check_in_time,
    CASE 
        WHEN rand_val < 0.92 THEN '18:00:00'::TIME + (random() * INTERVAL '30 minutes')
        ELSE NULL
    END as check_out_time
FROM (
    SELECT 
        e.employee_id,
        d.attendance_date,
        random() as rand_val
    FROM 
        employees e
    CROSS JOIN 
        (SELECT generate_series('2025-10-01'::DATE, '2026-01-31'::DATE, '1 day'::INTERVAL)::DATE AS attendance_date) d
    WHERE 
        EXTRACT(DOW FROM d.attendance_date) NOT IN (0, 6)
        AND NOT EXISTS (
            SELECT 1 FROM attendance 
            WHERE attendance.employee_id = e.employee_id 
            AND attendance.attendance_date = d.attendance_date
        )
) random_data;

-- ================================================
-- INSERT PAYROLL DATA FOR OCTOBER 2025
-- ================================================
INSERT INTO payroll (employee_id, month, year, base_salary, total_days, present_days, late_days, absent_days, 
                     late_deduction, absent_deduction, total_deduction, net_salary)
SELECT 
    e.employee_id,
    10 as month,
    2025 as year,
    e.base_salary,
    COALESCE(att.total_days, 22) as total_days,
    COALESCE(att.present_days, 19) as present_days,
    COALESCE(att.late_days, 2) as late_days,
    COALESCE(att.absent_days, 1) as absent_days,
    COALESCE(att.late_days, 2) * 200 as late_deduction,
    COALESCE(att.absent_days, 1) * 500 as absent_deduction,
    (COALESCE(att.late_days, 2) * 200) + (COALESCE(att.absent_days, 1) * 500) as total_deduction,
    e.base_salary - ((COALESCE(att.late_days, 2) * 200) + (COALESCE(att.absent_days, 1) * 500)) as net_salary
FROM employees e
LEFT JOIN (
    SELECT 
        employee_id,
        COUNT(*) as total_days,
        SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) as present_days,
        SUM(CASE WHEN status = 'Late' THEN 1 ELSE 0 END) as late_days,
        SUM(CASE WHEN status = 'Absent' THEN 1 ELSE 0 END) as absent_days
    FROM attendance
    WHERE EXTRACT(MONTH FROM attendance_date) = 10 AND EXTRACT(YEAR FROM attendance_date) = 2025
    GROUP BY employee_id
) att ON e.employee_id = att.employee_id;

-- ================================================
-- INSERT PAYROLL DATA FOR NOVEMBER 2025
-- ================================================
INSERT INTO payroll (employee_id, month, year, base_salary, total_days, present_days, late_days, absent_days, 
                     late_deduction, absent_deduction, total_deduction, net_salary)
SELECT 
    e.employee_id,
    11 as month,
    2025 as year,
    e.base_salary,
    COALESCE(att.total_days, 20) as total_days,
    COALESCE(att.present_days, 18) as present_days,
    COALESCE(att.late_days, 1) as late_days,
    COALESCE(att.absent_days, 1) as absent_days,
    COALESCE(att.late_days, 1) * 200 as late_deduction,
    COALESCE(att.absent_days, 1) * 500 as absent_deduction,
    (COALESCE(att.late_days, 1) * 200) + (COALESCE(att.absent_days, 1) * 500) as total_deduction,
    e.base_salary - ((COALESCE(att.late_days, 1) * 200) + (COALESCE(att.absent_days, 1) * 500)) as net_salary
FROM employees e
LEFT JOIN (
    SELECT 
        employee_id,
        COUNT(*) as total_days,
        SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) as present_days,
        SUM(CASE WHEN status = 'Late' THEN 1 ELSE 0 END) as late_days,
        SUM(CASE WHEN status = 'Absent' THEN 1 ELSE 0 END) as absent_days
    FROM attendance
    WHERE EXTRACT(MONTH FROM attendance_date) = 11 AND EXTRACT(YEAR FROM attendance_date) = 2025
    GROUP BY employee_id
) att ON e.employee_id = att.employee_id;

-- ================================================
-- INSERT PAYROLL DATA FOR DECEMBER 2025
-- ================================================
INSERT INTO payroll (employee_id, month, year, base_salary, total_days, present_days, late_days, absent_days, 
                     late_deduction, absent_deduction, total_deduction, net_salary)
SELECT 
    e.employee_id,
    12 as month,
    2025 as year,
    e.base_salary,
    COALESCE(att.total_days, 21) as total_days,
    COALESCE(att.present_days, 18) as present_days,
    COALESCE(att.late_days, 2) as late_days,
    COALESCE(att.absent_days, 1) as absent_days,
    COALESCE(att.late_days, 2) * 200 as late_deduction,
    COALESCE(att.absent_days, 1) * 500 as absent_deduction,
    (COALESCE(att.late_days, 2) * 200) + (COALESCE(att.absent_days, 1) * 500) as total_deduction,
    e.base_salary - ((COALESCE(att.late_days, 2) * 200) + (COALESCE(att.absent_days, 1) * 500)) as net_salary
FROM employees e
LEFT JOIN (
    SELECT 
        employee_id,
        COUNT(*) as total_days,
        SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) as present_days,
        SUM(CASE WHEN status = 'Late' THEN 1 ELSE 0 END) as late_days,
        SUM(CASE WHEN status = 'Absent' THEN 1 ELSE 0 END) as absent_days
    FROM attendance
    WHERE EXTRACT(MONTH FROM attendance_date) = 12 AND EXTRACT(YEAR FROM attendance_date) = 2025
    GROUP BY employee_id
) att ON e.employee_id = att.employee_id;

-- ================================================
-- INSERT PAYROLL DATA FOR JANUARY 2026
-- ================================================
INSERT INTO payroll (employee_id, month, year, base_salary, total_days, present_days, late_days, absent_days, 
                     late_deduction, absent_deduction, total_deduction, net_salary)
SELECT 
    e.employee_id,
    1 as month,
    2026 as year,
    e.base_salary,
    COALESCE(att.total_days, 22) as total_days,
    COALESCE(att.present_days, 19) as present_days,
    COALESCE(att.late_days, 2) as late_days,
    COALESCE(att.absent_days, 1) as absent_days,
    COALESCE(att.late_days, 2) * 200 as late_deduction,
    COALESCE(att.absent_days, 1) * 500 as absent_deduction,
    (COALESCE(att.late_days, 2) * 200) + (COALESCE(att.absent_days, 1) * 500) as total_deduction,
    e.base_salary - ((COALESCE(att.late_days, 2) * 200) + (COALESCE(att.absent_days, 1) * 500)) as net_salary
FROM employees e
LEFT JOIN (
    SELECT 
        employee_id,
        COUNT(*) as total_days,
        SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) as present_days,
        SUM(CASE WHEN status = 'Late' THEN 1 ELSE 0 END) as late_days,
        SUM(CASE WHEN status = 'Absent' THEN 1 ELSE 0 END) as absent_days
    FROM attendance
    WHERE EXTRACT(MONTH FROM attendance_date) = 1 AND EXTRACT(YEAR FROM attendance_date) = 2026
    GROUP BY employee_id
) att ON e.employee_id = att.employee_id;

-- ================================================
-- Display Summary
-- ================================================
SELECT '✓ Sample data inserted successfully!' AS status;
SELECT COUNT(*) AS total_departments FROM departments;
SELECT COUNT(*) AS total_employees FROM employees;
SELECT COUNT(*) AS total_attendance_records FROM attendance;
SELECT COUNT(*) AS total_payroll_records FROM payroll;
