const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const db = require('./db');
const { initializeDatabase } = require('./init-db');
const { populatePayroll } = require('./populate-payroll');

app.use(cors({
    origin: [
        'http://localhost:3000',
        'http://localhost:8080',
        'https://employee-payroll-attendance-analytics.onrender.com' // This is your frontend URL
    ]
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, '../frontend')));

// Root
app.get('/', (req, res) => res.sendFile(path.join(__dirname, '../frontend/index.html')));

// DEPARTMENTS
app.get('/api/departments', async (req, res) => {
    try {
        const result = await db.query(`SELECT * FROM departments ORDER BY department_name`);
        res.json({ success: true, data: result.rows });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// EMPLOYEES
app.get('/api/employees', async (req, res) => {
    try {
        const result = await db.query(`
            SELECT e.*, d.department_name FROM employees e
            JOIN departments d ON e.department_id = d.department_id
            ORDER BY e.employee_id
        `);
        res.json({ success: true, data: result.rows });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

app.post('/api/employees', async (req, res) => {
    try {
        const { first_name, last_name, email, phone, department_id, designation, base_salary, date_of_joining } = req.body;
        const result = await db.query(
            `INSERT INTO employees (first_name, last_name, email, phone, department_id, designation, base_salary, date_of_joining)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
            [first_name, last_name, email, phone, department_id, designation, base_salary, date_of_joining]
        );
        res.status(201).json({ success: true, data: result.rows[0] });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

app.put('/api/employees/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { first_name, last_name, email, phone, department_id, designation, base_salary, is_active } = req.body;
        const result = await db.query(
            `UPDATE employees SET first_name = $1, last_name = $2, email = $3, phone = $4, department_id = $5, designation = $6, base_salary = $7, is_active = $8 WHERE employee_id = $9 RETURNING *`,
            [first_name, last_name, email, phone, department_id, designation, base_salary, is_active, id]
        );
        res.json({ success: true, data: result.rows[0] });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// ATTENDANCE
app.get('/api/attendance', async (req, res) => {
    try {
        const { employee_id, month, year } = req.query;
        let query = `
            SELECT a.*, e.first_name, e.last_name, d.department_name 
            FROM attendance a
            JOIN employees e ON a.employee_id = e.employee_id
            JOIN departments d ON e.department_id = d.department_id
            WHERE 1=1
        `;
        const params = [];
        
        if (employee_id) {
            query += ` AND a.employee_id = $${params.length + 1}`;
            params.push(employee_id);
        }
        if (month && year) {
            query += ` AND EXTRACT(MONTH FROM a.attendance_date) = $${params.length + 1} AND EXTRACT(YEAR FROM a.attendance_date) = $${params.length + 2}`;
            params.push(month, year);
        }
        query += ` ORDER BY a.attendance_date DESC`;
        
        const result = await db.query(query, params);
        res.json({ success: true, data: result.rows });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

app.post('/api/attendance', async (req, res) => {
    try {
        const { employee_id, attendance_date, status, check_in_time, check_out_time, remarks } = req.body;
        const result = await db.query(
            `INSERT INTO attendance (employee_id, attendance_date, status, check_in_time, check_out_time, remarks)
             VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
            [employee_id, attendance_date, status, check_in_time, check_out_time, remarks]
        );
        res.status(201).json({ success: true, data: result.rows[0] });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// PAYROLL
app.get('/api/payroll', async (req, res) => {
    try {
        let { month, year } = req.query;
        let query = `
            SELECT p.*, e.first_name, e.last_name, e.designation, d.department_name 
            FROM payroll p
            JOIN employees e ON p.employee_id = e.employee_id
            JOIN departments d ON e.department_id = d.department_id
            WHERE 1=1
        `;
        const params = [];
        
        if (month && month !== '') {
            month = parseInt(month);
            if (!isNaN(month)) {
                query += ` AND p.month = $${params.length + 1}`;
                params.push(month);
            }
        }
        if (year && year !== '') {
            year = parseInt(year);
            if (!isNaN(year)) {
                query += ` AND p.year = $${params.length + 1}`;
                params.push(year);
            }
        }
        
        query += ` ORDER BY p.year DESC, p.month DESC`;
        
        const result = await db.query(query, params);
        res.json({ success: true, data: result.rows });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

app.post('/api/payroll/generate', async (req, res) => {
    try {
        let { month, year } = req.body;
        
        // Ensure month and year are integers
        month = parseInt(month);
        year = parseInt(year);
        
        if (isNaN(month) || isNaN(year) || month < 1 || month > 12) {
            return res.status(400).json({ success: false, error: 'Invalid month or year' });
        }
        
        // Calculate payroll for all active employees
        const employees = await db.query('SELECT * FROM employees WHERE is_active = TRUE');
        
        for (const emp of employees.rows) {
            // Check if payroll already exists
            const existing = await db.query(
                'SELECT * FROM payroll WHERE employee_id = $1 AND month = $2 AND year = $3',
                [emp.employee_id, month, year]
            );
            
            if (existing.rows.length > 0) {
                continue; // Skip if already exists
            }
            
            // Get attendance data for the month
            const attendance = await db.query(
                `SELECT status, COUNT(*) as count 
                 FROM attendance 
                 WHERE employee_id = $1 
                 AND EXTRACT(MONTH FROM attendance_date) = $2 
                 AND EXTRACT(YEAR FROM attendance_date) = $3 
                 GROUP BY status`,
                [emp.employee_id, month, year]
            );
            
            let present_days = 0, late_days = 0, absent_days = 0;
            
            attendance.rows.forEach(row => {
                if (row.status === 'Present') present_days = parseInt(row.count);
                if (row.status === 'Late') late_days = parseInt(row.count);
                if (row.status === 'Absent') absent_days = parseInt(row.count);
            });
            
            const total_days = present_days + late_days + absent_days;
            const late_deduction = late_days * 200; // ₹200 per late day
            const absent_deduction = absent_days * 500; // ₹500 per absent day
            const total_deduction = late_deduction + absent_deduction;
            const net_salary = emp.base_salary - total_deduction;
            
            // Insert payroll record
            await db.query(
                `INSERT INTO payroll 
                 (employee_id, month, year, base_salary, total_days, present_days, late_days, absent_days, 
                  late_deduction, absent_deduction, total_deduction, net_salary)
                 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)`,
                [emp.employee_id, month, year, emp.base_salary, total_days, present_days, late_days, 
                 absent_days, late_deduction, absent_deduction, total_deduction, net_salary]
            );
        }
        
        res.json({ success: true, message: 'Payroll generated successfully' });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

app.get('/api/payroll/reports', async (req, res) => {
    try {
        const { month, year } = req.query;
        let query = `SELECT * FROM view_monthly_payroll_report WHERE 1=1`;
        const params = [];
        
        if (month) {
            query += ` AND month = $${params.length + 1}`;
            params.push(month);
        }
        if (year) {
            query += ` AND year = $${params.length + 1}`;
            params.push(year);
        }
        query += ` ORDER BY year DESC, month DESC`;
        
        const result = await db.query(query, params);
        res.json({ success: true, data: result.rows });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

app.get('/api/payroll/department-summary', async (req, res) => {
    try {
        const { month, year } = req.query;
        let query = `SELECT * FROM view_department_payroll_summary WHERE 1=1`;
        const params = [];
        
        if (month) {
            query += ` AND month = $${params.length + 1}`;
            params.push(month);
        }
        if (year) {
            query += ` AND year = $${params.length + 1}`;
            params.push(year);
        }
        query += ` ORDER BY year DESC, month DESC`;
        
        const result = await db.query(query, params);
        res.json({ success: true, data: result.rows });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// ERROR HANDLERS
app.use((req, res) => res.status(404).json({ success: false, message: 'Route not found' }));
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({ success: false, error: err.message });
});

// START SERVER
const server = app.listen(PORT, '0.0.0.0', async () => {
    console.log('✓ Server running on http://localhost:' + PORT);
    
    // Initialize database if needed
    try {
        await initializeDatabase();
        await populatePayroll();
    } catch (err) {
        console.error('Initialization error:', err.message);
    }
});

process.on('SIGTERM', async () => {
    server.close(async () => {
        await db.end();
        process.exit(0);
    });
});

module.exports = app;
