*******************************************************************************
* rcMon-68k v1.3
*******************************************************************************
* Written to support my own RCBus 68000 board. Supports simple S-Record loading as
* well as memory display & modification. No breakpoints, single stepping or
* disassembly stuff.
*
* ROM : 128K organised as 64K  x 16bits (2x W27C512 EEPROM)
* RAM : 1M   organised as 512K x 16bits (2x AS6C4008)
*
* ROM starts at 0x000000 up to 0x01FFFF (128K)
* RAM starts at 0x100000 up to 0x1FFFFF (1M)
*
* Use EASyBIN to split the S-Record into ODD and EVEN bytes.
* The *_0.BIN file goes in the U ROM socket - holding D08..D15
* The *_1.BIN file goes in the L ROM socket - holding D00..D07
*
*******************************************************************************
* Exception Handling
*******************************************************************************
* ROM starts at $0000 and holds the exception vector table. The table entries
* each jump to a small routine that gets the handler address from the start of
* RAM (or wherever VEC_BASE is defined) and re-directs execution to that address.
* Initially the RAM addresses all point back to handlers in ROM but can be
* overwritten to point to a user supplied handler in RAM. 
*
* BUS ERROR & ADDRESS ERROR handlers always use the ROM vector table addresses.
* Some Easy68k TRAP #15 text I/O routines are implemented as follows:
* Currently only tasks 0,1,5,6,13 & 14 are supported.
*******************************************************************************
* CP/M-68K Support
* V1.3 of CP/M-68K is now supported. The CPM400 s-record file should be
* programmed into the EEPROMs at the same time as this monitor. CP/M will
* reside at address 0x0400 onwards.
*
* The hardware specific BIOS should also be programmed into the EEPROMs. The
* BIOS must reside at address 0x6000 onwards. 
*******************************************************************************

	INCLUDE "..\asm-inc\memory.inc"
	INCLUDE "..\asm-inc\devices.inc"
	
*******************************************************************************
* Set USE_REAL_UART as follows:
*  1 = use the real MC6861 DUART hardware
*  0 = use Easy68k Sim68k I/O window
* -1 = use Easy68k Sim68k COM port
*
* Sim68K COM port is defined at the end of this file - change accordingly
*
USE_REAL_UART     EQU     1

*------------------------------------------------------------------------------
* Macro to "jump" to exception handler pointed to in the RAM vector table
* Parameter \1 is the vector number 
* Put the handler address held in RAM onto the stack and RET to it
*------------------------------------------------------------------------------
ramVecJump	MACRO
	move.l	VEC_BASE+(\1<<2),-(SP)
	rts
	ENDM

*------------------------------------------------------------------------------
* ASCII control characters
*------------------------------------------------------------------------------
LF    equ $0A
CR    equ $0D

*------------------------------------------------------------------------------
* 68000 Exception Vector Table - THIS ONE IS IN ROM
* All exceptions get the handler addresses from the RAM vector table except for
* Bus Error, Address Error & TRAP #15 which always call handlers in the ROM. 
*------------------------------------------------------------------------------

    ORG     $0000

    DC.l    STACK_START    * Supervisor stack pointer
    DC.l    START          * Initial PC    

    DC.L    handleBusErr   *02 Bus Error     (** ROM handler **)
    DC.L    handleAddrErr  *03 Address Error (** ROM handler **)
    DC.L    jmpIllInst     *04 Illegal Instruction
    DC.L    jmpZeroDiv     *05 Zero Divide
    DC.L    jmpChkInst     *06 CHK Instruction
    DC.L    jmpTrapV       *07 TRAPV Instruction
    DC.L    jmpPriv        *08 Privilege Violation
    DC.L    jmpTrace       *09 Trace
    DC.L    jmpLineA       *0A Line 1010 Emulator
    DC.L    jmpLineF       *0B Line 1111 Emulator
    DC.L    jmpRes1        *0C (Unassigned, Reserved)
    DC.L    jmpRes2        *0D (Unassigned, Reserved)
    DC.L    jmpRes3        *0E (Unassigned, Reserved)
    DC.L    jmpUnInit      *0F Uninitialized Interrupt Vector
    DC.L    jmpRes4        *10 (Unassigned, Reserved)
    DC.L    jmpRes5        *11 (Unassigned, Reserved)
    DC.L    jmpRes6        *12 (Unassigned, Reserved)
    DC.L    jmpRes7        *13 (Unassigned, Reserved)
    DC.L    jmpRes8        *14 (Unassigned, Reserved)
    DC.L    jmpRes9        *15 (Unassigned, Reserved)
    DC.L    jmpRes10       *16 (Unassigned, Reserved)
    DC.L    jmpRes11       *17 (Unassigned, Reserved)
    DC.L    jmpSpur        *18 Spurious Interrupt
    DC.L    jmpAV1         *19 Level 1 Interrupt Autovector
    DC.L    jmpAV2         *1A Level 2 Interrupt Autovector
    DC.L    jmpAV3         *1B Level 3 Interrupt Autovector
    DC.L    jmpAV4         *1C Level 4 Interrupt Autovector
    DC.L    jmpAV5         *1D Level 5 Interrupt Autovector
    DC.L    jmpAV6         *1E Level 6 Interrupt Autovector
    DC.L    jmpAV7         *1F Level 7 Interrupt Autovector
    DC.L    jmpTrap0       *20 TRAP #0  Instruction Vector
    DC.L    jmpTrap1       *21 TRAP #1  Instruction Vector
    DC.L    jmpTrap2       *22 TRAP #2  Instruction Vector
    DC.L    jmpTrap3       *23 TRAP #3  Instruction Vector
    DC.L    jmpTrap4       *24 TRAP #4  Instruction Vector
    DC.L    jmpTrap5       *25 TRAP #5  Instruction Vector
    DC.L    jmpTrap6       *26 TRAP #6  Instruction Vector
    DC.L    jmpTrap7       *27 TRAP #7  Instruction Vector
    DC.L    jmpTrap8       *28 TRAP #8  Instruction Vector
    DC.L    jmpTrap9       *29 TRAP #9  Instruction Vector
    DC.L    jmpTrap10      *2A TRAP #10 Instruction Vector
    DC.L    jmpTrap11      *2B TRAP #11 Instruction Vector
    DC.L    jmpTrap12      *2C TRAP #12 Instruction Vector
    DC.L    jmpTrap13      *2D TRAP #13 Instruction Vector
    DC.L    jmpTrap14      *2E TRAP #14 Instruction Vector
    DC.L    easy68kTrap15  *2E TRAP #15 Instruction Vector (** ROM handler **)
		
*------------------------------------------------------------------------------
* Exception Vectors 30 to FF are not used on my system so just point them
* all to the default handler.

	DCB.L	208,jmpUnused

*------------------------------------------------------------------------------
* Start the monitor program after the CP/M BIOS code.
*------------------------------------------------------------------------------
	ORG		MON_BASE

*------------------------------------------------------------------------------
* The hard coded ROM exception vector table entries point to these individual
* handlers that then jump to (actually RETurn to) the address specified in the
* RAM exception vector table.
*------------------------------------------------------------------------------
    ORG		(*+1)&-2	* make sure the table is word aligned

jmpBusErr:	ramVecJump	$02
jmpAddrErr:	ramVecJump	$03
jmpIllInst:	ramVecJump	$04
jmpZeroDiv:	ramVecJump	$05
jmpChkInst:	ramVecJump	$06
jmpTrapV:	ramVecJump	$07
jmpPriv:	ramVecJump	$08
jmpTrace:	ramVecJump	$09
jmpLineA:	ramVecJump	$0A
jmpLineF:	ramVecJump	$0B
jmpRes1:	ramVecJump	$0C
jmpRes2:	ramVecJump	$0D
jmpRes3:	ramVecJump	$0E
jmpUnInit:	ramVecJump	$0F
jmpRes4:	ramVecJump	$10
jmpRes5:	ramVecJump	$11
jmpRes6:	ramVecJump	$12
jmpRes7:	ramVecJump	$13
jmpRes8:	ramVecJump	$14
jmpRes9:	ramVecJump	$15
jmpRes10:	ramVecJump	$16
jmpRes11:	ramVecJump	$17
jmpSpur:	ramVecJump	$18
jmpAV1:		ramVecJump	$19
jmpAV2:		ramVecJump	$1A
jmpAV3:		ramVecJump	$1B
jmpAV4:		ramVecJump	$1C
jmpAV5:		ramVecJump	$1D
jmpAV6:		ramVecJump	$1E
jmpAV7:		ramVecJump	$1F
jmpTrap0:	ramVecJump	$20
jmpTrap1:	ramVecJump	$21
jmpTrap2:	ramVecJump	$22
jmpTrap3:	ramVecJump	$23
jmpTrap4:	ramVecJump	$24
jmpTrap5:	ramVecJump	$25
jmpTrap6:	ramVecJump	$26
jmpTrap7:	ramVecJump	$27
jmpTrap8:	ramVecJump	$28
jmpTrap9:	ramVecJump	$29
jmpTrap10:	ramVecJump	$2A
jmpTrap11:	ramVecJump	$2B
jmpTrap12:	ramVecJump	$2C
jmpTrap13:	ramVecJump	$2D
jmpTrap14:	ramVecJump	$2E
jmpTrap15:	ramVecJump	$2F

jmpUnused:	ramVecJump	$30

*------------------------------------------------------------------------------
* This is the initial exception vector table that gets copied into RAM. It just
* holds the addresses of basic exception handlers in ROM. The ramVecJump indexes
* into this table to get the addresses of the actual exception handlers. 
*
* NOTE: Bus Error, Address Error & TRAP #15 are all hard coded to be handled by
* routines in ROM and the entries in this table are not used.
*------------------------------------------------------------------------------
    ORG		(*+1)&-2	   * make sure the table is word aligned

rom2ramIVT:
    DC.L    STACK_START    *00 Supervisor stack pointer
    DC.L    START          *01 Initial PC    

    DC.L    handleBusErr   *02 Bus Error
    DC.L    handleAddrErr  *03 Address Error
    DC.L    handleIllInst  *04 Illegal Instruction
    DC.L    handleZeroDiv  *05 Zero Divide
    DC.L    handleChkInst  *06 CHK Instruction
    DC.L    handleTrapV    *07 TRAPV Instruction
    DC.L    handlePriv     *08 Privilege Violation
    DC.L    handleTrace    *09 Trace
    DC.L    handleLineA    *0A Line 1010 Emulator
    DC.L    handleLineF    *0B Line 1111 Emulator
    DC.L    handleRes1     *0C (Unassigned, Reserved)
    DC.L    handleRes2     *0D (Unassigned, Reserved)
    DC.L    handleRes3     *0E (Unassigned, Reserved)
    DC.L    handleUnInit   *0F Uninitialized Interrupt Vector
    DC.L    handleRes4     *10 (Unassigned, Reserved)
    DC.L    handleRes5     *11 (Unassigned, Reserved)
    DC.L    handleRes6     *12 (Unassigned, Reserved)
    DC.L    handleRes7     *13 (Unassigned, Reserved)
    DC.L    handleRes8     *14 (Unassigned, Reserved)
    DC.L    handleRes9     *15 (Unassigned, Reserved)
    DC.L    handleRes10    *16 (Unassigned, Reserved)
    DC.L    handleRes11    *17 (Unassigned, Reserved)
    DC.L    handleSpur     *18 Spurious Interrupt
    DC.L    handleAV1      *19 Level 1 Interrupt Autovector
    DC.L    handleAV2      *1A Level 2 Interrupt Autovector
    DC.L    handleAV3      *1B Level 3 Interrupt Autovector
    DC.L    handleAV4      *1C Level 4 Interrupt Autovector
    DC.L    handleAV5      *1D Level 5 Interrupt Autovector
    DC.L    handleAV6      *1E Level 6 Interrupt Autovector
    DC.L    handleAV7      *1F Level 7 Interrupt Autovector
    DC.L    handleTrap0    *20 TRAP #0  Instruction Vector
    DC.L    handleTrap1    *21 TRAP #1  Instruction Vector
    DC.L    handleTrap2    *22 TRAP #2  Instruction Vector
    DC.L    handleTrap3    *23 TRAP #3  Instruction Vector
    DC.L    handleTrap4    *24 TRAP #4  Instruction Vector
    DC.L    handleTrap5    *25 TRAP #5  Instruction Vector
    DC.L    handleTrap6    *26 TRAP #6  Instruction Vector
    DC.L    handleTrap7    *27 TRAP #7  Instruction Vector
    DC.L    handleTrap8    *28 TRAP #8  Instruction Vector
    DC.L    handleTrap9    *29 TRAP #9  Instruction Vector
    DC.L    handleTrap10   *2A TRAP #10 Instruction Vector
    DC.L    handleTrap11   *2B TRAP #11 Instruction Vector
    DC.L    handleTrap12   *2C TRAP #12 Instruction Vector
    DC.L    handleTrap13   *2D TRAP #13 Instruction Vector
    DC.L    handleTrap14   *2E TRAP #14 Instruction Vector
    DC.L    handleTrap15   *2F TRAP #15 Instruction Vector

	DCB.L	208,handleUnused

*------------------------------------------------------------------------------
* Below are the actual exception handlers that are accessed from the vector
* table in RAM. The user can overwrite any of the RAM vector table addresses
* with the address of their own exception handler. These handlers simply output
* a message to the serial port and enter an endless loop.
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* BUS ERROR handler
* Print a message showing the PC and address being accessed
*------------------------------------------------------------------------------
handleBusErr:
    lea     bemsg1(PC), a0	* first message
    bsr.w   putString
	move.l	10(a7),d0		* get the program counter 
	bsr.w	writeAddr32
	
    lea     bemsg2(PC), a0	* second message
    bsr.w   putString
	bra.w	handleCleanUp
	
*------------------------------------------------------------------------------
* ADDRESS ERROR handler
* Print a message showing the PC and address being accessed
*------------------------------------------------------------------------------
handleAddrErr:
    lea     aemsg1(PC), a0	* first message
    bsr.w   putString
	move.l	10(a7),d0		* get the program counter 
	bsr.w	writeAddr32
	
    lea     aemsg2(PC), a0	* second message
    bsr.w   putString
	bra.w	handleCleanUp
	
*------------------------------------------------------------------------------
* ILLEGAL INSTRUCTION handler
*------------------------------------------------------------------------------
handleIllInst:
    lea     iimsg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp
	
*------------------------------------------------------------------------------
* DIVISION BY ZERO handler
*------------------------------------------------------------------------------
handleZeroDiv:
    lea     zdmsg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp
	
*------------------------------------------------------------------------------
* CHK handler
*------------------------------------------------------------------------------
handleChkInst:
    lea     cimsg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp
	
*------------------------------------------------------------------------------
* TRAPV handler
*------------------------------------------------------------------------------
handleTrapV:
    lea     tvmsg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp
	
*------------------------------------------------------------------------------
* PRIVILEGE VIOLATION handler
*------------------------------------------------------------------------------
handlePriv:
    lea     pvmsg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp
	
*------------------------------------------------------------------------------
* TRACE handler
*------------------------------------------------------------------------------
handleTrace:
    lea     trmsg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp
	
*------------------------------------------------------------------------------
* Unimplementd Instruction - Line A handler
*------------------------------------------------------------------------------
handleLineA:
    lea     lamsg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp
	
*------------------------------------------------------------------------------
* Unimplementd Instruction - Line F handler
*------------------------------------------------------------------------------
handleLineF:
    lea     lfmsg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp
	
*------------------------------------------------------------------------------
* Reserved Instruction handler
*------------------------------------------------------------------------------
handleRes1:
handleRes2:
handleRes3:
handleRes4:
handleRes5:
handleRes6:
handleRes7:
handleRes8:
handleRes9:
handleRes10:
handleRes11:
    lea     rimsg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp
	
*------------------------------------------------------------------------------
* Uninitialised Interrupt handler
*------------------------------------------------------------------------------
handleUnInit:
    lea     uimsg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp
	
*------------------------------------------------------------------------------
* Spurious Interrupt handler
*------------------------------------------------------------------------------
handleSpur:
    lea     simsg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp
	
*------------------------------------------------------------------------------
* Autovector Level 1 Exception handler
*------------------------------------------------------------------------------
handleAV1:
    lea     av1msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp

*------------------------------------------------------------------------------
* Autovector Level 2 Exception handler
*------------------------------------------------------------------------------
handleAV2:
    lea     av2msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp

*------------------------------------------------------------------------------
* Autovector Level 3 Exception handler
*------------------------------------------------------------------------------
handleAV3:
    lea     av3msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp

*------------------------------------------------------------------------------
* Autovector Level 4 Exception handler
*------------------------------------------------------------------------------
handleAV4:
    lea     av4msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp

*------------------------------------------------------------------------------
* Autovector Level 5 Exception handler
*------------------------------------------------------------------------------
handleAV5:
    lea     av5msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp

*------------------------------------------------------------------------------
* Autovector Level 6 Exception handler
*------------------------------------------------------------------------------
handleAV6:
    lea     av6msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp

*------------------------------------------------------------------------------
* Autovector Level 7 Exception handler
*------------------------------------------------------------------------------
handleAV7:
    lea     av7msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp
	
*------------------------------------------------------------------------------
* TRAP #0 Exception handler
*------------------------------------------------------------------------------
handleTrap0:
    lea     tr0msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp

*------------------------------------------------------------------------------
* TRAP #1 Exception handler
*------------------------------------------------------------------------------
handleTrap1:
    lea     tr1msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp

*------------------------------------------------------------------------------
* TRAP #2 Exception handler
*------------------------------------------------------------------------------
handleTrap2:
    lea     tr2msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp

*------------------------------------------------------------------------------
* TRAP #3 Exception handler
*------------------------------------------------------------------------------
handleTrap3:
    lea     tr3msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp

*------------------------------------------------------------------------------
* TRAP #4 Exception handler
*------------------------------------------------------------------------------
handleTrap4:
    lea     tr4msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp

*------------------------------------------------------------------------------
* TRAP #5 Exception handler
*------------------------------------------------------------------------------
handleTrap5:
    lea     tr5msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp

*------------------------------------------------------------------------------
* TRAP #6 Exception handler
*------------------------------------------------------------------------------
handleTrap6:
    lea     tr6msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp

*------------------------------------------------------------------------------
* TRAP #7 Exception handler
*------------------------------------------------------------------------------
handleTrap7:
    lea     tr7msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp

*------------------------------------------------------------------------------
* TRAP #8 Exception handler
*------------------------------------------------------------------------------
handleTrap8:
    lea     tr8msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp

*------------------------------------------------------------------------------
* TRAP #9 Exception handler
*------------------------------------------------------------------------------
handleTrap9:
    lea     tr9msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp

*------------------------------------------------------------------------------
* TRAP #10 Exception handler
*------------------------------------------------------------------------------
handleTrap10:
    lea     tr10msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp

*------------------------------------------------------------------------------
* TRAP #11 Exception handler
*------------------------------------------------------------------------------
handleTrap11:
    lea     tr11msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp

*------------------------------------------------------------------------------
* TRAP #12 Exception handler
*------------------------------------------------------------------------------
handleTrap12:
    lea     tr12msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp
	
*------------------------------------------------------------------------------
* TRAP #13 Exception handler
*------------------------------------------------------------------------------
handleTrap13:
    lea     tr13msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp
	
*------------------------------------------------------------------------------
* TRAP #14 Exception handler
*------------------------------------------------------------------------------
handleTrap14:
    lea     tr14msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp
	
*------------------------------------------------------------------------------
* TRAP #15 Exception handler
*------------------------------------------------------------------------------
handleTrap15:
    lea     tr15msg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp
	
*------------------------------------------------------------------------------
* User Exception handler - all remaining exception handlers land here
*------------------------------------------------------------------------------
handleUnused:
    lea     usermsg(PC), a0	* display message
    bsr.w   putString
	bra.w	handleCleanUp
	
*------------------------------------------------------------------------------
* All exception handlers jump here to output the PC of the next instruction
* after the exception occured.
*------------------------------------------------------------------------------
handleCleanUp:
	move.l	2(a7),d0		* get the address
	bsr.w 	writeAddr32
	bsr.w 	putCRLF
.infloop:
    bra.s   .infloop

*------------------------------------------------------------------------------
* Exception handler messages
*------------------------------------------------------------------------------
aemsg1:  dc.b	10,13,'STOP: An Address Error occured whilst executing code at address $',0
aemsg2:	 dc.b	10,13,'STOP: The address location being accessed was $',0
av1msg:  dc.b	10,13,'STOP: Autovector Level 1 exception occured near address $',0
av2msg:  dc.b	10,13,'STOP: Autovector Level 2 exception occured near address $',0
av3msg:  dc.b	10,13,'STOP: Autovector Level 3 exception occured near address $',0
av4msg:  dc.b	10,13,'STOP: Autovector Level 4 exception occured near address $',0
av5msg:  dc.b	10,13,'STOP: Autovector Level 5 exception occured near address $',0
av6msg:  dc.b	10,13,'STOP: Autovector Level 6 exception occured near address $',0
av7msg:  dc.b	10,13,'STOP: Autovector Level 7 exception occured near address $',0
bemsg1:  dc.b	10,13,'STOP: A Bus Error occured whilst executing code at address $',0
bemsg2:	 dc.b	10,13,'    : The address location being accessed was $',0
cimsg:   dc.b	10,13,'STOP: CHK exception occured near address $',0
iimsg:   dc.b	10,13,'STOP: Illegal Instruction was encountered near address $',0
lamsg:   dc.b	10,13,'STOP: LINE A exception occured near address $',0
lfmsg:   dc.b	10,13,'STOP: LINE F exception occured near address $',0
pvmsg:   dc.b	10,13,'STOP: Privilege Viloation exception occured near address $',0
rimsg:   dc.b	10,13,'STOP: Reserved exception occured near address $',0
simsg:   dc.b	10,13,'STOP: Spurious Interrupt exception occured near address $',0
trmsg:   dc.b	10,13,'STOP: TRACE exception occured near address $',0
tr0msg:  dc.b	10,13,'STOP: TRAP #0 exception occured near address $',0
tr1msg:  dc.b	10,13,'STOP: TRAP #1 exception occured near address $',0
tr2msg:  dc.b	10,13,'STOP: TRAP #2 exception occured near address $',0
tr3msg:  dc.b	10,13,'STOP: TRAP #3 exception occured near address $',0
tr4msg:  dc.b	10,13,'STOP: TRAP #4 exception occured near address $',0
tr5msg:  dc.b	10,13,'STOP: TRAP #5 exception occured near address $',0
tr6msg:  dc.b	10,13,'STOP: TRAP #6 exception occured near address $',0
tr7msg:  dc.b	10,13,'STOP: TRAP #7 exception occured near address $',0
tr8msg:  dc.b	10,13,'STOP: TRAP #8 exception occured near address $',0
tr9msg:  dc.b	10,13,'STOP: TRAP #9 exception occured near address $',0
tr10msg: dc.b	10,13,'STOP: TRAP #10 exception occured near address $',0
tr11msg: dc.b	10,13,'STOP: TRAP #11 exception occured near address $',0
tr12msg: dc.b	10,13,'STOP: TRAP #12 exception occured near address $',0
tr13msg: dc.b	10,13,'STOP: TRAP #13 exception occured near address $',0
tr14msg: dc.b	10,13,'STOP: TRAP #14 exception occured near address $',0
tr15msg: dc.b	10,13,'STOP: TRAP #15 exception occured near address $',0
tvmsg:   dc.b	10,13,'STOP: TRAPV exception occured near address $',0
uimsg: 	 dc.b	10,13,'STOP: Uninitialised Interrupt exception occured near address $',0
usermsg: dc.b	10,13,'STOP: User exception occured near address $',0
zdmsg:   dc.b	10,13,'STOP: Divide By Zero error occured near address $',0

* #############################################################################
* #############################################################################
* C O L D   S T A R T
* #############################################################################
* #############################################################################

    ORG		(*+1)&-2	* make we start on a word aligned address
START:
    lea     STACK_START, sp     * Set the stack pointer just in case

	* copy the exception vector table into RAM
	move.l	#rom2ramIVT,a0		* start of exception table in ROM
	move.l	#VEC_BASE,a1		* location in RAM to copy table to
	move.l	#256,d0				* 256 entries to copy
.copy:
    move.l  (a0)+,(a1)+     * copy the byte from ROM to RAM
    dbra    d0,.copy

*------------------------------------------------------------------------------
* Initialise the SCC68692 DUART port A
*------------------------------------------------------------------------------

    move.b  #$30, CRA       * Reset Transmitter
    move.b  #$20, CRA       * Reset Reciever
    move.b  #$10, CRA       * Reset Mode Register Pointer
    
    move.b  #$00, ACR       * Baud Rate Set #1
    move.b  #$13, MRA       * No Parity & 8-bit
    move.b  #$07, MRA       * Normal Mode, No CTS/RTS & 1 stop bit
    move.b  #BAUD_RATE, CSRA      * Set Tx and Rx baud rates
    move.b  #$00, IMR       * No interrupts
    move.b  #$05, CRA       * Enable Transmit/Recieve
    move.b  #$03, SOPR      * Turn off the 2 user LEDs on OP0 & OP1

    iflt USE_REAL_UART
	; using Sim68K COM port

	; initialise the serial port
    move.l  #1<<16+40,d0    ; PID 1, task 40
    lea     COMPORT,A1      ; name of port
    trap    #15             ; D0=0 success, 1 invalid PID, 2 error	

    ; set port parameters
    move.l  #1<<16+41,d0    ; PID 1, task 41
    move.l  portParams,d1   ; port parameters
    trap    #15             ; D0=0 success, 1 invalid PID, 2 error, 3 port not initialized
	
    endc
	
*------------------------------------------------------------------------------
* Warm Restart entry point
*------------------------------------------------------------------------------
monStart:
    lea     strBanner1(PC), a0	* Show the monitor details
    bsr.w   putString

    lea		strCommands(PC), a0 * And the command help message
    bsr.w   putString

monLoop:
    lea     strPrompt(PC), a0   * Prompt
    bsr.w   putString

monLoop_NP:
	bsr.w	getc			* get a character into D0
	bsr.w	chToUpper		* convert character to upper case
	
	cmpi.b	#LF,d0			* ignore Line-Feed
    beq.s   monLoop
	
    cmp.b   #'B', d0        * Boot EhBASIC v3.54
    beq.w   cmdBootEHBASIC

    cmp.b   #'C', d0        * Boot CP/M-68K
    beq.w   cmdBootCPM

    cmp.b   #'D', d0        * Dump memory command
    beq.w   cmdDispMemory

    cmp.b   #'I', d0        * Read from I/O space address
    beq.w   cmdIORead

    cmp.b   #'M', d0        * Modify memory command
    beq.w   cmdModifyMemory

    cmp.b   #'O', d0        * Write to I/O space address
    beq.w   cmdIOWrite

    cmp.b   #'S', d0        * S record download
    beq.w   cmdDownload

    cmp.b   #'G', d0        * Go command
    beq.w   cmdRun

    cmp.b   #'?', d0        * Help command
    beq.w   cmdHelp

    cmp.b   #' ', d0        * Ignore spaces
    ble.s   monLoop_NP		* go back without printing prompt    

	move.b	d0,d1			* save the unknown char
    lea     strUnkCmd(PC), a0   * unknown command
    bsr.w   putString
	move.b	d1,d0			* get unnknown char back
	bsr.w	writeByte		* print it
	
monLoop_CRLF:
	bsr.w	putCRLF
    bra.s   monLoop
	
*------------------------------------------------------------------------------
* (B) Boot EhBASIC v3.54
*------------------------------------------------------------------------------
cmdBootEHBASIC:
	* perform a simple check to see if EhBASIC has been programmed into the
	* EEPROM by reading address 0x9000 in the EEPROM. If it contains 0xFFFF,
	* then EhBASIC hasn't been programmed in!
	cmpi.w	#$FFFF,EHBASIC_BASE
	bne.s	.bootEHBASIC
    lea		strBASICErr1(PC), a0
    bsr.w   putString
    bra.w   monLoop

.bootEHBASIC:
	move.l	#EHBASIC_BASE,a0
    jsr     (a0)            * jump to EhBASIC 

    * I don't think EhBASIC can return back to the monitor but just in case it can
    * print out a message and wait for a reset.
    lea		strBASICReturn(PC), a0
    bsr.w   putString
.forever:
    bra.s	.forever

*------------------------------------------------------------------------------
* (C) Boot CP/M-68K v1.3
*------------------------------------------------------------------------------
cmdBootCPM:
	* perform a simple check to see if CP/M has been programmed into the EEPROM
	* by reading address 0x0400 in the EEPROM. If it contains 0xFFFF then CP/M
	* hasn't been programmed in!
	cmpi.w	#$FFFF,CPM_BASE
	bne.s	.chkBIOS
    lea		strCPMErr1(PC), a0
    bsr.w   putString
    bra.w   monLoop
	
.chkBIOS:	
	* perform a simple check to see if the BIOS has been programmed into the EEPROM
	* by reading address 0x0400 in the EEPROM. If it contains 0xFFFF then the CP/M
	* BIOS hasn't been programmed in!
	cmpi.w	#$FFFF,$6000
	bne.s	.bootCPM
    lea		strCPMErr2(PC), a0
    bsr.w   putString
    bra.w   monLoop
	
.bootCPM:
	move.l	#CPM_BASE,a0
    jsr     (a0)            * jump to CP/M-68K 
	
    * I don't think CP/M-68K can return back to the moitor but just in case it can
    * print out a message and wait for a reset.
    lea		strCPMReturn(PC), a0
    bsr.w   putString
.forever:
    bra.s	.forever
	
*------------------------------------------------------------------------------
* (D)ump memory
* Display 256 bytes of memory as ASCII-HEX characters
*------------------------------------------------------------------------------
cmdDispMemory:
	bsr.w	putc			* echo back the command character in D0
	move.b	#' ',d0
	bsr.w	putc
	
	clr.l	d2				* pre-set D2 to 0
	move.l	#8,d1			* read up to 8 digits
	bsr.w	hexToIntEcho	* from the serial port into D0
	bcs.w	monLoop			* back to prompt if there's an error
	
	move.l	d0,a0			* A0 holds the start address
    bsr.w   dumpRAM

    bra.w	monLoop

*------------------------------------------------------------------------------
* (G)o - execute code in memory starting at the specified address
*------------------------------------------------------------------------------
cmdRun:
	bsr.w	putc			* echo back the command character in D0
	move.b	#' ',d0
	bsr.w	putc

	clr.l	d2				* pre-set D2 to 0
	move.l	#8,d1			* read up to 8 digits
	bsr.w	hexToIntEcho	* from the serial port
	bcs.w	monLoop			* back to prompt if there's an error

    move.l  d0, a0			* copy start address into A0
    jsr     (a0)            * jump to user code 
    bra.w	monLoop

*------------------------------------------------------------------------------
* (I)nput a byte from I/O space address
*------------------------------------------------------------------------------
cmdIORead:
	bsr.w	putc			* echo back the command character in D0
	move.b	#' ',d0
	bsr.w	putc

	clr.l	d2				* pre-set D2 to 0
	move.l	#2,d1			* read up to 2 digit address
	bsr.w	hexToIntEcho	* from the serial port
	bcs.w	monLoop			* back to prompt if there's an error
	move.b	d0,d3			* save the typed in 8-bit address
	move.b	#'=',d0
	bsr.w	putc			* send an EQUALS

	; D3 = 8-bit address
	movea.l	#IO_BASE,a0
	andi.l	#$FF,d3			* clear all the unused bits
	asl.l	#1,d3			* make it a word offset
	addi.l	#1,d3			* make it an odd address to read from D0..D7
	move.b	(0,a0,d3),d0	* and read the new value in
	bsr.w	writeByte		* display the value
	bsr.w	putCRLF
    bra.w	monLoop

*------------------------------------------------------------------------------
* (M)odify memory
* Change memory contents 1 byte at a time
*------------------------------------------------------------------------------
cmdModifyMemory:
	bsr.w	putc			* echo back the command character in D0
	move.b	#' ',d0
	bsr.w	putc

	clr.l	d2				* pre-set D2 to 0
	move.l	#8,d1			* read up to 8 digits
	bsr.w	hexToIntEcho	* from the serial port
	bcs.w	monLoop			* back to prompt if there's an error
	move.b	d0,d1			* save the typed in address
    bsr.w   putCRLF
	move.b	d1,d0			* restore the typed in address
	
	move.l	d0,a0			* copy address into A0
.cMM_1:
	bsr.w	writeAddr32		* display the memory location address
	move.b	#' ',d0
	bsr.w	putc
	move.b	(a0),d0			* get the current memory contents
	move.b	d0,d2			* pre-set D2 to the existing memory value
	bsr.w	writeByte		* display the byte
	move.b	#' ',d0
	bsr.w	putc
	move.l	#2,d1			* read up to 2 digits
	bsr.w	hexToIntEcho	* from the serial port
	bcs.w	.cMM_2			* back to prompt if there's an error

	move.b	d0,(a0)+		* write out the new byte and move on
	move.l	a0,-(SP)		* save our address
    bsr.w   putCRLF
	move.l	(SP)+,a0		* restore our address
	move.l	a0,d0			* copy address back into D0 for printing
	bra.s	.cMM_1

.cMM_2:
	bsr.w	putCRLF
    bra.w	monLoop
	
*------------------------------------------------------------------------------
* (O)utput a byte to I/O space address
*------------------------------------------------------------------------------
cmdIOWrite:
	bsr.w	putc			* echo back the command character in D0
	move.b	#' ',d0
	bsr.w	putc

	clr.l	d2				* pre-set D2 to 0
	move.l	#2,d1			* read up to 2 digit address
	bsr.w	hexToIntEcho	* from the serial port
	bcs.w	monLoop			* back to prompt if there's an error
	move.b	d0,d3			* save the typed in 8-bit address
	move.b	#'=',d0
	bsr.w	putc			* send an EQUALS

	clr.l	d2				* pre-set D2 to 0
	move.l	#2,d1			* read up to 2 digit value
	bsr.w	hexToIntEcho	* from the serial port
	bcs.w	monLoop			* back to prompt if there's an error

	; D0 = value and D3 = 8-bit address
	movea.l	#IO_BASE,a0
	andi.l	#$FF,d3			* clear all the unused bits
	asl.l	#1,d3			* make it a word offset
	addi.l	#1,d3			* make it an odd address to write to D0..D7
	move.b	d0,(0,a0,d3)	* and write the new value out

	bsr.w	putCRLF
    bra.w	monLoop

*------------------------------------------------------------------------------
* (S) - download a single line of a Motorola S-Record
*------------------------------------------------------------------------------
cmdDownload:
	bsr.w	getc			* get the S-Record type
	cmp.b   #'1', d0
	beq.s	.cdl_S1			* read in an S1 record
	cmp.b   #'2', d0
	beq.s	.cdl_S2			* read in an S2 record
	cmp.b   #'8', d0
	beq.w	.cdl_EOL89		* handle S8 SRec terminator
	cmp.b   #'9', d0
	beq.w	.cdl_EOL89		* handle S9 SRec terminator

	bne     .cdl_EOL		* not S1 or S2 so ignore to end of line
			
.cdl_S1:		
	clr.l	d2
	move.b  #2, d1			* 2 characters to read
	bsr     hexToInt		* convert to byte count
	move.l  d0, d6			* D6 = byte count
	move.l  d0, d7			* D7 = byte count (running checksum)

	clr.l	d2
	move.b  #4, d1			* 4 characters to read
	bsr     hexToInt		* convert to address
	movea.l d0, a3			* A3 = destination address
	add.b   d0, d7			* update checksum with bits 00..07
	lsr.l   #8, d0
	add.b   d0, d7			* update checksum with bits 08..15

	subq.w  #3, D6          * take off the 3 bytes we just read in

	bra.s	.cdl_1				
				
.cdl_S2:			
	clr.l	d2
	move.b  #2, d1			* 2 characters to read
	bsr     hexToInt		* convert to byte count
	move.l  d0, d6			* D6 = byte count
	move.l  d0, d7			* D7 = byte count (running checksum)

	clr.l	d2
	move.b  #6, d1			* 6 characters to read
	bsr     hexToInt		* convert to address
	movea.l d0, a3			* A3 = destination address
	add.b   d0, d7			* update checksum with bits 00..07
	lsr.l   #8, d0
	add.b   d0, d7			* update checksum with bits 08..15
	lsr.l   #8, d0
	add.b   d0, d7			* update checksum with bits 16..23

    subq.w  #4, d6          * take off the 4 bytes we just read in

.cdl_1:
    tst.w   d6				* read all the bytes yet?
	beq.s   .cdl_2

	clr.l	d2
	move.w  #2, d1			* 2 characters to read
	bsr     hexToInt		* convert to data byte
	move.b  d0, (a3)+		* write the byte to memory
	add.b   d0, d7			* update checksum
	subq.w  #1, d6			* decrement byte count
	bra.s   .cdl_1

.cdl_2:
	clr.l	d2
	move.w  #2, d1			* 2 characters to read
	bsr     hexToInt		* convert to checksum byte
	add.b   d0, d7			* D7 = calc checksum + srec checksum
	addq.b  #1, d7			* checksum + 1 should = 0 if OK
	beq.s   .cdl_X

	move.b  #'X', d0		* checksum fail - print an X
	bsr     putc
    bra.w	monLoop_NP		* return to main loop without prompt

.cdl_X
	move.b  #'.', d0		* checksum good - print a dot
	bsr     putc
    bra.w	monLoop_NP		* return to main loop without prompt

.cdl_EOL
	bsr.w	getc			* discard chars until CR or LF
	cmpi.b	#CR,d0
	beq.s	.cdl_X
	cmpi.b	#LF,d0
	beq.s	.cdl_X
	bra.s	.cdl_EOL

.cdl_EOL89
	bsr.w	getc			* discard chars until CR or LF
	cmpi.b	#CR,d0
	beq.w	monLoop_CRLF	* return to main loop with prompt
	cmpi.b	#LF,d0
	beq.w	monLoop_CRLF	* return to main loop with prompt
	bra.s	.cdl_EOL89
	
*------------------------------------------------------------------------------
* Display the supported commands
*------------------------------------------------------------------------------
cmdHelp:
    lea     strCommands(PC), a0
    bsr.w   putString
    bra.w   monLoop

*------------------------------------------------------------------------------
* Dumps a 256 section of RAM to the screen
* Displays both hex values and ASCII characters
* a0 - Start Address
*------------------------------------------------------------------------------
dumpRAM:
    movem.l d0-d2/a1, -(SP) * Save registers
	move.l	a0,a1			* move the start address to A1

	bsr.w	putCRLF			* new line - trashes D0 & A0
	
	move.w	#15,d1			* 16 rows of data (DBRA needs 1 less!)
.dr_1:
	move.w	#15,d2			* 16 bytes of data per row (DBRA needs 1 less!)
    move.l  a1, d0			* copy the start address of the line into D0          
    bsr.w   writeAddr32     * Display as a 32-bit hex value
    lea     strColonSpace(PC), a0
    bsr.w   putString
    lea		msgASCIIDump, a0
.dr_2:
    move.b  (a1)+, d0       * Read a byte from RAM
    bsr.w   writeByte       * display byte as 2 hex digits	
	bsr.w	makePrintable	* convert to printable character
	move.b	d0,(a0)+		* save the printable char in output string
    move.b  #' ', d0
    bsr.w   putc			* insert a space
	dbra	d2,.dr_2

    move.b  #' ', d0
    bsr.w   putc			* insert a space

	move.b	#CR,(a0)+
	move.b	#LF,(a0)+
	move.b	#0,(a0)+
    lea		msgASCIIDump, a0
    bsr.w   putString		* print out the printable bytes
	dbra	d1,.dr_1

    movem.l (SP)+, d0-d2/a1 * Restore registers
	rts
	        
*------------------------------------------------------------------------------
* Convert character in D0 to upper case
* Only changes D0 if char is between 'a'..'z'
*------------------------------------------------------------------------------
chToUpper:
    cmp.b   #'a', d0         
    blt.s   .done            * less than lower-case 'a' so leave alone
    cmp.b   #'z', d0
    bgt.s   .done            * greater than lower-case 'z' so leave alone
    sub.b   #$20, d0         * convert to upper case
.done:
    rts
    
*------------------------------------------------------------------------------
* Convert a byte into a print safe character
* Substitute a '.' for any byte <32 or >126
* D0 holds the byte
*------------------------------------------------------------------------------
makePrintable:
    cmp.b   #' ', d0         
    blt.s   .mp_1           * less than a SPACE (char 32)

    cmp.b   #'~', d0         
    ble.s   .mp_x           * less than a DEL (char 127)

.mp_1:
	move.b	#'.',d0			* substitute a DOT (char 46)
.mp_x:
	rts
	
*--------------------------------------------------------------------------
* Read in an ASCII-HEX number - no echo back
*
* D2 = Value to return if no digits read in
* D1 = Max no of ASCII digits to read in
* D0 = Result
* Carry flag set if an error occurs / not ASCII-HEX digit
*--------------------------------------------------------------------------
hexToInt:
*	move.l	d2,-(SP)		* save D2
*	clr.l	d2				* D2 used to accumulate the final value
.h2i_1:
	bsr.w	getc			* get a character
	bsr.s	chToUpper		* convert to upper case if needed

	cmpi.b	#10,d0			* finish if it's CR or LF
	beq.s	.h2i_x
	cmpi.b	#13,d0
	beq.s	.h2i_x
	
	subi.b	#'0',d0
	bmi.s	.h2i_err		* quit if char is less than '0'

	cmpi.b	#9,d0
	ble.s	.h2i_2			* is it <= 9
	
	subi.b	#7,d0
	bmi.s	.h2i_err		* quit if char is >'9' and <'A'

	cmpi.b	#15,d0
	bgt.s	.h2i_err		* quit if char is >'F'

.h2i_2:
	lsl.l	#4, d2
	or.b    d0, d2			* insert the new digit

	subq.b	#1, d1			* decrement the digit count
	bne.s	.h2i_1			* go back for another digit?

.h2i_x:
	move.l	d2,d0			* put the answer back into D0
*	move.l	(SP)+,d2		* restore D2
	rts

.h2i_err:
*	move.l	(SP)+,d2		* restore D2
	ori.b	#1,CCR			* set the CARRY flag to signal an error
	rts

*--------------------------------------------------------------------------
* Read in an ASCII-HEX number with echo back
*
* D2 = Value to return if no digits read in
* D1 = Max no of ASCII digits to read in
* D0 = Result
* Carry flag set if an error occurs / not ASCII-HEX digit
*--------------------------------------------------------------------------
hexToIntEcho:
*	move.l	d2,-(SP)		* save D2
*	clr.l	d2				* D2 used to accumulate the final value
.h2i_1:
	bsr.w	getc			* get a character
	bsr.w	putc			* echo it back
	bsr.s	chToUpper		* convert to upper case if needed

	cmpi.b	#10,d0			* finish if it's CR or LF
	beq.s	.h2i_x
	cmpi.b	#13,d0
	beq.s	.h2i_x
	
	subi.b	#'0',d0
	bmi.s	.h2i_err		* quit if char is less than '0'

	cmpi.b	#9,d0
	ble.s	.h2i_2			* is it <= 9
	
	subi.b	#7,d0
	bmi.s	.h2i_err		* quit if char is >'9' and <'A'

	cmpi.b	#15,d0
	bgt.s	.h2i_err		* quit if char is >'F'

.h2i_2:
	lsl.l	#4, d2
	or.b    d0, d2			* insert the new digit

	subq.b	#1, d1			* decrement the digit count
	bne.s	.h2i_1			* go back for another digit?

.h2i_x:
	move.l	d2,d0			* put the answer back into D0
*	move.l	(SP)+,d2		* restore D2
	rts

.h2i_err:
*	move.l	(SP)+,d2		* restore D2
	ori.b	#1,CCR			* set the CARRY flag to signal an error
	rts

*==============================================================================
*==============================================================================
* EASy68K TRAP #15 routines
*==============================================================================
*==============================================================================

*------------------------------------------------------------------------------
* This is the jump table for the TRAP #15 tasks - not all tasks are supported!
*------------------------------------------------------------------------------

easy68kTaskTable:
	bra.w	easyTask0 
	bra.w	easyTask1 
	bra.w	easyTask2 
	bra.w	easyTask3 
	bra.w	easyTask4 
	bra.w	easyTask5 
	bra.w	easyTask6 
	bra.w	easyTask7 
	bra.w	easyTask8 
	bra.w	easyTask9 
	bra.w	easyTask10
	bra.w	easyTask11
	bra.w	easyTask12
	bra.w	easyTask13
	bra.w	easyTask14
	bra.w	easyTask15
	bra.w	easyTask16
	bra.w	easyTask17
	bra.w	easyTask18
	bra.w	easyTask19
	bra.w	easyTask20
	bra.w	easyTask21
	bra.w	easyTask22
	bra.w	easyTask23
	bra.w	easyTask24
	bra.w	easyTask25

*------------------------------------------------------------------------------
* These are the EASy68K tasks not yet implemented
* The required task number is in D0
* Display a message and stop in an endless loop.
*------------------------------------------------------------------------------

easyTask2: 
easyTask3:
easyTask4:
easyTask8: 
easyTask9: 
easyTask10:
easyTask11:
easyTask12:
easyTask15:
easyTask16:
easyTask17:
easyTask18:
easyTask19:
easyTask20:
easyTask21:
easyTask22:
easyTask23:
easyTask24:
easyTask25:
easyTaskUnsupported:
	exg		d0,d1			; put the task number into D1
    lea     strEasyTask1(PC), a0
    bsr.w   putString
	exg		d0,d1			; put the task number back into D0
	divu	#10,d0			; divide task number by 10
    bsr.w   writeNibble		; output the 10's digit
	swap	d0
    bsr.w   writeNibble		; output the 1's digit
    lea     strEasyTask2(PC), a0
    bsr.w   putString
.infloop:
    bra.s   .infloop

*------------------------------------------------------------------------------
* EASy68K TRAP #15 - Task 0
* Display n characters of string at (A1), n is D1.W (stops on NULL or max 255) with CR, LF.
*------------------------------------------------------------------------------
easyTask0:
	andi.w	#$00FF,d1	* DBRA works on a WORD so make sure upper byte is zero
	sub.b	#1,d1		* DBRA requires 1 less than actual number
.loop:
    move.b  (a1)+, d0    * Read in character
    beq.s   .end         * Check for the null
    
    bsr.w   putc		 * Otherwise write the character
    dbra	d1,.loop	 * And continue
.end:
	bsr.w	putCRLF		* append CR & LF
    rts

*------------------------------------------------------------------------------
* EASy68K TRAP #15 - Task 1
* Display n characters of string at (A1), n is D1.W (stops on NULL or max 255) without CR, LF.
*------------------------------------------------------------------------------
easyTask1:
	andi.w	#$00FF,d1	* DBRA works on a WORD so make sure upper byte is zero
	sub.b	#1,d1		* DBRA requires 1 less than actual number
.loop:
    move.b  (a1)+, d0    * Read in character
    beq.s   .end         * Check for the null
    
    bsr.w   putc		 * Otherwise write the character
    dbra	d1,.loop	 * And continue
.end:
    rts

*------------------------------------------------------------------------------
* EASy68K TRAP #15 - Task 5
* Read single ASCII character from the keyboard into D1.B. 
*------------------------------------------------------------------------------
easyTask5:
	bsr.w	getc		* wait for char - returned in D0
	move.b	d0,d1		* move the char into D1
	rts
	
*------------------------------------------------------------------------------
* EASy68K TRAP #15 - Task 6
* Display single ASCII character in D1.B.   
*------------------------------------------------------------------------------
easyTask6:
	move.b	d1,d0		* move the char into D0
	bsr.w	putc		* output the char
	rts

*------------------------------------------------------------------------------
* EASy68K TRAP #15 - Task 7
* Check for keyboard input. Set D1.B to 1 if keyboard input is pending,
* otherwise set to 0.
*------------------------------------------------------------------------------
easyTask7:
	move.b	SRA,d1			* get DUART status register
	andi.b	#$01,d1			* mask all but the RxRDY bit
	rts

*------------------------------------------------------------------------------
* EASy68K TRAP #15 - Task 13
* Display the NULL terminated string at (A1) with CR, LF.
*------------------------------------------------------------------------------
easyTask13:
.loop:
    move.b  (a1)+, d0    * Read in character
    beq.s   .end         * Check for the null
    
    bsr.w   putc		 * Otherwise write the character
    bra.s   .loop        * And continue
.end:
	bsr.w	putCRLF		* append CR & LF
    rts

*------------------------------------------------------------------------------
* EASy68K TRAP #15 - Task 14
* Display the NULL terminated string pointed to by (A1).
*------------------------------------------------------------------------------
easyTask14:
.loop:
    move.b  (a1)+, d0    * Read in character
    beq.s   .end         * Check for the null
    
    bsr.w   putc		 * Otherwise write the character
    bra.s   .loop        * And continue
.end:
    rts

*------------------------------------------------------------------------------
* This is the entry point for the TRAP #15 handler that gets called when any
* TRAP #15 services are required. Only a few tasks are implemented.
* Unimplemented tasks will produce an error message.
*------------------------------------------------------------------------------
easy68kTrap15:
	movem.l	d3/a0/a2,-(sp)
	lea		easy68kTaskTable(PC),a2
	cmp.b	#25,d0			; is task number greater than 25?
	bgt		easyTaskUnsupported
	
	clr.l	d3
	move.b	d0,d3			; task number into D3
	lsl.l	#2,d3			; convert task number into longword offset
	jsr		(a2,d3)			; jump to the specific task handler
	
	movem.l	(sp)+,d3/a0/a2
	rte
	
*==============================================================================
* These are the various printing routines that handle displaying of bytes,
* words, long words and 24-bit values as ASCII hexadecimal text. The routines
* must be kept in this order as program flow is meant to fall out of one
* routine and into the next, often without a return statement.
*==============================================================================

*------------------------------------------------------------------------------
* Output a 32-bit address as 8 ASCII hexadecimal digits
* D0 holds the 32-bit address
*------------------------------------------------------------------------------
writeAddr32:
    move.l  d0,-(sp)    ; save D0 first
    ror.l   #8,d0
    ror.l   #8,d0
    bsr.s   writeWord   ; write bits 16..31
    move.l  (sp)+,d0    ; restore D0
    bra.s   writeWord
    
*------------------------------------------------------------------------------
* Output a 24-bit address as 6 ASCII hexadecimal digits
* D0 holds the address in bits 0..23
* NOTE: the writeWord function must be directly after this function
*------------------------------------------------------------------------------
writeAddr24:
    move.l  d0,-(sp)    ; save D0 first
    ror.l   #8,d0
    ror.l   #8,d0
    bsr.s   writeByte   ; write bits 16..23
    move.l  (sp)+,d0    ; restore D0
    
*------------------------------------------------------------------------------
* Output a word as 4 ASCII hexadecimal digits
* D0 holds the word in bits 0..15
* NOTE: the writeByte function must be directly after this function
*------------------------------------------------------------------------------
writeWord:
    move.w  d0,-(sp)    ; save D0 first
    ror.w   #8,d0       ; get upper byte (0 => shift 8 times)
    bsr.s   writeByte
    move.w  (sp)+,d0    ; restore D0

*------------------------------------------------------------------------------
* Output a byte as 2 ASCII hexadecimal digits
* D0 holds the byte in bits 0..7
* NOTE: the writeNibble function must be directly after this function
*------------------------------------------------------------------------------
writeByte:
    move.b  d0,-(sp)    ; save D0 first
    ror.b   #4,d0       ; get upper nibble
    bsr.s   writeNibble
    move.b  (sp)+,d0    ; restore D0
    
*------------------------------------------------------------------------------
* Output 4 bits as an ASCII hexadecimal digit
* D0 holds the nibble in bits 0..3
*------------------------------------------------------------------------------
writeNibble:
    move.b  d0,-(sp)    ; save D0 first
    andi.b  #$0F,d0     ; make sure we only have the lower 4 bits
    cmpi.b  #10,d0      ; compare D0 to 10
    bcs.b   .wn1        ; less than 10 so don't add 7
    addi.b  #07,d0      ; add 7
.wn1:
    addi.b  #'0',d0     ; add ASCII code for char zero
    bsr     putc        ; write the ASCII digit out
    move.b  (sp)+,d0    ; restore D0
    rts

*------------------------------------------------------------------------------
* Prints a newline (CR, LF)
* NOTE: the putString function must follow this function
*------------------------------------------------------------------------------
putCRLF:
    lea     strNewline(PC), a0

*------------------------------------------------------------------------------
* Print a null terminated string
* A0 holds the address of the first character of the null terminated string
*------------------------------------------------------------------------------
putString:
.loop:
    move.b  (a0)+, d0    * Read in character
    beq.s   .end         * Check for the null
    
    bsr.s   putc		 * Otherwise write the character
    bra.s   .loop        * And continue
.end:
    rts

*------------------------------------------------------------------------------
* Write a character to UART Port A, blocking if UART is not ready
* D0 = char to send
*------------------------------------------------------------------------------
putc:
    ifgt USE_REAL_UART
	; using real hardware
	
    btst.b    #2, SRA      * Check if transmitter ready bit is set
    beq     putc     
    move.b  d0, TBA      * Transmit Character
	rts
	
    endc
    
    ifeq USE_REAL_UART
	; using Sim68K I/O window

	movem.l	d0-d1,-(sp)		* save d0, d1
	move.b	d0,d1			* copy character
	moveq	#6,d0			* character out
	trap	#15				* call simulator I/O function
	movem.l	(sp)+,d0-d1		* restore d0, d1
	rts
	
    endc

    iflt USE_REAL_UART
	; using Sim68K COM port

	movem.l	d0-d1/a1,-(sp)		* save d0, d1, a1
    lea     serBuff,a1
	move.b	d0,(a1)			; save the character to send
    move.b  #1,d1           ; max chars to send
    move.l  #1<<16+43,d0    ; PID 1, task 43 send string
    trap    #15             ; D0=0 success, 1 invalid CID, 2 error, 3 port not initialized, 4 timeout
	movem.l	(sp)+,d0-d1/a1	* restore d0, d1, a1
	rts
	
    endc

*------------------------------------------------------------------------------
* Read a character from UART Port A - blocking call so will wait for character
* D0 = recevied char
*------------------------------------------------------------------------------
getc:
    ifgt USE_REAL_UART
	; using real hardware

	move.b	SRA,d0			* get DUART status register
	andi.b	#$01,d0			* mask all but the RxRDY bit
	beq.s	getc

	nop
	nop
	nop
	nop
    move.b  RBA, d0      * Read Character into D0
    rts

	endc
	
    ifeq USE_REAL_UART
	; using Sim68K I/O window

	move.l	d1,-(sp)		* save d1
.getc_1
	moveq	#7,d0			* 7 = get the status
	trap	#15				* call simulator I/O function

	move.b	d1,d0			* copy the returned status
	beq.s	.getc_1			* test again until a char is available
	
	moveq	#5,d0			* 5 = get byte form the keyboard
	trap	#15				* call simulator I/O function

	move.b	d1,d0			* copy the returned byte
	move.l	(sp)+,d1		* restore d1
	tst.b	d0				* set the z flag on the received byte
	ori.b	#1,ccr			* set the carry, flag we got a byte
	rts

	endc

    iflt USE_REAL_UART
	; using Sim68K COM port

	movem.l	d1/a1,-(sp)		* save d1, a1
    lea     serBuff,a1
.getc_2
    move.b  #1,d1           ; max chars to read
    move.l  #1<<16+42,d0    ; PID 1, task 42 receive string
    trap    #15
	; got a character?
	cmpi.b	#1,d1			; D1 = 1 if a character received
	bne.s	.getc_2
	move.b	(a1),d0			; get the character
	movem.l	(sp)+,d1/a1		* restore d1, a1
	rts

	endc

*------------------------------------------------------------------------------
* String constants
*------------------------------------------------------------------------------
strBanner1:
	dc.b 10,13
	dc.b 'Simple RCBus 68000 ROM Monitor v1.3',10,13
	dc.b 'ROM: 0x000000 .. 0x01FFFF',10,13
	dc.b 'RAM: 0x100000 .. 0x1FFFFF',10,13,0
strCommands:
    dc.b 10,13,'Commands: ',10,13
	dc.b 'B     : Start EhBASIC v3.54',10,13
	dc.b 'C     : Start CP/M-68K v1.3',10,13
	dc.b 'Dnnnn : Display 256 bytes of memory starting at address nnnn',10,13
	dc.b 'Gnnnn : Execute code starting at address nnnn',10,13
	dc.b 'Iaa   : Read a byte from address aa in I/O space',10,13
	dc.b 'Mnnnn : Modify memory starting at address nnnn',10,13
	dc.b 'Oaabb : Write byte bb to address aa in I/O space',10,13
	dc.b 'S1xxx : Download S1 Hex Record ',10,13          
	dc.b 'S2xxx : Download S2 Hex Record ',10,13	
	dc.b '?     : Display this help',10,13
	dc.b 0
strPrompt:
    dc.b '> ',0
strUnkCmd:
    dc.b 'Unknown Command: ',0
strNewline:
    dc.b 10,13,0
strColonSpace:
    dc.b ': ',0
strUninitInt:
    dc.b 'Unhandled interrupt.',10,13,0
strEasyTask1:
	dc.b	10,13,'STOP: EASy68K TRAP #15 - Task ',0
strEasyTask2:
	dc.b	' not yet implemented',10,13,0
strCPMErr1:
	dc.b	10,13,'Cannot boot CP/M-68K - CP/M-68K missing from EEPROM',10,13,0
strCPMErr2:
	dc.b	10,13,'Cannot boot CP/M-68K - CP/M-68K BIOS missing from EEPROM',10,13,0
strCPMReturn:
	dc.b	10,13,'CP/M-68K returned to Monitor. Press RESET to restart.',10,13,0
strBASICErr1:
	dc.b	10,13,'Cannot boot EhBASIC - EhBASIC missing from EEPROM',10,13,0
strBASICReturn:
	dc.b	10,13,'EhBASIC returned to Monitor. Press RESET to restart.',10,13,0
	
    iflt USE_REAL_UART
	; using Sim68K COM port
	
COMPORT:    dc.b    'COM3',0    ; default com port
* PORTPARAMS dc.l    0		   ; 9600,8,N,1
PORTPARAMS: dc.l    9		   ; 38400,8,N,1

	endc

*------------------------------------------------------------------------------
* Monitor variables
*------------------------------------------------------------------------------
	ORG		STACK_START
msgASCIIDump:
	ds.b 20
serBuff:   
	ds.b	8
	
    END    START            * last line of source























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
