#!/bin/sh

# Health check script for n8n Railway deployment
echo "=== n8n Health Check ==="

# Check if n8n process is running
echo "1. Checking if n8n process is running..."
if pgrep -f "node.*dist/index.js" > /dev/null; then
    echo "✅ n8n process is running"
else
    echo "❌ n8n process is not running"
    echo "Process list:"
    ps aux | grep node || echo "No node processes found"
    exit 1
fi

# Check if port is listening
echo "2. Checking if port 5678 is listening..."
if netstat -tlnp 2>/dev/null | grep :5678 > /dev/null; then
    echo "✅ Port 5678 is listening"
else
    echo "❌ Port 5678 is not listening"
    echo "Listening ports:"
    netstat -tlnp 2>/dev/null || echo "netstat not available"
    exit 1
fi

# Test health endpoint
echo "3. Testing /healthz endpoint..."
if curl -f -s http://localhost:5678/healthz > /dev/null; then
    echo "✅ Health endpoint is responding"
    echo "Response:"
    curl -s http://localhost:5678/healthz
else
    echo "❌ Health endpoint is not responding"
    echo "Trying with verbose output:"
    curl -v http://localhost:5678/healthz || echo "curl failed"
    exit 1
fi

# Test readiness endpoint
echo "4. Testing /healthz/readiness endpoint..."
if curl -f -s http://localhost:5678/healthz/readiness > /dev/null; then
    echo "✅ Readiness endpoint is responding"
    echo "Response:"
    curl -s http://localhost:5678/healthz/readiness
else
    echo "⚠️  Readiness endpoint is not responding (this might be normal during startup)"
    echo "Trying with verbose output:"
    curl -v http://localhost:5678/healthz/readiness || echo "curl failed"
fi

echo "=== Health check completed ===" 