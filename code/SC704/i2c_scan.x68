*------------------------------------------------------------------------------
* I2C_SCAN.X68
*------------------------------------------------------------------------------
* Simple program to scan the I2C bus via an SC704 I2C bus master card
* and report back any active I2C devices.
*
* SCL is controlled by bit 0 and SDA is controlled by bit 7.
*

IO_BASE		EQU		$F00000		* I/O space base addr = 00F0_0000
SC704ADDR	EQU		$0C			* SC704 default address is 12 (0x0C)

SC704		EQU		IO_BASE+1+(SC704ADDR<<1)

SDALO		EQU		$7F			* AND with this value
SDAHI		EQU		$80			* OR  with this value
SCLLO		EQU		$FE			* AND with this value
SCLHI		EQU		$01			* OR  with this value

	ORG		$110000

START:
    lea     strTitle(PC), a1	* Show the program details
	move.b	#14,d0				* EASy68K task 14
	trap	#15

	move.b	#8,d2				* D2 = current I2C address
LOOP:
	bsr.w	I2CSTART			* START condition
	move.b	d2,d0				* get the address to check
	asl.b	#1,d0				* shift address left 1 bit
	bsr.w	I2CWRITE
	bcs.s	NAK					* NACK = no device at that address
	
	move.b	d2,d0				* get the address just checked
	bsr.w	writeByte

    lea     strCRLF(PC), a1		* new line
	move.b	#14,d0				* EASy68K task 14
	trap	#15
NAK:
	bsr.w	I2CSTOP				* STOP condition
	addi.b	#1,d2				* increment the address
	nop
	nop
	cmpi.b	#128,d2				* has it reached 128 yet?
	bne.s	LOOP

    lea     strFinished(PC), a1	* finished
	move.b	#14,d0				* EASy68K task 14
	trap	#15

ENDLESS:
	bra.s	ENDLESS				* stay here till reset
	
	
*------------------------------------------------------------------------------
* Send START condition
* Assumes SDA and SCL are both HIGH already
* D1 holds the last value written to the SC704
*------------------------------------------------------------------------------
I2CSTART:
	move.b	#SCLHI,d1
	move.b	d1,SC704		* set SCL HIGH & SDA LOW
	nop
	nop
	clr.b	d1
	move.b	d1,SC704		* set SCL LOW & SDA LOW
	rts
	
*------------------------------------------------------------------------------
* write a byte - D0 holds the byte to send
* C is set for a NACK and clear for an ACK
* State of SCL & SDA held in D1
*------------------------------------------------------------------------------
I2CWRITE:
	move.w	#7,d3			* number of bits to send minus 1
.loop1:
	move.w	d0,-(sp)		* save the byte
	andi.b	#$80,d0			* get just MSB of the byte
	move.b	d0,SC704		* write out the bit with SCL LOW
	ori.b	#SCLHI,d0		* SCL bit HIGH
	move.b	d0,SC704		* write out the bit with SCL HIGH
	nop
	nop
	nop
	nop
	andi.b	#SCLLO,d0
	move.b	d0,SC704		* write out the bit with SCL LOW
	move.w	(sp)+,d0		* get the byte back
	rol.b	#1,d0			* shift so next bit to send is in the MSB
	dbra	d3,.loop1

	* done 8 bits so check for ACK or NACK
	move.b	#SDAHI,d0
	move.b	d0,SC704		* release the SDA line with SCL LOW
	nop
	nop
	ori.b	#SCLHI,d0		* SCL bit HIGH
	move.b	d0,SC704		* write out SCL HIGH (and SDA HIGH)
	nop
	nop
	move.b	SC704,d0		* read the current SCL & SDA states
	move.b	#SDAHI,SC704	* set SCL LOW (and SDA HIGH)

	* bit 7 in D0 now holds the ACK (=0) or NACK (=1) response
	asl.b	#1,d0			* carry flag now holds ACK/NACK response
	rts

*------------------------------------------------------------------------------
* Send STOP condition
* SCL will already be low
*------------------------------------------------------------------------------
I2CSTOP:
	move.b	#$00,SC704		* set SCL LOW & SDA LOW
	nop
	nop
	nop
	move.b	#$01,SC704		* set SCL HIGH & SDA LOW
	nop
	nop
	nop
	move.b	#$81,SC704		* set SCL HIGH & SDA HIGH
	rts

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
    movem.l  d0/d1,-(sp)    ; save D0 & D1 first
    andi.b  #$0F,d0     ; make sure we only have the lower 4 bits
    cmpi.b  #10,d0      ; compare D0 to 10
    bcs.b   .wn1        ; less than 10 so don't add 7
    addi.b  #07,d0      ; add 7
.wn1:
    addi.b  #'0',d0     ; add ASCII code for char zero
	move.b	d0,d1
	move.b	#6,d0		; EASy68K task 6
	trap	#15			; display the character	
    movem.l  (sp)+,d0/d1 ; restore D0 & D1
    rts
	

strTitle:
	dc.b	'RCBus 68000 I2C Scanner - SC704 @ Address 0x0C',10,13
	dc.b	'Scanning for devices ...',10,13,0
strAckMsg:
	dc.b	'ACK received',10,13,0
strNakMsg:
	dc.b	'NAK received',10,13,0
strFinished:
	dc.b	'Scan finished',10,13,0
strCRLF:
	dc.b	10,13,0
	
	END		START
	