*------------------------------------------------------------------------------
* SPI_XFER.X68
*------------------------------------------------------------------------------
* Simple program to transfer some bytes using bit banged SPI via an SC611
* Micro SD module using SPI Mode 0.
*
* The SC611 should have jumpers set for I/O space address $69.
*
* SD card adapter CS is controlled by bit 3
* MOSI is controlled by bit 0
* SCK  is controlled by bit 4
* MISO is read in on bit 7
*
* Register D1 holds a working copy of the last byte written to the SC611
*

	INCLUDE "..\asm-inc\memory.inc"

SCK			EQU		$10
SDCS		EQU		$08
MOSI		EQU		$01
MISO		EQU		$80
	
*******************************************************************************
* These addresses are as configured on the individual boards in what would be
* the Z80 8-bit I/O space.
*
SC611ADDR   EQU     $69           * SC611 base address is 0x69

*******************************************************************************
* These are the Z80 8-bit I/O space addresses converted into 68000 memory space
*
SC611       EQU     IO_BASE+(SC611ADDR<<1)+1
	
    ORG     $110000

START:
    lea     strTitle(PC), a1	* Show the program details
	move.b	#14,d0				* EASy68K task 14
	trap	#15

	clr.l	d1

	; SPI Mode 0 so set SCK low (and make sure CS is high)
	move.b	#SDCS,d1
	move.b	d1,SC611

	; silly delay to let port settle
	move.l	#$FFFF,d0
.loop1:
	dbra	d0,.loop1
	
	* set the SD card socket CS low
	andi.b	#~SDCS,d1
	move.b	d1,SC611

	move.b	#$AA,d0
	bsr.w	spiXfer
	move.b	#$55,d0
	bsr.w	spiXfer
	move.b	#$F0,d0
	bsr.w	spiXfer
	move.b	#$0F,d0
	bsr.w	spiXfer
	
	move.w	#$1234,d0
	bsr.w	spiXfer16
	move.w	#$BEEF,d0
	bsr.w	spiXfer16
	
	* set the SD card socket CS high
	ori.b	#SDCS,d1
	move.b	d1,SC611
	rts
	
*------------------------------------------------------------------------------
* Exchange a single byte via SPI
* D0 holds the byte to send and the received byte
* D1 holds a working copy of the last byte written to the SC611 
* D2 holds the bit count
* D3 holds current read state of the SC611 port
*------------------------------------------------------------------------------
spiXfer:
	andi.l	#$FF,d0				* clear all bits but the lower 8 bits
	move.l	#7,d2				* 8 bits (DBRA needs 1 less)
.nextBit:
	lsr.b	#1,d1				* shift working copy right 1 bit
	lsl.b	#1,d0				* extend bit holds MOSI bit to send
	roxl.b	#1,d1				* shift extend bit into working copy
	
	move.b	d1,SC611			* write the new data bit out
	ori.b	#SCK,d1
	move.b	d1,SC611			* write the new clock bit out

	swap	d0					* get rx bits into LSW
	move.b	SC611,d3			* read the current state of the SC611
	lsl.b	#1,d3				* extend bit holds MISO bit received
	roxl.b	#1,d0				* shift extend bit into received byte
	
	andi.b	#~SCK,d1
	move.b	d1,SC611			* write the new clock bit out

	swap	d0					* get tx bits into LSW
	dbra	d2,.nextBit			* repeat for next bit

	* exchange done so switch the rx bits into the LSW
	swap	d0					* get rx bits back into LSW
	rts
	
*------------------------------------------------------------------------------
* Exchange a 16-bit word via SPI
* D0 holds the word to send and the received byte
* D1 holds a working copy of the last byte written to the SC611 
* D2 holds the bit count
* D3 holds current read state of the SC611 port
*------------------------------------------------------------------------------
spiXfer16:
	andi.l	#$FFFF,d0			* clear upper 16 bits
	move.l	#15,d2				* 16 bits (DBRA needs 1 less)
.nextBit:
	lsr.b	#1,d1				* shift working copy right 1 bit
	lsl.w	#1,d0				* extend bit holds MOSI bit to send
	roxl.b	#1,d1				* shift extend bit into working copy

	move.b	d1,SC611			* write the new data bit out
	ori.b	#SCK,d1
	move.b	d1,SC611			* write the new clock bit out

	swap	d0					* get rx bits into LSW
	move.b	SC611,d3			* read the current state of the SC611
	lsl.b	#1,d3				* extend bit holds MISO bit received
	roxl.w	#1,d0				* shift extend bit into received word

	andi.b	#~SCK,d1
	move.b	d1,SC611			* write the new clock bit out

	swap	d0					* get tx bits into LSW
	dbra	d2,.nextBit			* repeat for next bit

	* exchange done so switch the rx bits into the LSW
	swap	d0					* get rx bits back into LSW
	rts

	
strTitle:
	dc.b	'RCBus 68000 Micro SD Demo - SC611 @ Address 0x69',10,13,0

	END START
	
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
