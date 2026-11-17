#!/bin/sh

[ "$1" = python3-installer ] || exit 0

python3 - << 'EOF'
from installer import install
from installer.sources import WheelFile
from installer.destinations import SchemeDictionaryDestination
import tempfile
import os

# Verify the API is importable and overwrite_existing defaults to True
dest = SchemeDictionaryDestination(
    scheme_dict={
        "purelib": "/tmp",
        "platlib": "/tmp",
        "headers": "/tmp",
        "scripts": "/tmp",
        "data": "/tmp",
    },
    interpreter="/usr/bin/python3",
    script_kind="posix",
)
assert dest.overwrite_existing is True
EOF
