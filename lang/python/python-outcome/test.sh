#!/bin/sh

[ "$1" = python3-outcome ] || exit 0

python3 - << 'EOF'
from outcome import Value, Error, capture, acapture

# Value outcome
v = Value(42)
assert v.value == 42
assert v.unwrap() == 42

# Error outcome
e = Error(ValueError("oops"))
assert isinstance(e.error, ValueError)
try:
    e.unwrap()
    assert False, "Should have raised"
except ValueError as exc:
    assert str(exc) == "oops"

# capture()
result = capture(lambda: 1 + 1)
assert isinstance(result, Value)
assert result.value == 2

result2 = capture(lambda: 1 / 0)
assert isinstance(result2, Error)
assert isinstance(result2.error, ZeroDivisionError)

# acapture is present and callable (async test omitted: python3-asyncio not a dependency)
assert callable(acapture)
EOF
