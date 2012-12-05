#!/bin/sh

(sed '$d' EdDemo.hex; cat ATmegaBOOT_atmega128rfa1.hex) > combined.hex
