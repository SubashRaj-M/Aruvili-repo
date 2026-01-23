# Deployment Guide for Frappe LMS

This guide explains how to deploy Frappe LMS using Vercel (frontend) and Render (backend).

## Architecture

- **Frontend**: Vue.js application deployed on Vercel
- **Backend**: Frappe Framework Python application deployed on Render
- **Database**: PostgreSQL on Render
- **Cache**: Redis on Render

## Prerequisites

1. GitHub account with this repository
2. Vercel account (free tier works)
3. Render account (free tier works for testing)

## Step 1: Deploy Backend on Render

### 1.1 Create Database Service

1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click "New +" → "PostgreSQL"
3. Configure:
   - **Name**: `frappe-lms-db`
   - **Database**: `frappe_lms`
   - **User**: `frappe_user`
   - **Plan**: Starter (free tier)
4. Click "Create Database"
5. Note down the connection details (you'll need them later)

### 1.2 Create Redis Service

1. Click "New +" → "Redis"
2. Configure:
   - **Name**: `frappe-lms-redis`
   - **Plan**: Starter (free tier)
3. Click "Create Redis"
4. Note the connection string

### 1.3 Deploy Web Service

**Option A: Using render.yaml (Recommended)**

1. Click "New +" → "Blueprint"
2. Connect your GitHub repository
3. Render will automatically detect `render.yaml` and configure services
4. Review and deploy

**Option B: Manual Configuration**

1. Click "New +" → "Web Service"
2. Connect your GitHub repository
3. Configure:
   - **Name**: `frappe-lms-backend`
   - **Environment**: Python 3
   - **Build Command**: 
     ```bash
     pip install --upgrade pip && pip install frappe-bench && bench init --skip-redis-config-check --skip-mariadb-setup --frappe-branch version-15 frappe-bench && cd frappe-bench && bench get-app lms https://github.com/frappe/lms && bench new-site $SITE_NAME --no-mariadb-socket --admin-password $ADMIN_PASSWORD --db-host $DB_HOST --db-port $DB_PORT --db-name $DB_NAME --db-username $DB_USERNAME --db-password $DB_PASSWORD && bench --site $SITE_NAME install-app lms && bench build --app lms
     ```
   - **Start Command**: 
     ```bash
     cd frappe-bench && bench --site $SITE_NAME serve --host 0.0.0.0 --port $PORT
     ```
4. Add Environment Variables:
   - `SITE_NAME`: Your site name (e.g., `lms.example.com`)
   - `ADMIN_PASSWORD`: Admin password for Frappe
   - `DB_HOST`: From PostgreSQL service (auto-linked)
   - `DB_PORT`: From PostgreSQL service (auto-linked)
   - `DB_NAME`: From PostgreSQL service (auto-linked)
   - `DB_USERNAME`: From PostgreSQL service (auto-linked)
   - `DB_PASSWORD`: From PostgreSQL service (auto-linked)
   - `REDIS_URL`: From Redis service (auto-linked)
   - `PYTHON_VERSION`: `3.10.12`
5. Click "Create Web Service"

**Note**: The first build will take 10-15 minutes as it installs Frappe and all dependencies.

### 1.4 Get Backend URL

Once deployed, note your Render service URL (e.g., `https://frappe-lms-backend.onrender.com`)

## Step 2: Deploy Frontend on Vercel

### 2.1 Connect Repository

1. Go to [Vercel Dashboard](https://vercel.com/dashboard)
2. Click "Add New..." → "Project"
3. Import your GitHub repository
4. Configure:
   - **Framework Preset**: Other
   - **Root Directory**: `./` (root)
   - **Build Command**: `cd frontend && yarn install && yarn build`
   - **Output Directory**: `frontend/dist`
   - **Install Command**: `yarn install`

### 2.2 Configure Environment Variables

Add the following environment variable:
- `VITE_FRAPPE_API_URL`: Your Render backend URL (e.g., `https://frappe-lms-backend.onrender.com`)

**Important**: Make sure to include the protocol (`https://`) and do not include a trailing slash.

### 2.3 Configure Build Settings

In Vercel project settings:
- **Root Directory**: Leave as root (`./`)
- **Build Command**: `cd frontend && yarn install && yarn build`
- **Output Directory**: `frontend/dist`
- **Install Command**: `yarn install`

### 2.4 Deploy

Click "Deploy" and wait for the build to complete.

## Step 3: Configure CORS and Allowed Hosts

### 3.1 Update Backend Configuration

After the backend is deployed, you need to configure CORS and allowed hosts:

1. Go to your Render service dashboard
2. Click on "Shell" to open a terminal
3. Run the following commands:
   ```bash
   cd frappe-bench
   bench --site $SITE_NAME set-config cors_origin "*"
   bench --site $SITE_NAME set-config allow_cors "*"
   bench --site $SITE_NAME set-config allowed_hosts "['your-vercel-domain.vercel.app', 'your-custom-domain.com']"
   ```
   
   Replace `your-vercel-domain.vercel.app` with your actual Vercel deployment URL.

**Alternative**: You can also add these as environment variables in Render:
- `CORS_ORIGIN`: `*`
- `ALLOW_CORS`: `*`
- `ALLOWED_HOSTS`: `['your-vercel-domain.vercel.app']`

### 3.2 Update Frontend Environment Variable

1. Go to Vercel dashboard → Your Project → Settings → Environment Variables
2. Update `VITE_FRAPPE_API_URL` to your Render backend URL (e.g., `https://frappe-lms-backend.onrender.com`)
3. Redeploy the frontend for changes to take effect

## Step 4: Custom Domain (Optional)

### 4.1 Backend Domain

1. In Render dashboard, go to your web service
2. Click "Settings" → "Custom Domain"
3. Add your domain and configure DNS

### 4.2 Frontend Domain

1. In Vercel dashboard, go to your project
2. Click "Settings" → "Domains"
3. Add your domain and configure DNS

## Troubleshooting

### Backend Issues

- **Build fails**: Check Python version (should be 3.10.12)
- **Database connection fails**: Verify database credentials in environment variables
- **Site creation fails**: Ensure all database environment variables are set correctly

### Frontend Issues

- **API calls fail**: Verify `VITE_FRAPPE_API_URL` is set correctly
- **CORS errors**: Update backend CORS configuration
- **Build fails**: Check Node.js version (should be 18+)

### Common Commands

**Render Shell**:
```bash
cd frappe-bench
bench --site $SITE_NAME console
```

**Check logs**:
- Render: Dashboard → Service → Logs
- Vercel: Dashboard → Project → Deployments → View Function Logs

## Environment Variables Reference

### Backend (Render)
- `SITE_NAME`: Frappe site name
- `ADMIN_PASSWORD`: Admin user password
- `DB_HOST`: PostgreSQL host
- `DB_PORT`: PostgreSQL port
- `DB_NAME`: Database name
- `DB_USERNAME`: Database username
- `DB_PASSWORD`: Database password
- `REDIS_URL`: Redis connection string
- `PYTHON_VERSION`: Python version (3.10.12)

### Frontend (Vercel)
- `VITE_FRAPPE_API_URL`: Backend API URL

## Notes

- The first deployment will take longer (10-15 minutes for backend)
- Free tier services may spin down after inactivity
- Consider upgrading to paid plans for production use
- Monitor resource usage on both platforms

## Support

For issues specific to:
- **Frappe LMS**: [GitHub Issues](https://github.com/frappe/lms/issues)
- **Vercel**: [Vercel Documentation](https://vercel.com/docs)
- **Render**: [Render Documentation](https://render.com/docs)
