#!/usr/bin/env bash
set -u

# Run this on the local WSL machine where the two-node Minikube cluster runs.
# It intentionally does not modify the cluster until --node-failure is used.

NAMESPACE="${NAMESPACE:-devops-exam}"
API_URL="${API_URL:-http://api.myapp.local/}"
IDENTITY_URL="${IDENTITY_URL:-http://api.myapp.local/instance}"
REQUESTS="${REQUESTS:-40}"
FAIL_NODE="${FAIL_NODE:-minikube-m02}"
EXPECTED_API_IMAGE="${EXPECTED_API_IMAGE:-}"
NODE_FAILURE=false
PREFLIGHT_ONLY=false

usage() {
  cat <<'EOF'
Usage:
  ./part4-ha/verify-runtime-evidence.sh
  ./part4-ha/verify-runtime-evidence.sh --preflight
  ./part4-ha/verify-runtime-evidence.sh --node-failure

Environment overrides:
  NAMESPACE=devops-exam
  API_URL=http://api.myapp.local/
  IDENTITY_URL=http://api.myapp.local/instance
  REQUESTS=40
  FAIL_NODE=minikube-m02
  EXPECTED_API_IMAGE=devops-api:part4-local

The default mode counts responses by the API instance name.
The --node-failure mode stops one Minikube node, checks domain availability,
prints node/pod/endpoint state, and starts the node again before exiting.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --node-failure) NODE_FAILURE=true ;;
    --preflight) PREFLIGHT_ONLY=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 2
  }
}

for command in kubectl curl python3; do
  require_command "$command"
done
if [[ "${NODE_FAILURE}" == true ]]; then
  require_command minikube
fi

echo "=== Part 4 runtime evidence ==="
date
echo "Namespace: ${NAMESPACE}"
echo "API URL: ${API_URL}"
echo "Identity URL: ${IDENTITY_URL}"
echo

preflight() {
  echo "--- Deployment readiness preflight ---"
  if ! kubectl rollout status deployment/api-app -n "${NAMESPACE}" --timeout=120s; then
    echo "Preflight failed: api-app rollout did not complete successfully." >&2
    exit 1
  fi

  pod_json="$(kubectl get pods -n "${NAMESPACE}" -l app=api-app -o json)"
  pod_rows="$(printf '%s' "${pod_json}" | python3 -c '
import json, sys
for item in json.load(sys.stdin)["items"]:
    status = item.get("status", {})
    containers = status.get("containerStatuses", [])
    ready = containers[0].get("ready", False) if containers else False
    image = item.get("spec", {}).get("containers", [{}])[0].get("image", "<none>")
    print(item["metadata"]["name"], status.get("podIP", "<none>"), image, str(ready).lower())
')"
  printf '%s\n' "${pod_rows}"

  ready_count="$(printf '%s\n' "${pod_rows}" | awk '$4 == "true" {count++} END {print count+0}')"
  if [[ "${ready_count}" -lt 2 ]]; then
    echo "Preflight failed: at least two Ready API pods are required." >&2
    exit 1
  fi
  if printf '%s\n' "${pod_rows}" | awk '$2 == "<none>" || $4 != "true" {failed=1} END {exit failed}'; then
    :
  else
    echo "Preflight failed: every API pod must have a pod IP and READY=true." >&2
    exit 1
  fi
  image_count="$(printf '%s\n' "${pod_rows}" | awk '!seen[$3]++ {count++} END {print count+0}')"
  if [[ "${image_count}" -ne 1 ]]; then
    echo "Preflight failed: API pods are using mixed images." >&2
    exit 1
  fi
  actual_image="$(printf '%s\n' "${pod_rows}" | awk 'NR == 1 {print $3}')"
  if [[ -n "${EXPECTED_API_IMAGE}" && "${actual_image}" != "${EXPECTED_API_IMAGE}" ]]; then
    echo "Preflight failed: API pods use ${actual_image}, expected ${EXPECTED_API_IMAGE}." >&2
    exit 1
  fi

  endpoint_json="$(kubectl get endpointslice -n "${NAMESPACE}" \
    -l kubernetes.io/service-name=api-service -o json)"
  endpoint_rows="$(printf '%s' "${endpoint_json}" | python3 -c '
import json, sys
for item in json.load(sys.stdin)["items"]:
    for endpoint in item.get("endpoints", []):
        if endpoint.get("conditions", {}).get("ready", True) is False:
            continue
        for address in endpoint.get("addresses", []):
            print(address)
')"
  echo "API EndpointSlice addresses:"
  printf '%s\n' "${endpoint_rows}"
  if [[ -z "${endpoint_rows}" ]]; then
    echo "Preflight failed: api-service has no EndpointSlice addresses." >&2
    exit 1
  fi
  while read -r pod_name pod_ip image ready; do
    if ! printf '%s\n' "${endpoint_rows}" | grep -Fxq "${pod_ip}"; then
      echo "Preflight failed: Ready pod ${pod_name} IP ${pod_ip} is not in the API EndpointSlice." >&2
      exit 1
    fi
  done < <(printf '%s\n' "${pod_rows}" | awk '$4 == "true"')
  if [[ "${ready_count}" -ne "$(printf '%s\n' "${endpoint_rows}" | sort -u | wc -l)" ]]; then
    echo "Preflight failed: EndpointSlice does not contain exactly one address per Ready API pod." >&2
    exit 1
  fi

  rewrite_target="$(kubectl get ingress app-ingress -n "${NAMESPACE}" \
    -o jsonpath='{.metadata.annotations.nginx\.ingress\.kubernetes\.io/rewrite-target}' 2>/dev/null || true)"
  if [[ -n "${rewrite_target}" ]]; then
    echo "Preflight failed: app-ingress still has rewrite-target=${rewrite_target}; /instance would be rewritten." >&2
    exit 1
  fi
  echo "Preflight passed: API rollout, replicas, image, endpoints, and Ingress path handling are ready."
}

preflight
if [[ "${PREFLIGHT_ONLY}" == true ]]; then
  exit 0
fi

echo "--- Nodes before test ---"
kubectl get nodes -o wide
echo

echo "--- Application pods and ready API endpoints ---"
kubectl get pods -n "${NAMESPACE}" -o wide
kubectl get endpointslice -n "${NAMESPACE}" \
  -l kubernetes.io/service-name=api-service \
  -o wide
echo

if [[ "${NODE_FAILURE}" != true ]]; then
  echo "--- Per-instance request distribution (${REQUESTS} requests) ---"
  declare -A counts=()
  successful=0
  for i in $(seq 1 "${REQUESTS}"); do
    response="$(curl -fsS --max-time 10 "${IDENTITY_URL}")" || {
      echo "request=${i} HTTP failure" >&2
      continue
    }
    instance="$(printf '%s' "${response}" | python3 -c \
      'import json, sys; print(json.load(sys.stdin)["instance"])')" || {
      echo "request=${i} missing instance in response: ${response}" >&2
      continue
    }
    counts["${instance}"]=$(( ${counts["${instance}"]:-0} + 1 ))
    successful=$((successful + 1))
    printf 'request=%02d instance=%s response=%s\n' "${i}" "${instance}" "${response}"
  done
  echo
  echo "Successful requests: ${successful}/${REQUESTS}"
  echo "Requests by instance:"
  for instance in "${!counts[@]}"; do
    printf '%s %s\n' "${instance}" "${counts[$instance]}"
  done | sort

  if [[ "${successful}" -lt "${REQUESTS}" || "${#counts[@]}" -lt 2 ]]; then
    echo "Distribution check failed: every request must succeed and both replicas must respond." >&2
    exit 1
  fi

  min_count=999999
  max_count=0
  for instance in "${!counts[@]}"; do
    count="${counts[$instance]}"
    (( count < min_count )) && min_count="${count}"
    (( count > max_count )) && max_count="${count}"
  done
  if (( max_count > min_count * 2 )); then
    echo "Distribution check failed: response ratio ${max_count}:${min_count} exceeds 2:1." >&2
    exit 1
  fi
  echo "Distribution check passed: both replicas responded and counts stayed within 2:1."
  echo
  echo "Distribution test complete. No node was stopped."
  exit 0
fi

echo
echo "--- Controlled node-failure availability test ---"
kubectl get node "${FAIL_NODE}" -o wide
echo "Stopping Minikube node: ${FAIL_NODE}"
minikube node stop "${FAIL_NODE}"

restore_node() {
  echo
  echo "Restoring Minikube node: ${FAIL_NODE}"
  minikube node start "${FAIL_NODE}" || true
}
trap restore_node EXIT

echo "Waiting for Kubernetes to observe the node state..."
sleep 45
echo "--- Node state while failure is simulated ---"
kubectl get nodes -o wide
echo
echo "--- Requests through the domain while one node is unavailable ---"
node_successful=0
for i in $(seq 1 20); do
  http_code="$(curl -sS -o /tmp/part4-node-failure-response.json \
    -w '%{http_code}' --max-time 10 "${API_URL}" || true)"
  printf 'request=%02d HTTP=%s\n' "${i}" "${http_code}"
  [[ "${http_code}" == "200" ]] && node_successful=$((node_successful + 1))
  sleep 1
done
echo "Successful node-failure requests: ${node_successful}/20"
echo
echo "--- Pods and endpoints during the node test ---"
kubectl get pods -n "${NAMESPACE}" -o wide
kubectl get endpointslice -n "${NAMESPACE}" \
  -l kubernetes.io/service-name=api-service \
  -o wide

if [[ "${node_successful}" -lt 15 ]]; then
  echo "Node-failure availability check did not reach 15/20 successful requests." >&2
  exit 1
fi

echo "Node-failure availability check passed: ${node_successful}/20 HTTP 200 responses."