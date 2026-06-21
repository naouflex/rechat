export type DocPage = {
	slug: string;
	title: string;
	description: string;
	order: number;
};

export const DOC_PAGES: DocPage[] = [
	{
		slug: '',
		title: 'Home',
		description: 'Overview of Rechat, a self-hosted AI workspace.',
		order: 0
	},
	{
		slug: 'getting-started',
		title: 'Getting Started',
		description: 'Install, connect a model provider, and start chatting.',
		order: 1
	},
	{
		slug: 'features',
		title: 'Features',
		description: 'Chat, knowledge bases, models, channels, and more.',
		order: 2
	},
	{
		slug: 'troubleshooting',
		title: 'Troubleshooting',
		description: 'Fix common connection, context, and deploy issues.',
		order: 3
	},
	{
		slug: 'tutorials',
		title: 'Tutorials',
		description: 'Step-by-step guides for SSO, integrations, and maintenance.',
		order: 4
	},
	{
		slug: 'faq',
		title: 'FAQ',
		description: 'Frequently asked questions.',
		order: 5
	}
];

export function docHref(slug: string): string {
	return slug ? `/docs/${slug}` : '/docs';
}

export function getDocPage(slug: string): DocPage | undefined {
	return DOC_PAGES.find((p) => p.slug === slug);
}
