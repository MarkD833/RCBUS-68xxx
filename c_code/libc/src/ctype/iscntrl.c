/* iscntrl function */
/* test for control character */

#include <ctype.h>

int iscntrl(int c)
{
	if (c < 0x20 || c == 0x7f)
		return 1;
	return 0;
}
