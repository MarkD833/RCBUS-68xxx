/*
 * bsearch() - page 356 - figure 13.8
 * From The Standard C Library by P.J.Plauger (c) 1992
 */
 
#include <stdlib.h>

/* search sorted table by binary chop */
void *bsearch(const void *key, const void *base,
	size_t nelem, size_t size, _Cmpfun *cmp)
{
	const char *p;
	size_t n;

	for (p = (const char *)base, n = nelem; 0 < n; )
		{	/* check midpoint of whatever is left */
		const size_t pivot = n >> 1;
		const char *const q = p + size * pivot;
		const int val = (*cmp)(key, q);

		if (val < 0)
			n = pivot;	/* search below pivot */
		else if (val == 0)
			return ((void *)q);	/* found */
		else
			{	/* search above pivot */
			p = q + size;
			n -= pivot + 1;
			}
		}
	return (NULL);	/* no match */
}
