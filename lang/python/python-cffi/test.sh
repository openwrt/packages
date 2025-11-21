#!/bin/sh

[ "$1" = python3-cffi ] || exit 0

python3 - << EOF
from cffi import FFI
ffibuilder = FFI()
EOF
