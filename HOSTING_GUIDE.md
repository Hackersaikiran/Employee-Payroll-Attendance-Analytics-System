# Employee Payroll & Attendance System - Hosting Guide

## Overview
This application consists of:
- **Frontend**: Static HTML, CSS, JavaScript
- **Backend**: Node.js + Express server
- **Database**: PostgreSQL

---

## Option 1: Render (Recommended for Beginners)

### Why Render?
- Free tier available
- Easy deployment from GitHub
- Automatic PostgreSQL database hosting
- SSL certificate included
- Simple environment variables

### Step-by-Step Guide:

#### 1. Prepare Your Repository
```bash
# If not already in git, initialize it
cd d:\projects\Employee payroll and attendance analytics system
git init
git add .
git commit -m "Initial commit"
```

#### 2. Push to GitHub
```bash
# Create a new repository on GitHub (https://github.com/new)
# Then run:
git remote add origin https://github.com/YOUR_USERNAME/payroll-system.git
git branch -M main
git push -u origin main
```

#### 3. Create PostgreSQL Database on Render
1. Go to https://render.com
2. Sign up with GitHub account
3. Click "New +" → "PostgreSQL"
4. Choose a name: `payroll-db`
5. Select Free tier
6. Create database
7. Copy the **Internal Database URL** (save it)

#### 4. Deploy Backend on Render
1. Click "New +" → "Web Service"
2. Connect your GitHub repository
3. Enter settings:
   - **Name**: `payroll-system-api`
   - **Environment**: Node
   - **Build Command**: `cd backend && npm install`
   - **Start Command**: `cd backend && node server.js`
   - **Auto-deploy**: Yes

4. Add Environment Variables:
   - Click "Add Environment Variable"
   - Add:
     ```
     DATABASE_URL = your_postgres_url_from_step_3
     PORT = 3000
     NODE_ENV = production
     ```

#### 5. Update Backend Code for Production
Edit `backend/db.js`:

```javascript
const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

module.exports = pool;
```

Edit `backend/server.js` - Update CORS:
```javascript
app.use(cors({
    origin: [
        'http://localhost:3000',
        'http://localhost:8080',
        'https://your-render-domain.onrender.com' // Add your deployed URL
    ]
}));
```

#### 6. Deploy Frontend on Render
1. Click "New +" → "Static Site"
2. Connect your GitHub repository
3. Enter settings:
   - **Name**: `payroll-system-web`
   - **Build Command**: (leave empty)
   - **Publish Directory**: `frontend`

4. Add Environment Variable:
   - After deployment, edit `frontend/js/app.js`
   - Change `API_BASE_URL` to your backend URL:
   ```javascript
   const API_BASE_URL = 'https://payroll-system-api.onrender.com/api';
   ```

#### 7. Initialize Database on Render
1. From Render dashboard, find your Web Service
2. Go to "Shell" tab
3. Run:
```bash
cd backend
node backend/setup.js
```

This will run all SQL scripts to create tables and sample data.

---

## Option 2: DigitalOcean (More Control & Better Performance)

### Step-by-Step Guide:

#### 1. Create a DigitalOcean Account
- Sign up at https://www.digitalocean.com
- Add payment method

#### 2. Create a Droplet (Virtual Server)
1. Click "Create" → "Droplets"
2. Select:
   - **Image**: Ubuntu 22.04 LTS
   - **Size**: Basic ($6/month)
   - **Region**: Nearest to you
   - **SSH Key**: Add your SSH key or use password
3. Create Droplet

#### 3. Create PostgreSQL Database
1. Click "Create" → "Databases"
2. Select PostgreSQL 14
3. Choose region same as Droplet
4. Create database

#### 4. Connect to Droplet via SSH
```bash
ssh root@YOUR_DROPLET_IP
```

#### 5. Install Dependencies
```bash
# Update system
apt update && apt upgrade -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt install -y nodejs

# Install PM2 (process manager)
npm install -g pm2

# Install Nginx (web server)
apt install -y nginx

# Install Git
apt install -y git
```

#### 6. Clone Your Repository
```bash
cd /var/www
git clone https://github.com/YOUR_USERNAME/payroll-system.git
cd payroll-system
```

#### 7. Setup Backend
```bash
cd backend
npm install
```

#### 8. Create Environment File
```bash
cat > .env << EOF
DATABASE_URL=postgresql://USERNAME:PASSWORD@DATABASE_HOST:5432/DBNAME
PORT=3000
NODE_ENV=production
EOF
```

#### 9. Start Backend with PM2
```bash
pm2 start server.js --name "payroll-api"
pm2 startup
pm2 save
```

#### 10. Configure Nginx
Edit `/etc/nginx/sites-available/default`:

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name yourdomain.com www.yourdomain.com;

    # Frontend (Static files)
    location / {
        root /var/www/payroll-system/frontend;
        try_files $uri /index.html;
    }

    # Backend API
    location /api {
        proxy_pass http://localhost:3000/api;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Restart Nginx:
```bash
systemctl restart nginx
```

#### 11. Setup SSL Certificate (Let's Encrypt)
```bash
apt install -y certbot python3-certbot-nginx
certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

---

## Option 3: Heroku (Legacy but Still Works)

### Prerequisites:
- Heroku account (https://www.heroku.com)
- Heroku CLI installed

### Steps:
```bash
# Login to Heroku
heroku login

# Create app
heroku create payroll-system

# Add PostgreSQL
heroku addons:create heroku-postgresql:hobby-dev

# Push code
git push heroku main

# Run migrations
heroku run "cd backend && node backend/setup.js"

# View logs
heroku logs --tail
```

---

## Domain Setup

### For Any Hosting Provider:

1. **Buy a Domain** (if you don't have one):
   - Namecheap
   - GoDaddy
   - Google Domains

2. **Point Domain to Your Host**:
   - Update DNS settings in domain registrar
   - Add `A` record pointing to your server IP
   - Add `CNAME` record for www subdomain

3. **Update API URL in Frontend**:
   - Edit `frontend/js/app.js`
   - Change: `const API_BASE_URL = 'https://yourdomain.com/api';`

---

## Post-Deployment Checklist

- [ ] Database is accessible from server
- [ ] Environment variables are set correctly
- [ ] SSL certificate is installed
- [ ] Frontend loads successfully
- [ ] API endpoints respond
- [ ] All CRUD operations work
- [ ] Filters and search functionality work
- [ ] Payroll generation works
- [ ] Database backups are configured

---

## Environment Variables Required

```
DATABASE_URL=postgresql://user:password@host:5432/dbname
PORT=3000
NODE_ENV=production
CORS_ORIGIN=https://yourdomain.com
```

---

## Troubleshooting

### Backend won't start:
```bash
# Check logs
npm start

# Test database connection
psql $DATABASE_URL
```

### Frontend can't reach API:
- Check CORS settings in `server.js`
- Verify `API_BASE_URL` in `app.js` is correct
- Check network tab in browser DevTools

### Database errors:
- Verify connection string format
- Check database exists
- Run: `node backend/setup.js`

---

## Recommended Setup Summary

For production use, I recommend:

**Best Option: Render**
- Pros: Free tier, easy, integrated PostgreSQL, GitHub auto-deploy
- Cost: Free-$10/month
- Time to deploy: 15 minutes

**Best Value: DigitalOcean**
- Pros: Full control, good performance, cheap
- Cost: $6-12/month
- Time to deploy: 45 minutes

**Enterprise: AWS**
- Pros: Scalable, feature-rich
- Cost: $10-50/month
- Time to deploy: 2 hours

---

## Support & Documentation

- Render: https://render.com/docs
- DigitalOcean: https://docs.digitalocean.com
- Node.js: https://nodejs.org/docs
- PostgreSQL: https://www.postgresql.org/docs
- Express: https://expressjs.com/en/4x/api.html
