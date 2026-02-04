-- ============================================
-- Complete Database Setup Script
-- Run this file to set up the entire database
-- ============================================

-- Step 1: Create Schema
\echo '========================================';
\echo 'Step 1: Creating database schema...';
\echo '========================================';
\i schema.sql

-- Step 2: Create Views
\echo '';
\echo '========================================';
\echo 'Step 2: Creating views...';
\echo '========================================';
\i views.sql

-- Step 3: Create Triggers
\echo '';
\echo '========================================';
\echo 'Step 3: Creating triggers...';
\echo '========================================';
\i triggers.sql

-- Step 4: Create Procedures and Functions
\echo '';
\echo '========================================';
\echo 'Step 4: Creating procedures and functions...';
\echo '========================================';
\i procedures.sql

-- Step 5: Insert Sample Data
\echo '';
\echo '========================================';
\echo 'Step 5: Inserting sample data...';
\echo '========================================';
\i sample_data.sql

-- Final Summary
\echo '';
\echo '========================================';
\echo 'DATABASE SETUP COMPLETED SUCCESSFULLY!';
\echo '========================================';
\echo '';

-- Display statistics
\echo 'Database Statistics:';
\echo '-------------------';

SELECT 
    'Departments' AS table_name, 
    COUNT(*) AS record_count 
FROM departments
UNION ALL
SELECT 
    'Employees', 
    COUNT(*) 
FROM employees
UNION ALL
SELECT 
    'Attendance Records', 
    COUNT(*) 
FROM attendance
UNION ALL
SELECT 
    'Payroll Records', 
    COUNT(*) 
FROM payroll;

\echo '';
\echo 'Next Steps:';
\echo '1. Configure backend/.env with database credentials';
\echo '2. Run: cd backend && npm install';
\echo '3. Run: npm start';
\echo '4. Open frontend/index.html in browser';
\echo '';
\echo 'To generate sample payroll for January 2026:';
\echo 'CALL sp_generate_monthly_payroll(1, 2026);';
\echo '';
