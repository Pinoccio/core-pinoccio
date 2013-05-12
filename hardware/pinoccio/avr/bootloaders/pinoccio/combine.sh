#!/bin/sh

(sed '$d' EdDemo.hex; cat ATmegaBOOT_atmega128rfa1.hex) > combined.hex

echo "Install combined hex with the following avrdude command:"
echo "avrdude -p m128rfa1 -P usb -c avrisp2 -U flash:w:ATmegaBOOT_atmega128rfa1.hex:m -U lfuse:w:0xF7:m -U hfuse:w:0xDA:m -U efuse:w:0xF0:m"
