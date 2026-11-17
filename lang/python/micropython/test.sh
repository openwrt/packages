#!/bin/sh

[ "$1" = "micropython-mbedtls" ] || [ "$1" = "micropython-nossl" ] || exit 0

micropython -c "import sys; print(sys.version)" | grep -F "MicroPython v$2"
micropython -c "print('hello from micropython')" | grep -F "hello from micropython"
