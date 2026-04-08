/*
 * strchr() - page 403 - figure 14.14
 * From The Standard C Library by P.J.Plauger (c) 1992
 */

#include <string.h>

/* find the first occurrence of c in char s[] */
char *strchr(const char *s, int c)
{
	const char ch = c;
	
	for ( ; *s != ch; ++s)
		if (*s == '\0') return (NULL);
	
	return ((char *)s);
}
