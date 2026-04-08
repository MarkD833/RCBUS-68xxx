#include <stdint.h>
#include <stdlib.h>
#include <textio.h>
#include "v9958.h"

RGB palette[16] = {
    {0, 0, 0}, {1, 0, 0}, {4, 0, 0}, {4, 1, 1}, {15, 0, 0}, {0, 1, 0},   {0, 4, 0},   {1, 4, 1},
    {1, 8, 1}, {0, 0, 1}, {0, 0, 4}, {1, 1, 4}, {1, 1, 8},  {10, 0, 10}, {0, 15, 15}, {15, 15, 15},
};

int main()
{
    putStr("Testpit: V9958 Dots Demo for gcc\r\n");

    const uint8_t mode = PAL;
    const uint8_t lines = 212;

    putStr("setMode6\r\n");
    setMode6(lines, mode);

    putStr("setPalette\r\n");
    setPalette(palette);

    putStr("clearScreenBank0\r\n");
    clearScreenBank0(3);

    putStr("plot dots\r\n");
    uint16_t colour = 15;

    for(uint16_t y=10; y<lines; y=y+10) {
        for( uint16_t x=10; x<512; x=x+50) {
//            colour++;
            pointSet( x, y, colour & 15, CMD_LOGIC_IMP);

        }
    }

    return 0;
}
