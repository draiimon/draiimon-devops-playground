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
| Automated tests and linting | Test job passed: UI quality checks and API/UI Docker smoke tests completed | ✅ CI confirmed |
| Container image security scan | Optional; not yet added | ⏳ Pending |
| Staging deployment | Not yet added/verified | ⏳ Pending |
| Container registry/artifact storage | Docker Hub repositories created and a GitHub Actions access token generated; image push not yet verified | 🔄 Started |
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
important for the optional security-scan decision and should not be silently
ignored.

---

## Task 4 — Test Stage: Automated Checks and Smoke Tests

### Objective

The exam PDF requires a Test Stage that runs automated tests and code-quality
checks, and that fails the pipeline when a required check fails. The cloned
applications did not include a complete API test suite, so the workflow uses
honest, executable smoke tests against the real containerized services:

- UI dependency installation and lint/code-quality checking;
- API root endpoint verification;
- API `/trip` endpoint verification;
- UI root page verification;
- Docker Compose service-status verification.

This is not a fabricated unit-test result. It checks that the built
applications can start and respond through their published ports on a fresh
GitHub-hosted runner.

### Test job dependency

The test job is declared after the build job:

```yaml
test-stage:
  name: Test applications
  needs: build-images
  runs-on: ubuntu-latest
```

| Configuration | Meaning |
|---|---|
| `name: Test applications` | Human-readable job name shown in GitHub Actions |
| `needs: build-images` | The test job starts only after the image-build job succeeds |
| `runs-on: ubuntu-latest` | The test runs on a clean GitHub-hosted Linux runner |

Each job gets a fresh runner. Therefore, the test job cannot assume that
Docker images built in the earlier job still exist locally. The test command
uses `--build` so the API and UI images are rebuilt in the test job before
starting the services.

### Test step 1 — UI dependency installation and linting

```yaml
- name: Install UI dependencies and run lint
  working-directory: part2-docker/ui-src
  run: |
    npm ci
    npm run lint
```

`working-directory` makes the commands run inside the cloned Next.js
application rather than the repository root.

- `npm ci` installs exactly the versions recorded in `package-lock.json`.
  This is preferred in CI because it is reproducible and does not rewrite the
  lock file.
- `npm run lint` executes the UI project's `next lint` script.
- If linting returns a non-zero exit code, GitHub Actions stops the job and the
  pipeline fails.

The supplied run continued to the smoke-test step and completed cleanup, so
the preceding test-stage command did not fail. The same run also shows the
Next.js production build performing “Linting and checking validity of types”.

### Test step 2 — Start the real services

```bash
set -e

docker compose \
  -f part2-docker/docker-compose.yml \
  up -d --build db api ui
```

What happens:

1. `set -e` makes the shell stop if a command fails.
2. `-f` selects the repository's Compose file.
3. `up` creates or starts the services.
4. `-d` runs them in the background so the workflow can execute HTTP checks.
5. `--build` rebuilds the API and UI images in this fresh test job.
6. `db api ui` starts MySQL, the FastAPI API, and the Next.js UI.

The log shows the runner pulling the `mysql:8.0` image in multiple filesystem
layers. `Pulling`, `Downloading`, checksum verification, extraction, and
`db Pulled` are normal first-run Docker behavior, not errors. The hosted
runner starts without the candidate's local Docker cache.

The log then confirms:

```text
api  Built
ui   Built
Network ... Created
Volume ... Created
Container devops_db Created
Container devops_api Created
Container devops_ui Created
Container devops_db Started
Container devops_api Started
Container devops_ui Started
```

This proves the test job did not merely inspect files. It rebuilt and started
the actual application stack.

### Test step 3 — Automatic cleanup registration

```bash
trap 'docker compose -f part2-docker/docker-compose.yml down -v' EXIT
```

`trap ... EXIT` schedules cleanup when the shell exits, whether the test
passes or fails. The `down -v` command stops and removes the containers,
removes the temporary network, and removes the temporary MySQL volume.

This prevents a CI runner from leaving behind application processes or test
database data. The final log confirms that all three containers, the MySQL
volume, and the Compose network were removed.

### Test step 4 — Readiness loop

```bash
echo "Waiting for API and UI services..."

for attempt in {1..30}; do
  if curl -fsS http://localhost:8000/ >/tmp/api-root.json \
    && curl -fsS http://localhost:3000/ >/tmp/ui-root.html; then
    break
  fi
  sleep 5
done
```

Containers can be “started” before the applications are ready to accept
requests. The loop gives the API and UI up to 30 attempts, waiting 5 seconds
between attempts.

The curl flags mean:

| Flag | Meaning |
|---|---|
| `-f` | Treat HTTP 4xx/5xx responses as failures |
| `-s` | Suppress progress output |
| `-S` | Still show errors when a request fails |

The two `curl: (56) Recv failure: Connection reset by peer` messages happened
while the services were still starting. They were handled by the retry loop.
They did not become a pipeline failure because a later retry succeeded.

### Test step 5 — Assertions

```bash
test -s /tmp/api-root.json
test -s /tmp/ui-root.html

grep -q "Fast Api Exam api v1" /tmp/api-root.json

curl -fsS http://localhost:8000/trip >/tmp/api-trips.json
test -s /tmp/api-trips.json
```

These commands turn responses into explicit pass/fail conditions:

- `test -s` verifies that the response file exists and is not empty.
- `grep -q` verifies that the API returned the expected application message.
- `/trip` is requested separately to verify a database-backed API route, not
  only the static root endpoint.
- `curl -f` fails on an HTTP error response.
- Because `set -e` is active, any failed assertion stops the job.

The successful output is:

```text
API root endpoint passed.
API trip endpoint passed.
UI root endpoint passed.
```

This proves:

1. The API process started.
2. The API returned the expected root response.
3. The API could reach MySQL well enough to serve `/trip`.
4. The UI process started and served its root page.

### Test step 6 — Service inspection

```bash
docker compose \
  -f part2-docker/docker-compose.yml \
  ps
```

The captured status showed:

| Service | Image | Result |
|---|---|---|
| `devops_api` | `api-app:latest` | Running; health check starting |
| `devops_db` | `mysql:8.0` | Running and healthy |
| `devops_ui` | `ui-app:latest` | Running and healthy |

The API was still marked `health: starting` at that exact instant, but its
HTTP root and `/trip` checks had already passed. This is a timing difference
between the Compose health-check schedule and the direct smoke-test request;
it is not evidence that the API test failed.

### Final Test Stage result

The supplied GitHub Actions output confirms:

- database image pulled successfully;
- API and UI images rebuilt successfully;
- database, API, and UI containers started;
- UI lint/quality step did not fail;
- API root smoke test passed;
- API `/trip` smoke test passed;
- UI root smoke test passed;
- Compose service status was printed;
- cleanup ran successfully;
- temporary containers, network, and database volume were removed.

The raw evidence is preserved at:

`evidence/part3/task13-test-stage-output.txt`

### Warnings versus failures

| Log message | Classification | Explanation |
|---|---|---|
| Docker image layers downloading | Normal operation | The clean hosted runner had to pull the MySQL base image |
| `Connection reset by peer` during first curl attempts | Recoverable startup condition | The readiness loop retried until the services were ready |
| `pip` running as root during image build | Warning | Build-stage warning; the runtime image still uses a non-root user |
| 13 npm vulnerabilities | Security finding | Important follow-up; not a build/test failure |
| Outdated `caniuse-lite` | Maintenance warning | Does not fail the application build |
| Node.js 20 deprecation warning for `actions/checkout@v4` | Platform warning | The workflow still completed successfully |
| `API root endpoint passed` / `API trip endpoint passed` / `UI root endpoint passed` | Successful assertions | The actual application checks passed |

### Learning summary

The Build Stage answers: “Can a clean runner build the images?”

The Test Stage answers: “Can those applications start and respond correctly
when run together with their database?”

The readiness loop matters because `docker compose up` only means containers
were launched. It does not guarantee that MySQL is ready, that the API has
connected to MySQL, or that Next.js is accepting HTTP requests. The smoke
tests provide that additional evidence.

The Test Stage is now **confirmed complete**. The optional Docker image
security scan is still pending, and the PDF's Deploy Stage and Notifications
requirements remain to be implemented or documented as partial work.

---

## Task 5 — Container Registry: Docker Hub Repository

The Part 3 Deploy Stage requires Docker images to be pushed to a container
registry. Docker Hub was selected as the registry for this walkthrough.

### Confirmed action

The API image repository was created under the Docker Hub namespace:

```text
draiimon112/devops-api
```

The UI image repository was also created:

```text
draiimon112/devops-ui
```

Both repositories are public and ready to receive tagged images. Creating the
repositories alone does not yet prove that images were pushed; later workflow
evidence must show successful `docker push` commands.

### Evidence

- [Docker Hub API repository](screenshots/part3/task14-dockerhub-api-repository.png)
- [Docker Hub UI repository](screenshots/part3/task15-dockerhub-ui-repository.png)

### Current status

These are the first Deploy Stage setup steps. Next comes Docker Hub
authentication through GitHub Secrets and actual image-push evidence from
GitHub Actions. No password or access token is recorded in this
documentation.

---

## Task 6 — Docker Hub Personal Access Token

GitHub Actions needs permission to authenticate to Docker Hub before it can
push the API and UI images. A Docker Hub Personal Access Token (PAT) was
created for this purpose. The PAT is used as the Docker CLI password; the
Docker Hub username remains:

```text
draiimon112
```

### Docker Hub tutorial — create a PAT

1. Sign in to Docker Hub.
2. Open the profile menu and select **Account Settings**.
3. Open **Personal access tokens**.
4. Select **Generate new token**.
5. Use this description:

   ```text
   github-actions-devops
   ```

6. Select **Read & Write** permissions.
7. Generate the token.
8. Copy it immediately and store it safely; Docker Hub displays the token only
   at creation time.

The screenshot confirms the token description and its **Read & Write**
permission. It does not expose the token value.

### Evidence

- [Docker Hub access token created](screenshots/part3/task16-dockerhub-access-token-created.png)

### Security rule

The token must never be committed to the repository, written in the workflow
YAML, placed in documentation, or sent in chat. The next step is to save it as
an encrypted GitHub repository secret. The token itself is intentionally not
recorded in this project.

### Current status

The Docker Hub PAT has been created, but GitHub Actions authentication is not
yet verified. The registry requirement remains incomplete until the workflow
successfully logs in and pushes both tagged images.

---

## Task 7 — GitHub Actions Docker Hub Username Secret

GitHub Actions must receive Docker Hub credentials through encrypted repository
secrets rather than hardcoded values in the workflow file.

### Tutorial — add the Docker Hub username secret

1. Open the GitHub repository.
2. Go to **Settings**.
3. Open **Secrets and variables → Actions**.
4. Select the **Secrets** tab.
5. Select **New repository secret**.
6. Set the name exactly to:

   ```text
   DOCKERHUB_USERNAME
   ```

7. Enter the Docker Hub username as the secret value.
8. Select **Add secret**.

The repository secret list now shows `DOCKERHUB_USERNAME`. GitHub hides the
secret value after it is saved, so the screenshot proves the secret name was
created without exposing the value.

### Evidence

- [GitHub Docker Hub username secret](screenshots/part3/task17-github-dockerhub-username-secret.png)

### Security rule

Only the secret names are documented. The username secret value and Docker Hub
PAT value are not stored in this repository or in chat.

### Current status

`DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` are confirmed as encrypted
repository secret names. The screenshot of the token secret does not expose
its value. GitHub Actions login and image push are not yet verified; image push
and staging deployment remain pending.

### Evidence — Docker Hub token secret

- [GitHub Docker Hub token secret](screenshots/part3/task18-github-dockerhub-token-secret.png)

---

## Task 8 — Current Workflow Baseline Before Deploy Changes

The current workflow was printed from the candidate's WSL repository before
adding the Docker Hub Deploy Stage. The raw output is preserved at:

```text
evidence/part3/task19-current-workflow-output.txt
```

The output confirms that the current workflow contains these jobs:

1. `verify-workflow`
2. `build-images`
3. `test-stage`

It also confirms the existing behavior:

- automatic trigger on pushes to `staging`;
- optional `workflow_dispatch` trigger;
- Docker Compose configuration validation;
- API and UI image builds;
- commit-SHA and branch-name local image tags;
- UI linting;
- API root, API `/trip`, and UI smoke tests;
- Compose cleanup through the `EXIT` trap.

No Docker Hub login, registry image tags, `docker push`, staging update, or
Deploy job appears in this baseline output. This is useful evidence because it
clearly separates the completed Build/Test work from the next Deploy work.

### Evidence

- [Current workflow raw output](evidence/part3/task19-current-workflow-output.txt)

### Current status

The workflow is ready to be extended with a Docker Hub authentication and
image-push step. The next change must use the encrypted
`DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets and must not print either
credential.

---

## Task 9 — Draft Workflow Review: Keep Deploy After Test

The candidate printed a draft workflow after adding Docker Hub tags, login, and
push commands. The raw draft is preserved at:

```text
evidence/part3/task20-workflow-with-dockerhub-push-draft.txt
```

The Docker Hub commands use the correct encrypted secret names and the
repository names are correct. However, the draft places login and push inside
the `build-images` job. That would push images before the Test Stage runs,
which does not match the exam's required Build → Test → Deploy sequence.

There is a second CI design detail: GitHub Actions jobs use fresh runners, so
images built in `build-images` are not automatically available to a later
Deploy job. The final Deploy job must therefore build or otherwise receive the
images explicitly after the Test job succeeds.

### Review result

The draft is **not yet the final workflow**. The Docker Hub login and push
steps must be moved into a separate Deploy job that depends on `test-stage`.
No image push has been claimed from this draft.

---

## Task 10 — Workflow After Removing the Early Push

The workflow was printed again after removing the Docker Hub login and push
steps from the `build-images` job. The raw output is preserved at:

```text
evidence/part3/task21-workflow-after-removing-early-push.txt
```

This correction is valid because the workflow no longer pushes images before
the Test Stage. The Build job still validates Compose, builds the API and UI,
and displays the local images. The Test job still performs linting, smoke
tests, and service inspection.

The next local Step 9 edit removed the remaining image-tagging step from
`build-images`. In the actual WSL file, that step was named
`Tag images with commit SHA and branch` and created four local tags:

```text
api-app:${GITHUB_SHA}
ui-app:${GITHUB_SHA}
api-app:${GITHUB_REF_NAME}
ui-app:${GITHUB_REF_NAME}
```

This wording differs from an earlier draft that called the step `Tag images
for Docker Hub` and included Docker Hub namespace tags. The project record
follows the actual file that was edited, not the earlier example wording.
Both are image-tagging operations; neither is a `docker push`.

### Review result

- Early Docker Hub push: removed correctly.
- Build/Test order: preserved.
- Build-job image tagging: removed from the actual WSL workflow.
- Docker Hub image push: not implemented or claimed.
- Staging deployment: still pending.

### Step 9 local verification result

The candidate verified the actual file from:

```text
/home/draiimon/devops-exam/.github/workflows/deploy.yml
```

The command output confirmed:

```text
OK: Natanggal ang Docker Hub tagging block.
OK: Wala na ang Docker Hub tagging block.
```

`git diff --check` returned no error. The resulting order in the Build job is:

```text
Validate Docker Compose configuration
Build API and UI images
Show built images
```

The full workflow inspection also confirmed that `test-stage` still follows
`build-images`, runs UI linting, starts the database/API/UI services, waits for
the API and UI endpoints, checks the API response, checks `/trip`, and prints
the Compose service status. No test commands were removed during Step 9.

This is a successful **local file edit and verification**. It is not yet
evidence of a successful GitHub Actions run. The eventual Deploy job must
explicitly build or obtain images, tag them, log in securely, and push only
after `test-stage` succeeds.

### Step 9 commit result

After reviewing the file and passing `git diff --check`, the candidate staged
only `.github/workflows/deploy.yml` and created a local commit:

```text
Keep build stage focused on validation
```

The temporary file `deploy.yml.step9-backup` was intentionally not staged or
committed. It appeared as an untracked file after the commit, which is
expected for a local safety copy. It must not be pushed as part of the exam
repository. The commit confirms the Step 9 workflow correction is saved in
local Git history; it does not yet mean that the edited workflow has run on
GitHub Actions.

---

## Beginner Walkthrough — Understanding the Step 9 Workflow Edit

This section explains the exact workflow that was inspected before Step 9. The
goal is not only to edit YAML successfully, but to understand what each part
does and why the Docker Hub tagging step is being removed from the Build job.

### What the workflow file is

`.github/workflows/deploy.yml` is a GitHub Actions workflow file. It is a set
of instructions that GitHub's runner executes automatically. The `.yml`
extension means the file uses YAML syntax, where indentation shows structure.
YAML indentation is significant: spaces are part of the meaning, so tabs
should not be used.

The first lines are:

```yaml
name: CI/CD Pipeline - 2026

on:
  push:
    branches:
      - staging
  workflow_dispatch:
```

Meaning:

| YAML | Beginner explanation |
|---|---|
| `name` | The display name shown in the GitHub Actions page. |
| `on` | The event that starts the workflow. |
| `push` | Start automatically after a push. |
| `branches: staging` | Only pushes to the `staging` branch start it automatically. |
| `workflow_dispatch` | Adds a button so the workflow can also be started manually. |

The workflow also declares:

```yaml
permissions:
  contents: read
```

This gives the workflow read access to repository contents. It is a
least-privilege setting: the workflow does not automatically receive broad
write permission just because it runs.

### The three jobs and their order

The inspected workflow has three jobs:

```text
verify-workflow → build-images → test-stage
```

The arrows come from the `needs` lines:

```yaml
build-images:
  needs: verify-workflow

test-stage:
  needs: build-images
```

`needs` means “do not start this job until the named job succeeds.” This is
how the workflow expresses its sequence. A job is a group of steps running on
one GitHub Actions runner.

Important: jobs normally run on fresh runners. An image created inside
`build-images` is not automatically available inside `test-stage` or a future
Deploy job. A later job must build the image again or receive it through an
explicit artifact/registry mechanism.

### Job 1 — `verify-workflow`

```yaml
verify-workflow:
  name: Verify workflow
  runs-on: ubuntu-latest
```

This gives the job a readable name and requests a clean Ubuntu runner.
Its steps check out the repository and print the branch and commit:

```yaml
- name: Check out repository
  uses: actions/checkout@v4

- name: Confirm CI/CD starts
  run: |
    echo "Part 3 CI/CD workflow started successfully."
    echo "Branch: $GITHUB_REF_NAME"
    echo "Commit: $GITHUB_SHA"
```

`uses: actions/checkout@v4` is a reusable GitHub Action that downloads the
repository into the runner. `run: |` means “run the following indented lines
as shell commands.” `$GITHUB_REF_NAME` and `$GITHUB_SHA` are GitHub-provided
environment variables containing the branch name and commit identifier.

This job does not build or deploy anything. It is an intentionally simple
first check that confirms the workflow started and the repository can be
checked out.

### Job 2 — `build-images`

The Build job first checks out the repository, then validates the Compose
file:

```yaml
- name: Validate Docker Compose configuration
  run: |
    docker compose \
      -f part2-docker/docker-compose.yml \
      config --quiet
```

Breakdown:

- `docker compose` calls Docker Compose.
- `-f part2-docker/docker-compose.yml` selects the project's Compose file.
- `config` reads and validates the Compose configuration.
- `--quiet` suppresses normal output and returns an error if the configuration
  is invalid.
- The backslash (`\`) continues one shell command onto the next line. It is
  only formatting; the shell still sees one command.

The next step builds the real API and UI images:

```yaml
- name: Build API and UI images
  run: |
    docker compose \
      -f part2-docker/docker-compose.yml \
      build api ui
```

`api` and `ui` refer to services in the Compose file. The command uses the
repository's Dockerfiles and source code to create local runner images. It
does not upload them anywhere.

The remaining Build step displays the images:

```yaml
- name: Show built images
  run: |
    docker image ls api-app
    docker image ls ui-app
```

`docker image ls` lists locally available images. These two commands are
separate because some Docker versions accept only one repository argument at a
time.

### What the removed Docker Hub block was doing

The Step 9 block looked like this:

```yaml
- name: Tag images for Docker Hub
  run: |
    docker tag api-app:latest "${{ secrets.DOCKERHUB_USERNAME }}/devops-api:${GITHUB_SHA}"
    docker tag ui-app:latest "${{ secrets.DOCKERHUB_USERNAME }}/devops-ui:${GITHUB_SHA}"

    docker tag api-app:latest "${{ secrets.DOCKERHUB_USERNAME }}/devops-api:${GITHUB_REF_NAME}"
    docker tag ui-app:latest "${{ secrets.DOCKERHUB_USERNAME }}/devops-ui:${GITHUB_REF_NAME}"

    docker tag api-app:latest "${{ secrets.DOCKERHUB_USERNAME }}/devops-api:latest"
    docker tag ui-app:latest "${{ secrets.DOCKERHUB_USERNAME }}/devops-ui:latest"
```

Read one command from right to left:

```bash
docker tag api-app:latest USERNAME/devops-api:COMMIT_ID
```

It gives the same local image a second name. It does not copy the image and
it does not upload the image. A Docker image name has this general shape:

```text
registry-or-username/repository:tag
```

In this workflow:

| Part | Meaning |
|---|---|
| `api-app:latest` | The local API image produced by Compose. |
| `${{ secrets.DOCKERHUB_USERNAME }}` | GitHub Actions securely inserts the Docker Hub username; the value is hidden. |
| `devops-api` / `devops-ui` | The Docker Hub repository names. |
| `${GITHUB_SHA}` | An exact commit-based tag for traceability. |
| `${GITHUB_REF_NAME}` | A branch-based tag such as `staging`. |
| `latest` | A moving tag that normally means the newest published image. |

There are three tags for each image because they serve different purposes:

- **Commit tag:** identifies exactly which source commit produced the image.
- **Branch tag:** identifies the branch version, such as `staging`.
- **`latest` tag:** convenient for a default/current image, but it changes over
  time and is less precise.

`tag` and `push` are different:

```text
docker tag  = give a local image another name
docker push = upload a named image to a registry
```

The removed block only performed `docker tag`. It used the Docker Hub secret
name because the final image name needed the Docker Hub namespace, but it did
not log in and did not push. Passwords and token values must never be written
into this YAML file.

### Why Step 9 removes the block

This edit is a workflow-design correction, not a claim that Docker Hub is no
longer needed. The Build job should validate that the project can build. The
Test job should validate linting and runtime behavior. Publishing belongs
after those checks:

```text
Build → Test → Deploy
```

If image tagging and publishing are placed in the Build job, the pipeline can
prepare a registry image before the application tests pass. That is the wrong
order for a safe CI/CD pipeline.

There is also a runner-isolation reason. Because a later Deploy job receives a
fresh runner, tags created in `build-images` will not magically appear there.
The eventual Deploy job must explicitly build or obtain the images, tag them,
log in using encrypted secrets, and push them only after `test-stage`
succeeds. Step 9 removes the premature tags so the workflow is ready for that
proper Deploy design. Step 9 does **not** complete the Deploy job.

### Job 3 — `test-stage`

The Test job waits for the Build job:

```yaml
test-stage:
  needs: build-images
```

It installs UI dependencies and runs lint:

```yaml
working-directory: part2-docker/ui-src
run: |
  npm ci
  npm run lint
```

`working-directory` changes into the UI source directory for that step.
`npm ci` installs the exact dependency versions from the lockfile. `npm run
lint` checks the UI source for code-quality problems.

The smoke-test step starts the services:

```yaml
docker compose \
  -f part2-docker/docker-compose.yml \
  up -d --build db api ui
```

- `up` creates and starts the services.
- `-d` runs them in the background.
- `--build` rebuilds images if needed.
- `db api ui` lists the services to start.

This line registers cleanup:

```bash
trap 'docker compose -f part2-docker/docker-compose.yml down -v' EXIT
```

It tells the shell to stop the Compose stack when the step exits, including
when a test fails. `down -v` also removes the temporary Compose volumes. This
keeps one CI run from leaving containers or test data behind for another run.

The loop repeatedly requests the API and UI until they respond or the attempts
are exhausted:

```bash
for attempt in {1..30}; do
  if curl -fsS http://localhost:8000/ >/tmp/api-root.json \
    && curl -fsS http://localhost:3000/ >/tmp/ui-root.html; then
    break
  fi
  sleep 5
done
```

`curl -f` treats HTTP errors as failures, `-sS` keeps output readable while
still showing errors, and the `&&` means both endpoints must respond
successfully. The following `test` and `grep` commands then check that files
contain data and that the expected API response is present. This is stronger
evidence than merely proving that containers started.

### Two safe ways to perform Step 9

**Nano method, useful for learning:**

```bash
nano .github/workflows/deploy.yml
```

1. Press `Ctrl + W`.
2. Search for `Tag images for Docker Hub`.
3. Press `Enter`.
4. Use `Ctrl + A` to move to the beginning of the current line.
5. Press `Ctrl + K` once for each line in that block.
6. Stop before `- name: Show built images`.
7. Press `Ctrl + O`, then `Enter` to save.
8. Press `Ctrl + X` to exit.

`Ctrl + A` does **not** select the whole file in Nano; it moves to the
beginning of the current line. `Ctrl + K` cuts one line at a time. This is
why counting lines can be error-prone.

**Safer terminal method, useful when the block boundaries are known:**

```bash
cp .github/workflows/deploy.yml .github/workflows/deploy.yml.step9-backup

python3 - <<'PY'
from pathlib import Path

file = Path(".github/workflows/deploy.yml")
text = file.read_text()
start_marker = "      - name: Tag images for Docker Hub"
end_marker = "\n      - name: Show built images"
start = text.find(start_marker)
end = text.find(end_marker, start)
if start == -1 or end == -1:
    raise SystemExit("Expected Step 9 block was not found; no edit made.")
file.write_text(text[:start] + text[end + 1:])
print("Step 9 complete; backup retained.")
PY
```

This method stops with an error rather than guessing if either boundary is
missing. It also creates a backup before editing.

### Verify before commit or push

After either method, run:

```bash
sed -n '38,68p' .github/workflows/deploy.yml
grep -n "Tag images for Docker Hub" .github/workflows/deploy.yml \
  || echo "OK: Docker Hub tagging block is absent."
git diff --check
git diff -- .github/workflows/deploy.yml
```

The expected order is:

```text
Build API and UI images
Show built images
Test applications
```

Do not commit or push until the displayed section and diff match the intended
change. A local edit proves only that the file changed; a GitHub Actions run
is needed to prove that GitHub accepted and executed the workflow.

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

## Beginner Tutorial — Nano and Terminal Quick Hacks

These shortcuts were used while editing and checking the GitHub Actions
workflow. They are useful when working in a WSL terminal without opening a
full graphical editor.

### Open a file in Nano

```bash
nano .github/workflows/deploy.yml
```

`nano` opens the file directly in the terminal. The shortcut guide is shown at
the bottom of the screen. The `^` symbol means **Ctrl**. For example, `^W`
means **Ctrl + W**.

### Find text quickly

Instead of scrolling through a long YAML file:

1. Press **Ctrl + W**.
2. Type a distinctive phrase, for example:

   ```text
   Tag images for Docker Hub
   ```

3. Press **Enter**.

Nano jumps to the matching text. This is safer and faster than trying to find
the correct section by scrolling.

### Delete a whole block line by line

To remove a block after finding its first line:

1. Press **Ctrl + A** to move to the beginning of the current line.
2. Press **Ctrl + K** once for each line that should be removed.
3. Stop when the next line is the first line that must remain.

Important: in Nano, **Ctrl + A does not select the entire file**. It moves to
the beginning of the current line. **Ctrl + K** cuts the current line and
places it in Nano's cut buffer.

### Paste a YAML block

After placing the cursor at the correct location, paste using either:

- right-click in the terminal; or
- **Shift + Insert**.

Keep YAML indentation exactly as shown. Use spaces, not tabs. A job step
usually has six spaces before `- name`, and commands under `run: |` usually
have eight or ten spaces depending on their nesting level.

### Save and exit safely

After editing:

1. Press **Ctrl + O** to write the file.
2. Press **Enter** to confirm the existing filename.
3. Press **Ctrl + X** to exit Nano.

If Nano asks whether to save changes when exiting, choose `Y`, then press
**Enter** to confirm the filename.

### Verify the exact section after editing

Do not immediately commit after leaving Nano. Print only the relevant lines:

```bash
sed -n '38,75p' .github/workflows/deploy.yml
```

For the whole workflow:

```bash
cat .github/workflows/deploy.yml
```

For a numbered view that makes indentation easier to inspect:

```bash
nl -ba .github/workflows/deploy.yml | sed -n '1,150p'
```

### Check for whitespace problems

Before committing:

```bash
git diff --check
```

No output means the whitespace check passed. If it prints a line, fix that
line before continuing.

### Review the change before committing

```bash
git diff -- .github/workflows/deploy.yml
git status --short
```

The safe beginner sequence is:

```text
Search → edit a small block → save → exit → print the section → diff check
→ review diff → commit only after the YAML is confirmed
```

### Safety rules used in this walkthrough

- Do not paste Docker Hub passwords or tokens into the workflow file.
- Do not send token values in chat or screenshots.
- Do not commit immediately after editing.
- Do not push to GitHub until the workflow structure has been reviewed.
- Treat a pasted terminal output as evidence of what was displayed, not as
  proof that a workflow run succeeded.
- A workflow edit is not a successful deployment until GitHub Actions actually
  runs it and the logs show the expected result.

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

1. optional Docker image security scanning;
2. staging deployment;
3. container registry/artifact storage;
4. secrets management without exposing credentials;
5. rollback strategy;
6. success and failure notifications;
7. final full-pipeline screenshots and documentation update.

Part 3 must not be marked complete until these stages are implemented or
explicitly documented as partial submission items.

---

## Screenshot Inventory

All currently supplied Part 3 screenshots are stored in:

```text
documentation/screenshots/part3/
```

The folder contains 29 screenshot evidence files: 12 GitHub setup/history
screenshots and 17 staging/workflow/build, Test Stage, and Deploy Stage
preparation screenshots. The raw Test Stage output, current workflow
baseline, draft workflow review, and post-correction workflow output are
preserved separately at:

`evidence/part3/task13-test-stage-output.txt`

`evidence/part3/task19-current-workflow-output.txt`

`evidence/part3/task20-workflow-with-dockerhub-push-draft.txt`

`evidence/part3/task21-workflow-after-removing-early-push.txt`

The latest screenshot preparation evidence is:

- [Test Stage pre-push validation](screenshots/part3/task12-test-stage-pre-push-check.png)

This screenshot confirms that `git diff --check` returned no errors and that
only `.github/workflows/deploy.yml` was modified before the Test Stage commit.
It does not yet prove that the GitHub Actions Test Stage passed.