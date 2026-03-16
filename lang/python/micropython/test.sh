#!/bin/sh

nl="
"

micropython -c "import sys${nl}print(sys.version)" | grep -F " MicroPython v${PKG_VERSION} "
