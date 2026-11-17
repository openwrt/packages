#!/bin/sh

[ "$1" = python3-bidict ] || exit 0

python3 - <<'EOF'
from bidict import bidict

# Basic creation and lookup
b = bidict({'a': 1, 'b': 2, 'c': 3})
assert b['a'] == 1
assert b.inverse[1] == 'a'
assert b.inverse[2] == 'b'

# Put and update
b['d'] = 4
assert b['d'] == 4
assert b.inverse[4] == 'd'

# Delete
del b['d']
assert 'd' not in b
assert 4 not in b.inverse

# Inverse of inverse is the original
assert b.inverse.inverse is b

# len
assert len(b) == 3

print("python-bidict OK")
EOF
