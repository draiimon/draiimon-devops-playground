# 📍 Exam Progress Checkpoint

**Candidate:** draiimon  
**Machine:** Aloof — WSL2 (Ubuntu 24.04 on Windows)  
**Exam:** Junior DevOps Engineer Exam 2026  
**Last Updated:** August 6, 2026  

> ⚠️ **For the next agent:** Read this file FIRST before doing anything. It tells you exactly where we are, what's done, what's pending, and what rules to follow.

---

## 📋 Exam Reference

**PDF:** `attached_assets/Junior_DevOps_Engineer_Exam_2026_1785970827190.pdf`  
**Source Apps (Bitbucket):**
- API: https://bitbucket.org/metawhale/fast-api-clean
- UI: https://bitbucket.org/metawhale/nextjs_app

---

## 📁 Folder Structure

```
devops-exam/
├── CHECKPOINT.md                          ← YOU ARE HERE
├── README.md                              ← Main overview + architecture
├── Makefile
├── documentation/
│   ├── Part1-Linux-Basics-Documentation.md         ✅ Complete
│   ├── Part2-Docker-Containerization-Documentation.md  🔄 In Progress (Task 4 screenshot missing)
│   ├── Part3-CICD-Documentation.md                ❌ Not started
│   ├── Part4-HA-Documentation.md                  ❌ Not started
│   └── screenshots/
│       ├── part1/    ← All Part 1 screenshots live here
│       └── part2/    ← All Part 2 screenshots live here
├── part1-linux/
│   ├── system_health.sh     ✅
│   ├── backup.sh            ✅
│   ├── log_analysis.sh      ✅
│   └── scripting_demo.sh    ✅
├── part2-docker/
│   ├── api/
│   │   ├── Dockerfile       ✅ Multi-stage, non-root, healthcheck
│   │   └── requirements.txt ✅
│   ├── ui/
│   │   └── Dockerfile       ✅ 3-stage, non-root, healthcheck
│   └── docker-compose.yml   ✅ (contexts set to ./api-src and ./ui-src — see Task 4 instructions below)
├── part3-cicd/
│   └── .github/workflows/deploy.yml  ✅ Full GitHub Actions pipeline
├── part4-ha/
│   ├── k8s/          ✅ Full Kubernetes manifests
│   ├── helm/         ✅ Helm chart with staging values
│   └── argocd/       ✅ ArgoCD application manifest
└── k9s/              ✅ k9s config (aliases, hotkeys)
```

---

## ✅ Part 1 — Linux Basics — COMPLETE

**Documentation:** `documentation/Part1-Linux-Basics-Documentation.md`  
**Scripts:** `part1-linux/`

### Screenshot Status (all in `screenshots/part1/`)

| File | Task | Status |
|------|------|--------|
| `task01-02-files-permissions.png` | Tasks 1 & 2 — files, dirs, chmod, chown | ✅ Done |
| `task03-text-processing.png` | Task 3 — grep, head, tail, wc | ✅ Done |
| `task04-process-management.png` | Task 4 — ps, kill, jobs | ✅ Done |
| `task05-networking.png` | Task 5 — ip, ping, ss, nslookup | ✅ Done |
| `task06-packages-1.png` | Task 6 — apt install | ✅ Done |
| `task06-packages-2.png` | Task 6 — tree output | ✅ Done |
| `task07-system-info.png` | Task 7 — uname, df, free | ✅ Done |
| `task08-user-management.png` | Task 8 — useradd, groupadd, su | ✅ Done |
| `task09-archiving.png` | Task 9 — tar, gzip, zip | ✅ Done |
| `task10a-system-health.png` | Task 10a — system_health.sh output | ✅ Done |
| `task10bc-scripts.png` | Task 10b+c — backup.sh + log_analysis.sh | ✅ Done |
| `task10d-scripting-demo.png` | Task 10d — scripting_demo.sh (if/else, loops) | ⚠️ Missing — user needs to run scripting_demo.sh and take screenshot |

---

## ✅ Part 2 — Docker Containerization — COMPLETE

**Documentation:** `documentation/Part2-Docker-Containerization-Documentation.md`

### Screenshot Status (all in `screenshots/part2/`)

| File | Task | Status |
|------|------|--------|
| `task02-0-setup.png` | Pre-setup — mkdir + Dockerfile creation | ✅ Done |
| `task02-1-api-build.png` | Task 1 — `docker build api-app:latest` | ✅ Done |
| `task02-2-ui-build-1.png` | Task 2 — UI build start | ✅ Done |
| `task02-2-ui-build-2.png` | Task 2 — UI build complete | ✅ Done |
| `task02-3-local-execution.png` | Task 3 — `docker images` showing both images | ✅ Done |
| `task02-3-local-execution-2.png` | Task 3 — `docker ps` output (containers exited — explained in docs) | ✅ Done |
| `task02-4-docker-compose.png` | Task 4 — all 3 containers created (`done`) | ✅ Done |
| `task02-4-docker-compose-2.png` | Task 4 — DB running; UI/API exit logs explained | ✅ Done |
| `task02-4-docker-compose-3.png` | Task 4 — API exit: ModuleNotFoundError pymysql explained | ✅ Done |

---

## ⚡ NEXT — Part 3 — CI/CD Pipeline — NOT STARTED (docs only)

**Files exist:** `part3-cicd/.github/workflows/deploy.yml` ✅  
**Documentation:** ❌ Needs to be created at `documentation/Part3-CICD-Documentation.md`  
**Format:** Exactly same format as Part 1 and Part 2 docs (see Documentation Rules below)

### What the pipeline covers (aligned to PDF):
- ✅ Triggers on `staging` branch push + manual trigger (`workflow_dispatch`)
- ✅ Build stage — Docker images with commit SHA tags + BuildKit cache
- ✅ Test stage — pytest (API) + npm test (UI) + linting (ruff + eslint)
- ✅ Security scan — Trivy (CRITICAL/HIGH CVEs), SARIF upload to GitHub Security tab
- ✅ Deploy stage — Helm upgrade to Kubernetes (atomic, auto-rollback on failure)
- ✅ Notifications — Slack success + failure messages with commit info

### Screenshot needed:
- GitHub Actions pipeline running (screenshot of the Actions tab on GitHub showing the workflow)
- OR: screenshot of the YAML file in VSCode or terminal (`cat part3-cicd/.github/workflows/deploy.yml`)

---

## ❌ Part 4 — High Availability — NOT STARTED (docs only)

**Files exist:** `part4-ha/k8s/`, `part4-ha/helm/`, `part4-ha/argocd/` ✅  
**Documentation:** ❌ Needs to be created at `documentation/Part4-HA-Documentation.md`  
**Format:** Exactly same format as Part 1 and Part 2 docs (see Documentation Rules below)  
**Choice made:** Kubernetes (Option A — Recommended)

### What the HA setup covers (aligned to PDF):
- ✅ Redundancy — 2 replicas each (api + ui deployments)
- ✅ Load distribution — Kubernetes built-in load balancing via Services
- ✅ Domain-based access — `api.myapp.local` + `ui.myapp.local` via Nginx Ingress
- ✅ HPA — auto-scales api (2–10 pods) and ui (2–5 pods) based on CPU usage
- ✅ PodDisruptionBudget — ensures at least 1 pod stays up during maintenance
- ✅ Helm chart — parameterized deploy with `values.staging.yaml` override
- ✅ ArgoCD — GitOps continuous deployment from Git repo

### Screenshot needed:
- `kubectl get pods -n devops-exam` showing pods running
- OR: Helm/k9s showing services up

---

## 📐 Documentation Rules (STRICT — follow for all new docs)

1. **Format:** Same as `Part1-Linux-Basics-Documentation.md` exactly
   - Header: Candidate, Machine, Date, Exam
   - "Connection to previous part" section
   - Environment Overview
   - Each task: Commands Executed → Output → Explanation table → Screenshot
   - Completion summary table at the bottom
   - Screenshot checklist at the very bottom

2. **Screenshots:** Always go in `screenshots/partN/` folder (not root screenshots folder)

3. **Naming:** `taskNN-description.png` pattern

4. **User workflow:** User runs commands on WSL → sends screenshot → agent adds to repo + documents it

5. **Checkpoints:** Update this file every time a screenshot is added or a section is completed

6. **PDF alignment:** Always cross-check against `attached_assets/Junior_DevOps_Engineer_Exam_2026_1785970827190.pdf`

---

## 🗒️ Agent Notes

- The legacy builder deprecation warning is NOT an error — document it clearly
- `debconf` frontend warnings during `apt-get` in Docker builds are NOT errors
- `pip root user` warning in builder stage is NOT an error (runtime uses non-root)
- All scripts in `part1-linux/` are already `chmod +x`
- `docker-compose.yml` build contexts are set to `./api-src` and `./ui-src` — user must git clone first
- Part 2 Task 3 containers exited (no app code) — this is documented and explained in Part 2 doc
- Part 3 + Part 4 file contents are solid — only documentation markdown files are missing
- Do NOT rewrite existing docs from scratch — only add to them
