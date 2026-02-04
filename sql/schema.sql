-- ================================================
-- Employee Payroll & Attendance Analytics System
-- Database Schema (PostgreSQL)
-- Demonstrates: 3NF, Constraints, PKs, FKs, Checks, Indexes
-- ================================================

-- Drop existing tables if they exist (for clean setup)
DROP TABLE IF EXISTS payroll CASCADE;
DROP TABLE IF EXISTS attendance CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS departments CASCADE;

-- ================================================
-- TABLE: Departments
-- ================================================
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT chk_dept_name_length CHECK (LENGTH(department_name) >= 2)
);

-- Index for department name lookups
CREATE INDEX idx_dept_name ON departments(department_name);

-- ================================================
-- TABLE: Employees
-- ================================================
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15),
    department_id INTEGER NOT NULL,
    designation VARCHAR(100) NOT NULL,
    base_salary DECIMAL(10, 2) NOT NULL,
    date_of_joining DATE NOT NULL DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    CONSTRAINT fk_employee_department 
        FOREIGN KEY (department_id) 
        REFERENCES departments(department_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_base_salary CHECK (base_salary > 0),
    CONSTRAINT chk_email_format CHECK (email LIKE '%@%.%'),
    CONSTRAINT chk_phone_length CHECK (LENGTH(phone) >= 10),
    CONSTRAINT chk_joining_date CHECK (date_of_joining <= CURRENT_DATE)
);

-- Indexes for frequent queries
CREATE INDEX idx_employee_department ON employees(department_id);
CREATE INDEX idx_employee_email ON employees(email);
CREATE INDEX idx_employee_active ON employees(is_active);

-- ================================================
-- TABLE: Attendance
-- ================================================
CREATE TABLE attendance (
    attendance_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    attendance_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    check_in_time TIME,
    check_out_time TIME,
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    CONSTRAINT fk_attendance_employee 
        FOREIGN KEY (employee_id) 
        REFERENCES employees(employee_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_attendance_status 
        CHECK (status IN ('Present', 'Late', 'Absent')),
    CONSTRAINT chk_attendance_date 
        CHECK (attendance_date <= CURRENT_DATE),
    CONSTRAINT chk_check_times 
        CHECK (check_out_time IS NULL OR check_out_time > check_in_time),
    
    -- Unique constraint: one attendance record per employee per day
    CONSTRAINT unique_employee_date 
        UNIQUE (employee_id, attendance_date)
);

-- Indexes for performance
CREATE INDEX idx_attendance_employee ON attendance(employee_id);
CREATE INDEX idx_attendance_date ON attendance(attendance_date);
CREATE INDEX idx_attendance_status ON attendance(status);
CREATE INDEX idx_attendance_month ON attendance(EXTRACT(YEAR FROM attendance_date), EXTRACT(MONTH FROM attendance_date));

-- ================================================
-- TABLE: Payroll
-- ================================================
CREATE TABLE payroll (
    payroll_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    month INTEGER NOT NULL,
    year INTEGER NOT NULL,
    base_salary DECIMAL(10, 2) NOT NULL,
    total_days INTEGER NOT NULL DEFAULT 0,
    present_days INTEGER NOT NULL DEFAULT 0,
    late_days INTEGER NOT NULL DEFAULT 0,
    absent_days INTEGER NOT NULL DEFAULT 0,
    late_deduction DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    absent_deduction DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    total_deduction DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    net_salary DECIMAL(10, 2) NOT NULL,
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    CONSTRAINT fk_payroll_employee 
        FOREIGN KEY (employee_id) 
        REFERENCES employees(employee_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_month CHECK (month BETWEEN 1 AND 12),
    CONSTRAINT chk_year CHECK (year BETWEEN 2020 AND 2100),
    CONSTRAINT chk_base_salary_positive CHECK (base_salary > 0),
    CONSTRAINT chk_days_valid CHECK (
        total_days >= 0 AND 
        present_days >= 0 AND 
        late_days >= 0 AND 
        absent_days >= 0 AND
        (present_days + late_days + absent_days) <= total_days
    ),
    CONSTRAINT chk_deductions CHECK (
        late_deduction >= 0 AND 
        absent_deduction >= 0 AND 
        total_deduction >= 0 AND
        total_deduction <= base_salary
    ),
    CONSTRAINT chk_net_salary CHECK (net_salary >= 0),
    
    -- Unique constraint: one payroll record per employee per month
    CONSTRAINT unique_employee_month_year 
        UNIQUE (employee_id, month, year)
);

-- Indexes for performance
CREATE INDEX idx_payroll_employee ON payroll(employee_id);
CREATE INDEX idx_payroll_month_year ON payroll(year, month);

-- ================================================
-- COMMENTS (Documentation)
-- ================================================
COMMENT ON TABLE departments IS 'Stores department information';
COMMENT ON TABLE employees IS 'Stores employee master data with base salary';
COMMENT ON TABLE attendance IS 'Daily attendance records with status';
COMMENT ON TABLE payroll IS 'Monthly payroll records with calculated deductions';

COMMENT ON COLUMN attendance.status IS 'Valid values: Present, Late, Absent';
COMMENT ON COLUMN payroll.late_deduction IS 'Total deduction for late days';
COMMENT ON COLUMN payroll.absent_deduction IS 'Total deduction for absent days';
COMMENT ON COLUMN payroll.net_salary IS 'Final salary after deductions';
