#!/bin/sh

[ "$1" = mpremote ] || exit 0

python3 - "$2" <<'EOF'
import sys
import mpremote
from mpremote import main
from mpremote.transport_serial import SerialTransport
import importlib.metadata

version = sys.argv[1]
installed = importlib.metadata.version("mpremote")
assert installed == version, f"version mismatch: {installed!r} != {version!r}"
print(f"mpremote {installed} OK")
EOF
