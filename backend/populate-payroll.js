const db = require('./db');

// Function to populate payroll data directly from attendance
async function populatePayroll() {
    try {
        console.log('📊 Populating payroll data...');
        
        // Check if payroll already has data
        const existingCount = await db.query('SELECT COUNT(*) as count FROM payroll');
        if (existingCount.rows[0].count > 0) {
            console.log('✅ Payroll data already exists');
            return true;
        }

        // Get all unique month/year combinations from attendance
        const monthYears = await db.query(`
            SELECT DISTINCT 
                EXTRACT(MONTH FROM attendance_date) as month,
                EXTRACT(YEAR FROM attendance_date) as year
            FROM attendance
            ORDER BY year DESC, month DESC
        `);

        console.log(`Found ${monthYears.rows.length} months of attendance data`);

        // For each month/year, calculate and insert payroll for all employees
        for (const my of monthYears.rows) {
            const month = parseInt(my.month);
            const year = parseInt(my.year);

            console.log(`  Processing ${month}/${year}...`);

            // Get all employees
            const employees = await db.query('SELECT * FROM employees WHERE is_active = TRUE');

            for (const emp of employees.rows) {
                // Check if payroll already exists
                const existing = await db.query(
                    'SELECT * FROM payroll WHERE employee_id = $1 AND month = $2 AND year = $3',
                    [emp.employee_id, month, year]
                );

                if (existing.rows.length > 0) continue;

                // Get attendance data
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
                const late_deduction = late_days * 200;
                const absent_deduction = absent_days * 500;
                const total_deduction = late_deduction + absent_deduction;
                const net_salary = emp.base_salary - total_deduction;

                // Insert payroll
                await db.query(
                    `INSERT INTO payroll 
                     (employee_id, month, year, base_salary, total_days, present_days, late_days, absent_days, 
                      late_deduction, absent_deduction, total_deduction, net_salary)
                     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)`,
                    [emp.employee_id, month, year, emp.base_salary, total_days, present_days, late_days, 
                     absent_days, late_deduction, absent_deduction, total_deduction, net_salary]
                );
            }
        }

        const finalCount = await db.query('SELECT COUNT(*) as count FROM payroll');
        console.log(`✅ Payroll population complete! Total records: ${finalCount.rows[0].count}`);
        return true;
    } catch (error) {
        console.error('❌ Error populating payroll:', error.message);
        return false;
    }
}

module.exports = { populatePayroll };
