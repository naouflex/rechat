#!/usr/bin/env node
import { chromium } from 'playwright';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const OUT = path.join(ROOT, 'static/marketing/presentation');
const BASE = 'http://localhost:3000';
const EMAIL = 'demo@rechat.io';
const PASSWORD = 'DemoPass123!';

const browser = await chromium.launch({ headless: true });
const page = await browser.newPage({ viewport: { width: 1440, height: 900 }, deviceScaleFactor: 2 });

await page.goto(`${BASE}/auth`, { waitUntil: 'networkidle' });
await page.getByPlaceholder(/email/i).fill(EMAIL);
await page.getByPlaceholder(/password/i).fill(PASSWORD);
await page.getByRole('button', { name: /sign in/i }).click();
await page.waitForURL((url) => !url.pathname.includes('/auth'), { timeout: 30000 });

await page.goto(`${BASE}/docs`, { waitUntil: 'networkidle' });
await page.waitForTimeout(1200);
await page.screenshot({ path: path.join(OUT, '03-docs.png') });

await page.goto(`${BASE}/workspace/models`, { waitUntil: 'networkidle' });
await page.waitForTimeout(1200);
await page.screenshot({ path: path.join(OUT, '08-workspace-models.png') });

console.log('saved docs + workspace');
await browser.close();
