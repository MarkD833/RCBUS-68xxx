/*
 * difftime() - page 426 - figure 15.4
 * From The Standard C Library by P.J.Plauger (c) 1992
 *
 * Simplified to just subract t0 (the start time) from
 * t1 (the end time).
 */
 
#include <time.h>

/* compute difference in times */
double (difftime)(time_t t1, time_t t0)
{
	return t1 - t0;
}
