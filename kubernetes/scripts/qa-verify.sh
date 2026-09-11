#!/usr/bin/env bash
# BASIC Kubernetes QA verification script for the nginx-demo POC.
set -euo pipefail

NAMESPACE="qa-demo"
DEPLOYMENT="nginx-demo"
SERVICE="nginx-demo"
FAILED=0

pass() { echo "[PASS] $1"; }
fail() { echo "[FAIL] $1 :: ${2:-}"; FAILED=$((FAILED + 1)); }

echo
echo "=== BASIC K8s QA Verification ==="
echo

if ! kubectl get nodes >/dev/null 2>&1; then
  fail "Cluster reachable (kubectl get nodes)" "Cannot connect to cluster"
  echo
  echo "No live cluster. Install Docker Desktop (enable Kubernetes) or minikube, then re-run."
  exit 1
fi
pass "Cluster reachable (kubectl get nodes)"

if kubectl get ns "$NAMESPACE" >/dev/null 2>&1; then
  pass "Namespace '$NAMESPACE' exists"
else
  fail "Namespace '$NAMESPACE' exists"
fi

AVAIL=$(kubectl get deploy "$DEPLOYMENT" -n "$NAMESPACE" -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)
if [[ "${AVAIL:-0}" =~ ^[1-9][0-9]*$ ]]; then
  pass "Deployment '$DEPLOYMENT' has available replicas"
else
  fail "Deployment '$DEPLOYMENT' has available replicas" "availableReplicas=${AVAIL:-none}"
fi

DESIRED=$(kubectl get deploy "$DEPLOYMENT" -n "$NAMESPACE" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo 0)
READY=$(kubectl get deploy "$DEPLOYMENT" -n "$NAMESPACE" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo 0)
if [[ "$READY" == "$DESIRED" && -n "$READY" ]]; then
  pass "Ready replicas match desired ($READY/$DESIRED)"
else
  fail "Ready replicas match desired" "ready=$READY desired=$DESIRED"
fi

NOT_RUNNING=$(kubectl get pods -n "$NAMESPACE" -l "app=$DEPLOYMENT" --field-selector=status.phase!=Running -o name 2>/dev/null || true)
if [[ -z "${NOT_RUNNING}" ]]; then
  pass "All nginx-demo pods are Running"
else
  fail "All nginx-demo pods are Running" "$NOT_RUNNING"
fi

if kubectl get svc "$SERVICE" -n "$NAMESPACE" >/dev/null 2>&1; then
  pass "Service '$SERVICE' exists"
else
  fail "Service '$SERVICE' exists"
fi

EP=$(kubectl get endpoints "$SERVICE" -n "$NAMESPACE" -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null || true)
if [[ -n "${EP}" ]]; then
  pass "Service has endpoints"
else
  fail "Service has endpoints" "No endpoint IPs"
fi

if kubectl rollout status "deploy/$DEPLOYMENT" -n "$NAMESPACE" --timeout=60s; then
  pass "Rollout status successful"
else
  fail "Rollout status successful"
fi

POD=$(kubectl get pods -n "$NAMESPACE" -l "app=$DEPLOYMENT" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
if [[ -n "${POD}" ]] && kubectl logs "$POD" -n "$NAMESPACE" --tail=20 >/dev/null; then
  pass "Pod logs readable ($POD)"
else
  fail "Pod logs readable" "No pod or logs unavailable"
fi

echo
if [[ "$FAILED" -eq 0 ]]; then
  echo "QA RESULT: ALL CHECKS PASSED"
  exit 0
fi
echo "QA RESULT: $FAILED CHECK(S) FAILED"
exit 1
