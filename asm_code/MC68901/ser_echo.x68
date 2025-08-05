*------------------------------------------------------------------------------
* Dual MFP board - SER_ECHO
*------------------------------------------------------------------------------
* RCBus 68901 test program - simpley echo back the received character.
*
* SIO board - set J14 1-2 & 3-4 to share the UART 3.6864MHz clock.
* MFP board - set J6 1-2 to use external clock.
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
* Initialise the MC68901 USART - Timer D hard wired to provide the USART clock
* Base clock for all timers is 3.6864MHz from the SIO board (set the jumpers!)
*
* For 9600 baud : divider = clock / prescaler / 16 / baud rate = 6
* Clock is fixed at 3.6864MHz (from SIO board) and prescaler is 4
*
* Timer D counts down from 3 - we need the output to toggle twice (i.e. high then low)
*------------------------------------------------------------------------------

    ORG     $100400
START:
	move.b	#$01,TCDCR		* Timer D div 4 prescaler (Timer C stopped)
	move.b	#$03,TDDR		* Count down from 3
	
	move.b	#$88,UCR		* 1/16th clock, 8 bits, 1 start, 1 stop, no parity
	move.b	#$05,TSR		* Tx pin HIGH, Tx enabled
    move.b  #$01,RSR        * Rx enabled
    
    lea     strTitle(PC), a0	* Show the program details
    bsr.w   putString

	move.b	#'A',UDR		* Send an 'A' to the USART

.endless:
    btst.b  #7,RSR          * check for a character
    beq.s   .endless

    move.b  UDR,d0          * get the character
    move.b  d0,UDR          * and echo it back
	bra.s	.endless

*------------------------------------------------------------------------------
* Prints a newline (CR, LF)
* NOTE: the putString function must follow this function
*------------------------------------------------------------------------------
putCRLF:
    lea     strNewline(PC), a0

*------------------------------------------------------------------------------
* Print a null terminated string
* A0 holds the address of the first character of the null terminated string
*------------------------------------------------------------------------------
putString:
.loop:
    move.b  (a0)+, d0    * Read in character
    beq.s   .end         * Check for the null
    
    bsr.s   putc		 * Otherwise write the character
    bra.s   .loop        * And continue
.end:
    rts

*------------------------------------------------------------------------------
* Write a character to UART Port A, blocking if UART is not ready
* D0 = char to send
*------------------------------------------------------------------------------
putc:
    move.b  d0,d1       * move char to D1
    move.b  #6,D0       * task 6
    trap    #15
	rts

strTitle:
	dc.b 10,13,'Simple 68901 Character Echo',10,13,0
strNewline:
    dc.b 10,13,0

    END    START            * last line of source




















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
