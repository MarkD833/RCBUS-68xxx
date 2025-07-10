/******************************************************************************
* RCBus MC68000
*******************************************************************************
* #     #   #####    #####    #####    #####    #####     #   
* ##   ##  #     #  #     #  #     #  #     #  #     #   ##   
* # # # #  #        #        #     #  #        #     #  # #   
* #  #  #  #        ######    #####   ######    #####     #   
* #     #  #        #     #  #     #  #     #  #     #    #   
* #     #  #     #  #     #  #     #  #     #  #     #    #   
* #     #   #####    #####    #####    #####    #####   #####
*******************************************************************************
* MC68681 DUART
******************************************************************************/

#include <stdint.h>
#include <stdbool.h>
#include "mc68681.h"

/* MC68681 Registers - READ */
typedef struct __attribute__((packed)) {
	uint8_t		pad0;
	uint8_t		MODE_A;		/* MR1A & MR2A Register */
	uint8_t		pad1;
	uint8_t		STATUS_A;	/* Status - channel A Register */
	uint8_t		pad2;
	uint8_t		pad3;
	uint8_t		pad4;
	uint8_t		RXD_A;		/* Rx Data - channel A Register */
	uint8_t		pad5;
	uint8_t		IPCR;		/* Input Port Change Register */
	uint8_t		pad6;
	uint8_t		ISR;		/* Interrupt Status Register */
	uint8_t		pad7;
	uint8_t		CNTU;		/* Counter MSB Register */
	uint8_t		pad8;
	uint8_t		CNTL;		/* Counter LSB Register */
	uint8_t		pad9;
	uint8_t		MODE_B;		/* MR1B & MR2B Register */
	uint8_t		pad10;
	uint8_t		STATUS_B;	/* Status - channel B Register */
	uint8_t		pad11;
	uint8_t		pad12;
	uint8_t		pad13;
	uint8_t		RXD_B;		/* Rx Data - channel B Register */
	uint8_t		pad14;
	uint8_t		IVR;		/* Interrupt Vector Register */
	uint8_t		pad15;
	uint8_t		INPORT;		/* Input Port Register */
	uint8_t		pad16;
	uint8_t		CSTART;		/* Counter Start Register */
	uint8_t		pad17;
	uint8_t		CSTOP;		/* Counter Stop Register */
} MC68681rd;

/* MC68681 Registers - WRITE */
typedef struct __attribute__((packed)) {
	uint8_t		pad0;
	uint8_t		MODE_A;		/* MR1A & MR2A Register */
	uint8_t		pad1;
	uint8_t		CLK_A;		/* Clock Select - channel A Register */
	uint8_t		pad2;
	uint8_t		CMD_A;		/* Command - channel A Register */
	uint8_t		pad3;
	uint8_t		TXD_A;		/* Tx Data - channel A Register */
	uint8_t		pad4;
	uint8_t		ACR;		/* Auxiliary Control Register */
	uint8_t		pad5;
	uint8_t		IMR;		/* Interrupt Mask Register */
	uint8_t		pad6;
	uint8_t		CNTU;		/* Counter/Timer MSB Register */
	uint8_t		pad7;
	uint8_t		CNTL;		/* Counter/Timer LSB Register */
	uint8_t		pad8;
	uint8_t		MODE_B;		/* MR1B & MR2B Register */
	uint8_t		pad9;
	uint8_t		CLK_B;		/* Clock Select - channel B Register */
	uint8_t		pad10;
	uint8_t		CMD_B;		/* Command - channel B Register */
	uint8_t		pad11;
	uint8_t		TXD_B;		/* Tx Data - channel B Register */
	uint8_t		pad12;
	uint8_t		IVR;		/* Interrupt Vector Register */
	uint8_t		pad13;
	uint8_t		OPCR;		/* Output Port Configuration Register */
	uint8_t		pad14;
	uint8_t		OPSET;		/* Output Port Set Register */
	uint8_t		pad15;
	uint8_t		OPRESET;	/* Output Port Reset Register */
} MC68681wr;

volatile MC68681rd* const ser12rd = (MC68681rd*)SER12BASE;
volatile MC68681wr* const ser12wr = (MC68681wr*)SER12BASE;
volatile MC68681rd* const ser34rd = (MC68681rd*)SER34BASE;
volatile MC68681wr* const ser34wr = (MC68681wr*)SER34BASE;

static enum serCHAN currChan = SER1;

/******************************************************************************
* serInit - Initialise one of the serial ports on the dual SIO board.
* chan - serial channel
* baud - required baud rate
******************************************************************************/
void serInit( enum serCHAN chan, enum serBAUD baud )
{
	static bool ser12init = false;
	static bool ser34init = false;
	
	switch (chan) {
		case SER1:
			ser12wr->CMD_A = 0x30;	/* Reset Tx */
			ser12wr->CMD_A = 0x20;	/* Reset Rx */
			ser12wr->CMD_A = 0x10;	/* Reset Pointer */
			ser12wr->ACR = 0x00;	/* Baud rate set #1 */
			ser12wr->MODE_A = 0x13;	/* No Parity & 8-bit */
			ser12wr->MODE_A = 0x07;	/* Normal Mode, No CTS/RTS & 1 stop bit */
			ser12wr->CLK_A = baud;	/* Baud rate */
			
			/* don't write to the IMR if SER1 or SER2 already initialised */ 
			if (ser12init == false) {
				ser12init = true;
				ser12wr->IMR = 0x00;	/* No interrupts */
			}

			ser12wr->CMD_A = 0x05;	/* Enable Tx & Rx */
			break;
			
		case SER2:
			ser12wr->CMD_B = 0x30;	/* Reset Tx */
			ser12wr->CMD_B = 0x20;	/* Reset Rx */
			ser12wr->CMD_B = 0x10;	/* Reset Pointer */
			ser12wr->ACR = 0x00;	/* Baud rate set #1 */
			ser12wr->MODE_B = 0x13;	/* No Parity & 8-bit */
			ser12wr->MODE_B = 0x07;	/* Normal Mode, No CTS/RTS & 1 stop bit */
			ser12wr->CLK_B = baud;	/* Baud rate */

			/* don't write to the IMR if SER1 or SER2 already initialised */ 
			if (ser12init == false) {
				ser12init = true;
				ser12wr->IMR = 0x00;	/* No interrupts */
			}

			ser12wr->CMD_B = 0x05;	/* Enable Tx & Rx */
			break;
			
		case SER3:
			ser34wr->CMD_A = 0x30;	/* Reset Tx */
			ser34wr->CMD_A = 0x20;	/* Reset Rx */
			ser34wr->CMD_A = 0x10;	/* Reset Pointer */
			ser34wr->ACR = 0x00;	/* Baud rate set #1 */
			ser34wr->MODE_A = 0x13;	/* No Parity & 8-bit */
			ser34wr->MODE_A = 0x07;	/* Normal Mode, No CTS/RTS & 1 stop bit */
			ser34wr->CLK_A = baud;	/* Baud rate */

			/* don't write to the IMR if SER3 or SER4 already initialised */ 
			if (ser34init == false) {
				ser34init = true;
				ser34wr->IMR = 0x00;	/* No interrupts */
			}

			ser34wr->CMD_A = 0x05;	/* Enable Tx & Rx */
			break;
			
		case SER4:
			ser34wr->CMD_B = 0x30;	/* Reset Tx */
			ser34wr->CMD_B = 0x20;	/* Reset Rx */
			ser34wr->CMD_B = 0x10;	/* Reset Pointer */
			ser34wr->ACR = 0x00;	/* Baud rate set #1 */
			ser34wr->MODE_B = 0x13;	/* No Parity & 8-bit */
			ser34wr->MODE_B = 0x07;	/* Normal Mode, No CTS/RTS & 1 stop bit */
			ser34wr->CLK_B = baud;	/* Baud rate */

			/* don't write to the IMR if SER3 or SER4 already initialised */ 
			if (ser34init == false) {
				ser34init = true;
				ser34wr->IMR = 0x00;	/* No interrupts */
			}

			ser34wr->CMD_B = 0x05;	/* Enable Tx & Rx */
			break;
			
		default:
			break;
	}
}

/******************************************************************************
* serSetChan - set default channel for future printf's
******************************************************************************/
void serSetChan( enum serCHAN chan )
{
	currChan = chan;
}

/******************************************************************************
* putChar - output 1 character to the default serial port.
* Defaults to using Serial #1.
* ch - character to output
******************************************************************************/
void putchar_(char ch)
{
	switch (currChan) {
		case SER1:
			/* wait for tx ready flag */
			while ((ser12rd->STATUS_A & 0x04) == 0 ) {};
			
			/* write the char */
			ser12wr->TXD_A = ch;
			break;
			
		case SER2:
			/* wait for tx ready flag */
			while ((ser12rd->STATUS_B & 0x04) == 0 ) {};
			
			/* write the char */
			ser12wr->TXD_B = ch;
			break;
			
		case SER3:
			/* wait for tx ready flag */
			while ((ser34rd->STATUS_A & 0x04) == 0 ) {};
			
			/* write the char */
			ser34wr->TXD_A = ch;
			break;
			
		case SER4:
			/* wait for tx ready flag */
			while ((ser34rd->STATUS_B & 0x04) == 0 ) {};
			
			/* write the char */
			ser34wr->TXD_B = ch;
			break;
		
		default:
			break;
	}
}

