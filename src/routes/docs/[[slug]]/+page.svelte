<script lang="ts">
	import DocsPage from '$lib/components/docs/DocsPage.svelte';
	import { getDocContent } from '$lib/docs';
	import { getDocPage } from '$lib/docs/pages';
	import { error } from '@sveltejs/kit';

	export let data: { slug: string };

	const page = getDocPage(data.slug);
	if (!page) {
		throw error(404, 'Documentation page not found');
	}

	const html = getDocContent(data.slug);
	if (!html) {
		throw error(404, 'Documentation page not found');
	}
</script>

<svelte:head>
	<title>{page.title} · Rechat Docs</title>
	<meta name="description" content={page.description} />
</svelte:head>

<DocsPage title={page.title} {html} />
