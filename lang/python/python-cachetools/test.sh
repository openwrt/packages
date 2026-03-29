#!/bin/sh

[ "$1" = "python3-cachetools" ] || exit 0

python3 - << EOF
import sys
import cachetools

if cachetools.__version__ != "$2":
    print("Wrong version: " + cachetools.__version__)
    sys.exit(1)

from cachetools import LRUCache, TTLCache, LFUCache, cached

# LRUCache: evicts least recently used
cache = LRUCache(maxsize=2)
cache["a"] = 1
cache["b"] = 2
cache["c"] = 3  # evicts "a"
assert "a" not in cache
assert cache["b"] == 2
assert cache["c"] == 3

# LFUCache: evicts least frequently used
lfu = LFUCache(maxsize=2)
lfu["x"] = 10
lfu["y"] = 20
_ = lfu["x"]  # x accessed twice
lfu["z"] = 30  # evicts "y" (lower frequency)
assert "x" in lfu
assert "y" not in lfu

# TTLCache: entries expire
ttl = TTLCache(maxsize=10, ttl=60)
ttl["key"] = "val"
assert ttl["key"] == "val"

# @cached decorator
call_count = [0]

@cached(cache=LRUCache(maxsize=4))
def expensive(n):
    call_count[0] += 1
    return n * n

assert expensive(3) == 9
assert expensive(3) == 9   # cached, no extra call
assert call_count[0] == 1

sys.exit(0)
EOF
