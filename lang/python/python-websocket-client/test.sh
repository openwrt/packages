#!/bin/sh

[ "$1" = "python3-websocket-client" ] || exit 0

python3 - << EOF
import sys
import websocket

if websocket.__version__ != "$2":
    print("Wrong version: " + websocket.__version__)
    sys.exit(1)

# Verify core API is importable
from websocket import (
    WebSocket,
    WebSocketApp,
    WebSocketConnectionClosedException,
    WebSocketTimeoutException,
    WebSocketBadStatusException,
    create_connection,
    enableTrace,
)

# WebSocket can be instantiated (without connecting)
ws = WebSocket()
assert ws is not None

# WebSocketApp can be instantiated with just a URL
app = WebSocketApp("ws://localhost:9999")
assert app is not None

# Trace toggle does not raise
enableTrace(False)

sys.exit(0)
EOF
