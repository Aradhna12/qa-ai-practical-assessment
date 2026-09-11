# JMeter QA POC

Apache JMeter proof-of-concept for **functional API testing + light load** against [ReqRes](https://reqres.in).

## Prerequisites

- **Apache JMeter 5.6.3** installed at `D:\Jmeter\apache-jmeter-5.6.3` (or set `JMETER_HOME`)
- Internet access to `https://reqres.in`

## Quick start

```powershell
# 1. Run the test (non-GUI, real JMeter)
.\jmeter\scripts\run-poc.ps1

# 2. Verify install + results
.\jmeter\scripts\qa-verify.ps1

# Or via npm
npm run jmeter:run
npm run jmeter:verify
```

## Open in JMeter GUI (optional)

```powershell
D:\Jmeter\apache-jmeter-5.6.3\bin\jmeter.bat -t jmeter\test-plans\ReqRes-API-Load-POC.jmx
```

## Reports

**In JMeter GUI** — listeners under `02 - Reports`:
View Results Tree, Summary Report, Aggregate Report, View Results in Table, Simple Data Writer (JTL).

**HTML dashboard** — auto-generated after CLI run:

```powershell
npm run jmeter:run      # test + open report in browser
npm run jmeter:report   # rebuild HTML from latest JTL
```

## Outputs

| Artifact | Path |
|---|---|
| CLI JTL results | `jmeter/reports/results.jtl` |
| GUI JTL results | `jmeter/reports/gui-results.jtl` |
| HTML dashboard | `jmeter/reports/html-report/index.html` |
| Run log | `jmeter/reports/jmeter-run.log` |
| Version proof | `jmeter/docs/jmeter-version.txt` |

## Documentation

- Full POC write-up: [`BASIC-JMETER-QA-POC.md`](BASIC-JMETER-QA-POC.md)
- Screenshot guide: [`SCREENSHOTS.md`](SCREENSHOTS.md)
