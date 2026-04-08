/*
 * strncmp() - page 401 - figure 14.8
 * From The Standard C Library by P.J.Plauger (c) 1992
 */
 
#include <string.h>

/* compare unsigned char s1[max n], s2[max n] */
int strncmp(const char *s1, const char *s2, size_t n)
{
	for (; 0 < n; ++s1, ++s2, --n)
		if (*s1 != *s2)
			return (*(unsigned char *)s1
				< *(unsigned char *)s2 ? -1 : +1);
		else if (*s1 == '\0')
			return (0);
	return (0);
}
