*------------------------------------------------------------------------------
* ECHO.X68
*------------------------------------------------------------------------------
* Simple program to echo the state of the digital inpuuts on LEDs on an SC129 I/O board.
* The SC129 should have jumpers set for I/O space address $00 (default).
*------------------------------------------------------------------------------

	INCLUDE "..\asm-inc\memory.inc"

*******************************************************************************
* These addresses are as configured on the individual boards in what would be
* the Z80 8-bit I/O space.
*
SC129ADDR   EQU     $00           * SC129 base address is 0x00

*******************************************************************************
* These are the Z80 8-bit I/O space addresses converted into 68000 memory space
*
SC129       EQU     IO_BASE+(SC129ADDR<<1)+1

    ORG     $110000

START:
	move.b	SC129,d0		* read the digital inputs
	nop
	move.b	d0,SC129		* write them to the LEDs
	nop
	bra.s	START

    END    START            * last line of source

