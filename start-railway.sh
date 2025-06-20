#!/bin/sh

# Exit on any error
set -e

# Set default environment variables for Railway
export NODE_ENV=${NODE_ENV:-production}
export N8N_PORT=${PORT:-5678}
export N8N_HOST=${N8N_HOST:-0.0.0.0}
export N8N_PROTOCOL=${N8N_PROTOCOL:-http}

# Set database to SQLite for Railway if not specified
export DB_TYPE=${DB_TYPE:-sqlite}

# Create data directory if it doesn't exist
mkdir -p /app/data

# Print environment for debugging
echo "=== n8n Railway Startup ==="
echo "Starting n8n with configuration:"
echo "  NODE_ENV: $NODE_ENV"
echo "  N8N_PORT: $N8N_PORT"
echo "  N8N_HOST: $N8N_HOST"
echo "  N8N_PROTOCOL: $N8N_PROTOCOL"
echo "  DB_TYPE: $DB_TYPE"
echo "  PORT (Railway): $PORT"
echo "  PWD: $(pwd)"
echo "=========================="

# Check if the CLI directory exists
if [ ! -d "/app/packages/cli" ]; then
    echo "ERROR: /app/packages/cli directory not found!"
    ls -la /app/
    exit 1
fi

# Check if the built files exist
if [ ! -f "/app/packages/cli/dist/index.js" ]; then
    echo "ERROR: /app/packages/cli/dist/index.js not found! Build may have failed."
    ls -la /app/packages/cli/
    ls -la /app/packages/cli/dist/ || echo "dist directory not found"
    exit 1
fi

# Check Node.js and npm versions
echo "Checking Node.js environment..."
node --version
npm --version

# Set up database directory for SQLite
if [ "$DB_TYPE" = "sqlite" ]; then
    echo "Setting up SQLite database..."
    mkdir -p /app/data
    touch /app/data/database.sqlite
    echo "SQLite database file created at /app/data/database.sqlite"
fi

# Start n8n with better error handling
echo "Starting n8n on port $N8N_PORT..."
cd /app/packages/cli

# Try to use the n8n binary from the CLI package
if [ -f "/app/packages/cli/bin/n8n" ]; then
    echo "Using n8n binary from CLI package..."
    exec /app/packages/cli/bin/n8n start
elif [ -f "/app/packages/cli/dist/index.js" ]; then
    echo "Using n8n from dist directory..."
    exec node dist/index.js start
else
    echo "ERROR: n8n not found in expected locations!"
    echo "Checking available files:"
    ls -la /app/packages/cli/bin/ 2>/dev/null || echo "No bin directory"
    ls -la /app/packages/cli/dist/ 2>/dev/null || echo "No dist directory"
    exit 1
fi
