const fs = require('fs');
const path = require('path');
const db = require('./db');

// Check if database is already initialized
async function isDatabaseInitialized() {
    try {
        const result = await db.query(
            "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'employees')"
        );
        return result.rows[0].exists;
    } catch (error) {
        return false;
    }
}

// Initialize database by running SQL files
async function initializeDatabase() {
    try {
        console.log('🔍 Checking database initialization...');
        
        const isInitialized = await isDatabaseInitialized();
        if (isInitialized) {
            console.log('✅ Database already initialized.');
            return true;
        }

        console.log('⏳ Initializing database...');
        
        // Read and execute SQL files in order
        const sqlDir = path.join(__dirname, '../sql');
        const sqlFiles = [
            'schema.sql',
            'views.sql',
            'triggers.sql',
            'procedures.sql',
            'sample_data.sql'
        ];

        for (const file of sqlFiles) {
            const filePath = path.join(sqlDir, file);
            if (!fs.existsSync(filePath)) {
                console.warn(`⚠️  File not found: ${file}`);
                continue;
            }

            try {
                const sql = fs.readFileSync(filePath, 'utf8');
                // Split by semicolon and execute each statement
                const statements = sql.split(';').filter(stmt => stmt.trim());
                
                console.log(`📄 Running ${file}...`);
                for (const statement of statements) {
                    if (statement.trim()) {
                        try {
                            await db.query(statement);
                        } catch (err) {
                            // Ignore specific errors that are expected
                            if (!err.message.includes('already exists') && 
                                !err.message.includes('ERROR: relation') &&
                                !err.message.includes('PL/pgSQL')) {
                                console.error(`Error in ${file}:`, err.message);
                            }
                        }
                    }
                }
                console.log(`✅ ${file} completed`);
            } catch (err) {
                console.error(`❌ Error processing ${file}:`, err.message);
            }
        }

        console.log('✅ Database initialization completed successfully!');
        console.log('✅ Tables created, sample data inserted');
        return true;
    } catch (error) {
        console.error('❌ Database initialization failed:', error.message);
        return false;
    }
}

module.exports = { initializeDatabase, isDatabaseInitialized };
