/*
 * rand() - page 359 - figure 13.10
 * From The Standard C Library by P.J.Plauger (c) 1992
 */
 
#include <stdlib.h>

/* the seed */
unsigned long _Randseed = 1;

/* compute pseudo-random value */
int rand(void)
{
	_Randseed = _Randseed * 1103515245 + 12345;
	return ((unsigned int)(_Randseed >> 16) & RAND_MAX);
}
