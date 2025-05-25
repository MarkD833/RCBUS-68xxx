/*
 * This is the modified linker script to support an application type project on
 * my RCBus 68000 hardware.
 *
 * The RAM exception vector table lives at the start of RAM.
 * The monitor has 2K of RAM at the top of memory for its private variables.
 *
 *   base indicates at what address a memory begins
 *   sz indicates the size of that memory
 *
 * Values can be specified in decimal, hexadecimal, or as units such
 * as 1K or 1M.
 */
_rom_base = 0;
_rom_sz = 128K;
_ram_base = 0x100000;
_ram_sz = 1M;
_vec_base = _ram_base;
_vec_sz = 1K;
_mon_sz = 2K;

/*
 * Dont modify below this line (unless you know what youre doing),
 * except to add user interrupt vectors.
 */

STARTUP(crt0.o)
OUTPUT_ARCH(m68k)

__rom_end = (_rom_base + _rom_sz);
__ram_end = (_ram_base + _ram_sz - _mon_sz);

__ram_start = (_ram_base + _vec_sz);
__data_sz = (_ram_sz - _vec_sz - _mon_sz);



__text_sz = _rom_sz;
__data_start = _ram_base;

MEMORY {
    ram  (rwx!a) : ORIGIN = __ram_start, LENGTH = __data_sz
}

SECTIONS {
    /* code */
    .text : {
        _text_start = .;
        *(.text .text.*)
        . = ALIGN(0x10);
        _text_end = .;
    } > ram

    /* constants */
    .rodata : AT(_text_end) {
        _rodata_start = .;
        *(.rodata .rodata.*)
        . = ALIGN(0x10);
        _rodata_end = .;
    } > ram

    /* initial values of variables */
    .data : AT(_rodata_end) {
        _data_start = .;
        *(.data .data.*)
        . = ALIGN(0x10);
        _data_end = .;
    } > ram

    /* variables initialised to zero */
    .bss : {
        _bss_start = .;
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(0x10);
        _bss_end = .;
    } > ram
}
