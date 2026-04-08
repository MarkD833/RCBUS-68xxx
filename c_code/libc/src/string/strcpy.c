/*
 * strcpy() - page 402 - figure 14.12
 * From The Standard C Library by P.J.Plauger (c) 1992
 */

#include <string.h>

/* copy char s2[] to s1[] */ 
char *strcpy(char *s1, const char *s2)
{
	char *s = s1;
	
	for (s = s1; (*s++ = *s2++) != '\0'; );
	
	return (s1);
}
