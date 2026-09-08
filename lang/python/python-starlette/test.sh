#!/bin/sh

[ "$1" = python3-starlette ] || exit 0

python3 - << 'EOF'

from starlette.applications import Starlette
from starlette.responses import JSONResponse, PlainTextResponse
from starlette.routing import Route

# Render responses (no server or event loop needed) and build an app with a
# route, exercising the response encoders and the router.
assert JSONResponse({"a": 1}).body == b'{"a":1}'
assert PlainTextResponse("hi").body == b"hi"

async def home(request):
    return JSONResponse({"ok": True})

app = Starlette(routes=[Route("/", home)])
assert any(getattr(r, "path", None) == "/" for r in app.routes)

EOF
