# Employee Payroll & Attendance Analytics System

**A SQL-First Web Application Demonstrating Advanced PostgreSQL Features**

---

## 📋 Project Overview

This project is a comprehensive **Employee Payroll and Attendance Management System** built with a **SQL-first architecture** where all business logic resides in the database layer using PostgreSQL. The application demonstrates proficiency in advanced SQL concepts including stored procedures, triggers, views, complex joins, constraints, and performance optimization.

### 🎯 Key Objective
- **Demonstrate SQL Proficiency**: All business logic (payroll calculations, attendance analysis, salary deductions) is implemented in PostgreSQL, not in application code.
- **Interview-Ready**: Clean, well-documented code suitable for showcasing in technical interviews.
- **Real-World Application**: Solves actual business problems with proper data modeling and validation.

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Database** | PostgreSQL | Core business logic, data storage, and processing |
| **Backend** | Node.js + Express.js | API bridge between frontend and database |
| **Database Driver** | `pg` (node-postgres) | Raw SQL queries (NO ORM) |
| **Frontend** | HTML5, CSS3, Vanilla JavaScript | User interface |
| **API Communication** | Fetch API | RESTful API calls |

---

## 🗄️ Database Design

### Entity Relationship Diagram (ERD)

```
Departments (1) ──< (M) Employees (1) ──< (M) Attendance
                           │
                           │
                           └──< (M) Payroll
```

### Tables (Normalized to 3NF)

#### 1. **Departments**
- `department_id` (PK, SERIAL)
- `department_name` (UNIQUE, NOT NULL)
- `location`
- `created_at`

#### 2. **Employees**
- `employee_id` (PK, SERIAL)
- `first_name`, `last_name`, `email` (UNIQUE)
- `phone`, `designation`
- `department_id` (FK → Departments)
- `base_salary` (DECIMAL, CHECK > 0)
- `date_of_joining`, `is_active`

#### 3. **Attendance**
- `attendance_id` (PK, SERIAL)
- `employee_id` (FK → Employees)
- `attendance_date` (UNIQUE per employee)
- `status` (CHECK: 'Present', 'Late', 'Absent')
- `check_in_time`, `check_out_time`
- `remarks`

#### 4. **Payroll**
- `payroll_id` (PK, SERIAL)
- `employee_id` (FK → Employees)
- `month`, `year` (UNIQUE per employee)
- `base_salary`
- `total_days`, `present_days`, `late_days`, `absent_days`
- `late_deduction`, `absent_deduction`, `total_deduction`
- `net_salary` (Auto-calculated by trigger)
- `generated_at`

---

## 🎓 SQL Features Demonstrated

### 1. **Schema Design**
- ✅ Primary Keys (SERIAL)
- ✅ Foreign Keys with CASCADE/RESTRICT
- ✅ UNIQUE Constraints
- ✅ CHECK Constraints (salary > 0, email format, status values)
- ✅ NOT NULL Constraints
- ✅ DEFAULT Values

### 2. **Indexes**
```sql
CREATE INDEX idx_attendance_employee ON attendance(employee_id);
CREATE INDEX idx_attendance_date ON attendance(attendance_date);
CREATE INDEX idx_payroll_month_year ON payroll(year, month);
```

### 3. **Views (Reporting)**
- `view_monthly_attendance_summary` - Aggregate attendance stats per employee
- `view_monthly_payroll_report` - Complete payroll details with joins
- `view_department_payroll_summary` - Department-wise payroll aggregation
- `view_employee_attendance_status` - Employee details with latest attendance
- `view_top_performers_attendance` - Employees ranked by attendance
- `view_attendance_defaulters` - Identify poor attendance

### 4. **Stored Procedures**
```sql
-- Generate payroll for all employees for a given month
CALL sp_generate_monthly_payroll(1, 2026);

-- Generate payroll for a specific employee
CALL sp_generate_employee_payroll(3, 1, 2026);
```

**Business Logic in Procedure:**
- Late Day Deduction: ₹200 per day
- Absent Day Deduction: ₹500 per day
- Auto-calculates net salary
- Prevents duplicate payroll generation

### 5. **Functions**
```sql
-- Calculate expected salary without inserting into table
SELECT * FROM fn_calculate_expected_salary(3, 1, 2026);

-- Get department payroll summary
SELECT * FROM fn_get_department_payroll_summary(2, 1, 2026);

-- Delete payroll for a month (rollback)
SELECT fn_delete_monthly_payroll(1, 2026);
```

### 6. **Triggers**

| Trigger | Event | Purpose |
|---------|-------|---------|
| `trg_validate_attendance` | BEFORE INSERT/UPDATE | Validate attendance rules |
| `trg_prevent_duplicate_payroll` | BEFORE INSERT | Ensure one payroll per month |
| `trg_calculate_net_salary` | BEFORE INSERT/UPDATE | Auto-calculate net salary |
| `trg_check_employee_status` | BEFORE INSERT/UPDATE | Prevent operations on inactive employees |
| `trg_audit_payroll_changes` | AFTER UPDATE/DELETE | Audit trail for payroll changes |
| `trg_validate_payroll_integrity` | BEFORE INSERT/UPDATE | Validate payroll data integrity |

### 7. **Complex Queries**

**Joins:**
```sql
-- Multi-table join with aggregation
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS name,
    d.department_name,
    COUNT(a.attendance_id) AS total_attendance
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id
LEFT JOIN attendance a ON e.employee_id = a.employee_id
GROUP BY e.employee_id, d.department_name;
```

**Subqueries:**
```sql
-- Employees with above-average salary
SELECT * FROM employees
WHERE base_salary > (SELECT AVG(base_salary) FROM employees);
```

**Aggregate Functions:**
```sql
COUNT(), SUM(), AVG(), MIN(), MAX(), 
COUNT(CASE WHEN ... THEN 1 END)
```

---

## 📂 Project Structure

```
Employee payroll and attendance analytics system/
│
├── sql/                           # All SQL files
│   ├── schema.sql                 # Database schema with constraints
│   ├── sample_data.sql            # Sample data for testing
│   ├── views.sql                  # SQL views for reporting
│   ├── triggers.sql               # Triggers for automation
│   └── procedures.sql             # Stored procedures & functions
│
├── backend/                       # Node.js API
│   ├── server.js                  # Express server with API routes
│   ├── db.js                      # PostgreSQL connection pool
│   ├── package.json               # Dependencies
│   ├── .env                       # Environment variables
│   └── .env.example               # Environment template
│
├── frontend/                      # Frontend UI
│   ├── index.html                 # Main HTML page
│   ├── css/
│   │   └── styles.css             # Styling
│   └── js/
│       └── app.js                 # Frontend logic
│
└── README.md                      # This file
```

---

## 🚀 Setup Instructions

### Prerequisites
- **PostgreSQL** (version 12 or higher)
- **Node.js** (version 14 or higher)
- **npm** (comes with Node.js)

### Step 1: Database Setup

1. **Create Database:**
```bash
psql -U postgres
```

```sql
CREATE DATABASE payroll_db;
\c payroll_db
```

2. **Run SQL Scripts (in order):**
```bash
psql -U postgres -d payroll_db -f sql/schema.sql
psql -U postgres -d payroll_db -f sql/views.sql
psql -U postgres -d payroll_db -f sql/triggers.sql
psql -U postgres -d payroll_db -f sql/procedures.sql
psql -U postgres -d payroll_db -f sql/sample_data.sql
```

Or run all at once:
```bash
cd sql
psql -U postgres -d payroll_db -f schema.sql
psql -U postgres -d payroll_db -f views.sql
psql -U postgres -d payroll_db -f triggers.sql
psql -U postgres -d payroll_db -f procedures.sql
psql -U postgres -d payroll_db -f sample_data.sql
```

### Step 2: Backend Setup

1. **Navigate to backend folder:**
```bash
cd backend
```

2. **Install dependencies:**
```bash
npm install
```

3. **Configure environment variables:**
   - Copy `.env.example` to `.env`
   - Update database credentials:

```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=payroll_db
PORT=3000
```

4. **Start the server:**
```bash
npm start
```

Or for development with auto-reload:
```bash
npm run dev
```

Server will run on: `http://localhost:3000`

### Step 3: Frontend Setup

1. **Open the frontend:**
   - Simply open `frontend/index.html` in a web browser
   - Or use a local server (recommended):

**Option A: Using Python:**
```bash
cd frontend
python -m http.server 8080
```

**Option B: Using Node.js http-server:**
```bash
npm install -g http-server
cd frontend
http-server -p 8080
```

2. **Access the application:**
   - Open browser: `http://localhost:8080`

---

## 🎮 Usage Guide

### 1. **Employee Management**
- View all employees with department details
- Add new employees with validation
- Base salary and joining date tracking

### 2. **Attendance Entry**
- Mark daily attendance (Present/Late/Absent)
- Automatic validation via triggers
- Check-in/Check-out time tracking
- Filter by month and year

### 3. **Payroll Generation**
- Click "Generate Payroll" button
- Select month and year
- System calls stored procedure `sp_generate_monthly_payroll`
- **Automatic calculation:**
  - Late days → ₹200 deduction per day
  - Absent days → ₹500 deduction per day
  - Net salary = Base salary - Total deductions

### 4. **Payroll Reports**
- View detailed monthly payroll
- Department-wise summaries
- Attendance percentage
- Deduction breakdowns

### 5. **Departments**
- View all departments
- Add new departments
- See employee count per department

---

## 🔍 API Endpoints

### Health Check
```
GET /api/health
```

### Departments
```
GET    /api/departments          # Get all departments
POST   /api/departments          # Create department
```

### Employees
```
GET    /api/employees            # Get all employees
GET    /api/employees/:id        # Get employee by ID
POST   /api/employees            # Create employee
PUT    /api/employees/:id        # Update employee
```

### Attendance
```
GET    /api/attendance           # Get attendance records (with filters)
POST   /api/attendance           # Mark attendance
PUT    /api/attendance/:id       # Update attendance
GET    /api/attendance/summary/monthly  # Monthly summary (from view)
```

### Payroll
```
POST   /api/payroll/generate            # Generate payroll (calls procedure)
GET    /api/payroll/reports             # Get payroll reports (from view)
GET    /api/payroll/department-summary  # Department summary
GET    /api/payroll/expected-salary/:id # Calculate expected salary
```

---

## 💡 SQL Highlights for Interview

### 1. **Attendance Validation Trigger**
```sql
CREATE OR REPLACE FUNCTION fn_validate_attendance()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.attendance_date > CURRENT_DATE THEN
        RAISE EXCEPTION 'Cannot mark attendance for future dates';
    END IF;
    
    IF NEW.status = 'Absent' AND NEW.check_in_time IS NOT NULL THEN
        RAISE EXCEPTION 'Absent employees cannot have check-in time';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### 2. **Payroll Generation Procedure**
```sql
CREATE OR REPLACE PROCEDURE sp_generate_monthly_payroll(
    p_month INTEGER,
    p_year INTEGER
)
LANGUAGE plpgsql AS $$
DECLARE
    v_employee_record RECORD;
    c_late_deduction_rate CONSTANT DECIMAL(10, 2) := 200.00;
    c_absent_deduction_rate CONSTANT DECIMAL(10, 2) := 500.00;
BEGIN
    FOR v_employee_record IN 
        SELECT employee_id, base_salary FROM employees WHERE is_active = TRUE
    LOOP
        -- Calculate attendance and insert payroll
        -- (Full logic in procedures.sql)
    END LOOP;
END;
$$;
```

### 3. **Complex Reporting View**
```sql
CREATE OR REPLACE VIEW view_monthly_payroll_report AS
SELECT 
    p.payroll_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.department_name,
    p.base_salary,
    p.total_deduction,
    p.net_salary,
    ROUND((p.present_days::NUMERIC / p.total_days::NUMERIC) * 100, 2) AS attendance_percentage
FROM payroll p
INNER JOIN employees e ON p.employee_id = e.employee_id
INNER JOIN departments d ON e.department_id = d.department_id;
```

---

## 🎯 Interview Talking Points

1. **Normalized Database Design (3NF)**
   - No redundancy
   - Proper foreign key relationships
   - Atomic values

2. **SQL-Driven Business Logic**
   - Stored procedures for payroll calculation
   - Triggers for automatic validations
   - Views for complex reporting

3. **Data Integrity**
   - CHECK constraints for valid data
   - UNIQUE constraints to prevent duplicates
   - Foreign keys with appropriate CASCADE rules

4. **Performance Optimization**
   - Strategic indexes on frequently queried columns
   - Efficient aggregate queries
   - Connection pooling in backend

5. **Audit Trail**
   - Payroll audit table tracks all changes
   - Timestamps on all records
   - User tracking (CURRENT_USER)

6. **Clean Architecture**
   - Separation of concerns
   - Backend as thin API layer
   - All logic in database

---

## 📊 Sample Test Scenarios

### Test 1: Generate Payroll
```sql
-- Mark attendance for January 2026
-- Generate payroll
CALL sp_generate_monthly_payroll(1, 2026);

-- View results
SELECT * FROM view_monthly_payroll_report WHERE year = 2026 AND month = 1;
```

### Test 2: Attendance Validation
```sql
-- Try to mark future attendance (should fail)
INSERT INTO attendance (employee_id, attendance_date, status)
VALUES (1, '2027-12-31', 'Present');  -- Error: Cannot mark future attendance
```

### Test 3: Duplicate Payroll Prevention
```sql
-- Try to generate payroll twice (should fail on second attempt)
CALL sp_generate_monthly_payroll(1, 2026);  -- Success
CALL sp_generate_monthly_payroll(1, 2026);  -- Error: Payroll already exists
```

---

## 🔒 Business Rules Implemented in SQL

1. **Attendance Rules:**
   - Cannot mark attendance for future dates
   - Absent employees cannot have check-in/check-out times
   - One attendance record per employee per day
   - Check-out time must be after check-in time

2. **Payroll Rules:**
   - One payroll record per employee per month
   - Late deduction: ₹200 per late day
   - Absent deduction: ₹500 per absent day
   - Deductions cannot exceed base salary
   - Net salary auto-calculated by trigger

3. **Employee Rules:**
   - Email must be unique and valid format
   - Base salary must be positive
   - Date of joining cannot be in future
   - Cannot delete department with active employees

---

## 🎓 Learning Outcomes

After reviewing this project, you will understand:
- ✅ How to design normalized database schemas
- ✅ How to implement business logic in SQL
- ✅ How to use stored procedures and functions effectively
- ✅ How to create triggers for automatic data validation
- ✅ How to build complex SQL views for reporting
- ✅ How to use constraints for data integrity
- ✅ How to optimize queries with indexes
- ✅ How to build a clean REST API with raw SQL
- ✅ How to integrate frontend with backend APIs

---

## 🚀 Future Enhancements (Optional)

- [ ] Add authentication and authorization
- [ ] Implement role-based access control (RBAC)
- [ ] Add email notifications for payroll generation
- [ ] Create PDF export for payroll slips
- [ ] Add dashboard with charts and analytics
- [ ] Implement leave management
- [ ] Add overtime calculation
- [ ] Mobile responsive design improvements

---

## 📝 Notes

- **Database-First Approach**: This project emphasizes SQL skills by keeping business logic in the database layer.
- **No ORM Used**: Raw SQL queries using `pg` library to demonstrate SQL proficiency.
- **Production-Ready Patterns**: Uses connection pooling, prepared statements, and proper error handling.
- **Interview-Focused**: Code is clean, well-commented, and follows best practices.

---

## 📧 Contact

**Project Purpose**: SQL Proficiency Demonstration for Cognizant Interview

**Key Skills Demonstrated**:
- Advanced PostgreSQL (Stored Procedures, Triggers, Views, Functions)
- Database Design & Normalization
- Node.js + Express REST API
- Raw SQL Queries (no ORM)
- Frontend Development (HTML/CSS/JavaScript)

---

## 📜 License

This project is created for educational and interview purposes.

---

**Built with ❤️ to showcase SQL proficiency**

*"Let the database do the work"* 🚀
