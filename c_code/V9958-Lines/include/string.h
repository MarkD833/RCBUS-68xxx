/*
 * string.h standard header - page 398 - figure 14.1
 * From The Standard C Library by P.J.Plauger (c) 1992
 */
 
#ifndef _STRING
#define _STRING

#ifndef _STDLIB
#include <stdlib.h>
#endif

		/* macros */
#define NULL	_NULL
		/* type definitions */
#ifndef _SIZET
#define _SIZET
typedef _Sizet size_t;
#endif

#ifdef __cplusplus
extern "C" {
#endif
		/* declarations */
void *memchr(const void *, int, size_t);
int memcmp(const void *, const void *, size_t);
void *memcpy(void *, const void *, size_t);
void *memmove(void *, const void *, size_t);
void *memset(void *, int, size_t);
char *strcat(char *, const char *);
char *strchr(const char *, int);
int strcmp(const char *, const char *);
int strcoll(const char *, const char *);
char *strcpy(char *, const char *);
size_t strcspn(const char *, const char *);
size_t strlen(const char *);
char *strncat(char *, const char *, size_t);
int strncmp(const char *, const char *, size_t);
char *strncpy(char *, const char *, size_t);
char *strpbrk(const char *, const char *);
char *strrchr(const char *, int);
size_t strspn(const char *, const char *);
char *strstr(const char *, const char *);
char *strtok(char *, const char *);
char *_Strerror(int, char *);

/* non-standard functions */
void strrev(char *str);

		/* macro overrides */
#define strerror(errcode)	_Strerror(errcode, _NULL)

#ifdef __cplusplus
}
#endif

#endif
