/******************************************************************************
* RCBus MC68000
*******************************************************************************
*  ####### ####### #     # #######    ### ####### 
*     #    #        #   #     #        #  #     # 
*     #    #         # #      #        #  #     # 
*     #    #####      #       #        #  #     # 
*     #    #         # #      #        #  #     # 
*     #    #        #   #     #        #  #     # 
*     #    ####### #     #    #       ### ####### 
*******************************************************************************
* Simple print routines to output chars, strings, bytes, words, longs etc
* to the serial port.
******************************************************************************/

#include <stdint.h> 
#include <stdbool.h>

#include "textio.h"

void reverse(char str[], int length);
char* citoa(int num, char* str, int base);

const char hexDigit[] = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};
char strBuf[32];

/******************************************************************************
* Simple routine to write a char to the serial port.
* Uses the EASy68K TRAP#15 routine implemented in the monitor program to output
* the char to the monitor console port.
******************************************************************************/
void putCh( const char ch )
{
    asm(
        "move.b #6,%%d0\n\t"
        "move.b %0,%%d1\n\t"
        "trap #15\n\t"
    : /* outputs */
    : "r" (ch) /* inputs */
    : "d0", "d1" /* clobbered regs */
    );
}

/******************************************************************************
* Simple routine to write a null terminated string to the serial port.
******************************************************************************/
void putStr( const char *str )
{
	while ( *str != 0 ) {
		/* if LF then add in a CR */
		if ( *str == 0x0A ) putCh( 0x0D );
		putCh( *str++ );
	}
}

/******************************************************************************
* Simple routine to write a hexadecimal byte as 2 ASCII characters to the
* serial port.
******************************************************************************/
void putByte( const uint8_t x )
{
	putCh( hexDigit[ (x >> 4) & 0x0F ] );
	putCh( hexDigit[ x & 0x0F ] );
}

/******************************************************************************
* Simple routine to write a hexadecimal word as 4 ASCII characters to the
* serial port.
******************************************************************************/
void putWord( const uint16_t x )
{
	putByte( (x >> 8) & 0xFF );
	putByte( x & 0xFF );
}

/******************************************************************************
* Simple routine to write a hexadecimal long word as 8 ASCII characters to the
* serial port.
******************************************************************************/
void putLong( const uint32_t x )
{
	putWord( (x >> 16) & 0xFFFF );
	putWord( x & 0xFFFF );
}

/******************************************************************************
* simple routine to write a small integer (<1,000,000) as ASCII to the serial port
******************************************************************************/
void putInt( const int32_t i )
{
	citoa( i, strBuf, 10 );
	putStr( strBuf );
}

/******************************************************************************
* Simple itoa function from https://www.geeksforgeeks.org/implement-itoa/
******************************************************************************/
char* citoa(int num, char* str, int base)
{
    int i = 0;
    bool isNegative = false;

    /* Handle 0 explicitly, otherwise empty string is
     * printed for 0 */
    if (num == 0) {
        str[i++] = '0';
        str[i] = '\0';
        return str;
    }

    // In standard itoa(), negative numbers are handled
    // only with base 10. Otherwise numbers are
    // considered unsigned.
    if (num < 0 && base == 10) {
        isNegative = true;
        num = -num;
    }

    // Process individual digits
    while (num != 0) {
        int rem = num % base;
        str[i++] = (rem > 9) ? (rem - 10) + 'a' : rem + '0';
        num = num / base;
    }

    // If number is negative, append '-'
    if (isNegative)
        str[i++] = '-';

    str[i] = '\0'; // Append string terminator

    // Reverse the string
    reverse(str, i);

    return str;
}

/******************************************************************************
* Simple string reversal function from https://www.geeksforgeeks.org/implement-itoa/
******************************************************************************/
void reverse(char str[], int length)
{
    int start = 0;
    int end = length - 1;
    while (start < end) {
        char temp = str[start];
        str[start] = str[end];
        str[end] = temp;
        end--;
        start++;
    }
}
