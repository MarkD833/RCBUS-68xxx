/*
 * stdlib.h standard header - page 354 - figure 13.3
 * From The Standard C Library by P.J.Plauger (c) 1992
 */
 /*
  * Removed:
  * abort(), atexit(), calloc(), exit(), free(), malloc()
  * mblen(), mbstowcs(), mbtowc(), realloc(), system()
  * wcstombs(), wctomb()
  * _Mbtowc(), _Wctomb()
  */

#ifndef _STDLIB
#define _STDLIB
/*
#ifndef _YVALS
#include <yvals.h>
#endif
*/

#define _NULL	0


/* macros */
#define NULL		_NULL
#define EXIT_FAILURE	_EXFAIL
#define EXIT_SUCCESS	0
#define RAND_MAX	32767

/* type definitions */
typedef unsigned int _Sizet;

#ifndef _SIZET
#define _SIZET
typedef _Sizet size_t;
#endif

typedef struct {
	int quot;
	int rem;
	} div_t;
typedef struct {
	long quot;
	long rem;
	} ldiv_t;
typedef int _Cmpfun(const void *, const void *);

#ifdef __cplusplus
extern "C" {
#endif

/* declarations */
int abs(int);
double atof(const char *);
int atoi(const char *);
long atol(const char *);
void *bsearch(const void *, const void *,
	size_t, size_t, _Cmpfun *);
div_t div(int, int);
long labs(long);
ldiv_t ldiv(long, long);
void qsort(void *, size_t, size_t, _Cmpfun *);
int rand(void);
void srand(unsigned int);
double strtod(const char *, char **);
long strtol(const char *, char **, int);
unsigned long strtoul(const char *, char **, int);
double _Stod(const char *, char **);
unsigned long _Stoul(const char *, char **, int);

extern unsigned long _Randseed;

/* macro overrides */
/*
#define atof(s)		_Stod(s, 0)
#define atoi(s)		(int)_Stoul(s, 0, 10)
#define atol(s)		(long)_Stoul(s, 0, 10)
#define srand(seed)	(void)(_Randseed = (seed))
#define strtod(s, endptr)	_Stod(s, endptr)
#define strtoul(s, endptr, base)	_Stoul(s, endptr, base)
*/
#ifdef __cplusplus
}
#endif

#endif
