<script lang="ts">
	export let title = 'rechat · chat';
</script>

<div class="overflow-hidden rounded-xl border border-[var(--edge)] bg-[var(--panel)] shadow-2xl sm:rounded-2xl">
	<div class="flex items-center gap-2 border-b border-[var(--edge)] bg-[var(--panel-2)] px-4 py-2.5">
		<span class="h-2.5 w-2.5 rounded-full bg-[#ff5f57]"></span>
		<span class="h-2.5 w-2.5 rounded-full bg-[#febc2e]"></span>
		<span class="h-2.5 w-2.5 rounded-full bg-[#28c840]"></span>
		<div class="ml-2 flex flex-1 justify-center">
			<span class="rounded-md bg-[var(--surface)]/80 px-3 py-0.5 font-mono text-[10px] text-slate-500">
				{title}
			</span>
		</div>
	</div>
	<slot />
</div>
