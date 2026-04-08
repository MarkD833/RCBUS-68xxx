/*
 * labs() - page 356 - figure 13.6
 * From The Standard C Library by P.J.Plauger (c) 1992
 */
 
#include <stdlib.h>

/* compute absolute value of long argument */
long labs(long i)
{
	return ((i < 0) ? -i : i);
}
