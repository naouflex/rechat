<script lang="ts">
	import { onMount } from 'svelte';
	import {
		BRAND,
		CTA_FINAL,
		CTA_SIGNIN,
		TAGLINE_PRIMARY,
		TAGLINE_PRIMARY_ACCENT,
		TAGLINE_SUPPORTING
	} from '$lib/brand';
	import BrowserChrome from './BrowserChrome.svelte';
	import MarketingFooter from './MarketingFooter.svelte';
	import MarketingNav from './MarketingNav.svelte';
	import { handleSectionClick, scrollToSection } from './scroll';
	import './landing.css';

	export let signedIn = false;

	const headlineBefore = TAGLINE_PRIMARY.replace(` ${TAGLINE_PRIMARY_ACCENT}`, '');

	const STATS = [
		{ value: '50+', label: 'Model providers' },
		{ value: 'RAG', label: 'Knowledge grounding' },
		{ value: '100%', label: 'Self-hosted option' },
		{ value: '24/7', label: 'Your infrastructure' }
	] as const;

	const JOURNEY = [
		{
			step: '1',
			title: 'Deploy on your stack',
			text: 'Run Rechat on a VM, homelab, or cloud with Docker Compose. Point DNS, enable HTTPS, and connect Ollama locally or wire up cloud model APIs.'
		},
		{
			step: '2',
			title: 'Add knowledge & tools',
			text: 'Upload documents for RAG, configure system prompts, and attach OpenAPI tool servers so models can browse files, run code, and call your APIs.'
		},
		{
			step: '3',
			title: 'Chat with your team',
			text: 'Start conversations, share threads, manage models from the workspace, and invite teammates with role-based access, all from one interface.'
		}
	] as const;

	const FEATURES = [
		{
			title: 'Multi-model chat',
			text: 'Switch between Ollama, OpenAI, Anthropic, Google, and dozens more. Compare models side by side without juggling tabs.'
		},
		{
			title: 'Knowledge base & RAG',
			text: 'Upload PDFs, docs, and notes. Ground answers in your data with retrieval-augmented generation and collection-level access control.'
		},
		{
			title: 'Tools & functions',
			text: 'Connect OpenAPI tool servers and custom Python functions so agents can browse the web, execute code, and interact with your systems.'
		},
		{
			title: 'Full workspace',
			text: 'Manage prompts, models, skills, and automations from a dedicated workspace, not just a chat box.'
		},
		{
			title: 'Channels & sharing',
			text: 'Team channels, shared chats, and exportable conversation threads keep everyone aligned without leaving the platform.'
		},
		{
			title: 'Voice & vision',
			text: 'Speech-to-text, text-to-speech, and image understanding when your models support it, all in the same UI.'
		},
		{
			title: 'Self-hosted & private',
			text: 'Your conversations and documents stay on infrastructure you control. No vendor lock-in, no training on your data by default.'
		},
		{
			title: 'Admin & RBAC',
			text: 'Role-based access, user management, analytics, and granular permissions for teams that need more than a single seat.'
		},
		{
			title: 'Automations',
			text: 'Schedule recurring tasks, pipe outputs to webhooks, and build lightweight agent workflows without a separate orchestration layer.'
		}
	] as const;

	const MODELS = [
		{ name: 'Ollama', desc: 'Local LLMs on your GPU or CPU' },
		{ name: 'OpenAI', desc: 'GPT-4o, o-series, and embeddings' },
		{ name: 'Anthropic', desc: 'Claude family via API' },
		{ name: 'Google', desc: 'Gemini and Vertex endpoints' },
		{ name: 'Azure OpenAI', desc: 'Enterprise-hosted models' },
		{ name: 'OpenRouter', desc: 'One key, many providers' }
	] as const;

	const USE_CASES = [
		{
			title: 'Engineering copilot',
			text: 'Attach your codebase docs, API specs, and runbooks. Ask questions, generate PR descriptions, and debug with tool-augmented agents.'
		},
		{
			title: 'Internal knowledge base',
			text: 'Upload HR policies, product specs, and meeting notes. Give every team member a searchable assistant grounded in company data.'
		},
		{
			title: 'Research & analysis',
			text: 'Summarize long documents, compare model outputs, and export structured findings without sending sensitive data to a SaaS.'
		},
		{
			title: 'Customer support assist',
			text: 'Load FAQs and product docs into collections. Draft replies faster while keeping customer context on your own servers.'
		}
	] as const;

	const TRUST = [
		{ icon: 'lock', label: 'Self-hosted' },
		{ icon: 'shield', label: 'Your data stays yours' },
		{ icon: 'code', label: 'Open source core' },
		{ icon: 'bolt', label: 'Local & cloud models' }
	] as const;

	const FAQ = [
		{
			q: 'What is Rechat?',
			a: 'Rechat is a self-hosted AI chat platform built on Open WebUI. It gives you a modern chat interface with support for multiple models, knowledge bases, tools, and team features, all running on your own server.'
		},
		{
			q: 'Do I need a cloud API key?',
			a: 'No. You can run entirely on local models via Ollama. Cloud providers are optional if you want access to frontier models alongside your local stack.'
		},
		{
			q: 'Can I use it with my team?',
			a: 'Yes. Rechat supports multiple users with admin controls, shared channels, and workspace resources like prompts and knowledge collections.'
		},
		{
			q: 'How is my data stored?',
			a: 'Chat history and user data live in your PostgreSQL or SQLite database. Uploaded files stay on your server volume. Nothing is sent to Rechat. You own the stack.'
		},
		{
			q: 'Does it work offline?',
			a: 'With Ollama and local models, core chat works without external API calls. Cloud model features require network access to those providers.'
		},
		{
			q: 'How do I get started?',
			a: 'Sign in or create an account on this instance. The first user becomes admin. If you are deploying your own copy, run the Docker stack and point your browser at your domain.'
		}
	] as const;

	const MOCK_MESSAGES = [
		{ role: 'user', text: 'Summarize our Q3 roadmap doc and flag any risks.' },
		{
			role: 'assistant',
			text: 'Based on your knowledge base: three milestones ship in Q3. The main risk is the API migration timeline. I recommend a buffer week before the beta cut.'
		},
		{ role: 'user', text: 'Draft a Slack update for the eng team.' }
	] as const;

	onMount(() => {
		const hash = window.location.hash.slice(1);
		if (hash) {
			requestAnimationFrame(() => scrollToSection(hash));
		}
	});
</script>

<svelte:head>
	<title>{BRAND} | {TAGLINE_PRIMARY}</title>
	<meta name="description" content={TAGLINE_SUPPORTING} />
	<meta name="theme-color" content="#0a0a0a" />
</svelte:head>

<div class="landing min-h-screen overflow-x-hidden">
	<MarketingNav {signedIn} />

	<main>
		<header class="landing-hero relative overflow-hidden">
			<div class="landing-grid pointer-events-none absolute inset-0" aria-hidden="true"></div>
			<div
				class="landing-glow pointer-events-none absolute left-1/2 top-0 h-[520px] w-[min(900px,100vw)] -translate-x-1/2"
				aria-hidden="true"
			></div>
			<div class="relative mx-auto max-w-6xl px-5 pb-20 pt-14 text-center sm:px-6 sm:pb-28 sm:pt-20">
				<div
					class="landing-fade-up mx-auto inline-flex items-center gap-2 rounded-full border border-[var(--edge)] bg-[var(--panel)] px-4 py-1.5 text-xs font-medium text-[#8a8078]"
				>
					<span class="relative flex h-2 w-2">
						<span
							class="absolute inline-flex h-full w-full animate-ping rounded-full bg-[var(--accent)] opacity-40"
						></span>
						<span class="relative inline-flex h-2 w-2 rounded-full bg-[var(--accent)]"></span>
					</span>
					Self-hosted AI workspace
				</div>

				<h1
					class="landing-fade-up mx-auto mt-7 max-w-4xl text-4xl font-bold leading-[1.08] tracking-tight sm:text-5xl md:text-6xl"
					style="animation-delay: 80ms"
				>
					{headlineBefore}
					<span class="landing-gradient-text">{TAGLINE_PRIMARY_ACCENT}</span>
				</h1>

				<p
					class="landing-fade-up mx-auto mt-5 max-w-2xl text-base leading-relaxed text-[#a89890] sm:text-lg"
					style="animation-delay: 160ms"
				>
					{TAGLINE_SUPPORTING}
				</p>

				<div
					class="landing-fade-up mt-8 flex flex-col items-center justify-center gap-3 sm:flex-row"
					style="animation-delay: 240ms"
				>
					{#if signedIn}
						<a href="/" class="landing-btn-primary">{CTA_FINAL}</a>
					{:else}
						<a href="/auth" class="landing-btn-primary">{CTA_SIGNIN}</a>
						<a
							href="#how-it-works"
							class="landing-btn-ghost"
							on:click={(e) => handleSectionClick(e, 'how-it-works')}
						>
							See how it works
						</a>
					{/if}
				</div>

				<p class="landing-fade-up mt-4 text-xs text-[#6a625c]" style="animation-delay: 280ms">
					Ollama-ready · RAG & tools · No vendor lock-in
				</p>

				<div
					class="landing-fade-up relative mx-auto mt-14 max-w-3xl sm:mt-16"
					style="animation-delay: 320ms"
				>
					<div
						class="landing-mockup-glow pointer-events-none absolute -inset-4 rounded-3xl sm:-inset-8"
						aria-hidden="true"
					></div>
					<div class="relative">
						<BrowserChrome title="rechat · workspace">
							<div class="bg-[var(--surface)] p-4 sm:p-5">
								<div
									class="mb-3 flex items-center justify-between border-b border-[var(--edge)] pb-3"
								>
									<div class="flex items-center gap-2 text-sm font-semibold text-[#e8e0d8]">
										<span class="h-2 w-2 rounded-full bg-[var(--accent)]"></span>
										Q3 roadmap review
									</div>
									<span class="text-xs text-[#8a8078]">llama3.2 · RAG on</span>
								</div>
								<div class="space-y-3 text-sm">
									{#each MOCK_MESSAGES as msg}
										<div class="flex {msg.role === 'user' ? 'justify-end' : 'justify-start'}">
											<div
												class="max-w-[85%] rounded-xl px-3 py-2 {msg.role === 'user'
													? 'bg-[var(--accent)]/15 text-[#f0ebe6] ring-1 ring-[var(--accent)]/25'
													: 'border border-[var(--edge)] bg-[var(--panel)] text-[#c4bab2]'}"
											>
												{msg.text}
											</div>
										</div>
									{/each}
									<div
										class="flex items-center gap-2 rounded-lg border border-[var(--edge)] bg-[var(--panel)] px-3 py-2 text-[#8a8078]"
									>
										<span class="inline-flex gap-1">
											<span
												class="h-1.5 w-1.5 animate-bounce rounded-full bg-[var(--accent-mid)] [animation-delay:0ms]"
											></span>
											<span
												class="h-1.5 w-1.5 animate-bounce rounded-full bg-[var(--accent-mid)] [animation-delay:150ms]"
											></span>
											<span
												class="h-1.5 w-1.5 animate-bounce rounded-full bg-[var(--accent-mid)] [animation-delay:300ms]"
											></span>
										</span>
										<span class="text-xs">Thinking…</span>
									</div>
								</div>
							</div>
						</BrowserChrome>
					</div>
				</div>
			</div>
		</header>

		<div class="border-y border-[var(--edge)]">
			<div class="mx-auto grid max-w-6xl grid-cols-2 gap-px bg-[var(--edge)] sm:grid-cols-4">
				{#each TRUST as { icon, label }}
					<div
						class="flex items-center justify-center gap-2.5 bg-[var(--surface)] px-4 py-4 text-sm text-[#a89890]"
					>
						{#if icon === 'lock'}
							<svg
								class="h-4 w-4 shrink-0 text-[var(--accent)]"
								viewBox="0 0 24 24"
								fill="none"
								stroke="currentColor"
								stroke-width="2"
								><rect x="3" y="11" width="18" height="11" rx="2" /><path
									d="M7 11V7a5 5 0 0 1 10 0v4"
								/></svg
							>
						{:else if icon === 'shield'}
							<svg
								class="h-4 w-4 shrink-0 text-[var(--accent)]"
								viewBox="0 0 24 24"
								fill="none"
								stroke="currentColor"
								stroke-width="2"
								><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" /></svg
							>
						{:else if icon === 'code'}
							<svg
								class="h-4 w-4 shrink-0 text-[var(--accent)]"
								viewBox="0 0 24 24"
								fill="none"
								stroke="currentColor"
								stroke-width="2"
								><polyline points="16 18 22 12 16 6" /><polyline points="8 6 2 12 8 18" /></svg
							>
						{:else}
							<svg
								class="h-4 w-4 shrink-0 text-[var(--accent)]"
								viewBox="0 0 24 24"
								fill="none"
								stroke="currentColor"
								stroke-width="2"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z" /></svg
							>
						{/if}
						<span>{label}</span>
					</div>
				{/each}
			</div>
		</div>

		<section class="border-b border-[var(--edge)] bg-[var(--panel)]/40">
			<div class="mx-auto grid max-w-6xl grid-cols-2 gap-8 px-5 py-14 sm:grid-cols-4 sm:px-6">
				{#each STATS as { value, label }}
					<div class="text-center">
						<div class="landing-stat-value text-3xl font-bold sm:text-4xl">{value}</div>
						<div class="mt-1 text-sm text-[#8a8078]">{label}</div>
					</div>
				{/each}
			</div>
		</section>

		<section id="how-it-works" class="mx-auto max-w-6xl px-5 py-20 sm:px-6 sm:py-28">
			<div class="mx-auto max-w-2xl text-center">
				<p class="text-xs font-semibold uppercase tracking-widest text-[var(--accent)]">
					How it works
				</p>
				<h2 class="mt-3 text-3xl font-bold tracking-tight sm:text-4xl">
					From deploy to productive chat in three steps
				</h2>
				<p class="mt-3 text-[#a89890]">
					Spin up your instance, connect models and knowledge, then start chatting with your team.
				</p>
			</div>
			<div class="mt-14 grid gap-6 md:grid-cols-3 md:gap-8">
				{#each JOURNEY as { step, title, text }}
					<div
						class="relative rounded-2xl border border-[var(--edge)] bg-[var(--panel)] p-6 transition hover:border-[var(--accent)]/30"
					>
						<span class="font-mono text-xs font-medium text-[var(--accent)]">Step {step}</span>
						<h3 class="mt-3 text-lg font-semibold">{title}</h3>
						<p class="mt-2 text-sm leading-relaxed text-[#a89890]">{text}</p>
					</div>
				{/each}
			</div>
		</section>

		<section id="features" class="border-t border-[var(--edge)] bg-[var(--panel)]/20">
			<div class="mx-auto max-w-6xl px-5 py-20 sm:px-6 sm:py-28">
				<div class="mx-auto max-w-2xl text-center">
					<p class="text-xs font-semibold uppercase tracking-widest text-[var(--accent)]">
						Features
					</p>
					<h2 class="mt-3 text-3xl font-bold tracking-tight sm:text-4xl">
						Everything a modern AI workspace needs
					</h2>
					<p class="mt-3 text-[#a89890]">
						Models, RAG, tools, workspace management, and team features without sending data to a
						black box.
					</p>
				</div>
				<div class="mt-14 grid gap-4 sm:grid-cols-2 lg:grid-cols-3 lg:gap-5">
					{#each FEATURES as { title, text }}
						<div
							class="rounded-2xl border border-[var(--edge)] bg-[var(--panel)] p-6 transition hover:border-[var(--accent)]/25 hover:bg-[var(--panel-2)]"
						>
							<div
								class="mb-4 flex h-10 w-10 items-center justify-center rounded-xl border border-[var(--edge)] bg-[var(--panel-2)] text-[var(--accent)]"
							>
								<svg
									class="h-5 w-5"
									viewBox="0 0 24 24"
									fill="none"
									stroke="currentColor"
									stroke-width="1.75"
								>
									<circle cx="12" cy="12" r="4" />
									<path
										d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41"
									/>
								</svg>
							</div>
							<h3 class="font-semibold">{title}</h3>
							<p class="mt-2 text-sm leading-relaxed text-[#a89890]">{text}</p>
						</div>
					{/each}
				</div>
			</div>
		</section>

		<section id="models" class="border-t border-[var(--edge)]">
			<div class="mx-auto max-w-6xl px-5 py-20 sm:px-6 sm:py-28">
				<div class="mx-auto max-w-2xl text-center">
					<p class="text-xs font-semibold uppercase tracking-widest text-[var(--accent)]">
						Models
					</p>
					<h2 class="mt-3 text-3xl font-bold tracking-tight sm:text-4xl">
						One interface, every provider
					</h2>
					<p class="mt-3 text-[#a89890]">
						Run local models with Ollama or plug in cloud APIs. Mix and match per conversation.
					</p>
				</div>
				<div class="mt-14 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
					{#each MODELS as { name, desc }}
						<div
							class="flex items-start gap-4 rounded-2xl border border-[var(--edge)] bg-[var(--panel)] p-5"
						>
							<div
								class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-gradient-to-br from-[var(--accent)] to-[var(--accent-muted)] text-sm font-bold text-[#0a0a0a]"
							>
								{name.slice(0, 1)}
							</div>
							<div>
								<h3 class="font-semibold">{name}</h3>
								<p class="mt-1 text-sm text-[#8a8078]">{desc}</p>
							</div>
						</div>
					{/each}
				</div>
			</div>
		</section>

		<section id="use-cases" class="border-t border-[var(--edge)] bg-[var(--panel)]/20">
			<div class="mx-auto max-w-6xl px-5 py-20 sm:px-6 sm:py-28">
				<div class="mx-auto max-w-2xl text-center">
					<p class="text-xs font-semibold uppercase tracking-widest text-[var(--accent)]">
						Use cases
					</p>
					<h2 class="mt-3 text-3xl font-bold tracking-tight sm:text-4xl">
						Built for real work, not just demos
					</h2>
					<p class="mt-3 text-[#a89890]">
						Teams use Rechat for engineering, research, support, and internal knowledge, all on
						their own terms.
					</p>
				</div>
				<div class="mt-14 grid gap-6 md:grid-cols-2">
					{#each USE_CASES as { title, text }}
						<div
							class="rounded-2xl border border-[var(--edge)] bg-[var(--panel)] p-8 transition hover:border-[var(--accent)]/25"
						>
							<h3 class="text-xl font-semibold">{title}</h3>
							<p class="mt-3 text-sm leading-relaxed text-[#a89890]">{text}</p>
						</div>
					{/each}
				</div>
			</div>
		</section>

		<section id="faq" class="border-t border-[var(--edge)]">
			<div class="mx-auto max-w-3xl px-5 py-20 sm:px-6 sm:py-28">
				<div class="mx-auto max-w-2xl text-center">
					<p class="text-xs font-semibold uppercase tracking-widest text-[var(--accent)]">FAQ</p>
					<h2 class="mt-3 text-3xl font-bold tracking-tight sm:text-4xl">Common questions</h2>
				</div>
				<dl class="mt-12 space-y-4">
					{#each FAQ as { q, a }}
						<div
							class="rounded-2xl border border-[var(--edge)] bg-[var(--panel)] p-6 transition hover:border-[var(--accent)]/20"
						>
							<dt class="font-semibold text-[var(--text)]">{q}</dt>
							<dd class="mt-2 text-sm leading-relaxed text-[#a89890]">{a}</dd>
						</div>
					{/each}
				</dl>
			</div>
		</section>

		<section class="relative overflow-hidden border-t border-[var(--edge)]">
			<div class="landing-cta-glow pointer-events-none absolute inset-0" aria-hidden="true"></div>
			<div class="relative mx-auto max-w-3xl px-5 py-24 text-center sm:px-6 sm:py-32">
				<h2 class="text-3xl font-bold tracking-tight sm:text-4xl">Ready to chat on your terms?</h2>
				<p class="mx-auto mt-4 max-w-xl text-[#a89890]">
					Sign in to this instance and start a conversation, or deploy your own copy and own the
					full stack.
				</p>
				<div class="mt-8 flex flex-col items-center justify-center gap-3 sm:flex-row">
					<a href={signedIn ? '/' : '/auth'} class="landing-btn-primary">
						{signedIn ? CTA_FINAL : CTA_SIGNIN}
					</a>
					<a
						href="#features"
						class="landing-btn-ghost"
						on:click={(e) => handleSectionClick(e, 'features')}
					>
						Explore features
					</a>
				</div>
			</div>
		</section>
	</main>

	<MarketingFooter />
</div>
