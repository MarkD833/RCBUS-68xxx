*------------------------------------------------------------------------------
* HELLO.X68
*------------------------------------------------------------------------------
* Simple program to use an SC705 (MC68B50) as another UART.
* It transmits the string "Hello World!" at 57600,8,N,1.
*
* My board has a 3.3864MHz crystal fitted as X1. The SC705 design actually
* uses a 7.3728MHz crystal but I didn't have one to hand, therefore the
* baud rate is 57600 (for 3.3864MHz) instead of 115200 (for 7.3728MHz).
*
* Assumes that the SC705 is at I/O address 0xD0.
*

	INCLUDE "..\asm-inc\memory.inc"

*******************************************************************************
* These addresses are as configured on the individual boards in what would be
* the Z80 8-bit I/O space.
*
SC705ADDR	EQU		$D0			* SC705 address is 0xD0

*******************************************************************************
* These are the Z80 8-bit I/O space addresses converted into 68000 memory space
*
SC705		EQU		IO_BASE+(SC705ADDR<<1)+1

* MC6850 UART register definitions
CTRL		EQU		SC705
TXRX		EQU		SC705+2

	ORG		$110000

START:
    lea     strTitle(PC), a1	* Show the program details
	move.b	#14,d0				* EASy68K task 14
	trap	#15

	move.b	#$16,d0				* div 64, 8N1, INT disabled
	move.b	d0,CTRL
	
	nop
	nop
	nop

    lea     strMessage(PC), a1	* point to the message to transmit
.loop:
    move.b  (a1)+, d0    		* Read in character
    beq.s   .end         		* Check for the null

	* wait for tx buffer to be empty
.wait:
	move.b	CTRL,d1				* get current UART status
	andi.b	#$02,d1				* mask all but bit 1 (TDRE bit)
	beq.s	.wait
	
	move.b	d0,TXRX				* write the character to the UART
	bra.s	.loop				* go back for next character

.end:
    lea     strReturn(PC), a1	* Show the finished message
	move.b	#14,d0				* EASy68K task 14
	trap	#15

ENDLESS:
	bra.s	ENDLESS				* stay here till reset
	
	
strTitle:
	dc.b	'RCBus 68000 SC705 68B50 UART demo #1.',10,13
	dc.b	'Assumes SC705 is present at I/O address 0xD0.',10,13,0
strReturn:
	dc.b	10,13,'Press RESET to return to the monitor.',10,13,0
strMessage:
	dc.b	'Hello World!',10,13,0	

	END		START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
