*------------------------------------------------------------------------------
* ECHO.X68
*------------------------------------------------------------------------------
* Simple program to use an SC705 (MC68B50) as another UART.
* Simply echoes back any character received.
*
* My board has a 3.3864MHz crystal fitted as X1. The SC705 design actually
* uses a 7.3728MHz crystal but I didn't have one to hand!
*
* Assumes that the SC705 is at I/O address 0xD0.
*

IO_BASE		EQU		$F00000		* I/O space base addr = 00F0_0000
SC705ADDR	EQU		$D0			* SC705 address is 0xD0

SC705		EQU		IO_BASE+1+(SC705ADDR<<1)

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

	* wait for rx buffer to hold a character
.loop:
	move.b	CTRL,d1				* get current UART status
	andi.b	#$01,d1				* mask all but bit 0 (RDRF bit)
	beq.s	.loop

	* a characer has been received so read it in
	move.b	TXRX,d0				* D0 = character recevied
	
	* wait for tx buffer to be empty
.wait:
	move.b	CTRL,d1				* get current UART status
	andi.b	#$02,d1				* mask all but bit 1 (TDRE bit)
	beq.s	.wait

	* tx buffer is empty so write the character back out
	move.b	d0,TXRX				* write the character to the UART
	bra.s	.loop				* go back for next character

strTitle:
	dc.b	'RCBus 68000 SC705 68B50 UART demo #2.',10,13
	dc.b	'Assumes SC705 is present at I/O address 0xD0.',10,13
	dc.b	10,13,'Press RESET to return to the monitor.',10,13,0

	END		START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
