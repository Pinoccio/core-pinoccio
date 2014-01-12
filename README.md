pinoccio-firmware
=================

Firmware files, including bootloaders and app hex files for the ATmega16U2 and the Atmega256RFR2 MCUs

As of 8/25/2013, you *MUST* create your own toolchain (avr-gcc, avrdude, etc.) because the Atmega256RFR2 is a fairly new chip and Arduino binaries of these are from 2011 era.

--------
OPTION 1
--------

Download the pre-configured Pinoccio VM.  This is a 3.4GB torrent containing a VM template that
can be imported into either Virtualbox or VMWare Workstation/Fusion.

Magnet URI (current version is 0.9): 

magnet:?xt=urn:btih:3A291BD6C4EC6C720B73D0625285692DF7F030A7

See "Compiling sketches" later in this README for compiling sketches in the Arduino IDE

--------
OPTION 2
--------

Build the toolchain according to the instructions below:


install-avr-gcc.sh (for OS X) will help you in grabbing and building the newest avr-gcc, avrdude, etc.
install-avr-gcc-linux.sh has been tested on debian 6.x 'squeeze' and should also work on the current stable 7.x 'wheezy' (but also read below for ready-made Debian packages)

There are a few pieces to the puzzle that need to fit together to make it all play nicely..

1) Install Arduino 1.5.4 beta
2) Get a recent and patched toolchain (see below)

3) Replace Arduino IDE's avr-gcc and avrdude components with symlinks to the ones installed by the install script in #2:

    arduino-1.5.4/hardware/tools/avrdude --> PREFIX/bin/avrdude
    arduino-1.5.4/hardware/tools/avrdude.conf --> PREFIX/etc/avrdude.conf
    arduino-1.5.4/hardware/tools/avr/bin/ --> PREFIX/bin/

    If avr-gcc is available in your system $PATH, you can just remove the avr/bin directory entirely and the IDE will find avr-gcc automatically (this does not work for avrdude yet).

4) Link the hardware folder from the pinoccio-firmware repo into the Arduino IDE:

    arduino-1.5.4/hardware/pinoccio/ -> pinoccio-firmware/hardware/pinoccio/

5) Install Pinoccio support into the arduino IDE.  'git clone https://github.com/Pinoccio/pinoccio-arduino-library.git' somewhere convenient (inside your home tree is good).  You can then create a symlink to it in your arduino user libraries folder which should be ~/Arduino/libraries (IDE creates this automagically and puts a readme in it):

    ~/Arduino/libraries/Pinoccio/ -> pinoccio-arduino-library

   This step is optional if you just want to run a minimal sketch on the Pinoccio, but it adds support for various peripherals.

---------
Toolchain
---------

For using the atmega256rfr2 target, recent and/or patched versions of
the avr toolchain are needed. In particular:

 - Avrdude 6.0 or above
 - avr-libc trunk (which [contains support for 256rfr2][1])
 - gcc-avr 4.7.3 with patches
 - binutils 2.23.2 with patches

[1]: http://svn.savannah.nongnu.org/viewvc?view=rev&root=avr-libc&revision=2308

The needed patches are in the "patches" subdirectory of this repository.
Building the needed toolchain bits can be done automatically using the
shell scripts (tested on Linux and OSX) in this repository.

When using /usr/local/avr as the PREFIX install dir (default) the
pinoccio-arduino-library repo has some symlinks in it to the OS X
default install location in /Applications.  So it may make your life
easier if you replace the linux script's prefix with the one from the
other script (for OS X).  Otherwise, redirect the symlinks manually
(they're in pinoccio-arduino-library/examples/Shell/Default/build/core).

---------------
Debian / Ubuntu
---------------

If you're on Debian or Ubuntu, you can just grab read-made debs:
 - Avrdude 6.0 is available from Debian jessie
 - bin-utils 2.23.1-1 is available from Debian jessie and includes the
   needed patches
 - avr-libc is [available from here](http://apt.stderr.nl/pool/main/a/avr-libc/).
 - gcc-avr is [available from here](http://apt.stderr.nl/pool/main/g/gcc-avr/).



------------------
Compiling Sketches
------------------

You should then be able to open one of the Pinoccio examples using Open->libraries->Pinoccio->[example] and compile it.  Make sure your Board is set to Pinoccio and the Port is set to your serial port.

You need to `#include <SPI.h>` and `#include <Wire.h>` at the top of your sketch, since the Arduino IDE does not support libraries depending on other libraries yet.


