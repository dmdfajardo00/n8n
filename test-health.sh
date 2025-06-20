#!/bin/sh

# Simple health check test script
echo "Testing n8n health check..."

# Wait for the application to start
echo "Waiting for n8n to start..."
sleep 10

# Test the health endpoint
echo "Testing /healthz endpoint..."
if curl -f http://localhost:5678/healthz; then
    echo "✅ Health check passed!"
    exit 0
else
    echo "❌ Health check failed!"
    echo "Checking if n8n is running..."
    ps aux | grep node
    echo "Checking port 5678..."
    netstat -tlnp | grep 5678 || echo "Port 5678 not listening"
    exit 1
fi 