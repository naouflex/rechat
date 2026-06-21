#!/usr/bin/env node
/**
 * Capture Rechat presentation assets: screenshots + demo video (convert to GIF with ffmpeg).
 * Usage: node scripts/capture-presentation-assets.mjs [--base=http://localhost:3000]
 */
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

async function login(page) {
	await page.goto(`${BASE}/auth`, { waitUntil: 'networkidle' });
	await page.getByPlaceholder(/email/i).fill(EMAIL);
	await page.getByPlaceholder(/password/i).fill(PASSWORD);
	await page.getByRole('button', { name: /sign in/i }).click();
	await page.waitForURL((url) => !url.pathname.includes('/auth'), { timeout: 30000 });
	await page.waitForTimeout(1500);
}

async function selectModel(page) {
	const selector = page.getByRole('button', { name: /select a model/i }).first();
	if (await selector.isVisible().catch(() => false)) {
		await selector.click();
		await page.waitForTimeout(400);
		const tiny = page.getByRole('button', { name: /tinyllama/i }).first();
		if (await tiny.isVisible().catch(() => false)) {
			await tiny.click();
			await page.waitForTimeout(500);
			return;
		}
		const firstModel = page.locator('[role="option"], [role="menuitem"], button').filter({ hasText: /llama|gpt|model/i }).first();
		if (await firstModel.isVisible().catch(() => false)) {
			await firstModel.click();
			await page.waitForTimeout(500);
		}
	}
}

async function screenshot(page, name, opts = {}) {
	const file = path.join(OUT, name);
	await page.screenshot({ path: file, ...opts });
	console.log('saved', file);
}

async function main() {
	await mkdir(OUT, { recursive: true });

	const browser = await chromium.launch({ headless: true });
	const context = await browser.newContext({
		viewport: VIEWPORT,
		deviceScaleFactor: 2,
		recordVideo: {
			dir: OUT,
			size: VIEWPORT
		}
	});
	const page = await context.newPage();

	try {
		// 1. Landing page
		await page.goto(BASE, { waitUntil: 'networkidle' });
		await page.waitForTimeout(800);
		await screenshot(page, '01-landing-hero.png');
		await page.evaluate(() => window.scrollTo({ top: 900, behavior: 'instant' }));
		await page.waitForTimeout(400);
		await screenshot(page, '02-landing-features.png', { fullPage: false });
		await page.evaluate(() => window.scrollTo({ top: 0, behavior: 'instant' }));

		// 2. Docs (public)
		await page.goto(`${BASE}/docs`, { waitUntil: 'networkidle' });
		await page.waitForTimeout(800);
		if (page.url().includes('/auth')) {
			console.warn('Docs redirected to auth; skipping dedicated docs screenshot.');
		} else {
			await screenshot(page, '03-docs.png');
		}

		// 3. Auth
		await page.goto(`${BASE}/auth`, { waitUntil: 'networkidle' });
		await page.waitForTimeout(500);
		await screenshot(page, '04-auth-login.png');

		// 4. Login + chat (video recording starts with this context)
		await login(page);
		await selectModel(page);
		await page.waitForTimeout(1000);
		await screenshot(page, '05-chat-home.png');

		// Start new chat / focus composer
		const composer = page.locator('#chat-input, textarea, [contenteditable="true"]').first();
		await composer.waitFor({ state: 'visible', timeout: 15000 });

		const demoPrompt =
			'Explain in three bullet points why a self-hosted AI chat workspace is useful for a small team.';
		await composer.click();
		await composer.fill(demoPrompt);

		await page.waitForTimeout(500);
		await screenshot(page, '06-chat-composing.png');

		const sendBtn = page.locator('button[type="submit"], button[aria-label*="send" i]').last();
		if (await sendBtn.isEnabled().catch(() => false)) {
			await sendBtn.click();
		} else {
			await page.keyboard.press('Enter');
		}
		// Wait for assistant reply (tinyllama or fallback UI)
		await page.waitForTimeout(2000);
		try {
			await page.locator('[data-testid="assistant-message"], .markdown-prose').last().waitFor({
				state: 'visible',
				timeout: 90000
			});
		} catch {
			console.warn('Assistant reply not detected within timeout; capturing current state.');
		}
		await page.waitForTimeout(1500);
		await screenshot(page, '07-chat-conversation.png');

		// Sidebar / workspace peek
		await page.goto(`${BASE}/workspace/models`, { waitUntil: 'networkidle' });
		await page.waitForTimeout(800);
		await screenshot(page, '08-workspace-models.png');
	} finally {
		const video = page.video();
		await page.close();
		if (video) {
			const webmPath = path.join(OUT, 'demo-flow.webm');
			await video.saveAs(webmPath);
			console.log('saved', webmPath);
		}
		await context.close();
		await browser.close();
	}

	console.log('\nDone. Convert video to GIF:');
	console.log(`  ffmpeg -y -i ${OUT}/demo-flow.webm -vf "fps=12,scale=1280:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=128[p];[s1][p]paletteuse=dither=bayer" -loop 0 ${OUT}/demo-flow.gif`);
}

main().catch((err) => {
	console.error(err);
	process.exit(1);
});
