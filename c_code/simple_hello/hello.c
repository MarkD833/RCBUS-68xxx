/*

  Example of compiling C code for 68000. Doesn't require any C library
  or other run-time code except libgcc.
  
  Based on: https://jefftranter.blogspot.com/2017/05/building-68000-single-board-computer-c.html

*/


// Forward references so we can put main() first at a known start
// address.
void printString(const char *s);
void printNumber(unsigned int n);

// Main program.
int main()
{
    printString("\r\nHello\r\n");
    return 0;
}

// Print a character using TRAP #15
void outch(char c) {
    asm(
        "move.b #6,%%d0\n\t"
        "move.b %0,%%d1\n\t"
        "trap #15\n\t"
    : /* outputs */
    : "r" (c) /* inputs */
    : "d0", "d1" /* clobbered regs */
    );
}


// Print a string.
void printString(const char *s) {
    while (*s != 0) {
        outch(*s);
        s++;
    }
}

// Quick and dirty routine to print decimal number up to 10 digits
// long. Suppresses leading zeros.
void printNumber(unsigned int n) {
    unsigned int d;
    short digitPrinted = 0;
    unsigned int mult = 1000000000;

    while (mult > 1) {
        d = n / mult;
        if (d == 0) {
            if (digitPrinted) {
                outch(d + '0');
            }
        } else {
            outch(d + '0');
            digitPrinted = 1;
        }
        n = n - d * mult;
        mult = mult / 10;
    }
    outch(n + '0');
}
