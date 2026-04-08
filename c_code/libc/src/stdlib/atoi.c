/*
 * atoi() - page 361 - figure 13.13
 * From The Standard C Library by P.J.Plauger (c) 1992
 */
 
#include <stdlib.h>

/* convert string to int */
int atoi(const char *s)
{
	return ((int)_Stoul(s, NULL, 10));
}
