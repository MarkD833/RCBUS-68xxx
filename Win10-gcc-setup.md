# Setting up the GNU C Compiler environment

The steps outlined below are my notes on how I set up a Windows 10 development environment so I could write C code and compile and run it on my RCBus 68000 hardware.

# What software is required

In order to develop applications, I am currently using the following software:
- MSYS2 available from: https://www.msys2.org/
- GCC68K v13.1.0 available from: https://tranaptic.ca/gcc-downloads
- Tom Storey’s M68K bare metal suite available from: https://github.com/tomstorey/m68k_bare_metal

# Setting up
## Step 1 - Install MSYS2

Download the latest version of MSYS2. The file I downloaded was called `msys2-x86_64-20250221.exe`

Run the installer and select the installation location. In my case I chose `D:\msys64`. 

Next, check for and install any updates. In the install folder, run mingw64.exe and when the MSYS shell appears, type the following:
```
Pacman –Syu
```

Accept the proposed updates and when finished, the shell window will close. Repeat this step again until all packages are up to date.

## Step 2 - Install an M68K GCC cross compiler

I downloaded the file `MinGW-m68k-elf-13.1.0.zip` from the Tranaptic website link above.

Using Windows Explorer, navigate to your MSYS2 installation folder and then to the folder called `home`. Inside that folder there will be another folder that is the name of the current Windows 10 user. Within that folder, create a new folder called `gcc68k`.

Extract the contents of the zip file into the `gcc68k` folder making sure to keep the folder structure.

## Step 3 - Update the shell path

In order to find the GCC cross compiler executables, the shell path needs updating.

In the `home` folder, there is a file called `.bash_profile`. Open this file using Windows notepad and navigate to the end of the file and add a new entry to the shell path by typing in the following lines:

```
# Set PATH so it includes the gcc68k bin directory if it exists
if [ -d "${HOME}/gcc68k/bin" ] ; then
  PATH="${HOME}/gcc68k/bin:${PATH}"
fi
```

Save and close the file.

To check that the path has been updated, run mingw64.exe and when the MSYS shell appears, type the following:

```
echo $PATH
```

My setup reports back:

>/home/Mark/gcc68k/bin:/mingw64/bin:/usr/local/bin:/usr/bin:/bin:/c/Windows/System32:/c/Windows:/c/Windows/System32/Wbem:/c/Windows/System32/WindowsPowerShell/v1.0/:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl

Next, check that the GCC binaries can be found by typing:

```
m68k-elf-gcc –version
```
If successful, you should see something similar to this displayed:

```
m68k-elf-gcc.exe (Tranaptic-2023/06/16-13:17:25) 13.1.0
Copyright (C) 2023 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

## Step 4 - Installing the M68K bare metal suite

I downloaded a zip file of the complete M68K bare metal suite from Tom’s github page (see link above).

Using Windows Explorer, navigate to your `MSYS2` installation folder and then to the folder called `home`. Extract the contents of the bare metal zip file into the home folder making sure to keep the folder structure.

There should now be a folder called `m68k_bare_metal-master` which I renamed to `m68k_bare_metal` using Windows Explorer.

## Step 5 - Building libmetal

Building libmetal is as described in the readme.md but first I had to change the value of PREFIX in the makefile in the libmetal folder to match the M68K GCC cross compiler suite.

I changed the value of PREFIX so it read:
```
PREFIX=m68k-elf
```

To build libmetal, run mingw64.exe and when the MSYS shell appears, navigate to the libmetal folder by typing the following:
```
cd m68k_bare_metal/libmetal/
```
That should place you in the libmetal folder.

Start the libmetal build by simply typing:
```
make
```
I got some warnings about #pragma mark being unsupported and ‘nonnull’ arguments being compared to NULL.

I also got warnings in malloc.c about array subscripts being partly outside array bounds which I need to understand in case it’s an issue.

Once the build process completed, I had a file called `libmetal-68000.a`.

# Building the test application

In my scenario, I am using the application template rather than the standalone template. The build process is as described in the readme.md file but simply:

- Make a copy the application folder (or standalone folder)
- Modify the makefile
- Assemble crt0
- Make your project

The steps for me for a new project were carried out in the MSYS shell and my project was called test01. Firstly, make a copy of the existing `application` folder and call it test01 like this:
```
cp -a application test01
```
Then I edited the makefile to change the value of PREFIX as was done in building libmetal so that it read:
```
PREFIX=m68k-elf
```
Then I continued with the build with the 2 commands as follows:
```
make crt
make
```
If successful, that should produce a file called `bmbinary` and give you the confidence that the process is working.

The final step is then to create the S-record file with the command:
```
make rom
```

# Configuring for the RCBus-68000 Board

The linker scripts I am using are in the folders for the example C code along with the crt0.s file I am using and the relevant makefiles.

I'm just starting out with cross compiling using GCC so there will likely be some methods that I'm using that are inefficient or just plain wrong!

# Thoughts

One thing I have discovered is that, for me at least, inline assembly is rather hit and miss and ultimately just a pain in the backside as I chase down obscure error messages. I've found it much easier to have a separate assembler source file and call the routines from the C code.

I'd like to figure out a way of not duplicating the storage space for variables. Initialised variables, such as uint8_t x = 1 are normally stored in non volatile memory, usually FLASH or EPROM, (I think a section of memory the linker calls RODATA) and then copied into RAM (to the section of memory the linker calls BSS) as part of the initialisaion code in crt0.  

As the code is loaded into RAM from the serial port, I wonder if there is a way to put the initialised variables directly into the BSS section from the get-go or maybe leave them in the RODATA section and use them directly from there.
