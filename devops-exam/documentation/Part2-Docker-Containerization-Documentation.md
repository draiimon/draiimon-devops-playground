# Part 2: Docker Containerization — Documentation

**Candidate:** draiimon  
**Machine:** Aloof — WSL2 (Ubuntu 24.04 on Windows)  
**Date Completed:** August 7, 2026
**Exam:** Junior DevOps Engineer Exam 2026

---

## Connection to Part 1

Part 1 covered Linux commands, permissions, processes, networking, and shell
scripting. Part 2 applied those skills to package applications into Docker
images and run them together with Docker Compose.

| Part 1 skill | Use in Part 2 |
|---|---|
| File and directory commands | Created and checked the Docker project folders |
| Package management | Installed Python and Node dependencies inside images |
| Permissions and users | Ran the API and UI as non-root users |
| Networking and ports | Connected the API, UI, and database containers |
| Shell scripting | Used heredocs and the API startup wait command |

---

## Environment Overview

- **OS:** Ubuntu 24.04 on WSL2
- **Username:** `draiimon`
- **Hostname:** `Aloof`
- **Working directory:** `~/devops-exam/part2-docker`
- **Docker:** Docker version 29.1.3
- **Docker Compose:** docker-compose 1.29.2
- **Applications:** FastAPI API and Next.js UI cloned from Bitbucket
- **Database:** MySQL 8.0

---

## Task 1 — Clone and Check the Application Source

The exam required an API backend and a UI frontend. Both repositories were
cloned into separate folders so Docker Compose could build the real source.

### Commands Executed

```bash
cd ~/devops-exam/part2-docker

git clone https://bitbucket.org/metawhale/fast-api-clean api-src
git clone https://bitbucket.org/metawhale/nextjs_app ui-src

find api-src -maxdepth 1 -type f -print | sort
find ui-src -maxdepth 1 -type f -print | sort
```

### Important files found

```text
API: main.py, database.py, models.py, schemas.py, requirements.txt
UI:  package.json, package-lock.json, next.config.js, app/, components/
```

The API source uses `mysql+pymysql`, so the Compose database had to be MySQL,
not PostgreSQL.

### 📸 Screenshot

![Clone and verify the API and UI source](screenshots/part2/task02-4-git-clone.png)

---

## Task 2 — Prepare and Inspect the Dockerfiles

The Dockerfiles were copied into the cloned application folders. This makes
each folder a complete Docker build context.

### Commands Executed

```bash
cd ~/devops-exam/part2-docker

cp api/Dockerfile api-src/Dockerfile
cp ui/Dockerfile ui-src/Dockerfile

ls -l api-src/Dockerfile api-src/requirements.txt
ls -l ui-src/Dockerfile ui-src/package.json
```

The Dockerfiles were then reviewed before building:

```bash
printf "\nAPI Dockerfile:\n"
cat api-src/Dockerfile

printf "\nUI Dockerfile:\n"
cat ui-src/Dockerfile
```

### API Dockerfile used

```dockerfile
FROM python:3.11-slim AS build
WORKDIR /build
RUN apt-get update && apt-get install -y --no-install-recommends gcc \
    && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.11-slim
RUN addgroup --system app && adduser --system --ingroup app app
WORKDIR /app
COPY --from=build /install /usr/local
COPY --chown=app:app . .
USER app
ENV PORT=8000
EXPOSE 8000
HEALTHCHECK CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/')"
CMD ["sh", "-c", "until python -c \"import socket; s=socket.create_connection(('db',3306),2); s.close()\"; do sleep 2; done; exec uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}"]
```

### UI Dockerfile used

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
ENV NODE_ENV=production PORT=3000 HOSTNAME=0.0.0.0 NEXT_TELEMETRY_DISABLED=1
USER node
EXPOSE 3000
HEALTHCHECK CMD wget -qO- http://localhost:3000/ || exit 1
CMD ["npm", "start"]
```

### Why these lines were needed

| Line or feature | Purpose |
|---|---|
| Multi-stage API build | Keeps the compiler out of the final API image |
| `npm ci` | Installs the exact UI dependencies from the lock file |
| `npm run build` | Creates the production Next.js build |
| Non-root users | Avoids running the applications as root |
| `HEALTHCHECK` | Lets Docker report whether each application is healthy |
| API wait command | Waits for MySQL service `db` before starting FastAPI |

### Verification Commands

```bash
printf "\nAPI Dockerfile checks:\n"
grep -E "FROM|COPY requirements|USER app|HEALTHCHECK|uvicorn" api-src/Dockerfile

printf "\nUI Dockerfile checks:\n"
grep -E "FROM|npm ci|npm run build|USER|HEALTHCHECK|npm start" ui-src/Dockerfile
```

### 📸 Screenshots

![Dockerfiles copied into the cloned application folders](screenshots/part2/task02-6-copy-dockerfiles.png)

![Dockerfiles inspected before build](screenshots/part2/task02-7-dockerfile-check.png)

---

## Task 3 — Build the API and UI Images

### Command Executed

```bash
cd ~/devops-exam/part2-docker
docker-compose build
```

### Result

```text
Successfully built 2d0f3bd5508a
Successfully tagged api-app:latest

Successfully built 2a7aab427a68
Successfully tagged ui-app:latest
```

Both application images were built successfully.

### Warnings encountered

```text
DEPRECATED: The legacy builder is deprecated
debconf: unable to initialize frontend
WARNING: Running pip as the 'root' user
13 vulnerabilities ... from npm ci
Browserslist: caniuse-lite is outdated
```

These were warnings, not build failures:

- Docker completed the build using the installed legacy builder.
- `debconf` used non-interactive mode inside the image.
- pip ran as root only in the temporary builder stage; the final API uses
  the non-root `app` user.
- The npm audit messages came from the cloned application's dependencies.
- The UI still compiled successfully.

### 📸 Screenshot

![API and UI image build output](screenshots/part2/task02-4-build-both.png)

---

## Task 4 — Configure and Run Docker Compose

### Compose services

The final `docker-compose.yml` runs three services:

| Service | Image | Port | Purpose |
|---|---|---:|---|
| `api` | `api-app:latest` | `8000` | FastAPI backend |
| `ui` | `ui-app:latest` | `3000` | Next.js frontend |
| `db` | `mysql:8.0` | `3306` internal | MySQL database |

The API uses:

```text
mysql+pymysql://root:password@db:3306/testdb
```

### First Configuration Check

The first command used was:

```bash
docker compose config
```

### Error

```text
docker: unknown command: docker compose
```

This WSL installation has the older Compose command, so the correct command
was:

```bash
docker-compose config
```

The configuration was valid after using the hyphenated command.

### First Compose Problem

The first run used an old PostgreSQL container left from an earlier setup:

```bash
docker-compose up -d
```

### Error

```text
ERROR: for devops_db  'ContainerConfig'
KeyError: 'ContainerConfig'
```

The old container logs showed PostgreSQL, while the cloned FastAPI source
requires MySQL. The API and UI also showed `Exit 255`, and the first curl
checks failed:

```text
curl: (7) Failed to connect to localhost port 8000
curl: (7) Failed to connect to localhost port 3000
```

### Fix

The old containers were removed, without deleting the source files or named
database volume:

```bash
docker rm -f devops_db devops_api devops_ui 04417543e677_devops_db 2>/dev/null || true
```

The Compose file was corrected to use:

```yaml
image: mysql:8.0
MYSQL_ROOT_PASSWORD: password
MYSQL_DATABASE: testdb
DB_CONNECTION_STRING: mysql+pymysql://root:password@db:3306/testdb
```

### Final Configuration Check

```bash
cd ~/devops-exam/part2-docker
docker-compose config
```

The final output confirmed:

```text
image: mysql:8.0
MYSQL_DATABASE: testdb
DB_CONNECTION_STRING: mysql+pymysql://root:password@db:3306/testdb
```

### Final Start Command

```bash
docker-compose up -d
```

### Final Status

```bash
docker-compose ps
```

```text
devops_api   Up (healthy)   0.0.0.0:8000->8000/tcp
devops_db    Up (healthy)   3306/tcp
devops_ui    Up (healthy)   0.0.0.0:3000->3000/tcp
```

### Logs Checked

```bash
docker-compose logs --tail=100
docker-compose logs db
docker-compose logs api
docker-compose logs ui
```

The logs confirmed:

```text
API: Uvicorn running on http://0.0.0.0:8000
UI:  Next.js 13.5.6 — Ready
DB:  MySQL ready
```

### Application Tests

```bash
curl http://localhost:8000/
curl http://localhost:3000/
curl http://localhost:8000/trip
```

Results:

```json
{"message":"Fast Api Exam api v1"}
[]
```

The empty array from `/trip` was not an error. It meant the database was
working but had no trip records yet.

A test record was then created:

```bash
curl -X POST http://localhost:8000/trip \
  -H "Content-Type: application/json" \
  -d '{"name":"Docker Test Trip","description":"Test record from Docker","joiner_total_count":1}'

curl http://localhost:8000/trip
```

The API returned the created `Docker Test Trip` record successfully.

### Final Container Check

```bash
docker ps
```

All three containers were shown as `Up (healthy)`.

### 📸 Screenshots

![Docker Compose configuration with MySQL](screenshots/part2/task02-4-docker-compose.png)

![All services healthy and API/UI responses](screenshots/part2/task02-4-all-running.png)

![Final docker ps output](screenshots/part2/task02-4-docker-ps.png)

![API accessible in the browser](screenshots/part2/task02-4-api-browser.png)

![UI accessible in the browser](screenshots/part2/task02-4-ui-browser.png)

---

## ✅ Part 2 — Completion Summary

| Task | Description | Status |
|---|---|---|
| Task 1 | Clone and check API/UI source | ✅ Complete |
| Task 2 | Prepare and inspect Dockerfiles | ✅ Complete |
| Task 3 | Build API and UI images | ✅ Complete |
| Task 4 | Run API, UI, and MySQL with Compose | ✅ Complete |

**All 4 tasks completed. Part 2 — DONE ✅**

---

## 📸 Screenshot Checklist

| Screenshot | Filename | Status |
|---|---|---|
| Initial Docker setup | `task02-0-setup.png` | ✅ Done |
| API image build | `task02-1-api-build.png` | ✅ Done |
| UI image build | `task02-2-ui-build-1.png`, `task02-2-ui-build-2.png` | ✅ Done |
| Local image/container checks | `task02-3-local-execution.png`, `task02-3-local-execution-2.png` | ✅ Done |
| Clone and source verification | `task02-4-git-clone.png` | ✅ Done |
| Docker file check | `task02-5-file-check.png` | ✅ Done |
| Dockerfiles copied | `task02-6-copy-dockerfiles.png` | ✅ Done |
| Dockerfiles inspected | `task02-7-dockerfile-check.png` | ✅ Done |
| Both images built from cloned source | `task02-4-build-both.png` | ✅ Done |
| Compose services created/logs | `task02-4-docker-compose.png`, `task02-4-docker-compose-2.png` | ✅ Done |
| Earlier startup problem | `task02-4-docker-compose-3.png` | ✅ Documented |
| All services running | `task02-4-all-running.png` | ✅ Done |
| Final healthy containers | `task02-4-docker-ps.png` | ✅ Done |
| API browser test | `task02-4-api-browser.png` | ✅ Done |
| UI browser test | `task02-4-ui-browser.png` | ✅ Done |