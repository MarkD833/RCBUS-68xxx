*******************************************************************************
* rcMon-68302 v0.3 - sw version (see below)
*******************************************************************************
* Written to support my own RCBus 68302 board. Supports simple S-Record loading as
* well as memory display & modification. No breakpoints, single stepping or
* disassembly stuff.
*******************************************************************************
* This version of the 68302 monitor is the 'sw' version which makes use of the
* MC68302 internal chip selects to swap ROM and RAM such that RAM is at
* address 0x000000.
* 
* Assumes that an RCBus ROM/RAM v2 board is fitted with:
*   ROM : 1M organised as 512K x 16bits (2x SST39SF040 FLASH) - BANK 0
*   RAM : 1M organised as 512K x 16bits (2x AS6C4008) - BANK 1
*
* The ROM/RAM v2 board should:
* + NOT have the 74LS138 and 74LS125 chips fitted.
* + MUST have the 2 wire links fitted as detailed in the schematic notes.
*
* Initially ROM is at address 0x000000 .. 0x0FFFFF (via /CS0)
*
* After the switch, ROM is at address 0x600000 .. 0x6FFFFF (via /CS0)
*              and  RAM is at address 0x000000 .. 0x0FFFFF (via /CS1)
*
* Use EASyBIN to split the S-Record into ODD and EVEN bytes.
* The *_0.BIN file goes in the U ROM socket - holding D08..D15
* The *_1.BIN file goes in the L ROM socket - holding D00..D07
*
*******************************************************************************
* Exception Handling
*******************************************************************************
* After the ROM/RAM switch, the exception vector table is in RAM starting at
* address 0x000000 and exceptions up to TRAP #15 all have simple handers in ROM
* that print out a diagnostic message.
*
* Some Easy68k TRAP #15 text I/O routines are implemented as follows:
*   Currently only tasks 0,1,5,6,13 & 14 are supported.
*
*******************************************************************************

* TO REDO ************************************************
* Memory Map
* 0x000000 .. 0x0FFFFF 1Mb RAM
* 0x000000 .. 0x0003FF Exception vector table
* 0x600000 .. 0x6FFFFF 1Mb FLASH

* 008FFF This monitor
* 0x009000 ..          EhBASIC

*
* 0xFD0000 .. 0xFDFFFF 64K RCBus MREQ 
* 0xFE0000 .. 0xFEFFFF 64K RCBus IORQ
* 0xFFF000 .. 0xFFFFFF MC68302 Internal Peripheral Registers
*******************************************************************************

	INCLUDE "..\asm-inc\memory2.inc"
	INCLUDE "..\asm-inc\devices2.inc"
	INCLUDE "..\asm-inc\mc68302.inc"

*------------------------------------------------------------------------------
* ASCII control characters
*------------------------------------------------------------------------------
ASCII_LF    equ $0A
ASCII_CR    equ $0D

*------------------------------------------------------------------------------
* SYSCLK is the frequency of the external crystal oscillator in Hz
* Make sure that this is correct as it's used to calculate the baud rate.
*------------------------------------------------------------------------------
SYSCLK		EQU	7372800

*------------------------------------------------------------------------------
* SCC1 baud rate value - make sure SYSCLK is set correctly!
*------------------------------------------------------------------------------
SER1_BAUD		EQU	((SYSCLK>>4)/38400)-1
SER1_BUFSIZE	EQU	128

*------------------------------------------------------------------------------
* Helpers for the 68302 chip select base and option registers
* CS0 selects the ROM
* CS1 selects the RAM
* CS2 selects RCBus MEM space (A16=0) or IO space (A16=1)
*
* NOTES:
* + These settings are for when the ROM/RAM switch has happened.
* + OR in 0x0001 to the BR values to set the ENABLE bit for the chip select logic!
*------------------------------------------------------------------------------
CS0_BR		EQU	(ROM_BASE>>11)|$0001
CS0_OR		EQU	(~(ROM_SIZE-1)>>11)&$1FFC
CS1_BR		EQU	(RAM_BASE>>11)|$0001
CS1_OR		EQU	(~((RAM_SIZE-1)>>11))&$1FFC
CS2_BR		EQU	(RCBUS_BASE>>11)|$0001
CS2_OR		EQU	(~((RCBUS_SIZE-1)>>11))&$1FFC

*******************************************************************************
*
*  ####### #     #  #####  ####### ######  ####### ### ####### #     #  #####  
*  #        #   #  #     # #       #     #    #     #  #     # ##    # #     # 
*  #         # #   #       #       #     #    #     #  #     # # #   # #       
*  #####      #    #       #####   ######     #     #  #     # #  #  #  #####  
*  #         # #   #       #       #          #     #  #     # #   # #       # 
*  #        #   #  #     # #       #          #     #  #     # #    ## #     # 
*  ####### #     #  #####  ####### #          #    ### ####### #     #  #####  
*                                                                             
*******************************************************************************
* 68302 Exception Vector Table - to be copied into RAM at address 0x000000
* NOTE: The reset value in Base Register 0 (BR0) configures the ROM chip select
* (/CS0) so that ROM appears at address 0x000000. The initial PC value in the
* table has to point to the address of the startup code when the ROM is at
* address 0x000000. Subtract ROM_BASE from the address of the label START. 
*******************************************************************************
   
    ORG     ROM_BASE

    DC.L    STACK_START    *00 Supervisor stack pointer
    DC.L    START-ROM_BASE *01 Initial PC (adjusted for the ROM being at 0x000000)

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
    DC.L    easy68kTrap15  *2F TRAP #15 Instruction Vector

*------------------------------------------------------------------------------
* Exception Vectors 30 to 7F are not used on my system so just point them
* all to the default handler.

	DCB.L	80,handleUnused

*------------------------------------------------------------------------------
* The MC68302 GIMR should have the V7-V5 bits set to 100 so that the MC68302
* internal peripherals will use exception vectors $80 to $97.

	DC.L	handleUnused		*80 Error
	DC.L	handleUnused		*81 General purpose interrupt #0 (PB8)
	DC.L	handleUnused		*82 SMC2
	DC.L	handleUnused		*83 SMC1
	DC.L	handleUnused		*84 Timer 3
	DC.L	handleUnused		*85 SCP
	DC.L	handleUnused		*86 Timer 2
	DC.L	handleUnused		*87 General purpose interrupt #1 (PB9)
	DC.L	handleUnused		*88 SCC3
	DC.L	handleUnused		*89 Timer 1
	DC.L	handleUnused		*8A SCC2
	DC.L	handleUnused		*8B IDMA
	DC.L	handleUnused		*8C SDMA BErr
	DC.L	handleUnused		*8D SCC1
	DC.L	handleUnused		*8E General purpose interrupt #2 (PB10)
	DC.L	handleUnused		*8F General purpose interrupt #3 (PB11)
	DC.L	handleUnused		*90 (Unassigned)
	DC.L	handleUnused		*91 External Device
	DC.L	handleUnused		*92 (Unassigned)
	DC.L	handleUnused		*93 (Unassigned)
	DC.L	handleUnused		*94 (Unassigned)
	DC.L	handleUnused		*95 (Unassigned)
	DC.L	handleUnused		*96 External Device
	DC.L	handleUnused		*97 External Device

*------------------------------------------------------------------------------
* Interrupt Vectors $98 to $FF are not used on my system so just point them
* all to the default handler.

	DCB.L	104,handleUnused

*******************************************************************************
*
*   #####  ####### #       ######            #####  #######    #    ######  ####### 
*  #     # #     # #       #     #          #     #    #      # #   #     #    #    
*  #       #     # #       #     #          #          #     #   #  #     #    #    
*  #       #     # #       #     #           #####     #    #     # ######     #    
*  #       #     # #       #     #                #    #    ####### #   #      #    
*  #     # #     # #       #     #          #     #    #    #     # #    #     #    
*   #####  ####### ####### ######            #####     #    #     # #     #    #    
*
*******************************************************************************
* This code needs to go immediately after the exception vector table so that it
* lies within the first 8K of the ROM.
*
* NOTE: RAM is not accessible until BR1 and OR1 are both programmed.
*******************************************************************************

    ORG		(*+1)&-2					* make sure we start on a word aligned address
START:
	move.w	#$2700,sr					* mask off all interrupts
	move.w	#(M302_BASE_ADDR>>12),M302_BAR		* 68302 BAR points to 0xFFF000
	move.l	#(M302_BASE_ADDR+$240),sp	* initial stack at top of 68302 user RAM

	* Base Register 0 (BR0) and Option Register 0 (OR0) default to mapping /CS0
	* for an 8K block of memory starting at address 0x000000. This should be
	* enough for what we need to do to reconfigure the ROM and RAM addresses.

	* Configure Base Register 1 (BR1) and Option Register 1 (OR1) for /CS1
	* (i.e. the RAM) to be a 1MB block starting at ROM_BASE (yes, ROM_BASE!)
	* so that RAM is located where the ROM will be after the swap.
	move.w	#CS0_BR,M302_BR1		* Base Register 1
	move.w	#CS0_OR,M302_OR1		* Option Register 1

	* ROM (/CS0) is now at 0x000000 (default at reset) and RAM (/CS1) will
	* start at ROM_BASE.
  
	* NOTE: Disable the function code comparison first otherwise you can't copy
	* code and data from the ROM.
	andi.w	#$FFFE,M302_OR0

*------------------------------------------------------------------------------
* Copy the exception vector table from ROM to RAM
* The swap hasn't happened yet so ROM is at 0x000000 (i.e. RAM_BASE) and RAM
* starts at ROM_BASE!
*------------------------------------------------------------------------------

    movea.l #$000000,a0    			* A0 = start address of ROM
    movea.l #ROM_BASE,a1    		* A1 = start address of RAM before the swap
    move.w  #255,d1        			* D0 = number of longwords to copy - 256 but
                            		* DBRA needs 1 count less
.vtcopy:
    move.l  (a0)+,(a1)+     		* copy the bytes from ROM to RAM
    dbra    d1,.vtcopy	

*------------------------------------------------------------------------------
* Copy the ROM & RAM address swap code into the 68302 Dual Port RAM
* A0 holds the start address of the swap code in ROM when the ROM is mapped to
* address 0x000000 - i.e. on startup.
*------------------------------------------------------------------------------

    movea.l #dprCodeStart-ROM_BASE,a0
    movea.l #M302_BASE_ADDR,a1  * A1 = start address of the 68302 DP RAM
    move.l  #DPR_CODE_LEN,d2    * D2 = number of bytes to copy
.swcopy:
    move.b  (a0)+,(a1)+     	* copy the byte from EEROM to DP RAM
    dbra    d2,.swcopy

*------------------------------------------------------------------------------
* The switching code is now in DP RAM inside the 68302 so jump to it to perform
* the switch.
*------------------------------------------------------------------------------

	jmp		(M302_BASE_ADDR).L

*------------------------------------------------------------------------------
* This is the code that remaps the ROM and RAM addresses. It should be copied
* into the start of Dual Port RAM of the 68302 (i.e. M302_BASE_ADDR defined in
* mc68302.inc)
*------------------------------------------------------------------------------
dprCodeStart:
	move.w	#CS0_BR,M302_BR0		* Base Register 0
	move.w	#CS0_OR,M302_OR0		* Option Register 0

	move.w	#CS1_BR,M302_BR1		* Base Register 1
	move.w	#CS1_OR,M302_OR1		* Option Register 1

	* the ROM on CS0 is now mapped to start at address ROM_BASE
	* and the RAM on CS1 is now mapped to start at RAM_BASE (i.e. 0x000000)
	* so now return to the ROM code at its proper address.
	jmp		(dprReturn).L
	
DPR_CODE_LEN	EQU	*-dprCodeStart

*------------------------------------------------------------------------------
* Jump back to here from the switching code in the 68302 DP RAM.
* RAM should now be available from 0x000000 to RAM_LEN and the ROM should be
* positioned correctly starting at ROM_BASE.
*------------------------------------------------------------------------------
dprReturn:
	* setup the MC68302 chip select #2 for 128K of RCBus
	move.w	#(CS2_OR|$4000),M302_OR2	* DTACK after 2 wait states
	move.w	#(CS2_BR|$0001),M302_BR2	* enable CS2

*------------------------------------------------------------------------------
* Configure the 68302 interrupts
*------------------------------------------------------------------------------

	move.w	#$80,M302_GIMR			* normal mode, vectors 80+
	move.w	#0,M302_IMR				* no interrupts
	move.w	#$FFFF,M302_IPR			* clear pending interrupts
	move.w	#$FFFF,M302_ISR			* clear in-service

	* make sure that the stack pointer is initialised
    lea     STACK_START,sp

    * configure SCC1
	bsr		SCC1Init

*******************************************************************************
* The 68302 should now be set up with ROM and RAM at their correct addresses
* in the memory space. Jump to the monitor code from here.
*******************************************************************************

	jmp		(monStart).L

*******************************************************************************
* Below are the actual exception handlers that are accessed from the vector
* table in RAM. The user can overwrite any of the RAM vector table addresses
* with the address of their own exception handler. These handlers simply output
* a message to the serial port and enter an endless loop.
*******************************************************************************

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
* after the exception occured and then enter an endless loop.
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

*******************************************************************************
*
*  #     #    #    ######  #     #           #####  #######    #    ######  ####### 
*  #  #  #   # #   #     # ##   ##          #     #    #      # #   #     #    #    
*  #  #  #  #   #  #     # # # # #          #          #     #   #  #     #    #    
*  #  #  # #     # ######  #  #  #           #####     #    #     # ######     #    
*  #  #  # ####### #   #   #     #                #    #    ####### #   #      #    
*  #  #  # #     # #    #  #     #          #     #    #    #     # #    #     #    
*   ## ##  #     # #     # #     #           #####     #    #     # #     #    #    
*
*******************************************************************************
                                                                                  
    ORG		(*+1)&-2					* make sure we start on a word aligned address
monStart:
    lea     strBanner1(PC), a0	* Show the monitor details
    bsr.w   putString

    lea		strCommands(PC), a0 * And the command help message
    bsr.w   putString

monLoop:
    lea     strPrompt(PC), a0   * Prompt
    bsr.w   putString

monLoop_NP:
	bsr.w	getCh			* get a character into D0
	bsr.w	chToUpper		* convert character to upper case
	
	cmpi.b	#ASCII_LF,d0	* ignore Line-Feed
    beq.s   monLoop

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
* (D)ump memory
* Display 256 bytes of memory as ASCII-HEX characters
*------------------------------------------------------------------------------
cmdDispMemory:
	bsr.w	putCh			* echo back the command character in D0
	move.b	#' ',d0
	bsr.w	putCh
	
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
	bsr.w	putCh			* echo back the command character in D0
	move.b	#' ',d0
	bsr.w	putCh

	clr.l	d2				* pre-set D2 to 0
	move.l	#8,d1			* read up to 8 digits
	bsr.w	hexToIntEcho	* from the serial port
	bcs.w	monLoop			* back to prompt if there's an error

    move.l  d0, a0			* copy start address into A0
    jsr     (a0)            * jump to user code
	
	lea		strUserReturn(PC),a0
    bsr.w   putString
	
    bra.w	monLoop

*------------------------------------------------------------------------------
* (I)nput a byte from I/O space address
*------------------------------------------------------------------------------
cmdIORead:
	bsr.w	putCh			* echo back the command character in D0
	move.b	#' ',d0
	bsr.w	putCh

	clr.l	d2				* pre-set D2 to 0
	move.l	#2,d1			* read up to 2 digit address
	bsr.w	hexToIntEcho	* from the serial port
	bcs.w	monLoop			* back to prompt if there's an error
	move.b	d0,d3			* save the typed in 8-bit address
	move.b	#'=',d0
	bsr.w	putCh			* send an EQUALS

	; D3 = 8-bit address
	movea.l	#RCIO_BASE,a0
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
	bsr.w	putCh			* echo back the command character in D0
	move.b	#' ',d0
	bsr.w	putCh

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
	bsr.w	putCh
	move.b	(a0),d0			* get the current memory contents
	move.b	d0,d2			* pre-set D2 to the existing memory value
	bsr.w	writeByte		* display the byte
	move.b	#' ',d0
	bsr.w	putCh
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
	bsr.w	putCh			* echo back the command character in D0
	move.b	#' ',d0
	bsr.w	putCh

	clr.l	d2				* pre-set D2 to 0
	move.l	#2,d1			* read up to 2 digit address
	bsr.w	hexToIntEcho	* from the serial port
	bcs.w	monLoop			* back to prompt if there's an error
	move.b	d0,d3			* save the typed in 8-bit address
	move.b	#'=',d0
	bsr.w	putCh			* send an EQUALS

	clr.l	d2				* pre-set D2 to 0
	move.l	#2,d1			* read up to 2 digit value
	bsr.w	hexToIntEcho	* from the serial port
	bcs.w	monLoop			* back to prompt if there's an error

	; D0 = value and D3 = 8-bit address
	movea.l	#RCIO_BASE,a0
	andi.l	#$FF,d3			* clear all the unused bits
	asl.l	#1,d3			* make it a word offset
	addi.l	#1,d3			* make it an odd address to write to D0..D7
	move.b	d0,(0,a0,d3)	* and write the new value out

	bsr.w	putCRLF
    bra.w	monLoop

*------------------------------------------------------------------------------
* (S) - download a single line of a Motorola S-Record
*------------------------------------------------------------------------------
* Decode a single s-record that is held in one of the rx buffers and write it
* directly to RAM.
* A0 points to the SCC rx buffer holding the record inc the 'S' char
* A2 points to the SCC rx buffer descriptor flags register
*
* D0 = 0 if checksum OK or -1 if any error
* Uses:
*  D3 - running checksum
*------------------------------------------------------------------------------
cmdDownload:
    clr.l   d3              * running checksum sum = 0
    addq.l  #1, a0          * skip over 'S'

    move.b  (a0)+, d0       * get s-record type
    sub.b   #'0', d0
    move.b  d0, srecType

    bsr     readHexByte     * read byte count
    move.b  d0, srecByteCnt
    add.b   d0, d3          * add byte count to checksum

    * Decode address based on record type
	clr.l   d4              * D4 holds destination address
	cmp.b   #1, srecType
	beq.s   .addr2bytes
	cmp.b   #2, srecType
	beq.s   .addr3bytes
	cmp.b   #3, srecType
	beq.s   .addr4bytes
	bra    .ignore

.addr4Bytes:
	bsr     readHexByte
	add.b   d0, d3			* update checksum
	move.b  d0, d4          * addr bits 24..31
	lsl.l	#8, d4			* shift ready for next byte
	subi.b	#1, srecByteCnt * decrement byte count
	
.addr3Bytes:
	bsr     readHexByte
	add.b   d0, d3			* update checksum
	move.b  d0, d4          * addr bits 16..23
	lsl.l	#8, d4			* shift ready for next byte
	subi.b	#1, srecByteCnt * decrement byte count

.addr2Bytes:
	bsr     readHexByte
	add.b   d0, d3			* update checksum
	move.b  d0, d4          * addr bits 8..15
	lsl.l	#8, d4			* shift ready for next byte
	bsr     readHexByte
	add.b   d0, d3			* update checksum
	move.b  d0, d4          * addr bits 0..7
	subi.b	#3, srecByteCnt * decrement byte count by 2 (+1 for csum)

	* D4 now holds the destination address
    move.l  d4, a1          * A1 = target address to store data
	move.b	srecByteCnt, d4 * D4 = no of data bytes to read in

    * Read data bytes and store at (A1)
.rdLoop:
	tst.b   d4              * have we done yet?
	beq.s   .rdChecksum
	bsr     readHexByte
	add.b   d0, d3			* update checksum
	move.b  d0, (a1)+       * write byte to memory
	subq.b  #1, d4          * decrement byte count
    bra.s   .rdLoop

.rdChecksum:
	bsr     readHexByte     * D0 = checksum byte
	add.b   d0, d3          * final sum
	cmpi.b  #$ff, d3        * all good if D3 = $FF
	beq.s   .ok
.fail:
	ori.w	#$8000,(A2)     * signal buffer is free
	move.b  #'X', d0		* checksum fail - print an X
	bsr     putCh
    bra.w	monLoop_NP		* return to main loop without prompt
.ok:
	ori.w	#$8000,(A2)     * signal buffer is free
	move.b  #'.', d0		* checksum good - print a dot
	bsr     putCh
    bra.w	monLoop_NP		* return to main loop without prompt
.ignore:
	ori.w	#$8000,(A2)     * signal buffer is free
	move.b  #'?', d0		* unsupported record type - question mark
	bsr     putCh
	bsr.w	putCRLF
    bra.w   monLoop

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
    bsr.w   putCh			* insert a space
	dbra	d2,.dr_2

    move.b  #' ', d0
    bsr.w   putCh			* insert a space

	move.b	#ASCII_CR,(a0)+
	move.b	#ASCII_LF,(a0)+
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
	bsr.w	getCh			* get a character
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
	bsr.w	getCh			* get a character
	bsr.w	putCh			* echo it back
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

*------------------------------------------------------------------------------
* ReadHexByte - read two ASCII hex chars at (A0)+
* Uses: D1
* Ret:  D0 = binary byte
*------------------------------------------------------------------------------
ReadHexByte:
	move.b  (a0)+, d1
	bsr     HexCharToNibble
	lsl.w   #8, d0          * save nibble in bits 8..11
	move.b  (a0)+, d1
	bsr     HexCharToNibble
	lsl.b	#4, d0          * shift nibble into bits 4..7
	lsr.w	#4, d0          * shift whole byte into bits 0..7
	rts

*------------------------------------------------------------------------------
* HexCharToNibble - convert ASCII hex char in D1 to nibble
* Ret:  D0 = converted char
*------------------------------------------------------------------------------
HexCharToNibble:
	move.b  d1, d0          * move char to D0
	cmp.b   #'0', d0        * compare with ASCII char '0'
	blt.s   .HexError       * error if it's less than '0'
	cmp.b   #'9', d0        * compare with ASCII char '9'
	ble.s   .IsDigit        * it's a digit if less than '9'
	cmp.b   #'A', d0        * compare with ASCII char 'A'
	blt.s   .HexError       * error if it's less than 'A'
	cmp.b   #'F', d0        * compare with ASCII char 'F'
	ble.s   .IsUpper        * it's between 'A' and 'F'
	cmp.b   #'a', d0        * compare with ASCII char 'a'
	blt.s   .HexError       * error if it's less than 'a'
	cmp.b   #'f', d0        * compare with ASCII char 'f'
	bgt.s   .HexError       * error if it's greater than 'f'
	sub.b   #'a', d0
	add.b   #10, d0
	rts
.IsUpper:
	sub.b   #'A', d0
	add.b   #10, d0
	rts
.IsDigit:
	sub.b   #'0', d0
	rts
.HexError:
	moveq   #0, d0
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
    
    bsr.w   putCh		 * Otherwise write the character
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
    
    bsr.w   putCh		 * Otherwise write the character
    dbra	d1,.loop	 * And continue
.end:
    rts

*------------------------------------------------------------------------------
* EASy68K TRAP #15 - Task 5
* Read single ASCII character from the keyboard into D1.B. 
*------------------------------------------------------------------------------
easyTask5:
	bsr.w	getCh		* wait for char - returned in D0
	move.b	d0,d1		* move the char into D1
	rts
	
*------------------------------------------------------------------------------
* EASy68K TRAP #15 - Task 6
* Display single ASCII character in D1.B.   
*------------------------------------------------------------------------------
easyTask6:
	move.b	d1,d0		* move the char into D0
	bsr.w	putCh		* output the char
	rts

*------------------------------------------------------------------------------
* EASy68K TRAP #15 - Task 7
* Check for keyboard input. Set D1.B to 1 if keyboard input is pending,
* otherwise set to 0.
*------------------------------------------------------------------------------
easyTask7:
	bsr.w	chkCh
	rts

*------------------------------------------------------------------------------
* EASy68K TRAP #15 - Task 13
* Display the NULL terminated string at (A1) with CR, LF.
*------------------------------------------------------------------------------
easyTask13:
	exg		a0,a1			* A0 now holds the pointer to the string
	bsr.w	putString
	bsr.w	putCRLF			* append CR & LF
    rts

*------------------------------------------------------------------------------
* EASy68K TRAP #15 - Task 14
* Display the NULL terminated string pointed to by (A1).
*------------------------------------------------------------------------------
easyTask14:
	exg		a0,a1			* A0 now holds the pointer to the string
	bsr.w	putString
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

*--------------------------------------------------------------------------
* Initialise SCC1 as a UART - Section E.2 of the 68302UM
* Uses 1 Tx buffer and 2 Rx buffers, all held in external RAM.
* Baud rate is set by SER1_BAUD defined at the top of this file.
* Tx and Rx buffer sizes are set by SER1_BUFSIZE defined at the top of this file.
*
* NOTE:
* An Rx buffer will become ready for reading if:
* - A special character is received
* - Max characters received - set by value in MRBLR registers
* - A gap between characters received greater than MAXIDL
*--------------------------------------------------------------------------
SCC1Init:
	move.w	#$00C0,M302_SIMODE
	move.w	#(SER1_BAUD<<1),M302_SCON1	* set SCC1 baud rate
	move.w	#$0101,M302_SCM1				* set SCC1 to UART mode 8N1

	* TxBD0 in internal RAM
	move.w	#$2000,M302_SCC1PB+M302_TXBD0		* INT RAM - first and only tx buffer
	move.w	#$0000,M302_SCC1PB+M302_TXBD0+2	* no bytes in tx buffer
	move.l	#SCC1TXB0,M302_SCC1PB+M302_TXBD0+4

	* RxBD0 in internal RAM
	move.w	#$8000,M302_SCC1PB+M302_RXBD0		* first rx buffer
	move.l	#SCC1RXB0,M302_SCC1PB+M302_RXBD0+4

	* RxBD1 in internal RAM
	move.w	#$A000,M302_SCC1PB+M302_RXBD1		* second and final rx buffer
	move.l	#SCC1RXB1,M302_SCC1PB+M302_RXBD1+4

	move.b	#$20,M302_SCC1PB+M302_RFCR
	move.b	#$20,M302_SCC1PB+M302_TFCR
	
	* set the max rx buffer length to slightly less than the actual max size
	move.w	#SER1_BUFSIZE-4,M302_SCC1PB+M302_MRBLR
	
	* set MAXIDL to about 10mS - i.e. the time taken for 38 chars @ 38400 baud
	* if another char isn't received within 10mS, then buffer will be closed 
	move.w	#38,M302_SCC1PB+M302_MAXIDL		* set MAXIDL to a small value
	
	move.w	#0,M302_SCC1PB+M302_BRKCR			* no BREAK characters
	
	move.w	#0,M302_SCC1PB+M302_PAREC			* reset PARITY ERROR counter
	move.w	#0,M302_SCC1PB+M302_FRMEC			* reset FRAME ERROR counter
	move.w	#0,M302_SCC1PB+M302_NOSEC			* reset NOISE counter
	move.w	#0,M302_SCC1PB+M302_BRKEC			* reset BREAK counter
	
	move.w	#0,M302_SCC1PB+M302_UADDR1		* clear UART adress characters
	move.w	#0,M302_SCC1PB+M302_UADDR2

	move.w	#$000D,M302_SCC1PB+M302_CCHAR1	* CR is a special character
	move.w	#$8000,M302_SCC1PB+M302_CCHAR2	* no more special characters
	move.w	#0,M302_SCC1PB+M302_CCHAR8
	
	move.b	#$FF,M302_SCCE1              * clear any SCC1 events
	move.b	#0,M302_SCCM1                * no interrupts from SCC1
	ori.w	#$000C,M302_SCM1				* enable SCC1 Tx & Rx

	rts
	
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
    bsr     putCh       ; write the ASCII digit out
    move.b  (sp)+,d0    ; restore D0
    rts

*------------------------------------------------------------------------------
* Prints a newline (CR, LF)
* NOTE: the putString function must follow this function
*------------------------------------------------------------------------------
putCRLF:
    lea     strNewline(PC), a0

*------------------------------------------------------------------------------
* Write a null terminated string to SCC1, blocking if tx buffer is not ready
* A0 holds the address of the first character of the null terminated string
*------------------------------------------------------------------------------
putString:
	movem.l d0/a1,-(sp)				* save d0 & a1

.ps_1:
	btst.b	#7,M302_SCC1PB+M302_TXBD0			* test the R bit in TXBD0
	bne.s	.ps_1					* test again if R=1

	* SCC1 TX buffer #0 is available for use
	movea.l	#SCC1TXB0,a1			* A1 points to SCC1 Tx buffer
	clr.l	d0						* clear our char counter

.ps_2:
	move.b	(a0)+,(a1)+				* copy the char to SCC1 Tx buffer
	beq.s	.ps_ex					* done if it's a NULL
	addq.w	#1,d0					* increment tx buffer char count
	cmpi.w	#SER1_BUFSIZE-1,d0		* have we filled the tx buffer?
	bne.s	.ps_2
	
	* SCC1 TX buffer is full so send it
	move.w	d0,M302_SCC1PB+M302_TXBD0+2		* write number of chars to send
	ori.w	#$8000,M302_SCC1PB+M302_TXBD0		* signal tx buffer ready
	bra.s	.ps_1					* go back and wait for buffer to empty

.ps_ex:
	move.w	d0,M302_SCC1PB+M302_TXBD0+2		* write number of chars to send
	ori.w	#$8000,M302_SCC1PB+M302_TXBD0		* signal tx buffer ready

	movem.l (sp)+,d0/a1				* restore d0 & a1
	rts

*------------------------------------------------------------------------------
* Write a character to SCC1, blocking if UART is not ready
* D0 = char to send
*------------------------------------------------------------------------------
putCh:
	btst.b	#7,M302_SCC1PB+M302_TXBD0			* test the R bit in TXBD0
	bne.s	putCh					* test again if R=1

	* SCC1 TX buffer is available for use
	move.b	d0,SCC1TXB0				* write the char to the tx buffer
	move.w	#1,M302_SCC1PB+M302_TXBD0+2		* set 1 char to send
	ori.w	#$8000,M302_SCC1PB+M302_TXBD0		* signal tx buffer ready
	rts

*------------------------------------------------------------------------------
* Read a character from SCC1 - blocking call so will wait for character
* Check both Rx buffers for a character. If it's an S, then don't free the
* buffer as the S-record routine will do that.
* D0 = recevied char
* If it's an S-record then A0=addr of buffer & A2=addr of flags
*------------------------------------------------------------------------------
getCh:
    * check Rx buffer #0
	move.w	M302_SCC1PB+M302_RXBD0,d0			* read RxBD #0 status flags
	andi.w	#$8000,d0				* mask all but the empty flag
	bne.s	.getCh1					* check RxBD #1
	
	move.b	SCC1RXB0,d0				* get the received char
    cmpi.b  #'S',d0                 * is it the start of an S-record?
    bne.s   .ex1
    move.l  #SCC1RXB0,a0            * A0 = addr of buffer
    move.l  #M302_SCC1PB+M302_RXBD0,a2        * A2 = addr of buffer flags
    rts                             * exit without freeing buffer
.ex1:
	ori.w	#$8000,M302_SCC1PB+M302_RXBD0		* signal buffer is free
    rts

.getCh1:
    * check Rx buffer #1
	move.w	M302_SCC1PB+M302_RXBD1,d0			* read RxBD #1 status flags
	andi.w	#$8000,d0				* mask all but the empty flag
	bne.s	getCh					* check RxBD #0 again
	
	move.b	SCC1RXB1,d0				* read the receved char
    cmpi.b  #'S',d0                 * is it the start of an S-record?
    bne.s   .ex2
    move.l  #SCC1RXB1,a0            * A0 = addr of buffer
    move.l  #M302_SCC1PB+M302_RXBD1,a2        * A2 = addr of buffer flags
    rts                             * exit without freeing buffer
.ex2:
	ori.w	#$8000,M302_SCC1PB+M302_RXBD1		* signal buffer is free
    rts

*------------------------------------------------------------------------------
* Check for a character received on SCC1
* Check both Rx buffers for a character.
* Set D1.B to 1 if keyboard input is pending, otherwise set to 0.
*------------------------------------------------------------------------------
chkCh:
    * check Rx buffer #0
	move.w	M302_SCC1PB+M302_RXBD0,d0			* read RxBD #0 status flags
	andi.w	#$8000,d0				* mask all but the empty flag
	bne.s	.chkRx1					* no char so check RxBD #1
	
	move.b	#1,d1					* signal there's a char available
    rts

.chkRx1:
    * check Rx buffer #1
	move.w	M302_SCC1PB+M302_RXBD1,d0			* read RxBD #1 status flags
	andi.w	#$8000,d0				* mask all but the empty flag
	bne.s	chkCh_ex				* checks done - no char available
	
	move.b	#1,d1					* signal there's a char available
    rts

chkCh_ex:
	move.b	#0,d1					* signal there's no char available
    rts

*------------------------------------------------------------------------------
* String constants
*------------------------------------------------------------------------------
strBanner1:
	dc.b 10,13
	dc.b 'Simple RCBus 68302 (sw) ROM Monitor v1.0',10,13
	dc.b 'ROM: 0x600000 .. 0x6FFFFF',10,13
	dc.b 'RAM: 0x000000 .. 0x0FFFFF',10,13,0
strCommands:
    dc.b 10,13,'Commands: ',10,13
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
strUserReturn:
    dc.b 10,13,'User program completed.',10,13,0
strEasyTask1:
	dc.b	10,13,'STOP: EASy68K TRAP #15 - Task ',0
strEasyTask2:
	dc.b	' not yet implemented',10,13,0

*------------------------------------------------------------------------------
* put the SCC1 Tx and Rx buffers in internal 68302 RAM
*------------------------------------------------------------------------------
	org		M302_BASE_ADDR
	
* SCC1 RX and Tx buffers - 1 Tx and 2 Rx
SCC1TXB0:	ds.b	SER1_BUFSIZE
SCC1RXB0:	ds.b	SER1_BUFSIZE
SCC1RXB1:	ds.b	SER1_BUFSIZE

*------------------------------------------------------------------------------
* Monitor variables
*------------------------------------------------------------------------------
	ORG		STACK_START
msgASCIIDump:
	ds.b 20
serBuff:   
	ds.b	8
	
    ORG		(*+1)&-2	   * force word alignment

srecAddr:      ds.l 1
srecType:      ds.b 1
srecByteCnt:   ds.b 1

    END    START            * last line of source































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
