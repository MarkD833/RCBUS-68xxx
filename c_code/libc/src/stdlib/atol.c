/*
 * atol() - page 361 - figure 13.14
 * From The Standard C Library by P.J.Plauger (c) 1992
 */

#include <stdlib.h>

/* convert string to long */
long atol(const char *s)
{
	return ((long)_Stoul(s, NULL, 10));
}
