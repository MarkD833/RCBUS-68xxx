/*******************************************************************************
* RCBus-68000 TMS9918A Fern example program
*******************************************************************************
* Port of original assembler code by J.B. Langston
* https://github.com/jblang/TMS9918A
*******************************************************************************
*/
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include "simplePrint.h"
#include "mc68681.h"
#include "tms9918a.h"

int main(void)
{
uint8_t result;
float x = 0, y = 0, nx, ny;

	putStr("Simple demo of the TMSEMU (TMS9918A) video board.\n");
	putStr("Fern demo based on the Z80 code by JB Langston.\n");
	putStr("Does 2048 iterations then exits.\n");
	
	result = tmsProbe();
	
	if (result !=0 ) {
		tmsBitmap();
		tmsFill(TMS_FGBG(TMS_DARKGREEN, TMS_BLACK), TMS_BITMAPCOLORTBL, TMS_BITMAPCOLORLEN);

		for(uint16_t l=0; l<2048; l++) {
			uint8_t r = rand()/(RAND_MAX/100);
			if (r <= 1) {
				nx = 0;
				ny = 0.16 * y;
			} else if (r <= 8) {
				nx = 0.2 * x - 0.26 * y;
				ny = 0.23 * x + 0.22 * y + 1.6;
			} else if (r <= 15) {
				nx = -0.15 * x + 0.28 * y;
				ny = 0.26 * x + 0.24 * y + 0.44;
			} else {
				nx = 0.85 * x + 0.04 * y;
				ny = -0.04 * x + 0.85 * y + 1.6;
			}
			x = nx;
			y = ny;
			tmsPlotPixel(127+x*17, 191-y*17);
		};
	}
	else
	{
		putStr("\nCound not detect TMSEMU board at address 0x");
		putByte( TMS9918A_ADDR );
		putStr("\n\n");
	}
    return 0;
}
