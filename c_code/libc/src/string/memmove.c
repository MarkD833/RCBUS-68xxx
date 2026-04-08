/*
 * memmove() - page 400 - figure 14.5
 * From The Standard C Library by P.J.Plauger (c) 1992
 */
 
#include <string.h>

/* copy char s2[n] to s1[n] safely */
void *memmove(void *s1, const void *s2, size_t n)
{
	char *sc1 = (char *)s1;
	const char *sc2 = (const char *)s2;

	if (sc2 < sc1 && sc1 < sc2 + n)
		for (sc1 += n, sc2 += n; 0 < n; --n)
			*--sc1 = *--sc2;	/*copy backwards */
	else
		for (; 0 < n; --n)
			*sc1++ = *sc2++;	/* copy forwards */
	return (s1);
}
