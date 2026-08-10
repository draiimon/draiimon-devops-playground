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
│   ├── Part3-CICD-Documentation.md                   🔄 In progress — setup and workflow evidence recorded
│   ├── Part4-HA-Documentation.md                     ⏳ Pending — create after Part 3 verification
│   └── screenshots/
│       ├── part1/   ← 11 screenshots present
│       ├── part2/   ← 14 screenshots present (all done)
│       └── part3/   ← 27 screenshots present (setup, workflow, build, test, and registry evidence)
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

### Current position — Core Deploy Stage complete; final gaps remain

The repository was safely re-cloned locally from the current GitHub repository.
The old Part 3 draft documentation and nested workflow were removed locally,
committed, and pushed to `main`. A new `staging` branch was then created and
pushed to GitHub.

The first real Part 3 workflow was created locally at:

```text
.github/workflows/deploy.yml
```

The workflow now contains the starter verification, Docker Build Stage, and
Test Stage jobs. It:

- triggers automatically on pushes to `staging`;
- supports the optional manual `workflow_dispatch` trigger;
- checks out the repository;
- prints the branch and commit information;
- builds and tags the API and UI images;
- runs UI quality checks;
- starts the Compose stack for API/UI smoke tests;
- removes the temporary test containers, volume, and network.

The starter workflow was committed locally on the personal computer:

```text
c84f2ee Add initial GitHub Actions workflow
```

The starter workflow was pushed to GitHub and the first Actions run succeeded.
The provided evidence is stored in `documentation/screenshots/part3/` and
summarized in `documentation/Part3-CICD-Documentation.md`.

The workflow has since been extended with a Docker image build job for the API
and UI. Local Compose validation completed successfully, and the final local
build output confirmed both `api-app:latest` and `ui-app:latest` were built
successfully. The local WSL environment has Docker 29.1.3 and legacy
`docker-compose` 1.29.2, while the GitHub workflow uses the modern
`docker compose` command available on the hosted runner.

The local build recorded non-blocking warnings: Docker's legacy builder
deprecation, pip running as root during image construction, outdated
`caniuse-lite`, a newer npm version notice, and 13 npm dependency
vulnerabilities (3 moderate, 9 high, 1 critical). The vulnerability result is
documented as a follow-up for the optional security-scan decision.

The final local image listing confirmed:

- `api-app:latest` with image ID `2f9c65110975`
- `ui-app:latest` with image ID `7c5044be6886`

The supporting screenshot is
`documentation/screenshots/part3/task09-local-image-verification.png`.

### Confirmed CI build evidence

The updated workflow was committed and pushed to the `staging` branch. The
GitHub Actions build run completed successfully on the hosted runner.

The run verified:

- workflow: `Add Docker image build stage`;
- branch: `staging`;
- commit-based image tag:
  `55cf266e1223b89cf5d436f51c93e18915590a79`;
- API and UI images built successfully;
- both images were tagged with the commit SHA, `latest`, and `staging`;
- the final image listing was successful.

The Replit-side evidence files are:

- `documentation/screenshots/part3/task10-github-actions-build-success.png`
- `documentation/screenshots/part3/task11-github-actions-built-images.png`
- `documentation/screenshots/part3/task12-test-stage-pre-push-check.png`

### Confirmed Test Stage evidence

The Test Stage was pushed and completed successfully in GitHub Actions. The
supplied output confirms:

- the clean runner pulled the MySQL image;
- the API and UI images were rebuilt in the test job;
- the MySQL, API, and UI containers started;
- UI lint/quality checks did not fail;
- API root smoke test passed;
- API `/trip` smoke test passed;
- UI root smoke test passed;
- `docker compose ps` showed the services;
- the cleanup trap stopped and removed all containers;
- the temporary MySQL volume and Compose network were removed.

Two early `curl: (56) Recv failure: Connection reset by peer` messages were
transient startup responses. The readiness loop retried, later requests
succeeded, and the job completed successfully. They are documented as a
recoverable startup condition, not a pipeline failure.

Raw output:

`documentation/evidence/part3/task13-test-stage-output.txt`

The Test Stage now satisfies the required automated test/code-quality portion
of the PDF. The optional image security scan remains pending.

### First Deploy Stage evidence — Docker Hub API repository

The Docker Hub API repository was created under the user's namespace:

```text
draiimon112/devops-api
```

This is the first verified Deploy Stage setup step. The screenshot is stored
at:

```text
documentation/screenshots/part3/task14-dockerhub-api-repository.png
```

These first screenshots prove repository creation. At that earlier checkpoint,
they did not yet prove that a Docker image was pushed. Later evidence in this
checkpoint confirms GitHub Secrets authentication, image push, staging update,
and success notifications; rollback testing remains an optional follow-up.

The UI Docker Hub repository was also created:

```text
draiimon112/devops-ui
```

Its screenshot is stored at:

```text
documentation/screenshots/part3/task15-dockerhub-ui-repository.png
```

Together, these two screenshots prove Docker Hub repository setup only. They
do not yet prove that CI successfully pushed images.

### Docker Hub access token evidence

A Docker Hub Personal Access Token was created for GitHub Actions with the
description:

```text
github-actions-devops
```

The screenshot confirms **Read & Write** permissions:

```text
documentation/screenshots/part3/task16-dockerhub-access-token-created.png
```

The token value is not stored in this Repl, the repository, the documentation,
or chat. It must be added next as an encrypted GitHub repository secret. Token
creation alone does not prove that GitHub Actions can authenticate or push
images.

### GitHub Actions username secret evidence

The Docker Hub username was added to the GitHub repository's encrypted Actions
secrets using the exact name:

```text
DOCKERHUB_USERNAME
```

The screenshot is stored at:

```text
documentation/screenshots/part3/task17-github-dockerhub-username-secret.png
```

The secret name is visible, but its value is hidden. The Docker Hub PAT still
needs to be added as a separate encrypted secret. No credential value is
stored in this Repl, the repository, the documentation, or chat.

### GitHub Actions token secret evidence

The Docker Hub Personal Access Token was added to the GitHub repository's
encrypted Actions secrets using the exact name:

```text
DOCKERHUB_TOKEN
```

The screenshot is stored at:

```text
documentation/screenshots/part3/task18-github-dockerhub-token-secret.png
```

The token value is hidden and is not stored in this Repl, the repository, the
documentation, or chat. Both required credential secret names are now present.
GitHub Actions login and Docker image push still need to be verified by a real
workflow run.

### Current workflow baseline

The current workflow was printed from the user's WSL repository before adding
the Docker Hub Deploy Stage. The raw output is preserved at:

```text
documentation/evidence/part3/task19-current-workflow-output.txt
```

It confirms the existing `verify-workflow`, `build-images`, and `test-stage`
jobs, including the staging trigger, Docker image builds, linting, smoke tests,
and cleanup. It does not contain Docker Hub login, `docker push`, or a Deploy
job. This is the baseline for the next workflow change.

### Draft workflow review

The next workflow draft added Docker Hub tagging, login, and push commands, and
its raw output is preserved at:

```text
documentation/evidence/part3/task20-workflow-with-dockerhub-push-draft.txt
```

The Docker Hub secret names and image repository names are correct. However,
the draft placed the push inside `build-images`, before the Test Stage. It is
not accepted as the final workflow. The login/push steps must move to a
separate Deploy job that depends on the successful Test job. No image push is
claimed from this draft.

### Workflow after removing the early push

The workflow was printed again after the Docker Hub login and push steps were
removed from `build-images`. The raw output is preserved at:

```text
documentation/evidence/part3/task21-workflow-after-removing-early-push.txt
```

This correction is valid: the pipeline no longer pushes before testing. The
workflow is not final yet because Docker Hub image tagging remains in the
Build job, and each GitHub Actions job uses a fresh runner. The final Deploy
job must explicitly build/tag/login/push after the Test job succeeds.

### Beginner Nano and terminal tutorial

The Part 3 documentation includes a reusable quick-reference section for the
editing techniques used during this walkthrough:

- `Ctrl + W` to search for text in Nano;
- `Ctrl + A` to move to the start of the current line;
- `Ctrl + K` to remove one line at a time;
- right-click or `Shift + Insert` to paste;
- `Ctrl + O`, `Enter`, and `Ctrl + X` to save and exit;
- `sed`, `cat`, and `nl -ba` to inspect the result;
- `git diff --check` and `git diff` before committing.

It also records the safe sequence: search, edit a small block, save, inspect
the result, run the whitespace check, review the diff, and commit only after
the YAML is confirmed. Docker credentials must never be placed in the
workflow, documentation, screenshots, or chat.

### Step 9 learning notes — what the workflow code means

The Part 3 documentation now includes a full beginner walkthrough of the
workflow code used for Step 9. It explains:

- `on.push.branches: staging` and `workflow_dispatch`;
- the `verify-workflow`, `build-images`, and `test-stage` jobs;
- how `needs` creates the `Verify → Build → Test` order;
- why each GitHub Actions job uses a fresh runner;
- `docker compose config --quiet`, `build`, `up`, and cleanup with `trap`;
- `npm ci`, linting, `curl` readiness checks, `test`, and `grep`;
- the difference between `docker tag` and `docker push`;
- commit-SHA, branch, and `latest` Docker tags;
- why `${{ secrets.DOCKERHUB_USERNAME }}` is a secret reference rather than
  a value that should be pasted into the file;
- why Step 9 removes premature Docker Hub tagging without claiming that the
  final Deploy job is complete;
- both the educational Nano method and the safer boundary-checked
  copy-paste method;
- the exact verification commands to run before committing or pushing.

The important design lesson is:

```text
Build validates → Test proves behavior → Deploy publishes
```

The actual WSL workflow was then verified at:

```text
/home/draiimon/devops-exam/.github/workflows/deploy.yml
```

Step 9 successfully removed the actual Build-job step named
`Tag images with commit SHA and branch`. The four local commit/branch tag
commands were removed, while these steps remained intact:

```text
Validate Docker Compose configuration
Build API and UI images
Show built images
```

The full `test-stage` job also remained intact, including UI linting, Compose
startup, readiness checks, API assertions, and cleanup. `git diff --check`
returned no error. This proves the local YAML edit and formatting check; it
does not claim that GitHub Actions has run the edited workflow.

Removing the tagging block is a pipeline-order correction. It does not delete
the Docker Hub repositories, expose credentials, or complete the Deploy stage.
The future Deploy job must explicitly rebuild or obtain images, tag them, log in
securely, and push only after the Test job succeeds.

### Step 9 commit confirmation

The candidate passed the final whitespace check, staged only
`.github/workflows/deploy.yml`, and created the local commit:

```text
Keep build stage focused on validation
```

The temporary `deploy.yml.step9-backup` file remained untracked and was not
included in the commit. It is a safety copy only and must not be pushed to the
exam repository. The Step 9 edit is therefore saved locally; a GitHub Actions
run has not yet been claimed.

The candidate then moved that backup safely to `/tmp`. The local branch and
commit were confirmed as:

```text
staging
7a51dac (HEAD -> staging) Keep build stage focused on validation
```

The follow-up status check still showed:

```text
?? .github/workflows/.github/
```

Therefore the repository has one remaining untracked nested `.github` path.
This must be inspected before deletion or pushing. The correct next action is
not to ignore the status output and not to run a broad `git clean`; inspect the
path, confirm whether it is accidental, remove only the confirmed accidental
path, and verify `git status --short` again.

The inspection confirmed that the nested path contains only:

```text
.github/workflows/deploy.yml
```

with a file size of `0 bytes`. Because the command was run from the real
`.github/workflows` directory, this is an accidental nested
`.github/workflows` folder, not the actual workflow file. The real workflow is
the parent `deploy.yml`, which was already committed. Only the nested
untracked `.github` directory should be removed; no broad `git clean` should
be used.

The candidate then removed only that confirmed empty nested path. The command
reported:

```text
OK: Natanggal lamang ang empty accidental nested .github folder.
```

The subsequent `git status --short` produced no output, confirming that the
working tree is clean. The last commit remained:

```text
7a51dac (HEAD -> staging) Keep build stage focused on validation
```

This proves that the accidental nested folder was removed without affecting
the real workflow or the Step 9 commit. The local repository is now ready for
the next reviewed change. It does not yet prove a GitHub Actions run or a
Docker Hub image push.

### Step 9 GitHub Actions success evidence

After the clean Step 9 commit was pushed to `staging`, the GitHub Actions page
showed a green successful run:

```text
Workflow: CI/CD Pipeline — 2026
Branch: staging
Commit: 7a51dac
Message: Keep build stage focused on validation
Duration shown: approximately 2 minutes 56 seconds
```

This confirms that GitHub accepted and executed the committed workflow after
the Step 9 cleanup. It does not confirm a Docker Hub upload. The current
workflow still contains the Verify, Build, and Test jobs only; it has no
`docker login`, registry tagging, or `docker push` command. Docker Hub setup
and encrypted secrets are ready for the separate Deploy Stage, which must
depend on successful `test-stage`.

### Deploy job draft — pending validation

The candidate added a separate local `deploy` job after `test-stage` with:

```yaml
needs: test-stage
```

The draft rebuilds the API/UI images on the Deploy job's fresh runner, logs in
through `docker/login-action@v3`, creates Docker Hub tags, and pushes commit,
branch, and `latest` tags for both repositories. It references only the
encrypted secret names `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`; no secret
values were exposed.

A local backup was created as `deploy.yml.before-deploy`. `git diff --check`
returned no output, so the whitespace check passed. The workflow has not been
committed or pushed in this state. A whitespace check is not a YAML parser and
does not prove Docker Hub authentication; structural validation must happen
before the first Deploy run.

The next safe action is a local structural validation of the complete
workflow. It should confirm that each job appears once and that `deploy`
depends on `test-stage`, then parse the YAML if a parser is available. It must
not print secret values or contact Docker Hub.

### Docker Hub Deploy Stage success evidence

The reviewed workflow was pushed to `staging` and GitHub Actions completed the
full pipeline successfully:

```text
Verify workflow
→ Build Docker images
→ Test applications
→ Push images to Docker Hub
```

The GitHub Actions summary showed:

```text
Workflow run: Add Docker Hub deploy stage #5
Branch: staging
Status: Success
Duration shown: 4 minutes 14 seconds
Jobs: Verify workflow, Build Docker images, Test applications,
      Push images to Docker Hub
```

The green `Push images to Docker Hub` job confirms that the Docker Hub Deploy
job completed successfully after the Test job. The screenshot does not show
individual `docker push` log lines or the resulting Docker Hub repository
contents, so those are not separately claimed here.

The detailed uploaded runner log now supplies that repository-level evidence:

```text
attached_assets/Pasted-Current-runner-version-2-336-0-Runner-Image-Provisioner_1786164927904.txt
```

It confirms `Login Succeeded!`, successful pushes for both
`draiimon112/devops-api` and `draiimon112/devops-ui`, and successful commit,
`staging`, and `latest` tags for the checked-out commit
`f5d58e1c5530c852eaf91ec930c9b238f1bea3ba`. Docker logout and runner cleanup
also completed. This upgrades the Docker Hub publishing evidence from a
workflow-summary confirmation to detailed push-log confirmation.

The two accompanying Docker Hub screenshots provide independent repository
confirmation:

```text
documentation/screenshots/part3/task22-dockerhub-ui-published-tags.png
documentation/screenshots/part3/task23-dockerhub-api-published-tags.png
```

Both repositories visibly contain the `latest`, `staging`, and
`f5d58e1c5530c852e...` commit-SHA tags. Docker Hub registry publishing is
therefore complete and documented. These screenshots do not prove that a
separate running staging service was updated.

Additional tag-detail screenshots now show the `staging` tag manifest digest and
image layers for both repositories:

```text
documentation/screenshots/part3/task24-dockerhub-ui-staging-tag-detail.png
documentation/screenshots/part3/task25-dockerhub-api-staging-tag-detail.png
```

These confirm the contents of the published Docker Hub tags. They remain
registry evidence, not proof that a separate staging runtime pulled and started
the images.

### Staging runtime deployment evidence

The candidate then started a separate staging Compose project using the
published Docker Hub images. Evidence:

```text
documentation/screenshots/part3/task26-staging-containers-published-images.png
```

The screenshot confirms:

```text
/devops_staging_api -> draiimon112/devops-api:staging
/devops_staging_ui  -> draiimon112/devops-ui:staging
/devops_staging_db  -> mysql:8.0
```

The services were created under the separate `staging-release` Compose project.
The API and UI are exposed on host ports `8001` and `3001`; the database is
healthy. A later screenshot confirms that all three services are `Up (healthy)`
and that the API and UI are using the published Docker Hub `:staging` images:

```text
documentation/screenshots/part3/task27-staging-healthy-images.png
```

This confirms the staging runtime deployment. Additional HTTP smoke-test output
would strengthen the evidence but is not required to prove that the published
images were pulled into and started by the separate staging project.

The run displayed four non-blocking Node.js 20 deprecation warnings. The
warnings affected the checkout steps and the Docker login action, which are
currently being forced toward Node.js 24. This is a maintenance follow-up, not
a failed pipeline result.

Docker Hub publishing and staging service update are now confirmed. GitHub
Actions email notifications are enabled, the workflow-runs history is
preserved, and a successful workflow email for Attempt #2 is preserved as
`documentation/screenshots/part3/task30-success-email-notification.png`.
The full notification email view is also preserved as
`documentation/screenshots/part3/task41-success-email-notification-full.png`;
it shows the staging run and all four successful jobs.
The notification settings and workflow history are preserved as
`task28-notification-settings.png` and `task29-workflow-runs-history.png`.
Failure-email simulation is not required for this submission and will not be
performed. The immutable-tag rollback strategy is documented; a live rollback
test remains optional follow-up evidence.

### Final evidence-based handoff — August 8, 2026

Part 3's core CI/CD pipeline is now confirmed through Docker Hub publishing:

```text
Verify → Build → Test → Push images to Docker Hub
```

The successful run was on `staging`, lasted approximately 4 minutes 14 seconds,
and showed all four jobs passing. Four non-blocking Node.js 20 deprecation
warnings were recorded. The evidence also includes a successful GitHub Actions
email notification for Attempt #2. A failure simulation is not required for this
submission and will not be performed.

The rollback strategy is documented in
`documentation/Part3-CICD-Documentation.md`: restore the last known-good
commit-SHA image tags, restart the staging services, and rerun the smoke tests.
The strategy is not represented as a live rollback test.

### Next exact actions on the personal WSL computer

The local Docker preflight, GitHub Actions Docker build, Test Stage, Docker Hub
publishing, staging runtime, and success-email notification are complete. Do
not repeat them unless a later change requires it. The remaining optional Part
3 work is image scanning and testing the documented rollback procedure.
Continue documenting only work shown by local or GitHub evidence.

The previous commands that completed this checkpoint were:

```bash
cd ~/devops-exam
git diff --check
git status --short
git add .github/workflows/deploy.yml
git commit -m "Add Docker image build stage"
git push origin staging
```

The GitHub Actions run and built-image evidence are now recorded above. The
GitHub runner built fresh images; it did not reuse the local image IDs.

The Test Stage workflow was pushed and verified successfully. Its raw output
is preserved in the Replit-side evidence folder and explained in the Part 3
documentation.

The attempted command `docker image ls api-app ui-app` returned a Docker usage
error because this local Docker version accepts at most one repository
argument. This was only a listing-command syntax issue, not a build failure.
Use `docker image ls api-app` and `docker image ls ui-app` separately, or
filter the complete image list.

**Beginner workflow note:** The Part 2 local Docker build and the Part 3
GitHub Actions build are intentionally separate evidence. Part 2 proves that
the containers work on the candidate's WSL computer. Part 3 proves that a
clean GitHub Actions runner can rebuild them automatically from the repository.
The local Part 3 build is only a preflight check; it does not transfer local
images into GitHub Actions.

**Versioning note:** Confirmed versions must remain visible in the Part 3
documentation: WSL Ubuntu 24.04, Docker 29.1.3, legacy
`docker-compose` 1.29.2, `actions/checkout@v4`, API base image
`python:3.11-slim`, database image `mysql:8.0`, and CI image tags based on
`GITHUB_SHA` and `GITHUB_REF_NAME`. Local tool versions and the
GitHub-hosted runner environment are documented separately.

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
| Part 3 | CI/CD Pipeline (5 requirements) | ✅ Verify, Build, Test, Docker Hub publishing, staging deployment, and success email verified | ✅ Five exam-aligned tasks documented with commands, output, explanations, evidence, warnings, rollback strategy, and evidence boundary; failure simulation is not required | ✅ 49 screenshots plus 4 raw logs | ✅ **CORE COMPLETE** |
| Part 4 | High Availability (K8s Option A) | ✅ 10 K8s/Helm files | ❌ Not created | ❌ None yet | 🔴 Docs needed |
| Part 5 | Solution Presentation | N/A | N/A | N/A | 📅 Onsite |

**Remaining optional or unverified work:**
1. Decide whether to add the optional Docker image security scan.
2. Test the documented immutable-tag rollback procedure on staging.

---

## Latest Part 4 handoff — August 11, 2026

This section supersedes the older Part 4 planning notes above. Part 4 is using
Kubernetes Option A with Minikube and k9s. The actual local WSL walkthrough is
in progress and must remain evidence-based; do not claim application
deployment, domain access, or failover until those commands are run and
screenshots are captured.

### Completed and evidenced

- Docker, kubectl, Minikube, and k9s were installed and verified on local WSL.
- Part 3 Docker containers were stopped before the Kubernetes run.
- WSL memory was increased to approximately 5.8 GiB with 4 GiB swap.
- A two-node Minikube cluster was created successfully with:

  ```bash
  minikube start --nodes 2 --driver=docker --cpus=2 --memory=1800mb
  ```

- Control-plane node `minikube` is `Ready`.
- Worker node `minikube-m02` is `Ready`.
- Kubernetes version is `v1.35.1`.
- Minikube version is `v1.38.1`.
- kubectl is configured for the `minikube` context.
- Metrics Server is enabled and its pod was shown as `Running`.
- Ingress add-on is enabled and the `ingress-nginx-controller` pod is `1/1
  Running` in the `ingress-nginx` namespace.
- The corrected raw Kubernetes manifests were applied successfully after
  replacing stale placeholder images with:
  `draiimon112/devops-api:staging` and `draiimon112/devops-ui:staging`.
- The API and UI Deployments both completed successfully.
- The live k9s Pods view showed two API pods, two UI pods, and one MySQL pod,
  all `1/1 Running` with zero restarts.
- The live k9s Nodes view showed both `minikube` and `minikube-m02` as `Ready`
  on Kubernetes `v1.35.1`.

### Add-on evidence boundary

The latest add-on verification showed:

- Both nodes `Ready`.
- Kubernetes system pods `Running`.
- `metrics-server` enabled.
- `ingress` enabled in the Minikube add-on list.
- The `ingress-nginx-controller` pod was later verified as `1/1 Running` in
  the `ingress-nginx` namespace.
- `ingress-dns` is disabled; this is not required for the selected path.
- The `command not found` messages for `ingress` and `metrics-server` happened
  because those status labels were typed into Bash after the command output;
  they did not change the cluster.

### Part 4 evidence files

```text
documentation/screenshots/part4/step01-installation-check.png
documentation/screenshots/part4/step01-installation-success.png
documentation/screenshots/part4/step02-minikube-preflight.png
documentation/screenshots/part4/step02-minikube-preflight-clean.png
documentation/screenshots/part4/step02-minikube-preflight-ready.png
documentation/screenshots/part4/step03-minikube-start-success.png
documentation/screenshots/part4/step03-addons-verification-partial.png
documentation/screenshots/part4/step04-two-nodes-ready.png
documentation/screenshots/part4/step04-application-pods-ready.png
documentation/screenshots/part4/step05-services-clusterip.png
documentation/screenshots/part4/step06-ingress-host-routing.png
documentation/screenshots/part4/step07-hpa-metrics-ready.png
documentation/screenshots/part4/step08-domain-access-http-200.png
documentation/screenshots/part4/step09-node-taint-rollout.png
documentation/screenshots/part4/step09-pod-placement-two-nodes.png
```

The current Part 4 guide is:

```text
documentation/Part4-High-Availability-Documentation.md
```

It records the installation, preflight, Minikube start, add-on verification,
k9s workflow, resource-safe memory settings, and evidence boundaries.

### Exact next action

The Ingress controller and applications are now running. Services, Ingress,
HPA metrics, two Ready nodes, and successful domain requests have been
captured. Pod placement across both nodes has also been captured. Continue
with the real API failover test:

```bash
k9s -n devops-exam
```
