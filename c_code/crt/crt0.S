/*
 * crt0.S -- startup file for my RCBus 68000 board
 *
 *         ---+++ Beyond here be dragons +++---
 *
 * NOTE: This startup code passes through GCC before being assembled.
 *
 * My startup code has been developed based on earlier trial and error experiments. It is
 * fairly simple in what it does:
 *
 *  1. Initialise the stack pointer
 *  2. Zero out the bss section
 *  3. Run the C++ constructors
 *  4. Enable interrupts
 *  5. Call main()
 *  6. Print a message if main() returns
 *
 * There's no C++ destructor stuff as we won't be returning to the ROM monitor.
 */

	.title "crt0.S for RCBus MC68000"

 	.align	4
	.text

/*
 * The main application is defined in our C code.
 */
	.extern main

/* 
 * These values are set in the linker script.
 */
	.extern __stack_origin
	.extern __bss_start
	.extern _end
    .extern __sinit
    .extern __einit

/*
 * This is the entry point into the application. It needs to be called
 * __start because the linker script references it with the ENTRY() command.
 */
	.global __start

__start:
/* (1) See if user supplied their own stack (__stack != 0).  If not, then
 * assume the ROM monitor set it up and leave it alone.
 */
	move.l	#__stack_origin, %a0
	cmp.l	#0, %a0
	jbeq    1f
	move.l	%a0, %sp
1:
	/* set up initial stack frame */
	link	%a6, #-8

/*
 * (2) zero out the bss section.
 */
	move.l	#__bss_start, %d1
	move.l	#_end, %d0
	cmp.l	%d0, %d1
	jbeq	3f

	move.l	%d1, %a0
	sub.l	%d1, %d0
	subq.l	#1, %d0
2:
	clr.b	(%a0)+
	dbra	%d0, 2b
	clr.w	%d0
	subq.l	#1, %d0
	jbcc	2b
3:

/*
 * (3) handle the various c++ constructors.
 * __ctors_start is the start address of the constructors and __ctors_end is the
 * end address. If __ctors_start = __ctors_end then there are no constructors or
 * this is a C program.
 *
 * __ctors_start holds the address of the code created by the compiler
 * that will initialise all the c++ constructors.
 */
    nop
    move.l  #__ctors_start,%d0
    move.l  #__ctors_end,%d1
    cmp.l   %d0,%d1
    jbeq    4f
    move.l  %d0,%a0
    movea.l (%a0),%a1
    jsr     (%a1)

/*
 * (4) enable interrupts
 */
    move.w  #0x2000,%sr
/*
 * (5) call the main routine from the application to get it going.
 */
4:
	bsr 	main
	move.l	%d0, -(%sp)

/*
 * (6) main() has returned so simply print a message and enter an endless loop
*/
    move.l  #14,%d0
    lea     progEndMsg,%a1
    trap    #15
6:
    jmp 6b

    .data

progEndMsg:
    .dc.b  10,13,10,13
    .ascii "Returned from main(). Press RESET to return to monitor"
    .dc.b  10,13,0

