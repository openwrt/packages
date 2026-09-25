#!/bin/sh

[ "$1" = "python3-setuptools-scm" ] || exit 0

python3 - << EOF
import sys
import setuptools_scm

if setuptools_scm.__version__ != "$2":
    print("Wrong version: " + setuptools_scm.__version__)
    sys.exit(1)

# Test get_version() via pretend version env var (no git repo needed)
import os
os.environ["SETUPTOOLS_SCM_PRETEND_VERSION"] = "1.2.3"
version = setuptools_scm.get_version()
assert version == "1.2.3", f"Expected 1.2.3, got {version}"

sys.exit(0)
EOF
