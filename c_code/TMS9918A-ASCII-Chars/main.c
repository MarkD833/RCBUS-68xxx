#include <stdint.h>
#include <stdio.h>
#include "simplePrint.h"
#include "mc68681.h"
#include "tms9918a.h"
#include "tmsfont.h"

/******************************************************************************
* Border character definitions - must match characters in the chosen font.
*/
# define DOUBLEHORIZONTAL  205
# define DOUBLEVERTICAL    186
# define DOUBLETOPLEFT     201
# define DOUBLETOPRIGHT    187
# define DOUBLEBOTTOMLEFT  200
# define DOUBLEBOTTOMRIGHT 188

void textBorder( void );

const char title[] = "ASCII Character Set";

int main(void)
{
uint8_t result;
uint8_t ch=0;

	putStr("Simple demo of the TMSEMU (TMS9918A) video board.\n");
	putStr("ASCII character set based on the Z80 code by JB Langston.\n");
	
	result = tmsProbe();
//	putLong( result );
	
	if (result !=0 ) {
		tmsTextMode( font );
		tmsBackground( TmsDarkBlue );
		tmsTextColor( TmsWhite );
		
		textBorder();
		
		tmsTextPos( 2, 11 );
		tmsStrOut( title );

		for(uint8_t y=0; y<8; y++)
		{
			tmsTextPos( 6+(y<<1), 4 );
			for(uint8_t x=0;x<32; x++)
			{
				tmsRamOut( ch++ );
			}
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

void textBorder()
{
	// draw the top border
	tmsTextPos( 0, 0 );
	tmsChrOut( DOUBLETOPLEFT );
	tmsRepeat( DOUBLEHORIZONTAL, 38 );
	tmsChrOut( DOUBLETOPRIGHT );

	// then the side borders 
	for ( uint8_t row=0; row<22; row++)
	{
		tmsChrOut( DOUBLEVERTICAL );
		tmsRepeat( ' ', 38 );
		tmsChrOut( DOUBLEVERTICAL );
	}

	// then the bottom border
	tmsChrOut( DOUBLEBOTTOMLEFT );
	tmsRepeat( DOUBLEHORIZONTAL, 38 );
	tmsChrOut( DOUBLEBOTTOMRIGHT );
}
