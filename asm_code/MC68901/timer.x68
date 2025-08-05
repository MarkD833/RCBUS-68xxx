*------------------------------------------------------------------------------
* Dual MFP board - TIMER
*------------------------------------------------------------------------------
* RCBus 68901 test program - configure timer C to generate interrupts and an
* interrupt handler that sets a flag every half second so that GPIO pin 0 on
* MFPA can be toggled.
*
* MFP board - set J2 so MFP interrupt goes via INT2.
*
* SIO board - set J14 1-2 & 3-4 to share the UART 3.6864MHz clock.
* MFP board - set J6 1-2 to use external clock.
*
* With a divide by 200 prescaler, Timer C is clocked at 18.432KHz.
* Set Timer C counter to 0 (i.e. 256) so Timer C will time out every 13.888mS.
* Therefore half a second will be 36 interrupts.
*
* Add a wire jumper between MFP board J4-1 (MFP_A GPIO_0) and an SC129 digital
* i/o board P2-0 (IN) to get visual feedback on an LED. 
*------------------------------------------------------------------------------

*******************************************************************************
* Defines
*
MFP_BASE		EQU		$D10000 	* MC68901 base addr
AV2_ADDR        EQU     $100068     * AV2 vector table address

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
* D7 holds a count of the interrupts.
* D6 holds a flag to tell the main code that a 0.5sec timeout has occured.
*------------------------------------------------------------------------------
    ORG     $100400
START:
    * configure the 68901
    move.b  #$08,VR         * set software end of interrupt mode
	move.b	#$01,DDR		* set IO port bit 0 as an output
    move.b  #$20,IMRB       * allow Timer C interrupt
    move.b  #$20,IERB       * enable Timer C interrupt
    move.b  #0,TCDR         * put 256 into Timer C register
    move.l  #36,D7          * 36 timer interrupts = 0.5 seconds

    * insert the timer interrupt handler into the RAM vector table
    move.l  #timer_isr,AV2_ADDR

    move.w  #$2000,SR       * enable external interrupts
    move.b  #$70,TCDCR      * start Timer C with a div 200 prescaler
    
forever:
    * check if timeout flag has been set
   	btst    #0,D6           * test bit 0 of D6
	beq.s   forever

    eori.b  #1,GPDR         * toggle the GPIO Pin
	move.b  #0,D6           * clear the flag
	bra.s	forever	

timer_isr:
    move.b  #0,IPRB         * clear the interrupt pending register
    move.b  #$DF,ISRB       * clear the In-Service flag
    dbra    D7,timer_isr_exit
    move.b  #1,D6           * set the flag
    move.l  #36,D7          * reload our software down counter
timer_isr_exit:
    rte
    
    END    START            * last line of source
























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
