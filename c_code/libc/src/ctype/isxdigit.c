/* isxdigit function */
/* test for hexadecimal digit */

#include <ctype.h>

int isxdigit(int c)
{
	if (isdigit(c))
		return 1;
	if (c >= 'A' && c <= 'F')
		return 1;
	if (c >= 'a' && c <= 'f')
		return 1;
	return 0;
}
