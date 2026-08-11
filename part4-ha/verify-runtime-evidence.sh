#!/usr/bin/env bash
set -u

NAMESPACE="${NAMESPACE:-devops-exam}"
API_URL="${API_URL:-http://api.myapp.local/}"
IDENTITY_URL="${IDENTITY_URL:-http://api.myapp.local/instance}"
REQUESTS="${REQUESTS:-40}"
FAIL_NODE="${FAIL_NODE:-minikube-m02}"
EXPECTED_API_IMAGE="${EXPECTED_API_IMAGE:-}"
PREFLIGHT_ONLY=false
NODE_FAILURE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --preflight) PREFLIGHT_ONLY=true ;;
    --node-failure) NODE_FAILURE=true ;;
    -h|--help)
      echo "Usage: ./part4-ha/verify-runtime-evidence.sh [--preflight|--node-failure]"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 2
      ;;
  esac
  shift
done

for command in kubectl curl python3; do
  command -v "$command" >/dev/null 2>&1 || {
    echo "Missing command: $command" >&2
    exit 2
  }
done

if [[ "$NODE_FAILURE" == true ]]; then
  command -v minikube >/dev/null 2>&1 || {
    echo "Missing command: minikube" >&2
    exit 2
  }
fi

echo "=== Part 4 runtime evidence ==="
date
echo "Namespace: $NAMESPACE"
echo "Identity URL: $IDENTITY_URL"
echo

echo "--- Deployment readiness preflight ---"

kubectl rollout status deployment/api-app \
  -n "$NAMESPACE" --timeout=120s

PODS="$(kubectl get pods -n "$NAMESPACE" -l app=api-app \
  -o custom-columns='NAME:.metadata.name,IP:.status.podIP,IMAGE:.spec.containers[0].image,READY:.status.containerStatuses[0].ready' \
  --no-headers)"

printf '%s\n' "$PODS"

READY_COUNT="$(printf '%s\n' "$PODS" | awk '$4=="true"{n++} END{print n+0}')"

if [[ "$READY_COUNT" -lt 2 ]]; then
  echo "Preflight failed: fewer than two Ready API pods." >&2
  exit 1
fi

if printf '%s\n' "$PODS" | awk '$2=="<none>" || $4!="true"{bad=1} END{exit bad}'; then
  :
else
  echo "Preflight failed: an API pod is not Ready or has no IP." >&2
  exit 1
fi

IMAGE_COUNT="$(printf '%s\n' "$PODS" | awk '!seen[$3]++{n++} END{print n+0}')"

if [[ "$IMAGE_COUNT" -ne 1 ]]; then
  echo "Preflight failed: API pods use mixed images." >&2
  exit 1
fi

ACTUAL_IMAGE="$(printf '%s\n' "$PODS" | awk 'NR==1{print $3}')"

if [[ -n "$EXPECTED_API_IMAGE" && "$ACTUAL_IMAGE" != "$EXPECTED_API_IMAGE" ]]; then
  echo "Preflight failed: expected $EXPECTED_API_IMAGE but found $ACTUAL_IMAGE." >&2
  exit 1
fi

ENDPOINTS="$(kubectl get endpointslice -n "$NAMESPACE" \
  -l kubernetes.io/service-name=api-service -o wide)"

echo "--- API endpoints ---"
printf '%s\n' "$ENDPOINTS"

if ! printf '%s\n' "$ENDPOINTS" | grep -Eq '([0-9]{1,3}\.){3}[0-9]{1,3}'; then
  echo "Preflight failed: api-service has no endpoint IP." >&2
  exit 1
fi

REWRITE="$(kubectl get ingress app-ingress -n "$NAMESPACE" \
  -o jsonpath='{.metadata.annotations.nginx\.ingress\.kubernetes\.io/rewrite-target}' \
  2>/dev/null || true)"

if [[ -n "$REWRITE" ]]; then
  echo "Preflight failed: Ingress still has rewrite-target=$REWRITE." >&2
  exit 1
fi

IDENTITY_RESPONSE="$(curl -fsS --max-time 10 "$IDENTITY_URL")" || {
  echo "Preflight failed: $IDENTITY_URL returned non-200." >&2
  exit 1
}

INSTANCE="$(printf '%s' "$IDENTITY_RESPONSE" | python3 -c \
  'import json,sys; print(json.load(sys.stdin)["instance"])')" || {
  echo "Preflight failed: response has no instance field." >&2
  exit 1
}

echo "Identity endpoint passed: $INSTANCE"
echo "Preflight passed: API rollout, replicas, image, endpoints, Ingress, and /instance are ready."

if [[ "$PREFLIGHT_ONLY" == true ]]; then
  exit 0
fi

if [[ "$NODE_FAILURE" != true ]]; then
  echo
  echo "=== Per-replica distribution test ==="

  declare -A COUNTS
  SUCCESSFUL=0

  for i in $(seq 1 "$REQUESTS"); do
    RESPONSE="$(curl -fsS --max-time 10 "$IDENTITY_URL")" || {
      echo "request=$i HTTP failure" >&2
      continue
    }

    INSTANCE="$(printf '%s' "$RESPONSE" | python3 -c \
      'import json,sys; print(json.load(sys.stdin)["instance"])')" || continue

    COUNTS["$INSTANCE"]=$(( ${COUNTS["$INSTANCE"]:-0} + 1 ))
    SUCCESSFUL=$((SUCCESSFUL + 1))

    printf 'request=%02d instance=%s response=%s\n' \
      "$i" "$INSTANCE" "$RESPONSE"
  done

  echo
  echo "Successful requests: $SUCCESSFUL/$REQUESTS"
  echo "Requests by instance:"

  for INSTANCE in "${!COUNTS[@]}"; do
    printf '%s %s\n' "$INSTANCE" "${COUNTS[$INSTANCE]}"
  done | sort

  if [[ "$SUCCESSFUL" -lt "$REQUESTS" || "${#COUNTS[@]}" -lt 2 ]]; then
    echo "Distribution check failed" >&2
    exit 1
  fi

  MIN=999999
  MAX=0

  for INSTANCE in "${!COUNTS[@]}"; do
    COUNT="${COUNTS[$INSTANCE]}"
    (( COUNT < MIN )) && MIN="$COUNT"
    (( COUNT > MAX )) && MAX="$COUNT"
  done

  if (( MAX > MIN * 2 )); then
    echo "Distribution check failed: ratio ${MAX}:${MIN} exceeds 2:1." >&2
    exit 1
  fi

  echo "Distribution check passed"
  exit 0
fi

echo
echo "=== Controlled node-failure availability test ==="

kubectl get node "$FAIL_NODE" -o wide

restore_node() {
  echo "Restoring Minikube node: $FAIL_NODE"
  minikube node start "$FAIL_NODE" || true
}

trap restore_node EXIT

echo "Stopping Minikube node: $FAIL_NODE"
minikube node stop "$FAIL_NODE"

sleep 45

kubectl get nodes -o wide

SUCCESSFUL=0

for i in $(seq 1 20); do
  CODE="$(curl -sS -o /dev/null -w '%{http_code}' \
    --max-time 10 "$API_URL" || true)"

  printf 'request=%02d HTTP=%s\n' "$i" "$CODE"

  [[ "$CODE" == "200" ]] && SUCCESSFUL=$((SUCCESSFUL + 1))
  sleep 1
done

echo "Successful node-failure requests: $SUCCESSFUL/20"

if [[ "$SUCCESSFUL" -lt 15 ]]; then
  echo "Node-failure availability check failed" >&2
  exit 1
fi

echo "Node-failure availability check passed"
