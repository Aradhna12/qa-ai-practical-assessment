<#
.SYNOPSIS
  Generate JMeter HTML dashboard from a JTL results file.

.EXAMPLE
  .\jmeter\scripts\generate-html-report.ps1
  .\jmeter\scripts\generate-html-report.ps1 -JtlFile jmeter\reports\gui-results.jtl
#>

param(
  [string]$JtlFile = ""
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$JmeterHome = if ($env:JMETER_HOME) { $env:JMETER_HOME } else { "D:\Jmeter\apache-jmeter-5.6.3" }
$JmeterBin = Join-Path $JmeterHome "bin\jmeter.bat"
$ReportsDir = Join-Path $RepoRoot "jmeter\reports"
$HtmlReportDir = Join-Path $ReportsDir "html-report"

if ([string]::IsNullOrWhiteSpace($JtlFile)) {
  $cliJtl = Join-Path $ReportsDir "results.jtl"
  $guiJtl = Join-Path $ReportsDir "gui-results.jtl"
  if (Test-Path $cliJtl) { $JtlFile = $cliJtl }
  elseif (Test-Path $guiJtl) { $JtlFile = $guiJtl }
  else {
    Write-Host "No JTL file found. Run a test first (GUI or run-poc.ps1)." -ForegroundColor Red
    exit 1
  }
} else {
  $JtlFile = Resolve-Path $JtlFile
}

if (-not (Test-Path $JmeterBin)) {
  Write-Host "JMeter not found: $JmeterBin" -ForegroundColor Red
  exit 1
}

if (Test-Path $HtmlReportDir) { Remove-Item $HtmlReportDir -Recurse -Force }

Write-Host "Generating HTML report..." -ForegroundColor Cyan
Write-Host "  Source JTL : $JtlFile"
Write-Host "  Output dir : $HtmlReportDir"

& $JmeterBin -g $JtlFile -o $HtmlReportDir -j (Join-Path $ReportsDir "report-generator.log")

if ($LASTEXITCODE -ne 0) {
  Write-Host "Report generation failed." -ForegroundColor Red
  exit $LASTEXITCODE
}

$index = Join-Path $HtmlReportDir "index.html"
Write-Host "HTML report ready: $index" -ForegroundColor Green
Start-Process $index
