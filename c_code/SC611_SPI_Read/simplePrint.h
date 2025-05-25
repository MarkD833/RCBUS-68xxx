/******************************************************************************
* RCBus MC68000
*******************************************************************************
*  #####   ###  #     #  ######   #        #######      ######   ######   ###  #     #  ####### 
* #     #   #   ##   ##  #     #  #        #            #     #  #     #   #   ##    #     #    
* #         #   # # # #  #     #  #        #            #     #  #     #   #   # #   #     #    
*  #####    #   #  #  #  ######   #        #####        ######   ######    #   #  #  #     #    
*       #   #   #     #  #        #        #            #        #   #     #   #   # #     #    
* #     #   #   #     #  #        #        #            #        #    #    #   #    ##     #    
*  #####   ###  #     #  #        #######  #######      #        #     #  ###  #     #     #
*******************************************************************************
* Simple print routines to output chars, strings, bytes, words, longs etc
* to serial port.
******************************************************************************/

#ifndef SIMPLEPRINT_H
#define SIMPLEPRINT_H

#include <stdint.h> 

void putCh( const char ch );
void putStr( const char *str );

void putByte( const uint8_t x );
void putWord( const uint16_t x );
void putLong( const uint32_t x );

void putInt( const int32_t i );

#endif
