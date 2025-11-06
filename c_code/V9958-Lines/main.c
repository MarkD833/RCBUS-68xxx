#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "v9958.h"

// Forward references so we can put main() first at a known start
// address.
void printString(const char *s);
void printNumber(unsigned int n);
void printNum(const uint32_t n);
void outCh(char c);
void realOutCh(char c);

RGB palette[16] = {
    {0, 0, 0}, {1, 0, 0}, {4, 0, 0}, {4, 1, 1}, {15, 0, 0}, {0, 1, 0},   {0, 4, 0},   {1, 4, 1},
    {1, 8, 1}, {0, 0, 1}, {0, 0, 4}, {1, 1, 4}, {1, 1, 8},  {10, 0, 10}, {0, 15, 15}, {15, 15, 15},
};

int main()
{
    printString("Testpit: V9958 Lines Demo for gcc\r\n");

    const uint8_t mode = PAL;
    const uint8_t lines = 212;

    printString("setMode6\r\n");
    setMode6(lines, mode);

    printString("setPalette\r\n");
    setPalette(palette);

    printString("clearScreenBank0\r\n");
    clearScreenBank0(4);

    printString("draw some lines\r\n");
    uint16_t colour = 15;

    drawLine( 10, 10, 10, 200, colour, CMD_LOGIC_IMP);
    drawLine( 10, 200, 200, 200, colour, CMD_LOGIC_IMP);
    drawLine( 200, 200, 200, 10, colour, CMD_LOGIC_IMP);
    drawLine( 200, 10, 10, 10, colour, CMD_LOGIC_IMP);

    return 0;
}

/******************************************************************************
* VARIOUS PRINTING ROUTINES 
******************************************************************************/

// Print a character to the simulated IO on EASy68K
void outCh(char c) {
    asm(
        "move.b #6,%%d0\n\t"
        "move.b %0,%%d1\n\t"
        "trap #15\n\t"
    : /* outputs */
    : "r" (c) /* inputs */
    : "d0", "d1" /* clobbered regs */
    );
}

// Print a character to the SCC68681 DUART channel A
void realOutCh(char c) {
volatile char *SRA = (char *)(0xD00003);
volatile char *TBA = (char *)(0xD00007);

   /* Wait till the buffer becomes empty */
   while ( (*SRA & 0x04) == 0 );

   /* Copy the character to the buffer */
   *TBA = c;
}


// Print a string.
void printString(const char *s) {
    while (*s != 0) {
        outCh(*s);
        s++;
    }
}

char tempBuff[20];

void printNum(const uint32_t val)
{
    uint32_t v = val;
    uint8_t  p = 0;

    if(val!=0) {
        while((v != 0) && (p<16)) {
            tempBuff[p++] = 48+(v%10);
            v=v/10;
        }
        tempBuff[p]=0;
        strrev(tempBuff);
        printString(tempBuff);
    }
    else {
        outCh('0');
    }
}

// Quick and dirty routine to print decimal number up to 10 digits
// long. Suppresses leading zeros.
void printNumber(unsigned int n) {
    unsigned int d;
    short digitPrinted = 0;
    unsigned int mult = 1000000000;

    while (mult > 1) {
        d = n / mult;
        if (d == 0) {
            if (digitPrinted) {
                outCh(d + '0');
            }
        } else {
            outCh(d + '0');
            digitPrinted = 1;
        }
        n = n - d * mult;
        mult = mult / 10;
    }
    outCh(n + '0');
}
