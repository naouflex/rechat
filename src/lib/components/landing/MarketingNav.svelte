<script lang="ts">
	import { BRAND } from '$lib/brand';
	import { handleSectionClick } from './scroll';

	export let signedIn = false;

	let open = false;

	const NAV_LINKS = [
		{ id: 'how-it-works', label: 'How it works' },
		{ id: 'features', label: 'Features' },
		{ id: 'models', label: 'Models' },
		{ id: 'use-cases', label: 'Use cases' },
		{ id: 'faq', label: 'FAQ' }
	] as const;

	const closeMenu = () => {
		open = false;
	};
</script>

<nav class="sticky top-0 z-50 border-b border-[var(--edge)] bg-[var(--surface)]/85 backdrop-blur-xl">
	<div class="mx-auto flex max-w-6xl items-center justify-between gap-4 px-5 py-3.5 sm:px-6">
		<a href="/" class="flex items-center gap-2.5">
			<img src="/static/favicon.png" alt={BRAND} class="h-8 w-8 object-contain" />
			<span class="text-[15px] font-semibold text-[var(--text)]">{BRAND}</span>
		</a>

		<div class="hidden items-center gap-6 lg:flex">
			{#each NAV_LINKS as { id, label }}
				<a
					href="#{id}"
					class="text-sm text-[#a89890] transition hover:text-[var(--accent)]"
					on:click={(e) => handleSectionClick(e, id, closeMenu)}
				>
					{label}
				</a>
			{/each}
		</div>

		<div class="flex items-center gap-2 sm:gap-3">
			<a href={signedIn ? '/' : '/auth'} class="landing-btn-primary hidden sm:inline-flex">
				{signedIn ? 'Open app' : 'Sign in'}
			</a>
			<button
				type="button"
				class="rounded-lg border border-[var(--edge)] p-2 text-[#a89890] lg:hidden"
				aria-label="Open menu"
				on:click={() => (open = !open)}
			>
				<svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
					{#if open}
						<path d="M6 6l12 12M18 6 6 18" stroke-linecap="round" />
					{:else}
						<path d="M4 7h16M4 12h16M4 17h16" stroke-linecap="round" />
					{/if}
				</svg>
			</button>
		</div>
	</div>

	{#if open}
		<div class="border-t border-[var(--edge)] bg-[var(--panel)] px-5 py-4 lg:hidden">
			<div class="flex flex-col gap-3">
				{#each NAV_LINKS as { id, label }}
					<a
						href="#{id}"
						class="text-sm text-[#d4ccc4]"
						on:click={(e) => handleSectionClick(e, id, closeMenu)}
					>
						{label}
					</a>
				{/each}
				<a href={signedIn ? '/' : '/auth'} class="landing-btn-primary w-full justify-center">
					{signedIn ? 'Open app' : 'Sign in'}
				</a>
			</div>
		</div>
	{/if}
</nav>
