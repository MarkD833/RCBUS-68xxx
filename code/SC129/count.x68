*------------------------------------------------------------------------------
* COUNT.X68
*------------------------------------------------------------------------------
* Simple up counter on LEDs on an SC129 I/O board.
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
	clr.l	d0
.loop3:	
	move.l	#$01,d2	
.loop2:
	move.l	#$FFFF,d1
.loop1:
	nop
	dbra	d1,.loop1
	dbra	d2,.loop2

	add.b	#1,d0
	move.b	d0,SC129
	bra.s	.loop3

    END    START            * last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
