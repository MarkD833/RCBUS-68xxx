
	.title "putchar assembler support for printf"

	.globl	putchar

* ---------------------------------------------------------------------------
* putchar - output a single character to the default serial port
* Simply do a EASy68K TRAP #15 with task ID 6.
*
* int putchar( int c ) - return c in D0
*   - c is on the stack at 4(sp) - always a 32-bit value.
*
putchar:
	movem.l	%d0-%d1,-(%sp)		// save D0 & D1
	move.l	12(%sp),%d1			// get int off the stack
	move.b	#6,%d0
	trap	#15
	movem.l	(%sp)+,%d0-%d1		// restore D0 & D1
	rts
