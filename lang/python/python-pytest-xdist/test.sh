#!/bin/sh
[ "$1" = python3-pytest-xdist ] || exit 0

python3 - << 'EOF'
import xdist
import xdist.plugin
import xdist.scheduler

# Verify version
assert xdist.__version__, "xdist version is empty"

# Verify key scheduler classes are importable
from xdist.scheduler import LoadScheduling, EachScheduling
sched = LoadScheduling.__name__
assert sched == 'LoadScheduling'

print("pytest-xdist OK")
EOF
