/*
 * errno.h standard header - page 53 - figure 3.1
 * From The Standard C Library by P.J.Plauger (c) 1992
 */

#ifndef _ERRNO
#define _ERRNO

#ifndef _YVALS
#include <yvals.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

		/* error codes */
#define EDOM	_EDOM
#define ERANGE	_ERANGE
#define EFPOS	_EFPOS
	/* ADD YOURS HERE */
#define _NERR	_ERRMAX	/* one more than last code */
		/* declarations */
extern int errno;

#ifdef __cplusplus
}
#endif

#endif
