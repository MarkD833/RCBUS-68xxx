*******************************************************************************
* RCBus-68000 Nyan Cat TMS9918A example program
*******************************************************************************
* Port of original code by J.B. Langston
* https://github.com/jblang/TMS9918A
*******************************************************************************
* Nyan Cat for RC2014 and SC126 with TMS9918 and YM2149
* Hand-written assembly by J.B. Langston
* Nyan Cat images from Passan Kiskat by Dromedaar Vision: http://www.dromedaar.com/
* Nyan Cat theme by Karbofos: https://zxart.ee/eng/authors/k/karbofos/tognyanftro/qid:136394/
* PTx Player by S.V.Bulba <vorobey@mail.khstu.ru>

	INCLUDE "..\asm-inc\memory.inc"
	INCLUDE "..\asm-inc\devices.inc"

VsyncDiv				equ	3	* number of vsyncs per Animation frame

	ORG		RAM_BASE+$400
START:
	lea		titleMessage(pc),a0
	bsr.w	putString
	
	move.w	#VsyncDiv,VsyncCount
	move.w	#0,CurrFrame

	bsr.w	TmsProbe			* see if we can detect the TMS9918A chip
	beq.w	NoTms

	bsr.w	TmsMultiColor		* initialize screen and set background color
	move.b	#TmsDarkBlue,d0
	bsr.w	TmsBackground

FirstFrame:
	move.l	#Animation,a0		* get address of first frame
NextFrame:
	move.l	a0,CurrFrame		* save address of next animation frame
SkipDraw:
	bsr.w	TmsRegIn			* only draw when vsyncs counter reaches 0
	andi.b	#$80,d0				* just bit 7
	beq.s	SkipDraw
	
	subi.w	#1,VsyncCount
	bne.s	SkipDraw

	move.w	#VsyncDiv,VsyncCount * reset vsync counter from divisor
	
	move.l	CurrFrame,a0		* copy current frame to pattern table
	move.w	TmsPatternAddr,d2
	move.w	#TmsMulticolorPatternLen,d1
	bsr.w	TmsWrite
	
	cmpa.l	#EndAnimation,a0	* have we done all frames?
	beq.s	FirstFrame			* if yes then reset to first frame
	bra.s	NextFrame			* otherwise do next frame

Exit:
	rts

NoTms:
	lea		NoTmsMessage(pc),a0
	bsr.w	putString
	bra.s	Exit	
	
VsyncCount:
	ds.w	1
CurrFrame:
	ds.w	1
	
	
	
	INCLUDE	"tmsfont.inc"
	INCLUDE	"tms.inc"
	INCLUDE	"utility.inc"
	
TitleMessage:    
	dc.b    'RCBus-68000 TMS9918A demo of Nyan Cat',10,13
	dc.b	'Based on original Z80 code by J.B. Langston',10,13
	dc.b	'Press RESET to exit',10,13,0

NoTmsMessage:
	dc.b    'TMS9918A not found, aborting!',10,13,0

Animation:
	INCBIN	".\nyan\nyan.bin"
EndAnimation:


	END	START
	



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
