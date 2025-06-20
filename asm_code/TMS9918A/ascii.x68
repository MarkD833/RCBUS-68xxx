*******************************************************************************
* RCBus-68000 ASCII table TMS9918A text mode example program
*******************************************************************************
* Port of original code by J.B. Langston
* https://github.com/jblang/TMS9918A
*******************************************************************************

	INCLUDE "..\asm-inc\memory.inc"
	INCLUDE "..\asm-inc\devices.inc"

LineLen:                equ 32
DoubleHorizontal:       equ 205
DoubleVertical:         equ 186
DoubleTopLeft:          equ 201
DoubleTopRight:         equ 187
DoubleBottomLeft:       equ 200
DoubleBottomRight:      equ 188


	ORG		RAM_BASE+$400
START:
	lea		titleMessage(pc),a0
	bsr.w	putString
	
	bsr.w	TmsProbe			* see if we can detect the TMS9918A chip
	beq.w	NoTms
	
	move.l	#TmsFont,a0			* A0 = address of start of font table
	bsr.w	TmsTextMode
	
	move.b	#TmsDarkBlue,d0		* set colours
	bsr.w	TmsBackground
	move.b	#TmsWhite,d0
	bsr.w	TmsTextColor

	bsr.w	TextBorder
	
	move.b	#11,d0				* X coordinate
	move.b	#2,d1				* Y coordinate
	bsr.w	TmsTextPos
	move.l	#TitleMessage2,a0	* start addr of null terminated text string
	bsr.w	TmsStrOut
	
	move.b	#0,d2				* start with character #0
	move.b	#4,d0				* X coordinate
	move.b	#6,d1				* Y coordinate
	move.w	#7,d4				* 8 rows
nxtline:	
	move.w	#31,d3				* 32 chars per line
	bsr.w	TmsTextPos			* set text position
	exg		d0,d2				* swap character (D2) & X coordinate (D0)
nxtchar:
	bsr.w	TmsRamOut			* output the character
	addq.b	#1,d0				* increment character number
	dbra	d3,nxtchar			* do next char

	* next row
	exg		d0,d2				* swap character & X coordinate back
	addi.b	#2,d1				* down 2 rows
	dbra	d4,nxtline			* next line
	
Exit:
	rts

NoTms:
	lea		NoTmsMessage(pc),a0
	bsr.w	putString
	bra.s	Exit	

TextBorder:
	move.b	#0,d0				* X coordinate
	move.b	#0,d1				* Y coordinate
	bsr.w	TmsTextPos
	move.b	#DoubleTopLeft,d0
	bsr.w	TmsChrOut
	move.w	#37,d1				* 38 chars but DBRA needs 1 less
	move.b	#DoubleHorizontal,d0
	bsr.w	TmsRepeat
	move.b	#DoubleTopRight,d0
	bsr.w	TmsChrOut	
	
	move.w	#21,d2				* 22 lines but DBRA needs 1 less
BorderLoop:
	move.b	#DoubleVertical,d0
	bsr.w	TmsChrOut	
	move.b	#' ',d0				* space
	move.w	#37,d1				* 38 chars but DBRA needs 1 less
	bsr.w	TmsRepeat
	move.b	#DoubleVertical,d0	* vertical border
	bsr.w	TmsChrOut	
	dbra	d2,BorderLoop

	move.b	#DoubleBottomLeft,d0
	bsr.w	TmsChrOut
	move.w	#37,d1				* 38 chars but DBRA needs 1 less
	move.b	#DoubleHorizontal,d0
	bsr.w	TmsRepeat
	move.b	#DoubleBottomRight,d0
	bsr.w	TmsChrOut
	rts
	
TmsFont:
	INCLUDE	"tmsfont.inc"
	INCLUDE	"tms.inc"
	INCLUDE	"utility.inc"
	
TitleMessage:    
	dc.b    'RCBus-68000 TMS9918A demo of ASCII Character Set',10,13
	dc.b	'Based on original Z80 code by J.B. Langston',10,13,0

TitleMessage2:   
	dc.b    'ASCII Character Set',0
	
NoTmsMessage:
	dc.b    'TMS9918A not found, aborting!',10,13,0

	END	START
	


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
