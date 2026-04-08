/* ispunct function */
/* test for punctuation character */

#include <ctype.h>

int ispunct(int c)
{
    return isgraph(c) && !isalnum(c);
}
