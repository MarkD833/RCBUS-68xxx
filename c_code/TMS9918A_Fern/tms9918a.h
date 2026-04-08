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

#define TMS_TRANSPARENT  0
#define TMS_BLACK        1
#define TMS_MEDIUMGREEN  2
#define TMS_LIGHTGREEN   3
#define TMS_DARKBLUE     4
#define TMS_LIGHTBLUE    5
#define TMS_DARKRED      6
#define TMS_CYAN         7
#define TMS_MEDIUMRED    8
#define TMS_LIGHTRED     9
#define TMS_DARKYELLOW   10
#define TMS_LIGHTYELLOW  11
#define TMS_DARKGREEN    12
#define TMS_MAGENTA      13
#define TMS_GRAY         14
#define TMS_WHITE        15

#define TmsSprite32		2

#define TMS_FGBG(fg, bg) ((fg) << 4 | (bg))

#define TMS_BITMAPCOLORTBL 0x2000
#define TMS_BITMAPCOLORLEN 0x1800

/******************************************************************************
* The TMS9918A address converted to 68000 memory space.
* #define TMSPORT IO_BASE+(TMS9918A_ADDR<<1)+1
*/

uint8_t tmsProbe( void );
void    tmsBackground( const uint8_t col );
void    tmsBitmap( void );
void    tmsChrOut( const uint8_t val );
void    tmsFill( const uint8_t val, const uint16_t vdest, const uint16_t count );
void	tmsLoadSprites( const uint8_t *src, const uint16_t count );
void    tmsPlotPixel( uint8_t x, uint8_t y );
void    tmsRamOut( const uint8_t val );
uint8_t tmsRegIn( void );
void    tmsRepeat( const uint8_t val, const uint16_t count );
void	tmsSpriteConfig( const uint8_t options );
void    tmsStrOut( const char *str );
void    tmsTextColor( const uint8_t col );
void    tmsTextMode( const uint8_t *font );
void    tmsTextPos( const uint8_t row, const uint8_t col );
void	tmsUpdateSprites( const uint8_t *src, const uint16_t count );

uint16_t testPlotPixel( uint8_t x, uint8_t y );

#endif
