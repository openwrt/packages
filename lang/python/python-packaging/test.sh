#!/bin/sh

[ "$1" = python3-packaging ] || exit 0

python3 - << EOF
import sys
from packaging.version import Version, parse
v1 = parse("1.0a5")
v2 = Version("1.0")
sys.exit(0 if v1 < v2 else 1)
EOF
