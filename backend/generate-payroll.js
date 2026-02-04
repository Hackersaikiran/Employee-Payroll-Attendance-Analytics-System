const { Pool } = require('pg');

const pool = new Pool({
    host: 'localhost',
    port: 5432,
    user: 'postgres',
    password: '#Sai1234',
    database: 'payroll_db'
});

async function generatePayroll() {
    try {
        const month = 1; // January
        const year = 2026;
        
        console.log(`Generating payroll for ${month}/${year}...`);
        
        // Get all active employees
        const employees = await pool.query('SELECT * FROM employees WHERE is_active = TRUE');
        console.log(`Found ${employees.rows.length} active employees`);
        
        let generated = 0;
        
        for (const emp of employees.rows) {
            try {
                // Check if already exists
                const existing = await pool.query(
                    'SELECT * FROM payroll WHERE employee_id = $1 AND month = $2 AND year = $3',
                    [emp.employee_id, month, year]
                );
                
                if (existing.rows.length > 0) {
                    console.log(`Skipping employee ${emp.employee_id} - record exists`);
                    continue;
                }
                
                // Get attendance data
                const attendance = await pool.query(
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
                const late_deduction = late_days * 200;
                const absent_deduction = absent_days * 500;
                const total_deduction = late_deduction + absent_deduction;
                const net_salary = emp.base_salary - total_deduction;
                
                await pool.query(
                    `INSERT INTO payroll 
                     (employee_id, month, year, base_salary, total_days, present_days, late_days, absent_days, 
                      late_deduction, absent_deduction, total_deduction, net_salary)
                     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)`,
                    [emp.employee_id, month, year, emp.base_salary, total_days, present_days, late_days, 
                     absent_days, late_deduction, absent_deduction, total_deduction, net_salary]
                );
                
                generated++;
                console.log(`✓ Generated payroll for ${emp.first_name} ${emp.last_name}`);
            } catch (err) {
                console.error(`Error for employee ${emp.employee_id}:`, err.message);
            }
        }
        
        console.log(`\n✓ Generated ${generated} payroll records`);
        await pool.end();
    } catch (error) {
        console.error('Error:', error);
        await pool.end();
        process.exit(1);
    }
}

generatePayroll();
