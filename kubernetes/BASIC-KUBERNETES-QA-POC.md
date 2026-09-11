# BASIC Kubernetes QA POC

**Role:** Quality Engineer  
**Level:** Basic  
**Tooling:** kubectl + Kubernetes manifests + QA verification script  
**Sample app:** nginx (`nginx:1.27-alpine`) in namespace `qa-demo`  
**Date:** September 2026  
**Document path:** `kubernetes/BASIC-KUBERNETES-QA-POC.md`

---

## 1. POC Objective

Build and showcase a **basic-level Kubernetes QA** proof-of-concept that a Quality Engineer can use to:

1. Validate cluster connectivity
2. Deploy a simple application with manifests
3. Verify pods, deployment, and service health
4. Inspect describe/events and logs
5. Scale and confirm rollout
6. Demonstrate a **negative** failure (bad image)
7. Run a repeatable QA verification script
8. Present evidence with **screenshots**

This POC focuses on day-1 Kubernetes QA skills — not Helm, operators, or advanced networking.

---

## 2. What We Delivered

| Deliverable | Status | Path / details |
|---|---|---|
| Namespace manifest | Done | `kubernetes/manifests/namespace.yaml` |
| Deployment manifest | Done | `kubernetes/manifests/deployment.yaml` |
| Service manifest | Done | `kubernetes/manifests/service.yaml` |
| Negative test manifest | Done | `kubernetes/manifests/negative-bad-image.yaml` |
| QA verify script (PowerShell) | Done | `kubernetes/scripts/qa-verify.ps1` |
| QA verify script (Bash) | Done | `kubernetes/scripts/qa-verify.sh` |
| Visual guide (for screenshots) | Done | `kubernetes/docs/visual-guide.html` |
| Screenshot set | Done | `kubernetes/screenshots/` |
| POC write-up | Done | This document |
| README | Done | `kubernetes/README.md` |

---

## 3. Folder Structure

```
kubernetes/
├── BASIC-KUBERNETES-QA-POC.md      ← this document
├── README.md
├── SCREENSHOTS.md
├── docs/
│   └── visual-guide.html
├── manifests/
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── negative-bad-image.yaml
├── scripts/
│   ├── qa-verify.ps1
│   └── qa-verify.sh
└── screenshots/
    ├── 00-full-visual-guide.png
    ├── 01-cluster-nodes.png
    ├── 02-namespace-apply.png
    ├── 03-pods-ready.png
    ├── 04-deployment-service.png
    ├── 05-describe-logs.png
    ├── 06-scale-rollout.png
    ├── 07-negative-test.png
    ├── 08-qa-script-result.png
    └── 09-cleanup.png
```

---

## 4. QA Concepts Covered (Basic)

| QA concept | How this POC shows it |
|---|---|
| Cluster smoke check | `kubectl get nodes` → node Ready |
| Environment isolation | Dedicated `qa-demo` namespace |
| Deploy verification | Apply Deployment + Service |
| Functional readiness | Pods `Running`, Ready `1/1` |
| Service health | Endpoints populated |
| Observability | `describe` events + `logs` |
| Change validation | Scale replicas + `rollout status` |
| Negative testing | Bad image → ErrImagePull / ImagePullBackOff |
| Automated gate | `qa-verify.ps1` / `.sh` pass/fail checks |
| Evidence | Screenshot pack for assessment/demo |

---

## 5. Prerequisites

1. **kubectl** installed (already available on this machine: client v1.37.x)
2. A local Kubernetes cluster, one of:
   - Docker Desktop → Settings → Kubernetes → **Enable Kubernetes**
   - OR minikube / kind
3. Confirm:

```powershell
kubectl version --client
kubectl get nodes
```

> If `kubectl get nodes` fails, enable Docker Desktop Kubernetes (approve UAC if prompted), wait until it is green, then retry.

---

## 6. How to Run the POC (Live Cluster)

### Step 1 — Deploy happy path

```powershell
kubectl apply -f kubernetes/manifests/namespace.yaml
kubectl apply -f kubernetes/manifests/deployment.yaml
kubectl apply -f kubernetes/manifests/service.yaml
kubectl get pods,deploy,svc -n qa-demo
```

### Step 2 — QA checks manually

```powershell
kubectl get pods -n qa-demo -o wide
kubectl describe deploy nginx-demo -n qa-demo
kubectl logs -n qa-demo -l app=nginx-demo --tail=20
kubectl get endpoints nginx-demo -n qa-demo
```

### Step 3 — Scale & rollout

```powershell
kubectl scale deploy/nginx-demo -n qa-demo --replicas=3
kubectl rollout status deploy/nginx-demo -n qa-demo
```

### Step 4 — Negative test

```powershell
kubectl apply -f kubernetes/manifests/negative-bad-image.yaml
kubectl get pods -n qa-demo -l app=bad-image-demo
kubectl describe pod -n qa-demo -l app=bad-image-demo
```

Expected: `ErrImagePull` or `ImagePullBackOff`.

### Step 5 — Automated QA script

```powershell
.\kubernetes\scripts\qa-verify.ps1
```

### Step 6 — Cleanup

```powershell
kubectl delete -f kubernetes/manifests/negative-bad-image.yaml --ignore-not-found
kubectl delete -f kubernetes/manifests/ --ignore-not-found
```

---

## 7. Screenshot Index (Demo Evidence)

Generate / refresh screenshots:

```powershell
npm run k8s:screenshots
```

| File | What it shows |
|---|---|
| `00-full-visual-guide.png` | Full POC overview |
| `01-cluster-nodes.png` | Node Ready / cluster connectivity |
| `02-namespace-apply.png` | Apply namespace + manifests |
| `03-pods-ready.png` | Pods Running / Ready checks |
| `04-deployment-service.png` | Deployment + Service + endpoints |
| `05-describe-logs.png` | Describe events + logs |
| `06-scale-rollout.png` | Scale and rollout success |
| `07-negative-test.png` | Bad image failure detection |
| `08-qa-script-result.png` | Automated QA script ALL PASSED |
| `09-cleanup.png` | Resource cleanup |

See `kubernetes/SCREENSHOTS.md` for details.

---

## 8. Expected Demo Flow (5–7 minutes)

1. Open `kubernetes/BASIC-KUBERNETES-QA-POC.md`
2. Show manifests under `kubernetes/manifests/`
3. Show screenshots `01` → `08`
4. (Optional live) run apply + `qa-verify.ps1`
5. Show negative pod failure screenshot / live `ErrImagePull`
6. Cleanup

---

## 9. Scope Boundaries (Basic)

### In scope
- kubectl resource verification
- Deploy / Service / Pod readiness
- Logs + describe
- Scale / rollout
- One negative case
- Screenshot evidence + QA script

### Out of scope
- Helm / Kustomize advanced overlays
- Ingress / TLS / service mesh
- NetworkPolicy deep testing
- Chaos engineering
- Multi-cluster / GitOps (Argo CD)

---

## 10. Conclusion

This BASIC Kubernetes QA POC demonstrates that a Quality Engineer can:

- Validate a cluster is healthy before testing
- Deploy and verify an application with kubectl
- Assert pod/service readiness like a QA gate
- Debug with describe/logs
- Prove failure detection with a negative case
- Automate checks with a simple verification script
- Present clear screenshot evidence

**POC status: Complete and ready for showcase.**
