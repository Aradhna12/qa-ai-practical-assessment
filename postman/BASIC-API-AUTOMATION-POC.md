# BASIC API Automation POC — Postman

**Role:** Quality Engineer  
**Level:** Basic  
**Tool:** Postman (Collection + Environment + Tests + Monitor + Docs)  
**Target API:** [ReqRes](https://reqres.in) — `https://reqres.in/api`  
**Date:** September 2026  
**Document path:** `postman/BASIC-API-AUTOMATION-POC.md`

---

## 1. POC Objective

Build and showcase a **basic-level API test automation** suite in Postman that a QA engineer can:

1. Open in Postman workspace
2. Run manually (single request or Collection Runner)
3. Demonstrate assertions, variables, and request chaining
4. Show scheduled cloud runs via Monitor
5. Share public documentation

This POC proves readiness for day-to-day API testing work without advanced frameworks.

---

## 2. What We Delivered

| Deliverable | Status | Details |
|---|---|---|
| Postman Collection | Done | `QA Basic API Automation - ReqRes` |
| Postman Environment | Done | `ReqRes - Dev (QA Automation)` |
| Test scripts (assertions) | Done | Status, body, and response-time checks |
| Variable chaining | Done | Login token + `userId` / `createdUserId` |
| Positive + negative tests | Done | Valid login + invalid login |
| CRUD coverage | Done | GET, POST, PUT, DELETE users |
| E2E smoke flow | Done | Login → List → Get → Create → Delete |
| Public documentation | Done | Published Postman docs |
| Scheduled monitor | Done | Daily run at 09:00 IST |
| Repo documentation | Done | This document |

---

## 3. Live Postman Showcase Links

| Asset | Link |
|---|---|
| **Collection** — `QA Basic API Automation - ReqRes` | [Open in Postman](https://go.postman.co/collection/40280682-33b12cf3-3086-4e72-a142-746a3cae6696) |
| **Environment** — `ReqRes - Dev (QA Automation)` | [Open environment](https://go.postman.co/environment/40280682-bd2e6422-ff40-4d2b-b8a4-6b83e15bd2e3) |
| **Public docs** | [View documentation](https://documenter-api.postman.tech/view/40280682/2sBYAys8ss) |
| **Monitor** — daily 09:00 IST | [Open monitor](https://go.postman.co/monitor/40280682-1f1ad9b8-5e9b-4c60-bf43-d4cad892a202) |

> Open these while signed into the Postman account used for this POC.

---

## 4. Collection Structure

```
QA Basic API Automation - ReqRes
│
├── Collection scripts (apply to all requests)
│   ├── Pre-request: set Accept / Content-Type headers
│   └── Test: response time under SLA (default 3000 ms)
│
├── 01 - Authentication
│   ├── Login - Valid Credentials          (200 + token saved)
│   └── Login - Invalid Credentials        (400 + error message)
│
├── 02 - Users CRUD
│   ├── GET List Users                     (200 + save userId)
│   ├── GET Single User                    (200 + id/email checks)
│   ├── POST Create User                   (201 + save createdUserId)
│   ├── PUT Update User                    (200 + updated fields)
│   └── DELETE User                        (204)
│
└── 03 - E2E Smoke Flow
    ├── E2E 1 - Login
    ├── E2E 2 - List Users
    ├── E2E 3 - Get User
    ├── E2E 4 - Create User
    └── E2E 5 - Delete User
```

---

## 5. Environment Variables

Environment name: **ReqRes - Dev (QA Automation)**

| Variable | Example value | Purpose |
|---|---|---|
| `baseUrl` | `https://reqres.in/api` | API base URL |
| `validEmail` | `eve.holt@reqres.in` | Valid login email |
| `validPassword` | `cityslicka` | Valid login password (secret) |
| `userId` | `2` (updated at runtime) | Chained user id from list |
| `authToken` | *(set after login)* | Token from login response |
| `createdUserId` | *(set after create)* | Id of newly created user |
| `maxResponseTimeMs` | `3000` | Response time SLA |

---

## 6. Basic QA Concepts Covered

### 6.1 Environment variables
URLs and credentials are not hard-coded in every request. Requests use `{{baseUrl}}`, `{{validEmail}}`, etc.

### 6.2 Assertions (test scripts)
Each request validates expected behavior, for example:

```javascript
pm.test('Status is 200', () => pm.response.to.have.status(200));

pm.test('Token is present', () => {
    const body = pm.response.json();
    pm.expect(body).to.have.property('token');
    pm.expect(body.token).to.be.a('string').and.not.empty;
});
```

### 6.3 Variable chaining
- Login stores `authToken`
- List Users stores `userId`
- Create User stores `createdUserId`
- Later requests reuse those values via `{{userId}}` / `{{createdUserId}}`

### 6.4 Positive and negative testing
- Valid login → expect **200** + token
- Invalid login → expect **400** + error

### 6.5 CRUD operations
- **GET** list / single user
- **POST** create user
- **PUT** update user
- **DELETE** user

### 6.6 E2E smoke flow
One folder runs a full business path end-to-end in order.

### 6.7 Collection-level checks
Every request checks response time under SLA (`maxResponseTimeMs`).

### 6.8 Showcase integrations
- Public documentation for sharing
- Monitor for scheduled automated runs in Postman Cloud

---

## 7. Sample Assertions Used

| Request | Key checks |
|---|---|
| Login - Valid Credentials | Status 200, `token` exists, save to environment |
| Login - Invalid Credentials | Status 400, `error` message present |
| GET List Users | Status 200, `data` array not empty, pagination keys, save `userId` |
| GET Single User | Status 200, id matches `userId`, email format |
| POST Create User | Status 201, `id` + `createdAt`, save `createdUserId` |
| PUT Update User | Status 200, updated name/job + `updatedAt` |
| DELETE User | Status 204 |
| E2E folder | Same checks chained in sequence |

---

## 8. How to Run / Demo (Step-by-step)

### Option A — Best demo (Collection Runner)

1. Open Postman Desktop or Web
2. Open collection: **QA Basic API Automation - ReqRes**
3. Select environment: **ReqRes - Dev (QA Automation)**
4. Click **...** on folder **03 - E2E Smoke Flow** → **Run**
5. Click **Run**
6. Show all tests green in the results panel

### Option B — Single request demo

1. Open **01 - Authentication → Login - Valid Credentials**
2. Click **Send**
3. Open **Test Results** tab → show passing assertions
4. Open environment variables → show `authToken` populated

### Option C — Negative test demo

1. Open **Login - Invalid Credentials**
2. Click **Send**
3. Confirm status **400** and error assertion pass

### Option D — Monitor / Docs demo

1. Open Monitor link → show scheduled daily run
2. Open Docs link → show published API documentation

---

## 9. What We Did in This POC (Work Summary)

1. Connected to Postman account / workspace
2. Created basic automation collection for ReqRes API
3. Created dedicated Dev environment with variables
4. Added folders for Authentication, Users CRUD, and E2E Smoke Flow
5. Added requests with test scripts for status, body, and chaining
6. Added collection-level pre-request + SLA tests
7. Published public documentation for showcase
8. Created a daily Monitor (09:00 Asia/Kolkata)
9. Documented the full BASIC POC in this single file

---

## 10. Scope Boundaries (Basic Level)

### In scope
- Functional API checks (status + key fields)
- Environment usage
- Request chaining
- Positive / negative cases
- Simple CRUD + E2E smoke
- Manual run + Postman Monitor showcase

### Out of scope (intentionally for BASIC)
- Complex auth (OAuth, JWT validation flows)
- Performance / load testing
- Security / penetration testing
- Full contract / schema suite (available in extended repo POC)
- Advanced CI pipelines (available in extended repo POC)

> Extended Newman + schema + CI collection lives at:  
> `postman/collections/ReqRes-API-Automation-POC.postman_collection.json`

---

## 11. Expected Demo Outcome

After running **03 - E2E Smoke Flow**, a successful demo shows:

- All requests executed in order
- All assertions passed (green)
- Environment variables updated (`authToken`, `userId`, `createdUserId`)
- Clear evidence of basic API automation skills in Postman

---

## 12. Conclusion

This BASIC Postman API Automation POC demonstrates that a Quality Engineer can:

- Design a readable test collection
- Use environments and variables correctly
- Write meaningful assertions
- Chain requests for realistic flows
- Cover positive, negative, CRUD, and E2E smoke cases
- Showcase work live in Postman (collection, docs, monitor)

**POC status: Complete and ready for showcase.**
