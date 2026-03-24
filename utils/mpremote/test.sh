#!/bin/sh

[ "$1" = mpremote ] || exit 0

python3 - <<'EOF'
import mpremote
from mpremote import main
from mpremote.transport_serial import SerialTransport

print("mpremote OK")
EOF
