# ============================================================
# Dockerfile — FastAPI backend (2026 edition)
# Multi-stage build with Chainguard distroless runtime image
# ============================================================

# ---- Stage 1: Builder ----------------------------------------
FROM python:3.11-slim AS builder

WORKDIR /build

# Install build deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Install into /install prefix so we can copy cleanly
RUN pip install --upgrade pip \
    && pip install --prefix=/install --no-cache-dir -r requirements.txt

# ---- Stage 2: Runtime (distroless-style slim) ----------------
FROM python:3.11-slim AS runtime

# Labels (OCI image spec)
LABEL org.opencontainers.image.title="api-app" \
      org.opencontainers.image.description="FastAPI backend" \
      org.opencontainers.image.source="https://github.com/YOUR_USERNAME/YOUR_REPO"

# Non-root user
RUN groupadd --gid 1001 appgroup \
    && useradd  --uid 1001 --gid 1001 --no-create-home --shell /sbin/nologin appuser

WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /install /usr/local

# Copy app source
COPY --chown=appuser:appgroup . .

USER appuser

EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/healthz')" || exit 1

CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000} --workers 2 --access-log"]
