<#
.SYNOPSIS
  Install ReqRes JMeter POC into local Apache JMeter (PC install folder).

.EXAMPLE
  .\jmeter\scripts\install-to-pc-jmeter.ps1
#>

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$JmeterHome = if ($env:JMETER_HOME) { $env:JMETER_HOME } else { "D:\Jmeter\apache-jmeter-5.6.3" }
$JmeterBin = Join-Path $JmeterHome "bin\jmeter.bat"
$PocRoot = Join-Path $JmeterHome "qa-poc"
$SourceJmx = Join-Path $RepoRoot "jmeter\test-plans\ReqRes-API-Load-POC.jmx"
$SourceCsv = Join-Path $RepoRoot "jmeter\data\create-users.csv"
$SourceSmoke = Join-Path $RepoRoot "jmeter\test-plans\ReqRes-Smoke-Check.jmx"

if (-not (Test-Path $JmeterBin)) {
  Write-Host "JMeter not found: $JmeterBin" -ForegroundColor Red
  exit 1
}

$dirs = @(
  $PocRoot,
  (Join-Path $PocRoot "test-plans"),
  (Join-Path $PocRoot "data"),
  (Join-Path $PocRoot "reports")
)
foreach ($d in $dirs) {
  New-Item -ItemType Directory -Force -Path $d | Out-Null
}

# Copy test assets and patch paths for JMETER_HOME
$jmxContent = Get-Content $SourceJmx -Raw -Encoding UTF8
$jmxContent = $jmxContent.Replace(
  '${__P(user.dir)}/jmeter/data/create-users.csv',
  '${__P(JMETER_HOME)}/qa-poc/data/create-users.csv'
)
$jmxContent = $jmxContent.Replace(
  '${__P(user.dir)}/jmeter/reports/gui-results.jtl',
  '${__P(JMETER_HOME)}/qa-poc/reports/gui-results.jtl'
)
$jmxContent | Set-Content -Path (Join-Path $PocRoot "test-plans\ReqRes-API-Load-POC.jmx") -Encoding UTF8

Copy-Item $SourceCsv -Destination (Join-Path $PocRoot "data\create-users.csv") -Force
if (Test-Path $SourceSmoke) {
  Copy-Item $SourceSmoke -Destination (Join-Path $PocRoot "test-plans\ReqRes-Smoke-Check.jmx") -Force
}

# Launcher: open GUI
@'
@echo off
set JMETER_HOME=%~dp0..
cd /d "%JMETER_HOME%\bin"
call jmeter.bat -t "%JMETER_HOME%\qa-poc\test-plans\ReqRes-API-Load-POC.jmx"
'@ | Set-Content -Path (Join-Path $PocRoot "open-gui.bat") -Encoding ASCII

# Launcher: run non-GUI + HTML report
@'
@echo off
set JMETER_HOME=%~dp0..
set POC=%JMETER_HOME%\qa-poc
set JTL=%POC%\reports\results.jtl
set HTML=%POC%\reports\html-report
set LOG=%POC%\reports\jmeter-run.log

if exist "%JTL%" del /f "%JTL%"
if exist "%HTML%" rmdir /s /q "%HTML%"

cd /d "%JMETER_HOME%\bin"
echo Running ReqRes POC (non-GUI)...
call jmeter.bat -n -t "%POC%\test-plans\ReqRes-API-Load-POC.jmx" -l "%JTL%" -j "%LOG%" -e -o "%HTML%"
if errorlevel 1 exit /b 1
echo.
echo HTML report: %HTML%\index.html
start "" "%HTML%\index.html"
'@ | Set-Content -Path (Join-Path $PocRoot "run-poc.bat") -Encoding ASCII

# Launcher: generate HTML from JTL
@'
@echo off
set JMETER_HOME=%~dp0..
set POC=%JMETER_HOME%\qa-poc
set JTL=%POC%\reports\results.jtl
set GUIJTL=%POC%\reports\gui-results.jtl
set HTML=%POC%\reports\html-report

if exist "%GUIJTL%" (
  set JTL=%GUIJTL%
)
if not exist "%JTL%" (
  echo No JTL found. Run open-gui.bat and start test, or run run-poc.bat first.
  exit /b 1
)
if exist "%HTML%" rmdir /s /q "%HTML%"
cd /d "%JMETER_HOME%\bin"
call jmeter.bat -g "%JTL%" -o "%HTML%"
start "" "%HTML%\index.html"
'@ | Set-Content -Path (Join-Path $PocRoot "generate-report.bat") -Encoding ASCII

# Shortcuts in JMeter bin folder
@'
@echo off
call "%~dp0..\qa-poc\open-gui.bat"
'@ | Set-Content -Path (Join-Path $JmeterHome "bin\QA-ReqRes-POC-GUI.bat") -Encoding ASCII

@'
@echo off
call "%~dp0..\qa-poc\run-poc.bat"
'@ | Set-Content -Path (Join-Path $JmeterHome "bin\QA-ReqRes-POC-Run.bat") -Encoding ASCII

@'
@echo off
call "%~dp0..\qa-poc\generate-report.bat"
'@ | Set-Content -Path (Join-Path $JmeterHome "bin\QA-ReqRes-POC-Report.bat") -Encoding ASCII

# README in PC JMeter folder
@'
ReqRes API QA POC (installed from qa-ai-practical-assessment)
=============================================================

Location: %JMETER_HOME%\qa-poc

Quick start (double-click or run from cmd):
  open-gui.bat          - Open JMeter GUI with test plan + report listeners
  run-poc.bat           - Run non-GUI test + open HTML dashboard
  generate-report.bat   - Build HTML report from latest JTL

From JMeter bin folder:
  QA-ReqRes-POC-GUI.bat
  QA-ReqRes-POC-Run.bat
  QA-ReqRes-POC-Report.bat

Reports:
  qa-poc\reports\results.jtl
  qa-poc\reports\gui-results.jtl   (from GUI Simple Data Writer)
  qa-poc\reports\html-report\index.html

Re-install / update from repo:
  powershell -File D:\qa-ai-practical-assessment\jmeter\scripts\install-to-pc-jmeter.ps1
'@ | Set-Content -Path (Join-Path $PocRoot "README.txt") -Encoding ASCII

Write-Host ""
Write-Host "=== Installed to PC JMeter ===" -ForegroundColor Green
Write-Host "JMETER_HOME : $JmeterHome"
Write-Host "POC folder  : $PocRoot"
Write-Host ""
Write-Host "Launch from PC JMeter:" -ForegroundColor Cyan
Write-Host "  $PocRoot\open-gui.bat"
Write-Host "  $PocRoot\run-poc.bat"
Write-Host "  $JmeterHome\bin\QA-ReqRes-POC-GUI.bat"
Write-Host ""
