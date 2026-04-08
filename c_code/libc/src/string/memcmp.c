/*
 * memcmp() - page 399 - figure 14.3
 * From The Standard C Library by P.J.Plauger (c) 1992
 */
 
#include <string.h>

/* compare unsigned char s1[n], s2[n] */
int memcmp(const void *s1, const void *s2, size_t n)
{
	const unsigned char *su1 = (const unsigned char *)s1;
	const unsigned char *su2 = (const unsigned char *)s2;

	for (; 0 < n; ++su1, ++su2, --n)
		if (*su1 != *su2)
			return (*su1 < *su2 ? -1 : +1);
	return (0);
}
