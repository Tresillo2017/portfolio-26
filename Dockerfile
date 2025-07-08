# Build stage
FROM node:18-alpine AS build

WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./

# Install dependencies (including dev dependencies needed for build)
RUN --mount=type=cache,id=npm,target=/root/.npm npm ci

# Copy environment file (if exists)
COPY .env* ./

# Copy source code
COPY . .

# Build the React app
ENV NODE_ENV=production
RUN npm run build

# Production stage - serve with nginx
FROM nginx:alpine AS production

# Copy built app to nginx html directory
COPY --from=build /app/public /usr/share/nginx/html

# Copy custom nginx config if needed (optional)
# COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]