#!/bin/sh

[ "$1" = python3-lru-dict ] || exit 0

python3 - << 'EOF'
from lru import LRU

cache = LRU(3)
cache["a"] = 1
cache["b"] = 2
cache["c"] = 3
assert len(cache) == 3

# Adding a 4th item evicts the least-recently-used entry ("a")
cache["d"] = 4
assert len(cache) == 3
assert "a" not in cache
assert "d" in cache

# Access "b" to make it recently used, then "c" becomes LRU
_ = cache["b"]
cache["e"] = 5
assert "b" in cache
assert "c" not in cache

# Test LRU capacity can be changed at runtime
cache.set_size(5)
assert cache.get_size() == 5

print("python3-lru-dict OK")
EOF
