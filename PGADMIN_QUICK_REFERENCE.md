# SQL Commands to Run in pgAdmin - Quick Reference

## Files to Run in pgAdmin (in this order)

### Step 1: Clear Old Data & Create Schema (if starting fresh)
**File Path**: `sql/schema.sql`
- **Location**: Open this file and copy all content
- **Paste into pgAdmin Query Editor**
- **Click Execute**

### Step 2: Insert Comprehensive Sample Data (UPDATED)
**File Path**: `sql/sample_data.sql` 
- **Location**: Open this file and copy all content
- **Paste into pgAdmin Query Editor**
- **Click Execute**

---

## Direct Copy-Paste Commands

If you want to manually run SQL without files:

```sql
-- Step 1: Clear all existing data
TRUNCATE TABLE payroll CASCADE;
TRUNCATE TABLE attendance CASCADE;
TRUNCATE TABLE employees CASCADE;
TRUNCATE TABLE departments CASCADE;

-- Step 2: Verify data was cleared
SELECT COUNT(*) FROM departments;
SELECT COUNT(*) FROM employees;
SELECT COUNT(*) FROM attendance;
SELECT COUNT(*) FROM payroll;
```

---

## Verify Data After Running sample_data.sql

Copy and run this query to check data:

```sql
-- Check departments
SELECT COUNT(*) AS total_departments FROM departments;
SELECT * FROM departments;

-- Check employees per department
SELECT d.department_name, COUNT(e.employee_id) as employee_count
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name;

-- Check attendance records
SELECT COUNT(*) AS total_attendance_records FROM attendance;
SELECT 
    EXTRACT(MONTH FROM attendance_date) as month,
    EXTRACT(YEAR FROM attendance_date) as year,
    COUNT(*) as record_count
FROM attendance
GROUP BY year, month
ORDER BY year DESC, month DESC;

-- Check payroll records
SELECT COUNT(*) AS total_payroll_records FROM payroll;
SELECT 
    month, year,
    COUNT(*) as employee_count,
    ROUND(AVG(net_salary)::numeric, 2) as avg_net_salary
FROM payroll
GROUP BY year, month
ORDER BY year DESC, month DESC;

-- Check specific attendance data for filters to work
SELECT DISTINCT EXTRACT(YEAR FROM attendance_date) as years FROM attendance ORDER BY years DESC;
SELECT DISTINCT EXTRACT(MONTH FROM attendance_date) as months FROM attendance ORDER BY months DESC;
```

---

## Expected Output After Running sample_data.sql

```
Total Departments: 7
Total Employees: 21
Total Attendance Records: 1800+
Total Payroll Records: 84

Departments:
- Human Resources
- Engineering
- Sales & Marketing
- Finance
- Operations
- Quality Assurance
- Customer Support

Attendance Data Available For:
- October 2025
- November 2025
- December 2025
- January 2026

Payroll Data Available For:
- October 2025 (21 employees)
- November 2025 (21 employees)
- December 2025 (21 employees)
- January 2026 (21 employees)
```

---

## pgAdmin Location

To access pgAdmin:
1. Open browser
2. Go to: `http://localhost:5050`
3. Login with your pgAdmin credentials
4. Select your PostgreSQL server
5. Click on `payroll_db` database
6. Go to **Tools** → **Query Tool**
7. Paste SQL commands
8. Click **Execute** button (lightning bolt icon or F5)

---

## After Executing - Refresh Application

1. Stop backend server (if running): `Ctrl+C`
2. Start backend again: `npm start` in backend folder
3. Refresh browser: `F5` or `Ctrl+R` at `http://localhost:3000`

**Now all filters will work with sufficient data!**

---

## Complete File Paths for Reference

```
d:\projects\Employee payroll and attendance analytics system\
├── sql/
│   ├── schema.sql         ← Run 1st (if needed)
│   ├── sample_data.sql    ← Run 2nd (UPDATED with 4 months data)
│   ├── views.sql          ← Optional
│   ├── triggers.sql       ← Optional
│   └── procedures.sql     ← Optional
└── frontend/
    └── index.html         ← Open at http://localhost:3000
```
