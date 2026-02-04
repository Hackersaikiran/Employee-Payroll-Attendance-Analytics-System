# How to Update Database with New Data in pgAdmin

## Step-by-Step Instructions

### Prerequisites
- pgAdmin installed and running
- PostgreSQL database server running
- Connected to your `payroll_db` database

---

## Method 1: Using pgAdmin Query Editor (RECOMMENDED)

### Step 1: Open pgAdmin
- Open pgAdmin in your browser (usually http://localhost:5050)
- Login with your credentials

### Step 2: Navigate to Query Editor
1. In the left sidebar, expand your PostgreSQL server
2. Expand "Databases"
3. Click on `payroll_db` to select it
4. Go to **Tools** menu → **Query Tool** (or press Alt+Shift+Q)

### Step 3: Run SQL Files in Order

The files should be executed in this specific order:

#### **File 1: schema.sql** (Only if starting fresh)
- Path: `sql/schema.sql`
- **Action**: Paste the entire contents into the Query Editor
- Click **Execute** (Run button or F5)
- **Expected Output**: Tables created successfully

#### **File 2: sample_data.sql** (NEW - Updated with more data)
- Path: `sql/sample_data.sql`
- **Action**: Paste the entire contents into the Query Editor
- Click **Execute** (Run button or F5)
- **Expected Output**: 
  - Database cleared and reset
  - 21 employees inserted (5 more than before)
  - 7 departments created
  - 4 months of attendance data (October 2025 - January 2026)
  - Payroll records for all 4 months

---

## Method 2: Using Command Line (If Schema Already Exists)

If you only want to update the data without recreating schema:

```bash
# Connect to PostgreSQL
psql -U postgres -d payroll_db -f sql/sample_data.sql
```

---

## What's New in the Updated sample_data.sql?

### New Data Added:
✅ **More Employees**: Increased from 12 to 21 employees
✅ **More Departments**: 7 departments (was 5)
✅ **Multi-Month Attendance**: Oct, Nov, Dec 2025 + Jan 2026
✅ **Payroll Records**: 4 months × 21 employees = 84 payroll records
✅ **Realistic Patterns**: Varied attendance (Present, Late, Absent)

### Data Coverage:
- **Months**: October, November, December 2025, January 2026
- **Attendance Records**: ~1,800+ records across all employees
- **Payroll Records**: 84 records (4 months × 21 employees)
- **Departments**: 7 departments with proper distribution

---

## Expected Results After Running sample_data.sql

After executing, you should see:

```
✓ Sample data inserted successfully!
total_departments | 7
total_employees | 21
total_attendance_records | 1800+
total_payroll_records | 84
```

---

## Filters That Will Now Work Accurately

With this comprehensive data, the following filters will work properly:

### **Attendance Filters**
- Filter by Month: October, November, December 2025, January 2026
- Filter by Year: 2025, 2026
- Filter by Employee: All 21 employees have attendance data
- Filter by Department: All 7 departments represented

### **Payroll Filters**
- Filter by Month: October, November, December 2025, January 2026
- Filter by Year: 2025, 2026
- Filter by Employee: All 21 employees have payroll records
- Different salary deductions based on attendance

### **Department View**
- All 7 departments with employees assigned
- Proper location information

---

## Troubleshooting

### Error: "Duplicate key value violates unique constraint"
- **Solution**: The data might already exist. This is normal if running twice.
- The script includes TRUNCATE to clear old data first.

### Error: "Column does not exist"
- **Solution**: Make sure `schema.sql` was run first to create tables
- Run `sql/schema.sql` before `sql/sample_data.sql`

### No data appearing in filters
- **Solution**: Run the script and wait for it to complete
- Then refresh the browser and clear browser cache
- Navigate to Employees tab to verify data loaded

### Error: "relation does not exist"
- **Solution**: Make sure database `payroll_db` exists
- Check that you're connected to the correct database in pgAdmin

---

## File Locations

All SQL files are in: `sql/` folder
- `sql/schema.sql` - Creates all tables (run once)
- `sql/sample_data.sql` - Inserts comprehensive data (run for updates)
- `sql/views.sql` - Creates views (optional)
- `sql/triggers.sql` - Creates triggers (optional)
- `sql/procedures.sql` - Creates procedures (optional)

---

## Quick Summary

| Step | File | Action | Expected Result |
|------|------|--------|-----------------|
| 1 | schema.sql | Execute in pgAdmin | All tables created |
| 2 | sample_data.sql | Execute in pgAdmin | 21 employees, 7 departments, 4 months data |
| 3 | Refresh browser | F5 or Ctrl+R | All filters work, data displays |

---

## After Running - Test the Application

1. Go to http://localhost:3000
2. Navigate to each tab:
   - ✅ Employees: Should show 21 employees
   - ✅ Departments: Should show 7 departments
   - ✅ Attendance: Should show attendance for Oct-Jan
   - ✅ Payroll: Should show payroll for Oct-Jan

3. Test filters:
   - Try filtering attendance by different months
   - Try filtering payroll by 2025 vs 2026
   - Try different departments

**All filters should now work accurately with sufficient data!**
