/* isalnum function */
/* test for alphanumeric character */

#include <ctype.h>

int isalnum(int c)
{
	return isalpha(c) || isdigit(c);
}
