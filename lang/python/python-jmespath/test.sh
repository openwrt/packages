#!/bin/sh

[ "$1" = "python3-jmespath" ] || exit 0

python3 - << EOF
import sys
import jmespath

if jmespath.__version__ != "$2":
    print("Wrong version: " + jmespath.__version__)
    sys.exit(1)

# Basic field access
data = {"name": "Alice", "age": 30}
assert jmespath.search("name", data) == "Alice"
assert jmespath.search("age", data) == 30
assert jmespath.search("missing", data) is None

# Nested access
data = {"a": {"b": {"c": 42}}}
assert jmespath.search("a.b.c", data) == 42

# Array indexing and slicing
data = {"items": [1, 2, 3, 4, 5]}
assert jmespath.search("items[0]", data) == 1
assert jmespath.search("items[-1]", data) == 5
assert jmespath.search("items[1:3]", data) == [2, 3]

# Wildcard and filter
data = {"people": [{"name": "Alice", "age": 30}, {"name": "Bob", "age": 25}]}
assert jmespath.search("people[].name", data) == ["Alice", "Bob"]
assert jmespath.search("people[?age > \`28\`].name", data) == ["Alice"]

# Pre-compiled expression
expr = jmespath.compile("a.b")
assert expr.search({"a": {"b": 99}}) == 99

sys.exit(0)
EOF
