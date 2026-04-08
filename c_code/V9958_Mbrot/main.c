#include <stdint.h>
#include <stdlib.h>
#include <textio.h>

#include "v9958.h"

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
    putStr("Testpit: V9958 Mandelbrot Demo for gcc\r\n");

    const uint8_t mode = PAL;
    const uint8_t lines = 212;

    putStr("setMode6\r\n");
    setMode6(lines, mode);

    putStr("setPalette\r\n");
    setPalette(palette);

    putStr("clearScreenBank0\r\n");
    clearScreenBank0(4);

    putStr("plot mandelbrot\r\n");

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

