*******************************************************************************
* RCBus-68000 TMS9918A graphics subroutines
*******************************************************************************
* Based on the original code by J.B. Langston (his copyright below)
* https://github.com/jblang/TMS9918A
*
* Simple Z80 to 68000 translation with registers mapped roughly as
* A -> D0, BC -> D1, DE -> D2 & HL -> A0
*******************************************************************************
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

* VDP Programmer's Guide: http://map.grauw.nl/resources/video/ti-vdp-programmers-guide.pdf

	INCLUDE "..\asm-inc\memory.inc"

* ===========================================================================
* This address is as configured on the board in what would be the Z80 8-bit
* I/O space.
*
DISPADDR   EQU     $98           * Addresses $98 & $99

* ===========================================================================
* configuration parameters; can be changed at runtime
* ===========================================================================
* TmsPort = VRAM RD/WR & TmsPort+2 = VDP Registers
TmsPort:				equ     IO_BASE+(DISPADDR<<1)+1   * port for TMS vram (reg is 1 higher)

TmsWait:				dc.b    31              * iterations to wait after ram access
TmsScreenColors:		dc.b    0               * background (low nybble), text color (high nybble)

TmsMode:				dc.w    0               * mode registers
TmsNameAddr:			dc.w    $3800           * name table address (multiples of 400H)
TmsColorAddr:			dc.w    $2000           * color table address (multiples of 40H)
TmsPatternAddr:			dc.w    0               * pattern table (multiples of 800H)
TmsSpritePatternAddr:	dc.w    $1800           * sprite attribute table (multiples of 80H)
TmsSpriteAttrAddr:		dc.w    $3bc0           * sprite pattern table (multiples of 800H)

* ===========================================================================
* register constants
* ===========================================================================
TmsWriteBit:            equ $40                 ; bit to indicate memory write

* ===========================================================================
* Registers within the TMS9918A - NOT I/O space registers!
* ===========================================================================
TmsCtrl0Reg:            equ $80
TmsCtrl1Reg:            equ $81
TmsNameReg:             equ $82
TmsColorTableReg:       equ $83
TmsPatternReg:          equ $84
TmsSpriteAttrReg:       equ $85
TmsSpritePatternReg:    equ $86
TmsColorReg:            equ $87

* Control Register Bits
TmsM3:                  equ $200
TmsExtVideo:            equ $100
Tms16k:                 equ $80
TmsDisplayEnable:       equ $40
TmsIntEnableBit:        equ $20
TmsM1:                  equ $10
TmsM2:                  equ 8
TmsSprite32:            equ 2
TmsSpriteMag:           equ 1

* ===========================================================================
* table lengths
* ===========================================================================

TmsTileNameLen:         equ $300
TmsTextNameLen:         equ $3c0

TmsTileColorLen:        equ $20
TmsBitmapColorLen:      equ $800

TmsTilePatternLen:      equ $800
TmsTextPatternLen:      equ $800
TmsMulticolorPatternLen: equ $600
TmsBitmapPatternLen:    equ $1800

* ===========================================================================
* color constants - TMS9918 VDP Programmer Guide Table 2.1
* ===========================================================================

TmsTransparent:         equ 0
TmsBlack:               equ 1
TmsMediumGreen:         equ 2
TmsLightGreen:          equ 3
TmsDarkBlue:            equ 4
TmsLightBlue:           equ 5
TmsDarkRed:             equ 6
TmsCyan:                equ 7
TmsMediumRed:           equ 8
TmsLightRed:            equ 9
TmsDarkYellow:          equ $0a
TmsLightYellow:         equ $0b
TmsDarkGreen:           equ $0c
TmsMagenta:             equ $0d
TmsGray:                equ $0e
TmsWhite:               equ $0f

* ===========================================================================
* port I/O routines
* ===========================================================================

	ORG		(*+3)&-4	* make we start on a longword aligned address

* ---------------------------------------------------------------------------
* TmsProbe - check that the TMS9918A is at the expected I/O address
* Does this by checking to see if the frame flag in the status register is
* getting set or not.
TmsProbe:
	bsr.w	TmsRegIn					* read status reg to clear frame flag
	bsr.w	TmsRegIn					* read it again
	andi.b	#$80,d0						* is bit 7 still set?
	bne.s	TmsProbeFailed				* if it is then likely not a TMS9918A

	move.w	#$FFFF,d1					* long enough for another vsync?
TmsProbeWait:
	bsr.w	TmsRegIn					* check frame flag again
	andi.b	#$80,d0						* is bit 7 set?
	bne.s	TmsProbeDone				* if set, it's a TMS9918A
	dbra	d1,TmsProbeWait				* check again
TmsProbeFailed:
	clr.b	d0
TmsProbeDone:
	rts

* ---------------------------------------------------------------------------
* TmsSetReg - set a single register value
* Write the data byte then the register address byte
* parameters:
*      D0 = register value (A)
*      D1 = register to set (E)
TmsSetReg:
	move.b	d0,TmsPort+2
	move.b	d1,TmsPort+2
	rts
	
* ---------------------------------------------------------------------------
* TmsRegOut - write to configured register port
* parameters:
*       D0 = value to write (A)
TmsRegOut:
	move.b	d0,TmsPort+2
	rts

* ---------------------------------------------------------------------------
* TmsRegIn - read from configured register port
* returns:
*      D0 = value read (A)
TmsRegIn:
	move.b	TmsPort+2,d0
	rts

* ---------------------------------------------------------------------------
* TmsRamOut - write to configured VRAM port
*      D0 = value to write (A)
TmsRamOut:
	move.b	d0,TmsPort
	rts
	
	* remove the RTS above to put in a software delay here
	move.w	d0,-(sp)
	move.w	#10,d0
TmsRamOutDelay:	
	nop
	dbra	d0,TmsRamOutDelay
	move.w	(sp)+,d0
	rts

* ---------------------------------------------------------------------------
* TmsRamIn - read from configured VRAM port
*      D0 = value read (A)
TmsRamIn:
	move.b	TmsPort,d0
	rts

* ===========================================================================
* register configuration routines
* ===========================================================================

* ---------------------------------------------------------------------------
* TmsBackground - set the background color
*      D0 = requested color (A)
TmsBackground:
	andi.b	#$0F,d0						* just the new background colour
	andi.b	#$0F0,TmsScreenColors		* mask off old background colour
	or.b	TmsScreenColors,d0			* insert new background colour
	move.b	d0,TmsScreenColors			* save it to our local copy
	
	move.b	#TmsColorReg,d1
	bra.w	TmsSetReg					* write new fore/back colours
	
* ===========================================================================
* initialization routines
* ===========================================================================

TmsBlankFlags:          equ     Tms16k
TmsTileFlags:           equ     Tms16k|TmsDisplayEnable
TmsTextFlags:           equ     Tms16k|TmsDisplayEnable|TmsM1
TmsMulticolorFlags:     equ     Tms16k|TmsDisplayEnable|TmsM2
TmsBitmapFlags:         equ     Tms16k|TmsDisplayEnable|TmsM3

* ---------------------------------------------------------------------------
* reset registers and clear all 16KB of video memory
TmsReset:
	move.w	#TmsBlankFlags,d0	* blank the screen with 16KB enabled
	move.w	d0,TmsMode
	move.b	#TmsCtrl1Reg,d1
	bsr.w	TmsSetReg
	
	lsr.w	#8,d0
	move.b	#TmsCtrl0Reg,d1
	bsr.w	TmsSetReg

	move.b	#TmsTransparent,d0
	bsr.w	TmsBackground

	move.b	#TmsTransparent,d0
	bsr.w	TmsTextColor

	* clear the entire VRAM
	move.w	#0,d2						* VRAM destination address
	move.w	#$4000,d1					* byte count
	move.w	#0,d0						* value to fill 
	bsr.w	TmsFill
	rts
	
* ---------------------------------------------------------------------------
* TmsTextMode - initialize for text mode
*      A0 = address of font to load
TmsTextMode:
	move.l	a0,-(sp)					* save start addr of font
	bsr.w	TmsReset
	move.l	(sp)+,a0
	move.w	TmsPatternAddr,d2			* destination addr
	move.w	#TmsTextPatternLen,d1		* byte count
	bsr.w	TmsWrite					* write out the font
	move.w	#TmsTextFlags,d0
	move.w	d0,TmsMode
	* fallthrough to TmsInitNonBitmap

* ---------------------------------------------------------------------------
* TmsInitNonBitmap - non-bitmap color and pattern table configuration
TmsInitNonBitmap:
	* set up color table address (register = address / 400H)
	andi.w	#$3FC0,TmsColorAddr
	move.w	TmsColorAddr,d0
	lsr.w	#6,d0						* reduce colour table address to a byte
	move.b	#TmsColorTableReg,d1
	bsr.w	TmsSetReg
	
	* set up pattern table address (register = address / 800H)
	andi.w	#$3800,TmsPatternAddr
	move.w	TmsPatternAddr,d0
	lsr.w	#8,d0
	lsr.b	#3,d0
	move.b	#TmsPatternReg,d1
	bsr.w	TmsSetReg
	bra.w	TmsInitCommon


* ---------------------------------------------------------------------------
* TmsInitCommon - common initialization for all modes
TmsInitCommon:
	* set up name table address (register = address / 400H)
	andi.w	#$3C00,TmsNameAddr
	move.w	TmsNameAddr,d0				* upper byte
	lsr.w	#8,d0
	lsr.b	#2,d0
	move.b	#TmsNameReg,d1
	bsr.w	TmsSetReg
	
	* set up sprite pattern table address (register = address / 80H)
	andi.w	#$7F80,TmsSpriteAttrAddr
	move.w	TmsSpriteAttrAddr,d0
	lsl.w	#1,d0
	move.b	#TmsSpriteAttrReg,d1
	bsr.w	TmsSetReg

	* set up sprite attribute table address (register = address / 800H)
	andi.w	#$3800,TmsSpritePatternAddr
	move.w	TmsSpritePatternAddr,d0		* upper byte
	lsr.w	#8,d0
	lsr.b	#3,d0
	move.b	#TmsSpritePatternReg,d1
	bsr.w	TmsSetReg

	* set up control registers
	move.w	TmsMode,d0
	move.b	#TmsCtrl1Reg,d1
	bsr.w	TmsSetReg

	lsr.w	#8,d0
	move.b	#TmsCtrl0Reg,d1
	bra.w	TmsSetReg
	


* ===========================================================================
* memory access routines
* ===========================================================================

* ---------------------------------------------------------------------------
* TmsWriteAddr - set the next address of vram to write
*      D2 = VRAM address
TmsWriteAddr:
	move.w	d2,d0
	andi.w	#$3FFF,d0			* mask off msb to max of 16KB
	bsr.w	TmsRegOut			* send lower byte
	lsr.w	#8,d0
	ori.b	#TmsWriteBit,d0		* indicate that this is a write
	bsr.w	TmsRegOut			* send upper byte
	rts

* ---------------------------------------------------------------------------
* TmsWrite - copy bytes from ram to vram
*      A0 = ram source address
*      D2 = vram destination address
*      D1 = byte count
TmsWrite:
	bsr.w	TmsWriteAddr
	subq	#1,d1				* DBRA needs 1 less
TmsWriteLoop:
	move.b	(a0)+,d0
	bsr.w	TmsRamOut
	dbra	d1,TmsWriteLoop
	rts
	
* ---------------------------------------------------------------------------
* TmsFill - fill a section of memory with a single value
*      D0 = value to fill
*      D1 = byte count
*      D2 = vram destination address
TmsFill:
	move.w	d0,-(sp)			* save fill value
	bsr.w	TmsWriteAddr		* write VRAM start addr
	move.w	(sp)+,d0			* restore fill value
	subq.w	#1,d1				* DBRA needs 1 less
TmsFillLoop:
	bsr.w	TmsRamOut
	dbra	d1,TmsFillLoop
	rts
	
* ===========================================================================
* text routines
* ===========================================================================

* ---------------------------------------------------------------------------
* TmsTextColor - set text color
*      D0 = requested color
TmsTextColor:
	lsl.b	#4,d0						* text colour into high nibble
	andi.b	#$0F,TmsScreenColors		* mask off old foreground colour
	or.b	TmsScreenColors,d0			* insert new foreground colour
	move.b	d0,TmsScreenColors			* save it to our local copy

	move.b	#TmsColorReg,d1
	bra.w	TmsSetReg					* write new fore/back colours

* ---------------------------------------------------------------------------
* TmsTextPos - set the address to place text at X/Y coordinate
*		D0 = X
*		D1 = Y
TmsTextPos:
	andi.w	#$00FF,d1			* just the lower byte of Y coordinate
	move.w	d1,d2				* copy Y coordinate to D2
	lsl.w	#3,d2				* D2 = Y * 8
	lsl.w	#5,d1				* D1 = Y * 32
	add.w	d1,d2				* D2 = Y * 40

	andi.w	#$00FF,d0			* just the lower byte of X coordinate
	add.w	d0,d2				* D2 = (y * 40) + x
	add.w	TmsNameAddr,d2		* add name table base address
	bra.w	TmsWriteAddr

* ---------------------------------------------------------------------------
* TmsStrOut - copy a null-terminated string to VRAM
*		A0 = start addr of null terminated string
TmsStrOut:
	move.b	(a0)+,d0			* get char
    beq.s   .end         		* check for the null
	bsr.w	TmsRamOut			* write the char
	bra.s	TmsStrOut			* and repeat
.end:
	rts
	
* ---------------------------------------------------------------------------
* TmsRepeat - repeat a character a certain number of times
*       D0 = character to output
*		D1 = count
TmsRepeat:
	bsr.w	TmsRamOut
	dbra	d1,TmsRepeat
	rts
	
* ---------------------------------------------------------------------------
* TmsChrOut - output a character
*       D0 = character to output
TmsChrOut:
	bra.w	TmsRamOut
	
	