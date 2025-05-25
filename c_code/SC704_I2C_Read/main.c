#include <stdint.h>
#include <stdio.h>
#include "mc68681.h"
#include "simplePrint.h"
#include "sc704.h"

#define EE_ADDR 0x50

char ch;

uint8_t result;
uint8_t data[16];

int main(void)
{
	putStr("Simple demo of SC704 reading from on-board EEPROM\n");
	putStr("Reading 16 bytes from address 0x0000 onwards\n");
	putStr("Assumes on-board EEPROM address is 0x50\n\n");
	
	i2cInit();

	// tell the EEPROM the address to start reading from
	if (i2cWriteTo( EE_ADDR ) == 0 ) {
		i2cWrite( 0x00 );
		i2cWrite( 0x00 );
		i2cStop();

		// now read from that address in the EEPROM
		if( i2cReadFrom( EE_ADDR ) == 0 ) {
			for(uint8_t x=0;x<16;x++) {
				result = i2cRead( &data[x] );
				putByte( data[x] );
				putCh( ' ' );
			}
			putStr( "\n" );
		}
	}
	
	putStr("Read complete\n\n");
	
    return 0;
}

