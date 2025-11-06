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

float fabs(float v);

RGB palette[16] = {
    {0, 0, 0}, {1, 0, 0}, {2, 0, 0},  {3, 0, 0},  {4, 0, 0},  {5, 0, 0},  {6, 0, 0},  {7, 0, 0},
    {8, 0, 0}, {9, 0, 0}, {10, 0, 0}, {11, 0, 0}, {12, 0, 0}, {13, 0, 0}, {14, 0, 0}, {15, 0, 0}
};

#define ITERATION_MAX 16
#define CX_MIN        -2.5
#define CX_MAX        1.5
#define CY_MIN        -2.0
#define CY_MAX        2.0
#define IX_MAX        512

#define PIXEL_WIDTH ((CX_MAX - CX_MIN) / IX_MAX)

#define ESCAPE_RADIUS 2
/* bail-out value , radius of circle ;  */
#define ER2 (ESCAPE_RADIUS * ESCAPE_RADIUS)

float Cx;
float Cy;
float Zx;
float Zy;
float Zx2;
float Zy2;

/* screen ( integer) coordinate */
uint16_t iX, iY;
uint8_t  iteration;
float fv;

int main()
{
    printString("Testpit: V9958 Mandelbrot Demo for gcc\r\n");

    const uint8_t mode = PAL;
    const uint8_t lines = 212;

    printString("setMode6\r\n");
    setMode6(lines, mode);

    printString("setPalette\r\n");
    setPalette(palette);

    printString("clearScreenBank0\r\n");
    clearScreenBank0(4);

    printString("plot mandelbrot\r\n");

    const float pixelHeight = ((CY_MAX - CY_MIN) / lines);

    for (iY = 0; iY < lines; iY++) {
        Cy = CY_MIN + iY * pixelHeight;

        if (fabs(Cy) < pixelHeight / 2)
            Cy = 0.0;

        for (iX = 0; iX < IX_MAX; iX++) {
            Cx = CX_MIN + iX * PIXEL_WIDTH;

            Zx  = 0.0;
            Zy  = 0.0;
            Zx2 = Zx * Zx;
            Zy2 = Zy * Zy;

            for (iteration = 0; iteration < ITERATION_MAX && ((Zx2 + Zy2) < ER2); iteration++) {
            Zy  = 2 * Zx * Zy + Cy;
            Zx  = Zx2 - Zy2 + Cx;
            Zx2 = Zx * Zx;
            Zy2 = Zy * Zy;
            };

            pointSet(iX, iY, iteration, CMD_LOGIC_IMP);
        }
    }
    return 0;
}

float fabs(float fval)
{
	asm(
		"andi.l #0x7FFFFFFF,%0"
		: "+r" (fval)     /* param %0 called fval in C code */
		: /* no inputs */
		: /* no clobbers */
		);

	return fval;
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
