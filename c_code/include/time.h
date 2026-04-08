/*
 * time.h standard header - page 424 - figure 15.1
 * From The Standard C Library by P.J.Plauger (c) 1992
 */

#ifndef _TIME
#define _TIME

#ifdef __cplusplus
extern "C" {
#endif

typedef unsigned long time_t;

struct tm {
	int tm_sec;
	int tm_min;
	int tm_hour;
	int tm_mday;
	int tm_mon;
	int tm_year;
	int tm_wday;
	int tm_yday;
	int tm_isdst;
	};
	
/* declarations */
double difftime(time_t, time_t);

#ifdef __cplusplus
}
#endif

#endif