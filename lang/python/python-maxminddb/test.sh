#!/bin/sh

[ "$1" = python3-maxminddb ] || exit 0

python3 - << 'EOF'
import maxminddb
from maxminddb import open_database, InvalidDatabaseError

assert callable(open_database)
assert issubclass(InvalidDatabaseError, Exception)

print("python3-maxminddb OK")
EOF