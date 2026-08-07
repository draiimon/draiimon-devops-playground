# FastAPI backend container built from the cloned Bitbucket application.
FROM python:3.11-slim AS builder

WORKDIR /build

RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install --prefix=/install --no-cache-dir -r requirements.txt

FROM python:3.11-slim AS runtime

RUN groupadd --gid 1001 appgroup \
    && useradd --uid 1001 --gid 1001 --no-create-home --shell /sbin/nologin appuser

WORKDIR /app
COPY --from=builder /install /usr/local
COPY --chown=appuser:appgroup . .

USER appuser

ENV PORT=8000
EXPOSE 8000

# The cloned application exposes "/" rather than "/healthz".
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/')" || exit 1

CMD ["sh", "-c", "until python -c \"import socket; s=socket.create_connection(('db', 3306), 2); s.close()\"; do sleep 2; done; uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000} --access-log"]