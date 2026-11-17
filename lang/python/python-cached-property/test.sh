[ "$1" = python3-cached-property ] || exit 0

python3 - << 'EOF'
from cached_property import cached_property

class MyClass:
    def __init__(self):
        self._calls = 0

    @cached_property
    def value(self):
        self._calls += 1
        return 42

obj = MyClass()
assert obj.value == 42
assert obj.value == 42
assert obj._calls == 1, f"Expected 1 call, got {obj._calls}"
print("python3-cached-property OK")
EOF
