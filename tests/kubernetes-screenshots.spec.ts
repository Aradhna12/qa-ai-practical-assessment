import { test } from '@playwright/test';
import fs from 'fs';
import path from 'path';
import { pathToFileURL } from 'url';

const screenshotDir = path.resolve(__dirname, '../kubernetes/screenshots');
const guidePath = path.resolve(__dirname, '../kubernetes/docs/visual-guide.html');

const guideSections = [
  { id: 'cluster-nodes', file: '01-cluster-nodes.png', name: 'Cluster nodes' },
  { id: 'namespace-apply', file: '02-namespace-apply.png', name: 'Namespace apply' },
  { id: 'pods-ready', file: '03-pods-ready.png', name: 'Pods ready' },
  { id: 'deployment-service', file: '04-deployment-service.png', name: 'Deployment and service' },
  { id: 'describe-logs', file: '05-describe-logs.png', name: 'Describe and logs' },
  { id: 'scale-rollout', file: '06-scale-rollout.png', name: 'Scale and rollout' },
  { id: 'negative-test', file: '07-negative-test.png', name: 'Negative test' },
  { id: 'qa-script-result', file: '08-qa-script-result.png', name: 'QA script result' },
  { id: 'cleanup', file: '09-cleanup.png', name: 'Cleanup' },
];

test.describe.configure({ mode: 'serial' });

test.beforeAll(() => {
  fs.mkdirSync(screenshotDir, { recursive: true });
});

test.describe('Kubernetes QA POC screenshots', () => {
  test.use({
    viewport: { width: 1280, height: 800 },
    deviceScaleFactor: 1,
  });

  for (const section of guideSections) {
    test(`capture ${section.name}`, async ({ page }) => {
      await page.goto(pathToFileURL(guidePath).href);
      const element = page.locator(`#${section.id}`);
      await element.waitFor({ state: 'visible' });
      await element.screenshot({
        path: path.join(screenshotDir, section.file),
      });
    });
  }

  test('capture full visual guide overview', async ({ page }) => {
    await page.goto(pathToFileURL(guidePath).href);
    await page.waitForLoadState('networkidle');

    await page.screenshot({
      path: path.join(screenshotDir, '00-full-visual-guide.png'),
      fullPage: true,
    });
  });
});
