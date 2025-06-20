# Railway Deployment Troubleshooting Guide

## Problem: Health Check Failing

If you're experiencing health check failures on Railway, follow these troubleshooting steps:

### 1. Check Railway Logs

First, check the Railway logs to see what's happening during startup:

```bash
railway logs
```

Look for any error messages, especially:
- Database connection errors
- Port binding issues
- Missing dependencies
- Build failures

### 2. Common Issues and Solutions

#### Issue: Application Not Starting
**Symptoms**: Health check fails with "service unavailable"
**Solution**: 
- Check if the build completed successfully
- Verify that `/app/packages/cli/dist/index.js` exists
- Ensure all dependencies are installed

#### Issue: Port Configuration
**Symptoms**: Application starts but health check fails
**Solution**:
- Railway sets the `PORT` environment variable
- The application should use `PORT` instead of hardcoded `5678`
- Check that `N8N_PORT=${PORT:-5678}` is set correctly

#### Issue: Database Connection
**Symptoms**: Application starts but database initialization fails
**Solution**:
- For SQLite: Ensure `/app/data` directory exists and is writable
- For PostgreSQL: Check connection credentials and network access
- Verify database migrations can run

#### Issue: Memory/Resource Limits
**Symptoms**: Application crashes or fails to start
**Solution**:
- Railway has memory limits that might be exceeded
- Check if the application needs more resources
- Consider using a larger Railway plan

### 3. Debugging Scripts

The following scripts are included in the Docker image for debugging:

#### Environment Check
```bash
# Run inside the container
./env-check.sh
```

#### Health Check
```bash
# Run inside the container
./health-check.sh
```

#### Test Health Endpoint
```bash
# Run inside the container
./test-health.sh
```

### 4. Manual Testing

To manually test the deployment:

1. **SSH into the Railway container**:
   ```bash
   railway shell
   ```

2. **Check if the application is running**:
   ```bash
   ps aux | grep node
   ```

3. **Check if the port is listening**:
   ```bash
   netstat -tlnp | grep 5678
   ```

4. **Test the health endpoint**:
   ```bash
   curl http://localhost:5678/healthz
   ```

5. **Check application logs**:
   ```bash
   tail -f /app/logs/n8n.log
   ```

### 5. Environment Variables

Ensure these environment variables are set correctly in Railway:

```bash
# Required
NODE_ENV=production
DB_TYPE=sqlite  # or postgresdb

# Optional but recommended
N8N_HOST=0.0.0.0
N8N_PROTOCOL=http

# For PostgreSQL
DB_POSTGRESDB_HOST=your-postgres-host
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=your-user
DB_POSTGRESDB_PASSWORD=your-password
```

### 6. Railway Configuration

The `railway.json` file should contain:

```json
{
  "build": {
    "builder": "DOCKERFILE",
    "dockerfilePath": "Dockerfile"
  },
  "deploy": {
    "startCommand": "/app/start-railway.sh",
    "healthcheckPath": "/healthz",
    "healthcheckTimeout": 300,
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10,
    "healthcheckInterval": 30,
    "healthcheckRetries": 5
  }
}
```

### 7. Alternative Solutions

If the Alpine-based Dockerfile continues to have issues:

1. **Use the alternative Dockerfile**:
   ```bash
   # Update railway.json
   "dockerfilePath": "Dockerfile.alternative"
   ```

2. **Use a different base image**:
   - Switch to `node:22-slim` (Debian-based)
   - Avoid musl compatibility issues

3. **Use Railway's native deployment**:
   - Remove Dockerfile
   - Use Railway's built-in Node.js support
   - Set build command: `pnpm install && pnpm run build`
   - Set start command: `cd packages/cli && node dist/index.js start`

### 8. Getting Help

If you're still experiencing issues:

1. Check the [n8n documentation](https://docs.n8n.io/)
2. Check the [Railway documentation](https://docs.railway.app/)
3. Look for similar issues in the [n8n GitHub repository](https://github.com/n8n-io/n8n)
4. Check the [Railway community](https://community.railway.app/)

### 9. Health Check Endpoints

n8n provides two health check endpoints:

- `/healthz` - Basic health check (always returns 200 if server is running)
- `/healthz/readiness` - Readiness check (returns 200 only when database is connected and migrated)

Railway uses `/healthz` for health checks, which should always be available once the server starts. 