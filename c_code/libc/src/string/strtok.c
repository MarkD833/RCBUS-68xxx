/*
 * strtok() - page 405 - figure 14.20
 * From The Standard C Library by P.J.Plauger (c) 1992
 */
 
#include <string.h>

/* find next token in s1[] delimited by s2[] */
char *strtok(char *s1, const char *s2)
{
	char *sbegin, *send;
	static char *ssave = "";	/* for safety */

	sbegin = s1 ? s1 : ssave;
	sbegin += strspn(sbegin, s2);
	if (*sbegin == '\0')
		{	/* end of scan */
		ssave = "";	/* for safety */
		return (NULL);
		}
	send = sbegin + strcspn(sbegin, s2);
	if (*send != '\0')
		*send++ = '\0';
	ssave = send;
	return (sbegin);
}
