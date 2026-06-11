#!/bin/sh

[ "$1" = python3-attrs ] || exit 0

python3 - <<'EOF'
import attr
import attrs

# Define a class with attrs
@attr.s
class Point:
    x = attr.ib()
    y = attr.ib(default=0)

p = Point(1, 2)
assert p.x == 1
assert p.y == 2

p2 = Point(3)
assert p2.y == 0

# Equality
assert Point(1, 2) == Point(1, 2)
assert Point(1, 2) != Point(1, 3)

# attrs.define (modern API)
@attrs.define
class Circle:
    radius: float
    color: str = "red"

c = Circle(5.0)
assert c.radius == 5.0
assert c.color == "red"

c2 = Circle(radius=3.0, color="blue")
assert c2.color == "blue"

# asdict
d = attr.asdict(p)
assert d == {"x": 1, "y": 2}

print("python-attrs OK")
EOF
