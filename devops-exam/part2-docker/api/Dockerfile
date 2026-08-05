# ============================================================
# Dockerfile – FastAPI Backend
# Multi-stage build: keeps the final image small and clean
# ============================================================

# ---- Stage 1: Builder ----
FROM python:3.11-slim AS builder

WORKDIR /build

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better layer caching
COPY requirements.txt .

# Install Python packages into a dedicated prefix
RUN pip install --upgrade pip \
    && pip install --prefix=/install --no-cache-dir -r requirements.txt


# ---- Stage 2: Runtime ----
FROM python:3.11-slim AS runtime

# Security: create a non-root user
RUN groupadd --gid 1001 appgroup \
    && useradd  --uid 1001 --gid 1001 --no-create-home appuser

WORKDIR /app

# Copy only the installed packages from builder
COPY --from=builder /install /usr/local

# Copy application source
COPY . .

# Set ownership
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose the FastAPI default port
EXPOSE 8000

# Health check — hits the /healthz endpoint every 30s
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/healthz')" \
    || exit 1

# Start the app with Uvicorn
# Reads PORT env var; falls back to 8000
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000} --workers 2"]
