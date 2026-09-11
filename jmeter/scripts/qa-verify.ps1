<#
.SYNOPSIS
  Verify JMeter installation and POC run results.

.EXAMPLE
  .\jmeter\scripts\qa-verify.ps1
#>

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$JmeterHome = if ($env:JMETER_HOME) { $env:JMETER_HOME } else { "D:\Jmeter\apache-jmeter-5.6.3" }
$JmeterBin = Join-Path $JmeterHome "bin\jmeter.bat"
$TestPlan = Join-Path $RepoRoot "jmeter\test-plans\ReqRes-API-Load-POC.jmx"
$ResultsJtl = Join-Path $RepoRoot "jmeter\reports\results.jtl"
$HtmlIndex = Join-Path $RepoRoot "jmeter\reports\html-report\index.html"
$VersionFile = Join-Path $RepoRoot "jmeter\docs\jmeter-version.txt"
$Failed = 0

function Write-Check([string]$Name, [bool]$Pass, [string]$Detail = "") {
  if ($Pass) {
    Write-Host "[PASS] $Name" -ForegroundColor Green
  } else {
    Write-Host "[FAIL] $Name :: $Detail" -ForegroundColor Red
    $script:Failed++
  }
}

Write-Host ""
Write-Host "=== JMeter QA Verification ===" -ForegroundColor Cyan
Write-Host ""

Write-Check "JMeter binary exists" (Test-Path $JmeterBin) $JmeterBin

if (Test-Path $JmeterBin) {
  $versionOutput = & $JmeterBin -v 2>&1 | Out-String
  New-Item -ItemType Directory -Force -Path (Split-Path $VersionFile) | Out-Null
  $versionOutput | Set-Content -Path $VersionFile -Encoding UTF8
  $hasVersion = $versionOutput -match "5\.6\.3"
  Write-Check "JMeter version 5.6.3 detected" $hasVersion "See $VersionFile"
}

Write-Check "Test plan exists" (Test-Path $TestPlan) $TestPlan
Write-Check "CSV data file exists" (Test-Path (Join-Path $RepoRoot "jmeter\data\create-users.csv"))

if (-not (Test-Path $ResultsJtl)) {
  Write-Host ""
  Write-Host "No results yet - running JMeter POC first..." -ForegroundColor Yellow
  Write-Host ""
  & (Join-Path $PSScriptRoot "run-poc.ps1")
}

Write-Check "Results JTL generated" (Test-Path $ResultsJtl) $ResultsJtl
Write-Check "HTML dashboard generated" (Test-Path $HtmlIndex) $HtmlIndex

if (Test-Path $ResultsJtl) {
  $lines = Get-Content $ResultsJtl | Where-Object { $_ -notmatch '^#' -and $_.Trim() -ne '' }
  $sampleCount = ($lines | Measure-Object).Count
  $rowMsg = "Sample results captured ($sampleCount row(s))"
  Write-Check $rowMsg ($sampleCount -gt 0)

  $failureCount = 0
  foreach ($line in $lines) {
    if ($line -match ',false,') {
      $label = ($line -split ',')[2]
      if ($label -notmatch 'Negative 404') {
        $failureCount++
      }
    }
  }
  $failMsg = "$failureCount failed sample(s)"
  Write-Check "All functional samples successful" ($failureCount -eq 0) $failMsg
}

Write-Host ""
if ($Failed -eq 0) {
  Write-Host "ALL CHECKS PASSED" -ForegroundColor Green
  exit 0
}

Write-Host "$Failed CHECK(S) FAILED" -ForegroundColor Red
exit 1
