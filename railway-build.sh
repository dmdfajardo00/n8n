#!/bin/bash

# Railway-specific build script
# This script handles the "No changed files matched patterns" error

set -e

echo "🚀 Starting Railway build process..."

# Set environment variables to disable caching
export TURBO_FORCE=true
export TURBO_CACHE=false
export CI=true
export NODE_ENV=production

# Clean any existing build artifacts
echo "🧹 Cleaning build artifacts..."
rm -rf packages/*/dist packages/*/.turbo .turbo node_modules/.cache

# Install dependencies
echo "📦 Installing dependencies..."
pnpm install --frozen-lockfile --reporter=append-only

# Force rebuild all packages
echo "🔨 Building application..."
pnpm run build --force

echo "✅ Build completed successfully!" 