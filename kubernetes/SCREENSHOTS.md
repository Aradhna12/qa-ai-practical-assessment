# Kubernetes QA POC — Screenshots

Visual evidence for the BASIC Kubernetes QA POC.

## Generate screenshots

```powershell
npm install
npm run k8s:screenshots
```

This captures section screenshots from `kubernetes/docs/visual-guide.html` into `kubernetes/screenshots/` using Playwright.

## Screenshot index

| File | Description |
|---|---|
| `00-full-visual-guide.png` | Full overview of the K8s QA POC |
| `01-cluster-nodes.png` | Cluster connectivity / node Ready |
| `02-namespace-apply.png` | Apply namespace + manifests |
| `03-pods-ready.png` | Pods Running and Ready |
| `04-deployment-service.png` | Deployment, Service, endpoints |
| `05-describe-logs.png` | Describe events + logs smoke |
| `06-scale-rollout.png` | Scale replicas + rollout status |
| `07-negative-test.png` | Bad image negative test |
| `08-qa-script-result.png` | Automated QA script ALL PASSED |
| `09-cleanup.png` | Cleanup commands |

## Live cluster screenshots (optional upgrade)

When Docker Desktop Kubernetes (or minikube/kind) is running:

1. Deploy manifests
2. Run the commands from `BASIC-KUBERNETES-QA-POC.md`
3. Capture terminal windows into `kubernetes/screenshots/live/`

Suggested live captures:

- `live/01-kubectl-get-nodes.png`
- `live/02-kubectl-get-pods.png`
- `live/03-qa-verify-pass.png`
- `live/04-imagepullbackoff.png`
