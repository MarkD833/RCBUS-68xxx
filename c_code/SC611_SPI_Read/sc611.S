/******************************************************************************
* RCBus MC68000
*******************************************************************************
*  #####    #####    #####     #      #                    #####   ######   ### 
* #     #  #     #  #     #   ##     ##                   #     #  #     #   #  
* #        #        #        # #    # #                   #        #     #   #  
*  #####   #        ######     #      #        #####       #####   ######    #  
*       #  #        #     #    #      #                         #  #         #  
* #     #  #     #  #     #    #      #                   #     #  #         #  
*  #####    #####    #####   #####  #####                  #####   #        ###
********************************************************************************
* SC611 - MicroSD card storage module low level bit bang SPI code.
* Coded to support SPI Mode 0.
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
        .title "sc611.S assembler support for the SC611 SPI card"
		
        .section .text
        .align 2

        .type spiTransfer, @function
        .type spiTransfer16, @function
        .globl spiTransfer
        .globl spiTransfer16

		.equ SCK,0x10

/*****************************************************************************
* spiTransfer - exchange 1 byte with an SPI device
* Defined as: uint8_t spiTransfer( uint8_t data );
* The byte to send has been placed on the stack as a 32-bit value
* The received byte is left in D0 to be picked up by the C code
*****************************************************************************/
spiTransfer:
	move.l	%sp@(4),%d0		// get the byte to send from the stack
	move.l	%d2,-(%sp)		// save D2
	move.l	%d2,-(%sp)		// save D3
	
	andi.l	#0xFF,%d0		// clear all bits but the lower 8 bits
	move.b	sc611Copy,%d1	// get the last value written to the SC611
	movea.l	SC611,%a0
	move.l	#7,%d2			// 8 bits (DBRA needs 1 less)
0:
	lsr.b	#1,%d1			// shift working copy right 1 bit
	lsl.b	#1,%d0			// extend bit holds MOSI bit to send
	roxl.b	#1,%d1			// shift extend bit into working copy
	
	move.b	%d1,(%a0)		// write the new data bit out
	ori.b	#SCK,%d1
	move.b	%d1,(%a0)		// write the new clock bit out

	swap	%d0				// get rx bits into LSW
	move.b	(%a0),%d3		// read the current state of the SC611
	lsl.b	#1,%d3			// extend bit holds MISO bit received
	roxl.b	#1,%d0			// shift extend bit into received byte
	
	andi.b	#~SCK,%d1
	move.b	%d1,(%a0)		// write the new clock bit out

	swap	%d0				// get tx bits into LSW
	dbra	%d2,0b			// repeat for next bit

	// exchange done so switch the rx bits into the LSW
	swap	%d0				// get rx bits back into LSW
	move.b	%d1,sc611Copy	// tell C the last value written to the SC611
	move.l	(%sp)+,%d3		// restore D3
	move.l	(%sp)+,%d2		// restore D2

	rts

/*****************************************************************************
* spiTransfer16 - exchange 1 word (16 bits)  with an SPI device
* Defined as: uint16_t spiTransfer16( uint16_t data );
* The word to send has been placed on the stack as a 32-bit value
* The received word is left in D0 to be picked up by the C code
*****************************************************************************/
spiTransfer16:
	move.l	%sp@(4),%d0		// get the word to send from the stack
	move.l	%d2,-(%sp)		// save D2
	move.l	%d2,-(%sp)		// save D3

	andi.l	#0xFFFF,%d0		// clear all bits but the lower 16 bits
	move.b	sc611Copy,%d1	// get the last value written to the SC611
	movea.l	SC611,%a0
	move.l	#15,%d2			// 16 bits (DBRA needs 1 less)
1:
	lsr.b	#1,%d1			// shift working copy right 1 bit
	lsl.w	#1,%d0			// extend bit holds MOSI bit to send
	roxl.b	#1,%d1			// shift extend bit into working copy
	
	move.b	%d1,(%a0)		// write the new data bit out
	ori.b	#SCK,%d1
	move.b	%d1,(%a0)		// write the new clock bit out

	swap	%d0				// get rx bits into LSW
	move.b	(%a0),%d3		// read the current state of the SC611
	lsl.b	#1,%d3			// extend bit holds MISO bit received
	roxl.w	#1,%d0			// shift extend bit into received byte
	
	andi.b	#~SCK,%d1
	move.b	%d1,(%a0)		// write the new clock bit out

	swap	%d0				// get tx bits into LSW
	dbra	%d2,1b			// repeat for next bit

	// exchange done so switch the rx bits into the LSW
	swap	%d0				// get rx bits back into LSW
	move.b	%d1,sc611Copy	// tell C the last value written to the SC611
	move.l	(%sp)+,%d3		// restore D3
	move.l	(%sp)+,%d2		// restore D2

	rts

