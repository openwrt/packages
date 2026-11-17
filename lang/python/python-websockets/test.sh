#!/bin/sh

[ "$1" = python3-websockets ] || exit 0

python3 - << 'EOF'
import websockets
from websockets.version import version
assert version, "websockets version is empty"

from websockets.frames import Frame, Opcode
from websockets.http11 import Request, Response
from websockets.datastructures import Headers

h = Headers([("Content-Type", "text/plain")])
assert h["Content-Type"] == "text/plain", "Headers lookup failed"
EOF
