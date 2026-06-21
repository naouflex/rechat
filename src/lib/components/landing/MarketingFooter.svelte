<script lang="ts">
	import { BRAND } from '$lib/brand';
	import { handleSectionClick } from './scroll';

	const SECTION_LINKS = [
		{ id: 'how-it-works', label: 'How it works' },
		{ id: 'features', label: 'Features' },
		{ id: 'models', label: 'Models' },
		{ id: 'use-cases', label: 'Use cases' },
		{ id: 'faq', label: 'FAQ' }
	] as const;

	const FOOTER_SECTIONS = [
		{
			title: 'Product',
			links: SECTION_LINKS.map(({ id, label }) => ({ type: 'section' as const, id, label }))
		},
		{
			title: 'Workspace',
			links: [
				{ type: 'href' as const, href: '/auth', label: 'Chat' },
				{ type: 'href' as const, href: '/auth', label: 'Knowledge base' },
				{ type: 'href' as const, href: '/auth', label: 'Prompts & tools' }
			]
		},
		{
			title: 'Resources',
			links: [
				{ type: 'href' as const, href: '/docs', label: 'Documentation' },
				{
					type: 'href' as const,
					href: 'https://github.com/open-webui/open-webui',
					label: 'Upstream (Open WebUI)',
					external: true
				},
				{ type: 'href' as const, href: 'https://ollama.com', label: 'Ollama', external: true }
			]
		},
		{
			title: 'Get started',
			links: [
				{ type: 'href' as const, href: '/auth', label: 'Create account' },
				{ type: 'href' as const, href: '/auth', label: 'Sign in' }
			]
		}
	] as const;
</script>

<footer class="border-t border-[var(--edge)] bg-[var(--surface)]">
	<div class="mx-auto max-w-6xl px-5 py-14 sm:px-6">
		<div class="grid gap-10 md:grid-cols-[1.4fr_3fr] md:gap-12">
			<div class="max-w-xs">
				<a href="/" class="flex items-center gap-2.5">
					<img src="/static/favicon.png" alt={BRAND} class="h-8 w-8 object-contain" />
					<span class="text-base font-semibold text-[var(--text)]">{BRAND}</span>
				</a>
				<p class="mt-4 text-sm leading-relaxed text-[#8a8078]">
					Self-hosted AI chat with models, knowledge, tools, and a full workspace on your
					infrastructure.
				</p>
			</div>
			<div class="grid grid-cols-2 gap-x-8 gap-y-10 sm:grid-cols-4">
				{#each FOOTER_SECTIONS as section}
					<div>
						<h3 class="text-xs font-semibold uppercase tracking-widest text-[#c4bab2]">
							{section.title}
						</h3>
						<ul class="mt-4 space-y-3">
							{#each section.links as link}
								<li>
									{#if link.type === 'section'}
										<a
											href="#{link.id}"
											class="text-sm text-[#8a8078] transition hover:text-[var(--accent)]"
											on:click={(e) => handleSectionClick(e, link.id)}
										>
											{link.label}
										</a>
									{:else}
										<a
											href={link.href}
											{...(link.external
												? { target: '_blank', rel: 'noopener noreferrer' }
												: {})}
											class="text-sm text-[#8a8078] transition hover:text-[var(--accent)]"
										>
											{link.label}
										</a>
									{/if}
								</li>
							{/each}
						</ul>
					</div>
				{/each}
			</div>
		</div>
	</div>
	<div class="border-t border-[var(--edge)]/60">
		<div
			class="mx-auto flex max-w-6xl flex-col gap-2 px-5 py-6 sm:flex-row sm:items-center sm:justify-between sm:px-6"
		>
			<p class="text-xs text-[#6a625c]">© {new Date().getFullYear()} {BRAND}</p>
			<p class="text-xs text-[#6a625c]">
				Powered by{' '}
				<a
					href="https://github.com/open-webui/open-webui"
					target="_blank"
					rel="noopener noreferrer"
					class="text-[#8a8078] hover:text-[var(--accent)]"
				>
					Open WebUI
				</a>
			</p>
		</div>
	</div>
</footer>
