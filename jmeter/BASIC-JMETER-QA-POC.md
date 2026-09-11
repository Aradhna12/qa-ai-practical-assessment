# BASIC JMeter QA POC

**Role:** Quality Engineer  
**Level:** Intermediate (deeper than hello-world)  
**Tool:** Apache JMeter 5.6.3 (non-GUI + optional GUI)  
**Target API:** [ReqRes](https://reqres.in) — `https://reqres.in/api`  
**Date:** September 2026  
**Document path:** `jmeter/BASIC-JMETER-QA-POC.md`

---

## 1. POC Objective

Build and showcase a **deeper JMeter proof-of-concept** that a QA engineer can use to:

1. Prove JMeter is installed and runnable on the local machine
2. Run functional API checks with assertions
3. Chain variables (login token, user IDs) across requests
4. Drive data from CSV (data-driven POST)
5. Apply light concurrent load (5 users, 2 loops)
6. Include negative testing with conditional logic
7. Generate JTL + HTML dashboard reports
8. Automate verification with a PowerShell QA script

---

## 2. What We Delivered

| Deliverable | Status | Path / details |
|---|---|---|
| JMeter test plan (.jmx) | Done | `jmeter/test-plans/ReqRes-API-Load-POC.jmx` |
| CSV test data | Done | `jmeter/data/create-users.csv` |
| Non-GUI run script | Done | `jmeter/scripts/run-poc.ps1` |
| QA verify script | Done | `jmeter/scripts/qa-verify.ps1` |
| JTL + HTML reports | Done | `jmeter/reports/` (generated on run) |
| Install proof (version) | Done | `jmeter/docs/jmeter-version.txt` |
| POC write-up | Done | This document |
| README | Done | `jmeter/README.md` |

---

## 3. JMeter Installation Proof

**Install path:** `D:\Jmeter\apache-jmeter-5.6.3`  
**POC on PC JMeter:** `D:\Jmeter\apache-jmeter-5.6.3\qa-poc`  
**Version:** Apache JMeter **5.6.3**

### Install / update POC on your PC JMeter

```powershell
npm run jmeter:install
# or
.\jmeter\scripts\install-to-pc-jmeter.ps1
```

**PC JMeter shortcuts** (after install):

| File | Action |
|---|---|
| `D:\Jmeter\apache-jmeter-5.6.3\qa-poc\open-gui.bat` | Open GUI + test plan + reports |
| `D:\Jmeter\apache-jmeter-5.6.3\qa-poc\run-poc.bat` | Run test + HTML dashboard |
| `D:\Jmeter\apache-jmeter-5.6.3\qa-poc\generate-report.bat` | Build HTML from JTL |
| `D:\Jmeter\apache-jmeter-5.6.3\bin\QA-ReqRes-POC-GUI.bat` | Same as open-gui |
| `D:\Jmeter\apache-jmeter-5.6.3\bin\QA-ReqRes-POC-Run.bat` | Same as run-poc |
| `D:\Jmeter\apache-jmeter-5.6.3\bin\QA-ReqRes-POC-Report.bat` | Same as generate-report |

```powershell
D:\Jmeter\apache-jmeter-5.6.3\bin\jmeter.bat -v
```

Expected output includes:

```
... 5.6.3
Copyright (c) 1999-2024 The Apache Software Foundation
```

Saved proof file: `jmeter/docs/jmeter-version.txt` (created by `qa-verify.ps1`).

---

## 4. Test Plan Structure

```
ReqRes API Load & Functional POC
│
├── User Defined Variables
│   ├── baseUrl, apiPath
│   ├── maxResponseTimeMs (SLA: 3000 ms)
│   └── loginEmail, loginPassword
│
├── 00 - Setup Health Check (Setup Thread Group)
│   └── GET /api/users?page=1  → assert 200 (stop test if API down)
│
└── 01 - API Load & Functional Flow (Thread Group)
    ├── HTTP Request Defaults + Header Manager
    ├── CSV Data Set Config (create-users.csv)
    ├── Cookie Manager + Cache Manager
    ├── Think Time (Uniform Random Timer 100–500 ms)
    │
    ├── Once Only Controller
    │   └── POST /login
    │       ├── Response Assertion (200)
    │       ├── JSON Extractor → authToken
    │       ├── Duration Assertion (SLA)
    │       └── JSR223 Groovy Assertion (token present)
    │
    ├── Transaction Controller — Users CRUD
    │   ├── GET /users?page=1  → extract userId
    │   ├── GET /users/${userId}
    │   ├── POST /users (CSV name/job) → extract createdUserId
    │   ├── PUT /users/${userId}
    │   └── DELETE /users/${userId}  → assert 204
    │
    └── If Controller (negative, even thread numbers)
        └── GET /users/999  → assert 404
```

**Load profile:** 2 threads, 3 s ramp-up, 1 loop (light load to avoid ReqRes rate limits).

---

## 5. JMeter Concepts Covered (Deeper QA)

| QA / JMeter concept | How this POC shows it |
|---|---|
| Test Plan & Thread Groups | Main flow + Setup Thread Group |
| HTTP Request Defaults | Shared host/protocol/path |
| Header Manager | Accept + Content-Type JSON |
| CSV Data Set | Data-driven user creation |
| Once Only Controller | Login once per thread |
| Transaction Controller | Group CRUD as one transaction |
| If Controller | Conditional negative test |
| JSON PostProcessor | Extract token, userId, createdUserId |
| Response Assertion | Status codes 200/201/204/404 |
| Duration Assertion | Response time SLA |
| JSR223 Assertion (Groovy) | Custom token validation |
| Timers | Think time between requests |
| Non-GUI execution | `jmeter -n -t ... -l ... -e -o ...` |
| HTML Dashboard | Auto-generated from JTL |

---

## 6. How to Run (Real JMeter)

### Option A — PowerShell script (recommended)

```powershell
cd D:\qa-ai-practical-assessment
.\jmeter\scripts\run-poc.ps1
```

### Option B — Direct JMeter command

```powershell
$env:JMETER_HOME = "D:\Jmeter\apache-jmeter-5.6.3"
$ROOT = "D:\qa-ai-practical-assessment"

& "$env:JMETER_HOME\bin\jmeter.bat" -n `
  -t "$ROOT\jmeter\test-plans\ReqRes-API-Load-POC.jmx" `
  -l "$ROOT\jmeter\reports\results.jtl" `
  -j "$ROOT\jmeter\reports\jmeter-run.log" `
  -e -o "$ROOT\jmeter\reports\html-report" `
  -Juser.dir=$ROOT
```

### Option C — JMeter GUI (explore / debug)

```powershell
D:\Jmeter\apache-jmeter-5.6.3\bin\jmeter.bat -t jmeter\test-plans\ReqRes-API-Load-POC.jmx
```

### Verify everything

```powershell
.\jmeter\scripts\qa-verify.ps1
```

---

## 7. Reports in JMeter

### Built-in listeners (GUI)

The test plan includes these **02 - Reports** listeners (visible in JMeter GUI after reload):

| Listener | Purpose |
|---|---|
| **View Results Tree** | Request/response detail per sample |
| **Summary Report** | Pass/fail counts, avg response time |
| **Aggregate Report** | Min/max/percentiles per label |
| **View Results in Table** | Tabular live results |
| **Simple Data Writer** | Saves `jmeter/reports/gui-results.jtl` |

**GUI workflow:**
1. Open GUI: `npm run jmeter:gui`
2. Click **Start** (green play)
3. Click each listener tab to view live reports
4. Generate HTML dashboard from GUI results:

```powershell
.\jmeter\scripts\generate-html-report.ps1 -JtlFile jmeter\reports\gui-results.jtl
```

### HTML dashboard (CLI / auto)

After `run-poc.ps1`, JMeter generates:

| File | Path |
|---|---|
| JTL results | `jmeter/reports/results.jtl` |
| HTML dashboard | `jmeter/reports/html-report/index.html` |
| Run log | `jmeter/reports/jmeter-run.log` |

```powershell
npm run jmeter:run      # runs test + opens HTML report in browser
npm run jmeter:report   # regenerate HTML from latest JTL
```

---

## 8. Expected Results

After a successful run:

| Check | Expected |
|---|---|
| Exit code | `0` |
| `results.jtl` | Created with sample rows |
| `html-report/index.html` | Dashboard with 0% error rate |
| Failed samples | `0` |
| `qa-verify.ps1` | `ALL CHECKS PASSED` |

Open the HTML report in a browser:

```
jmeter/reports/html-report/index.html
```

---

## 9. Folder Structure

```
jmeter/
├── BASIC-JMETER-QA-POC.md
├── README.md
├── SCREENSHOTS.md
├── data/
│   └── create-users.csv
├── docs/
│   └── jmeter-version.txt
├── reports/                    ← generated (gitignored)
│   ├── results.jtl
│   ├── jmeter-run.log
│   └── html-report/
├── scripts/
│   ├── run-poc.ps1
│   └── qa-verify.ps1
├── screenshots/
│   └── (capture proof screenshots here)
└── test-plans/
    └── ReqRes-API-Load-POC.jmx
```

---

## 10. Screenshot Evidence Checklist

Capture these for your QA portfolio:

| # | What to capture | Suggested filename |
|---|---|---|
| 1 | `jmeter -v` showing 5.6.3 | `01-jmeter-version.png` |
| 2 | JMeter GUI with test plan tree open | `02-test-plan-gui.png` |
| 3 | Terminal: `run-poc.ps1` success | `03-non-gui-run.png` |
| 4 | HTML dashboard — Statistics tab | `04-html-dashboard.png` |
| 5 | `qa-verify.ps1` ALL PASSED | `05-qa-verify-pass.png` |

See [`SCREENSHOTS.md`](SCREENSHOTS.md) for step-by-step capture instructions.

---

## 11. Troubleshooting

| Issue | Fix |
|---|---|
| `jmeter` not in PATH | Use full path `D:\Jmeter\apache-jmeter-5.6.3\bin\jmeter.bat` or set `JMETER_HOME` |
| CSV not found | Run from repo root; script passes `-Juser.dir=` |
| HTTP 429 on **GET API Health** | ReqRes rate limit — **disable** `00 - Setup Health Check` (already disabled by default) or wait 5–10 min |
| HTTP 429 on Login/CRUD | Too many runs; wait 5–10 min, clear results (Run → Clear all), use 1 thread |
| Red errors in View Results Tree from old runs | Click **Run → Clear all** before each new test |
| Connection errors | Check internet access to `https://reqres.in` |
| Assertion failures | Open `jmeter/reports/jmeter-run.log` for details |

---

## 12. Alignment with Other POCs

This JMeter POC uses the same **ReqRes API** and CSV user data pattern as the Postman collection in `postman/`, so you can compare:

- **Postman** → manual/exploratory + Newman CI
- **JMeter** → load, concurrency, performance SLA, HTML dashboards
