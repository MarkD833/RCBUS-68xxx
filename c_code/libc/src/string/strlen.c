/*
 * strlen() - page 403 - figure 14.13
 * From The Standard C Library by P.J.Plauger (c) 1992
 */

#include <string.h>

/* find the length of s[] */
size_t (strlen)(const char *s)
{
	const char *sc;
	
	for (sc = s; *sc != '\0'; ++sc);
	
	return (sc - s);
}
