# Squirtvana PWA - Build & Deployment Guide

Complete guide for building and deploying Squirtvana to production.

## Table of Contents

1. [Development Build](#development-build)
2. [Production Build](#production-build)
3. [Deployment Options](#deployment-options)
4. [Environment Setup](#environment-setup)
5. [Docker Deployment](#docker-deployment)
6. [Troubleshooting](#troubleshooting)

---

## Development Build

### Prerequisites

```bash
# Node.js 18+
node --version

# Python 3.8+
python --version

# npm or pnpm
npm --version
```

### Setup

```bash
# 1. Install frontend dependencies
npm install

# 2. Create .env file
cp .env.example .env

# 3. Add API keys to .env
nano .env

# 4. Install backend dependencies
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Run Development Servers

**Terminal 1 - Frontend:**
```bash
npm run dev
# Available at: http://localhost:5174
```

**Terminal 2 - Backend:**
```bash
source venv/bin/activate
python app.py
# Running on: http://localhost:5000
```

### Hot Reload

- Frontend: Automatic with Vite
- Backend: Restart required (or use flask-reload)

---

## Production Build

### Frontend Build

```bash
# Build optimized production bundle
npm run build

# Output: dist/ directory
# Size: ~100-200KB (gzipped)

# Test production build locally
npm run preview
# Available at: http://localhost:4173
```

### Frontend Optimization

```bash
# Analyze bundle size
npm run build -- --analyze

# Run linter
npm run lint

# Format code
npm run format
```

### Backend Optimization

```bash
# Python code quality
pip install pylint flake8
pylint app.py
flake8 app.py

# Type checking
pip install mypy
mypy app.py
```

---

## Deployment Options

### Option 1: Static Hosting (Recommended for PWA)

#### Vercel (Recommended)

```bash
# Install Vercel CLI
npm install -g vercel

# Build
npm run build

# Deploy
vercel --prod
```

**Benefits:**
- ✅ Free tier available
- ✅ Automatic SSL/HTTPS
- ✅ Global CDN
- ✅ Easy version management

#### Netlify

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Build and deploy
netlify deploy --prod --dir=dist
```

**Benefits:**
- ✅ Free tier
- ✅ Automatic deployments from Git
- ✅ Serverless functions
- ✅ Form handling

#### GitHub Pages

```bash
# Configure for GitHub Pages
# Edit vite.config.js:
# base: '/squirtvana/'

# Build
npm run build

# Deploy (manual)
git add dist/
git commit -m "Deploy to GitHub Pages"
git push origin main
```

### Option 2: Full Stack Deployment

#### Heroku (Discontinued)
Alternative: Railway, Render, or Fly.io

#### Railway

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Deploy
railway up
```

#### Render

1. Connect GitHub repository
2. Set build command: `npm run build && pip install -r requirements.txt`
3. Set start command: `gunicorn app:app`
4. Add environment variables
5. Deploy

### Option 3: Docker Deployment

See [Docker Deployment](#docker-deployment) section below.

---

## Environment Setup

### Production Environment Variables

**Create `.env.production`:**

```env
# Frontend (Vite)
VITE_API_URL=https://your-api-domain.com
VITE_OPENROUTER_KEY=sk-or-v1-xxxxx
VITE_ELEVENLABS_KEY=sk_xxxxx
VITE_ELEVENLABS_VOICE_ID=xxxxx

# Backend (Flask)
FLASK_ENV=production
FLASK_DEBUG=0
SECRET_KEY=your-secret-key-change-this
DATABASE_URL=postgresql://user:pass@host/db

# Security
CORS_ORIGINS=https://your-domain.com,https://www.your-domain.com
```

### Vite Configuration

```javascript
// vite.config.js
export default defineConfig({
  build: {
    outDir: 'dist',
    sourcemap: false,  // Don't expose source in production
    minify: 'terser',
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
        }
      }
    }
  },
  server: {
    proxy: {
      '/api': {
        target: process.env.VITE_API_URL || 'http://localhost:5000',
        changeOrigin: true,
      }
    }
  }
})
```

### Flask Configuration

```python
# app.py
import os
from flask import Flask
from flask_cors import CORS

app = Flask(__name__)

# Configuration
app.config['ENV'] = os.getenv('FLASK_ENV', 'development')
app.config['DEBUG'] = os.getenv('FLASK_DEBUG', '0') == '1'
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-key-change-in-production')

# CORS
cors_origins = os.getenv('CORS_ORIGINS', 'http://localhost:5174').split(',')
CORS(app, resources={r"/api/*": {"origins": cors_origins}})

# Security headers
@app.after_request
def set_security_headers(response):
    response.headers['X-Frame-Options'] = 'SAMEORIGIN'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
    return response
```

---

## Docker Deployment

### Dockerfile

```dockerfile
# Frontend build stage
FROM node:18-alpine AS frontend
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Backend stage
FROM python:3.11-slim
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt gunicorn

# Copy backend
COPY app.py .
COPY .env .env

# Copy frontend build
COPY --from=frontend /app/dist ./static/dist

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:5000/api/health || exit 1

# Expose port
EXPOSE 5000

# Run gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "app:app"]
```

### Docker Compose

```yaml
version: '3.8'

services:
  squirtvana:
    build: .
    ports:
      - "5000:5000"
    environment:
      FLASK_ENV: production
      FLASK_DEBUG: 0
      SECRET_KEY: ${SECRET_KEY}
      VITE_OPENROUTER_KEY: ${VITE_OPENROUTER_KEY}
      VITE_ELEVENLABS_KEY: ${VITE_ELEVENLABS_KEY}
    volumes:
      - ./logs:/app/logs
    restart: unless-stopped
    networks:
      - squirtvana-network

networks:
  squirtvana-network:
    driver: bridge
```

**Build and run:**
```bash
docker-compose up --build -d
```

---

## Performance Optimization

### Frontend

```javascript
// Code splitting
const AIGenerator = React.lazy(() => import('./components/AIGenerator'))

// Image optimization
import { Picture } from 'react-picture'
<Picture src="image.jpg" alt="Description" />

// Service Worker
// Create public/sw.js for offline support
```

### Backend

```python
# Connection pooling
from sqlalchemy import create_engine
engine = create_engine(
    DATABASE_URL,
    pool_size=20,
    max_overflow=40,
    pool_pre_ping=True
)

# Caching
from flask_caching import Cache
cache = Cache(app, config={'CACHE_TYPE': 'redis'})

@app.route('/api/data')
@cache.cached(timeout=300)
def get_data():
    return jsonify({'data': []})
```

### Database

```sql
-- Add indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_streams_user_id ON streams(user_id);

-- Regular maintenance
VACUUM ANALYZE;
```

---

## Monitoring & Logging

### Application Logging

```python
import logging
from logging.handlers import RotatingFileHandler

# Setup logging
if not app.debug:
    file_handler = RotatingFileHandler('app.log', maxBytes=10240000, backupCount=10)
    file_handler.setFormatter(logging.Formatter(
        '%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
    ))
    file_handler.setLevel(logging.INFO)
    app.logger.addHandler(file_handler)
```

### Error Tracking (Sentry)

```python
import sentry_sdk
from sentry_sdk.integrations.flask import FlaskIntegration

sentry_sdk.init(
    dsn="your-sentry-dsn",
    integrations=[FlaskIntegration()],
    traces_sample_rate=0.1
)
```

---

## SSL/HTTPS Setup

### Let's Encrypt (Free)

```bash
# Install Certbot
sudo apt-get install certbot python3-certbot-nginx

# Get certificate
sudo certbot certonly --standalone -d your-domain.com

# Auto-renew
sudo systemctl enable certbot.timer
```

### Nginx Configuration

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

---

## Troubleshooting

### Build Fails

```bash
# Clear cache
rm -rf node_modules package-lock.json dist
npm install
npm run build
```

### Module Not Found

```bash
# Check imports
grep -r "from '\./'" src/

# Verify paths
npm run build -- --reporter=verbose
```

### Deployment Issues

```bash
# Check logs
docker logs container-id

# SSH into server
ssh user@server-ip

# View processes
pm2 list  # If using PM2
```

---

## Performance Metrics

**Target Metrics:**
- ✅ Page Load Time: < 2s
- ✅ First Contentful Paint: < 1s
- ✅ API Response Time: < 200ms
- ✅ Lighthouse Score: > 90

**Check Performance:**
```bash
# Local testing
npm run preview

# Lighthouse
npx lighthouse http://localhost:4173
```

---

## Rollback Plan

```bash
# Keep previous versions tagged
git tag -a v1.0.0 -m "Stable release"

# Rollback if needed
git checkout v1.0.0
npm run build
# Redeploy
```

---

## Security Checklist

- [ ] API keys in environment variables
- [ ] HTTPS/SSL enabled
- [ ] CORS properly configured
- [ ] Security headers set
- [ ] No source maps in production
- [ ] Secrets not in code
- [ ] Database backups enabled
- [ ] Rate limiting configured
- [ ] Input validation enabled
- [ ] CSRF protection enabled

---

## Production Deployment Checklist

- [ ] `.env` configured with production values
- [ ] `npm run build` completes without errors
- [ ] `npm run lint` passes
- [ ] All tests pass
- [ ] Database migrations run
- [ ] HTTPS configured
- [ ] Monitoring/logging setup
- [ ] Backups configured
- [ ] CDN/caching configured
- [ ] Performance tested

---

For questions, check [README.md](./README.md) or GitHub Issues.
