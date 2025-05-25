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
* SC611 - MicroSD card storgae module
******************************************************************************/

#ifndef SC611_H
#define SC611_H

#include <stdint.h>
#include "system.h"

/******************************************************************************
* The address of the SC611 card as set by jumpers on the actual board.
*/
#define SC611ADDR 0x69

/******************************************************************************
* The SC611 address converted to 68000 memory space.
*/
#define SC611BASE IO_BASE+(SC611ADDR<<1)+1

/* list of possible SPI chip select signals */
enum spiCS { SDCard, CS1, CS2, CS5, CS6, CS7 };
 
void spiInit( void );
void spiSelect( enum spiCS cs );
void spiDeselect( void );

extern uint8_t spiTransfer( uint8_t data );
extern uint16_t spiTransfer16( uint16_t data );

#endif
