/* isalpha function */
/* test for alphabetic character */

#include <ctype.h>

int isalpha(int c)
{
	if (c >= 'A' && c <= 'Z')
		return 1;
	if (c >= 'a' && c <= 'z')
		return 1;
	return 0;
}
