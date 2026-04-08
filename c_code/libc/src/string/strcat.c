/*
 * strcat() - page 402 - figure 14.10
 * From The Standard C Library by P.J.Plauger (c) 1992
 */

#include <string.h>

/* copy char s2[] to end of s1[] */
char *strcat(char *s1, const char *s2)
{
	char *s;

	for (s = s1; *s != '\0'; ++s)
		;			/* find end of s1[] */
	for (; (*s = *s2) != '\0'; ++s, ++s2)
		;			/* copy s2[] to end */
	return (s1);
}
