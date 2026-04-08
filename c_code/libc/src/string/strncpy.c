/*
 * strncpy() - page 402 - figure 14.9
 * From The Standard C Library by P.J.Plauger (c) 1992
 */
 
#include <string.h>

/* copy char s2[max n] to s1[n] */
char *strncpy(char *s1, const char *s2, size_t n)
{
	char *s;

	for (s = s1; 0 < n && *s2 != '\0'; --n)
		*s++ = *s2++;	/* copy at most n chars from s2[] */
	for (; 0 < n; --n)
		*s++ = '\0';
	return (s1);
}
