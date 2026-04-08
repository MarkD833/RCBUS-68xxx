/*
 * memset() - page 400 - figure 14.6
 * From The Standard C Library by P.J.Plauger (c) 1992
 */

#include <string.h>

/* store c throughout unsigned char s[n] */
void *memset(void *s, int c, size_t n)
{
	const unsigned char uc = c;
	unsigned char *su = (unsigned char *)s;

	for (; 0 < n; ++su, --n)
		*su = uc;
	return (s);
}
