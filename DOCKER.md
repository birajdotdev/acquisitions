# Docker Setup Guide

This guide explains how to run the Acquisitions API using Docker with different configurations for development and production environments.

## Overview

- **Development**: Uses [Neon Local](https://neon.com/docs/local/neon-local) to create ephemeral database branches
- **Production**: Connects directly to Neon Cloud database

## Prerequisites

1. **Docker & Docker Compose** installed on your system
2. **Neon Account** with an existing project
3. **Neon API Key** (get from [Neon Console](https://console.neon.tech))

## Development Environment Setup

### 1. Configure Environment Variables

Copy and update your development environment file:

```bash
cp .env.development .env.development.local
```

Edit `.env.development.local` and replace the placeholder values:

```env
NEON_API_KEY=your_actual_neon_api_key
NEON_PROJECT_ID=your_actual_project_id
PARENT_BRANCH_ID=your_parent_branch_id_or_main_branch_id
ARCJET_KEY=your_development_arcjet_key
```

### 2. Start Development Environment

```bash
# Start all services (Neon Local + App)
docker-compose -f docker-compose.dev.yml --env-file .env.development.local up

# Or run in detached mode
docker-compose -f docker-compose.dev.yml --env-file .env.development.local up -d

# View logs
docker-compose -f docker-compose.dev.yml logs -f
```

### 3. What Happens in Development

1. **Neon Local** container starts and creates a fresh ephemeral branch from your parent branch
2. **Application** container starts with hot-reload enabled
3. App connects to `postgres://neon:npg@neon-local:5432/neondb`
4. When you stop the containers, the ephemeral branch is automatically deleted

### 4. Development Commands

```bash
# Stop services
docker-compose -f docker-compose.dev.yml down

# Rebuild and restart
docker-compose -f docker-compose.dev.yml up --build

# Run database migrations
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Generate new migration
docker-compose -f docker-compose.dev.yml exec app npm run db:generate

# Access app shell
docker-compose -f docker-compose.dev.yml exec app sh
```

## Production Environment Setup

### 1. Configure Environment Variables

Create your production environment file:

```bash
cp .env.production .env.production.local
```

Edit `.env.production.local` with your production values:

```env
DATABASE_URL=postgresql://neondb_owner:your_password@your-endpoint.neon.tech/neondb?sslmode=require
JWT_SECRET=your_very_secure_jwt_secret_here
ARCJET_KEY=your_production_arcjet_key
```

### 2. Start Production Environment

```bash
# Start production service
docker-compose -f docker-compose.prod.yml --env-file .env.production.local up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f app
```

### 3. What Happens in Production

1. **Application** builds optimized production image
2. Runs as non-root user with security hardening
3. Connects directly to your Neon Cloud database
4. Includes health checks and resource limits

### 4. Production Commands

```bash
# Stop production service
docker-compose -f docker-compose.prod.yml down

# Update production deployment
docker-compose -f docker-compose.prod.yml up -d --build

# Run database migrations in production
docker-compose -f docker-compose.prod.yml exec app npm run db:migrate

# Check service health
docker-compose -f docker-compose.prod.yml ps
```

## Environment Variables Reference

### Development (.env.development)
```env
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug
DATABASE_URL=postgres://neon:npg@neon-local:5432/neondb?sslmode=require
JWT_SECRET=dev_jwt_secret_key_change_in_production

# Neon Local Configuration
NEON_API_KEY=your_neon_api_key
NEON_PROJECT_ID=your_neon_project_id
PARENT_BRANCH_ID=your_parent_branch_id

ARCJET_KEY=your_arcjet_dev_key
```

### Production (.env.production)
```env
NODE_ENV=production
PORT=3000
LOG_LEVEL=info
DATABASE_URL=postgresql://neondb_owner:password@endpoint.neon.tech/neondb?sslmode=require
JWT_SECRET=your_secure_jwt_secret
ARCJET_KEY=your_production_arcjet_key
```

## Troubleshooting

### Common Issues

1. **Neon Local connection fails**
   ```bash
   # Check if Neon Local is healthy
   docker-compose -f docker-compose.dev.yml ps
   docker-compose -f docker-compose.dev.yml logs neon-local
   ```

2. **App can't connect to database**
   ```bash
   # Verify network connectivity
   docker-compose -f docker-compose.dev.yml exec app nc -z neon-local 5432
   ```

3. **Permission errors in production**
   ```bash
   # Check container logs
   docker-compose -f docker-compose.prod.yml logs app
   ```

4. **Hot reload not working**
   - Ensure source code is properly mounted in `docker-compose.dev.yml`
   - Check volume mounts: `docker-compose -f docker-compose.dev.yml exec app ls -la /app/src`

### Health Checks

Both environments include health checks:

- **Development**: Checks Neon Local proxy availability
- **Production**: HTTP health check on `/health` endpoint

```bash
# Check health status
docker-compose -f docker-compose.dev.yml ps    # Development
docker-compose -f docker-compose.prod.yml ps   # Production
```

## Best Practices

1. **Never commit actual API keys** - Use `.local` files for real credentials
2. **Use ephemeral branches** in development to avoid database conflicts
3. **Run migrations** before deploying production changes
4. **Monitor logs** in production for performance issues
5. **Backup production data** regularly

## Docker Architecture

### Multi-stage Dockerfile
- **Base**: Common Node.js setup
- **Development**: Includes dev dependencies, enables hot-reload
- **Production**: Optimized, security-hardened, minimal dependencies

### Networking
Both environments use isolated Docker networks for security.

### Volumes
- **Development**: Source code mounted for hot-reload
- **Production**: No external volumes for security

## Integration with CI/CD

### GitHub Actions Example
```yaml
# Build and test
- name: Build Docker image
  run: docker build -t acquisitions-app .

# Deploy to production
- name: Deploy to production
  run: |
    docker-compose -f docker-compose.prod.yml --env-file .env.production.local up -d --build
```

For questions or issues, refer to the [Neon Local documentation](https://neon.com/docs/local/neon-local).