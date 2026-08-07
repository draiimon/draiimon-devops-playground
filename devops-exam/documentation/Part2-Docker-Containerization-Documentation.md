# Part 2: Docker Containerization — Complete Documentation

**Candidate:** draiimon  
**Machine:** Aloof — WSL2 (Ubuntu 24.04 on Windows)  
**Date Completed:** August 7, 2026
**Exam:** Junior DevOps Engineer Exam 2026

---

## Objective

The objective of Part 2 was to containerize the two sample applications required by
the exam:

| Application | Technology | Container port | Role |
|-------------|------------|---------------:|------|
| API Backend | FastAPI / Python | `8000` | Provides the backend API and database operations |
| UI Frontend | Next.js / Node.js | `3000` | Provides the web interface |
| Database | MySQL 8.0 | `3306` internal | Stores the API application's data |

Docker was used so that the applications, dependencies, runtime versions, ports,
network, and database could be reproduced consistently instead of being installed
directly on the host machine.

---

## Connection to Part 1

Part 1 demonstrated Linux commands and troubleshooting skills. Part 2 applied those
same skills to a containerized application stack.

| Part 1 skill | How it was used in Part 2 |
|--------------|---------------------------|
| `cd`, file and directory management | Entered the project directory and organized `api-src/`, `ui-src/`, `api/`, and `ui/` |
| `find`, `ls`, `cat`, and `grep` | Inspected cloned repositories and verified Dockerfile contents |
| Package management | Installed Python build dependencies in the API builder image and Node packages in the UI image |
| Permissions and users | Created and used non-root users inside both application images |
| Networking and ports | Published API port `8000`, UI port `3000`, and connected services over Docker's bridge network |
| Processes and troubleshooting | Checked containers, logs, health status, and failed startup processes |
| Shell scripting | Used heredocs to create Dockerfiles and a shell loop to wait for MySQL |

---

## Exam Requirement Alignment

The following table maps the work to the Part 2 requirements in
`Junior_DevOps_Engineer_Exam_2026_1785970827190.pdf`.

| PDF requirement | Evidence in this project | Status |
|-----------------|--------------------------|--------|
| API Dockerfile | `part2-docker/api-src/Dockerfile` | ✅ Complete |
| Python dependencies | `requirements.txt` copied and installed with `pip` | ✅ Complete |
| Appropriate API base image | `python:3.11-slim` | ✅ Complete |
| API port exposed | `EXPOSE 8000` and `8000:8000` mapping | ✅ Complete |
| API multi-stage build | `builder` and `runtime` stages | ✅ Complete |
| UI Dockerfile | `part2-docker/ui-src/Dockerfile` | ✅ Complete |
| Node.js environment | `node:20-alpine` | ✅ Complete |
| Production UI build | `npm ci` followed by `npm run build` | ✅ Complete |
| UI port exposed | `EXPOSE 3000` and `3000:3000` mapping | ✅ Complete |
| Production optimization | Locked dependency installation, production environment, telemetry disabled | ✅ Complete |
| Build with `docker build` | API and UI images built and tagged | ✅ Complete |
| Run with `docker run` | Local image/container execution was attempted and then repeated with real cloned source | ✅ Complete |
| Verify containerized applications | `docker ps`, logs, `curl`, browser checks, and health checks | ✅ Complete |
| Test inter-service communication | API connected to MySQL using the `db` service name | ✅ Complete |
| Docker Compose | `docker-compose.yml` with API, UI, MySQL, network, environment, health checks, and volume | ✅ Complete |

---

## Environment Overview

| Item | Value |
|------|-------|
| Operating system | Ubuntu 24.04 on WSL2 |
| Username | `draiimon` |
| Hostname | `Aloof` |
| Working directory | `~/devops-exam/part2-docker` |
| Docker | Docker version `29.1.3` |
| Compose command available | Legacy `docker-compose` version `1.29.2` |
| API source | Bitbucket `metawhale/fast-api-clean` |
| UI source | Bitbucket `metawhale/nextjs_app` |
| Database driver used by API | `mysql+pymysql` |
| Final database image | `mysql:8.0` |

### Important compatibility finding

The cloned FastAPI application uses a MySQL connection string:

```text
mysql+pymysql://root:password@db:3306/testdb
```

Therefore, the Compose database had to be MySQL. The earlier PostgreSQL setup was
not compatible with the cloned application and was one of the main problems solved
during this part.

---

# Task 1 — Clone and Verify the Application Source

## Purpose

The Dockerfiles cannot build a working application if the build context contains only
an empty folder or a Dockerfile. The API and UI repositories were cloned first so
that the Docker build contexts contained the real `main.py`, `requirements.txt`,
`package.json`, Next.js `app/`, and component files.

This step directly follows the exam's **Application Components** and **Repository
Setup** instructions.

## Commands Executed

```bash
cd ~/devops-exam/part2-docker

git clone https://bitbucket.org/metawhale/fast-api-clean api-src
git clone https://bitbucket.org/metawhale/nextjs_app ui-src

find api-src -maxdepth 1 -type f -print | sort
find ui-src -maxdepth 1 -type f -print | sort
```

## Command-by-Command Explanation

| Command | Explanation and purpose |
|---------|-------------------------|
| `cd ~/devops-exam/part2-docker` | Changes the current directory to the Part 2 Docker project. All following relative paths are resolved from this location. |
| `git clone https://bitbucket.org/metawhale/fast-api-clean api-src` | Downloads the FastAPI repository from Bitbucket and places it in a local directory named `api-src`. |
| `git clone https://bitbucket.org/metawhale/nextjs_app ui-src` | Downloads the Next.js repository and places it in a local directory named `ui-src`. |
| `find api-src -maxdepth 1 -type f -print` | Lists files directly inside the API source directory. `-maxdepth 1` avoids listing every nested file, while `-type f` limits the result to regular files. |
| `find ui-src -maxdepth 1 -type f -print` | Performs the same top-level file check for the UI repository. |
| `sort` | Sorts each `find` result so the verification output is easier to read. |

## Important Files Found

```text
API: main.py, database.py, models.py, schemas.py, requirements.txt
UI:  package.json, package-lock.json, next.config.js, app/, components/
```

## Why the Clone Step Was Necessary

The first local execution attempt used image contexts that did not contain the real
application source. The images could be created, but the containers exited because
the application entry points were not present. The correction was to clone the two
Bitbucket repositories before copying the Dockerfiles and building the final images.

| Problem | Cause | Solution |
|---------|-------|----------|
| Container exited immediately during the early local run | The image context did not yet contain the real API/UI application source | Clone the FastAPI and Next.js repositories into `api-src/` and `ui-src/` before building |
| Database choice was unclear | The original setup did not yet match the cloned API's driver | Inspect `requirements.txt` and the API connection string, then use MySQL |

## Result

The two source repositories existed locally and could be used as Docker build
contexts. The Compose file was later configured to use:

```yaml
api:
  build:
    context: ./api-src
ui:
  build:
    context: ./ui-src
```

## 📸 Screenshot

![Clone and verify the API and UI source](screenshots/part2/task02-4-git-clone.png)

---

# Task 2 — Prepare, Inspect, Correct, and Verify the Dockerfiles

## Purpose

The Dockerfiles define how the API and UI become production-style container images.
They specify the base runtime, working directory, dependency installation, build
steps, ports, health checks, security user, and startup command.

The Dockerfiles were first copied into the cloned source directories, then inspected.
The inspection identified missing production steps before the final Docker build.

## Step 2A — Copy the Dockerfiles into the Cloned Source Folders

### Commands Executed

```bash
cd ~/devops-exam/part2-docker

cp api/Dockerfile api-src/Dockerfile
cp ui/Dockerfile ui-src/Dockerfile

ls -l api-src/Dockerfile api-src/requirements.txt
ls -l ui-src/Dockerfile ui-src/package.json
```

### Command-by-Command Explanation

| Command | Explanation and purpose |
|---------|-------------------------|
| `cd ~/devops-exam/part2-docker` | Ensures the `api/`, `ui/`, `api-src/`, and `ui-src/` relative paths are correct. |
| `cp api/Dockerfile api-src/Dockerfile` | Copies the API container definition into the API repository, making `api-src` a complete Docker build context. |
| `cp ui/Dockerfile ui-src/Dockerfile` | Copies the UI container definition into the UI repository. |
| `ls -l api-src/Dockerfile api-src/requirements.txt` | Confirms that the API Dockerfile and its Python dependency file exist. |
| `ls -l ui-src/Dockerfile ui-src/package.json` | Confirms that the UI Dockerfile and its Node package manifest exist. |

### Why Dockerfiles Were Copied into the Source Folders

Docker sends the selected build context to the Docker daemon. By placing each
Dockerfile inside its matching source folder, `COPY` instructions can access the
application source and dependency files without using files outside the build
context.

## Step 2B — Inspect the Dockerfiles Before Building

### Commands Executed

```bash
printf "\nAPI Dockerfile:\n"
cat api-src/Dockerfile

printf "\nUI Dockerfile:\n"
cat ui-src/Dockerfile
```

### Command-by-Command Explanation

| Command | Explanation and purpose |
|---------|-------------------------|
| `printf "\nAPI Dockerfile:\n"` | Prints a label and blank line so the API Dockerfile output is easy to identify. |
| `cat api-src/Dockerfile` | Prints the complete API Dockerfile to the terminal for manual review. |
| `printf "\nUI Dockerfile:\n"` | Prints a label separating the API output from the UI output. |
| `cat ui-src/Dockerfile` | Prints the complete UI Dockerfile for review. |

## Problems Found During Inspection

The inspection was intentionally performed before the build. This prevented a
misconfigured Dockerfile from being treated as a successful production image.

| File | Problem found | Why it mattered | Correction |
|------|---------------|-----------------|------------|
| API Dockerfile | It did not wait for MySQL before starting FastAPI | The API could start before the database was accepting connections | Added a shell loop that checks `db:3306` before launching Uvicorn |
| UI Dockerfile | Missing complete dependency and production build flow | A Next.js production image needs dependencies and a generated `.next` build | Added `COPY package.json package-lock.json`, `npm ci`, `COPY . .`, and `npm run build` |
| UI Dockerfile | Used `node server.js` in the earlier draft | The cloned project is a Next.js app and is started with its package script | Changed the startup command to `npm start` |
| Both images | Earlier contexts did not contain the cloned source | The runtime entry points were absent | Cloned the repositories and built from `api-src` and `ui-src` |

## Step 2C — Correction Commands Executed

The following heredoc commands wrote the corrected Dockerfiles into the cloned
application folders.

```bash
cd ~/devops-exam/part2-docker

cat > api-src/Dockerfile <<'EOF'
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
    && useradd --uid 1001 --gid 1001 \
       --no-create-home --shell /sbin/nologin appuser
WORKDIR /app
COPY --from=builder /install /usr/local
COPY --chown=appuser:appgroup . .
USER appuser
ENV PORT=8000
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/')" || exit 1
CMD ["sh", "-c", "until python -c \"import socket; s=socket.create_connection(('db', 3306), 2); s.close()\"; do sleep 2; done; uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000} --access-log"]
EOF

cat > ui-src/Dockerfile <<'EOF'
FROM node:20-alpine
RUN addgroup --system --gid 1001 nodejs \
    && adduser --system --uid 1001 nextjs
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build
ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    PORT=3000 \
    HOSTNAME=0.0.0.0
USER nextjs
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD wget -qO- http://localhost:3000/ || exit 1
CMD ["npm", "start"]
EOF
```

### Heredoc and Redirection Explanation

| Command or syntax | Explanation and purpose |
|-------------------|-------------------------|
| `cat > api-src/Dockerfile` | Opens or replaces the API Dockerfile and writes the following text to it. `>` redirects the text into the file. |
| `cat > ui-src/Dockerfile` | Writes the UI Dockerfile in the same way. |
| `<<'EOF'` | Starts a quoted heredoc. Every line is written literally until a line containing only `EOF` is reached. |
| `EOF` | Marks the end of each Dockerfile's heredoc input. |
| Quoted `'EOF'` | Prevents the local shell from expanding variables such as `${PORT}` while the Dockerfile is being written. |

## Step 2D — Final Verification Commands

```bash
printf "\nAPI Dockerfile checks:\n"
grep -E "FROM|COPY requirements|USER appuser|HEALTHCHECK|uvicorn" api-src/Dockerfile

printf "\nUI Dockerfile checks:\n"
grep -E "FROM|npm ci|npm run build|USER nextjs|HEALTHCHECK|npm start" ui-src/Dockerfile
```

### Command-by-Command Explanation

| Command | Explanation and purpose |
|---------|-------------------------|
| `printf "\nAPI Dockerfile checks:\n"` | Adds a readable heading for the API verification output. |
| `grep -E "FROM|COPY requirements|USER appuser|HEALTHCHECK|uvicorn" api-src/Dockerfile` | Uses extended regular expressions to print only the important API lines: base stages, dependency copy, non-root user, health check, and startup server. |
| `printf "\nUI Dockerfile checks:\n"` | Adds a heading for the UI verification output. |
| `grep -E "FROM|npm ci|npm run build|USER nextjs|HEALTHCHECK|npm start" ui-src/Dockerfile` | Confirms the UI base image, locked dependency installation, production build, non-root user, health check, and correct Next.js startup command. |
| `|` inside the regular expression | Means “or” in the extended pattern, so one `grep` command can check multiple required lines. |

## Final API Dockerfile

```dockerfile
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
```

### API Dockerfile Line-by-Line Explanation

| Dockerfile line or group | Purpose |
|--------------------------|---------|
| `FROM python:3.11-slim AS builder` | Uses a small Python image for the dependency-building stage and names the stage `builder`. |
| `WORKDIR /build` | Sets the working directory inside the builder container. |
| `RUN apt-get update` | Refreshes the Debian package index inside the builder image. |
| `apt-get install -y --no-install-recommends gcc` | Installs the C compiler required by packages that may need native compilation; `-y` confirms automatically and `--no-install-recommends` avoids unnecessary packages. |
| `rm -rf /var/lib/apt/lists/*` | Removes package indexes after installation to reduce the image layer size. |
| `COPY requirements.txt .` | Copies only the dependency file first, allowing Docker to cache dependency installation when application code changes. |
| `pip install --upgrade pip` | Updates pip in the temporary builder environment. |
| `pip install --prefix=/install --no-cache-dir -r requirements.txt` | Installs the exact API dependencies into `/install`; `--no-cache-dir` avoids retaining pip's download cache. |
| `FROM python:3.11-slim AS runtime` | Starts a clean runtime stage, leaving compiler packages out of the final image. |
| `groupadd --gid 1001 appgroup` | Creates a dedicated application group with a fixed numeric ID. |
| `useradd --uid 1001 ... appuser` | Creates a non-root runtime user with no login shell and no unnecessary home directory. |
| `WORKDIR /app` | Sets the runtime application directory. |
| `COPY --from=builder /install /usr/local` | Copies only installed Python packages from the builder stage into the runtime image. |
| `COPY --chown=appuser:appgroup . .` | Copies the cloned API source and assigns ownership to the non-root application user. |
| `USER appuser` | Runs the API as an unprivileged user instead of root, satisfying the security guideline. |
| `ENV PORT=8000` | Defines the default API port inside the image. |
| `EXPOSE 8000` | Documents the port on which the API listens. It does not publish the port by itself; Compose or `docker run -p` does that. |
| `HEALTHCHECK --interval=30s ...` | Tells Docker to test the API every 30 seconds, allowing the container status to become `healthy` or `unhealthy`. |
| `urllib.request.urlopen('http://localhost:8000/')` | Checks the actual root endpoint exposed by the cloned application. |
| `|| exit 1` | Makes a failed HTTP check return a failure status to Docker. |
| `CMD ["sh", "-c", "..."]` | Starts a shell command so the database wait loop can run before the API server. |
| `socket.create_connection(('db', 3306), 2)` | Tests whether the Compose service named `db` accepts TCP connections on MySQL port `3306`. |
| `while ...; do sleep 2; done` | Repeats the database check every two seconds until the database is reachable. |
| `uvicorn main:app` | Starts the FastAPI application object named `app` in `main.py`. |
| `--host 0.0.0.0` | Makes the API reachable from outside the container through the published port. |
| `--port ${PORT:-8000}` | Uses the `PORT` environment variable, defaulting to `8000`. |
| `--access-log` | Enables request logging for troubleshooting and verification. |

## Final UI Dockerfile

```dockerfile
# Next.js frontend container built from the cloned Bitbucket application.
FROM node:20-alpine AS builder

RUN addgroup --system --gid 1001 nodejs \
    && adduser --system --uid 1001 nextjs

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    PORT=3000 \
    HOSTNAME=0.0.0.0

USER nextjs

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD wget -qO- http://localhost:3000/ || exit 1

CMD ["npm", "start"]
```

### UI Dockerfile Line-by-Line Explanation

| Dockerfile line or group | Purpose |
|--------------------------|---------|
| `FROM node:20-alpine AS builder` | Uses a small Node.js Alpine image and names the build stage. |
| `addgroup --system --gid 1001 nodejs` | Creates a system group for the UI process. |
| `adduser --system --uid 1001 nextjs` | Creates the non-root user that runs the final UI process. |
| `WORKDIR /app` | Sets the working directory for the Next.js project. |
| `COPY package.json package-lock.json ./` | Copies dependency manifests before application source so the `npm ci` layer can be cached. |
| `RUN npm ci` | Installs the exact locked dependency versions from `package-lock.json`, producing reproducible builds. |
| `COPY . .` | Copies the cloned Next.js source into the image. |
| `RUN npm run build` | Runs the project's `next build` script and creates an optimized production build. |
| `NODE_ENV=production` | Marks the runtime as production mode. |
| `NEXT_TELEMETRY_DISABLED=1` | Disables Next.js anonymous telemetry in the container. |
| `PORT=3000` | Sets the UI listening port. |
| `HOSTNAME=0.0.0.0` | Makes Next.js listen on all container interfaces. |
| `USER nextjs` | Runs the application as a non-root user. |
| `EXPOSE 3000` | Documents the port used by the Next.js server. |
| `HEALTHCHECK ... wget -qO-` | Requests the UI root page and marks the container unhealthy if the request fails. |
| `--interval=30s` | Runs the health check every 30 seconds. |
| `--timeout=10s` | Gives each check up to 10 seconds. |
| `--start-period=30s` | Allows the UI time to start before failures count. |
| `--retries=3` | Requires three failed checks before Docker marks the container unhealthy. |
| `CMD ["npm", "start"]` | Starts the cloned Next.js application using the script defined in `package.json`. |

## 📸 Screenshots

![Dockerfiles copied into the cloned application folders](screenshots/part2/task02-6-copy-dockerfiles.png)

![Dockerfiles inspected before build](screenshots/part2/task02-7-dockerfile-check.png)

---

# Task 3 — Build the API and UI Images

## Purpose

This task verifies that both application images can be built independently and
through Compose. A successful build proves that Docker can obtain the base images,
install dependencies, copy the source, and produce tagged images.

## Step 3A — Initial API Image Build

### Command Executed

```bash
cd ~/devops-exam/part2-docker
docker build -t api-app:latest ./api
```

### Command Explanation

| Command or option | Purpose |
|-------------------|---------|
| `cd ~/devops-exam/part2-docker` | Enters the Docker project directory. |
| `docker build` | Builds an image from a Dockerfile. |
| `-t api-app:latest` | Tags the resulting image with repository name `api-app` and tag `latest`. |
| `./api` | Uses the `api` folder as the build context. |

### Recorded Result

```text
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
Successfully built 1ca9c3c0e40e
Successfully tagged api-app:latest
```

The initial API image build succeeded. The legacy builder message was a warning
about the installed Docker tooling, not a build failure.

## Step 3B — Source-Based Compose Build

After the repositories were cloned and the Dockerfiles corrected, the final build
was performed from the real source folders:

```bash
cd ~/devops-exam/part2-docker
docker-compose build
```

### Command Explanation

| Command or option | Purpose |
|-------------------|---------|
| `docker-compose build` | Reads `docker-compose.yml` and builds every service that has a `build` section. |
| `db uses an image, skipping` | Confirms that the database uses a prebuilt `mysql:8.0` image instead of a local Dockerfile. |
| `Building api` | Builds the API from `./api-src`. |
| `Building ui` | Builds the UI from `./ui-src`. |
| `Sending build context to Docker daemon` | Transfers the selected source folder and Dockerfile to Docker for the build. |
| `Step n/m` | Shows Docker executing each Dockerfile instruction. |
| `Using cache` | Reuses an unchanged layer instead of rebuilding it. |
| `Removed intermediate container` | Removes temporary containers used to create image layers. |
| `Successfully built` | Confirms the image was created. |
| `Successfully tagged` | Confirms the image received its configured tag. |

### API Build Output

```text
Successfully installed PyMySQL-1.1.0 SQLAlchemy-2.0.22
fastapi-0.104.0 ... uvicorn-0.23.2
Successfully built 2d0f3bd5508a
Successfully tagged api-app:latest
```

### UI Build Output

```text
added 276 packages, and audited 277 packages in 22s
13 vulnerabilities (4 moderate, 8 high, 1 critical)
✓ Compiled successfully
✓ Generating static pages (5/5)
Successfully built 2a7aab427a68
Successfully tagged ui-app:latest
```

The UI completed the Next.js production build despite dependency audit warnings.
The warnings were recorded below and were not silent.

## Step 3C — Direct UI Build Command

The independent UI build command required by the exam was also used during the
initial local build phase:

```bash
docker build -t ui-app:latest ./ui
```

| Part | Purpose |
|------|---------|
| `docker build` | Builds the UI image. |
| `-t ui-app:latest` | Gives the image a reusable name and tag. |
| `./ui` | Selects the UI Dockerfile and build context. |

The successful UI build and tag were recorded in the Part 2 build evidence.

## Build Warnings and Their Meaning

| Warning or notice | What it meant | Impact |
|-------------------|---------------|--------|
| `DEPRECATED: The legacy builder is deprecated` | Docker was using the installed legacy builder rather than BuildKit | The build still completed successfully; it is a tooling upgrade notice |
| `debconf: unable to initialize frontend` | The image build has no interactive terminal or `TERM` setting | Package installation continued in non-interactive mode |
| `WARNING: Running pip as the 'root' user` | pip ran as root in the temporary builder stage | The final runtime uses `appuser`; this warning did not apply to the final process |
| `13 vulnerabilities (4 moderate, 8 high, 1 critical)` | npm reported vulnerabilities in the cloned dependency tree | The image still built; the finding should be reviewed in a future dependency-maintenance task |
| `npm notice New major version` | npm reported that a newer npm release exists | Informational only |
| `Browserslist: caniuse-lite is outdated` | Browser compatibility data was older than the current release | The Next.js production build still completed |
| Next.js telemetry notice | Next.js explained its anonymous telemetry behavior | `NEXT_TELEMETRY_DISABLED=1` was set in the final image |

## Build Problems Solved

| Problem | Why it occurred | Fix |
|---------|-----------------|-----|
| Images could build but local containers exited | The early build context did not contain the cloned application entry points | Clone both Bitbucket repositories and build from `api-src` and `ui-src` |
| UI Dockerfile was not production-complete | It lacked locked dependency installation and `next build` | Added `npm ci`, `COPY . .`, and `npm run build` |
| API could race the database startup | Compose services can start at different times | Added the API database connection wait loop |
| UI startup command did not match the app | `node server.js` was not the correct entry point for the cloned Next.js app | Changed to `npm start` |

## 📸 Screenshots

![API image build output](screenshots/part2/task02-1-api-build.png)

![UI Dockerfile setup and build start](screenshots/part2/task02-2-ui-build-1.png)

![UI build complete and tagged](screenshots/part2/task02-2-ui-build-2.png)

![Both images built from the cloned source](screenshots/part2/task02-4-build-both.png)

---

# Task 4 — Local Execution and Docker Compose

## Purpose

This task verifies the complete application stack, not just the images. The final
stack contains:

| Service | Image/build source | Published port | Purpose |
|---------|--------------------|---------------:|---------|
| `api` | `api-app:latest`, built from `./api-src` | `8000:8000` | FastAPI backend |
| `ui` | `ui-app:latest`, built from `./ui-src` | `3000:3000` | Next.js frontend |
| `db` | `mysql:8.0` | Internal `3306` | MySQL database |

The API and UI are published to the WSL host. The database is intentionally kept
internal to the Docker network instead of being published directly.

## Step 4A — Early Local Execution Attempt

The first local execution attempt used the independently built images before the
Bitbucket source was present in their build contexts:

```bash
docker images | grep -E "api-app|ui-app"
docker run -d -p 8000:8000 --name devops_api api-app:latest
docker run -d -p 3000:3000 --name devops_ui ui-app:latest
docker ps
```

### Command Explanation

| Command | Purpose |
|---------|---------|
| `docker images` | Lists locally available Docker images. |
| `grep -E "api-app|ui-app"` | Filters the image list to the API and UI tags. |
| `docker run -d` | Creates and starts a container in detached/background mode. |
| `-p 8000:8000` | Maps host port `8000` to container port `8000`. |
| `-p 3000:3000` | Maps host port `3000` to container port `3000`. |
| `--name devops_api` | Assigns a readable name to the API container. |
| `--name devops_ui` | Assigns a readable name to the UI container. |
| `docker ps` | Lists currently running containers. |

### Problem Encountered

The containers exited instead of remaining in `docker ps`. The images existed, but
the real application files were not yet in the image context. This was the reason
the clone step had to happen before repeating local execution.

| Observation | Meaning |
|-------------|---------|
| Image was listed by `docker images` | The image creation step succeeded |
| Container was not listed by `docker ps` | The container process had already exited |
| No usable API/UI response | The image did not contain the expected application entry point |

### Solution

The Bitbucket API and UI repositories were cloned into `api-src/` and `ui-src/`,
the Dockerfiles were copied into those folders, and both images were rebuilt from
the real application source. The final execution was then performed with Compose.

## Step 4B — First Compose Configuration Command

### Command Executed

```bash
docker compose config
```

### Error Encountered

```text
docker: unknown command: docker compose
```

### Cause

The WSL installation had the older standalone Compose executable
`docker-compose` version `1.29.2`. It did not support the newer space-separated
syntax `docker compose`.

### Solution

Use the hyphenated command supported by the installed version:

```bash
docker-compose config
```

### Command Explanation

| Command | Purpose |
|---------|---------|
| `docker compose config` | Newer Docker Compose plugin syntax; unavailable in this environment. |
| `docker-compose config` | Legacy Compose syntax that renders and validates the Compose configuration. |

This was a command compatibility problem, not an application or YAML problem.

## Step 4C — First Compose Startup Problem

### Command Executed

```bash
docker-compose up -d
```

### Error Encountered

```text
ERROR: for devops_db  'ContainerConfig'
ERROR: for db  'ContainerConfig'
KeyError: 'ContainerConfig'
```

### Container Status at the Time

```text
04417543e677_devops_db   docker-entrypoint.sh postgres   Exit 255
devops_api               sh -c uvicorn main:app --h ...  Exit 255
devops_ui                docker-entrypoint.sh npm start   Exit 255
```

### Evidence from the Logs

```text
The files belonging to this database system will be owned by user "postgres".
PostgreSQL 15.18
listening on ... port 5432
```

### Diagnosis

An old PostgreSQL container from the earlier setup was still present. The current
cloned FastAPI application required MySQL through `mysql+pymysql`, while the old
container was PostgreSQL on port `5432`. In addition, legacy Compose encountered a
`ContainerConfig` metadata error while attempting to recreate the stale container.

This produced multiple symptoms:

```text
curl: (7) Failed to connect to localhost port 8000
curl: (7) Failed to connect to localhost port 3000
```

The API and UI were not available through the expected host ports during that failed
run.

## Step 4D — Cleanup and Configuration Correction

### Cleanup Command Executed

```bash
docker rm -f devops_db devops_api devops_ui 04417543e677_devops_db 2>/dev/null || true
```

### Command Explanation

| Command or syntax | Purpose |
|-------------------|---------|
| `docker rm` | Removes stopped containers. |
| `-f` | Forces removal, including running containers. |
| `devops_db devops_api devops_ui` | Removes the named application/database containers. |
| `04417543e677_devops_db` | Removes the older generated Compose container name seen in `docker-compose ps`. |
| `2>/dev/null` | Hides expected “container not found” messages when a named container is already absent. |
| `|| true` | Allows the cleanup line to finish without stopping if one listed container does not exist. |

The cleanup removed stale containers only. It did not delete the cloned source
folders or the named database volume.

### Corrected Database Settings

```yaml
image: mysql:8.0
MYSQL_ROOT_PASSWORD: password
MYSQL_DATABASE: testdb
DB_CONNECTION_STRING: mysql+pymysql://root:password@db:3306/testdb
```

| Setting | Purpose |
|---------|---------|
| `image: mysql:8.0` | Uses the database engine required by the cloned API. |
| `MYSQL_ROOT_PASSWORD: password` | Sets the root password used by the local exam database. |
| `MYSQL_DATABASE: testdb` | Creates the database expected by the API connection string. |
| `DB_CONNECTION_STRING=...` | Tells the API to connect to the Compose service named `db`, port `3306`, database `testdb`. |

## Step 4E — Final Compose Configuration

### Command Executed

```bash
cd ~/devops-exam/part2-docker
docker-compose config
```

### Final Configuration Values Confirmed

```text
image: mysql:8.0
MYSQL_DATABASE: testdb
DB_CONNECTION_STRING: mysql+pymysql://root:password@db:3306/testdb
```

The configuration rendered successfully with the correct MySQL image and API
connection string.

## Step 4F — Final Stack Startup

### Commands Executed

```bash
docker-compose up -d
docker-compose ps
```

### Command Explanation

| Command | Purpose |
|---------|---------|
| `docker-compose up` | Creates and starts the services defined in the Compose file. |
| `-d` | Runs the services in detached/background mode. |
| `docker-compose ps` | Shows service names, commands, state, health, and published ports. |

### Final Status

```text
devops_api   Up (healthy)   0.0.0.0:8000->8000/tcp
devops_db    Up (healthy)   3306/tcp
devops_ui    Up (healthy)   0.0.0.0:3000->3000/tcp
```

This was the successful final state. All three services were running and healthy.

## Step 4G — Log Inspection

### Commands Executed

```bash
docker-compose logs --tail=100
docker-compose logs db
docker-compose logs api
docker-compose logs ui
```

### Command Explanation

| Command | Purpose |
|---------|---------|
| `docker-compose logs` | Displays logs from the Compose services. |
| `--tail=100` | Limits the combined output to the latest 100 lines per service. |
| `docker-compose logs db` | Shows only database logs. |
| `docker-compose logs api` | Shows only FastAPI logs. |
| `docker-compose logs ui` | Shows only Next.js logs. |

### Important Final Log Results

```text
API: Uvicorn running on http://0.0.0.0:8000
UI:  Next.js 13.5.6 — Ready
DB:  MySQL ready
```

The API wait loop allowed the API to start only after the database network endpoint
was reachable.

## Step 4H — API and UI Verification

### Commands Executed

```bash
curl http://localhost:8000/
curl http://localhost:3000/
curl http://localhost:8000/trip
```

### Recorded Results

```json
{"message":"Fast Api Exam api v1"}
[]
```

The API root responded with its expected message. The `/trip` endpoint returned an
empty array because the database was reachable but did not yet contain trip records.
An empty array was therefore a valid application response, not an error.

The UI returned an HTML document beginning with the Next.js page:

```html
<!DOCTYPE html><html lang="en">
...
<h1>Next.js Data App</h1>
...
```

The full response contained the generated Next.js CSS, JavaScript chunks, page title,
and rendered application markup. This confirmed that the production Next.js server
was serving the application.

### Command Explanation

| Command | Purpose |
|---------|---------|
| `curl http://localhost:8000/` | Sends an HTTP request to the published API port and verifies the root endpoint. |
| `curl http://localhost:3000/` | Sends an HTTP request to the published UI port and verifies the Next.js page. |
| `curl http://localhost:8000/trip` | Verifies that the API can reach and query the database-backed trip route. |

## Step 4I — Create and Read a Test Record

### Commands Executed

```bash
curl -X POST http://localhost:8000/trip \
  -H "Content-Type: application/json" \
  -d '{"name":"Docker Test Trip","description":"Test record from Docker","joiner_total_count":1}'

curl http://localhost:8000/trip
```

### Command Explanation

| Command or option | Purpose |
|-------------------|---------|
| `curl -X POST` | Sends a POST request to create a record. |
| `http://localhost:8000/trip` | Selects the API trip endpoint. |
| `-H "Content-Type: application/json"` | Tells FastAPI that the request body is JSON. |
| `-d '{...}'` | Sends the JSON payload containing the trip name, description, and joiner count. |
| Second `curl` request | Reads the trip endpoint again to verify that the record was persisted and can be returned. |

### Result

The API returned the created `Docker Test Trip` record successfully, and the
subsequent GET request returned the stored trip data. This proved that the test was
not only an HTTP test: it also verified API-to-MySQL communication and persistence.

## Step 4J — Final Container Check

### Command Executed

```bash
docker ps
```

### Command Explanation

| Command | Purpose |
|---------|---------|
| `docker ps` | Lists running containers and shows their image, command, status, and port mappings. |

### Final Output

```text
devops_api     api-app:latest   Up (healthy)   0.0.0.0:8000->8000/tcp
devops_db      mysql:8.0        Up (healthy)   3306/tcp
devops_ui      ui-app:latest    Up (healthy)   0.0.0.0:3000->3000/tcp
```

## Complete Troubleshooting Record

This section collects every documented problem from the Part 2 execution so the
troubleshooting process is clear during the exam presentation.

| # | Error/problem encountered | Evidence | Root cause | Solution | Final result |
|---:|---------------------------|----------|------------|----------|--------------|
| 1 | Containers exited during early `docker run` execution | `docker ps` did not retain the API/UI containers | Images were built before the real Bitbucket source was present | Clone both repositories and build from `api-src` and `ui-src` | Source-based images ran successfully |
| 2 | `docker: unknown command: docker compose` | `docker compose config` output | Installed Compose was the legacy hyphenated executable | Use `docker-compose config` | Configuration validation succeeded |
| 3 | `KeyError: 'ContainerConfig'` | `docker-compose up -d` traceback | Legacy Compose attempted to recreate stale container metadata | Remove stale containers and recreate the stack | Compose recreated services successfully |
| 4 | PostgreSQL appeared instead of MySQL | Logs showed PostgreSQL 15 on port `5432` | An old database container remained from an earlier setup | Use `mysql:8.0` and `mysql+pymysql` settings | MySQL became healthy on internal port `3306` |
| 5 | API/UI `Exit 255` and curl connection failures | `docker-compose ps` and curl output | The stack was using stale/incompatible containers during the failed run | Clean containers, rebuild from real source, and start corrected Compose stack | API and UI responded on ports `8000` and `3000` |
| 6 | Legacy Compose `watch_events` raised `KeyError: 'id'` | Attached `docker-compose up --build` log | Old Python Compose event handling encountered a Docker event without the expected ID | Use detached startup and verify with `ps`, logs, health checks, and curl | Final detached Compose run was healthy |
| 7 | `debconf` frontend warnings | API image build log | Docker build has no interactive terminal | Allow non-interactive package installation to continue | Build completed |
| 8 | pip root warning | API builder log | Dependencies were installed as root in the temporary builder stage | Keep the final runtime process under `appuser` | Runtime was non-root |
| 9 | npm vulnerability audit warning | UI image build log | The cloned dependency tree contained reported vulnerabilities | Record the warning for dependency review; do not hide it | UI production build completed |
| 10 | Outdated Browserslist data | Next.js build log | Browser compatibility database was old | Record the maintenance notice | Next.js compiled successfully |

## What Was Actually Solved

| Solution | Why it was important |
|----------|----------------------|
| Cloned the two Bitbucket applications before running the containers | Docker needed the real application code and entry points |
| Copied Dockerfiles into the cloned source directories | Each directory became a self-contained build context |
| Added API multi-stage dependency installation | Build-only tooling stayed out of the final runtime stage |
| Added non-root users | Reduced the security risk of running application processes as root |
| Added API and UI health checks | Docker could report whether the services were actually responding |
| Added the API database wait loop | Prevented a startup race between FastAPI and MySQL |
| Changed UI startup to `npm start` | Matched the cloned Next.js application |
| Replaced stale PostgreSQL with MySQL | Matched the API's `mysql+pymysql` driver and connection string |
| Removed stale containers | Prevented legacy Compose from reusing incompatible metadata and configuration |
| Used `docker-compose` instead of `docker compose` | Matched the Compose command installed in WSL |
| Verified both empty and populated `/trip` responses | Distinguished a valid empty database response from an application failure |

## 📸 Screenshots

![Initial setup and Dockerfile creation](screenshots/part2/task02-0-setup.png)

![Local image and container execution checks](screenshots/part2/task02-3-local-execution.png)

![Second local execution evidence](screenshots/part2/task02-3-local-execution-2.png)

![Compose configuration with MySQL](screenshots/part2/task02-4-docker-compose.png)

![Database and application startup logs](screenshots/part2/task02-4-docker-compose-2.png)

![Earlier startup problem and correction](screenshots/part2/task02-4-docker-compose-3.png)

![All services running](screenshots/part2/task02-4-all-running.png)

![Final healthy container status](screenshots/part2/task02-4-docker-ps.png)

![API response in the browser](screenshots/part2/task02-4-api-browser.png)

![UI response in the browser](screenshots/part2/task02-4-ui-browser.png)

![Dockerfile and source file check](screenshots/part2/task02-5-file-check.png)

---

# Docker Compose File — Full Explanation

The final `docker-compose.yml` combines the API, UI, and MySQL database into one
local stack.

## Full Compose File

```yaml
# docker-compose.yml
# Local development: run API + UI together with one command
# Usage: docker-compose up --build

services:

  # API – FastAPI backend
  api:
    build:
      context: ./api-src
      dockerfile: Dockerfile
    image: api-app:latest
    container_name: devops_api
    restart: unless-stopped
    ports:
      - "8000:8000"
    environment:
      - PORT=8000
      - DB_CONNECTION_STRING=${DB_CONNECTION_STRING:-mysql+pymysql://root:password@db:3306/testdb}
      - DEBUG=${DEBUG:-false}
    depends_on:
      db:
        condition: service_started
    healthcheck:
      test: ["CMD", "python", "-c",
             "import urllib.request; urllib.request.urlopen('http://localhost:8000/')"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 15s
    networks:
      - app-network

  # UI – Next.js frontend
  ui:
    build:
      context: ./ui-src
      dockerfile: Dockerfile
    image: ui-app:latest
    container_name: devops_ui
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL:-http://localhost:8000}
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

  # Database – MySQL required by the cloned FastAPI application
  db:
    image: mysql:8.0
    container_name: devops_db
    restart: unless-stopped
    environment:
      - MYSQL_ROOT_PASSWORD=password
      - MYSQL_DATABASE=testdb
    volumes:
      - mysql-data:/var/lib/mysql
    healthcheck:
      test: ["CMD-SHELL", "mysqladmin ping -h localhost -uroot -p$${MYSQL_ROOT_PASSWORD} --silent"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network
    # The database is not exposed outside the internal Docker network.

networks:
  app-network:
    driver: bridge

volumes:
  mysql-data:
```

## Compose Line-by-Line Explanation

| Compose line or group | Purpose |
|-----------------------|---------|
| `services:` | Begins the list of containers managed by Compose. |
| `api:` | Defines the FastAPI service. Other services can refer to it by the name `api`. |
| `build:` | Tells Compose to build an image rather than only pulling one. |
| `context: ./api-src` | Uses the cloned API repository as the build context. |
| `dockerfile: Dockerfile` | Uses the Dockerfile inside `api-src`. |
| `image: api-app:latest` | Names and tags the built API image. |
| `container_name: devops_api` | Gives the API container a predictable name for logs and troubleshooting. |
| `restart: unless-stopped` | Restarts the service after a failure unless it was deliberately stopped. |
| `"8000:8000"` | Publishes host port `8000` to container port `8000`. |
| `PORT=8000` | Supplies the API port environment variable. |
| `DB_CONNECTION_STRING=...` | Supplies the MySQL connection string; `${...:-default}` uses an external value when provided and otherwise uses the local default. |
| `DEBUG=${DEBUG:-false}` | Defaults debug mode to false while allowing an environment override. |
| `depends_on: db` | Starts the API after Compose has started the database service. |
| `condition: service_started` | Waits for the database container to start; the API Dockerfile's TCP loop handles actual database reachability. |
| API `healthcheck.test` | Runs a Python HTTP request against the API root endpoint. |
| `interval: 30s` | Checks API health every 30 seconds. |
| `timeout: 10s` | Allows 10 seconds for each API check. |
| `retries: 3` | Requires three failures before the service is marked unhealthy. |
| `start_period: 15s` | Gives the API time to start before health failures count. |
| `networks: app-network` | Places the API on the shared bridge network. |
| `ui:` | Defines the Next.js frontend service. |
| `context: ./ui-src` | Uses the cloned UI repository as the UI build context. |
| `image: ui-app:latest` | Names and tags the built UI image. |
| `container_name: devops_ui` | Gives the UI container a predictable name. |
| UI `restart: unless-stopped` | Restarts the UI after an unexpected process failure. |
| `"3000:3000"` | Publishes host port `3000` to container port `3000`. |
| `NODE_ENV=production` | Runs the UI in production mode. |
| `NEXT_PUBLIC_API_URL=http://localhost:8000` | Gives browser-side code a host-accessible API URL. |
| `PORT=3000` | Sets the Next.js listening port. |
| `depends_on: api` | Starts the UI after the API container has started. |
| UI `healthcheck.test` | Uses `wget` to request the UI root page. |
| UI `start_period: 20s` | Allows time for Next.js to start before health failures count. |
| `db:` | Defines the database service. Other containers reach it as `db`. |
| `image: mysql:8.0` | Uses the MySQL version compatible with the API's `PyMySQL` driver. |
| `container_name: devops_db` | Gives the database container a predictable name. |
| `MYSQL_ROOT_PASSWORD=password` | Configures the local MySQL root password. |
| `MYSQL_DATABASE=testdb` | Creates the database used by the API. |
| `mysql-data:/var/lib/mysql` | Persists MySQL data in a named Docker volume. |
| Database `healthcheck.test` | Runs `mysqladmin ping` to verify that MySQL accepts connections. |
| `-p$${MYSQL_ROOT_PASSWORD}` | Uses `$$` so Compose passes the variable for expansion inside the container rather than expanding it prematurely. |
| Database `interval: 10s` | Checks database health every 10 seconds. |
| Database `timeout: 5s` | Allows five seconds per database health check. |
| Database `retries: 5` | Requires five failed checks before unhealthy status. |
| Database network entry | Keeps MySQL reachable by the API on the internal network. |
| No database `ports` mapping | Prevents direct host access to MySQL; only the API needs database access. |
| `networks:` | Declares custom networks used by the services. |
| `app-network:` | Names the shared application network. |
| `driver: bridge` | Creates a Docker bridge network for service-to-service communication. |
| `volumes:` | Declares named persistent storage. |
| `mysql-data:` | Names the volume storing MySQL data across container recreation. |

## Compose Design Decisions

| Decision | Reason |
|----------|--------|
| MySQL instead of PostgreSQL | The cloned FastAPI source uses `mysql+pymysql` |
| Internal database port only | Reduces unnecessary host exposure |
| Named volume | Preserves database records when the database container is recreated |
| Service names `api`, `ui`, and `db` | Provides stable DNS names inside the Compose network |
| Health checks | Converts “process exists” into a useful service health signal |
| `service_started` plus API wait loop | Handles both Compose startup ordering and actual MySQL readiness |
| Non-root application users | Follows the exam's container security guidance |

---

## Part 2 Completion Summary

| Task | Description | Status |
|------|-------------|--------|
| Task 1 | Clone and verify the FastAPI and Next.js application source | ✅ Complete |
| Task 2 | Copy, inspect, correct, and verify both Dockerfiles | ✅ Complete |
| Task 3 | Build API and UI images independently and through Compose | ✅ Complete |
| Task 4 | Run API, UI, and MySQL with Docker Compose | ✅ Complete |
| Task 4 | Verify API root endpoint | ✅ Complete |
| Task 4 | Verify UI root page | ✅ Complete |
| Task 4 | Verify database-backed `/trip` endpoint | ✅ Complete |
| Task 4 | Create and retrieve a test trip record | ✅ Complete |
| Task 4 | Confirm all containers are `Up (healthy)` | ✅ Complete |
| Troubleshooting | Document all errors, warnings, problems, and fixes | ✅ Complete |

**All Part 2 requirements were completed and documented. Part 2 — DONE ✅**

---

## Screenshot Checklist

| Screenshot | Filename | What it proves | Status |
|------------|----------|----------------|--------|
| Initial Docker setup | `task02-0-setup.png` | Initial folder and Dockerfile setup | ✅ Present |
| API image build | `task02-1-api-build.png` | API Dockerfile build output | ✅ Present |
| UI build start | `task02-2-ui-build-1.png` | UI Dockerfile setup and build start | ✅ Present |
| UI build complete | `task02-2-ui-build-2.png` | UI image successfully built and tagged | ✅ Present |
| Local execution | `task02-3-local-execution.png` | Local image/container execution evidence | ✅ Present |
| Local execution follow-up | `task02-3-local-execution-2.png` | Second local execution check | ✅ Present |
| Clone and source verification | `task02-4-git-clone.png` | Bitbucket repositories and source files | ✅ Present |
| Both images built | `task02-4-build-both.png` | Source-based API and UI image builds | ✅ Present |
| Compose configuration | `task02-4-docker-compose.png` | Compose services and MySQL configuration | ✅ Present |
| Compose startup logs | `task02-4-docker-compose-2.png` | Database and application startup logs | ✅ Present |
| Earlier Compose problem | `task02-4-docker-compose-3.png` | PostgreSQL/legacy-container problem and correction | ✅ Present |
| All services running | `task02-4-all-running.png` | API, UI, and database running together | ✅ Present |
| Final container status | `task02-4-docker-ps.png` | All containers `Up (healthy)` | ✅ Present |
| API browser test | `task02-4-api-browser.png` | FastAPI root response | ✅ Present |
| UI browser test | `task02-4-ui-browser.png` | Next.js frontend response | ✅ Present |
| Source file check | `task02-5-file-check.png` | Docker setup and source files checked | ✅ Present |
| Dockerfiles copied | `task02-6-copy-dockerfiles.png` | Dockerfiles placed in cloned source folders | ✅ Present |
| Dockerfiles inspected | `task02-7-dockerfile-check.png` | Dockerfile review before build | ✅ Present |

---

## Final Learning Summary

Part 2 demonstrated that successful containerization is more than writing a
Dockerfile. The application source, database driver, service startup order, ports,
container health, and installed Docker tooling must all agree.

The most important troubleshooting lesson was to follow the evidence:

1. The image can exist even when its container exits.
2. A container can log “ready” while the host request still fails if the wrong
   container or port mapping is being used.
3. A Compose metadata error can come from stale containers rather than invalid
   application code.
4. Database image and application connection driver must match.
5. Warnings should be recorded and explained separately from actual failures.
