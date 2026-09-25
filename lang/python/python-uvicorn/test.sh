#!/bin/sh

[ "$1" = python3-uvicorn ] || exit 0

python3 - << 'EOF'

import uvicorn

# Config.load() imports and wires the HTTP/WS protocol backends (h11, etc.)
# for a trivial ASGI app - a real functional check that never binds a port.
async def app(scope, receive, send):
    pass

cfg = uvicorn.Config(app, host="127.0.0.1", port=8000, log_level="warning", loop="asyncio")
cfg.load()
assert cfg.loaded is True
assert uvicorn.Server(cfg).config is cfg

EOF
