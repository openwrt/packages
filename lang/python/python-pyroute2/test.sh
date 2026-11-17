#!/bin/sh

[ "$1" = python3-pyroute2 ] || exit 0

python3 - << 'EOF'
from pyroute2 import IPRoute, NDB
from pyroute2.netlink import nlmsg

# Verify key classes are importable
assert callable(IPRoute)
assert callable(NDB)
assert issubclass(nlmsg, object)

print("python3-pyroute2 OK")
EOF