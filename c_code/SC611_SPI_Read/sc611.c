/******************************************************************************
* RCBus MC68000
*******************************************************************************
*  #####    #####    #####     #      #                    #####   ######   ### 
* #     #  #     #  #     #   ##     ##                   #     #  #     #   #  
* #        #        #        # #    # #                   #        #     #   #  
*  #####   #        ######     #      #        #####       #####   ######    #  
*       #  #        #     #    #      #                         #  #         #  
* #     #  #     #  #     #    #      #                   #     #  #         #  
*  #####    #####    #####   #####  #####                  #####   #        ###
*******************************************************************************
* SC611 - MicroSD card storage module.
* Coded to support SPI Mode 0.
******************************************************************************/

#include <stdint.h>
#include "sc611.h"


volatile uint8_t* const SC611 = (uint8_t*)SC611BASE;

/* copy of the last byte written to the SC611 output latch */
volatile uint8_t sc611Copy = 0;

/******************************************************************************
* spiInit - Initialise SC611 SPI board.
* Just sets all the available CS signals HIGH
******************************************************************************/
void spiInit( void )
{
	/* all outputs HIGH except SCK */
	sc611Copy = 0xEF;
	*SC611 = sc611Copy;
}

/******************************************************************************
* spiSelect - set a CS signal LOW.
******************************************************************************/
void spiSelect( enum spiCS cs )
{
	switch( cs ) {
		case SDCard:
			sc611Copy = 0xE7;
			break;
			
		case CS1:
			sc611Copy = 0xED;
			break;

		case CS2:
			sc611Copy = 0xEB;
			break;

		case CS5:
			sc611Copy = 0xCF;
			break;

		case CS6:
			sc611Copy = 0xAF;
			break;

		case CS7:
			sc611Copy = 0x6F;
			break;

		default:
			break;
	}
	*SC611 = sc611Copy;
}

/******************************************************************************
* spiDeselect - set all CS signals HIGH.
******************************************************************************/
void spiDeselect( void  )
{
	sc611Copy = 0xEF;
	*SC611 = sc611Copy;
}
