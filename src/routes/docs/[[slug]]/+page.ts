import type { PageLoad } from './$types';
import { getDocPage } from '$lib/docs/pages';
import { error } from '@sveltejs/kit';

export const load: PageLoad = ({ params }) => {
	const slug = params.slug ?? '';
	const page = getDocPage(slug);
	if (!page) {
		throw error(404, 'Documentation page not found');
	}
	return { slug };
};
