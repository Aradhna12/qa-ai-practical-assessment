Kubernetes screenshot / kubectl evidence capture
===============================================
Captured: 2026-09-11 11:08:42 +05:30
Host: TTNPL-6976
Shell: Windows PowerShell

1) kubectl client version captured
----------------------------------
YES — saved to kubernetes/docs/kubectl-client-version.txt

Client Version: v1.36.1
Kustomize Version: v5.8.1

2) Cluster availability (kubectl get nodes)
-------------------------------------------
Cluster available: NO
kubectl get nodes failed (no API server on localhost:8080).

Output:
kubectl : E0911 11:08:42.548927   78236 memcache.go:265] "Unhandled Error" err="couldn't get current server API group 
list: Get \"http://localhost:8080/api?timeout=32s\": dial tcp [::1]:8080: connectex: No connection could be made 
because the target machine actively refused it."
At C:\Users\Aradhna\AppData\Local\Temp\ps-script-74c416a6-82a1-4da4-b31d-be5b31211555.ps1:100 char:367
+ ... -version.txt -Raw).Trim(); $nodesOut = kubectl get nodes 2>&1 | Out-S ...
+                                            ~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (E0911 11:08:42....ly refused it.":String) [], RemoteException
    + FullyQualifiedErrorId : NativeCommandError
 
E0911 11:08:42.549922   78236 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get 
\"http://localhost:8080/api?timeout=32s\": dial tcp [::1]:8080: connectex: No connection could be made because the 
target machine actively refused it."
E0911 11:08:42.551334   78236 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get 
\"http://localhost:8080/api?timeout=32s\": dial tcp [::1]:8080: connectex: No connection could be made because the 
target machine actively refused it."
E0911 11:08:42.551849   78236 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get 
\"http://localhost:8080/api?timeout=32s\": dial tcp [::1]:8080: connectex: No connection could be made because the 
target machine actively refused it."
E0911 11:08:42.553121   78236 memcache.go:265] "Unhandled Error" err="couldn't get current server API group list: Get 
\"http://localhost:8080/api?timeout=32s\": dial tcp [::1]:8080: connectex: No connection could be made because the 
target machine actively refused it."
Unable to connect to the server: dial tcp [::1]:8080: connectex: No connection could be made because the target 
machine actively refused it.

3) Screenshot generation result
-------------------------------
Command: npm run k8s:screenshots
Result: SUCCESS (10 passed)
Playwright project: chromium
Spec: tests/kubernetes-screenshots.spec.ts

Screenshot files:
  - 00-full-visual-guide.png (445502 bytes)
  - 01-cluster-nodes.png (19881 bytes)
  - 02-namespace-apply.png (21596 bytes)
  - 03-pods-ready.png (25438 bytes)
  - 04-deployment-service.png (24201 bytes)
  - 05-describe-logs.png (24516 bytes)
  - 06-scale-rollout.png (20734 bytes)
  - 07-negative-test.png (23483 bytes)
  - 08-qa-script-result.png (31185 bytes)
  - 09-cleanup.png (17310 bytes)

Notes
-----
- PATH was refreshed from Machine + User environment variables before kubectl.
- kubernetes/screenshots directory ensured via New-Item -Force.
- npm install reported packages up to date; chromium installed via npx playwright install chromium.
