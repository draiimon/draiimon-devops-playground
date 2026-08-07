# 📍 Exam Progress Checkpoint

**Candidate:** draiimon  
**Machine:** Aloof — WSL2 (Ubuntu 24.04 on Windows)  
**Exam:** Junior DevOps Engineer Exam 2026  
**Last Updated:** August 7, 2026

> ⚠️ **For the next agent:** Read this file FIRST before doing anything. It tells you exactly where we are, what's done, what's pending, and the rules to follow. Cross-reference everything against the exam PDF at `attached_assets/Junior_DevOps_Engineer_Exam_2026_1785970827190.pdf`.

---

## 📋 Exam Reference

**PDF:** `attached_assets/Junior_DevOps_Engineer_Exam_2026_1785970827190.pdf`  
**Source Apps (Bitbucket):**
- API: https://bitbucket.org/metawhale/fast-api-clean
- UI: https://bitbucket.org/metawhale/nextjs_app

---

## 📁 Folder Structure (current state)

```
devops-exam/
├── CHECKPOINT.md                                     ← YOU ARE HERE
├── README.md                                         ← Main overview + architecture
├── Makefile
├── documentation/
│   ├── Part1-Linux-Basics-Documentation.md           ✅ Complete (1 screenshot still missing — see below)
│   ├── Part2-Docker-Containerization-Documentation.md  ✅ Complete
│   ├── Part3-CICD-Documentation.md                   ❌ FILE DOES NOT EXIST — must be created
│   ├── Part4-HA-Documentation.md                     ❌ FILE DOES NOT EXIST — must be created
│   └── screenshots/
│       ├── part1/   ← 11 screenshots present (1 missing)
│       └── part2/   ← 14 screenshots present (all done)
├── part1-linux/
│   ├── system_health.sh       ✅ chmod +x already applied
│   ├── backup.sh              ✅ chmod +x already applied
│   ├── log_analysis.sh        ✅ chmod +x already applied
│   └── scripting_demo.sh      ✅ chmod +x already applied (screenshot still needed)
├── part2-docker/
│   ├── api/
│   │   ├── Dockerfile         ✅ Multi-stage, non-root (appuser), HEALTHCHECK
│   │   └── requirements.txt   ✅
│   ├── api-src/               ✅ Cloned FastAPI application source
│   ├── ui/
│   │   └── Dockerfile         ✅ 3-stage, non-root (nextjs), HEALTHCHECK
│   ├── ui-src/                ✅ Cloned Next.js application source
│   └── docker-compose.yml     ✅ 3-service (api + ui + MySQL db), named network, healthchecks
├── part3-cicd/
│   └── .github/
│       └── workflows/
│           └── deploy.yml     ✅ Full GitHub Actions pipeline (304 lines)
├── part4-ha/
│   ├── k8s/                   ✅ Full Kubernetes manifests (8 files)
│   ├── helm/                  ✅ Helm chart + values.yaml + values.staging.yaml
│   └── argocd/
│       └── application.yaml   ✅ ArgoCD GitOps manifest
└── k9s/                       ✅ k9s config (aliases, hotkeys)
```

---

## ✅ PART 1 — Linux Basics — COMPLETE (1 screenshot pending)

**Documentation file:** `documentation/Part1-Linux-Basics-Documentation.md` ✅ Complete  
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
| `task10d-scripting-demo.png` | Task 10d — scripting_demo.sh (if/else, loops, redirects, pipes) | ⚠️ **MISSING** |

### ⚠️ Action Needed — Part 1 Screenshot

The user still needs to send a screenshot of running `scripting_demo.sh`:

```bash
# On WSL terminal:
bash ~/devops-exam/part1-linux/scripting_demo.sh
```

When user sends the screenshot → save it as `documentation/screenshots/part1/task10d-scripting-demo.png`  
Then add this entry to the Part 1 doc screenshot checklist (it already has a placeholder row for it).

---

## ✅ PART 2 — Docker Containerization — COMPLETE ✅

**Documentation file:** `documentation/Part2-Docker-Containerization-Documentation.md` ✅ Fully complete  
**All 4 tasks done. All screenshots present.**

### PDF Alignment Check (Part 2)

| PDF Requirement | Our Coverage | Status |
|-----------------|-------------|--------|
| Task 1: API Backend Containerization | `api/Dockerfile` — multi-stage, python:3.11-slim, non-root `appuser`, HEALTHCHECK, EXPOSE 8000 | ✅ |
| Task 2: UI Frontend Containerization | `ui/Dockerfile` — 3-stage (deps/builder/runtime), node:20-alpine, non-root `nextjs`, HEALTHCHECK, EXPOSE 3000 | ✅ |
| Task 3: Local Execution (`docker build` + `docker run`) | Both images built and run; `docker images` confirmed both present | ✅ |
| Task 4: Docker Compose | `docker-compose.yml` — 3 services (api + ui + db), `app-network`, `db-data` volume, `depends_on` health conditions | ✅ |
| Multi-stage builds | API: 2-stage; UI: 3-stage | ✅ |
| Non-root user | API: `appuser`; UI: `nextjs` | ✅ |
| Health checks | Both Dockerfiles + docker-compose healthchecks | ✅ |
| `docker-compose up --build` with all 3 services | `devops_api`, `devops_ui`, `devops_db` all confirmed Up | ✅ |

### Screenshot Status — Part 2 (`screenshots/part2/`)

| Filename | Content | File Present |
|----------|---------|-------------|
| `task02-0-setup.png` | Pre-setup — mkdir + Dockerfile creation via heredoc | ✅ Present |
| `task02-1-api-build.png` | Task 1 — `docker build -t api-app:latest ./api` output | ✅ Present |
| `task02-2-ui-build-1.png` | Task 2 — UI Dockerfile setup + build start | ✅ Present |
| `task02-2-ui-build-2.png` | Task 2 — UI build complete, tagged `ui-app:latest` | ✅ Present |
| `task02-3-local-execution.png` | Task 3 — `docker images` showing both images | ✅ Present |
| `task02-3-local-execution-2.png` | Task 3 — `docker ps` | ✅ Present |
| `task02-4-git-clone.png` | Task 4 — clone and verify Bitbucket API/UI source | ✅ Present and documented |
| `task02-4-build-both.png` | Task 4 — building both images from real source | ✅ Present |
| `task02-4-docker-compose.png` | Task 4 — `docker-compose up --build` → all 3 containers created | ✅ Present |
| `task02-4-docker-compose-2.png` | Task 4 — DB running; API/UI startup logs | ✅ Present |
| `task02-4-docker-compose-3.png` | Task 4 — API ModuleNotFoundError explained | ✅ Present |
| `task02-4-all-running.png` | Task 4 — All 3 services logs: API ready on :8000, UI ready on :3000, DB ready on :5432 | ✅ Present |
| `task02-4-docker-ps.png` | Task 4 — `docker ps` showing all 3 containers STATUS: Up 24 minutes | ✅ Present |
| `task02-4-ui-browser.png` | Task 4 — UI accessible in browser at localhost:3000 | ✅ Present |

### Confirmed Final State (from docker ps screenshot)

```
CONTAINER ID   IMAGE                COMMAND               STATUS
devops_ui      ui-app:latest        "node server.js"      Up 24 minutes   0.0.0.0:3000->3000/tcp
devops_api     api-app:latest       "sh -c 'uvicorn..."   Up 24 minutes   0.0.0.0:8000->8000/tcp
devops_db      postgres:15-alpine   "docker-entrypoint"   Up 24 minutes (healthy)   5432/tcp
```

**Part 2 is 100% DONE ✅**

---

## ⚡ NEXT — PART 3 — CI/CD Pipeline — FILES DONE, DOCUMENTATION NEEDED

**Pipeline file:** `part3-cicd/.github/workflows/deploy.yml` ✅ (304 lines, production-grade)  
**Documentation:** ❌ `documentation/Part3-CICD-Documentation.md` does NOT exist yet — must be created

### What the pipeline covers (aligned to PDF requirements)

| PDF Requirement | Our Implementation | Status |
|-----------------|-------------------|--------|
| Automatic triggering on `staging` branch | `on: push: branches: [staging]` | ✅ |
| Manual trigger | `workflow_dispatch` with optional reason input | ✅ |
| Build Stage — Docker images for both apps | Job `build` with matrix strategy (api + ui in parallel) | ✅ |
| Image tagging (commit SHA + branch) | `docker/metadata-action` → SHA short tag + branch tag + `latest` | ✅ |
| Build caching | `cache-from/cache-to: type=gha` (GitHub Actions cache backend) | ✅ |
| Test Stage — automated tests | Job `test` — pytest (API) + npm test (UI) | ✅ |
| Linting / code quality | `ruff` for API, `npm run lint` for UI | ✅ |
| Security scan | Job `scan` — Trivy CRITICAL/HIGH CVEs, SARIF to GitHub Security tab | ✅ |
| Deploy Stage — push images to registry | Docker Hub push via `docker/build-push-action` | ✅ |
| Deploy to staging via Helm | `helm upgrade --atomic` (auto-rollback on failure) | ✅ |
| Rollback strategy | `--atomic` flag — Helm auto-rolls back if deploy fails | ✅ |
| Notifications success | Slack success message with branch, commit SHA, actor, run link | ✅ |
| Notifications failure | Slack failure message with same details | ✅ |

### Pipeline Job Order

```
build (api + ui in parallel)
  ↓
scan (security) + test (lint + tests) — both run in parallel after build
  ↓
deploy (Helm upgrade to Kubernetes staging)
  ↓
notify (always runs — success or failure)
```

### Secrets required (for the pipeline to run on GitHub)

| Secret name | What it is |
|-------------|-----------|
| `DOCKER_USERNAME` | Docker Hub username |
| `DOCKER_PASSWORD` | Docker Hub password or access token |
| `KUBE_CONFIG_STAGING` | kubeconfig for staging Kubernetes cluster |
| `SLACK_WEBHOOK_URL` | Slack incoming webhook URL |

### Action Needed — Part 3 Documentation

Create `documentation/Part3-CICD-Documentation.md` following EXACTLY the same format as Part 1 and Part 2 docs:
1. Header: Candidate, Machine, Date, Exam
2. "Connection to previous part" section — link CI/CD to Part 2 Docker work
3. Environment Overview
4. Each requirement from the PDF: Commands / Config → Explanation table → Screenshot (if available)
5. Completion summary table at the bottom (all 5 PDF requirements: trigger, build, test, deploy, notify)
6. Screenshot checklist at the very bottom

For the screenshot, the user can take one of:
- `cat part3-cicd/.github/workflows/deploy.yml | head -60` (terminal view of the pipeline YAML)
- Screenshot of the GitHub Actions tab on GitHub showing the workflow running (if they push to their repo)

Save screenshot as: `documentation/screenshots/part3/task03-cicd-pipeline.png`

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

6. **PDF alignment:** Always cross-check requirements against `attached_assets/Junior_DevOps_Engineer_Exam_2026_1785970827190.pdf` before writing documentation

7. **Do NOT rewrite existing docs from scratch** — only add to them

---

## 🗒️ Agent Notes (do not repeat mistakes)

- The legacy builder deprecation warning in Docker is NOT an error — document it clearly when it appears
- `debconf` frontend warnings during `apt-get` in Docker builds are NOT errors
- `pip root user` warning in the builder stage is NOT an error (runtime uses non-root)
- All scripts in `part1-linux/` are already `chmod +x`
- The `docker-compose.yml` build contexts must point at `./api-src` and `./ui-src` (cloned from Bitbucket)
- The cloned FastAPI application uses MySQL through `DB_CONNECTION_STRING`; the Compose database must match that driver instead of using PostgreSQL
- Part 3 pipeline uses matrix strategy — API and UI are built in parallel jobs
- Part 4 uses Kubernetes Option A (Recommended by the PDF) — NOT Docker Swarm or VM-based
- The `image` field in `k8s/api-deployment.yaml` has placeholder `DOCKER_USERNAME/api-app:latest` — user must replace with their actual Docker Hub username
- `part3-cicd/` folder has only one file: `.github/workflows/deploy.yml` — no other files exist

---

## 📊 Overall Exam Progress Summary

**Repository setup note:** The exam's two Application Components are now explicitly documented in `README.md` and in Part 2 → Task 4 → Step 1. The FastAPI repository is cloned into `part2-docker/api-src/` and the Next.js repository into `part2-docker/ui-src/`; Docker Compose uses those folders as its build contexts.

**Clone verification:** Both repositories were cloned successfully and both source-based Docker images were built successfully with `docker compose build api ui`.

| Part | PDF Section | Files | Documentation | Screenshots | Status |
|------|-------------|-------|--------------|-------------|--------|
| Part 1 | Linux Basics (10 tasks) | ✅ 4 scripts | ✅ Done | ⚠️ 11/12 (task10d missing) | 🟡 Near-complete |
| Part 2 | Docker Containerization (4 tasks) | ✅ 2 Dockerfiles + compose | ✅ Done | ✅ 14/14 | ✅ **COMPLETE** |
| Part 3 | CI/CD Pipeline (5 requirements) | ✅ deploy.yml | ❌ Not created | ❌ None yet | 🔴 Docs needed |
| Part 4 | High Availability (K8s Option A) | ✅ 10 K8s/Helm files | ❌ Not created | ❌ None yet | 🔴 Docs needed |
| Part 5 | Solution Presentation | N/A | N/A | N/A | 📅 Onsite |

**Immediate priority for next session:**
1. (Optional) Get `task10d-scripting-demo.png` from user → finishes Part 1 completely
2. Create `documentation/Part3-CICD-Documentation.md` 
3. Create `documentation/Part4-HA-Documentation.md`
