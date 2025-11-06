/* Based on the linker script for the M68332BCC Business Card Computer in Newlib
 *
 * Beyond here be more dragons ...
 * This script is a bit of a frankenstein mess and I don't know enough about GNU C++
 * to know what sections are really needed.
 *
 */
OUTPUT_ARCH(m68k)
STARTUP(../../crt/crt0.o)
ENTRY(__start)
/* Uncomment this if you want srecords. This is needed for a.out
 * if you plan to use GDB.
OUTPUT_FORMAT(srec)
 */
SEARCH_DIR(.)
/* GROUP(-lbcc -lc -lgcc)
*/
__DYNAMIC  =  0;

/*
 * Setup the memory map of the M68000 RCBus Processor Card.
 * There is a 4K block at the top of RAM that the monitor can use so set the RAM
 * length to 1Mb - 4Kb
 *
 * NOTE: On the 68000, the stack grows down from high memory.
 *
 * The memory map looks like this:
 * +--------------------+ <- low memory
 * | .text              |
 * |        _etext      |
 * +--------------------+
 * | .init_array        | the constructors for C++
 * |        __sinit     | are here
 * |        __einit     |
 * +--------------------+
 * | .data              | initialized data goes here
 * |        _edata      |
 * +--------------------+
 * | .bss               |
 * |        __bss_start | start of bss, cleared by crt0
 * |        _end        | start of heap, used by sbrk()
 * +--------------------+
 * | .heap              |
 * |        _sheap      |
 * |        _eheap      |
 * +--------------------+
 * .                    .
 * .                    .
 * .                    .
 * |        __stack     | top of stack
 * +--------------------+
 */

MEMORY
{
  ram (rwx) : ORIGIN = 0x100400, LENGTH = 1M - 4096
}

/*
 * set the stack to be at the top of user memory, since the stack
 * grows down
 */
__stack_origin = ORIGIN(ram) + LENGTH(ram);

/* Define a heap size - how does 8Kb sound? !!! */
__HEAP_SIZE = 8K;

/*
 * stick everything in ram (of course)
 */
SECTIONS
{
  .text :
  {
    . = ALIGN(4);
    *(.text .text.*)

    . = ALIGN(4);
    *(.rodata .rodata.*)
    *(.gcc_except_table) 

    . = ALIGN(4);
    KEEP(*(.init))
    . = ALIGN(4);
    __preinit_array_start = .;
    KEEP (*(.preinit_array))
    __preinit_array_end = .;

    _etext = .;
    *(.lit)
  } > ram

  .ctors :
  {
    . = ALIGN(4);
    __ctors_start = .;
    *(.ctors)
    __ctors_end = .;
  } > ram

  .data :
  {
    . = ALIGN(4);
    *(.got.plt) *(.got)
    *(.shdata)
    *(.data .data.*)
    _edata = .;
  } > ram

  .bss :
  {
    . = ALIGN(0x4);
    __bss_start = . ;
    *(.shbss)
    *(.bss .bss.*)
    *(COMMON)
    _end =  ALIGN (0x8);
    __end = _end;
  } > ram

  /* heap section */
  .heap (NOLOAD):
  {
    . = ALIGN(8);
     _sheap = .;
    . = . + __HEAP_SIZE;
    . = ALIGN(8);
    _eheap = .;
  } > ram

  .stab 0 (NOLOAD) :
  {
    *(.stab)
  }

  .stabstr 0 (NOLOAD) :
  {
    *(.stabstr)
  }
}
