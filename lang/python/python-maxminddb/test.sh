#!/bin/sh

[ "$1" = python3-maxminddb ] || exit 0

python3 - "$2" << 'EOF'
import sys
import tempfile

import maxminddb
from maxminddb import (
    MODE_AUTO,
    MODE_FD,
    MODE_FILE,
    MODE_MEMORY,
    MODE_MMAP,
    MODE_MMAP_EXT,
    InvalidDatabaseError,
    open_database,
)

expected = sys.argv[1]
if maxminddb.__version__ != expected:
    print(f"version mismatch: got {maxminddb.__version__}, expected {expected}")
    sys.exit(1)

# All MODE_* constants documented in the README must be distinct ints; this
# proves the public import surface still re-exports the loader modes that
# open_database accepts.
modes = {MODE_AUTO, MODE_FD, MODE_FILE, MODE_MEMORY, MODE_MMAP, MODE_MMAP_EXT}
assert len(modes) == 6, f"MODE_* constants are not distinct: {modes}"
assert all(isinstance(m, int) for m in modes)

# open_database on a path that does not exist must raise FileNotFoundError;
# this proves the loader actually reaches the filesystem.
try:
    open_database("/nonexistent.mmdb")
except FileNotFoundError:
    pass
else:
    print("open_database accepted a missing path")
    sys.exit(1)

# A non-MMDB file must raise InvalidDatabaseError; this exercises the metadata
# parser and confirms the public exception type is re-exported.
with tempfile.NamedTemporaryFile(suffix=".mmdb") as f:
    f.write(b"not a maxmind db")
    f.flush()
    try:
        open_database(f.name)
    except InvalidDatabaseError:
        pass
    else:
        print("open_database accepted a non-MMDB file")
        sys.exit(1)

print("python3-maxminddb OK")
EOF
