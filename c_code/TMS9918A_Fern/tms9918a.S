/******************************************************************************
* RCBus MC68000
*******************************************************************************
* #######  #     #   #####    #####    #####     #     #####      #    
*     #     ##   ##  #     #  #     #  #     #   ##    #     #    # #   
*     #     # # # #  #        #     #  #     #  # #    #     #   #   #  
*     #     #  #  #   #####    ######   ######    #     #####   #     # 
*     #     #     #        #        #        #    #    #     #  ####### 
*     #     #     #  #     #  #     #  #     #    #    #     #  #     # 
*     #     #     #   #####    #####    #####   #####   #####   #     #
********************************************************************************
* TMS9918A - TMSEMUv3 low level code.
********************************************************************************
* This low level assembler code has been put together based on my earlier
* assembler code which was based on the Z80 code by JB Langston at:
* https://github.com/jblang/TMS9918A/tree/master
*
* TMS9918A graphics subroutines
* Copyright 2018-2020 J.B. Langston
*
* Permission is hereby granted, free of charge, to any person obtaining a 
* copy of this software and associated documentation files (the "Software"), 
* to deal in the Software without restriction, including without limitation 
* the rights to use, copy, modify, merge, publish, distribute, sublicense, 
* and/or sell copies of the Software, and to permit persons to whom the 
* Software is furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
* DEALINGS IN THE SOFTWARE.
*
* VDP Programmers Guide: http://map.grauw.nl/resources/video/ti-vdp-programmers-guide.pdf
*
********************************************************************************
* My assembler code used a simple Z80 to 68000 translation with registers mapped
* roughly as A -> D0, BC -> D1, DE -> D2 & HL -> A0. This may not be the correct
* way to implement this functionality but with my very limited knowledge of GCC,
* it worked for me after a lot of trial and error.
********************************************************************************
* Note: GCC seems to pass function parameters on the stack and designates D0,D1,
* A0 & A1 as scratch registers which dont need preserving.
*
* Some functionality such as setting the background colour needs to available
* from C as well as asm. Function names beginning tms* will preserve registers,
* but function names beginning iTms* (i.e. internal) will assume that has been
* taken care of by the calling routine.
********************************************************************************
*/
	.title "tms9918a.S assembler support for the TMSEMUv3 card"

#include "system.h"

* ===========================================================================
* register constants
* ===========================================================================
	.equ	TmsWriteBit,		0x40

* ===========================================================================
* Registers within the TMS9918A - NOT I/O space registers!
* ===========================================================================
	.equ	TmsCtrl0Reg,         0x80
	.equ	TmsCtrl1Reg,         0x81
	.equ	TmsNameReg,          0x82
	.equ	TmsColorTableReg,    0x83
	.equ	TmsPatternReg,       0x84
	.equ	TmsSpriteAttrReg,    0x85
	.equ	TmsSpritePatternReg, 0x86
	.equ	TmsColorReg,         0x87

* Control Register Bits
	.equ	TmsM3,               0x200
	.equ	TmsExtVideo,         0x100
	.equ	Tms16k,              0x80
	.equ	TmsDisplayEnable,    0x40
	.equ	TmsIntEnableBit,     0x20
	.equ	TmsM1,               0x10
	.equ	TmsM2,               0x08
	.equ	TmsSprite32,         0x02
	.equ	TmsSpriteMag,        0x01

* ===========================================================================
* table lengths
* ===========================================================================

	.equ	TmsTileNameLen,      0x300
	.equ	TmsTextNameLen,      0x3C0

	.equ	TmsTileColorLen,     0x20
	.equ	TmsBitmapColorLen,   0x800

	.equ	TmsTilePatternLen,   0x800
	.equ	TmsTextPatternLen,   0x800
	.equ	TmsMulticolorPatternLen, 0x600
	.equ	TmsBitmapPatternLen, 0x1800

* The inclusive OR '|' symbol does not seem to work here (no idea why not)
* so I use + instead which seems to be fine!
  
	.equ	TmsBlankFlags,       Tms16k
	.equ	TmsTileFlags,        Tms16k+TmsDisplayEnable
	.equ	TmsTextFlags,        Tms16k+TmsDisplayEnable+TmsM1
	.equ	TmsMulticolorFlags,  Tms16k+TmsDisplayEnable+TmsM2
	.equ	TmsBitmapFlags,      Tms16k+TmsDisplayEnable+TmsM3

* ===========================================================================
* color constants - TMS9918 VDP Programmer Guide Table 2.1
* ===========================================================================

	.equ	TmsTransparent,      0

* ===========================================================================
* TMSPORT = VRAM RD/WR address & TmsPort+2 = VDP Registers
* ===========================================================================

	.equ	TMS9918A_ADDR, 0x98
	.equ	TMSPORT, IO_BASE+(TMS9918A_ADDR<<1)+1
		
        .section .text
        .align 2
		
		.globl tmsBackground
		.globl tmsBitmap
		.globl tmsChrOut
		.globl tmsFill
		.globl tmsLoadSprites
		.globl tmsPlotPixel
		.globl tmsProbe
		.globl tmsRamOut
		.globl tmsRegIn
		.globl tmsRepeat
		.globl tmsSpriteConfig
		.globl tmsStrOut
		.globl tmsTextColor
		.globl tmsTextMode
		.globl tmsTextPos
		.globl tmsUpdateSprites
	
/*****************************************************************************
* port I/O routines
*****************************************************************************/

* ---------------------------------------------------------------------------
* tmsProbe - check that the TMS9918A is at the expected I/O address
* Does this by checking to see if the frame flag in the status register is
* getting set or not.
*
* uint8_t tmsProbe( void ) - return value in D0
*
tmsProbe:
	bsr.w	iTmsRegIn					// read status reg to clear frame flag
	bsr.w	iTmsRegIn					// read it again
	andi.b	#0x80,%d0					// is bit 7 still set?
	bne.s	TmsProbeFailed				// if it is then likely not a TMS9918A

	move.w	#0xFFFF,%d1					// long enough for another vsync?
TmsProbeWait:
	bsr.w	iTmsRegIn					// check frame flag again
	andi.b	#0x80,%d0					// is bit 7 set?
	bne.s	TmsProbeDone				// if set, its a TMS9918A
	dbra	%d1,TmsProbeWait			// check again
TmsProbeFailed:
	clr.b	%d0
TmsProbeDone:
	rts

* ---------------------------------------------------------------------------
* iTmsSetReg - set a single register value - INTERNAL FUNCTION
* Write the data byte followed by the register address byte
* parameters:
*      D0 = register value (A)
*      D1 = register to set (E)
iTmsSetReg:
	move.b	%d0,TMSPORT+2
	move.b	%d1,TMSPORT+2
	rts

* ---------------------------------------------------------------------------
* iTmsRegOut - write to configured register port - INTERNAL FUNCTION
* parameters:
*       D0 = value to write (A)
iTmsRegOut:
	move.b	%d0,TMSPORT+2
	rts

* ---------------------------------------------------------------------------
* iTmsRegIn - read from configured register port - INTERNAL FUNCTION
* returns:
*      D0 = value read (A)
tmsRegIn:
iTmsRegIn:
	move.b	TMSPORT+2,%d0
	rts
	
* ---------------------------------------------------------------------------
* tmsRamOut - write to configured VRAM port
*      D0 = value to write (A)
*
* void tmsRamOut( const uint8_t val )
*   - byte to write is on the stack at 4(sp) - always a 32-bit value.
*
tmsRamOut:
	move.l	4(%sp),%d0					// get byte off the stack
iTmsRamOut:
	move.b	%d0,TMSPORT
	rts

* ---------------------------------------------------------------------------
* tmsRamIn - read from configured VRAM port
*      D0 = value read (A)
iTmsRamIn:
	move.b	TMSPORT,%d0
	rts

* ===========================================================================
* register configuration routines
* ===========================================================================

* ---------------------------------------------------------------------------
* tmsBackground - set the background color
*
* void tmsBackground( const uint8_t col );
*   - colour is on the stack at 4(sp) - always a 32-bit value.
*
tmsBackground:
	move.l	4(%sp),%d0					// get background colour off the stack
iTmsBackground:
	andi.b	#0x0F,%d0					// just the new background colour
	andi.b	#0xF0,TmsScreenColors		// mask off old background colour
	or.b	TmsScreenColors,%d0			// insert new background colour
	move.b	%d0,TmsScreenColors			// save it to our local copy
	
	move.b	#TmsColorReg,%d1
	bra.w	iTmsSetReg					// write new fore/back colours
	
* ---------------------------------------------------------------------------
* set the sprite configuration
*       D0 = sprite options (A)
*
* void tmsSpriteConfig( const uint8_t options );
*   - options is on the stack at 4(sp) - always a 32-bit value.
*
	.equ	mask1, TmsSprite32+TmsSpriteMag
	
tmsSpriteConfig:
	move.l	4(%sp),%d0					// get sprite options off the stack
	andi.b	#mask1,%d0
	move.b	%d0,%d1
	move.w	TmsMode,%d0
	andi.b	#~mask1,%d0
	or.b	%d1,%d0
	move.w	%d0,TmsMode
	move.b	#TmsCtrl1Reg,%d1
	bra.w	iTmsSetReg
	
* ===========================================================================
* initialization routines
* ==========================================================================

* ---------------------------------------------------------------------------
* reset registers and clear all 16KB of video memory
tmsReset:
	move.w	#TmsBlankFlags,%d0			// blank the screen with 16KB enabled
	move.w	%d0,TmsMode
	move.b	#TmsCtrl1Reg,%d1
	bsr.w	iTmsSetReg
	
	lsr.w	#8,%d0
	move.b	#TmsCtrl0Reg,%d1
	bsr.w	iTmsSetReg

	move.b	#TmsTransparent,%d0
	bsr.w	iTmsBackground

	move.b	#TmsTransparent,%d0
	bsr.w	iTmsTextColor

	* clear the entire VRAM
	move.l	%d2,-(%sp)					// save D2
	move.w	#0,%d2						// VRAM destination address
	move.w	#0x4000,%d1					// byte count
	move.w	#0,%d0						// value to fill 
	bsr.w	iTmsFill
	move.l	(%sp)+,%d2					// restore D2
	rts	

* ---------------------------------------------------------------------------
* initialize for multicolor mode
* Simple register mapping from Z80 to 68000:
* A->D0, B->D1, C->D2, D->D3 & E->D4
tmsMulticolor:
	movem.l	%d2-%d4,-(%sp)				// save D2, D3 & D4
	bsr.w	tmsReset
	move.w	TmsNameAddr,%d2
	bsr.w	iTmsWriteAddr				// write VRAM start addr
	move.w	#5,%d3						// name table has 6 sections (D3=D)
	clr.l	%d4							// lines in first section start at 0 (D4=E)
TmsSectionLoop:
    move.w	#3,%d2						// each section has 4 identical lines (D2=C)
TmsLineLoop:
    move.w	#31,%d1						// each line is 32 bytes long (D1=B)
	move.w	%d4,%d0						// same starting value for each line in section
TmsByteLoop: 
	bsr.w	iTmsRamOut
	addi.w	#1,%d0						// byte value
	dbra	%d1,TmsByteLoop
	dbra	%d2,TmsLineLoop
	move.w	%d0,%d4						//  next starting value = current + 32
	dbra	%d3,TmsSectionLoop
	move.w	#TmsMulticolorFlags,%d0
	move.w	%d0,TmsMode
	movem.l	(%sp)+,%d2-%d4				// restore D2, D3 & D4

	bra.w	iTmsInitNonBitmap

* ---------------------------------------------------------------------------
* TmsTextMode - initialize for text mode
*
* void tmsTextMode( const uint8_t *font );
*   - font start addr is on the stack at 4(sp) - always a 32-bit value.
*
tmsTextMode:
	bsr.w	tmsReset

	move.l	4(%sp),%a0					// get start address of the font

	move.l	%d2,-(%sp)					// save D2
	move.w	TmsPatternAddr,%d2			// destination addr
	move.w	#TmsTextPatternLen,%d1		// byte count
	bsr.w	iTmsWrite					// write out the font
	move.l	(%sp)+,%d2					// restore D2

	move.w	#TmsTextFlags,%d0
	move.w	%d0,TmsMode

	* fallthrough to iTmsInitNonBitmap
	
* ---------------------------------------------------------------------------
* iTmsInitNonBitmap - non-bitmap color and pattern table configuration
iTmsInitNonBitmap:
	* set up color table address (register = address / 400H)
	andi.w	#0x3FC0,TmsColorAddr
	move.w	TmsColorAddr,%d0
	lsr.w	#6,%d0						// reduce colour table address to a byte
	move.b	#TmsColorTableReg,%d1
	bsr.w	iTmsSetReg
	
	* set up pattern table address (register = address / 800H)
	andi.w	#0x3800,TmsPatternAddr
	move.w	TmsPatternAddr,%d0
	lsr.w	#8,%d0
	lsr.b	#3,%d0
	move.b	#TmsPatternReg,%d1
	bsr.w	iTmsSetReg
	bra.w	iTmsInitCommon

* ---------------------------------------------------------------------------
* TmsBitmap - initialise for bitmapped graphics
*
* void tmsBitmap( void );
*
tmsBitmap:
	bsr.w	tmsReset
	move.l	%d2,-(%sp)					// save D2
	move.w	TmsNameAddr,%d2				// initialize name table with 3 sets
	bsr.w	iTmsWriteAddr				// of 256 bytes ranging from 00-FF
	move.l	(%sp)+,%d2					// restore D2

	move.w	#0x02FF,%d1
	clr.l	%d0
TmsBitmapLoop:
	bsr.w	iTmsRamOut
	addi.b	#1,%d0
	nop
	nop
	dbra	%d1,TmsBitmapLoop
	
	move.w	#TmsBitmapFlags,%d0
	move.w	%d0,TmsMode

	* set up color table at 0H (register = 7FH) or 2000H (register = 0FFH)
	andi.w	#0x2000,TmsColorAddr
	bne.s	TmsColorTableHigh
	move.b	#0x7F,%d0					// color table at 0H
	bra.s	TmsColorTableLow
TmsColorTableHigh:
	move.b	#0xFF,%d0					// color table at 2000H
TmsColorTableLow:
	move.b	#TmsColorTableReg,%d1
	bsr.w	iTmsSetReg

	* set up pattern table at 0H (register = 3) or 2000H (register = 7)
	andi.w	#0x2000,TmsPatternAddr
	bne.s	TmsPatternTableHigh
	move.b	#0x03,%d0					// pattern table at 0H
	bra.s	TmsPatternTableLow
TmsPatternTableHigh:
	move.b	#0x07,%d0					// pattern table at 2000H
TmsPatternTableLow:
	move.b	#TmsPatternReg,%d1
	bsr.w	iTmsSetReg
	* fall through to iTmsInitCommon

* ---------------------------------------------------------------------------
* TmsInitCommon - common initialization for all modes
iTmsInitCommon:
	* set up name table address (register = address / 400H)
	andi.w	#0x3C00,TmsNameAddr
	move.w	TmsNameAddr,%d0
	lsr.w	#8,%d0
	lsr.b	#2,%d0
	move.b	#TmsNameReg,%d1
	bsr.w	iTmsSetReg
	
	* set up sprite pattern table address (register = address / 80H)
	andi.w	#0x7F80,TmsSpriteAttrAddr
	move.w	TmsSpriteAttrAddr,%d0
	lsr.w	#7,%d0
	move.b	#TmsSpriteAttrReg,%d1
	bsr.w	iTmsSetReg

	* set up sprite attribute table address (register = address / 800H)
	andi.w	#0x3800,TmsSpritePatternAddr
	move.w	TmsSpritePatternAddr,%d0
	lsr.w	#8,%d0
	lsr.b	#3,%d0
	move.b	#TmsSpritePatternReg,%d1
	bsr.w	iTmsSetReg

	* set up control registers
	move.w	TmsMode,%d0
	move.b	#TmsCtrl1Reg,%d1
	bsr.w	iTmsSetReg

	lsr.w	#8,%d0
	move.b	#TmsCtrl0Reg,%d1
	bra.w	iTmsSetReg

* ===========================================================================
* memory access routines
* ===========================================================================

* ---------------------------------------------------------------------------
* iTmsWriteAddr - set the next address of vram to write
*      D2 = VRAM address
iTmsWriteAddr:
	move.w	%d2,%d0
	andi.w	#0x3FFF,%d0					// mask off msb to max of 16KB
	bsr.w	iTmsRegOut					// send lower byte
	lsr.w	#8,%d0
	ori.b	#TmsWriteBit,%d0			// indicate that this is a write
	bsr.w	iTmsRegOut					// send upper byte
	rts

* ---------------------------------------------------------------------------
* iTmsReadAddr - set the next address of vram to read
*      D2 = VRAM address
iTmsReadAddr:
	move.w	%d2,%d0
	andi.w	#0x3FFF,%d0					// mask off msb to max of 16KB
	bsr.w	iTmsRegOut					// send lower byte
	lsr.w	#8,%d0
	bsr.w	iTmsRegOut					// send upper byte
	rts

* ---------------------------------------------------------------------------
* tmsWrite - copy bytes from ram to vram
*      A0 = ram source address
*      D2 = vram destination address
*      D1 = byte count
*
* void tmsWrite( const uint8_t *src, const uint8_t *dest, const uint16_t count );
*   - count is on the stack at 12(sp) - always a 32-bit value.
*   - dest  is on the stack at  8(sp) - always a 32-bit value.
*   - src   is on the stack at  4(sp) - always a 32-bit value.
*
* Note additional offset of 4 bytes on the stack as D2 is saved first
*
tmsWrite:
	move.l	%d2,-(%sp)					// save D2
	move.l	8(%sp),%a0					// get the source address off the stack
	move.l	12(%sp),%d2					// get the destination address off the stack
	move.l	16(%sp),%d1					// get the count off the stack
	bsr.w	iTmsWrite					// write out the data
	move.l	(%sp)+,%d2					// restore D2
	rts
	
iTmsWrite:
	bsr.w	iTmsWriteAddr				// write the VRAM start address
	subq.w	#1,%d1						// byte count -1 as DBRA needs 1 less
iTmsWriteLoop:
	move.b	(%a0)+,%d0
	bsr.w	iTmsRamOut
	dbra	%d1,iTmsWriteLoop
	rts

* ---------------------------------------------------------------------------
* iTmsFill - fill a section of memory with a single value
*      D0 = value to fill with
*      D1 = byte count
*      D2 = vram destination address
*
* void tmsFill( const uint8_t val, const uint16_t vdest, const uint16_t count );
*   - value to repeat is on the stack at 4(sp) - always a 32-bit value.
*   - vram destination addr is on the stack at 8(sp) - always a 32-bit value.
*   - no of times to repeat is on the stack at 12(sp) - always a 32-bit value.
*
* Note additional offset of 4 bytes on the stack as D2 is saved first
*
tmsFill:
	move.l	%d2,-(%sp)					// save D2
	move.l	8(%sp),%d0					// get the value to write off the stack
	move.l	12(%sp),%d2					// get the vram destination address off the stack
	move.l	16(%sp),%d1					// get the repeat count off the stack
	bsr.w	iTmsFill					// write out the data
	move.l	(%sp)+,%d2					// restore D2
	rts
	
iTmsFill:
	move.w	%d0,-(%sp)					// save fill value
	bsr.w	iTmsWriteAddr				// write VRAM start addr
	move.w	(%sp)+,%d0					// restore fill value
	subq.w	#1,%d1						// DBRA needs 1 less

	move.l	%d7,-(%sp)					// save D7
iTmsFillLoop:
	bsr.w	iTmsRamOut

	* crude delay loop - do we need this with the TMSEMU board?
	move.w	#10,%d7
iTmsFillDelay:
	nop
	nop
	dbra	%d7,iTmsFillDelay

	dbra	%d1,iTmsFillLoop
	move.l	(%sp)+,%d7					// restore D7
	rts
	
* ===========================================================================
* text routines
* ===========================================================================

* ---------------------------------------------------------------------------
* tmsTextColor - set text color
*      D0 = requested color
*
* void tmsTextColor( const uint8_t col )
*   - colour is on the stack at 4(sp) - always a 32-bit value.
*
tmsTextColor:
	move.l	4(%sp),%d0					// get text colour off the stack
iTmsTextColor:
	lsl.b	#4,%d0						// text colour into high nibble
	andi.b	#0x0F,TmsScreenColors		// mask off old foreground colour
	or.b	TmsScreenColors,%d0			// insert new foreground colour
	move.b	%d0,TmsScreenColors			// save it to our local copy

	move.b	#TmsColorReg,%d1
	bra.w	iTmsSetReg					// write new fore/back colours

* ---------------------------------------------------------------------------
* tmsTextPos - set the address to place text at X/Y coordinate
*		D0 = X
*		D1 = Y
*
* void tmsTextPos( const uint8_t row, const uint8_t col )
*   - row is on the stack at 8(sp) - always a 32-bit value.
*   - col is on the stack at 4(sp) - always a 32-bit value.
*
tmsTextPos:
	move.l	8(%sp),%d0					// get row number off the stack
	move.l	4(%sp),%d1					// get col number off the stack
	move.l	%d2,-(%sp)					// save D2

	andi.w	#0x00FF,%d1					// just the lower byte of Y coordinate
	move.w	%d1,%d2						// copy Y coordinate to D2
	lsl.w	#3,%d2						// D2 = Y * 8
	lsl.w	#5,%d1						// D1 = Y * 32
	add.w	%d1,%d2						// D2 = Y * 40

	andi.w	#0x00FF,%d0					// just the lower byte of X coordinate
	add.w	%d0,%d2						// D2 = (y * 40) + x

	add.w	TmsNameAddr,%d2				// add name table base address
	bsr.w	iTmsWriteAddr
	move.l	(%sp)+,%d2					// restore D2
	rts

* ---------------------------------------------------------------------------
* tmsStrOut - copy a null-terminated string to VRAM
*		A0 = start addr of null terminated string
*
* void tmsStrOut( const char *str )
*   - start addr of string is on the stack at 4(sp) - always a 32-bit value.
*
tmsStrOut:
	move.l	4(%sp),%a0					// get the start addr of the string
iTmsStrOut:
	move.b	(%a0)+,%d0					// get char
    beq.s   tmsStrOutEnd         		// check for the null
	bsr.w	iTmsRamOut					// write the char
	bra.s	iTmsStrOut					// and repeat
tmsStrOutEnd:
	rts

* ---------------------------------------------------------------------------
* tmsRepeat - repeat a character a certain number of times
*       D0 = character to output
*		D1 = count
*
* void tmsRepeat( const uint8_t val, const uint16_t count )
*   - value to repeat is on the stack at 4(sp) - always a 32-bit value.
*   - no of times to repeat is on the stack at 8(sp) - always a 32-bit value.
* 
tmsRepeat:
	move.l	4(%sp),%d0					// get the character to repeat off the stack
	move.l	8(%sp),%d1					// get repetition count off the stack
	subq.w	#1,%d1						// DBRA needs 1 less
iTmsRepeat:
	bsr.w	iTmsRamOut
	dbra	%d1,iTmsRepeat
	rts
	
* ---------------------------------------------------------------------------
* tmsChrOut - output a character
*       D0 = character to output
*
* void tmsChrOut( const uint8_t val )
*   - char is on the stack at 4(sp) - always a 32-bit value.
*
tmsChrOut:
	bra.w	tmsRamOut	

* ===========================================================================
* bitmap routines
* ===========================================================================

* ---------------------------------------------------------------------------
* tmsPlotPixel - set or clear pixel at X, Y position
*
* void tmsPlotPixel( uint8_t x, uint8_t y );
*   - x is on the stack at 4(sp) - always a 32-bit value.
*   - y is on the stack at 8(sp) - always a 32-bit value.
*
tmsPlotPixel:
	move.l	8(%sp),%d1					// get the Y coordinate
	cmpi.w	#192,%d1					// is Y greater than 192?
	bge.s	tmsPlotPixelExit			// if yes then done!

	move.l	4(%sp),%d0					// get the X coordinate
	bsr.w	iTmsXYAddr					// convert to an address in A0

	// compute the bit to set in the vram byte using the lower
	// 3 bits of the X coordinate
	move.l	#0x80,%d1					// preset the bit to be shifted
	andi.b	#0x07,%d0					// get lower 3 bits of X coordinate
	beq.s	tmsPlotPixelNoShift			// skip shift if X MOD 8 is zero
	lsr.b	%d0,%d1						// shift D1 right by D0 times

tmsPlotPixelNoShift:
	// D1 holds the bit to set in the vram byte so read the current vram
	// value, OR in the new bit and write back to vram
	adda.w	TmsPatternAddr,%a0			// add pattern table base address
	move.l	%d2,-(%sp)					// save D2
	move.w	%a0,%d2
	bsr.w	iTmsReadAddr				// set read address in pattern table
	bsr.w	iTmsRamIn					// D0 = byte read in from vram

	or.b	%d0,%d1						// insert new pixel bit into old vram byte
	bsr.w	iTmsWriteAddr				// set write address in pattern table
	move.b	%d1,%d0
	bsr.w	iTmsRamOut
	move.l	(%sp)+,%d2					// restore D2
	
tmsPlotPixelExit:
	rts
	
* ---------------------------------------------------------------------------
* tmsXYAddr - convert X & Y coordinates into a vram address
*		D0 = X
*		D1 = Y
*		returns address in A0
*
* The coordinates are encoded into a 16 bit word as follows:
* | 15 (MSB)                    8 | 7                     (LSB) 0 |
* | 0 | 0 | 0 | Y7| Y6| Y5| Y4| Y3| X7| X6| X5| X4| X3| Y2| Y1| Y0|
*
* The X coordinate bits 2..0 are not used when computing the address. They are
* used by the calling routine to determine the bit position in the byte
* written to VRAM.
*
iTmsXYAddr:
	movem.l	%d0-%d1,-(%sp)				// save registers
	movea.l	#0,%a0						// and clear A0

	lsl.w	#5,%d1						// top 5 bits of Y in D1[12..8]
										// and lower 3 bits of Y in D1[7..5]
	lsr.b	#5,%d1						// lower 3 bits of Y in D1[2..0]

	andi.b	#0xF8,%d0					// D0 = ( x & 0xF8 )
	or.b	%d0,%d1						// insert X coordinate
	movea.l	%d1,%a0						// A0 = computed address
	movem.l	(%sp)+,%d0-%d1				// restore registers
	rts

* ===========================================================================
* sprite routines
* ===========================================================================

* ---------------------------------------------------------------------------
* tmsLoadSprites - copy the sprite data to vram
*
* void tmsLoadSprites( const uint8_t *src, const uint16_t count );
*   - count is on the stack at 8(sp) - always a 32-bit value.
*   - src   is on the stack at 4(sp) - always a 32-bit value.
*
* Note additional offset of 4 bytes required as D2 is saved on the stack
*
tmsLoadSprites:
	move.l	%d2,-(%sp)					// save D2
	move.l	8(%sp),%a0					// get the source address off the stack
	move.l	12(%sp),%d1					// get the count off the stack

	move.w	TmsSpritePatternAddr,%d2	// d2 = sprite pattern address in VRAM
	bsr.w	iTmsWrite					// write out the data
	move.l	(%sp)+,%d2					// restore D2
	rts
	
* ---------------------------------------------------------------------------
* tmsUpdateSprites - update the sprite attribute table
*
* void tmsUpdateSprites( const uint8_t *src, const uint16_t count );
*   - count is on the stack at 8(sp) - always a 32-bit value.
*   - src   is on the stack at 4(sp) - always a 32-bit value.
*
* Note additional offset of 4 bytes on the stack as D2 is saved first
*
tmsUpdateSprites:
	move.l	%d2,-(%sp)					// save D2
	move.l	8(%sp),%a0					// get the source address off the stack
	move.l	12(%sp),%d1					// get the count off the stack

	move.w	TmsSpriteAttrAddr,%d2		// d2 = sprite attribute address in VRAM
	bsr.w	iTmsWrite					// write out the data
	move.l	(%sp)+,%d2					// restore D2
	rts
	

		.section .data
        .align 4

/*****************************************************************************
* configuration parameters which can be changed at runtime
*****************************************************************************/
TmsWait:				dc.b    31              // iterations to wait after ram access
TmsScreenColors:		dc.b    0               // background (low nybble), text color (high nybble)

TmsMode:				dc.w    0               // mode registers
TmsNameAddr:			dc.w    0x3800          // name table address (multiples of 400H)
TmsColorAddr:			dc.w    0x2000          // color table address (multiples of 40H)
TmsPatternAddr:			dc.w    0               // pattern table (multiples of 800H)
TmsSpritePatternAddr:	dc.w    0x1800          // sprite attribute table (multiples of 80H)
TmsSpriteAttrAddr:		dc.w    0x3b00          // sprite pattern table (multiples of 800H)
