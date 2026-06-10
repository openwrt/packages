#!/bin/sh

[ "$1" = python3-tornado ] || exit 0

python3 - << 'EOF'
import tornado
assert tornado.version, "tornado version is empty"

from tornado.web import Application, RequestHandler
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop

class TestHandler(RequestHandler):
    def get(self):
        self.write("ok")

app = Application([(r"/", TestHandler)])
assert app is not None, "failed to create tornado Application"
EOF
