# 📍 Exam Progress Checkpoint

**Candidate:** draiimon  
**Machine:** Aloof — WSL2 (Ubuntu 24.04 on Windows)  
**Exam:** Junior DevOps Engineer Exam 2026  
**Last Updated:** August 8, 2026

> ⚠️ **For the next maintainer:** Read this file FIRST before doing anything. It tells you exactly where we are, what's done, what's pending, and the rules to follow. Cross-reference everything against the exam PDF at `documentation/reference/Junior_DevOps_Engineer_Exam_2026.pdf`.

---

## 📋 Exam Reference

**PDF:** `documentation/reference/Junior_DevOps_Engineer_2026.pdf`
**Source Apps (Bitbucket):**
- API: https://bitbucket.org/metawhale/fast-api-clean
- UI: https://bitbucket.org/metawhale/nextjs_app

---

## 📁 Folder Structure (current state)

```
repository-root/
├── CHECKPOINT.md                                     ← YOU ARE HERE
├── README.md                                         ← Main overview + architecture
├── Makefile
├── documentation/
│   ├── Part1-Linux-Basics-Documentation.md           ✅ Complete — now formatted consistently with Part 2
│   ├── Part2-Docker-Containerization-Documentation.md  ✅ Complete
│   ├── Part3-CICD-Documentation.md                   ⏳ Pending — begin local walkthrough
│   ├── Part4-HA-Documentation.md                     ⏳ Pending — create after Part 3 verification
│   └── screenshots/
│       ├── part1/   ← 11 screenshots present
│       └── part2/   ← 14 screenshots present (all done)
├── part1-linux/
│   ├── system_health.sh       ✅ chmod +x already applied
│   ├── backup.sh              ✅ chmod +x already applied
│   ├── log_analysis.sh        ✅ chmod +x already applied
│   └── scripting_demo.sh      ✅ chmod +x already applied
├── part2-docker/
│   ├── api/
│   │   ├── Dockerfile         ✅ Multi-stage, non-root (appuser), HEALTHCHECK
│   │   └── requirements.txt   ✅
│   ├── api-src/               ✅ Cloned FastAPI application source
│   ├── ui/
│   │   └── Dockerfile         ✅ production build, non-root (nextjs), HEALTHCHECK
│   ├── ui-src/                ✅ Cloned Next.js application source
│   └── docker-compose.yml     ✅ 3-service (api + ui + MySQL db), named network, healthchecks
├── .github/
│   └── workflows/
│       └── deploy.yml                               ⏳ Created locally in Step 8; not yet pushed
├── part3-cicd/                                      ⏳ Retained as an empty legacy directory
├── part4-ha/
│   ├── k8s/                   ✅ Full Kubernetes manifests (8 files)
│   ├── helm/                  ✅ Helm chart + values.yaml + values.staging.yaml
│   └── argocd/
│       └── application.yaml   ✅ ArgoCD GitOps manifest
└── k9s/                       ✅ k9s config (aliases, hotkeys)
```

---

## ✅ PART 1 — Linux Basics — FULLY COMPLETE ✅

**Documentation file:** `documentation/Part1-Linux-Basics-Documentation.md` ✅ Complete — now formatted consistently with Part 2
**Scripts folder:** `part1-linux/` — all 4 scripts present and executable

### PDF Alignment Check (Part 1)

| PDF Requirement | Our Coverage | Status |
|-----------------|-------------|--------|
| Task 1: File & Directory Management | `mkdir -p`, `touch`, `cp`, `mv`, `ln -s`, `find`, `du -sh` | ✅ |
| Task 2: Permissions & Ownership | `chmod 755`, `chmod u+x`, `chmod 600`, `chown` | ✅ |
| Task 3: Text Processing & Searching | `grep`, `grep -E`, `find`, `cat`, `head`, `tail`, `tail -f`, `wc`, `sort`, `uniq` | ✅ |
| Task 4: Process Management | `ps aux`, `top -bn1`, `free -h`, `sleep &`, `jobs`, `kill %1`, `uptime` | ✅ |
| Task 5: Networking Basics | `ip addr`, `ping`, `ss -tuln`, `nslookup`, `curl -O`, `ip route` | ✅ |
| Task 6: Package Management | `apt update`, `apt install`, `apt remove`, `apt search`, `dpkg -l` | ✅ |
| Task 7: System Information | `uname -a`, `df -h`, `du -sh`, `free -h`, `uptime`, `journalctl` | ✅ |
| Task 8: User & Group Management | `useradd`, `groupadd`, `usermod -aG`, `id`, `whoami`, `su -` | ✅ |
| Task 9: Archiving & Compression | `tar -cvf`, `tar -czvf`, `tar -xzvf`, `gzip`, `zip -r`, `unzip` | ✅ |
| Task 10: Shell Scripting | Variables, `if/else`, `for`, `while`, `>`, `>>`, pipes `\|` | ✅ |
| Example Task 1: Log Analysis (system_health.sh) | `system_health.sh` — date, uptime, CPU, memory, top 5 processes, disk | ✅ |
| Example Task 2: System Health Script | Covered by `system_health.sh` | ✅ |
| Example Task 3: File Backup Automation | `backup.sh` — timestamped tar.gz + 7-day cleanup | ✅ |
| Example Task 4: User & Permission Management | Covered in Task 8 | ✅ |

### Screenshot Status — Part 1 (`screenshots/part1/`)

| Filename | Task | File Present |
|----------|------|-------------|
| `task01-02-files-permissions.png` | Tasks 1 & 2 — mkdir, touch, cp, mv, chmod, chown | ✅ Present |
| `task03-text-processing.png` | Task 3 — grep, head, tail, wc | ✅ Present |
| `task04-process-management.png` | Task 4 — ps, kill, jobs | ✅ Present |
| `task05-networking.png` | Task 5 — ip, ping, ss, nslookup | ✅ Present |
| `task06-packages-1.png` | Task 6 — apt install | ✅ Present |
| `task06-packages-2.png` | Task 6 — tree output | ✅ Present |
| `task07-system-info.png` | Task 7 — uname, df, free | ✅ Present |
| `task08-user-management.png` | Task 8 — useradd, groupadd, su | ✅ Present |
| `task09-archiving.png` | Task 9 — tar, gzip, zip | ✅ Present |
| `task10a-system-health.png` | Task 10a — system_health.sh output | ✅ Present |
| `task10bc-scripts.png` | Task 10b+c — backup.sh + log_analysis.sh output | ✅ Present |
---

## ✅ PART 2 — Docker Containerization — COMPLETE ✅

**Documentation file:** `documentation/Part2-Docker-Containerization-Documentation.md` ✅ Fully rebuilt in Part 1 format
**All 4 tasks done. Final MySQL Compose run and screenshots recorded.**

### Part 2 documentation coverage

The Part 2 document now follows the same task-by-task format as Part 1:

- `Environment Overview`
- `Task 1 — API Backend Containerization`
- `Task 2 — UI Frontend Containerization`
- `Task 3 — Local Docker Build and Run`
- `Task 4 — Docker Compose, Networking, and Final Verification`
- each task uses `Commands Executed`, `Output`, `Explanation`, and `📸 Screenshots`
- API and UI Dockerfile line-by-line explanations are inside their task sections
- Docker Compose line-by-line explanations are inside Task 4
- actual build outputs and final API/UI responses are preserved
- warnings are separated from actual errors
- the early missing-source container problem remains documented in Task 3
- the `docker compose` versus `docker-compose` error remains documented in Task 4
- the legacy Compose `ContainerConfig` error remains documented in Task 4
- the stale PostgreSQL versus required MySQL problem remains documented in Task 4
- cleanup commands, configuration corrections, final solutions, and screenshots remain included
- an extra English operational guide now explains how to stop, start, force-kill, rerun, rebuild, inspect logs, and verify the Compose services

The document remains aligned to the Part 2 section of
`documentation/reference/Junior_DevOps_Engineer_Exam_2026.pdf`.

### PDF Alignment Check (Part 2)

| PDF Requirement | Our Coverage | Status |
|-----------------|-------------|--------|
| Task 1: API Backend Containerization | `api-src/Dockerfile` — multi-stage, python:3.11-slim, non-root `app`, HEALTHCHECK, EXPOSE 8000 | ✅ |
| Task 2: UI Frontend Containerization | `ui-src/Dockerfile` — node:20-alpine, non-root `node`, HEALTHCHECK, EXPOSE 3000 | ✅ |
| Task 3: Local Execution (`docker-compose build`) | API and UI images built successfully from the cloned source | ✅ |
| Task 4: Docker Compose | `docker-compose.yml` — 3 services (api + ui + MySQL db), `app-network`, `mysql-data` volume, `depends_on` health conditions | ✅ |
| Build optimization | API: 2-stage; UI: locked `npm ci` + production `npm run build` | ✅ |
| Non-root user | API: `appuser`; UI: `nextjs` | ✅ |
| Health checks | Both Dockerfiles + docker-compose healthchecks | ✅ |
| `docker-compose up -d` with all 3 services | `devops_api`, `devops_ui`, `devops_db` all confirmed `Up (healthy)` | ✅ |

### Screenshot Status — Part 2 (`screenshots/part2/`)

| Filename | Content | File Present |
|----------|---------|-------------|
| `task02-0-setup.png` | Pre-setup — mkdir + Dockerfile creation via heredoc | ✅ Present |
| `task02-1-api-build.png` | API image build output | ✅ Present |
| `task02-2-ui-build-1.png` | UI Dockerfile setup and build start | ✅ Present |
| `task02-2-ui-build-2.png` | UI build complete and tagged | ✅ Present |
| `task02-3-local-execution.png` | Both images present | ✅ Present |
| `task02-3-local-execution-2.png` | Local container check | ✅ Present |
| `task02-4-git-clone.png` | Clone and verify Bitbucket API/UI source | ✅ Present |
| `task02-5-file-check.png` | Docker files and cloned source check | ✅ Present |
| `task02-6-copy-dockerfiles.png` | Dockerfiles copied into cloned folders | ✅ Present |
| `task02-7-dockerfile-check.png` | Dockerfiles inspected before build | ✅ Present |
| `task02-4-build-both.png` | Both images built from real source | ✅ Present |
| `task02-4-docker-compose.png` | Compose services created | ✅ Present |
| `task02-4-docker-compose-2.png` | Database and application startup logs | ✅ Present |
| `task02-4-docker-compose-3.png` | Earlier startup issue and correction | ✅ Present |
| `task02-4-all-running.png` | API, UI, and database running | ✅ Present |
| `task02-4-docker-ps.png` | Final API, MySQL, and UI `Up (healthy)` | ✅ Present |
| `task02-4-api-browser.png` | FastAPI root endpoint in browser | ✅ Present |
| `task02-4-ui-browser.png` | UI in browser at localhost:3000 | ✅ Present |

### Confirmed Final State (from docker ps screenshot)

```
CONTAINER ID   IMAGE          COMMAND                 STATUS
devops_api     api-app:latest "uvicorn main:app..."  Up (healthy)  0.0.0.0:8000->8000/tcp
devops_db      mysql:8.0     "docker-entrypoint..."  Up (healthy)  3306/tcp
devops_ui      ui-app:latest "npm start"             Up (healthy)  0.0.0.0:3000->3000/tcp
```

**Part 2 is 100% DONE ✅ — full documentation and final MySQL-backed run verified.**

---

## 🔄 PART 3 — CI/CD Pipeline — IN PROGRESS

Part 3 is being performed on the candidate's personal WSL/Ubuntu computer, not in
this Replit workspace. Uploaded terminal screenshots and user-provided command
output are the source of truth for what has actually been completed.

### Current position — Step 11

The repository was safely re-cloned locally from the current GitHub repository.
The old Part 3 draft documentation and nested workflow were removed locally,
committed, and pushed to `main`. A new `staging` branch was then created and
pushed to GitHub.

The first real Part 3 workflow was created locally at:

```text
.github/workflows/deploy.yml
```

It currently contains only the starter verification job and:

- triggers automatically on pushes to `staging`;
- supports the optional manual `workflow_dispatch` trigger;
- checks out the repository;
- prints the branch and commit information.

The starter workflow was committed locally on the personal computer:

```text
c84f2ee Add initial GitHub Actions workflow
```

**Important:** This commit has not been pushed to GitHub yet. The next action is
Step 11: run `git push origin staging`, then verify the workflow in the GitHub
Actions tab. Do not document a successful GitHub Actions run until the user
provides the result or screenshot.

---

## ❌ PART 4 — High Availability — FILES DONE, DOCUMENTATION NEEDED

**Kubernetes manifests:** `part4-ha/k8s/` ✅ (8 files — full set)  
**Helm chart:** `part4-ha/helm/` ✅ (Chart.yaml + templates/ + values.yaml + values.staging.yaml)  
**ArgoCD:** `part4-ha/argocd/application.yaml` ✅  
**Documentation:** ❌ `documentation/Part4-HA-Documentation.md` does NOT exist yet — must be created

### What the HA setup covers (aligned to PDF requirements — Option A: Kubernetes)

| PDF Requirement | Our Implementation | Status |
|-----------------|-------------------|--------|
| Redundancy — min 2 replicas each | `api-deployment.yaml`: `replicas: 2`; `ui-deployment.yaml`: `replicas: 2` | ✅ |
| Automatic failover | Kubernetes restarts failed pods automatically via `restartPolicy: Always` | ✅ |
| Health checks for recovery | `livenessProbe` (restart hung pods) + `readinessProbe` (only route traffic when ready) | ✅ |
| Load distribution | Kubernetes `ClusterIP` Service distributes traffic across replicas (round-robin) | ✅ |
| No single point of failure | `topologySpreadConstraints` spreads pods across different nodes | ✅ |
| Domain-based access | `api.myapp.local` + `ui.myapp.local` via Nginx Ingress | ✅ |
| HPA (auto-scaling) | `hpa.yaml` — API: 2–10 pods at 70% CPU; UI: 2–5 pods at 70% CPU | ✅ |
| PodDisruptionBudget | `pdb.yaml` — `minAvailable: 1` during maintenance | ✅ |
| Helm chart | Full parameterized chart in `part4-ha/helm/` with staging override values | ✅ |
| GitOps / ArgoCD | `argocd/application.yaml` for GitOps continuous deployment | ✅ |

### Kubernetes manifest files (all in `part4-ha/k8s/`)

| File | Purpose |
|------|---------|
| `namespace.yaml` | Creates `devops-exam` namespace |
| `configmap.yaml` | App environment variables |
| `secret.yaml` | DATABASE_URL + SECRET_KEY (base64 encoded) |
| `api-deployment.yaml` | API Deployment — 2 replicas, liveness + readiness probes, topology spread |
| `api-service.yaml` | API ClusterIP service |
| `ui-deployment.yaml` | UI Deployment — 2 replicas, liveness + readiness probes |
| `ui-service.yaml` | UI ClusterIP service |
| `ingress.yaml` | Nginx Ingress — `api.myapp.local` → api-service, `ui.myapp.local` → ui-service |
| `hpa.yaml` | HorizontalPodAutoscaler for API + UI |
| `poddisruptionbudget.yaml` | PodDisruptionBudget — minAvailable: 1 |

### Hosts file entry required for local testing

```
# Add to /etc/hosts (Linux/Mac) or C:\Windows\System32\drivers\etc\hosts (Windows)
127.0.0.1 api.myapp.local
127.0.0.1 ui.myapp.local
```

### Action Needed — Part 4 Documentation

Create `documentation/Part4-HA-Documentation.md` following EXACTLY the same format as Part 1 and Part 2 docs:
1. Header: Candidate, Machine, Date, Exam
2. "Connection to previous part" section — link HA to Part 3 CI/CD (pipeline deploys via Helm to the K8s cluster)
3. Environment Overview — Kubernetes choice, Minikube or kind for local testing
4. Each requirement from the PDF: Option A selected (Kubernetes)
5. For each requirement: show the YAML content → Explanation table → Screenshot (if available)
6. Domain configuration section — `/etc/hosts` setup
7. Completion summary table
8. Screenshot checklist

For screenshots, user can run (if they have Minikube):
```bash
kubectl get all -n devops-exam
kubectl get ingress -n devops-exam
```
Save screenshot as: `documentation/screenshots/part4/task04-ha-kubectl.png`

---

## 📐 Documentation Rules (STRICT — follow for all new docs)

1. **Format:** Exactly the same as `Part1-Linux-Basics-Documentation.md` and `Part2-Docker-Containerization-Documentation.md`
   - Header block at top: Candidate, Machine, Date, Exam
   - "Connection to previous part" table
   - Environment Overview
   - Each task section: **Commands Executed** → code block → **Explanation** table → **📸 Screenshot**
   - Completion summary table at the bottom
   - Screenshot checklist at the very end

2. **Screenshots directory:** Always save in `screenshots/partN/` — NEVER in root screenshots folder

3. **Naming convention:** `taskNN-description.png` pattern (e.g. `task03-cicd-pipeline.png`)

4. **User workflow:** User runs commands on WSL → sends screenshot → agent saves to `screenshots/partN/` → documents in markdown

5. **Checkpoint updates:** Update THIS file every time a screenshot is added or a section changes

6. **PDF alignment:** Always cross-check requirements against `documentation/reference/Junior_DevOps_Engineer_Exam_2026.pdf` before writing documentation

7. **Do NOT rewrite existing docs from scratch unless the user explicitly requests a full rebuild** — otherwise only add to them

---

## 🗒️ Agent Notes (do not repeat mistakes)

- The legacy builder deprecation warning in Docker is NOT an error — document it clearly when it appears
- `debconf` frontend warnings during `apt-get` in Docker builds are NOT errors
- `pip root user` warning in the builder stage is NOT an error (runtime uses non-root)
- All scripts in `part1-linux/` are already `chmod +x`
- The `docker-compose.yml` build contexts must point at `./api-src` and `./ui-src` (cloned from Bitbucket)
- The cloned FastAPI application uses MySQL through `DB_CONNECTION_STRING`; the Compose database must match that driver instead of using PostgreSQL
- Part 4 uses Kubernetes Option A (Recommended by the PDF) — NOT Docker Swarm or VM-based
- The `image` field in `k8s/api-deployment.yaml` has placeholder `DOCKER_USERNAME/api-app:latest` — user must replace with their actual Docker Hub username
- Git author preference: use `draiimon` / `Mark Andrei Castillo <99703880+draiimon@users.noreply.github.com>` for future commits and pushes

---

## 📊 Overall Exam Progress Summary

**Repository setup note:** The exam's two Application Components are now explicitly documented in `README.md` and in Part 2 → Task 4 → Step 1. The FastAPI repository is cloned into `part2-docker/api-src/` and the Next.js repository into `part2-docker/ui-src/`; Docker Compose uses those folders as its build contexts.

**Repository verification:** Both repositories were cloned successfully and both source-based Docker images were built successfully. The user's local WSL walkthrough was then completed and verified with the final MySQL-backed Compose run.

**Final local walkthrough status:** Steps 2A–2E of the Part 2 application-source walkthrough are complete on the user's local WSL machine and documented with screenshots:

- Step 2A — clone and verify the Bitbucket API and UI repositories
- Step 2B — check the existing Docker setup files and cloned source files
- Step 2C — copy `api/Dockerfile` into `api-src/` and `ui/Dockerfile` into `ui-src/`
- Step 2D — inspect the Dockerfiles before building
- Step 2E — update and verify the concise production Dockerfiles, build both images, correct the Compose database to MySQL, start all services, and verify healthy containers plus API/UI responses

The final local result was:

- `devops_api` — `Up (healthy)` on port `8000`
- `devops_db` — `mysql:8.0`, `Up (healthy)` on the internal MySQL port `3306`
- `devops_ui` — `Up (healthy)` on port `3000`
- API root and `/trip` endpoints responded successfully
- A test trip record was created successfully through the API
- The cloned Next.js UI served successfully at `http://localhost:3000`

| Part | PDF Section | Files | Documentation | Screenshots | Status |
|------|-------------|-------|--------------|-------------|--------|
| Part 1 | Linux Basics (10 tasks) | ✅ 4 scripts | ✅ Done | ✅ 11 screenshots included | ✅ **COMPLETE** |
| Part 2 | Docker Containerization (4 tasks) | ✅ 2 Dockerfiles + compose | ✅ Full command/error/solution documentation plus container lifecycle guide | ✅ All evidence present | ✅ **COMPLETE** |
| Part 3 | CI/CD Pipeline (5 requirements) | 🔄 Starter workflow committed locally | 🔄 In progress from Step 11 | ⏳ First push/run evidence pending | 🔄 **IN PROGRESS** |
| Part 4 | High Availability (K8s Option A) | ✅ 10 K8s/Helm files | ❌ Not created | ❌ None yet | 🔴 Docs needed |
| Part 5 | Solution Presentation | N/A | N/A | N/A | 📅 Onsite |

**Immediate priority for next session:**
1. Continue Step 11: push the committed starter workflow from local `staging`.
2. Verify the first GitHub Actions run.
3. Continue incrementally with the remaining PDF requirements, documenting only
   the work shown by the candidate's local screenshots.
