ENTRY(_start)
SECTIONS
{
    .text 0 : { *(.text) }
    .ramtext 0x08000000 : AT(0x400) {
        *(.ramtext)
        . = ALIGN(4);
    }
    __ram_load = LOADADDR(.ramtext);
    __ram_end = ADDR(.ramtext) + SIZEOF(.ramtext);
    ASSERT(SIZEOF(.text) <= 0x400, "ROM code overlaps RAM payload image")
    ASSERT(SIZEOF(.ramtext) <= 0x1000, "RAM code overlaps test data")
}
