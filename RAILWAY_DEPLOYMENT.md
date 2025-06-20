# Railway Deployment Guide for n8n

## Problem Description

When deploying n8n to Railway, you may encounter the following error during the build process:

```
Error: Cannot find module @rollup/rollup-linux-x64-musl. npm has a bug related to optional dependencies (https://github.com/npm/cli/issues/4828).
```

This error occurs because:
1. Railway uses Alpine Linux with musl libc
2. The Rollup bundler tries to load native modules for better performance
3. The `--no-optional` flag in the original Dockerfile prevents optional dependencies from being installed
4. The native module `@rollup/rollup-linux-x64-musl` is not available during the build

### Additional Error: "No changed files matched patterns"

You may also encounter this error:

```
No changed files matched patterns: packages/**, *.json, *.yaml, *.yml
```

This error occurs because:
1. Turbo's caching mechanism is too aggressive
2. Railway's build context doesn't properly detect file changes
3. The build process thinks nothing has changed when it should rebuild

## Solutions

### Solution 1: Modified Alpine-based Dockerfile (Recommended)

The main `Dockerfile` has been updated with the following changes:

1. **Removed `--no-optional` flag**: This allows optional dependencies to be installed
2. **Added environment variables**:
   - `ROLLUP_SKIP_NATIVE=true`: Tells Rollup to skip native modules
   - `NODE_OPTIONS="--max-old-space-size=4096"`: Increases memory limit
   - `npm_config_arch=x64`, `npm_config_platform=linux`, `npm_config_libc=musl`: Ensures correct native module selection
   - `TURBO_FORCE=true`, `TURBO_CACHE=false`, `CI=true`: Disables Turbo caching
3. **Added fallback installation**: Manually installs the Rollup native module if needed
4. **Added cache cleaning**: Removes existing build artifacts before building

### Solution 2: Alternative Dockerfile (Dockerfile.alpine)

If the Alpine-based solution doesn't work, use `Dockerfile.alpine` which:

1. **Uses `node:22-alpine`**: Based on Alpine Linux with musl
2. **Includes Turbo cache fixes**: Disables caching and forces rebuilds
3. **Smaller image size**: More efficient for Railway deployment

### Solution 3: Custom Build Script

Use the `railway-build.sh` script for manual builds:

```bash
# Make the script executable
chmod +x railway-build.sh

# Run the build script
./railway-build.sh
```

## Usage

### For Solution 1 (Alpine-based):
```bash
# Use the default Dockerfile
docker build -t n8n-railway .
```

### For Solution 2 (Debian-based):
```bash
# Use the alternative Dockerfile
docker build -f Dockerfile.alpine -t n8n-railway .
```

### For Solution 3 (Custom script):
```bash
# Use the custom build script
./railway-build.sh
```

## Railway Configuration

Make sure your `railway.json` file points to the correct Dockerfile:

```json
{
  "build": {
    "builder": "DOCKERFILE",
    "dockerfilePath": "Dockerfile"
  }
}
```

Or for the alternative solution:

```json
{
  "build": {
    "builder": "DOCKERFILE",
    "dockerfilePath": "Dockerfile.alpine"
  }
}
```

## Environment Variables

The following environment variables are automatically set in the Dockerfile:

- `DOCKER_BUILD=true`: Indicates Docker build environment
- `NODE_ENV=production`: Production environment
- `ROLLUP_SKIP_NATIVE=true`: Skip Rollup native modules
- `NODE_OPTIONS="--max-old-space-size=4096"`: Increase memory limit
- `TURBO_FORCE=true`: Force Turbo to rebuild all packages
- `TURBO_CACHE=false`: Disable Turbo caching
- `CI=true`: Indicates CI environment
- `N8N_PORT=5678`: n8n port
- `N8N_HOST=0.0.0.0`: Bind to all interfaces
- `N8N_PROTOCOL=http`: Use HTTP protocol

## Troubleshooting

If you still encounter issues:

1. **Check Railway logs**: Look for specific error messages
2. **Try the alternative Dockerfile**: Switch to `Dockerfile.alpine`
3. **Use the custom build script**: Run `railway-build.sh` manually
4. **Increase build resources**: Railway may need more memory/CPU for the build
5. **Check pnpm version**: Ensure compatibility with the pnpm version specified
6. **Clear Railway cache**: Sometimes Railway's own caching can cause issues

## Additional Notes

- The build process may take longer due to the removal of `--no-optional` and disabled caching
- The image size will be slightly larger but more reliable
- The alternative Dockerfile uses Alpine Linux for smaller size but includes all necessary fixes
- The custom build script provides a manual alternative for complex deployment scenarios 