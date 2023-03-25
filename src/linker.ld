ENTRY(_start)

SECTIONS {
	/* ensure that the multiboot header is at the beginning */
	.multiboot :
	{
		/* KEEP otherwise it gets garbage collected by linker */
		*(.multiboot)
		. = ALIGN(2K);
	}

	.text :
	{
		*(.text .text.*)
		. = ALIGN(4K);
	}

	.rodata :
	{
		*(.rodata .rodata.*)
		. = ALIGN(4K);
	}

	.data :
	{
		*(.data.rel.ro.local*) *(.data.rel.ro .data.rel.ro.*) *(.data.*)
		. = ALIGN(4K);
	}

	.gdt :
	{
		*(.gdt)
		. = ALIGN(4K);
	}

	.bss :
	{
		*(.bss .bss.*)
		. = ALIGN(4K);
	}
}