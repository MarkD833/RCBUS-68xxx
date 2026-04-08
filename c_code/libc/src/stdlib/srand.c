/*
 * srand() - page 359 - figure 13.11
 * From The Standard C Library by P.J.Plauger (c) 1992
 */
 
 /* srand function */
#include <stdlib.h>

/* alter the seed */
void srand(unsigned int seed)
{
	_Randseed = seed;
}
