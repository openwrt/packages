#!/bin/sh

[ "$1" = "python3-pyudev" ] || exit 0

python3 - << EOF
import sys
import pyudev

if pyudev.__version__ != "$2":
    print("Wrong version: " + pyudev.__version__)
    sys.exit(1)

# Verify key classes are importable
from pyudev import Context, Device, Devices, Enumerator, Monitor
from pyudev import DeviceNotFoundAtPathError, DeviceNotFoundByNameError

# Create a Context (requires libudev to be available)
ctx = Context()

# Enumerate devices - libudev-zero may return an empty list, just verify no crash
enumerator = ctx.list_devices()
assert isinstance(enumerator, Enumerator)
list(enumerator)  # consume iterator

sys.exit(0)
EOF
