# ============================================================
# Dockerfile – Next.js Frontend
# Multi-stage build: build then serve only the output
# ============================================================

# ---- Stage 1: Dependencies ----
FROM node:20-alpine AS deps

# Install libc compatibility for some native modules
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Copy package files first (cache-friendly)
COPY package.json package-lock.json* ./

RUN npm ci --only=production --frozen-lockfile


# ---- Stage 2: Builder ----
FROM node:20-alpine AS builder

WORKDIR /app

# Copy node_modules from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy source
COPY . .

# Disable Next.js telemetry during build
ENV NEXT_TELEMETRY_DISABLED=1

# Build the Next.js application
RUN npm run build


# ---- Stage 3: Runtime ----
FROM node:20-alpine AS runtime

# Security: non-root user
RUN addgroup --system --gid 1001 nodejs \
    && adduser  --system --uid 1001 nextjs

WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Copy Next.js standalone output (requires `output: 'standalone'` in next.config.js)
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static    ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/public          ./public

USER nextjs

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD wget -qO- http://localhost:3000/ || exit 1

CMD ["node", "server.js"]
