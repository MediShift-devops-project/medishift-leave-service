# FROM node:20-alpine AS builder
# WORKDIR /app
# COPY package*.json ./
# RUN npm install
# COPY . .

# FROM node:20-alpine

# RUN addgroup -S appgroup && \
#     adduser -S appuser -G appgroup

# WORKDIR /app

# COPY --chown=appuser:appgroup package*.json ./
# RUN npm install --only=production && \
#     npm cache clean --force

# COPY --chown=appuser:appgroup --from=builder /app/src ./src

# USER appuser
# ENV NODE_ENV=production
# EXPOSE 3004
# CMD ["node", "src/index.js"]


# # ---------- Stage 1: Build ----------
# FROM node:20-alpine AS builder

# WORKDIR /app

# # Force fresh dependency install layer when lock file changes
# COPY package*.json ./

# # Install ONLY production dependencies
# RUN npm ci --omit=dev && npm cache clean --force

# # Copy source
# COPY . .

# # ---------- Stage 2: Runtime (NO npm guaranteed) ----------
# FROM gcr.io/distroless/nodejs20-debian12

# WORKDIR /app

# # Copy ONLY required runtime files
# COPY --from=builder /app/node_modules ./node_modules
# COPY --from=builder /app/src ./src
# COPY --from=builder /app/package.json ./package.json

# ENV NODE_ENV=production

# USER nonroot

# EXPOSE 3004

# CMD ["src/index.js"]


# ---------- Stage 1: Build ----------
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY . .

# ---------- Stage 2: Secure Runtime ----------
FROM cgr.dev/chainguard/node:latest

WORKDIR /app

COPY --from=builder /app ./

ENV NODE_ENV=production

EXPOSE 3004

CMD ["node", "src/index.js"]
