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
| CI/CD platform | GitHub Actions |
| Workflow file | `.github/workflows/deploy.yml` |
| Trigger branch | `staging` |

The local WSL environment does not support the `docker compose` v2
subcommand, but provides the legacy `docker-compose` command. Therefore,
`docker-compose` is used for local validation. The GitHub Actions workflow
uses `docker compose`, which is available on the GitHub-hosted runner.

---

## Part 3 Requirements Status

| PDF requirement | Current evidence | Status |
|---|---|---|
| Automatic trigger on `staging` | Workflow run triggered by a push to `staging` | ✅ Confirmed |
| Optional manual trigger | `workflow_dispatch` is present | ✅ Confirmed |
| Pipeline as Code | Root `.github/workflows/deploy.yml` | ✅ Confirmed |
| Build API and UI images | Build job added; local build was still running in latest screenshot | 🔄 In progress |
| Image tagging | SHA and branch tag commands added to workflow | 🔄 Added, pending CI verification |
| Dockerfile validation | Compose config validation step added | 🔄 Added, pending CI verification |
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

The latest build screenshot shows the API build downloading Debian
dependencies. It is progress evidence only; it does not prove final build
success:

- [Docker build progress](screenshots/part3/task08-docker-build-progress.png)

The legacy Docker builder deprecation message is a warning. The final build
result must still be captured after the command returns to the shell prompt.

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

The folder contains 20 evidence files: 12 GitHub setup/history screenshots
and 8 staging/workflow/build screenshots.