/*
 * strtoul() - page 361 - figure 13.15
 * From The Standard C Library by P.J.Plauger (c) 1992
 */
 
#include <stdlib.h>

/* convert string to unsigned long, with checking */
unsigned long (strtoul)(const char *s, char **endptr, int base)
{
	return (_Stoul(s, endptr, base));
}
