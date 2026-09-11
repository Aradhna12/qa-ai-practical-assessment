<#
.SYNOPSIS
  Run the ReqRes JMeter POC in non-GUI mode (real Apache JMeter).

.EXAMPLE
  .\jmeter\scripts\run-poc.ps1
#>

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$JmeterHome = if ($env:JMETER_HOME) { $env:JMETER_HOME } else { "D:\Jmeter\apache-jmeter-5.6.3" }
$JmeterBin = Join-Path $JmeterHome "bin\jmeter.bat"
$TestPlan = Join-Path $RepoRoot "jmeter\test-plans\ReqRes-API-Load-POC.jmx"
$ReportsDir = Join-Path $RepoRoot "jmeter\reports"
$ResultsJtl = Join-Path $ReportsDir "results.jtl"
$HtmlReportDir = Join-Path $ReportsDir "html-report"
$JmeterLog = Join-Path $ReportsDir "jmeter-run.log"

if (-not (Test-Path $JmeterBin)) {
  Write-Host "JMeter not found at: $JmeterBin" -ForegroundColor Red
  Write-Host "Set JMETER_HOME or install JMeter, then re-run." -ForegroundColor Yellow
  exit 1
}

if (-not (Test-Path $TestPlan)) {
  Write-Host "Test plan not found: $TestPlan" -ForegroundColor Red
  exit 1
}

New-Item -ItemType Directory -Force -Path $ReportsDir | Out-Null
if (Test-Path $ResultsJtl) { Remove-Item $ResultsJtl -Force }
if (Test-Path $HtmlReportDir) { Remove-Item $HtmlReportDir -Recurse -Force }

function Wait-ForApiReady {
  param([string]$Url, [int]$MaxWaitSeconds = 180)
  $elapsed = 0
  $delay = 10
  while ($elapsed -lt $MaxWaitSeconds) {
    try {
      $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 15
      if ($response.StatusCode -eq 200) {
        Write-Host "API ready (HTTP 200) after ${elapsed}s wait." -ForegroundColor Green
        return $true
      }
    } catch {
      $status = $_.Exception.Response.StatusCode.value__
      Write-Host "API not ready (HTTP $status). Waiting ${delay}s..." -ForegroundColor Yellow
    }
    Start-Sleep -Seconds $delay
    $elapsed += $delay
    if ($delay -lt 30) { $delay += 5 }
  }
  return $false
}

Write-Host "`n=== JMeter POC Run (non-GUI) ===" -ForegroundColor Cyan
Write-Host "Checking ReqRes API availability..."
if (-not (Wait-ForApiReady "https://reqres.in/api/users?page=1")) {
  Write-Host "ReqRes API still rate-limited. Continuing JMeter run anyway (expect 429 errors)." -ForegroundColor Yellow
}
Write-Host "JMETER_HOME : $JmeterHome"
Write-Host "Test plan   : $TestPlan"
Write-Host "Results     : $ResultsJtl"
Write-Host "HTML report : $HtmlReportDir`n"

& $JmeterBin -n `
  -t $TestPlan `
  -l $ResultsJtl `
  -j $JmeterLog `
  -e -o $HtmlReportDir `
  -Juser.dir=$RepoRoot

if ($LASTEXITCODE -ne 0) {
  Write-Host "`nJMeter run failed (exit $LASTEXITCODE). See $JmeterLog" -ForegroundColor Red
  exit $LASTEXITCODE
}

Write-Host "`nJMeter run completed successfully." -ForegroundColor Green
$indexHtml = Join-Path $HtmlReportDir "index.html"
Write-Host "HTML report: $indexHtml`n"
if (Test-Path $indexHtml) {
  Start-Process $indexHtml
}
