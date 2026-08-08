# Part 3: CI/CD Pipeline — Documentation

**Candidate:** draiimon  
**Machine:** Aloof — WSL2 (Ubuntu 24.04 on Windows)  
**Exam:** Junior DevOps Engineer Exam 2026  
**CI/CD platform:** GitHub Actions  
**Repository:** `draiimon/draiimon-devops-playground`

> **Evidence boundary:** Part 3 work was performed on the candidate's local
> WSL/Ubuntu computer. The screenshots in `documentation/screenshots/part3/`
> and the uploaded terminal outputs are the evidence source. This document
> records confirmed work only and does not mark unfinished pipeline stages as
> complete.

---

## Environment Overview

| Item | Value |
|---|---|
| Operating system | Ubuntu 24.04 on WSL2 |
| Hostname | `Aloof` |
| Working directory | `~/devops-exam` |
| Docker | `29.1.3` |
| Local Compose command | Legacy `docker-compose` `1.29.2` |
| Docker Python client | `docker-py 5.0.3` |
| Local Python | `CPython 3.12.3` |
| Local OpenSSL | `3.0.13` |
| CI/CD platform | GitHub Actions |
| Workflow file | `.github/workflows/deploy.yml` |
| Trigger branch | `staging` |

The local WSL environment does not support the `docker compose` v2
subcommand, but provides the legacy `docker-compose` command. Therefore,
`docker-compose` is used for local validation. The GitHub Actions workflow
uses `docker compose`, which is available on the GitHub-hosted runner.

### Versioning and Reproducibility

Version information is recorded because the local WSL environment and the
GitHub-hosted runner are different environments.

| Component | Version or tag | Where used |
|---|---|---|
| GitHub Actions checkout | `actions/checkout@v4` | Workflow repository checkout |
| Docker runner image | `ubuntu-latest` | GitHub Actions jobs |
| API build base image | `python:3.11-slim` | API Dockerfile |
| Database image | `mysql:8.0` | Docker Compose |
| Local Docker | `29.1.3` | WSL preflight validation |
| Local Compose | `docker-compose 1.29.2` | WSL preflight validation |
| Image tags | `${GITHUB_SHA}`, `${GITHUB_REF_NAME}` | CI build output |

The workflow uses commit-SHA and branch-name tags so that an image can be
identified by the source revision and environment branch. The
`ubuntu-latest` runner is intentionally used for the GitHub-hosted CI job;
the exact hosted runner tool versions can change independently from the
candidate's local WSL versions.

GitHub displayed a Node.js runtime deprecation warning for the checkout
action. This was recorded as a warning and did not fail the successful starter
workflow.

---

## Part 3 Requirements Status

| PDF requirement | Current evidence | Status |
|---|---|---|
| Automatic trigger on `staging` | Workflow run triggered by a push to `staging` | ✅ Confirmed |
| Optional manual trigger | `workflow_dispatch` is present | ✅ Confirmed |
| Pipeline as Code | Root `.github/workflows/deploy.yml` | ✅ Confirmed |
| Build API and UI images | GitHub Actions built both images successfully on `staging` | ✅ CI confirmed |
| Image tagging | Images listed with commit SHA, `latest`, and `staging` tags | ✅ CI confirmed |
| Dockerfile validation | Compose config validation completed locally | ✅ Local preflight confirmed |
| Automated tests and linting | Not yet added/verified | ⏳ Pending |
| Container image security scan | Optional; not yet added | ⏳ Pending |
| Staging deployment | Not yet added/verified | ⏳ Pending |
| Container registry/artifact storage | Not yet configured | ⏳ Pending |
| Rollback strategy | Not yet documented/implemented | ⏳ Pending |
| Success/failure notifications | Not yet configured | ⏳ Pending |

**Overall status: Part 3 is in progress.** The GitHub Actions setup and starter
verification are complete, but the full build → test → deploy pipeline is not
yet complete.

---

## Task 1 — Repository and GitHub Setup

### Confirmed actions

1. Installed GitHub CLI in WSL.
2. Created a backup of the pre-Part-3 repository.
3. Verified the GitHub remote and current branch.
4. Re-cloned the repository from GitHub.
5. Detected and removed the old Part 3 documentation and nested workflow.
6. Committed the reset as `Reset Part 3 for new walkthrough`.
7. Pushed the reset to `main`.
8. Created and inspected the new root workflow at `.github/workflows/deploy.yml`.

### Evidence

- [GitHub CLI installation](screenshots/part3/setup-01-github-cli-installation.png)
- [Repository folder check](screenshots/part3/setup-02-repository-folder-check.png)
- [Pre-Part-3 backup](screenshots/part3/setup-03-pre-part3-backup.png)
- [Remote and branch check](screenshots/part3/setup-04-remote-branch-check.png)
- [Fresh repository clone](screenshots/part3/setup-05-fresh-repository-clone.png)
- [Old Part 3 files detected](screenshots/part3/setup-06-old-part3-detection.png)
- [Old Part 3 cleanup](screenshots/part3/setup-07-old-part3-cleanup.png)
- [Staged cleanup check](screenshots/part3/setup-08-staged-cleanup-check.png)
- [Reset commit](screenshots/part3/setup-10-reset-part3-commit.png)
- [Clean main status](screenshots/part3/setup-09-clean-main-status.png)
- [Reset pushed to main](screenshots/part3/setup-11-push-main-reset.png)
- [Root workflow created](screenshots/part3/setup-12-root-workflow-created.png)

---

## Task 2 — Starter Workflow and Staging Trigger

The starter workflow was stored in the repository at:

```text
.github/workflows/deploy.yml
```

The workflow:

- triggers automatically on pushes to `staging`;
- supports the optional `workflow_dispatch` manual trigger;
- checks out the repository using `actions/checkout@v4`;
- prints the branch and commit information.

The starter workflow was committed locally as:

```text
c84f2ee Add initial GitHub Actions workflow
```

### Push evidence

The local push completed successfully:

```text
9642d8d..c84f2ee  staging -> staging
```

Evidence: [Push staging success](screenshots/part3/task01-push-staging-success.png)

### GitHub Actions evidence

The workflow run confirmed:

- workflow: `deploy.yml`;
- branch: `staging`;
- commit: `c84f2ee`;
- status: **Success**;
- verification job: passed;
- branch and commit information: printed in the job log.

Evidence:

- [Workflow success summary](screenshots/part3/task02-workflow-success-summary.png)
- [Checkout log](screenshots/part3/task03-workflow-checkout-log.png)
- [Workflow confirmation](screenshots/part3/task04-workflow-confirmation.png)

GitHub displayed a Node.js 20 deprecation warning for
`actions/checkout@v4`. The warning did not fail the workflow and is recorded
as a non-blocking warning, not as a pipeline error.

---

## Task 3 — Workflow Inspection and Docker Build Stage

The workflow was inspected locally before extending it:

- [Initial workflow inspection](screenshots/part3/task05-local-workflow-inspection.png)
- [Workflow reinspection](screenshots/part3/task06-local-workflow-reinspection.png)

The Compose configuration defines these build contexts:

| Service | Build context | Dockerfile |
|---|---|---|
| API | `part2-docker/api-src` | `Dockerfile` |
| UI | `part2-docker/ui-src` | `Dockerfile` |
| Database | `mysql:8.0` image | Registry image |

The workflow build job was extended to:

1. validate `part2-docker/docker-compose.yml`;
2. build the `api` and `ui` services;
3. tag images with `GITHUB_SHA`;
4. tag images with `GITHUB_REF_NAME`;
5. list the resulting images.

The local environment check is recorded in:

- [Docker Compose version check](screenshots/part3/task07-docker-compose-version-check.png)

The final pasted local build output confirms:

```text
Successfully built 2f9c65110975
Successfully tagged api-app:latest
Successfully built 7c5044be6886
Successfully tagged ui-app:latest
```

The Next.js production build also reported `Compiled successfully` and
generated the static pages successfully. This confirms the local preflight
build for both application images:

- [Docker build progress](screenshots/part3/task08-docker-build-progress.png)

The screenshot captures the build in progress, while the pasted terminal
output records the final successful result. The legacy Docker builder
deprecation message is a warning and did not stop either build.

The separate image verification confirmed both resulting local tags:

```text
api-app:latest  2f9c65110975
ui-app:latest   7c5044be6886
```

Evidence: [Local image verification](screenshots/part3/task09-local-image-verification.png)

### GitHub Actions build verification

The updated workflow was committed and pushed to the `staging` branch. The
GitHub Actions run completed successfully and verified the Docker build stage
on a clean hosted runner.

The successful run showed:

| Item | Confirmed result |
|---|---|
| Workflow | `Add Docker image build stage` |
| Branch | `staging` |
| Commit-based image tag | `55cf266e1223b89cf5d436f51c93e18915590a79` |
| API image | `api-app` built successfully |
| UI image | `ui-app` built successfully |
| API tags | Commit SHA, `latest`, and `staging` |
| UI tags | Commit SHA, `latest`, and `staging` |
| GitHub Actions status | Success |

The build log also confirms the expected production build details:

- API base image: `python:3.11-slim`
- UI base image: `node:20-alpine`
- Next.js production compilation completed successfully
- API image size: approximately `180MB`
- UI image size: approximately `722MB`

Evidence:

- [GitHub Actions build success](screenshots/part3/task10-github-actions-build-success.png)
- [GitHub Actions built images and tags](screenshots/part3/task11-github-actions-built-images.png)

### Build warnings recorded

The build completed, but the following warnings require attention in the
test/security stage:

- Docker's legacy builder is deprecated.
- `pip` was upgraded inside the API image from `24.0` to `26.2.1`.
- `pip` warned about running as root during image construction; the runtime
  container switches to the non-root `appuser`.
- `npm ci` reported 13 dependency vulnerabilities: 3 moderate, 9 high, and
  1 critical. The build still passed, but this must not be silently ignored.
- Next.js reported outdated `caniuse-lite` data.
- npm reported a newer major npm version (`10.8.2` to `12.0.2`).

These are not local build failures. The vulnerability result is especially
important for the upcoming test/security stage and should be investigated
before the pipeline is marked complete.

---

## Beginner Note — Why Part 2 and Part 3 Both Build Docker Images

The successful Docker build from Part 2 and the Docker build in Part 3 serve
different purposes:

| Build | What it proves |
|---|---|
| Part 2 local build | The Dockerfiles, Compose file, and application containers work on the candidate's WSL computer |
| Part 3 GitHub Actions build | The repository can be checked out and rebuilt automatically by a clean CI runner after a push |

The local image is not uploaded automatically to GitHub Actions. The hosted
runner builds a fresh image from the repository. The local Part 3 build is a
preflight check: it catches incorrect paths or Dockerfile problems before the
workflow is pushed, while the GitHub Actions run is the official CI evidence.

Because the Part 2 build was already successful, repeating the local build is
supporting validation rather than a replacement for the Part 3 CI build.

---

## Important Commands and Explanations

| Command | Purpose |
|---|---|
| `git push origin staging` | Pushes the local staging branch to GitHub and triggers Actions |
| `git diff --check` | Checks the diff for whitespace errors |
| `docker-compose ... config --quiet` | Validates the Compose configuration locally |
| `docker compose ... build api ui` | Builds API and UI images on the GitHub runner |
| `docker image tag` | Adds commit-SHA and branch tags to built images |
| `q` in `(END)` | Exits the `less` terminal viewer |

### Docker image listing note

The local command `docker image ls api-app ui-app` returned a usage error
because this Docker version accepts at most one repository argument for
`docker image ls`. This was a command-syntax issue, not a failed image build.
The images can be checked separately:

```bash
docker image ls api-app
docker image ls ui-app
```

Or together with a filtered list:

```bash
docker image ls | grep -E 'REPOSITORY|api-app|ui-app'
```

---

## Remaining Work

The next implementation work is to complete and verify:

1. API and UI Docker builds in GitHub Actions;
2. automated tests and lint/code-quality checks;
3. staging deployment;
4. container registry/artifact storage;
5. secrets management without exposing credentials;
6. rollback strategy;
7. success and failure notifications;
8. final full-pipeline screenshots and documentation update.

Part 3 must not be marked complete until these stages are implemented or
explicitly documented as partial submission items.

---

## Screenshot Inventory

All currently supplied Part 3 screenshots are stored in:

```text
documentation/screenshots/part3/
```

The folder contains 21 evidence files: 12 GitHub setup/history screenshots
and 9 staging/workflow/build screenshots.