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
- API: https://bitbucket.org/metawhale/fast-api-clean/src/main/
- UI: https://bitbucket.org/metawhale/nextjs_app/src/main/

---

## 📁 Folder Structure

```
devops-exam/
├── CHECKPOINT.md                          ← YOU ARE HERE
├── README.md                              ← Main overview + architecture
├── Makefile
├── documentation/
│   ├── Part1-Linux-Basics-Documentation.md         ✅ Complete
│   ├── Part2-Docker-Containerization-Documentation.md  🔄 In Progress
│   ├── Part3-CICD-Documentation.md                ❌ Not started
│   ├── Part4-HA-Documentation.md                  ❌ Not started
│   └── screenshots/
│       ├── part1/    ← All Part 1 screenshots live here
│       └── part2/    ← All Part 2 screenshots live here
├── part1-linux/
│   ├── system_health.sh     ✅ (includes service check for docker/nginx)
│   ├── backup.sh            ✅
│   ├── log_analysis.sh      ✅
│   └── scripting_demo.sh    ✅ (if/else, for, while, >, >>, pipes)
├── part2-docker/
│   ├── api/
│   │   ├── Dockerfile       ✅ Multi-stage, non-root, healthcheck
│   │   ├── requirements.txt ✅
│   │   └── .dockerignore    ✅
│   ├── ui/
│   │   ├── Dockerfile       ✅ 3-stage, non-root, healthcheck
│   │   └── .dockerignore    ✅
│   └── docker-compose.yml   ✅ API + UI + PostgreSQL
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
| `task10d-scripting-demo.png` | Task 10d — scripting_demo.sh (if/else, loops) | ⚠️ Missing |

---

## 🔄 Part 2 — Docker Containerization — IN PROGRESS

**Documentation:** `documentation/Part2-Docker-Containerization-Documentation.md`

### Screenshot Status (all go in `screenshots/part2/`)

| File | Task | Status |
|------|------|--------|
| `task02-0-setup.png` | Pre-setup — mkdir + Dockerfile creation | ✅ Done |
| `task02-1-api-build.png` | Task 1 — `docker build api-app:latest` | ✅ Done |
| `task02-2-ui-build-1.png` | Task 2 — UI build start | ✅ Done |
| `task02-2-ui-build-2.png` | Task 2 — UI build complete | ✅ Done |
| `task02-3-local-execution.png` | Task 3 — `docker ps` + `docker images` | ⚠️ Next up |
| `task02-4-docker-compose.png` | Task 4 — `docker-compose up --build` | ⚠️ Pending |

### Next Step for Part 2 (Screenshot 3)

Run this in WSL:
```bash
docker images | grep -E "api-app|ui-app"
docker run -d -p 8000:8000 --name devops_api api-app:latest
docker run -d -p 3000:3000 --name devops_ui ui-app:latest
docker ps
```
Take screenshot showing both images and both containers running.

---

## ❌ Part 3 — CI/CD Pipeline — NOT STARTED (docs)

**Files exist:** `part3-cicd/.github/workflows/deploy.yml` ✅  
**Documentation:** ❌ Needs to be created  
**Format:** Same format as Part 1 and Part 2 docs  
**Screenshot needed:** GitHub Actions pipeline running (or YAML file shown in terminal)

### What the pipeline covers (aligned to PDF):
- ✅ Triggers on `staging` branch push + manual trigger
- ✅ Build stage — Docker images with commit SHA tags + BuildKit cache
- ✅ Test stage — pytest (API) + npm test (UI) + linting (ruff + eslint)
- ✅ Security scan — Trivy (CRITICAL/HIGH CVEs), SARIF upload to GitHub
- ✅ Deploy stage — Helm upgrade to Kubernetes (atomic, auto-rollback)
- ✅ Notifications — Slack success + failure with commit info

---

## ❌ Part 4 — High Availability — NOT STARTED (docs)

**Files exist:** `part4-ha/k8s/`, `part4-ha/helm/`, `part4-ha/argocd/` ✅  
**Documentation:** ❌ Needs to be created  
**Format:** Same format as Part 1 and Part 2 docs  
**Choice made:** Kubernetes (Option A — Recommended)

### What the HA setup covers (aligned to PDF):
- ✅ Redundancy — 2 replicas each (api + ui deployments)
- ✅ Load distribution — Kubernetes built-in load balancing via Services
- ✅ Domain-based access — `api.myapp.local` + `ui.myapp.local` via Ingress
- ✅ HPA — auto-scales based on CPU usage
- ✅ PodDisruptionBudget — prevents all pods going down during maintenance
- ✅ Helm chart — parameterized deploy with staging values
- ✅ ArgoCD — GitOps continuous deployment

---

## 📐 Documentation Rules (STRICT — follow for all new docs)

1. **Format:** Same as `Part1-Linux-Basics-Documentation.md` exactly
   - Header: Candidate, Machine, Date, Exam
   - Connection to previous part section
   - Environment Overview
   - Each task: Commands Executed → Output → Explanation table → Screenshot
   - Completion summary table at the bottom
   - Screenshot checklist at the very bottom

2. **Screenshots:** Always go in `screenshots/partN/` folder (not the root screenshots folder)

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
- Part 2 docker files were created locally on WSL via heredoc (files don't exist on the real Bitbucket app yet)
- Part 3 + Part 4 file contents are solid — only documentation is missing
