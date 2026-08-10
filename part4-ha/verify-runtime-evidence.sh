#!/usr/bin/env bash
set -u

# Run this on the local WSL machine where the two-node Minikube cluster runs.
# It intentionally does not modify the cluster until --node-failure is used.

NAMESPACE="${NAMESPACE:-devops-exam}"
API_URL="${API_URL:-http://api.myapp.local/}"
IDENTITY_URL="${IDENTITY_URL:-http://api.myapp.local/instance}"
REQUESTS="${REQUESTS:-40}"
FAIL_NODE="${FAIL_NODE:-minikube-m02}"
NODE_FAILURE=false

usage() {
  cat <<'EOF'
Usage:
  ./part4-ha/verify-runtime-evidence.sh
  ./part4-ha/verify-runtime-evidence.sh --node-failure

Environment overrides:
  NAMESPACE=devops-exam
  API_URL=http://api.myapp.local/
  IDENTITY_URL=http://api.myapp.local/instance
  REQUESTS=40
  FAIL_NODE=minikube-m02

The default mode counts responses by the API instance name.
The --node-failure mode stops one Minikube node, checks domain availability,
prints node/pod/endpoint state, and starts the node again before exiting.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --node-failure) NODE_FAILURE=true ;;
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