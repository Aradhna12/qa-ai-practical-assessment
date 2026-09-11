# JMeter QA POC — Screenshots

Visual evidence that JMeter is installed and the POC runs successfully.

## Recommended captures

Save screenshots under `jmeter/screenshots/`.

### 1. JMeter version proof

```powershell
D:\Jmeter\apache-jmeter-5.6.3\bin\jmeter.bat -v
```

Save as: `01-jmeter-version.png`

Or use the generated file: `jmeter/docs/jmeter-version.txt`

### 2. Test plan in JMeter GUI

```powershell
D:\Jmeter\apache-jmeter-5.6.3\bin\jmeter.bat -t jmeter\test-plans\ReqRes-API-Load-POC.jmx
```

Expand the tree (Setup Thread Group, Thread Group, controllers, assertions).  
Save as: `02-test-plan-gui.png`

### 3. Non-GUI run (real execution)

```powershell
.\jmeter\scripts\run-poc.ps1
```

Capture the terminal showing `JMeter run completed successfully.`  
Save as: `03-non-gui-run.png`

### 4. HTML dashboard

Open `jmeter/reports/html-report/index.html` in a browser.  
Capture the **Dashboard** and **Statistics** pages.  
Save as: `04-html-dashboard.png`

### 5. QA verification script

```powershell
.\jmeter\scripts\qa-verify.ps1
```

Capture `ALL CHECKS PASSED`.  
Save as: `05-qa-verify-pass.png`

## Screenshot index

| File | Description |
|---|---|
| `01-jmeter-version.png` | Apache JMeter 5.6.3 installed |
| `02-test-plan-gui.png` | Test plan structure in GUI |
| `03-non-gui-run.png` | CLI run with real JMeter |
| `04-html-dashboard.png` | HTML report / 0% errors |
| `05-qa-verify-pass.png` | Automated QA script passed |
