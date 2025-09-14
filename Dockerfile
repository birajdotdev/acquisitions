# Use Node.js 20 Alpine as base image
FROM node:20-alpine AS base

# Set working directory
WORKDIR /app

# Install dependencies needed for native modules
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    && ln -sf python3 /usr/bin/python

# Copy package files
COPY package*.json ./

# Development stage
FROM base AS development
# Install all dependencies (including dev dependencies)
RUN npm ci
# Copy source code
COPY . .
# Expose port
EXPOSE 3000
# Use development script with watch mode
CMD ["npm", "run", "dev"]

# Production dependencies stage
FROM base AS prod-deps
# Install only production dependencies
RUN npm ci --only=production && npm cache clean --force

# Production stage
FROM node:20-alpine AS production
WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache dumb-init

# Copy production dependencies
COPY --from=prod-deps /app/node_modules ./node_modules

# Copy application code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Change ownership of the app directory
RUN chown -R nodejs:nodejs /app
USER nodejs

# Expose port
EXPOSE 3000

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start the application
CMD ["npm", "start"]