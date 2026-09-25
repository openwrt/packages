#!/bin/sh

[ "$1" = python3-flask-babel ] || exit 0

python3 - <<'EOF'
from flask import Flask
from flask_babel import Babel, gettext, lazy_gettext

app = Flask(__name__)
babel = Babel(app)

with app.app_context():
    result = gettext("Hello")
    assert isinstance(result, str), "gettext should return a string"

lazy = lazy_gettext("World")
assert str(lazy) == "World", f"lazy_gettext failed: {lazy!r}"

print("python3-flask-babel OK")
EOF
