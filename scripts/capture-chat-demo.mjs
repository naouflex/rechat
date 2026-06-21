#!/usr/bin/env node
/** Capture chat demo video + conversation screenshots (assumes landing assets already exist). */
import { chromium } from 'playwright';
import { mkdir } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const OUT = path.join(ROOT, 'static/marketing/presentation');
const BASE = process.argv.find((a) => a.startsWith('--base='))?.split('=')[1] ?? 'http://localhost:3000';
const EMAIL = 'demo@rechat.io';
const PASSWORD = 'DemoPass123!';
const VIEWPORT = { width: 1440, height: 900 };

async function screenshot(page, name) {
	const file = path.join(OUT, name);
	await page.screenshot({ path: file });
	console.log('saved', file);
}

async function selectTinyLlama(page) {
	const modelBtn = page.getByRole('button', { name: /selected model/i }).first();
	await modelBtn.waitFor({ state: 'visible', timeout: 15000 });
	const label = await modelBtn.innerText();
	if (/tinyllama/i.test(label)) return;

	await modelBtn.click();
	await page.getByRole('option', { name: /tinyllama/i }).click();
	await page.waitForTimeout(600);
}

async function main() {
	await mkdir(OUT, { recursive: true });
	const browser = await chromium.launch({ headless: true });
	const context = await browser.newContext({
		viewport: VIEWPORT,
		deviceScaleFactor: 2,
		recordVideo: { dir: OUT, size: VIEWPORT }
	});
	const page = await context.newPage();

	try {
		await page.goto(`${BASE}/auth`, { waitUntil: 'networkidle' });
		await page.getByPlaceholder(/email/i).fill(EMAIL);
		await page.getByPlaceholder(/password/i).fill(PASSWORD);
		await page.getByRole('button', { name: /sign in/i }).click();
		await page.waitForURL((url) => !url.pathname.includes('/auth'), { timeout: 30000 });
		await page.waitForTimeout(2000);

		await selectTinyLlama(page);
		await screenshot(page, '05-chat-home.png');

		const composer = page.locator('[contenteditable="true"], #chat-input, textarea').first();
		await composer.click();
		const prompt =
			'Explain in three bullet points why a self-hosted AI chat workspace is useful for a small team.';
		await composer.fill(prompt);
		await page.waitForTimeout(500);
		await screenshot(page, '06-chat-composing.png');

		await page.keyboard.press('Enter');
		await page.waitForFunction(
			() => {
				const blocks = document.querySelectorAll('.markdown-prose');
				return blocks.length >= 2 && blocks[blocks.length - 1].textContent.trim().length > 40;
			},
			{ timeout: 120000 }
		);
		await page.waitForTimeout(3000);
		await screenshot(page, '07-chat-conversation.png');
	} finally {
		const video = page.video();
		await page.close();
		if (video) {
			const webmPath = path.join(OUT, 'demo-flow.webm');
			try {
				await video.saveAs(webmPath);
				console.log('saved', webmPath);
			} catch (err) {
				console.warn('Video save skipped:', err.message);
			}
		}
		await context.close();
		await browser.close();
	}
}

main().catch((e) => {
	console.error(e);
	process.exit(1);
});
