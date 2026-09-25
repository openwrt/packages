#!/bin/sh

[ "$1" = python3-cffi ] || exit 0

# cffi's cffi-gen-src CLI has no version flag, so assert the version here and
# build an FFI object to exercise the compiled C extension.
python3 - "$2" << 'EOF'
import sys
import cffi
from cffi import FFI

assert cffi.__version__ == sys.argv[1], (cffi.__version__, sys.argv[1])
ffibuilder = FFI()
EOF
