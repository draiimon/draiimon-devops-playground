# Part 4: High Availability Deployment — Documentation

**Candidate:** draiimon  
**Exam:** Junior DevOps Engineer Exam 2026  
**Chosen orchestration platform:** Kubernetes  
**Configuration directory:** `part4-ha/`  
**Source of truth:** `documentation/reference/Junior_DevOps_Engineer_Exam_2026.pdf`

> **Evidence boundary:** This document records the Kubernetes and Helm
> configuration currently present in the repository. At the time of writing,
> no Part 4 screenshot set or live-cluster command output has been captured in
> this repository. Therefore, configuration is described as **configured** and
> live deployment behavior is not marked as proven until a real cluster run is
> documented.

---

## PDF Requirements Status

The PDF defines Part 4 as **High Availability Deployment**. It requires:

1. Redundancy
2. Load distribution
3. Domain-based access
4. One orchestration option

Kubernetes is the selected option because it provides Deployments, Services,
Ingress, health probes, rolling updates, autoscaling, and disruption
protection in one platform.

| PDF requirement | Repository implementation | Evidence status |
|---|---|---|
| Applications on at least 2 servers, VMs, or nodes | Two replicas per API and UI Deployment, with node-spread constraints | Configured; multi-node runtime not yet captured |
| Automatic failover and recovery | Kubernetes Deployments, restart policy, liveness probes, readiness probes | Configured; failover test not yet captured |
| Load distribution | ClusterIP Services select all ready replicas; Ingress routes each host to its Service | Configured; traffic distribution not yet captured |
| Domain-based access | `api.myapp.local` and `ui.myapp.local` Ingress hosts plus hosts-file instructions | Configured; domain request not yet captured |
| Health checks | API `/healthz`; UI `/`; liveness and readiness probes | Configured; probe status not yet captured |
| Horizontal scaling | API and UI HPA templates with minimum replica count of 2 | Configured; metrics-server/HPA behavior not yet captured |
| Zero-downtime updates | RollingUpdate with `maxUnavailable: 0` and `maxSurge: 1` | Configured; rollout result not yet captured |
| Orchestration manifests | Raw Kubernetes manifests and a Helm chart | Repository files present |

---

## Environment and Architecture

The deployment is designed for the FastAPI API and Next.js UI containers built
in Part 2 and published by the Part 3 pipeline.

```text
                         Domain-based requests
                    ┌──────────────────────────┐
                    │ api.myapp.local           │
                    │ ui.myapp.local            │
                    └────────────┬─────────────┘
                                 │
                       ┌─────────▼─────────┐
                       │ Kubernetes Ingress │
                       │ nginx controller   │
                       └─────────┬─────────┘
                         ┌───────┴────────┐
                         │                │
                 ┌───────▼───────┐ ┌──────▼────────┐
                 │ API ClusterIP │ │ UI ClusterIP  │
                 │ Service       │ │ Service       │
                 └───────┬───────┘ └──────┬────────┘
                         │                │
                    ┌────┴────┐      ┌────┴────┐
                    │ API pod │      │ UI pod  │
                    │ API pod │      │ UI pod  │
                    └─────────┘      └─────────┘
```

The Helm defaults request two API replicas and two UI replicas. The
`topologySpreadConstraints` attempt to place replicas on different
`kubernetes.io/hostname` values. This improves fault tolerance when the
cluster has at least two schedulable nodes; two replicas alone do not prove
that two physical or virtual nodes exist.

---

## Task 1 — Redundancy, Failover, and Health Recovery

### Commands Executed

```bash
cd ~/devops-exam

find part4-ha -type f -print | sort

sed -n '1,180p' part4-ha/helm/values.yaml
sed -n '1,180p' part4-ha/helm/templates/deployment-api.yaml
sed -n '1,180p' part4-ha/helm/templates/deployment-ui.yaml
sed -n '1,160p' part4-ha/helm/templates/pdb.yaml
```

### Output

The repository contains:

```text
part4-ha/helm/Chart.yaml
part4-ha/helm/values.yaml
part4-ha/helm/values.staging.yaml
part4-ha/helm/templates/deployment-api.yaml
part4-ha/helm/templates/deployment-ui.yaml
part4-ha/helm/templates/pdb.yaml
part4-ha/helm/templates/hpa.yaml
part4-ha/k8s/api-deployment.yaml
part4-ha/k8s/ui-deployment.yaml
part4-ha/k8s/poddisruptionbudget.yaml
```

The Helm values define:

```yaml
api:
  replicaCount: 2

ui:
  replicaCount: 2

pdb:
  enabled: true
  minAvailable: 1
```

The Deployment templates define:

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 0
    maxSurge: 1
```

The API and UI templates also define liveness and readiness probes. The API
probe uses `/healthz`; the UI probe uses `/`.

### Explanation

Redundancy is implemented at the pod level:

- The API starts with at least two replicas.
- The UI starts with at least two replicas.
- A Service can route traffic to all matching ready pods.
- A failed container can be restarted by Kubernetes.
- A liveness probe identifies a stuck application.
- A readiness probe removes an unready pod from traffic without necessarily
  restarting it.
- `maxUnavailable: 0` prevents a rolling update from intentionally reducing
  the available replica count before a replacement is ready.
- A PodDisruptionBudget requires at least one pod to remain available during
  voluntary disruptions.
- The topology spread rule requests distribution across node hostnames.

The PDF asks for applications across at least two nodes. The manifest expresses
the placement requirement, but the repository does not contain a captured
`kubectl get nodes` result. The two-node requirement must be demonstrated on
the target cluster rather than inferred from `replicas: 2`.

### 📸 Screenshots

No Part 4 screenshot has been captured for this task yet.

The required evidence should be placed directly under this task:

```text
kubectl get nodes -o wide
kubectl get pods -n devops-exam -o wide
kubectl describe deployment myapp-api -n devops-exam
kubectl describe deployment myapp-ui -n devops-exam
kubectl get pdb -n devops-exam
kubectl get pods -n devops-exam -w
```

### Screenshot Explanation

The node screenshot should prove that the cluster has at least two schedulable
nodes. The pod listing should show two API pods and two UI pods, including the
node on which each pod runs. The Deployment and PDB outputs should explain
why the application can recover from a pod failure while preserving service
availability.

A valid failover demonstration should delete one replica, then show that the
Service remains available and Kubernetes creates or schedules a replacement.
That result must be captured from a real cluster; a manifest alone is not
failover evidence.

---

## Task 2 — Load Distribution and Zero-Downtime Updates

### Commands Executed

```bash
sed -n '1,180p' part4-ha/helm/templates/services.yaml
sed -n '1,180p' part4-ha/helm/templates/ingress.yaml
sed -n '1,180p' part4-ha/helm/templates/hpa.yaml
sed -n '1,180p' part4-ha/helm/templates/pdb.yaml
```

### Output

The chart creates two internal ClusterIP Services:

```yaml
api:
  type: ClusterIP
  port: 80
  targetPort: 8000

ui:
  type: ClusterIP
  port: 80
  targetPort: 3000
```

The chart also defines HorizontalPodAutoscalers:

```yaml
api:
  minReplicas: 2
  maxReplicas: 6

ui:
  minReplicas: 2
  maxReplicas: 4
```

The API HPA uses CPU and memory utilization targets. The UI HPA uses a CPU
utilization target. Both HPAs require resource requests and a working
metrics-server installation.

### Explanation

The ClusterIP Services provide the stable internal endpoints for the
replicated workloads. Kubernetes selects pods using the component labels
defined by the chart. Only ready pods should receive application traffic
because readiness probes control endpoint eligibility.

The Ingress is the external routing layer. It sends API host traffic to the
API Service and UI host traffic to the UI Service. This means callers do not
need direct pod IP addresses or direct application port access.

The HorizontalPodAutoscaler adds horizontal scaling within the configured
limits. It does not replace the baseline two replicas: the minimum remains
two even when traffic is low.

The rolling-update settings support zero-downtime deployment behavior:

1. Kubernetes creates a replacement pod.
2. The replacement must pass readiness checks.
3. The old pod is not counted as unavailable during the update.
4. The Service continues routing to available ready endpoints.

No session-persistence configuration is present. That is acceptable for the
current stateless API/UI design, but a stateful session feature would require
an explicit session strategy such as shared storage or cookie-based affinity.

### 📸 Screenshots

No Part 4 screenshot has been captured for this task yet.

The required evidence should be placed here:

```text
kubectl get svc -n devops-exam
kubectl get endpointslice -n devops-exam
kubectl get hpa -n devops-exam
kubectl rollout status deployment/myapp-api -n devops-exam
kubectl rollout status deployment/myapp-ui -n devops-exam
```

### Screenshot Explanation

The Service and EndpointSlice output should show that the stable Service names
resolve to multiple ready pod endpoints. The HPA output should show the
configured minimum and maximum replica counts and its metrics status.

The rollout screenshot should show a completed update with no unavailable
replicas. To prove traffic distribution rather than only configuration,
capture repeated requests or application logs while more than one ready
replica is serving traffic.

---

## Task 3 — Domain-Based Access

### Commands Executed

```bash
sed -n '1,180p' part4-ha/helm/values.yaml
sed -n '1,180p' part4-ha/helm/templates/ingress.yaml
sed -n '1,180p' part4-ha/k8s/ingress.yaml
```

### Output

The configured local domains are:

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    api: api.myapp.local
    ui: ui.myapp.local
```

The expected hosts-file entries are:

```text
127.0.0.1 api.myapp.local
127.0.0.1 ui.myapp.local
```

For a Minikube cluster, the address should use the actual Minikube IP:

```bash
echo "$(minikube ip) api.myapp.local ui.myapp.local" | sudo tee -a /etc/hosts
```

### Explanation

The Ingress defines host-based routing:

- `api.myapp.local/` routes to the API ClusterIP Service on port 80.
- `ui.myapp.local/` routes to the UI ClusterIP Service on port 80.

The Services then forward traffic to the application container ports:

- API Service port 80 → API pod port 8000.
- UI Service port 80 → UI pod port 3000.

This satisfies the PDF's domain-based access design because users access host
names instead of direct application IP:port combinations. The `/etc/hosts`
mapping is local DNS for a development or exam cluster. A production
deployment would use a real DNS record and a reachable Ingress address.

The domain names are also used in the UI configuration:
`NEXT_PUBLIC_API_URL` is set to `http://api.myapp.local`. This keeps browser
requests on the domain-based API route rather than exposing an internal
ClusterIP address.

### 📸 Screenshots

No Part 4 screenshot has been captured for this task yet.

The required evidence should be placed here:

```text
kubectl get ingress -n devops-exam
getent hosts api.myapp.local
getent hosts ui.myapp.local
curl -i http://api.myapp.local/healthz
curl -I http://ui.myapp.local/
```

### Screenshot Explanation

The Ingress output should show both host rules and their backend Services.
The hosts lookup should show that the local names resolve to the cluster
entrypoint. The API request should return its health response, and the UI
request should return an HTTP response through the domain name.

If the Ingress controller is exposed through a non-loopback address, replace
`127.0.0.1` with the actual cluster or load-balancer address. Do not label a
direct `localhost:8000` or `localhost:3000` test as domain-based evidence.

---

## Task 4 — Kubernetes Orchestration and Deployment Operations

### Commands Executed

```bash
kubectl apply -f part4-ha/k8s/

helm lint ./part4-ha/helm

helm install myapp ./part4-ha/helm \
  --namespace devops-exam \
  --create-namespace \
  --set api.image.repository=YOUR_DOCKERHUB_USERNAME/api-app \
  --set api.image.tag=YOUR_TAG \
  --set ui.image.repository=YOUR_DOCKERHUB_USERNAME/ui-app \
  --set ui.image.tag=YOUR_TAG

helm upgrade myapp ./part4-ha/helm \
  --namespace devops-exam \
  --set api.image.repository=YOUR_DOCKERHUB_USERNAME/api-app \
  --set api.image.tag=YOUR_TAG \
  --set ui.image.repository=YOUR_DOCKERHUB_USERNAME/ui-app \
  --set ui.image.tag=YOUR_TAG \
  --atomic \
  --timeout 3m
```

### Output

The repository provides both deployment styles required for Kubernetes work:

```text
part4-ha/k8s/       raw Kubernetes manifests
part4-ha/helm/      reusable Helm chart
part4-ha/argocd/    ArgoCD GitOps Application
```

The raw manifests include:

- Namespace
- API and UI Deployments
- API and UI ClusterIP Services
- ConfigMap
- Secret template
- Ingress
- HorizontalPodAutoscalers
- PodDisruptionBudget

The Helm chart additionally provides environment values, reusable templates,
rolling updates, autoscaling, disruption budgets, and ArgoCD-compatible
deployment packaging.

### Explanation

Kubernetes is the selected orchestration option from the PDF. The repository
supports two operational paths:

1. **Direct manifests:** apply the files under `part4-ha/k8s/`.
2. **Helm:** install or upgrade the chart under `part4-ha/helm/`.

The Makefile provides shortcuts for namespace creation, Helm installation,
upgrades, rollout status, ArgoCD application setup, and Minikube preparation.

The ArgoCD Application watches the `staging` branch and the
`part4-ha/helm` path. Automated sync, pruning, and self-healing are enabled.
However, the manifest currently contains the placeholder repository URL
`https://github.com/YOUR_USERNAME/YOUR_REPO.git`. It must be replaced with the
actual public repository URL before ArgoCD can synchronize the chart.

The image repositories in the default values also contain the placeholder
`your-dockerhub-username`. The deployment command or an environment-specific
values file must supply the actual published image repositories and immutable
tag before installation.

The repository contains a sample Kubernetes Secret with demonstration values.
Base64 encoding is not encryption. Production credentials must be supplied
through a secret manager, sealed secret, or protected cluster operation; real
credentials must not be committed to Git or included in screenshots.

### 📸 Screenshots

No Part 4 screenshot has been captured for this task yet.

The required evidence should be placed here:

```text
helm lint ./part4-ha/helm
helm template myapp ./part4-ha/helm --namespace devops-exam
kubectl apply -f part4-ha/k8s/
kubectl get all -n devops-exam
kubectl get ingress,hpa,pdb -n devops-exam
kubectl get application myapp -n argocd
```

### Screenshot Explanation

The Helm output should prove that the chart renders without template errors.
The Kubernetes resource listing should show the Deployments, Services, pods,
Ingress, HPAs, and PDBs in the expected namespace. The ArgoCD output should
show the actual synchronization state only after the repository URL and image
references have been configured.

The final evidence should include the exact image tag used for the run. Avoid
using only `latest` for a final proof because an immutable commit or release
tag makes the deployment reproducible and supports rollback.

---

## Troubleshooting Guide

### Pods remain Pending

```bash
kubectl describe pod <pod-name> -n devops-exam
kubectl get nodes -o wide
```

Check whether the cluster has enough CPU and memory and whether the topology
spread constraint can be satisfied. A single-node cluster cannot demonstrate
two-node placement.

### Pods are running but not Ready

```bash
kubectl describe pod <pod-name> -n devops-exam
kubectl logs <pod-name> -n devops-exam
kubectl get events -n devops-exam --sort-by=.lastTimestamp
```

Confirm that the configured image exposes the probe path and port. The Helm
API probe expects `/healthz` on port 8000; the UI probe expects `/` on port
3000.

### Ingress returns 404 or does not receive traffic

```bash
kubectl get ingress -n devops-exam
kubectl get pods -n ingress-nginx
kubectl describe ingress myapp-ingress -n devops-exam
```

Confirm that the nginx Ingress controller is installed, the Ingress class
matches `nginx`, and the hosts file points to the controller's reachable
address.

### HPA shows unknown metrics

```bash
kubectl get hpa -n devops-exam
kubectl top pods -n devops-exam
```

Install or enable metrics-server and ensure every workload has CPU resource
requests. The chart already defines CPU requests for both workloads.

### ArgoCD cannot sync

```bash
kubectl get application myapp -n argocd
argocd app get myapp
```

Replace the placeholder Git repository URL, confirm that the `staging` branch
contains `part4-ha/helm`, and check that the target cluster and namespace are
reachable by ArgoCD.

---

## Architecture Decisions and Trade-offs

| Decision | Reason | Trade-off |
|---|---|---|
| Kubernetes | Matches the PDF's recommended option and supplies built-in orchestration primitives | More setup and operational complexity than Docker Swarm |
| Helm | Packages reusable templates and environment-specific values | Rendering adds another layer to debug |
| ClusterIP Services | Keeps application pods internal and lets Ingress own external routing | Requires a working Ingress controller |
| Two baseline replicas | Meets the PDF minimum and supports pod-level failover | Two replicas do not guarantee two nodes unless the cluster has two nodes |
| HPA | Allows horizontal scaling based on resource usage | Requires metrics-server and meaningful resource requests |
| RollingUpdate with zero unavailable pods | Supports safer releases and reduced interruption | Needs enough capacity for the surge pod |
| Local hosts file | Simple and repeatable for an exam or local cluster | Not a production DNS solution |
| ArgoCD self-healing | Reconciles cluster drift from Git | Requires a real repository URL and an installed ArgoCD controller |

---

## Submission Status

### Completed in the repository

- Kubernetes was selected as the Part 4 orchestration option.
- Raw Kubernetes manifests are present under `part4-ha/k8s/`.
- A Helm chart is present under `part4-ha/helm/`.
- API and UI Deployments request two replicas.
- Services, Ingress, health probes, HPA, PDB, and rolling-update settings are
  configured.
- Domain names and local hosts-file instructions are documented.
- ArgoCD GitOps configuration is present.

### Still required for a complete evidence-backed submission

- Replace the ArgoCD repository URL placeholder.
- Replace Docker Hub image repository placeholders with the actual published
  images and an immutable tag.
- Run the chart or manifests on a real Kubernetes cluster.
- Capture node and pod placement evidence.
- Capture readiness, Service endpoints, Ingress, HPA, and PDB output.
- Perform and document a real pod-failure recovery test.
- Verify domain-based API and UI access.
- Capture screenshots directly under the task they prove.

The PDF explicitly accepts partial work, so this document preserves the
configuration that exists without claiming live HA behavior that has not yet
been observed.