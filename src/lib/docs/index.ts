import home from './content/home.md?raw';
import gettingStarted from './content/getting-started.md?raw';
import features from './content/features.md?raw';
import troubleshooting from './content/troubleshooting.md?raw';
import tutorials from './content/tutorials.md?raw';
import faq from './content/faq.md?raw';

const CONTENT: Record<string, string> = {
	'': home,
	'getting-started': gettingStarted,
	features,
	troubleshooting,
	tutorials,
	faq
};

export function getDocContent(slug: string): string | undefined {
	return CONTENT[slug];
}
