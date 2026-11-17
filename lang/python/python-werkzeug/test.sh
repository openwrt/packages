#!/bin/sh

[ "$1" = python3-werkzeug ] || exit 0

python3 - <<'EOF'
from werkzeug.test import Client
from werkzeug.wrappers import Request, Response

def app(environ, start_response):
    request = Request(environ)
    text = f"Hello, {request.args.get('name', 'world')}!"
    response = Response(text, mimetype='text/plain')
    return response(environ, start_response)

client = Client(app)

resp = client.get('/')
assert resp.status_code == 200
assert resp.data == b'Hello, world!'

resp = client.get('/?name=OpenWrt')
assert resp.status_code == 200
assert resp.data == b'Hello, OpenWrt!'
EOF
