pinoccio-firmware
=================

Firmware files, including bootloaders and app hex files for the ATmega16U2 and the ATmega128RFA1 MCUs

As of 8/25/2013, you *MUST* create your own toolchain (avr-gcc, avrdude, etc.) because the Atmega256RFR2 is a fairly new chip and Arduino binaries of these are from 2011 era.
install-avr-gcc.sh will help you in grabbing and building the newest avr-gcc, avrdude, etc.
