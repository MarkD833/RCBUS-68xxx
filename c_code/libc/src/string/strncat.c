/*
 * strncat() - page 401 - figure 14.7
 * From The Standard C Library by P.J.Plauger (c) 1992
 */
 
#include <string.h>

/* copy char s2[max n] to end of s1[] */
char *strncat(char *s1, const char *s2, size_t n)
{
	char *s;

	for (s = s1; *s != '\0'; ++s)
		;	/* find end of s1[] */
	for (; 0 < n && *s2 != '\0'; --n)
		*s++ = *s2++;	/* copy at most n chars from s2[] */
	*s = '\0';
	return (s1);
}
