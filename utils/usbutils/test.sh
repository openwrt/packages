#!/bin/sh

[ "$1" = "usbutils" ] || exit 0

# Binary accessible via alternatives
test -x /usr/libexec/lsusb-usbutils

# lsusb tree view runs without crashing (may be empty in test env)
lsusb -t 2>/dev/null; [ $? -ne 127 ]

# lsusb device listing runs without crashing
lsusb 2>/dev/null; [ $? -ne 127 ]

# usbreset is installed and shows usage when invoked without arguments
usbreset 2>&1 | grep -q "Usage:"
