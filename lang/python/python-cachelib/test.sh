#!/bin/sh
[ "$1" = python3-cachelib ] || exit 0
python3 - << 'EOF'
from cachelib import SimpleCache, NullCache

cache = SimpleCache()
cache.set("key", "value")
assert cache.get("key") == "value", "SimpleCache set/get failed"
assert cache.get("missing") is None
cache.delete("key")
assert cache.get("key") is None, "delete failed"

cache.set("a", 1)
cache.set("b", 2)
cache.clear()
assert cache.get("a") is None, "clear failed"

null = NullCache()
null.set("k", "v")
assert null.get("k") is None, "NullCache should not store"
EOF
