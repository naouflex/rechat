/** Smooth-scroll to a landing section without triggering SvelteKit navigation. */
export function scrollToSection(id: string, onDone?: () => void) {
	const el = document.getElementById(id);
	if (!el) return false;
	el.scrollIntoView({ behavior: 'smooth', block: 'start' });
	history.replaceState(history.state, '', `#${id}`);
	onDone?.();
	return true;
}

export function handleSectionClick(e: MouseEvent, id: string, onDone?: () => void) {
	e.preventDefault();
	scrollToSection(id, onDone);
}
