#!/bin/sh

[ "$1" = python3-orjson ] || exit 0

python3 - << 'EOF'
import faulthandler
faulthandler.enable()

print("importing orjson...", flush=True)
import orjson
print("import OK", flush=True)

# Basic encode/decode
data = {"key": "value", "number": 42, "flag": True, "empty": None}
encoded = orjson.dumps(data)
assert isinstance(encoded, bytes)
decoded = orjson.loads(encoded)
assert decoded == data
print("basic encode/decode OK", flush=True)

# List roundtrip
lst = [1, 2, 3, "hello"]
assert orjson.loads(orjson.dumps(lst)) == lst
print("list roundtrip OK", flush=True)

# Nested structures
nested = {"a": {"b": {"c": 1}}}
assert orjson.loads(orjson.dumps(nested)) == nested
print("nested OK", flush=True)

# OPT_SORT_KEYS option
obj = {"z": 1, "a": 2, "m": 3}
sorted_json = orjson.dumps(obj, option=orjson.OPT_SORT_KEYS)
assert sorted_json == b'{"a":2,"m":3,"z":1}'
print("sort_keys OK", flush=True)

print("orjson OK")
EOF
