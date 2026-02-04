@echo off
REM ================================================
REM Database Setup Script for Windows
REM Employee Payroll & Attendance Analytics System
REM ================================================

echo.
echo ========================================
echo Employee Payroll System - Database Setup
echo ========================================
echo.

REM Set variables
set DB_NAME=payroll_db
set DB_USER=postgres

echo Step 1: Creating database...
echo.

REM Create database
psql -U %DB_USER% -c "DROP DATABASE IF EXISTS %DB_NAME%;"
psql -U %DB_USER% -c "CREATE DATABASE %DB_NAME%;"

echo.
echo Database created successfully!
echo.
echo Step 2: Running SQL scripts...
echo.

REM Change to SQL directory
cd sql

REM Run SQL scripts in order
echo [1/5] Creating schema...
psql -U %DB_USER% -d %DB_NAME% -f schema.sql

echo [2/5] Creating views...
psql -U %DB_USER% -d %DB_NAME% -f views.sql

echo [3/5] Creating triggers...
psql -U %DB_USER% -d %DB_NAME% -f triggers.sql

echo [4/5] Creating procedures...
psql -U %DB_USER% -d %DB_NAME% -f procedures.sql

echo [5/5] Inserting sample data...
psql -U %DB_USER% -d %DB_NAME% -f sample_data.sql

cd ..

echo.
echo ========================================
echo Database Setup Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Configure backend/.env with your PostgreSQL password
echo 2. Run: cd backend
echo 3. Run: npm install
echo 4. Run: npm start
echo 5. Open frontend/index.html in browser
echo.
echo To generate sample payroll, run in psql:
echo CALL sp_generate_monthly_payroll(1, 2026);
echo.

pause
