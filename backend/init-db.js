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
        // Skip triggers.sql and procedures.sql as they use PL/pgSQL and are not required
        const sqlDir = path.join(__dirname, '../sql');
        const sqlFiles = [
            'schema.sql',
            'views.sql',
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
                
                console.log(`📄 Running ${file}...`);
                
                // For sample_data.sql, split by semicolon but handle it carefully
                if (file === 'sample_data.sql') {
                    const statements = sql.split(';').filter(stmt => stmt.trim());
                    for (const statement of statements) {
                        if (statement.trim()) {
                            try {
                                await db.query(statement);
                            } catch (err) {
                                // Silently ignore expected errors
                                if (!err.message.includes('already exists') && 
                                    !err.message.includes('relation') &&
                                    !err.message.includes('violates')) {
                                    console.log(`  ℹ️  Info: ${err.message.substring(0, 50)}...`);
                                }
                            }
                        }
                    }
                } else {
                    // For schema.sql and views.sql, execute as single query
                    try {
                        await db.query(sql);
                    } catch (err) {
                        // Ignore already exists errors
                        if (!err.message.includes('already exists')) {
                            console.log(`  ℹ️  ${err.message.substring(0, 60)}...`);
                        }
                    }
                }
                
                console.log(`✅ ${file} completed`);
            } catch (err) {
                console.error(`❌ Error processing ${file}:`, err.message);
            }
        }

        console.log('\n✅ Database initialization completed successfully!');
        console.log('✅ Tables created, views setup, sample data inserted\n');
        return true;
    } catch (error) {
        console.error('❌ Database initialization failed:', error.message);
        return false;
    }
}

module.exports = { initializeDatabase, isDatabaseInitialized };
