*******************************************************************************
* RCBus-68000 Sprite Patterns TMS9918A example program
*******************************************************************************
* Port of original code by J.B. Langston
* https://github.com/jblang/TMS9918A
*******************************************************************************
* TMS9918A SpritePatterns example
* by J.B. Langston

	INCLUDE "..\asm-inc\memory.inc"
	INCLUDE "..\asm-inc\devices.inc"
	
VsyncDiv:		equ	6					* number of interrupts per animation frame
SpriteCount:	equ	8					* number of frames in animation

	ORG		RAM_BASE+$400
START:
	lea		titleMessage(pc),a0
	bsr.w	putString
	
	move.b	#VsyncDiv,VsyncCount
	move.b	#0,CurrSprite

	bsr.w	TmsProbe					* see if we can detect the TMS9918A chip
	beq.w	NoTms
	
	* should have an empty screen with a blue background

	bsr.w	TmsBitmap					* initialize screen

	* should have a green screen with a black box

	move.b	#TmsSprite32,d0
	bsr.w	TmsSpriteConfig
	
	* should have a green screen with a black box

	move.w	#SpritePatternLen,d1		* set up sprite patterns
	move.w	TmsSpritePatternAddr,d2
	movea.l	#SpritePatterns,a0
	bsr.w	TmsWrite	

	* should have a green screen with a black box

FirstSprite:        
	clr.l	d0							* reset to first sprite frame
NextSprite:
    move.b	d0,CurrSprite				* save current sprite frame in memory
SameSprite:
	bsr.w	TmsRegIn					* only update during vsync
	andi.b	#$80,d0						* just bit 7
	beq.s	SameSprite

	* do X coordinate
	move.b	XDelta,d0
	add.b	d0,Sprite1X
	add.b	d0,Sprite2X
	cmpi.b	#240,Sprite1X				* bounce off the edge
	bne.s	L1
	neg.b	XDelta						* change direction of motion
L1:
	cmpi.b	#0,Sprite1X					* bounce off the edge
	bne.s	L2
	neg.b	XDelta						* change direction of motion
L2:

	* do Y coordinate
	move.b	YDelta,d0
	add.b	d0,Sprite1Y
	add.b	d0,Sprite2Y
	cmpi.b	#176,Sprite1Y				* bounce off the edge
	bne.s	L3
	neg.b	YDelta						* change direction of motion
L3:
	cmpi.b	#0,Sprite1Y					* bounce off the edge
	bne.s	L4
	neg.b	YDelta						* change direction of motion
L4:

	move.w	#9,d1						* update sprite attribute table
	move.w	TmsSpriteAttrAddr,d2
	movea.l	#Sprite1Y,a0
	bsr.w	TmsWrite

	* should have a globe on the LHS now
	
	subi.b	#1,VsyncCount				* count down the vsyncs
	bne.w	SameSprite					* draw the same image until it reaches 0

	move.b	#VsyncDiv,VsyncCount		* reset vsync counter from divisor

	move.b	CurrSprite,d0
	move.b	d0,Sprite1Name
	addi.b	#4,d0
	move.b	d0,Sprite2Name

	addi.b	#4,d0
	cmpi.b	#(SpriteCount*8),d0
	bne.w	NextSprite
	bra.w	FirstSprite

Exit:
	rts

NoTms:
	lea		NoTmsMessage(pc),a0
	bsr.w	putString
	bra.s	Exit


	INCLUDE	"tms.inc"
	INCLUDE	"utility.inc"

VsyncCount:		ds.b	1				* vsync down counter
CurrSprite:		ds.b	1				* current sprite frame

XDelta:			dc.b	1				* direction horizontal motion
YDelta:			dc.b	1				* direction vertical motion

; Sprite Attributes
Sprite1Y:		dc.b	88
Sprite1X:		dc.b	0
Sprite1Name:	dc.b	0
Sprite1Color:	dc.b	TmsDarkBlue
Sprite2Y:		dc.b	88
Sprite2X:		dc.b	0
Sprite2Name:	dc.b	4
Sprite2Color:	dc.b	TmsLightGreen

SpriteTerm:		dc.b	$0D0

; planet sprites from TI VDP Programmer's guide
SpritePatterns:
        ; Sprite world0 pattern 1
        dc.b    $007,$01C,$038,$070,$078,$05C,$00E,$00F
        dc.b    $00F,$01F,$07F,$063,$073,$03D,$01F,$007
        dc.b    $0E0,$0F8,$07C,$066,$0F2,$0BE,$0DC,$0FC
        dc.b    $0F8,$0A0,$0C0,$0C0,$0E2,$0F4,$0F8,$0E0
        ; Sprite world0 pattern 2
        dc.b    $000,$003,$007,$00F,$007,$0A3,$0F1,$0F0
        dc.b    $0F0,$0E0,$080,$01C,$00C,$002,$000,$000
        dc.b    $000,$000,$080,$098,$00C,$041,$023,$003
        dc.b    $007,$05F,$03F,$03E,$01C,$008,$000,$000
        ; Sprite world1 pattern 1
        dc.b    $003,$01F,$03E,$07C,$07E,$097,$003,$003
        dc.b    $003,$007,$01F,$078,$07C,$03F,$01F,$007
        dc.b    $0E0,$038,$01C,$018,$03C,$02F,$0B7,$0FF
        dc.b    $0FE,$0E8,$0F0,$0F0,$0F8,$07C,$0F8,$0E0
        ; Sprite world1 pattern 2
        dc.b    $000,$000,$001,$003,$001,$068,$0FC,$0FC
        dc.b    $0FC,$0F8,$0E0,$007,$003,$000,$000,$000
        dc.b    $000,$0C0,$0E0,$0E6,$0C2,$0D0,$048,$000
        dc.b    $001,$017,$00F,$00E,$006,$080,$000,$000
        ; Sprite world2 pattern 1
        dc.b    $007,$01F,$03F,$07F,$03F,$0E5,$0C0,$0C0
        dc.b    $080,$001,$007,$01E,$03F,$03F,$01F,$007
        dc.b    $0E0,$0C8,$084,$006,$08E,$0CB,$0ED,$0FF
        dc.b    $0FF,$0FA,$0FC,$03C,$03E,$0DC,$0F8,$0E0
        ; Sprite world2 pattern 2
        dc.b    $000,$000,$000,$000,$040,$01A,$03F,$03F
        dc.b    $07F,$0FE,$0F8,$061,$040,$000,$000,$000
        dc.b    $000,$030,$078,$0F8,$070,$034,$012,$000
        dc.b    $000,$005,$003,$0C2,$0C0,$020,$000,$000
        ; Sprite world3 pattern 1
        dc.b    $007,$01F,$03F,$01F,$04F,$0F9,$070,$0F0
        dc.b    $0E0,$080,$001,$007,$00F,$01F,$01F,$007
        dc.b    $0E0,$0F0,$0E0,$0C2,$0E2,$072,$03B,$03F
        dc.b    $03F,$07E,$0FF,$08E,$0CE,$0F4,$0F8,$0E0
        ; Sprite world3 pattern 2
        dc.b    $000,$000,$000,$060,$030,$006,$08F,$00F
        dc.b    $01F,$07F,$0FE,$078,$070,$020,$000,$000
        dc.b    $000,$008,$01C,$03C,$01C,$08D,$0C4,$0C0
        dc.b    $0C0,$081,$000,$070,$030,$008,$000,$000
        ; Sprite world4 pattern 1
        dc.b    $007,$01F,$03F,$067,$073,$0BE,$0DC,$0FC
        dc.b    $0F8,$0A0,$0C0,$041,$063,$037,$01F,$007
        dc.b    $0E0,$0F8,$0F8,$0F0,$0F8,$05C,$00E,$00F
        dc.b    $00F,$01F,$07F,$0E2,$0F2,$0FC,$0F8,$0E0
        ; Sprite world4 pattern 2
        dc.b    $000,$000,$000,$018,$00C,$041,$023,$003
        dc.b    $007,$05F,$03F,$03E,$01C,$008,$000,$000
        dc.b    $000,$000,$004,$00E,$006,$0A3,$0F1,$0F0
        dc.b    $0F0,$0E0,$080,$01C,$00C,$000,$000,$000
        ; Sprite world5 pattern 1
        dc.b    $007,$01F,$01F,$019,$03C,$02F,$0B7,$0FF
        dc.b    $0FE,$0E8,$0F0,$070,$078,$03D,$01F,$007
        dc.b    $0E0,$0F8,$0FC,$0FC,$0FE,$097,$003,$003
        dc.b    $003,$007,$01F,$078,$0FC,$0FC,$0F8,$0E0
        ; Sprite world5 pattern 2
        dc.b    $000,$000,$020,$066,$043,$0D0,$048,$000
        dc.b    $001,$017,$00F,$00F,$007,$002,$000,$000
        dc.b    $000,$000,$000,$002,$000,$068,$0FC,$0FC
        dc.b    $0FC,$0F8,$0E0,$086,$002,$000,$000,$000
        ; Sprite world6 pattern 1
        dc.b    $007,$00F,$007,$006,$00F,$0CB,$0ED,$0FF
        dc.b    $0FF,$0FA,$0FC,$03C,$03E,$01F,$01F,$007
        dc.b    $0E0,$0F8,$0FC,$07E,$03E,$0E5,$0C0,$0C0
        dc.b    $080,$001,$007,$01E,$03E,$07C,$0F8,$0E0
        ; Sprite world6 pattern 2
        dc.b    $000,$010,$038,$079,$070,$034,$012,$000
        dc.b    $000,$005,$003,$043,$041,$020,$000,$000
        dc.b    $000,$000,$000,$080,$0C0,$01A,$03F,$03F
        dc.b    $07F,$0FE,$0F8,$0E0,$0C0,$080,$000,$000
        ; Sprite world7 pattern 1
        dc.b    $007,$013,$021,$041,$063,$072,$03B,$03F
        dc.b    $03F,$07E,$0FF,$00F,$04F,$037,$01F,$007
        dc.b    $0E0,$0F8,$0FC,$09E,$0CE,$0F9,$070,$0F0
        dc.b    $0E0,$080,$001,$006,$08E,$0DC,$0F8,$0E0
        ; Sprite world7 pattern 2
        dc.b    $000,$00C,$01E,$03E,$01C,$08D,$0C4,$0C0
        dc.b    $0C0,$081,$000,$070,$030,$008,$000,$000
        dc.b    $000,$000,$000,$060,$030,$006,$08F,$00F
        dc.b    $01F,$07F,$0FE,$0F8,$070,$020,$000,$000
        
SpritePatternLen equ *-SpritePatterns

TitleMessage:    
	dc.b    'RCBus-68000 TMS9918A demo of Sprites',10,13
	dc.b	'Based on original Z80 code by J.B. Langston',10,13
	dc.b	'Press RESET to exit',10,13,0
	
NoTmsMessage:
	dc.b    'TMS9918A not found, aborting!',10,13,0
	
	END	START


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
