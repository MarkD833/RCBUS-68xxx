/******************************************************************************
* RCBus MC68000
*******************************************************************************
* #######  #     #   #####    #####    #####     #     #####      #    
*     #     ##   ##  #     #  #     #  #     #   ##    #     #    # #   
*     #     # # # #  #        #     #  #     #  # #    #     #   #   #  
*     #     #  #  #   #####    ######   ######    #     #####   #     # 
*     #     #     #        #        #        #    #    #     #  ####### 
*     #     #     #  #     #  #     #  #     #    #    #     #  #     # 
*     #     #     #   #####    #####    #####   #####   #####   #     #
*******************************************************************************
* TMS9918A - TMSEMUv3 low level code.
******************************************************************************/

#ifndef TMS9918A_H
#define TMS9918A_H

#include <stdint.h>
#include "system.h"

/******************************************************************************
* The address of the TMS9918A card as set by the jumper on the actual board.
*/
#define TMS9918A_ADDR 0x98

/******************************************************************************
* color constants - TMS9918 VDP Programmer Guide Table 2.1
*/

#define TmsTransparent  0
#define TmsBlack        1
#define TmsMediumGreen  2
#define TmsLightGreen   3
#define TmsDarkBlue     4
#define TmsLightBlue    5
#define TmsDarkRed      6
#define TmsCyan         7
#define TmsMediumRed    8
#define TmsLightRed     9
#define TmsDarkYellow   10
#define TmsLightYellow  11
#define TmsDarkGreen    12
#define TmsMagenta      13
#define TmsGray         14
#define TmsWhite        15

/******************************************************************************
* The TMS9918A address converted to 68000 memory space.
* #define TMSPORT IO_BASE+(TMS9918A_ADDR<<1)+1
*/

uint8_t tmsProbe( void );
void    tmsBackground( const uint8_t col );
void    tmsChrOut( const uint8_t val );
void    tmsRamOut( const uint8_t val );
void    tmsRepeat( const uint8_t val, const uint8_t count );
void    tmsStrOut( const char *str );
void    tmsTextColor( const uint8_t col );
void    tmsTextMode( const uint8_t *font );
void    tmsTextPos( const uint8_t row, const uint8_t col );

#endif
