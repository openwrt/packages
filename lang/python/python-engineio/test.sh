#!/bin/sh

[ "$1" = "python3-engineio" ] || exit 0

python3 - << EOF
import sys

# Verify key classes are importable
from engineio import Server, AsyncServer, WSGIApp, ASGIApp

# AsyncServer with asgi mode needs no external dependencies
asrv = AsyncServer(async_mode='asgi')
assert asrv is not None

received = []

@asrv.on("connect")
async def on_connect(sid, environ):
    received.append(("connect", sid))

@asrv.on("disconnect")
async def on_disconnect(sid):
    received.append(("disconnect", sid))

# ASGI app wrapper
aapp = ASGIApp(asrv)
assert aapp is not None

sys.exit(0)
EOF
