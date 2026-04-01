#!/bin/sh

[ "$1" = python3-aiosignal ] || exit 0

python3 - << 'EOF'

from aiosignal import Signal

# Test Signal creation and basic list operations
sig = Signal(owner=object())
assert len(sig) == 0

callback = lambda: None
sig.append(callback)
assert len(sig) == 1
assert sig[0] is callback

# Test freeze
sig.freeze()
assert sig.frozen

# Test that frozen signal raises on modification
try:
    sig.append(lambda: None)
    assert False, "should have raised"
except RuntimeError:
    pass

EOF
