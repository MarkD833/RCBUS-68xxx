/*
 * div() - page 355 - figure 13.5
 * From The Standard C Library by P.J.Plauger (c) 1992
 */
 
#include <stdlib.h>

/* compute int quotient and remainder */
div_t div(int numer, int denom)
{
	div_t val;

	val.quot = numer / denom;
	val.rem = numer - denom * val.quot;
	if (val.quot < 0 && 0 < val.rem)
		{	/* fix remainder with wrong sign */
		val.quot += 1;
		val.rem -= denom;
		}
	return (val);
}
