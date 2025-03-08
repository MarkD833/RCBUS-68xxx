*------------------------------------------------------------------------------
* ECHO.X68
*------------------------------------------------------------------------------
* Simple program to echo the state of the digital inpuuts on LEDs on an SC129 I/O board.
* The SC129 should have jumpers set for I/O space address $00 (default).
*------------------------------------------------------------------------------

*******************************************************************************
* Defines
*
IO_BASE			EQU		$F00000		* I/O space base addr = 00F0_0000
SC129			EQU		IO_BASE+1

    ORG     $110000

START:
	move.b	SC129,d0		* read the digital inputs
	nop
	move.b	d0,SC129		* write them to the LEDs
	nop
	bra.s	START

    END    START            * last line of source

