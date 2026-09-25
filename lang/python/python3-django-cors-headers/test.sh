#!/bin/sh

[ "$1" = python3-django-cors-headers ] || exit 0

python3 - << 'EOF'
import corsheaders
from corsheaders.middleware import CorsMiddleware
from corsheaders.conf import conf

assert CorsMiddleware is not None
assert conf is not None

print("python3-django-cors-headers OK")
EOF
