/* toupper function */
/* convert to uppercase character */

#include <ctype.h>

int toupper(int c)
{
	if (c >= 'a' && c <= 'z')
		return c - 'a' + 'A';
	return c;
}
