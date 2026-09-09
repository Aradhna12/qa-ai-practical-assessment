# Postman API Automation — Screenshots

Visual documentation for the API automation POC.

## Generate screenshots

```bash
npm install
npm run postman:screenshots
```

This captures section screenshots via Playwright into `postman/screenshots/` from the visual guide.

To also include the Newman HTML report screenshot (requires a successful API test run first):

```bash
npm run postman:screenshots:full
```

Or generate the report separately, then capture:

```bash
npm run postman:report
npm run postman:screenshots
```

## Screenshot index

| File | Description |
|------|-------------|
| `00-full-visual-guide.png` | Full overview of the POC |
| `01-collection-structure.png` | Postman collection folders and request layout |
| `02-environment-setup.png` | Environment variables (`ReqRes - Dev`) |
| `03-test-assertions.png` | Test scripts and passing assertions |
| `04-collection-runner-results.png` | Collection runner pass/fail summary |
| `05-contract-tests.png` | JSON Schema contract validation |
| `06-newman-cli.png` | Newman CLI commands and output |
| `07-newman-html-report.png` | Full Newman HTML test report |
| `07-newman-html-report-summary.png` | Report summary section |

## Manual Postman GUI screenshots (optional)

If you have Postman Desktop installed, capture these for your assessment submission:

1. **Import** — File → Import → select collection + environment JSON files
2. **Environment** — Select `ReqRes - Dev` from the environment dropdown
3. **Send request** — Run `Login - Valid Credentials` and show Tests tab (green checkmarks)
4. **Collection Runner** — Run folder `04 - E2E Workflow` and screenshot results
5. **Contract tests** — Run folder `05 - Contract Tests` and screenshot results

Save manual captures to `postman/screenshots/manual/` if needed.
