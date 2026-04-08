# Simple makefile for my RCBus 68000 board
# Uses GCC68K v13.1.0 via MSYS2
#
CPU=68000

# Start address - gets inserted as the 1st line of the listing file for EASy68K
# This should be the start address of RAM as defined in the linker script.
# There will be a way to pass this to the linker rather than define it in 2 places!
#
START_ADDR=00100400

# This is the path to the GNU complier tools
#
GCC_PATH=D:/gcc68k_13.1.0/

# This is the prefix for the suite of GNU compiler tools
#
GCC_PREFIX=bin/m68k-elf-

# This is where our own libraries can be found
#
LIB_PATH=../libs

# This is where include file headers are found
#
INC_PATH=../include

# These are the tools we might need to use during the build process
#
CXX=$(GCC_PATH)$(GCC_PREFIX)g++.exe
CC=$(GCC_PATH)$(GCC_PREFIX)gcc.exe
AS=$(GCC_PATH)$(GCC_PREFIX)as.exe
LD=$(GCC_PATH)$(GCC_PREFIX)ld.exe
OBJCOPY=$(GCC_PATH)$(GCC_PREFIX)objcopy.exe
OBJDUMP=$(GCC_PATH)$(GCC_PREFIX)objdump.exe
SIZE=$(GCC_PATH)$(GCC_PREFIX)size.exe
RM=rm

TARGET ?= a.out
BUILD_DIR ?= ./build
SRC_DIRS ?= .

# SRCS will be a list of all C, C++ or asm files in the directory
SRCS := $(wildcard *.cpp *.c *.s *.S)
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

# DEBUG: Print out the list of source files used
$(info Source Files: $(SRCS))

CPPFLAGS += -g -Wall -Werror -msoft-float -I $(INC_PATH)
CPPFLAGS += -march=$(CPU) -fno-common -Os -ffunction-sections -fdata-sections -ffreestanding

# The order of the libs matters here: my libc requires functions in libgcc so must come before libgcc
LDFLAGS += -T ../rc68000.ld -L $(GCC_PATH)lib/gcc/m68k-elf/13.1.0/m68000 -L $(LIB_PATH) -l:libm.a -l:libc.a -l:libgcc.a

ASFLAGS += -mcpu=$(CPU)

# Linking
$(BUILD_DIR)/$(TARGET): $(OBJS)
	$(LD) $(OBJS) -o $@ $(LDFLAGS)
	$(OBJCOPY) -I elf32-m68k -O srec $(BUILD_DIR)/a.out program.s68
	$(SIZE) -G $(BUILD_DIR)/a.out

# assembly using GNU AS
$(BUILD_DIR)/%.s.o: %.s
	@if not exist "$(dir $@)" mkdir "$(subst /,\,$(dir $@))"
	$(AS) $(ASFLAGS) -c $< -o $@

# assembly using GNU GCC
$(BUILD_DIR)/%.S.o: %.S
	@if not exist "$(dir $@)" mkdir "$(subst /,\,$(dir $@))"
	$(CC) -march=$(CPU) -c $< -o $@

# compiling C source
$(BUILD_DIR)/%.c.o: %.c
	@if not exist "$(dir $@)" mkdir "$(subst /,\,$(dir $@))"
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# compiling C++ source
$(BUILD_DIR)/%.cpp.o: %.cpp
	@if not exist "$(dir $@)" mkdir "$(subst /,\,$(dir $@))"
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

.PHONY: clean

clean:
	del /Q build
	del /Q program.s68 program.l68
	
# This creates an assemler listing file and then tweaks it using a simple python script
# so that SIM68K will step through it when running the code through the simulator
simlist:
	$(OBJDUMP) -mm68k:$(CPU) -belf32-m68k -dt -j.text $(BUILD_DIR)/a.out >program.lst
	python ../gcc2easy.py program.lst $(START_ADDR)
	del program.lst

