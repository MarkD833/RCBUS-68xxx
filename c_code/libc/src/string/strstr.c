/*
 * strstr() - page 405 - figure 14.19
 * From The Standard C Library by P.J.Plauger (c) 1992
 */
#include <string.h>

/* find first occurrence of s2[] in s1[] */
char *strstr(const char *s1, const char *s2)
{
	if (*s2 == '\0')
		return ((char *)s1);
	for (; (s1 = strchr(s1, *s2)) != NULL; ++s1)
		{	/* match rest of prefix */
		const char *sc1, *sc2;

		for (sc1 = s1, sc2 = s2; ; )
			if (*++sc2 == '\0')
				return ((char *)s1);
			else if (*++sc1 != *sc2)
				break;
		}
	return (NULL);
}
