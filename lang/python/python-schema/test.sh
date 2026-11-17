#!/bin/sh

[ "$1" = "python3-schema" ] || exit 0

python3 - << EOF
import sys
import schema as sc

if sc.__version__ != "$2":
    print("Wrong version: " + sc.__version__)
    sys.exit(1)

from schema import Schema, SchemaError, Optional, And, Or

# Basic type validation
s = Schema(int)
assert s.validate(42) == 42
try:
    s.validate("not an int")
    sys.exit(1)
except SchemaError:
    pass

# Dict schema
s = Schema({"name": str, "age": And(int, lambda n: n > 0)})
data = s.validate({"name": "Alice", "age": 30})
assert data["name"] == "Alice"
assert data["age"] == 30

# Optional key
s = Schema({"key": str, Optional("opt"): int})
assert s.validate({"key": "val"}) == {"key": "val"}

# Or
s = Schema(Or(int, str))
assert s.validate(1) == 1
assert s.validate("x") == "x"

sys.exit(0)
EOF
