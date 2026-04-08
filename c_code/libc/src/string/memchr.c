/*
 * memchr() - page 399 - figure 14.2
 * From The Standard C Library by P.J.Plauger (c) 1992
 */
#include <string.h>

/* find first occurrence of c in s[n] */
void *memchr(const void *s, int c, size_t n)
{
	const unsigned char uc = c;
	const unsigned char *su = (const unsigned char *)s;

	for (; 0 < n; ++su, --n)
		if (*su == uc)
			return ((void *)su);
	return (NULL);
}
