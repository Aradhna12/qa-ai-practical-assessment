# Postman API Automation POC

A practical proof-of-concept for API test automation using **Postman** and **Newman** (CLI runner).

## What this POC covers

| QA concept | Implementation |
|---|---|
| Environment variables | `baseUrl`, `userId`, `authToken`, credentials |
| Request chaining | Login → store token → use `userId` in later requests |
| Assertions | Status codes, JSON fields, response time SLA |
| **JSON Schema contracts** | Folder `05 - Contract Tests` + `postman/schemas/` |
| Negative testing | Invalid login (400), user not found (404) |
| Dynamic data | Postman dynamic variables (`$randomFirstName`, etc.) |
| Data-driven tests | CSV file + Newman `--iteration-data` |
| E2E workflow | Folder `04 - E2E Workflow` (run in order) |
| **Custom API support** | `custom-api.postman_environment.json` |
| **CI/CD** | GitHub Actions workflow (`.github/workflows/postman-api-tests.yml`) |
| CI-ready reports | JUnit XML and HTML (htmlextra) reporters |

## Target API

[ReqRes](https://reqres.in) — free public REST API for practice (no API key required).

## Prerequisites

1. [Postman Desktop](https://www.postman.com/downloads/) (optional, for GUI)
2. Node.js 18+ (for Newman CLI)

## Quick start

### 1. Import into Postman (GUI)

1. Open Postman → **Import**
2. Import these files:
   - `postman/collections/ReqRes-API-Automation-POC.postman_collection.json`
   - `postman/environments/reqres-dev.postman_environment.json`
   - `postman/environments/custom-api.postman_environment.json` (optional, for your own API)
3. Select the **ReqRes - Dev** environment (top-right dropdown)
4. Run individual requests or use **Collection Runner**

**Recommended runner order for full CRUD flow:**

```
04 - E2E Workflow  (run entire folder)
```

Or run folders `01` → `02` → `03` in sequence.

### 2. Run via Newman (CLI)

```bash
npm install
```

| Command | Description |
|---|---|
| `npm run postman:run` | Run entire collection |
| `npm run postman:run:workflow` | Run E2E workflow folder only |
| `npm run postman:run:contracts` | Run JSON Schema contract tests only |
| `npm run postman:run:data-driven` | Run CSV data-driven create-user tests + HTML report |
| `npm run postman:run:custom` | Run against your API (`custom-api` environment) |
| `npm run postman:run:ci` | Run all tests, export JUnit XML for CI pipelines |

Reports are written to `postman/reports/` (gitignored).

## Screenshots

Generate visual documentation screenshots automatically:

```bash
npm run postman:screenshots          # Visual guide screenshots (no API calls)
npm run postman:screenshots:full     # Includes Newman HTML report screenshot
```

Output is saved to `postman/screenshots/` (see [SCREENSHOTS.md](./SCREENSHOTS.md) for the full index).

| Screenshot | What it shows |
|---|---|
| `01-collection-structure.png` | Collection folders and request layout |
| `02-environment-setup.png` | Environment variables |
| `03-test-assertions.png` | Test scripts and passing assertions |
| `04-collection-runner-results.png` | Runner pass/fail summary |
| `05-contract-tests.png` | JSON Schema contract tests |
| `06-newman-cli.png` | Newman CLI commands |
| `07-newman-html-report.png` | Newman HTML test report |

## Collection structure

```
ReqRes API Automation POC
├── 01 - Authentication              Login, register, negative login
├── 02 - Users (Read)                List, get by ID, pagination, 404
├── 03 - Users (Write)               Create, PUT, PATCH, DELETE, CSV-driven create
├── 04 - E2E Workflow                Login → list → get → create → delete
└── 05 - Contract Tests (JSON Schema) Schema validation for key endpoints
```

## JSON Schema contract tests

Schemas live in `postman/schemas/` (source of truth for documentation):

| Schema file | Endpoint |
|---|---|
| `login-response.schema.json` | `POST /login` |
| `user-list-response.schema.json` | `GET /users` |
| `user-single-response.schema.json` | `GET /users/:id` |
| `create-user-response.schema.json` | `POST /users` |
| `error-response.schema.json` | Error payloads (400 login, etc.) |
| `not-found-response.schema.json` | Empty body 404 responses |

Tests use Postman's built-in validator:

```javascript
const schema = JSON.parse(pm.collectionVariables.get('schema_login_response'));
pm.test('Contract: login response matches JSON Schema', function () {
    pm.response.to.have.jsonSchema(schema);
});
```

Run contract tests only:

```bash
npm run postman:run:contracts
```

## Point at your own API

1. Open `postman/environments/custom-api.postman_environment.json`
2. Update these values:

| Variable | Example |
|---|---|
| `baseUrl` | `http://localhost:3000/api` |
| `validEmail` | Your test user email |
| `validPassword` | Your test user password |
| `apiKey` | Optional Bearer token (auto-added to `Authorization` header when set) |

3. Run:

```bash
npm run postman:run:custom
```

**Note:** Your API must follow ReqRes-compatible paths (`/login`, `/users`, etc.) or adapt the collection URLs and schemas accordingly.

## GitHub Actions CI

Workflow file: `.github/workflows/postman-api-tests.yml`

Triggers on:
- Push to `main` / `master`
- Pull requests
- Manual `workflow_dispatch`

The pipeline runs `npm run postman:run:ci`, uploads JUnit XML as an artifact, and publishes results to the PR checks tab.

## Key test patterns (for learning)

### Status + body assertion

```javascript
pm.test('Status code is 200', function () {
    pm.response.to.have.status(200);
});

const json = pm.response.json();
pm.expect(json.data).to.be.an('array').that.is.not.empty;
```

### Chain variables between requests

```javascript
// In "Get All Users" test script:
pm.environment.set('userId', pm.response.json().data[0].id);

// Next request URL uses: {{baseUrl}}/users/{{userId}}
```

### Collection-level checks (every request)

- Response time below `maxResponseTimeMs` (default 3000ms)
- `Content-Type` includes `application/json` (skipped for 204 responses)
- Optional `Authorization: Bearer {{apiKey}}` when `apiKey` is set

### Data-driven (Newman)

CSV at `postman/data/create-users.csv`:

```csv
name,job
Alice Johnson,QA Engineer
Bob Smith,SDET
```

Run: `npm run postman:run:data-driven`

## Troubleshooting

| Issue | Fix |
|---|---|
| `ECONNREFUSED` | Check internet access; ReqRes must be reachable |
| Newman not found | Run `npm install` first |
| Tests fail on timing | Increase `maxResponseTimeMs` in environment |
| `userId` undefined in write tests | Run `02 - Users (Read)` or `04 - E2E Workflow` first |
| Custom API tests fail | Verify `baseUrl`, credentials, and that endpoints match ReqRes structure |
| Schema contract fails | Compare response with files in `postman/schemas/` and update schema or API |
