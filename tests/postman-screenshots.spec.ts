import { test } from '@playwright/test';
import fs from 'fs';
import path from 'path';
import { pathToFileURL } from 'url';

const screenshotDir = path.resolve(__dirname, '../postman/screenshots');
const guidePath = path.resolve(__dirname, '../postman/docs/visual-guide.html');
const reportPath = path.resolve(__dirname, '../postman/reports/htmlextra-report.html');

const guideSections = [
  { id: 'collection-structure', file: '01-collection-structure.png', name: 'Collection structure' },
  { id: 'environment-setup', file: '02-environment-setup.png', name: 'Environment setup' },
  { id: 'test-assertions', file: '03-test-assertions.png', name: 'Test assertions' },
  { id: 'collection-runner', file: '04-collection-runner-results.png', name: 'Collection runner results' },
  { id: 'contract-tests', file: '05-contract-tests.png', name: 'Contract tests' },
  { id: 'newman-cli', file: '06-newman-cli.png', name: 'Newman CLI' },
];

test.describe.configure({ mode: 'serial' });

test.beforeAll(() => {
  fs.mkdirSync(screenshotDir, { recursive: true });
});

test.describe('Postman POC screenshots', () => {
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

  test('capture Newman HTML report', async ({ page }) => {
    test.skip(!fs.existsSync(reportPath), 'Run npm run postman:report first to generate HTML report');

    await page.goto(pathToFileURL(reportPath).href);
    await page.waitForLoadState('networkidle');

    await page.screenshot({
      path: path.join(screenshotDir, '07-newman-html-report.png'),
      fullPage: true,
    });

    const summary = page.locator('.summary, .dashboard, .container, body').first();
    if (await summary.count()) {
      await summary.screenshot({
        path: path.join(screenshotDir, '07-newman-html-report-summary.png'),
      });
    }
  });

  test('capture full visual guide overview', async ({ page }) => {
    await page.goto(pathToFileURL(guidePath).href);
    await page.waitForLoadState('networkidle');

    await page.screenshot({
      path: path.join(screenshotDir, '00-full-visual-guide.png'),
      fullPage: true,
    });
  });
});
