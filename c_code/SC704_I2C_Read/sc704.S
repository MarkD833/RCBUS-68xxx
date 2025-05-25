/******************************************************************************
* RCBus MC68000
*******************************************************************************
*  #####    #####   #######    ###    #               ###   #####    #####  
* #     #  #     #  #    #    #   #   #    #           #   #     #  #     # 
* #        #            #    #     #  #    #           #         #  #       
*  #####   #           #     #     #  #    #   #####   #    #####   #       
*       #  #          #      #     #  #######          #   #        #       
* #     #  #     #    #       #   #        #           #   #        #     # 
*  #####    #####     #        ###         #          ###  #######   #####
********************************************************************************
* SC704 - I2C Bus Master module low level bit bang code.
* Does not support clock stretching or other clever I2C functionality.
* Developed using the Texas Instruments Basic Guide to I2C - Nov 2022 (SBAA565).
********************************************************************************
* This low level assembler code has been put together based on my earlier bit
* banged SPI code for the SC611 but with suitable massaging to make it work
* with the GNU Assembler.
* This may not be the correct way to implement this functionality but with my
* very limited knowledge of GCC, it worked for me after a lot of trial and error.
********************************************************************************
* Note: registers D0, D1, A0 & A1 appear to be free to use as you wish, but any
* other register used has to be restored to the original value before returning.
********************************************************************************
*/
        .title "sc704.S assembler support for the SC704 I2C card"
		
        .section .text
        .align 2

		.type i2cInit, @function
		.type i2cReadFrom, @function
		.type i2cWriteTo, @function
		.type i2cWrite, @function
		.type i2cRead, @function
		.type i2cStop, @function
		
		.globl i2cInit
		.globl i2cReadFrom
		.globl i2cWriteTo
		.globl i2cWrite
		.globl i2cRead
		.globl i2cStop

		.globl SC704BASE
		
		.equ SCL,0x01
		.equ SDA,0x80
		
		
/*****************************************************************************
* i2cInit - setup the I2C bus ready for use
* Defined as: void i2cInit( void );
* Simply set both SCL and SDA high
*****************************************************************************/
i2cInit:
	movea.l	SC704BASE,%a0
	move.b	#SCL+SDA,(%a0)
	rts
	
/*****************************************************************************
* i2cReadFrom - start an I2C read sequence
* Defined as: uint8_t i2cReadFrom( uint8_t addr );
* Output a START condition followed by the device address with the R/W bit set
* Assumes that SCL & SDA are both already HIGH
*****************************************************************************/
i2cReadFrom:
	move.l	%sp@(4),%d0		// get the device address from the stack
	lsl.b	#1,%d0			// shift device address left 1 bit
	ori.b	#1,%d0			// doing a read so set the R/W bit

	// generate the I2C START condition
	movea.l	SC704BASE,%a0
	clr.l	%d1
	move.b	#SCL,(%a0)		// SDA low
	nop
	move.b	#0,(%a0)		// SCL & SDA low

	bra.w	i2cOutput

/*****************************************************************************
* i2cWriteTo : start an I2C write sequence
* Defined as: uint8_t i2cWriteTo( uint8_t addr );
* Output a START condition followed by the device address with the R/W bit clear
* Assumes that SCL & SDA are both already HIGH
*****************************************************************************/
i2cWriteTo:
	move.l	%sp@(4),%d0		// get the device address from the stack
	lsl.b	#1,%d0			// shift device address left 1 bit

	// generate the I2C START condition
	movea.l	SC704BASE,%a0
	clr.l	%d1
	move.b	#SCL,(%a0)		// SDA low
	nop
	move.b	#0,(%a0)		// SCL & SDA low

	bra.w	i2cOutput

/*****************************************************************************
* i2cWrite : write a byte onto the I2C bus
* Defined as: uint8_t i2cWrite( uint8_t data );
*****************************************************************************/
i2cWrite:
	move.l	%sp@(4),%d0		// get the byte to write from the stack
	bra.w	i2cOutput

/*****************************************************************************
* i2cOutput : write a byte onto the I2C bus
* Byte to write should already be in D0
* This routine is used by i2cReadFrom, i2cWriteTo and i2cWrite to actually
* write the byte onto the I2C bus and read the ACK/NAK response.
*****************************************************************************/
i2cOutput:
	movea.l	SC704BASE,%a0
	move.l	%d2,-(%sp)		// save D2
	move.l	#7,%d2			// 8 bits to send (DBRA needs 1 less)
0:
	lsl.b	#1,%d0			// extend bit holds data bit to send
	roxr.b	#1,%d1			// shift extend bit into bit 7
	move.b	%d1,(%a0)		// write the SDA bit
	ori.b	#SCL,%d1
	move.b	%d1,(%a0)		// write the SDA bit with SCL high
	andi.b	#SDA,%d1
	move.b	%d1,(%a0)		// write the SDA bit with SCL low

	dbra	%d2,0b			// repeat for next bit

	// get the ACK/NAK response
	move.b	#SDA,%d1
	move.b	%d1,(%a0)		// release the SDA line i.e. set it high
	ori.b	#SCL,%d1
	move.b	%d1,(%a0)		// set SCL high
	nop
	nop
	move.b	(%a0),%d0		// read value on the SC704 port
	rol.b	#1,%d0			// ACK/NAK bit is now bit 0
	andi.l	#0x01,%d0		// clear all other bits

	move.b	#SDA,%d1
	move.b	%d1,(%a0)		// SDA high & SCL low

	move.l	(%sp)+,%d2		// restore D2
	rts

/*****************************************************************************
* i2cRead : read a byte from the I2C bus
* Defined as: uint8_t i2cRead( uint8_t *data );
*****************************************************************************/
i2cRead:
	move.l	%sp@(4),%a1		// get the address to store the byte from the stack
	movea.l	SC704BASE,%a0
	move.l	%d2,-(%sp)		// save D2
	move.l	#7,%d2			// 8 bits to receive (DBRA needs 1 less)
	move.l	#0,%d0			// clear D0
1:
	move.b	#SCL+SDA,%d1
	move.b	%d1,(%a0)		// set SCL high
	nop
	nop
	move.b	(%a0),%d0		// read value on the SC704 port
	move.b	#SDA,%d1
	move.b	%d1,(%a0)		// set SCL low

	lsl.w	#1,%d0			// shift bit 7 into upper byte of D0
	nop
	dbra	%d2,1b			// repeat for next bit

	// upper byte of D0.W holds the received byte
	lsr.w	#8,%d0			// shift into lower byte
	move.b	%d0,(%a1)		// and save it

	// get the ACK/NAK response
	move.b	#SCL,%d1
	move.b	%d1,(%a0)		// set SCL high
	nop
	nop
	move.b	(%a0),%d0		// read value on the SC704 port
	rol.b	#1,%d0			// ACK/NAK bit is now bit 0
	andi.l	#0x01,%d0		// clear all other bits

	move.b	#SDA,%d1
	move.b	%d1,(%a0)		// SDA high & SCL low

	move.l	(%sp)+,%d2		// restore D2
	rts

/*****************************************************************************
* i2cStop - generate the I2C STOP condition
* Defined as: void i2cStop( void );
* Output a START condition followed by the device address with the R/W bit set
* Assumes that SDA is HIGH and SCL is LOW
*****************************************************************************/
i2cStop:
	movea.l	SC704BASE,%a0
	move.b	#0,(%a0)		// SCL & SDA low
	nop
	move.b	#SCL,(%a0)		// SCL high & SDA low
	nop
	move.b	#SCL+SDA,(%a0)	// SCL & SDA both high
	rts

