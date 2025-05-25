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
* to the serial port.
******************************************************************************/

#include <stdint.h> 
#include <stdbool.h>

#include "simplePrint.h"

void reverse(char str[], int length);
char* citoa(int num, char* str, int base);

/* locations for serial port #1 status register and transmit register */
volatile uint8_t* const SRA = (uint8_t*) 0xD00003;
volatile uint8_t* const TBA = (uint8_t*) 0xD00007;

const char hexDigit[] = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};
char strBuf[32];

/******************************************************************************
* simple routine to write a char to serial port #1
******************************************************************************/
void putCh( const char ch )
{
	/* wait for tx to be ready for a new char */
	while (( *SRA & 0x04 ) == 0 ) {};
	
	/* write the character */
	*TBA = ch;
}

/******************************************************************************
* simple routine to write a null terminated string to the serial port
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
* simple routine to write a hexadecimal byte as ASCII to the serial port
******************************************************************************/
void putByte( const uint8_t x )
{
	putCh( hexDigit[ (x >> 4) & 0x0F ] );
	putCh( hexDigit[ x & 0x0F ] );
}

/******************************************************************************
* simple routine to write a hexadecimal word as ASCII to the serial port
******************************************************************************/
void putWord( const uint16_t x )
{
	putByte( (x >> 8) & 0xFF );
	putByte( x & 0xFF );
}

/******************************************************************************
* simple routine to write a hexadecimal long word as ASCII to the serial port
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
