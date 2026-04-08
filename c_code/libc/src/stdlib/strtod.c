/*
 * strtod() - page 362 - figure 13.18
 * From The Standard C Library by P.J.Plauger (c) 1992
 */
 
#include <stdlib.h>

/* convert string to double, with checking */
double strtod(const char *s, char **endptr)
{
	return (_Stod(s, endptr));
}
