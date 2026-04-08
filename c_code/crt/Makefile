# Simple makefile to try using the GNU C++ cross compiler for M68K
#
CPU=68000

# This is the path to the GNU complier tools
#
GCC_PATH=D:/gcc68k_13.1.0/

# This is the prefix for the suite of GNU compiler tools
#
GCC_PREFIX=bin/m68k-elf-

# These are the tools we might need to use during the build process
#
CXX=$(GCC_PATH)$(GCC_PREFIX)g++.exe
CC=$(GCC_PATH)$(GCC_PREFIX)gcc.exe
AS=$(GCC_PATH)$(GCC_PREFIX)as.exe
LD=$(GCC_PATH)$(GCC_PREFIX)ld.exe
OBJCOPY=$(GCC_PATH)$(GCC_PREFIX)objcopy.exe
OBJDUMP=$(GCC_PATH)$(GCC_PREFIX)objdump.exe
SIZE=$(GCC_PATH)$(GCC_PREFIX)size.exe

CFLAGS += -Wall -Werror -msoft-float -I core -I include
CFLAGS += -march=$(CPU) -fno-common -Os -ffunction-sections -fdata-sections -ffreestanding

# build the crt
crt: crt0.S
	$(CC) $(CFLAGS) -c -o crt0.o crt0.S


