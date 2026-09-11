<#
.SYNOPSIS
  Open Apache JMeter GUI with the ReqRes POC test plan on this PC.

.EXAMPLE
  .\jmeter\scripts\open-jmeter-gui.ps1
#>

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$JmeterHome = if ($env:JMETER_HOME) { $env:JMETER_HOME } else { "D:\Jmeter\apache-jmeter-5.6.3" }
$JmeterBat = Join-Path $JmeterHome "bin\jmeter.bat"
$TestPlan = Join-Path $RepoRoot "jmeter\test-plans\ReqRes-API-Load-POC.jmx"

if (-not (Test-Path $JmeterBat)) {
  Write-Host "JMeter not found: $JmeterBat" -ForegroundColor Red
  Write-Host "Install JMeter or set JMETER_HOME, then try again." -ForegroundColor Yellow
  exit 1
}

if (-not (Test-Path $TestPlan)) {
  Write-Host "Test plan not found: $TestPlan" -ForegroundColor Red
  exit 1
}

Write-Host "Opening JMeter GUI..." -ForegroundColor Cyan
Write-Host "  JMeter   : $JmeterBat"
Write-Host "  Test plan: $TestPlan"
Write-Host ""
Write-Host "In JMeter: click the green Start button (Ctrl+R) to run the test." -ForegroundColor Green

Start-Process -FilePath $JmeterBat -ArgumentList @("-t", $TestPlan, "-Juser.dir=$RepoRoot") -WorkingDirectory (Join-Path $JmeterHome "bin")
