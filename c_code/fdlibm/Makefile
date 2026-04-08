# Simple makefile for my 68000 board to create a sort-of libc based on the
# source code in the book The Standard C Library by P.J.Plauger (c) 1992

CPU=68000

# This is the path to the GNU complier tools
#
GCC_PATH=D:/gcc68k_13.1.0/

# This is the prefix for the suite of GNU compiler tools
#
GCC_PREFIX=bin/m68k-elf-

# These are the tools we might need to use during the build process
#
CC=$(GCC_PATH)$(GCC_PREFIX)gcc.exe
AS=$(GCC_PATH)$(GCC_PREFIX)as.exe
AR=$(GCC_PATH)$(GCC_PREFIX)ar.exe
SIZE=$(GCC_PATH)$(GCC_PREFIX)size.exe

# Removed -Werror as "dereferencing type-punned pointer will break strict-aliasing rules"
# will generate an error when trying to manipulate IEEE 754 bit representations.
CFLAGS += -Wall -I include
CFLAGS += -mcpu=$(CPU) -D_IEEE_LIBM -fno-common -Os -ffunction-sections -fdata-sections -ffreestanding

ASFLAGS += -mcpu=$(CPU) -I include

# Name of the output library we are creating
LIB_NAME = libm.a

# SRC_DIR is the root folder where the various subfolder are found
SRC_DIR = src

# BUILD_DIR is where the object files will go
BUILD_DIR = build

# SRCS will be a list of all C files in the SRC_DIR
SRCS = $(wildcard $(SRC_DIR)/*.c)

# Create the object filenames
OBJS = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.c.o, $(SRCS))

#
# Default IEEE libm
#
CFLAGS += -D_IEEE_LIBM

# Default target
all: $(LIB_NAME)

# Rule to create the library	
$(LIB_NAME): $(OBJS)
	$(AR) r $@ $(OBJS)

# Rule to assemble using GNU AS - assembler file with LOWERCASE .s extension
$(BUILD_DIR)/%.s.o: $(SRC_DIR)/%.s
	@if not exist "$(dir $@)" mkdir "$(subst /,\,$(dir $@))"
	$(info assemble using AS)
	$(AS) $(ASFLAGS) -c $< -o $@

# Rule to assemble using GNU GCC - assembler file with UPPERCASE .S extension
$(BUILD_DIR)/%.S.o: $(SRC_DIR)/%.S
	@if not exist "$(dir $@)" mkdir "$(subst /,\,$(dir $@))"
	$(info assemble using GCC)
	$(CC) $(CFLAGS) -c $< -o $@

# Rule to compile C source files
$(BUILD_DIR)/%.c.o: $(SRC_DIR)/%.c
	@if not exist "$(dir $@)" mkdir "$(subst /,\,$(dir $@))"
	$(CC) $(CFLAGS) -c $< -o $@

# Clean up build artifacts using Windows CMD commands
clean:
	@if exist $(BUILD_DIR) rd /s /q $(BUILD_DIR)
	@if exist $(LIB_NAME) del /q $(LIB_NAME)

.PHONY: all clean
