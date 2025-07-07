/*******************************************************************************
* RCBus-68000 Nyan Cat TMS9918A example program
*******************************************************************************
* Port of original code by J.B. Langston - video only
* https://github.com/jblang/TMS9918A
*******************************************************************************
* Nyan Cat for RC2014 and SC126 with TMS9918 and YM2149
* Hand-written assembly by J.B. Langston
* Nyan Cat images from Passan Kiskat by Dromedaar Vision: http://www.dromedaar.com/
* Nyan Cat theme by Karbofos: https://zxart.ee/eng/authors/k/karbofos/tognyanftro/qid:136394/
* PTx Player by S.V.Bulba <vorobey@mail.khstu.ru>
*/

#include <stdint.h>
#include <stdio.h>
#include "simplePrint.h"
#include "mc68681.h"
#include "tms9918a.h"
#include "nyan.c"

const uint16_t TmsMulticolorPatternLen = 0x600;

const uint8_t vsyncDiv = 3;		// number of interrupts per animation frame

uint8_t vsyncCount = 0;
uint8_t currFrame = 0;
uint16_t animIndex = 0;

int main(void)
{
uint8_t result;

	putStr("Simple demo of the TMSEMU (TMS9918A) video board.\n");
	putStr("Nyan cat demo based on the Z80 code by JB Langston.\n");

	result = tmsProbe();
	
	if (result !=0 ) {
		tmsMultiColor();
		tmsBackground( TmsDarkBlue );
		
		animIndex = 0;

		while( 1 ) {

			// wait for 3 vsyncs
			for ( vsyncCount=0; vsyncCount<vsyncDiv; vsyncCount++ ) {
				while (( tmsRegIn() & 0x80 ) == 0 ) {
				};
			};

			// copy the animation frame into vram
			tmsUpdateMultiColor( &rawData[ animIndex ] );
			animIndex = animIndex + TmsMulticolorPatternLen;

			// wrap round to start frame once all frames are done
			if ( animIndex >= sizeof( rawData ) ) animIndex = 0;
		}
	}
	else
	{
		putStr("\nCound not detect TMSEMU board at address 0x");
		putByte( TMS9918A_ADDR );
		putStr("\n\n");
	}
    return 0;
}
