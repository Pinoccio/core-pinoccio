This is the current bootloader for Pinoccio boards using the ATMega256RFR2 chip.  It includes uracoli for over-the-air (OTA) firmware updates.

integrate uracoli into bootloader:
 (1) fetch uracoli-src package http://uracoli.nongnu.org/download.html
 (2) extract to folder "uracoli-src"
 (3) build for board pinoccio: uracoli-src> make -C src pinccio
 (4) Atmel Studio Project references to libs in folder /lib and /inc

