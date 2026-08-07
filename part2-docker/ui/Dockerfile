# ---- Single-stage: install, build, and serve ----------------
FROM node:20-alpine

# Security: create non-root user
RUN addgroup --system --gid 1001 nodejs \
    && adduser  --system --uid 1001 nextjs

WORKDIR /app

# Install dependencies first (layer cache optimisation)
COPY package*.json ./
RUN npm install

# Copy source and build
COPY . .
RUN npm run build

# Switch to non-root user
USER nextjs

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD wget -qO- http://localhost:3000/ || exit 1

# Start the Next.js production server
CMD ["npm", "start"]
