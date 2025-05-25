#include <stdint.h>
#include <stdio.h>
#include "mc68681.h"
#include "simplePrint.h"
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

