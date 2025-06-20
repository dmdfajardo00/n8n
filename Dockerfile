# Use Node.js 22 Alpine as base
FROM node:22-alpine

# Install system dependencies
RUN apk add --no-cache \
    python3 \
    py3-pip \
    ffmpeg \
    git \
    && pip3 install --no-cache-dir --break-system-packages yt-dlp

# Set working directory
WORKDIR /app

# Set Docker build environment variable
ENV DOCKER_BUILD=true
ENV NODE_ENV=production

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
    pnpm install --frozen-lockfile --no-optional --reporter=append-only || \
    (echo "pnpm install failed, checking for errors..." && exit 1)

# Build the application
RUN pnpm run build

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S n8n -u 1001

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