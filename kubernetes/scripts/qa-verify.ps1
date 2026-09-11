<#
.SYNOPSIS
  BASIC Kubernetes QA verification script for the nginx-demo POC.

.DESCRIPTION
  Runs common QA checks a Quality Engineer would perform after deploy:
  - cluster connectivity
  - namespace exists
  - deployment ready
  - pods Running / Ready
  - service endpoints
  - rollout status
  - basic log smoke check

.EXAMPLE
  .\kubernetes\scripts\qa-verify.ps1
#>

$ErrorActionPreference = "Stop"
$Namespace = "qa-demo"
$Deployment = "nginx-demo"
$Service = "nginx-demo"
$Failed = 0

function Write-Check([string]$Name, [bool]$Pass, [string]$Detail = "") {
  if ($Pass) {
    Write-Host "[PASS] $Name" -ForegroundColor Green
  } else {
    Write-Host "[FAIL] $Name :: $Detail" -ForegroundColor Red
    $script:Failed++
  }
}

Write-Host "`n=== BASIC K8s QA Verification ===`n" -ForegroundColor Cyan

# 1. Cluster connectivity
try {
  $nodes = kubectl get nodes -o json 2>$null | ConvertFrom-Json
  $readyNodes = @($nodes.items | Where-Object {
    ($_.status.conditions | Where-Object { $_.type -eq "Ready" -and $_.status -eq "True" })
  })
  Write-Check "Cluster reachable (kubectl get nodes)" ($readyNodes.Count -ge 1) "No Ready nodes"
} catch {
  Write-Check "Cluster reachable (kubectl get nodes)" $false $_.Exception.Message
  Write-Host "`nNo live cluster. Install Docker Desktop (enable Kubernetes) or minikube, then re-run.`n" -ForegroundColor Yellow
  exit 1
}

# 2. Namespace
$ns = kubectl get ns $Namespace -o name 2>$null
Write-Check "Namespace '$Namespace' exists" ($LASTEXITCODE -eq 0 -and $ns)

# 3. Deployment available replicas
$avail = kubectl get deploy $Deployment -n $Namespace -o jsonpath="{.status.availableReplicas}" 2>$null
Write-Check "Deployment '$Deployment' has available replicas" ($avail -as [int] -ge 1) "availableReplicas=$avail"

# 4. Desired vs ready replicas
$desired = kubectl get deploy $Deployment -n $Namespace -o jsonpath="{.spec.replicas}" 2>$null
$ready = kubectl get deploy $Deployment -n $Namespace -o jsonpath="{.status.readyReplicas}" 2>$null
Write-Check "Ready replicas match desired ($ready/$desired)" (($ready -as [int]) -eq ($desired -as [int])) "ready=$ready desired=$desired"

# 5. Pods Running
$notRunning = kubectl get pods -n $Namespace -l app=$Deployment --field-selector=status.phase!=Running -o name 2>$null
Write-Check "All nginx-demo pods are Running" ([string]::IsNullOrWhiteSpace($notRunning)) $notRunning

# 6. Service exists
$svc = kubectl get svc $Service -n $Namespace -o name 2>$null
Write-Check "Service '$Service' exists" ($LASTEXITCODE -eq 0 -and $svc)

# 7. Endpoints populated
$ep = kubectl get endpoints $Service -n $Namespace -o jsonpath="{.subsets[*].addresses[*].ip}" 2>$null
Write-Check "Service has endpoints" (-not [string]::IsNullOrWhiteSpace($ep)) "No endpoint IPs"

# 8. Rollout status
kubectl rollout status deploy/$Deployment -n $Namespace --timeout=60s | Out-Host
Write-Check "Rollout status successful" ($LASTEXITCODE -eq 0)

# 9. Logs smoke (first pod)
$pod = kubectl get pods -n $Namespace -l app=$Deployment -o jsonpath="{.items[0].metadata.name}" 2>$null
if ($pod) {
  $logs = kubectl logs $pod -n $Namespace --tail=20 2>$null
  Write-Check "Pod logs readable ($pod)" ($LASTEXITCODE -eq 0)
} else {
  Write-Check "Pod logs readable" $false "No pod found"
}

Write-Host ""
if ($Failed -eq 0) {
  Write-Host "QA RESULT: ALL CHECKS PASSED" -ForegroundColor Green
  exit 0
} else {
  Write-Host "QA RESULT: $Failed CHECK(S) FAILED" -ForegroundColor Red
  exit 1
}
