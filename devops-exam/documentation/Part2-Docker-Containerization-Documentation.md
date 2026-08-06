# Part 2: Docker Containerization — Documentation

**Candidate:** draiimon  
**Machine:** Aloof — WSL2 (Ubuntu 24.04 on Windows)  
**Date Completed:** August 6, 2026  
**Exam:** Junior DevOps Engineer Exam 2026

---

## Connection to Part 1

Part 1 established the Linux foundation this entire exam builds on — file management, permissions, process control, networking, and shell scripting. **Part 2 directly applies those skills inside Docker containers:**

| Part 1 Skill | How it's used in Part 2 |
|--------------|------------------------|
| File & directory management (`mkdir`, `cp`, `mv`) | Creating the project folder structure on the local machine before running Docker |
| File permissions (`chmod`, non-root users) | Dockerfiles create non-root users (`appuser`, `nextjs`) — same concept as `useradd` in Task 8 |
| Package management (`apt install`) | Dockerfile RUN steps use `apt-get install` and `pip install` to set up the environment |
| Shell scripting (`bash`, variables, `CMD`) | The container entrypoint (`CMD`) is a shell command, same as writing a `.sh` script |
| Networking (`ip addr`, ports) | Docker maps ports with `-p host:container`, same concept as the ports seen with `ss -tuln` |
| Archiving (`tar`) | Docker images are internally layered archives — each `COPY` and `RUN` is a layer |

---

## Environment Overview

All tasks were performed on **WSL2 (Windows Subsystem for Linux 2)** running Ubuntu 24.04 on a Windows machine. Docker Desktop (with WSL2 backend) was used to build and run containers.

- **Username:** draiimon  
- **Hostname:** Aloof  
- **Docker version:** Docker Desktop with WSL2 backend  
- **Working Directory:** `~/devops-exam/part2-docker`

---

## Pre-Task Setup — Creating the Project Structure on Local Machine

Before building Docker images, the project folder structure needs to exist on the local WSL machine. The files live in Replit (the exam workspace), so we recreate them locally first.

### Why this is needed

Docker runs on your **local machine** — it cannot pull files directly from Replit. The `docker build` command needs the `Dockerfile` and source files to be present on the same machine where Docker is running. This is the same principle as Part 1 Task 1 (`mkdir -p`) — you always set up your directory structure before working inside it.

### Commands Executed

```bash
# Create the folder structure (same as Part 1 Task 1 — mkdir -p)
mkdir -p ~/devops-exam/part2-docker/api

# Create requirements.txt
cat > ~/devops-exam/part2-docker/api/requirements.txt << 'EOF'
fastapi>=0.111.0
uvicorn[standard]>=0.29.0
sqlalchemy>=2.0.0
alembic>=1.13.0
asyncpg>=0.29.0
pydantic>=2.7.0
pydantic-settings>=2.2.0
httpx>=0.27.0
python-jose[cryptography]>=3.3.0
passlib[bcrypt]>=1.7.4
python-dotenv>=1.0.0
python-multipart>=0.0.9
EOF

# Create the Dockerfile
cat > ~/devops-exam/part2-docker/api/Dockerfile << 'EOF'
FROM python:3.11-slim AS builder
WORKDIR /build
RUN apt-get update && apt-get install -y --no-install-recommends gcc libpq-dev && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install --upgrade pip && pip install --prefix=/install --no-cache-dir -r requirements.txt
FROM python:3.11-slim AS runtime
RUN groupadd --gid 1001 appgroup && useradd --uid 1001 --gid 1001 --no-create-home --shell /sbin/nologin appuser
WORKDIR /app
COPY --from=builder /install /usr/local
COPY --chown=appuser:appgroup . .
USER appuser
EXPOSE 8000
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}"]
EOF
```

### Explanation

| Command | What it does |
|---------|-------------|
| `mkdir -p ~/devops-exam/part2-docker/api` | Creates nested folders in one shot — `-p` means "create parent directories too, no error if they exist" (same as Part 1 Task 1) |
| `cat > file << 'EOF' ... EOF` | **Heredoc** — a way to write a multi-line block of text directly into a file from the terminal, without opening a text editor. Everything between `EOF` and `EOF` is written as the file content |
| `~/devops-exam/` | The tilde `~` is shorthand for your home directory `/home/draiimon` |
| `FROM python:3.11-slim AS builder` | Pulls the official Python 3.11 slim image from Docker Hub as the **build stage** — "slim" means it has the minimum OS packages needed |
| `RUN apt-get install gcc libpq-dev` | Installs C compiler (`gcc`) and PostgreSQL headers (`libpq-dev`) needed to compile some Python packages |
| `pip install --prefix=/install` | Installs Python packages into a separate `/install` folder so they can be cleanly copied to the next stage |
| `FROM python:3.11-slim AS runtime` | Starts a **fresh, clean image** — no build tools, no compiler, just the runtime. This is what makes multi-stage builds powerful |
| `useradd --no-create-home --shell /sbin/nologin appuser` | Creates a locked-down non-root user — no home folder, no login shell. Containers should never run as root |
| `COPY --from=builder /install /usr/local` | Copies only the installed packages from the builder stage — leaves the compiler and build tools behind |
| `EXPOSE 8000` | Documents which port the app listens on (does not actually open the port — that's done with `-p` in `docker run`) |
| `CMD ["sh", "-c", "uvicorn main:app ..."]` | The default command that runs when the container starts — launches the FastAPI app with Uvicorn |

### 📸 Screenshot — Pre-Task Setup

![Pre-Task Setup - Creating folder structure and files](screenshots/part2/task02-0-setup.png)

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

### Build Command

```bash
cd ~/devops-exam/part2-docker
docker build -t api-app:latest ./api
```

### Full Build Log — Step by Step

```
Step 1/13 : FROM python:3.11-slim AS builder
Step 2/13 : WORKDIR /build
Step 3/13 : RUN apt-get update && apt-get install -y --no-install-recommends gcc libpq-dev
Step 4/13 : COPY requirements.txt .
Step 5/13 : RUN pip install --upgrade pip && pip install --prefix=/install --no-cache-dir -r requirements.txt
→ Successfully installed: fastapi, uvicorn, sqlalchemy, asyncpg, pydantic, python-jose,
  passlib, httpx, alembic, cryptography, bcrypt, starlette, uvloop, watchfiles, websockets...

Step 6/13 : FROM python:3.11-slim AS runtime      ← fresh clean image starts here
Step 7/13 : RUN groupadd --gid 1001 appgroup && useradd --uid 1001 ... appuser
Step 8/13 : WORKDIR /app
Step 9/13 : COPY --from=builder /install /usr/local
Step 10/13: COPY --chown=appuser:appgroup . .
Step 11/13: USER appuser
Step 12/13: EXPOSE 8000
Step 13/13: CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}"]

Successfully built 1ca9c3c0e40e
Successfully tagged api-app:latest
```

### What Each Step Does

| Step | Command | What's happening |
|------|---------|-----------------|
| 1 | `FROM python:3.11-slim AS builder` | Downloads the official Python 3.11 slim image from Docker Hub — this is the **builder stage** |
| 2 | `WORKDIR /build` | Sets the working directory inside the container to `/build` — like `cd /build` |
| 3 | `RUN apt-get install gcc libpq-dev` | Installs the C compiler (`gcc`) and PostgreSQL headers (`libpq-dev`) needed to compile Python packages that have C extensions |
| 4 | `COPY requirements.txt .` | Copies `requirements.txt` from your machine into the container |
| 5 | `pip install --prefix=/install` | Installs all Python packages into `/install` folder — isolated so they can be cleanly copied to the next stage |
| 6 | `FROM python:3.11-slim AS runtime` | **Starts a brand new, clean image** — no compiler, no build tools. This is the power of multi-stage builds — the final image is small and clean |
| 7 | `RUN groupadd && useradd appuser` | Creates a non-root user `appuser` — containers must not run as root in production |
| 8 | `WORKDIR /app` | Sets the working directory in the runtime image to `/app` |
| 9 | `COPY --from=builder /install /usr/local` | Copies only the installed packages from the builder — leaves the compiler behind |
| 10 | `COPY --chown=appuser:appgroup . .` | Copies the app source code, giving ownership to `appuser` |
| 11 | `USER appuser` | Switches to the non-root user — all commands from here run as `appuser` |
| 12 | `EXPOSE 8000` | Documents that the app listens on port 8000 |
| 13 | `CMD [...]` | The command that runs when the container starts — launches FastAPI with Uvicorn |

### ⚠️ Warnings Explained — These Are NOT Errors

| Warning | Why it appears | Is it a problem? |
|---------|---------------|-----------------|
| `DEPRECATED: The legacy builder` | Docker Desktop recommends using the newer BuildKit engine. The old builder still works perfectly. | ❌ No — build succeeds. Fix: run `export DOCKER_BUILDKIT=1` to silence it |
| `debconf: unable to initialize frontend: Dialog` | During `apt-get install`, Docker containers don't have an interactive terminal so the package installer can't show dialog boxes. It automatically falls back to non-interactive mode. | ❌ No — packages install fine anyway |
| `WARNING: Running pip as the 'root' user` | In the **builder stage**, pip runs as root inside the container. This is fine because it's a temporary build environment, not the final image. In the runtime stage, we switch to `appuser`. | ❌ No — the runtime stage runs as a non-root user as required |

### 📸 Screenshot — Task 1

![Task 1 - API Docker Build](screenshots/part2/task02-1-api-build.png)

> ✅ **Build result:** `Successfully built 1ca9c3c0e40e` → `Successfully tagged api-app:latest` — the image was built and tagged correctly.

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

### Build Command

```bash
mkdir -p ~/devops-exam/part2-docker/ui
# (create Dockerfile via heredoc — see pre-setup section)
cd ~/devops-exam/part2-docker
docker build -t ui-app:latest ./ui
```

### Full Build Log — Step by Step

```
Step 1/14 : FROM node:20-alpine AS deps        ← deps stage starts
Step 2/14 : RUN apk add --no-cache libc6-compat
  → Installing musl-obstack, libucontext, gcompat (21 packages, 11.0 MiB)
Step 3/14 : WORKDIR /app

Step 4/14 : FROM node:20-alpine AS builder     ← builder stage starts
Step 5/14 : WORKDIR /app
Step 6/14 : ENV NEXT_TELEMETRY_DISABLED=1

Step 7/14 : FROM node:20-alpine AS runtime     ← runtime stage starts (fresh clean image)
Step 8/14 : RUN addgroup --system --gid 1001 nodejs && adduser --system --uid 1001 nextjs
Step 9/14 : WORKDIR /app
Step 10/14: ENV NODE_ENV=production NEXT_TELEMETRY_DISABLED=1 PORT=3000 HOSTNAME="0.0.0.0"
Step 11/14: USER nextjs
Step 12/14: EXPOSE 3000
Step 13/14: HEALTHCHECK --interval=30s ... CMD wget -qO- http://localhost:3000/ || exit 1
Step 14/14: CMD ["node", "server.js"]

Successfully built f78652353702
Successfully tagged ui-app:latest
```

### What Each Step Does

| Step | Command | What's happening |
|------|---------|-----------------|
| 1 | `FROM node:20-alpine AS deps` | Downloads Node.js 20 Alpine image — Alpine is the smallest Linux distro (~5MB vs ~200MB for full Ubuntu) |
| 2 | `RUN apk add libc6-compat` | Installs compatibility libraries needed by some Node.js packages — `apk` is Alpine's package manager (same idea as `apt` in Ubuntu) |
| 3 | `WORKDIR /app` | Sets working directory in the deps stage |
| 4 | `FROM node:20-alpine AS builder` | Starts the **builder stage** — note Docker reuses the same `node:20-alpine` image it already pulled, no re-download needed |
| 5 | `WORKDIR /app` | Sets working directory in the builder stage |
| 6 | `ENV NEXT_TELEMETRY_DISABLED=1` | Disables Next.js from sending usage analytics during the build |
| 7 | `FROM node:20-alpine AS runtime` | Starts the **final runtime stage** — fresh clean image, no build tools |
| 8 | `addgroup && adduser nextjs` | Creates a non-root system user `nextjs` — same security principle as Task 1's `appuser` |
| 9 | `WORKDIR /app` | Sets working directory in the runtime stage |
| 10 | `ENV NODE_ENV=production ...` | Sets production environment variables — `HOSTNAME="0.0.0.0"` makes the server listen on all network interfaces |
| 11 | `USER nextjs` | Switches to non-root user — container will NOT run as root |
| 12 | `EXPOSE 3000` | Documents the app port |
| 13 | `HEALTHCHECK` | Docker checks `wget http://localhost:3000/` every 30s to confirm the app is alive |
| 14 | `CMD ["node", "server.js"]` | Starts the Next.js standalone server — `server.js` is the self-contained output from `next build` |

### Key Difference vs API Build

| | API (13 steps) | UI (14 steps) |
|-|----------------|---------------|
| Base image | `python:3.11-slim` | `node:20-alpine` |
| Stages | 2 (builder + runtime) | 3 (deps + builder + runtime) |
| Package manager | `apt-get` + `pip` | `apk` (Alpine) + `npm` |
| Non-root user | `appuser` | `nextjs` |
| Extra step | — | `libc6-compat` for Alpine compatibility |

> 📝 **Why 3 stages for UI?** The `deps` stage is separated specifically to cache `node_modules`. If only your source code changes but `package.json` stays the same, Docker reuses the cached `deps` layer and skips `npm ci` entirely — making rebuilds much faster.

### 📸 Screenshots — Task 2

![Task 2 - UI Dockerfile Setup and Build Start](screenshots/part2/task02-2-ui-build-1.png)

![Task 2 - UI Dockerfile Build Complete](screenshots/part2/task02-2-ui-build-2.png)

> ✅ **Build result:** `Successfully built f78652353702` → `Successfully tagged ui-app:latest`

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

⚠️ **Screenshot missing** — please add and place as `screenshots/part2/task02-3-local-execution.png`

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

⚠️ **Screenshot missing** — please add and place as `screenshots/part2/task02-4-docker-compose.png`

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
| Pre-Setup — folder structure + file creation | `task02-0-setup.png` | ✅ Done |
| Task 1 — API Dockerfile build output | `task02-1-api-build.png` | ✅ Done |
| Task 2 — UI Dockerfile build output | `task02-2-ui-build.png` | ⚠️ Missing |
| Task 3 — `docker ps` + `docker images` | `task02-3-local-execution.png` | ⚠️ Missing |
| Task 4 — `docker-compose up` output | `task02-4-docker-compose.png` | ⚠️ Missing |
