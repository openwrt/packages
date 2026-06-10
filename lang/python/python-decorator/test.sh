#!/bin/sh

[ "$1" = "python3-decorator" ] || exit 0

python3 - << EOF
import sys
import decorator

if decorator.__version__ != "$2":
    print("Wrong version: " + decorator.__version__)
    sys.exit(1)

from decorator import decorator as dec, decorate

# Basic usage: preserve function signature
@dec
def trace(f, *args, **kw):
    result = f(*args, **kw)
    return result

def greet(name, greeting="Hello"):
    return f"{greeting}, {name}"

traced = trace(greet)
assert traced("Alice") == "Hello, Alice"
assert traced("Bob", greeting="Hi") == "Hi, Bob"

# Signature is preserved
import inspect
sig = inspect.signature(traced)
assert "name" in sig.parameters
assert "greeting" in sig.parameters

# Works with classes (dispatch-style)
@dec
def noop(f, *args, **kw):
    return f(*args, **kw)

class MyClass:
    @noop
    def method(self, x):
        return x * 2

obj = MyClass()
assert obj.method(3) == 6

sys.exit(0)
EOF
