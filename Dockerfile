# Alternative Dockerfile for Railway deployment
# Use Node.js 22 with glibc instead of Alpine to avoid musl issues
FROM node:22-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    ffmpeg \
    git \
    && pip3 install --no-cache-dir yt-dlp \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Set Docker build environment variable
ENV DOCKER_BUILD=true
ENV NODE_ENV=production

# Set environment variables for better build performance
ENV NODE_OPTIONS="--max-old-space-size=4096"

# Copy package files and npm configuration
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./

# Install and enable corepack, then prepare specific pnpm version
RUN npm install -g corepack@0.33 && corepack enable && corepack prepare pnpm@10.12.1 --activate

# Copy source code
COPY . .

# Install dependencies with verbose output for debugging
RUN echo "Starting pnpm install..." && \
    pnpm --version && \
    node --version && \
    pnpm install --frozen-lockfile --reporter=append-only || \
    (echo "pnpm install failed, checking for errors..." && exit 1)

# Build the application
RUN pnpm run build

# Create non-root user
RUN groupadd -g 1001 nodejs && \
    useradd -u 1001 -g nodejs -s /bin/bash -m n8n

# Make start script executable and change ownership
RUN chmod +x /app/start-railway.sh
RUN chown -R n8n:nodejs /app
USER n8n

# Expose port
EXPOSE 5678

# Set environment variables
ENV NODE_ENV=production
ENV N8N_PORT=5678
ENV N8N_HOST=0.0.0.0
ENV N8N_PROTOCOL=http

# Start the application
CMD ["/app/start-railway.sh"] 