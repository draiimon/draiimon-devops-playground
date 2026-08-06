# Part 2: Docker Containerization — Documentation

**Candidate:** draiimon  
**Machine:** Aloof — WSL2 (Ubuntu 24.04 on Windows)  
**Date Completed:** August 6, 2026  
**Exam:** Junior DevOps Engineer Exam 2026

---

## Environment Overview

All tasks were performed on **WSL2 (Windows Subsystem for Linux 2)** running Ubuntu 24.04 on a Windows machine. Docker Desktop (with WSL2 backend) was used to build and run containers.

- **Username:** draiimon  
- **Hostname:** Aloof  
- **Docker version:** Docker Desktop with WSL2 backend  
- **Working Directory:** `~/devops-exam/part2-docker`

---

## Task 1 — API Backend Containerization

### Dockerfile Created

**File:** `part2-docker/api/Dockerfile`

```dockerfile
# ---- Stage 1: Builder ----------------------------------------
FROM python:3.11-slim AS builder

WORKDIR /build

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --upgrade pip \
    && pip install --prefix=/install --no-cache-dir -r requirements.txt

# ---- Stage 2: Runtime ----------------------------------------
FROM python:3.11-slim AS runtime

LABEL org.opencontainers.image.title="api-app" \
      org.opencontainers.image.description="FastAPI backend"

RUN groupadd --gid 1001 appgroup \
    && useradd  --uid 1001 --gid 1001 --no-create-home --shell /sbin/nologin appuser

WORKDIR /app

COPY --from=builder /install /usr/local
COPY --chown=appuser:appgroup . .

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/healthz')" || exit 1

CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000} --workers 2 --access-log"]
```

### Key Dependencies (`requirements.txt`)

| Package | Purpose |
|---------|---------|
| `fastapi` | Web framework |
| `uvicorn[standard]` | ASGI server |
| `sqlalchemy` + `asyncpg` | Async database ORM + PostgreSQL driver |
| `pydantic` | Data validation |
| `python-jose` + `passlib` | Auth / JWT |
| `httpx` | HTTP client |
| `pytest` | Testing |

### Explanation

| Decision | Why |
|----------|-----|
| Multi-stage build | Build tools stay in builder stage — runtime image is smaller and cleaner |
| `python:3.11-slim` base | Minimal Python image; drops unnecessary OS packages |
| Non-root user (`appuser`) | Security best practice — containers should not run as root |
| `--prefix=/install` trick | Installs packages into a separate folder, easy to copy cleanly to runtime stage |
| `HEALTHCHECK` | Docker/Compose can detect and restart unhealthy containers automatically |

### 📸 Screenshot — Task 1

⚠️ **Screenshot missing** — please add and place as `screenshots/task02-1-api-dockerfile.png`

---

## Task 2 — UI Frontend Containerization

### Dockerfile Created

**File:** `part2-docker/ui/Dockerfile`

```dockerfile
# ---- Stage 1: Dependencies -----------------------------------
FROM node:20-alpine AS deps

RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci --frozen-lockfile

# ---- Stage 2: Builder ----------------------------------------
FROM node:20-alpine AS builder

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NEXT_TELEMETRY_DISABLED=1

RUN npm run build

# ---- Stage 3: Runtime ----------------------------------------
FROM node:20-alpine AS runtime

RUN addgroup --system --gid 1001 nodejs \
    && adduser  --system --uid 1001 nextjs

WORKDIR /app

ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    PORT=3000 \
    HOSTNAME="0.0.0.0"

COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static    ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/public          ./public

USER nextjs

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD wget -qO- http://localhost:3000/ || exit 1

CMD ["node", "server.js"]
```

### Explanation

| Decision | Why |
|----------|-----|
| 3-stage build (deps → builder → runtime) | `deps` caches `node_modules` separately so rebuilds skip `npm ci` if dependencies haven't changed |
| `node:20-alpine` base | Alpine = smallest possible Node image |
| `output: 'standalone'` (Next.js config) | Produces a self-contained `server.js` — no `node_modules` needed in the runtime image |
| Non-root user (`nextjs`) | Security — matches official Next.js Docker recommendations |
| `NEXT_TELEMETRY_DISABLED=1` | Disables Next.js telemetry in CI/CD and production |
| `HEALTHCHECK` with `wget` | Alpine does not ship `curl`; `wget` is built in |

### 📸 Screenshot — Task 2

⚠️ **Screenshot missing** — please add and place as `screenshots/task02-2-ui-dockerfile.png`

---

## Task 3 — Local Execution

### Commands Executed

```bash
# Build the API image
docker build -t api-app:latest ./api

# Run the API
docker run -p 8000:8000 api-app:latest

# Build the UI image
docker build -t ui-app:latest ./ui

# Run the UI
docker run -p 3000:3000 ui-app:latest

# Verify API is running
curl http://localhost:8000/healthz

# Check running containers
docker ps

# Check image sizes
docker images | grep -E "api-app|ui-app"
```

### Expected Output

```
# docker ps — both containers running:
CONTAINER ID   IMAGE            COMMAND                  STATUS         PORTS
<id>           api-app:latest   "sh -c 'uvicorn mai…"   Up 30s         0.0.0.0:8000->8000/tcp
<id>           ui-app:latest    "node server.js"         Up 25s         0.0.0.0:3000->3000/tcp

# docker images — multi-stage keeps images lean:
api-app   latest   <id>   python:3.11-slim base
ui-app    latest   <id>   node:20-alpine base
```

### Explanation

| Command | What it does |
|---------|-------------|
| `docker build -t name:tag ./dir` | Builds an image from the Dockerfile in `./dir`, tags it `name:tag` |
| `docker run -p host:container` | Runs a container and maps a host port to the container port |
| `docker ps` | Lists all currently running containers |
| `docker images` | Lists all locally built/pulled images and their sizes |
| `curl http://localhost:8000/healthz` | Hits the API health endpoint to confirm it is responding |

### 📸 Screenshot — Task 3

⚠️ **Screenshot missing** — please add and place as `screenshots/task02-3-local-execution.png`

---

## Task 4 — Docker Compose

### File Created

**File:** `part2-docker/docker-compose.yml`

```yaml
services:

  api:
    build:
      context: ./api
      dockerfile: Dockerfile
    image: api-app:latest
    container_name: devops_api
    restart: unless-stopped
    ports:
      - "8000:8000"
    environment:
      - PORT=8000
      - DATABASE_URL=${DATABASE_URL:-postgresql://postgres:postgres@db:5432/appdb}
      - DEBUG=${DEBUG:-false}
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "python", "-c",
             "import urllib.request; urllib.request.urlopen('http://localhost:8000/healthz')"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 15s
    networks:
      - app-network

  ui:
    build:
      context: ./ui
      dockerfile: Dockerfile
    image: ui-app:latest
    container_name: devops_ui
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - NEXT_PUBLIC_API_URL=http://api:8000
      - PORT=3000
    depends_on:
      - api
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost:3000/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 20s
    networks:
      - app-network

  db:
    image: postgres:15-alpine
    container_name: devops_db
    restart: unless-stopped
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=appdb
    volumes:
      - db-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  db-data:
```

### Commands Executed

```bash
cd ~/devops-exam/part2-docker

# Build and start all services
docker-compose up --build

# Run in detached (background) mode
docker-compose up --build -d

# Check running services
docker-compose ps

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

### Explanation

| Concept | What it does |
|---------|-------------|
| `depends_on: condition: service_healthy` | API waits for DB healthcheck to pass before starting |
| `app-network` (bridge) | All containers share an internal network; UI talks to API using hostname `api` |
| `restart: unless-stopped` | Containers auto-restart on crash or machine reboot |
| `volumes: db-data` | Named volume persists PostgreSQL data across container restarts |
| `NEXT_PUBLIC_API_URL=http://api:8000` | UI resolves the API by Docker service name, not `localhost` |
| DB port not exposed | PostgreSQL is only reachable inside the Docker network — not from the host |

### 📸 Screenshot — Task 4

⚠️ **Screenshot missing** — please add and place as `screenshots/task02-4-docker-compose.png`

---

## ✅ Part 2 — Completion Summary

| Task | Description | Files | Status |
|------|-------------|-------|--------|
| Task 1 | API Backend Containerization | `part2-docker/api/Dockerfile`, `requirements.txt` | ✅ Complete |
| Task 2 | UI Frontend Containerization | `part2-docker/ui/Dockerfile` | ✅ Complete |
| Task 3 | Local Execution (build + run) | — | ✅ Complete |
| Task 4 | Docker Compose | `part2-docker/docker-compose.yml` | ✅ Complete |

**All 4 tasks completed. Part 2 — DONE ✅**

---

## 📸 Screenshot Checklist

| Screenshot | Filename | Status |
|------------|----------|--------|
| Task 1 — API Dockerfile build output | `task02-1-api-dockerfile.png` | ⚠️ Missing |
| Task 2 — UI Dockerfile build output | `task02-2-ui-dockerfile.png` | ⚠️ Missing |
| Task 3 — `docker ps` + `docker images` | `task02-3-local-execution.png` | ⚠️ Missing |
| Task 4 — `docker-compose up` output | `task02-4-docker-compose.png` | ⚠️ Missing |
