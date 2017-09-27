ENTRY(start)
OUTPUT_FORMAT(binary)

SECTIONS
{
	. = 0x000;
	.text : { *(.text) }
	.bss : { *(.bss) }
}
