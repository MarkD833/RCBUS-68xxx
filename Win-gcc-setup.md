# Setting up the GNU C Compiler environment

The steps outlined below are my notes on how I set up a Windows 10 (or Windows 11) development environment so I could write C code and compile and run it on my RCBus 68000 hardware.

# What software is required

In order to develop applications, I am currently using the following software:
- GCC68K v13.1.0 - available from: https://tranaptic.ca/gcc-downloads
- Setup batch file - also available from: https://tranaptic.ca/gcc-downloads
- Notepad++ - available from: https://notepad-plus-plus.org/downloads/

I use Notepad++ as my editor but there are plenty of other options out there.

# Setting up
## Step 1 - Install the M68K GCC cross compiler

I downloaded the file `MinGW-m68k-elf-13.1.0.zip` from the Tranaptic website link above.

I then created a folder in the root of my D drive called `gcc68k-13.1.0` and then extracted the contents of the zip file into the `gcc68k-13.1.0` folder making sure to keep the folder structure.

## Step 2 - Configure the setup file

I downloaded the file `setup.bat` from the same Tranaptic website link above and then edited it for my specific needs as I'm only interested in building for the 68000 processor.

My `setup.bat` file then looked like this:
```
@echo off

set GCC_INSTALL_DIR=d:\gcc68k_13.1.0

set GCC_VERSION=13.1.0
set TARGET_VERSION=-%GCC_VERSION%
set LIBDIR_VERSION=%GCC_VERSION%
set LIBDIR_SUFFIX=m68000

set SHTITLE=M68K
set target_gcc=m68k-elf

set LIBCDIR=%GCC_INSTALL_DIR%\%target_gcc%\lib\%LIBDIR_SUFFIX%
set LIBDIR=%GCC_INSTALL_DIR%\lib\gcc\%target_gcc%\%LIBDIR_VERSION%\%LIBDIR_SUFFIX%

PATH=%PATH%;%GCC_INSTALL_DIR%\bin
title GCC(%GCC_VERSION%) - %SHTITLE%
```

## Step 3 - Creating a root folder

I created a separate folder in the root of my D: drive called `gcc68k`. This will be my root development folder. The intention is to do all the development work in subfolders of this folder.

## Step 4 - Copy the repository files

Take the contents of the c_code repository folder and copy the lot into the root development folder which is `D:\gcc68k` for me. This should give you a folder structure similar to this:
```
D:\gcc68k
  +- crt
  +- fdlibm
  +- include
  +- libs
  +- libc
  +- SC611_SPI_Read_Write
  +- SC704_I2C_Read_Write
  +- SC704_I2C_Scan
  +- simple_hello
  +- TMS9918A_ASCII_Chars
  +- TMS9918A_Fern
  +- TMS9918A_Nyan
  +- TMS9918A_Sprite
  +- V9958_Dots
  +- V9958_Lines
  \- V9958_Mbrot
```
It should also give you 2 files in the root development folder. The `rc68000.ld` file describes the memory layout for the linker.

The python script `gcc2easy.py` is something I created and it is called by some of the makefiles when the command `make simlist` is given. It will generate a listing file that should be compatible with the SIM68K program that is supplied as part of the EASy68K suite. This should allow you to step through a C (or C++) program using SIM68K.

# First Use
## Step 1 - Build the C runtime crt0

This simple piece of code is required by all the C programs and is built by simply issuing the `make` command from a CMD prompt within the `crt` folder. This should create the file `crt.o` in the crt folder. 

## Step 2 - Build a simple libc

Having tried several times to build Newlib and failed, I decided to abandon it and create my own libc library. My libc is a cut down version of the standard C library and has a few basic functions present. Most of these are based on the source code provided in the book "The Standard C Library" by P.J.Plauger.
 
The library is built by simply issuing the `make` command from a CMD prompt within the `libc` folder. This should generate the file `libc.a` which should then be copied into the `libs` folder.

## Step 3 - Build a simple libm

The mathematical functions I am using are handled by the maths library FDLIBM (Freely Distributable LIBM) version 5.3.

The library is built by simply issuing the `make` command from a CMD prompt within the `fdlibm` folder. This should generate the file `libm.a` which should then be copied into the `libs` folder.

Note: The compilation process will generate a lot of warnings of the type: "dereferencing type-punned pointer will break strict-aliasing rules". This seems to be due to the way the library code is trying to  manipulate IEEE 754 bit representations.

# All Set!

That's it. You should now have an environment setup to develop C programs for the 68000 directly from the Windows CMD prompt.

Remeber to run the `SETUP.BAT` file each time you open up a CMD prompt so the compiler executables can be found.

# But finally some notes

1. I'm just starting out with cross compiling using GCC so there will likely be some methods that I'm using that are inefficient or just plain wrong!

2. One thing I have discovered is that, for me at least, inline assembly is rather hit and miss and ultimately just a pain in the backside as I chase down obscure error messages. I've found it much easier to have a separate assembler source file and call the routines from the C code.

3. The development environment is Windows so be aware that some Linux commands that are used in makefiles do not exist in Windows or have their Windows equivalents.
