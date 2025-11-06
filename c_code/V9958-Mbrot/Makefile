# Simple makefile to try using the GNU C++ cross compiler for M68K
#
CPU=68000

# Start address - gets inserted as the 1st line of the listing file for EASy68K
# 
START_ADDR=00100400

# Destination folder for the files for EASy68K
#
EASY_FOLDER=/media/ssd2/VirtualMachines/Tiny10_Shared

# This is the path to the GNU complier tools
#
GCC_PATH=$(HOME)/opt/cross/

# This is the prefix for the suite of GNU compiler tools
#
GCC_PREFIX=bin/m68k-elf-

# These are the tools we might need to use during the build process
#
CXX=$(GCC_PATH)$(GCC_PREFIX)g++
CC=$(GCC_PATH)$(GCC_PREFIX)gcc
AS=$(GCC_PATH)$(GCC_PREFIX)as
LD=$(GCC_PATH)$(GCC_PREFIX)ld
OBJCOPY=$(GCC_PATH)$(GCC_PREFIX)objcopy
OBJDUMP=$(GCC_PATH)$(GCC_PREFIX)objdump
SIZE=$(GCC_PATH)$(GCC_PREFIX)size
RM=rm

TARGET ?= a.out
BUILD_DIR ?= ./build
SRC_DIRS ?= .

# SRCS will be a list of all C, C++ or asm files in the directory
SRCS := $(shell find $(SRC_DIRS) -name '*.cpp' -or -name '*.c' -or -name '*.s' -or -name '*.S')
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

INC_DIRS := $(shell find $(SRC_DIRS) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

CPPFLAGS += -Wall -Werror -msoft-float -I core -I include
CPPFLAGS += -march=$(CPU) -fno-common -Os -ffunction-sections -fdata-sections -ffreestanding

# LDFLAGS += -T m68k.ld -L /usr/lib/gcc-cross/m68k-linux-gnu/14/include/ -l gcc
LDFLAGS += -T m68k.ld -L $(GCC_PATH)lib/gcc/m68k-elf/15.2.0/m68000 -l gcc -L . -l:libcm68k.a

ASFLAGS += -mcpu=$(CPU)

# Linking
$(BUILD_DIR)/$(TARGET): $(OBJS)
	$(LD) $(OBJS) -o $@ $(LDFLAGS)
	$(OBJCOPY) -I elf32-m68k -O srec $(BUILD_DIR)/a.out prog.s68
	$(SIZE) -G $(BUILD_DIR)/a.out
#	cp prog.s68 ~/ssd2/VirtualMachines/Tiny10_Shared

# assembly using GNU AS
$(BUILD_DIR)/%.s.o: %.s
	$(MKDIR_P) $(dir $@)
	$(AS) $(ASFLAGS) -c $< -o $@

# assembly using GNU GCC
$(BUILD_DIR)/%.S.o: %.S
	$(MKDIR_P) $(dir $@)
	$(CC) -march=$(CPU) -c $< -o $@

# compiling C source
$(BUILD_DIR)/%.c.o: %.c
	$(MKDIR_P) $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# compiling C++ source
$(BUILD_DIR)/%.cpp.o: %.cpp
	$(MKDIR_P) $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

.PHONY: clean

clean:
	$(RM) -rf $(BUILD_DIR)

# build the crt
crt: ../crt/crt0.S
	$(CC) $(CFLAGS) -c -o ../crt/crt0.o ../crt/crt0.S
	rm -f crt0.d

-include $(DEPS)

dump:
	$(OBJDUMP) -mm68k:$(CPU) -belf32-m68k -dt -h -j.text $(BUILD_DIR)/a.out
	$(OBJDUMP) -mm68k:$(CPU) -belf32-m68k -st -h -j.rodata -j.data -j.bss $(BUILD_DIR)/a.out

dumps:
	$(OBJDUMP) -mm68k:$(CPU) -belf32-m68k -St -j.text $(BUILD_DIR)/a.out
	$(OBJDUMP) -mm68k:$(CPU) -belf32-m68k -st -j.rodata -j.data -j.bss $(BUILD_DIR)/a.out

dumpn:
	$(OBJDUMP) -mm68k:$(CPU) -belf32-m68k -h -s $(BUILD_DIR)/a.out

# This creates an assemler listing file and then tweaks it using SED so that
# SIM68K will step through it when running the code through the simulator
simlist:
	$(OBJDUMP) -mm68k:$(CPU) -belf32-m68k -dt -j.text $(BUILD_DIR)/a.out >prog.l68
	sed -i 's#^  \([0-9]\)#00\1#' prog.l68
	sed -i 's#^\t\.\.\.##' prog.l68
	sed -i '1i$(START_ADDR)  Starting Address' prog.l68
	cp prog.l68 $(EASY_FOLDER)
	cp prog.s68 $(EASY_FOLDER)


MKDIR_P ?= mkdir -p

