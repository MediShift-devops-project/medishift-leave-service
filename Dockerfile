# -------- Stage 1: Build --------
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies (deterministic)
COPY package*.json ./
RUN npm ci

# Copy source
COPY . .

# -------- Stage 2: Minimal Runtime --------
FROM gcr.io/distroless/nodejs20-debian12

WORKDIR /app

# Copy only required files from builder
COPY --from=builder /app /app

# Use non-root user (distroless already provides one)
USER nonroot

ENV NODE_ENV=production

EXPOSE 3004

CMD ["src/index.js"]
