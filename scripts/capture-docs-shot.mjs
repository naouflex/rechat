#!/usr/bin/env node
import { chromium } from 'playwright';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const OUT = path.join(path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..'), 'static/marketing/presentation');
const browser = await chromium.launch({ headless: true });
const page = await browser.newPage({ viewport: { width: 1440, height: 900 }, deviceScaleFactor: 2 });
await page.goto('https://rechat.naoufel.io/docs', { waitUntil: 'networkidle' });
await page.waitForTimeout(1500);
await page.screenshot({ path: path.join(OUT, '03-docs.png') });
console.log('saved production docs');
await browser.close();
