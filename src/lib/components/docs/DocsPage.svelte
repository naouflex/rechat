<script lang="ts">
	import { marked } from 'marked';
	import DOMPurify from 'dompurify';
	import { BRAND } from '$lib/brand';
	import MarketingNav from '$lib/components/landing/MarketingNav.svelte';
	import { DOC_PAGES, docHref } from '$lib/docs/pages';
	import '$lib/components/landing/landing.css';

	export let title = 'Documentation';
	export let html = '';

	$: safeHtml = DOMPurify.sanitize(
		marked.parse(html, { gfm: true, breaks: false }) as string,
		{ ADD_ATTR: ['target', 'rel'] }
	);
</script>

<div class="landing min-h-screen">
	<MarketingNav signedIn={false} />

	<div class="mx-auto flex max-w-6xl gap-10 px-5 py-10 sm:px-6 lg:py-14">
		<aside class="hidden w-52 shrink-0 lg:block">
			<p class="mb-4 text-xs font-semibold uppercase tracking-widest text-[var(--accent)]">
				Documentation
			</p>
			<nav class="sticky top-20 space-y-1">
				{#each DOC_PAGES as page}
					<a
						href={docHref(page.slug)}
						class="block rounded-lg px-3 py-2 text-sm transition {title === page.title
							? 'bg-[var(--panel)] text-[var(--accent)]'
							: 'text-[#a89890] hover:bg-[var(--panel)] hover:text-[var(--text)]'}"
					>
						{page.title === 'Home' ? BRAND : page.title}
					</a>
				{/each}
			</nav>
			<p class="mt-8 text-xs leading-relaxed text-[#6a625c]">
				Based on
				<a
					href="https://docs.openwebui.com/"
					target="_blank"
					rel="noopener noreferrer"
					class="text-[#8a8078] hover:text-[var(--accent)]"
				>
					Open WebUI docs
				</a>
				. Rechat is a fork.
			</p>
		</aside>

		<article class="docs-prose min-w-0 flex-1 pb-16">
			<div class="docs-body">{@html safeHtml}</div>
		</article>
	</div>
</div>

<style>
	:global(.docs-prose .docs-body) {
		color: #c4bab2;
		line-height: 1.7;
	}

	:global(.docs-prose .docs-body h1) {
		font-size: 2rem;
		font-weight: 700;
		color: var(--text);
		margin-bottom: 1rem;
	}

	:global(.docs-prose .docs-body h2) {
		font-size: 1.35rem;
		font-weight: 600;
		color: var(--text);
		margin-top: 2.5rem;
		margin-bottom: 0.75rem;
		padding-bottom: 0.35rem;
		border-bottom: 1px solid var(--edge);
	}

	:global(.docs-prose .docs-body h3) {
		font-size: 1.05rem;
		font-weight: 600;
		color: var(--text);
		margin-top: 1.75rem;
		margin-bottom: 0.5rem;
	}

	:global(.docs-prose .docs-body p) {
		margin-bottom: 1rem;
	}

	:global(.docs-prose .docs-body a) {
		color: var(--accent);
		text-decoration: underline;
		text-underline-offset: 2px;
	}

	:global(.docs-prose .docs-body ul),
	:global(.docs-prose .docs-body ol) {
		margin-bottom: 1rem;
		padding-left: 1.25rem;
	}

	:global(.docs-prose .docs-body li) {
		margin-bottom: 0.35rem;
	}

	:global(.docs-prose .docs-body blockquote) {
		border-left: 3px solid var(--accent-mid);
		padding-left: 1rem;
		margin: 1.25rem 0;
		color: #a89890;
	}

	:global(.docs-prose .docs-body code) {
		font-size: 0.875em;
		background: var(--panel);
		padding: 0.15rem 0.4rem;
		border-radius: 0.25rem;
	}

	:global(.docs-prose .docs-body pre) {
		background: var(--panel);
		border: 1px solid var(--edge);
		border-radius: 0.75rem;
		padding: 1rem;
		overflow-x: auto;
		margin-bottom: 1rem;
	}

	:global(.docs-prose .docs-body pre code) {
		background: none;
		padding: 0;
	}

	:global(.docs-prose .docs-body table) {
		width: 100%;
		border-collapse: collapse;
		margin-bottom: 1.25rem;
		font-size: 0.875rem;
	}

	:global(.docs-prose .docs-body th),
	:global(.docs-prose .docs-body td) {
		border: 1px solid var(--edge);
		padding: 0.5rem 0.75rem;
		text-align: left;
	}

	:global(.docs-prose .docs-body th) {
		background: var(--panel);
		color: var(--text);
	}

	:global(.docs-prose .docs-body hr) {
		border: none;
		border-top: 1px solid var(--edge);
		margin: 2rem 0;
	}
</style>
