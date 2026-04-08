/******************************************************************************
* RCBus MC68000 - SC704 - I2C Device Scanner
*******************************************************************************
* This demo program will scan for devices connected to the I2C bus within the
* I2C device address range of 08..7F and print out the address of any device
* that responds with an ACK. 
******************************************************************************/

#include <stdint.h>
#include <textio.h>
#include "sc704.h"

uint8_t result;

int main(void)
{
	putStr("Simple demo of SC704 scanning I2C bus for devices\n");
	
	i2cInit();

	// scan each i2c address looking for an ACK
	for(uint8_t addr=0x8; addr<0x80; addr++) {
		result = i2cWriteTo( addr );
		i2cStop();
		if(result == 0 ) {
			putByte( addr );
			putStr( "\n" );
		}
	}

	putStr("Scan complete\n\n");
	
    return 0;
}

