*------------------------------------------------------------------------------
* Dual MFP board - TOGGLE
*------------------------------------------------------------------------------
* RCBus 68901 test program - simply toggle GPIO pin 0 on MFPA.
*------------------------------------------------------------------------------

*******************************************************************************
* Defines
*
MFP_BASE		EQU		$D10000 	* MC68901 base addr

*------------------------------------------------------------------------------
* MC68901 Multi-Function Peripheral Register Addresses
* MFP 8-bit data is on D0..D7 => odd addresses
* All registers are read/write?
*
GPDR	equ	MFP_BASE+$01	* General Purpose I/O Data Register
AER		equ	MFP_BASE+$03	* Active Edge Register
DDR		equ	MFP_BASE+$05	* Data Direction Register
IERA	equ	MFP_BASE+$07	* Interrupt Enable Register A
IERB	equ	MFP_BASE+$09	* Interrupt Enable Register B
IPRA	equ	MFP_BASE+$0B	* Interrupt Pending Register A
IPRB	equ	MFP_BASE+$0D	* Interrupt Pending Register B
ISRA	equ	MFP_BASE+$0F	* Interrupt In-service Register A
ISRB	equ	MFP_BASE+$11	* Interrupt In-service Register B
IMRA	equ	MFP_BASE+$13	* Interrupt Mask Register A
IMRB	equ	MFP_BASE+$15	* Interrupt Mask Register B
VR		equ	MFP_BASE+$17	* Vector Register
TACR	equ	MFP_BASE+$19	* Timer A Control Register
TBCR	equ	MFP_BASE+$1B	* Timer B Control Register
TCDCR	equ	MFP_BASE+$1D	* Timer C and D Control Register
TADR	equ	MFP_BASE+$1F	* Timer A Data Register
TBDR	equ	MFP_BASE+$21	* Timer B Data Register
TCDR	equ	MFP_BASE+$23	* Timer C Data Register
TDDR	equ	MFP_BASE+$25	* Timer D Data Register
SCR		equ	MFP_BASE+$27	* Synchronous Character Register
UCR		equ	MFP_BASE+$29	* USART Control Register
RSR		equ	MFP_BASE+$2B	* Receiver Status Register
TSR		equ	MFP_BASE+$2D	* Transmitter Status Register
UDR		equ	MFP_BASE+$2F	* USART Data Register

*------------------------------------------------------------------------------
* 
*------------------------------------------------------------------------------
    ORG     $100400
START:
	move.b	#$01,DDR		* Set IO port bit 0 as an output

forever:
	move.b	#$00,GPDR		* set IO port bit 0 low
	bsr.s	delay
	move.b	#$01,GPDR
	bsr.s	delay
	bra.s	forever	

delay:
	move.l	#$04,d1
.loop1:
	move.l	#$FFFF,d0
.loop2:
	nop
	dbra	d0,.loop2
	dbra	d1,.loop1
	rts

    END    START            * last line of source





















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
