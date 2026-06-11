#!/bin/sh

[ "$1" = python3-pyrsistent ] || exit 0

python3 - << 'EOF'

from pyrsistent import pmap, pvector, pset

# Persistent map
m = pmap({"a": 1, "b": 2})
m2 = m.set("c", 3)
assert m["a"] == 1
assert "c" not in m
assert m2["c"] == 3

# Persistent vector
v = pvector([1, 2, 3])
v2 = v.append(4)
assert len(v) == 3
assert len(v2) == 4
assert v2[3] == 4

# Persistent set
s = pset([1, 2, 3])
s2 = s.add(4)
assert 4 not in s
assert 4 in s2

EOF
