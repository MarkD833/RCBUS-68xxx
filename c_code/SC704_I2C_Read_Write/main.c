/******************************************************************************
* RCBus MC68000 - SC704 - I2C Write and Read
*******************************************************************************
* This demo program will attempt to write a text string to the on-board 24LC256
* EEPROM and read it back again.
* The EEPROM address jumpers JP2, JP3 & JP4 should be in the lower position to
* set the device address to 0x50. The Write Protect jumper JP5 should be set to
* Write Enabled.
******************************************************************************/

#include <stdint.h>
#include <textio.h>
#include "sc704.h"

#define EE_ADDR 0x50

/* message to write - max of 63 bytes in one go! */
char msg[] = "You are in open forest, with a deep valley to one side.";

uint8_t data;

uint8_t result;

int main(void)
{
	i2cInit();

	putStr("Simple demo of SC704 writing to and reading from the on-board EEPROM\n");
	
	i2cInit();

	putStr("Writing the following null terminated phrase to address 0x0100 in the EEPROM:\n");
    putStr( msg );
	putStr("\n\n");

	i2cInit();

	// tell the EEPROM the address to start writing to
	if (i2cWriteTo( EE_ADDR ) == 0 ) {
		i2cWrite( 0x01 );
		i2cWrite( 0x00 );

		// now write the message to the EEPROM
		for (uint8_t i=0; i<64; i++) {
			i2cWrite( msg[i] );
			if (msg[i] == 0) break;
		}
		i2cStop();
	}
	
	putStr("Now read back the text just written to the EEPROM.\n");

	// tell the EEPROM the address to start reading from
	if (i2cWriteTo( EE_ADDR ) == 0 ) {
		i2cWrite( 0x01 );
		i2cWrite( 0x00 );
		i2cStop();

		// now read from that address in the EEPROM
		if( i2cReadFrom( EE_ADDR ) == 0 ) {
			for (uint8_t i=0; i<64; i++) {
				result = i2cRead( &data );
				if ( data == 0 ) break;
				putCh( data );
			}
			i2cStop();
			putStr( "\n" );
		}
	}
	
	putStr("\n\n");
	
    return 0;
}

