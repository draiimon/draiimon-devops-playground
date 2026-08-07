# Part 3: CI/CD Pipeline — Documentation

**Candidate:** draiimon  
**Machine:** Aloof — WSL2 (Ubuntu 24.04 on Windows)  
**Date Completed:** August 7, 2026  
**Exam:** Junior DevOps Engineer Exam 2026

---

## Connection to Previous Part

Part 2 created production-ready Docker images and a Docker Compose stack for the
FastAPI API, Next.js UI, and MySQL database. Part 3 automates the next steps:
building those images after a code change, checking the application sources,
scanning the images, publishing them to Docker Hub, and deploying the tagged
images to the Kubernetes staging environment.

| Previous work | CI/CD connection |
|---------------|------------------|
| API Dockerfile | GitHub Actions builds the API image from `part2-docker/api-src/`. |
| UI Dockerfile | GitHub Actions builds the UI image from `part2-docker/ui-src/`. |
| Docker Compose integration | The workflow starts the Compose stack and verifies API, UI, and database-backed responses. |
| Kubernetes/Helm files from Part 4 | The deploy job runs `helm upgrade --install --atomic` against the staging cluster. |

---

## Environment Overview

The pipeline is implemented as **GitHub Actions** using the workflow file
`part3-cicd/.github/workflows/deploy.yml`. GitHub-hosted Ubuntu runners perform
the build and validation work. Docker Hub stores the published images, and the
staging Kubernetes cluster receives the deployment through Helm.

| Item | Value |
|------|-------|
| CI/CD platform | GitHub Actions |
| Workflow file | `part3-cicd/.github/workflows/deploy.yml` |
| Automatic branch | `staging` |
| Manual trigger | `workflow_dispatch` |
| Runner | `ubuntu-latest` |
| Container registry | Docker Hub |
| API build context | `part2-docker/api-src` |
| UI build context | `part2-docker/ui-src` |
| Local integration stack | `part2-docker/docker-compose.yml` |
| Deployment tool | Helm |
| Staging orchestrator | Kubernetes |
| Kubernetes namespace | `devops-exam` |
| Notification channel | Slack |

---

## Chosen Platform — GitHub Actions

GitHub Actions was selected because it is the CI/CD platform currently familiar
to the candidate and is directly integrated with GitHub repositories. The
pipeline is stored as code in the repository, so its trigger rules, build
commands, validation steps, deployment process, and notifications can be
reviewed and changed together with the application.

The workflow uses a matrix for the API and UI image builds. This allows both
images to build independently and in parallel while using the same secure and
repeatable build steps.

---

## Requirement 1 — Automatic Triggering

### Configuration

```yaml
name: CI/CD Pipeline — 2026

on:
  push:
    branches: [staging]
  workflow_dispatch:
    inputs:
      reason:
        description: "Reason for manual deploy"
        required: false
        default: "Manual trigger"
```

### Explanation

| Configuration | What it does |
|---------------|--------------|
| `on: push` | Starts the workflow after a repository push event. |
| `branches: [staging]` | Limits automatic execution to commits pushed to the `staging` branch. |
| `workflow_dispatch` | Adds a Run workflow button for an authorized manual run. |
| `reason` input | Allows the operator to record why a manual deployment was started. |

This satisfies the PDF requirement that the pipeline trigger automatically on
commits to `staging`, while also providing an optional manual trigger.

### Commands Used to Inspect the Trigger

```bash
cd ~/devops-exam
sed -n '1,30p' part3-cicd/.github/workflows/deploy.yml
```

### Output

```text
on:
  push:
    branches: [staging]
  workflow_dispatch:
```

### Explanation

The output shows that the branch trigger and manual trigger are both present in
the committed workflow file. A live GitHub Actions run requires the repository
to be pushed to GitHub and the required secrets to be configured.

---

## Requirement 2 — Build Stage

### Build Matrix Configuration

```yaml
strategy:
  fail-fast: false
  matrix:
    include:
      - app: api
        context: ./part2-docker/api-src
        image_var: API_IMAGE
      - app: ui
        context: ./part2-docker/ui-src
        image_var: UI_IMAGE
```

The build contexts point to the actual cloned Bitbucket application sources.
This is important because the source-based Dockerfiles from Part 2 copy the
application files during the image build.

### Docker Build and Tagging Configuration

```yaml
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v3

- name: Validate Dockerfile
  run: docker buildx build --check "${{ matrix.context }}"

- name: Log in to Docker Hub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKER_PASSWORD }}

- name: Docker metadata
  id: meta
  uses: docker/metadata-action@v5
  with:
    images: ${{ env[matrix.image_var] }}
    tags: |
      type=sha,prefix=,format=long
      type=ref,event=branch
      type=raw,value=latest,enable=${{ github.ref == 'refs/heads/staging' }}

- name: Build and push ${{ matrix.app }} image
  uses: docker/build-push-action@v5
  with:
    context: ${{ matrix.context }}
    push: true
    tags: ${{ steps.meta.outputs.tags }}
    cache-from: type=gha,scope=${{ matrix.app }}
    cache-to: type=gha,scope=${{ matrix.app }},mode=max
    provenance: true
    sbom: true
```

### Explanation

| Step or setting | What it does |
|-----------------|--------------|
| `docker/setup-buildx-action` | Enables Docker Buildx for modern image builds and caching. |
| `docker buildx build --check` | Validates the Dockerfile before the image is published. |
| `docker/login-action` | Authenticates to Docker Hub using GitHub secrets. |
| `docker/metadata-action` | Generates consistent image tags and OCI labels. |
| Full SHA tag | Gives each image an immutable commit-based version. |
| Branch tag | Keeps a branch reference available for the workflow output. |
| `latest` on `staging` | Marks the latest image produced from the staging branch. |
| `docker/build-push-action` | Builds and publishes the API or UI image. |
| `cache-from` / `cache-to` | Reuses BuildKit layers to reduce later build time. |
| `provenance: true` | Publishes build provenance metadata. |
| `sbom: true` | Includes software bill of materials metadata with the image. |
| `fail-fast: false` | Allows the API and UI matrix results to finish independently. |

### Image Naming

The workflow defines these registry image names:

```yaml
env:
  REGISTRY: docker.io
  API_IMAGE: ${{ secrets.DOCKER_USERNAME }}/api-app
  UI_IMAGE: ${{ secrets.DOCKER_USERNAME }}/ui-app
```

The resulting images use the candidate's Docker Hub namespace and include a
commit SHA tag, a branch tag, and `latest` for the staging branch.

---

## Requirement 3 — Test Stage

### API Source Validation

```yaml
- name: Validate API Python source
  working-directory: ./part2-docker/api-src
  run: |
    python -m compileall -q .
    grep -q "FastAPI" main.py
    grep -q "uvicorn" requirements.txt
```

The cloned API repository does not contain a `tests/` directory or a test
runner configuration. Therefore, the workflow performs an executable Python
compile check and validates the expected FastAPI and Uvicorn application
dependencies instead of claiming that nonexistent unit tests ran.

### UI Lint and Production Build

```yaml
- name: Set up Node 20
  uses: actions/setup-node@v4
  with:
    node-version: "20"
    cache: npm
    cache-dependency-path: part2-docker/ui-src/package-lock.json

- name: Lint and build UI
  working-directory: ./part2-docker/ui-src
  run: |
    npm ci
    npm run lint
    npm run build
```

The UI uses the committed `package-lock.json`, runs the existing `lint` script,
and compiles a production Next.js build. Any failed command stops the job.

### Docker Compose Integration Smoke Test

```yaml
- name: Run Docker Compose integration smoke test
  run: |
    docker compose -f part2-docker/docker-compose.yml up -d --build
    trap 'docker compose -f part2-docker/docker-compose.yml down -v' EXIT

    for attempt in {1..30}; do
      if curl --fail --silent http://localhost:8000/ >/dev/null \
        && curl --fail --silent http://localhost:3000/ >/dev/null \
        && curl --fail --silent http://localhost:8000/trip >/dev/null; then
        break
      fi
      if [ "$attempt" -eq 30 ]; then
        docker compose -f part2-docker/docker-compose.yml logs
        exit 1
      fi
      sleep 5
    done

    curl --fail --silent -X POST http://localhost:8000/trip \
      -H "Content-Type: application/json" \
      -d '{"name":"CI Smoke Test","description":"GitHub Actions integration check","joiner_total_count":1}' \
      >/dev/null

    curl --fail --silent http://localhost:8000/trip >/dev/null
```

### Explanation

| Test or validation | What it proves |
|--------------------|----------------|
| `python -m compileall` | Python files compile without syntax errors. |
| FastAPI/Uvicorn checks | The expected API application structure is present. |
| `npm ci` | The UI dependencies install from the committed lockfile. |
| `npm run lint` | The UI passes its configured linting rules. |
| `npm run build` | The UI can be compiled for production. |
| Compose startup | The API, UI, and MySQL services can be built and started together. |
| API root request | The FastAPI service responds through port `8000`. |
| UI root request | The production Next.js service responds through port `3000`. |
| `/trip` GET request | The API can reach its database-backed route. |
| `/trip` POST and GET | A record can be created and read back through the running stack. |
| `curl --fail` | Any non-success HTTP response causes the smoke test to fail. |
| `trap ... down -v` | The temporary CI Compose stack is cleaned up after the job. |

This test stage uses real application and container behavior. It does not
invent unit-test results for test files that are not present in the cloned
repositories.

---

## Security Scan and Build Integrity

Although security scanning is optional in the PDF, this pipeline includes it as
a separate job:

```yaml
- name: Run Trivy vulnerability scan
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: ${{ env[matrix.image_var] }}:${{ github.sha }}
    format: sarif
    output: trivy-${{ matrix.app }}.sarif
    severity: CRITICAL,HIGH
    exit-code: 1
```

The scan runs after the images are built and published. A CRITICAL or HIGH
finding makes the scan job fail, and the SARIF report is uploaded to the
GitHub Security tab for review.

The build also generates an SBOM and provenance metadata and signs each image
with Cosign. These features improve traceability and help verify where an image
came from.

---

## Requirement 4 — Deploy Stage

### Kubernetes Deployment

```yaml
deploy:
  name: Deploy to Staging
  needs: [build, scan, test]
  environment:
    name: staging
    url: http://api.myapp.local
```

The deployment job cannot begin until the build, security scan, and test jobs
have succeeded.

```yaml
- name: Configure kubectl
  uses: azure/k8s-set-context@v4
  with:
    method: kubeconfig
    kubeconfig: ${{ secrets.KUBE_CONFIG_STAGING }}

- name: Helm upgrade (atomic — auto-rollback on failure)
  run: |
    helm upgrade myapp ./part4-ha/helm \
      --install \
      --namespace devops-exam \
      --create-namespace \
      --set api.image.repository=${{ env.API_IMAGE }} \
      --set api.image.tag=${{ steps.tag.outputs.tag }} \
      --set ui.image.repository=${{ env.UI_IMAGE }} \
      --set ui.image.tag=${{ steps.tag.outputs.tag }} \
      --atomic \
      --timeout 5m \
      --history-max 5
```

### Rollout and Smoke Verification

```yaml
- name: Verify rollout
  run: |
    kubectl rollout status deployment/myapp-api --namespace devops-exam --timeout=2m
    kubectl rollout status deployment/myapp-ui  --namespace devops-exam --timeout=2m

- name: Smoke test
  run: |
    sleep 10
    kubectl run smoke-test --rm -i --restart=Never \
      --image=curlimages/curl:latest \
      --namespace devops-exam \
      -- curl -sf http://myapp-api-service/healthz || exit 1
```

### Explanation

| Deployment setting or step | What it does |
|----------------------------|--------------|
| `needs: [build, scan, test]` | Prevents deployment when an earlier quality gate fails. |
| `KUBE_CONFIG_STAGING` | Provides the staging cluster context through a GitHub secret. |
| `helm upgrade --install` | Installs the release if absent or upgrades it if present. |
| `--namespace devops-exam` | Keeps the staging resources isolated in the exam namespace. |
| Image repository values | Selects the Docker Hub API and UI repositories. |
| Full commit tag | Deploys the exact images produced by the current workflow run. |
| `--atomic` | Automatically rolls back the Helm release if the upgrade fails. |
| `--timeout 5m` | Limits how long Helm waits for the deployment operation. |
| `--history-max 5` | Retains recent Helm revisions for rollback and troubleshooting. |
| `kubectl rollout status` | Waits for both deployments to become available. |
| Kubernetes smoke test | Verifies that the deployed API service responds inside the cluster. |

The deployment uses a rolling-update strategy defined by the Kubernetes/Helm
configuration from Part 4. The atomic flag provides an automatic rollback path
when the release cannot become healthy.

---

## Requirement 5 — Notifications

### Success Notification

```yaml
- name: Slack — success
  if: ${{ needs.deploy.result == 'success' }}
  uses: slackapi/slack-github-action@v1
```

### Failure Notification

```yaml
- name: Slack — failure
  if: ${{ needs.deploy.result != 'success' }}
  uses: slackapi/slack-github-action@v1
```

The notification job uses `if: always()` and depends on all previous jobs, so it
can report either a successful or unsuccessful pipeline result.

Both messages include:

- branch name
- commit SHA
- GitHub actor
- link to the workflow run or its logs

This satisfies the PDF requirement for success and failure notifications with
relevant commit and run information.

---

## Required GitHub Secrets

Secrets must be configured in the GitHub repository settings. They must not be
committed to the repository or printed in workflow output.

| Secret | Purpose |
|--------|---------|
| `DOCKER_USERNAME` | Docker Hub account namespace. |
| `DOCKER_PASSWORD` | Docker Hub access token used by the login action. |
| `KUBE_CONFIG_STAGING` | Kubeconfig used to access the staging Kubernetes cluster. |
| `SLACK_WEBHOOK_URL` | Slack incoming webhook used for pipeline notifications. |

The workflow uses GitHub's secret references, for example:

```yaml
${{ secrets.DOCKER_USERNAME }}
${{ secrets.DOCKER_PASSWORD }}
${{ secrets.KUBE_CONFIG_STAGING }}
${{ secrets.SLACK_WEBHOOK_URL }}
```

---

## Pipeline Job Order

```text
push to staging or manual workflow_dispatch
                    ↓
build (API + UI matrix jobs in parallel)
                    ↓
scan (Trivy) + test (source checks, UI build, Compose smoke test)
                    ↓
deploy (Helm rolling update to Kubernetes staging)
                    ↓
rollout verification + Kubernetes smoke test
                    ↓
notify (Slack success or failure, always runs)
```

---

## Problems Encountered and Solutions

| Problem | Cause | Solution |
|---------|-------|----------|
| Workflow originally built from `part2-docker/api` and `part2-docker/ui` | Those folders contain the standalone Docker setup files, not the complete cloned application source used by the final Compose stack. | Updated the matrix contexts to `part2-docker/api-src` and `part2-docker/ui-src`. |
| Workflow referenced `pytest tests/` for the API | The cloned API source does not contain a `tests/` directory. | Replaced the nonexistent test command with Python compilation checks and a real Compose integration smoke test. |
| Workflow referenced `npm test` for the UI | The cloned UI `package.json` has `lint`, `build`, and `start`, but no `test` script. | Use the existing UI lint/build scripts and the end-to-end Compose smoke test. |
| Registry scan used `latest` while deployment used a commit tag | The scan and deployment could inspect different image versions. | Use the full `github.sha` tag for scan and deployment consistency. |
| README described SSH deployment | The actual workflow deploys through Helm to Kubernetes. | Updated the README to describe the GitHub Actions and Helm flow. |

---

## Local Inspection Commands

```bash
cd ~/devops-exam

# Inspect the workflow
sed -n '1,304p' part3-cicd/.github/workflows/deploy.yml

# Check the application build contexts
find part2-docker/api-src part2-docker/ui-src -maxdepth 2 -type f | sort

# Validate the local Compose configuration
docker-compose -f part2-docker/docker-compose.yml config

# Run the same local integration stack used by the CI smoke test
docker-compose -f part2-docker/docker-compose.yml up -d --build
curl --fail http://localhost:8000/
curl --fail http://localhost:3000/
curl --fail http://localhost:8000/trip
docker-compose -f part2-docker/docker-compose.yml down
```

The GitHub-hosted workflow uses the newer `docker compose` command available on
GitHub's Ubuntu runner. The local WSL environment documented in Part 2 uses
legacy `docker-compose` version 1.29.2.

---

## ✅ Part 3 — Completion Summary

| Requirement | Description | Status |
|-------------|-------------|--------|
| Requirement 1 | Automatic trigger on `staging` plus manual `workflow_dispatch` | ✅ Complete |
| Requirement 2 | API/UI Docker builds, commit/branch tags, cache, Dockerfile validation, SBOM, provenance | ✅ Complete |
| Requirement 3 | API source validation, UI lint/build, Compose integration smoke test, fail-on-error behavior | ✅ Complete |
| Security enhancement | Trivy scan for CRITICAL/HIGH vulnerabilities and SARIF upload | ✅ Complete |
| Requirement 4 | Docker Hub push and Helm deployment to Kubernetes staging with atomic rollback | ✅ Complete |
| Requirement 5 | Slack success/failure notifications with branch, commit, actor, and run link | ✅ Complete |
| Documentation | GitHub secrets, job order, troubleshooting, and local inspection commands | ✅ Complete |

**Part 3 GitHub Actions pipeline configuration and documentation are complete.**

---

## 📸 Screenshot Checklist

| Screenshot | Filename | Status |
|------------|----------|--------|
| Workflow trigger and YAML configuration | `task03-cicd-pipeline.png` | ⏳ Live GitHub Actions screenshot can be added after the workflow is pushed and run |

The committed workflow file itself is the primary configuration evidence for
Part 3. A GitHub Actions run screenshot is optional supporting evidence and
requires the repository to be connected to GitHub with the required secrets.