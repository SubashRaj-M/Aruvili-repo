# Quick Start Deployment Guide

## TL;DR - Deploy in 15 minutes

### Backend (Render)

1. **Create PostgreSQL Database**
   - Render Dashboard → New → PostgreSQL
   - Name: `frappe-lms-db`
   - Plan: Starter

2. **Create Redis**
   - Render Dashboard → New → Redis  
   - Name: `frappe-lms-redis`
   - Plan: Starter

3. **Deploy Web Service**
   - Render Dashboard → New → Web Service
   - Connect GitHub repo
   - Use `render.yaml` OR manually configure:
     - **Build Command**: See `render.yaml` for details
     - **Start Command**: `cd frappe-bench && bench --site $SITE_NAME serve --host 0.0.0.0 --port $PORT`
   - Set environment variables (see `render.yaml`)

### Frontend (Vercel)

1. **Import Project**
   - Vercel Dashboard → Add New → Project
   - Import GitHub repo

2. **Configure**
   - Root Directory: `./`
   - Build Command: `cd frontend && yarn install && yarn build`
   - Output Directory: `frontend/dist`
   - Environment Variable: `VITE_FRAPPE_API_URL` = Your Render backend URL

3. **Deploy**
   - Click Deploy

### Connect Them

1. Update `VITE_FRAPPE_API_URL` in Vercel with your Render URL
2. Configure CORS in Render backend (see DEPLOYMENT.md Step 3)

**Full details**: See [DEPLOYMENT.md](./DEPLOYMENT.md)
