# Alternative Dockerfile for Railway deployment
# Use Node.js 22 with glibc instead of Alpine to avoid musl issues
FROM node:22-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    ffmpeg \
    git \
    curl \
    && pip3 install --no-cache-dir --break-system-packages yt-dlp \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Set Docker build environment variable
ENV DOCKER_BUILD=true
ENV NODE_ENV=production

# Set environment variables for better build performance
ENV NODE_OPTIONS="--max-old-space-size=4096"
ENV TURBO_FORCE=true
ENV CI=true

# Copy package files and npm configuration
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./

# Install and enable corepack, then prepare specific pnpm version
RUN npm install -g corepack@0.33 && corepack enable && corepack prepare pnpm@10.12.1 --activate

# Copy source code
COPY . .

# Clean any existing build artifacts and Turbo cache
RUN rm -rf packages/*/dist packages/*/.turbo .turbo

# Install dependencies with verbose output for debugging
RUN echo "Starting pnpm install..." && \
    pnpm --version && \
    node --version && \
    pnpm install --frozen-lockfile --reporter=append-only || \
    (echo "pnpm install failed, checking for errors..." && exit 1)

# Build the application with forced rebuild
RUN echo "Starting build process..." && \
    pnpm run build --force || \
    (echo "Build failed, trying without cache..." && pnpm run build --cache=local:r,remote:r)

# Create non-root user
RUN groupadd -g 1001 nodejs && \
    useradd -u 1001 -g nodejs -s /bin/bash -m n8n

# Make scripts executable and change ownership
RUN chmod +x /app/start-railway.sh
RUN chmod +x /app/health-check.sh
RUN chmod +x /app/env-check.sh
RUN chmod +x /app/test-health.sh
RUN chown -R n8n:nodejs /app
USER n8n

# Expose port
EXPOSE 5678

# Set environment variables
ENV NODE_ENV=production
ENV N8N_PORT=5678
ENV N8N_HOST=0.0.0.0
ENV N8N_PROTOCOL=http

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:5678/healthz || exit 1

# Start the application
CMD ["/app/start-railway.sh"] 