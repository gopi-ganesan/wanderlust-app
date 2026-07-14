FROM node:18-alpine AS build

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy all project files
COPY . .


# Production Stage
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY --from=build /app/package*.json ./

# Install production dependencies only
RUN npm ci --omit=dev

# Copy complete application
COPY --from=build /app .

EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
CMD wget -qO- http://localhost:5000/health || exit 1

# Start backend server
CMD ["node", "server.js"]
