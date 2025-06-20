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
echo "Starting n8n with configuration:"
echo "  NODE_ENV: $NODE_ENV"
echo "  N8N_PORT: $N8N_PORT"
echo "  N8N_HOST: $N8N_HOST"
echo "  N8N_PROTOCOL: $N8N_PROTOCOL"
echo "  DB_TYPE: $DB_TYPE"

# Check if the CLI directory exists
if [ ! -d "/app/packages/cli" ]; then
    echo "ERROR: /app/packages/cli directory not found!"
    exit 1
fi

# Check if the built files exist
if [ ! -f "/app/packages/cli/dist/index.js" ]; then
    echo "ERROR: /app/packages/cli/dist/index.js not found! Build may have failed."
    exit 1
fi

# Start n8n
echo "Starting n8n on port $N8N_PORT..."
cd /app/packages/cli
exec node dist/index.js start 