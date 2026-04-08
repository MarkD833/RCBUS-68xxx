/******************************************************************************
* RCBus MC68000
*******************************************************************************
*  #####    #####   #######    ###    #               ###   #####    #####  
* #     #  #     #  #    #    #   #   #    #           #   #     #  #     # 
* #        #            #    #     #  #    #           #         #  #       
*  #####   #           #     #     #  #    #   #####   #    #####   #       
*       #  #          #      #     #  #######          #   #        #       
* #     #  #     #    #       #   #        #           #   #        #     # 
*  #####    #####     #        ###         #          ###  #######   #####
*******************************************************************************
* SC704 - I2C Bus Master module.
******************************************************************************/

#ifndef SC704_H
#define SC704_H

#include <stdint.h>
#include "system.h"

/******************************************************************************
* The address of the SC704 card as set by jumpers on the actual board.
*/
#define SC704ADDR 0x0C

/******************************************************************************
* The SC704 address converted to 68000 memory space.
*/
const uint32_t SC704BASE = IO_BASE+(SC704ADDR<<1)+1;

void i2cInit( void );
uint8_t i2cReadFrom( uint8_t addr );
uint8_t i2cWriteTo( uint8_t addr );
uint8_t i2cRead( uint8_t *data );
uint8_t i2cWrite( uint8_t data );
void i2cStop( void );

#endif
