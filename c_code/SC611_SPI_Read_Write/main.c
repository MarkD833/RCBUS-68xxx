/******************************************************************************
* RCBus MC68000 - SC611 - SPI Write and Read
*******************************************************************************
* This demo program will attempt to write a text string to an external EEPROM
* connected to the SC611 SPI connector. It has been tested with a Microchip
* 25LC256 SPI EEPROM.
*
* If using a different SPI EEPROM, you may need to check the values for the
* commands.
******************************************************************************/

#include <stdint.h>
#include <textio.h>
#include "sc611.h"

/* message to write - max of 64 bytes in one go! */
char msg[] = "You are in open forest, with a deep valley to one side.";

char ch;
uint8_t txtAddrMSB = 0;
uint8_t txtAddrLSB = 0;

/* 25LC256 EEPROM Commands */
#define WRITE_CMD     0x02
#define READ_CMD      0x03
#define WRITE_DISABLE 0x04
#define WRITE_ENABLE  0x06

int main(void)
{
	putStr("Simple demo of SC611 writing to and reading from a 25LC256 EEPROM\n");
	
	spiInit();

	putStr("Enable writing to the EEPROM.\n");
	spiSelect( SDCard );
	spiTransfer( WRITE_ENABLE );
	spiDeselect();

	putStr("Writing the following null terminated phrase to address 0x0100 in the EEPROM:\n");
    putStr( msg );
	putStr("\n\n");

	spiSelect( SDCard );
	spiTransfer( WRITE_CMD );
	spiTransfer16( 0x0100 );
	for (uint8_t i=0; i<64; i++) {
		spiTransfer( msg[i] );
		if (msg[i] == 0) break;
	}
	spiDeselect();

	putStr("Now read back the text just written to the EEPROM.\n");

	spiSelect( SDCard );
	spiTransfer( READ_CMD );
	spiTransfer16( 0x0100 );

	for (uint8_t i=0; i<128; i++) {
		ch = spiTransfer( 0xFF );
		if (ch == 0) break;
		putCh( ch );
	}
	spiDeselect();
	putStr("\n\n");
	
    return 0;
}

