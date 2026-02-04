const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

const pool = new Pool({
    host: 'localhost',
    port: 5432,
    user: 'postgres',
    password: '#Sai1234',
    database: 'payroll_db'
});

async function setupDatabase() {
    try {
        console.log('Starting database setup...');
        
        // Read and execute SQL files in order
        const sqlDir = path.join(__dirname, '../sql');
        const files = ['schema.sql', 'views.sql', 'triggers.sql', 'procedures.sql', 'sample_data.sql'];
        
        for (const file of files) {
            console.log(`\nExecuting ${file}...`);
            const sql = fs.readFileSync(path.join(sqlDir, file), 'utf8');
            
            // Split by semicolon and execute each statement
            const statements = sql.split(';').filter(s => s.trim().length > 0);
            
            for (const statement of statements) {
                try {
                    await pool.query(statement);
                } catch (err) {
                    console.error(`Error in ${file}:`, err.message);
                    // Continue with next statement
                }
            }
            
            console.log(`✓ ${file} completed`);
        }
        
        console.log('\n✓ Database setup completed successfully!');
        await pool.end();
    } catch (error) {
        console.error('Setup failed:', error);
        await pool.end();
        process.exit(1);
    }
}

setupDatabase();
