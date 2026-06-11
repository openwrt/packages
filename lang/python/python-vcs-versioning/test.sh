#!/bin/sh

[ "$1" = "python3-vcs-versioning" ] || exit 0

python3 - << EOF
import sys
import vcs_versioning

if vcs_versioning.__version__ != "$2":
    print("Wrong version: " + vcs_versioning.__version__)
    sys.exit(1)

# Test core classes are importable
from vcs_versioning import Configuration, ScmVersion, Version
from vcs_versioning import DEFAULT_VERSION_SCHEME, DEFAULT_LOCAL_SCHEME

# Test Version parsing
v = Version("1.2.3")
assert str(v) == "1.2.3", f"Expected 1.2.3, got {v}"

# Test default schemes are set
assert DEFAULT_VERSION_SCHEME is not None
assert DEFAULT_LOCAL_SCHEME is not None

sys.exit(0)
EOF
