*------------------------------------------------------------------------------
* 25LC256.X68
*------------------------------------------------------------------------------
* Simple program to read some bytes from a Microchip 25LC256 SPI EEPROM that is
* connected to the SD card adapter slot on the SC611.
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

READCMD		EQU		$03

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
	
	* Read 2 bytes from address $0000.
	* The 2 bytes are an address of a null termianted string in the EEPROM.
	andi.b	#~SDCS,d1			* set the EEPROM CS low
	move.b	d1,SC611
	move.b	#READCMD,d0
	bsr.w	spiXfer				* send READ command
	move.w	#$0000,d0
	bsr.w	spiXfer16			* send 16 bit memory address
	move.w	#$FFFF,d0
	bsr.w	spiXfer16			* get 16 bit address of text string
	ori.b	#SDCS,d1			* set the SD card CS high
	move.b	d1,SC611
	
	rol.w	#8,d0				* swap high and low bytes
    move.w  d0,-(sp)    		* save the 16-bit address
	bsr.w	writeWord			* display the start address of the text string
	
    lea     strText(PC), a1		* Show text
	move.b	#14,d0				* EASy68K task 14
	trap	#15

	* Read the null terminated text string from EEPROM
	andi.b	#~SDCS,d1			* set the EEPROM CS low
	move.b	d1,SC611
	move.b	#READCMD,d0
	bsr.w	spiXfer				* send READ command
    move.w  (sp)+,d0    		* restore the 16-bit address
	bsr.w	spiXfer16			* send 16 bit memory address
rdloop:
	move.b	#$FF,d0
	bsr.w	spiXfer				* get the character
	cmpi.b	#0,d0				* is it a NULL?
	beq.s	done				* if NULL then we're done
	bsr.w	putc				* display character
	bra.s	rdloop				* go back for next character
done:
	ori.b	#SDCS,d1			* set the SD card CS high
	move.b	d1,SC611

	bsr.w	putCRLF
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
    lea     strNewline(PC), a1
	move.b	#14,d0				* EASy68K task 14
	trap	#15
	rts
	
*------------------------------------------------------------------------------
* Write a character to UART Port A, blocking if UART is not ready
* D0 = char to send
*------------------------------------------------------------------------------
putc:
	movem.l	d0-d1,-(sp)		* save d0, d1
	move.b	d0,d1			* copy character
	moveq	#6,d0			* character out
	trap	#15				* call simulator I/O function
	movem.l	(sp)+,d0-d1		* restore d0, d1
	rts

strTitle:
	dc.b	'RCBus 68000 Micro SD Demo - SC611 @ Address 0x69.',10,13
	dc.b	'Read some data from a Microchip 25LC256 EEPROM.',10,13,10,13
	dc.b	'Text string starts at address $',0
strText:
	dc.b	10,13,'TEXT: ',0
strNewline:
    dc.b 10,13,0
	
	END START
	



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
