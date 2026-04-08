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
    putStr("Testpit: V9958 Lines Demo for gcc\r\n");

    const uint8_t mode = PAL;
    const uint8_t lines = 212;

    putStr("setMode6\r\n");
    setMode6(lines, mode);

    putStr("setPalette\r\n");
    setPalette(palette);

    putStr("clearScreenBank0\r\n");
    clearScreenBank0(4);

    putStr("draw some lines\r\n");
    uint16_t colour = 15;

    drawLine( 10, 10, 10, 200, colour, CMD_LOGIC_IMP);
    drawLine( 10, 200, 200, 200, colour, CMD_LOGIC_IMP);
    drawLine( 200, 200, 200, 10, colour, CMD_LOGIC_IMP);
    drawLine( 200, 10, 10, 10, colour, CMD_LOGIC_IMP);

    return 0;
}
