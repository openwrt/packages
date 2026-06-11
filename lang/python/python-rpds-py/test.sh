#!/bin/sh

[ "$1" = python3-rpds-py ] || exit 0

python3 - << 'EOF'

from rpds import HashTrieMap, HashTrieSet, List

m = HashTrieMap({"foo": "bar", "baz": "quux"})
assert m.insert("spam", 37) == HashTrieMap({"foo": "bar", "baz": "quux", "spam": 37})
assert m.remove("foo") == HashTrieMap({"baz": "quux"})

s = HashTrieSet({"foo", "bar", "baz", "quux"})
assert s.insert("spam") == HashTrieSet({"foo", "bar", "baz", "quux", "spam"})
assert s.remove("foo") == HashTrieSet({"bar", "baz", "quux"})

L = List([1, 3, 5])
assert L.push_front(-1) == List([-1, 1, 3, 5])
assert L.rest == List([3, 5])

EOF
