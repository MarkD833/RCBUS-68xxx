/* isprint function */
/* test for printable character */

#include <ctype.h>

int isprint(int c)
{	
	if (c >= 0x20 && c < 0x7f)
		return 1;
	return 0;
}
