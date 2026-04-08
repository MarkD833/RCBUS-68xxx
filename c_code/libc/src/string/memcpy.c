/*
 * memcpy() - page 400 - figure 14.4
 * From The Standard C Library by P.J.Plauger (c) 1992
 */
 
#include <string.h>

/* copy char s2[n] to s1[n] in any order */
void *memcpy(void *s1, const void *s2, size_t n)
{
	char *su1 = (char *)s1;
	const char *su2 = (const char *)s2;

	for (; 0 < n; ++su1, ++su2, --n)
		*su1 = *su2;
	return (s1);
}
