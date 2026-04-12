#!/bin/sh

[ "$1" = python3-pyusb ] || exit 0

python3 - << 'EOF'
import usb
import usb.core
import usb.util
import usb.control
import usb.backend.libusb1

# version string is a non-empty string
assert isinstance(usb.__version__, str) and len(usb.__version__) > 0,     'bad version: ' + repr(usb.__version__)

# exception classes are proper Exception subclasses
assert issubclass(usb.core.USBError, Exception)
assert issubclass(usb.core.NoBackendError, Exception)

# find() returns an empty list, or raises NoBackendError when no backend is available
try:
    devices = list(usb.core.find(find_all=True))
    assert isinstance(devices, list), 'find() did not return a list'
except usb.core.NoBackendError:
    pass  # acceptable: no USB backend available in test environment

# util.find_descriptor is callable
assert callable(usb.util.find_descriptor)
EOF