/*
 * ldiv() - page 356 - figure 13.7
 * From The Standard C Library by P.J.Plauger (c) 1992
 */
 
#include <stdlib.h>

/* compute long quotient and remainder */
ldiv_t ldiv(long numer, long denom)
{
	ldiv_t val;

	val.quot = numer / denom;
	val.rem = numer - denom * val.quot;
	if (val.quot < 0 && 0 < val.rem)
		{	/* fix remainder with wrong sign */
		val.quot += 1;
		val.rem -= denom;
		}
	return (val);
}
