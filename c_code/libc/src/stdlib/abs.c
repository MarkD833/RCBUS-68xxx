/*
 * abs() - page 355 - figure 13.4
 * From The Standard C Library by P.J.Plauger (c) 1992
 */
 
#include <stdlib.h>

/* compute absolute value of int argument */
int abs(int i)
{
	return ((i < 0) ? -i : i);
}
