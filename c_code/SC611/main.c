#include <stdint.h>
#include <stdio.h>
#include "mc68681.h"
#include "simplePrint.h"
#include "sc611.h"

char ch;
uint8_t txtAddrMSB = 0;
uint8_t txtAddrLSB = 0;

#define READ_CMD 0x03

int main(void)
{
	putStr("Simple demo of SC611 reading from a 25LC256 EEPROM\n");
	
	spiInit();

	spiSelect( SDCard );
	spiTransfer( READ_CMD );
	spiTransfer16( 0x0000 );
	txtAddrLSB = spiTransfer( 0xFF );
	txtAddrMSB = spiTransfer( 0xFF );
	spiDeselect();
	
	putStr("Text string is at address 0x");
	putByte( txtAddrMSB );
	putByte( txtAddrLSB );
	putStr("\nText: ");
	
	spiSelect( SDCard );
	spiTransfer( READ_CMD );
	spiTransfer( txtAddrMSB );
	spiTransfer( txtAddrLSB );

	for (uint8_t i=0; i<128; i++) {
		ch = spiTransfer( 0xFF );
		if (ch == 0) break;
		putCh( ch );
	}
	spiDeselect();
	putStr("\n\n");
	
    return 0;
}

