pinoccio-firmware
=================

Firmware files, including bootloaders and app hex files for the ATmega16U2 and the Atmega256RFR2 MCUs

As of 8/25/2013, you *MUST* create your own toolchain (avr-gcc, avrdude, etc.) because the Atmega256RFR2 is a fairly new chip and Arduino binaries of these are from 2011 era.

install-avr-gcc.sh (for OS X) will help you in grabbing and building the newest avr-gcc, avrdude, etc.
install-avr-gcc-linux.sh has been tested on debian 6.x 'squeeze' and should also work on the current stable 7.x 'wheezy'

--

There are a few pieces to the puzzle that need to fit together to make it all play nicely..

1) Install Arduino 1.5.4 beta
2) Run this repo's install script to compile and install the avr toolchain (your OS needs gcc, make, binutils etc).

When using /usr/local/avr as the PREFIX install dir (default) the pinoccio-arduino-library repo has some symlinks in it to the OS X default install location in /Applications.  So it may make your life easier if you replace the linux script's prefix with the one from the other script (for OS X).  Otherwise, redirect the symlinks manually (they're in pinoccio-arduino-library/examples/Shell/Default/build/core).

3) Replace Arduino IDE's avr-gcc and avrdude components with symlinks to the ones installed by the install script in #2:

    arduino-1.5.4/hardware/tools/avr/bin/avrdude --> PREFIX/bin/avrdude
    arduino-1.5.4/hardware/tools/avr/bin/avrdude.conf --> PREFIX/etc/avrdude.conf
    arduino-1.5.4/hardware/tools/avr/bin/avr/bin/ --> PREFIX/bin/

4) Install Pinoccio support into the arduino IDE.  'git clone https://github.com/Pinoccio/pinoccio-arduino-library.git' somewhere convenient (inside your home tree is good).  You can then create a symlink to it in your arduino user libraries folder which should be ~/Arduino/libraries (IDE creates this automagically and puts a readme in it):

    ~/Arduino/libraries/Pinoccio/ -> pinoccio-arduino-library

5) Link the hardware library from the pinoccio-firmware repo into the Arduino IDE:

    arduino-1.5.4/hardware/pinoccio/ -> pinoccio-firmware/hardware/pinoccio/

6) Download the stable release of arduino 1.0.5 and copy the libraries/SPI and libraries/Wire directories into the corresponding location of 1.5.4.  For some reason those libraries disappear in the new version of arduino??

You should then be able to open one of the Pinoccio examples using Open->libraries->Pinoccio->[example] and compile it.  Make sure your Board is set to Pinoccio and the Port is set to your serial port.

You may still need to "#include <SPI.h>" and "#include <Wire.h>" at the top of your sketch.  Not sure why the underlying header files (via Scout.h) can't include them...

