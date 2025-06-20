#!/bin/sh

# Environment check script for n8n Railway deployment
echo "=== n8n Environment Check ==="

# Check Railway-specific environment variables
echo "Railway Environment Variables:"
echo "  PORT: $PORT"
echo "  RAILWAY_STATIC_URL: $RAILWAY_STATIC_URL"
echo "  RAILWAY_PUBLIC_DOMAIN: $RAILWAY_PUBLIC_DOMAIN"

# Check n8n-specific environment variables
echo ""
echo "n8n Environment Variables:"
echo "  NODE_ENV: $NODE_ENV"
echo "  N8N_PORT: $N8N_PORT"
echo "  N8N_HOST: $N8N_HOST"
echo "  N8N_PROTOCOL: $N8N_PROTOCOL"
echo "  DB_TYPE: $DB_TYPE"

# Check database-specific environment variables
echo ""
echo "Database Environment Variables:"
echo "  DB_SQLITE_DATABASE: $DB_SQLITE_DATABASE"
echo "  DB_POSTGRESDB_HOST: $DB_POSTGRESDB_HOST"
echo "  DB_POSTGRESDB_PORT: $DB_POSTGRESDB_PORT"
echo "  DB_POSTGRESDB_DATABASE: $DB_POSTGRESDB_DATABASE"

# Check system information
echo ""
echo "System Information:"
echo "  Current directory: $(pwd)"
echo "  Node.js version: $(node --version)"
echo "  npm version: $(npm --version)"
echo "  Available memory: $(free -h 2>/dev/null | grep Mem | awk '{print $2}' || echo 'Unknown')"

# Check file system
echo ""
echo "File System Check:"
echo "  /app exists: $([ -d /app ] && echo 'Yes' || echo 'No')"
echo "  /app/packages/cli exists: $([ -d /app/packages/cli ] && echo 'Yes' || echo 'No')"
echo "  /app/packages/cli/dist/index.js exists: $([ -f /app/packages/cli/dist/index.js ] && echo 'Yes' || echo 'No')"
echo "  /app/data exists: $([ -d /app/data ] && echo 'Yes' || echo 'No')"

echo "=== Environment check completed ===" 