#!/bin/sh

(sed '$d' Pinoccio-usbserial.hex; cat Pinoccio-usbdfu.hex) > Pinoccio-Combined.hex
