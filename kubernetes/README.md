# Kubernetes QA POC (Basic)

Basic-level Kubernetes verification for Quality Engineers using **kubectl**, YAML manifests, and a pass/fail QA script.

## Quick links

| Item | Location |
|---|---|
| Full POC write-up | [BASIC-KUBERNETES-QA-POC.md](./BASIC-KUBERNETES-QA-POC.md) |
| Screenshots index | [SCREENSHOTS.md](./SCREENSHOTS.md) |
| Visual guide | [docs/visual-guide.html](./docs/visual-guide.html) |
| Manifests | [manifests/](./manifests/) |
| QA scripts | [scripts/](./scripts/) |

## What this covers

- Cluster connectivity (`kubectl get nodes`)
- Namespace + Deployment + Service
- Pod Ready / Running checks
- Service endpoints
- Describe + logs
- Scale + rollout status
- Negative test (bad image → ImagePullBackOff)
- Automated QA verification script

## Run (with live cluster)

```powershell
kubectl apply -f kubernetes/manifests/namespace.yaml
kubectl apply -f kubernetes/manifests/deployment.yaml
kubectl apply -f kubernetes/manifests/service.yaml
.\kubernetes\scripts\qa-verify.ps1
```

## Generate screenshots

```powershell
npm run k8s:screenshots
```

## Cleanup

```powershell
kubectl delete -f kubernetes/manifests/ --ignore-not-found
```
