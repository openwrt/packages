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

# udev_version() returns an integer
from pyudev._util import udev_version
ver = udev_version(ctx)
assert isinstance(ver, int), f"Expected int udev version, got {type(ver)}"
assert ver > 0, f"Expected positive udev version, got {ver}"

# Enumerate devices - at least one subsystem must exist
enumerator = ctx.list_devices()
assert isinstance(enumerator, Enumerator)

# Enumerate devices in a common subsystem
devices = list(ctx.list_devices(subsystem="net"))
# At least loopback should be present
assert len(devices) > 0, "Expected at least one net device"

sys.exit(0)
EOF
