/*
 * strrchr() - page 404 - figure 14.18
 * From The Standard C Library by P.J.Plauger (c) 1992
 */

#include <string.h>

/* find last occurrence of c in char s[] */
char *strrchr(const char *s, int c)
{
	const char ch = c;
	const char *sc;

	for (sc = NULL; ; ++s)
	{	/* check another char */
		if (*s == ch)
			sc = s;
		if (*s == '\0')
			return ((char *)sc);
	}
}
