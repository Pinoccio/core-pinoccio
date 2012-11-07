#!/bin/sh

(sed '$d' Pinoccio-usbserial-4.7.2.hex; cat Pinoccio-usbdfu-4.7.2.hex) > Pinoccio-Combined-4.7.2.hex
