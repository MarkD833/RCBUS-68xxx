/*
 * strtol() - page 362 - figure 13.16
 * From The Standard C Library by P.J.Plauger (c) 1992
 */
 
#include <ctype.h>
#include <errno.h>
#include <limits.h>
#include <stdlib.h>

/* convert string to long, with checking */
long strtol(const char *s, char **endptr, int base)
{
	const char *sc;
	char *se, sign;
	unsigned long x;

	if (endptr == NULL)
		endptr = &se;
	for (sc = s; isspace(*sc); ++sc)
		;
	sign = *sc == '-' || *sc == '+' ? *sc++ : '+';
	x = _Stoul(sc, endptr, base);
	if (sc == *endptr)
		*endptr = (char *)s;
	if ((s == *endptr && x != 0) || (sign == '+' && LONG_MAX < x)
		|| (sign == '-' && -(unsigned long)LONG_MIN < x))
		{	/* overflow */
		errno = ERANGE;
		return (sign == '-' ? LONG_MIN : LONG_MAX);
		}
	else
		return ((long)(sign == '-' ? -x : x));
}
