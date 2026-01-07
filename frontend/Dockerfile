# Multi-stage Dockerfile for FitPulse frontend (Vue 3 + Vite)

# ---- Build stage ----
FROM node:18-alpine AS build
WORKDIR /app

# Install dependencies
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./
RUN npm ci || npm i

# Copy source and build
COPY . .
ARG VITE_API_BASE
ENV VITE_API_BASE=${VITE_API_BASE}
RUN npm run build

# ---- Runtime stage ----
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# Copy built assets
COPY --from=build /app/dist .

# Default Nginx settings are sufficient for static hosting
EXPOSE 80
CMD ["nginx","-g","daemon off;"]
