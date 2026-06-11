#!/bin/sh

[ "$1" = python3-jsonpath-ng ] || exit 0

python3 - << 'EOF'
from jsonpath_ng import parse
from jsonpath_ng.ext import parse as ext_parse

data = {
    "store": {
        "books": [
            {"title": "A", "price": 10},
            {"title": "B", "price": 20},
            {"title": "C", "price": 15},
        ]
    }
}

# Basic path
expr = parse("store.books[*].title")
matches = [m.value for m in expr.find(data)]
assert matches == ["A", "B", "C"], f"Unexpected: {matches}"

# Indexed access
expr2 = parse("store.books[1].price")
assert expr2.find(data)[0].value == 20

# Filter expression (ext parser)
expr3 = ext_parse("store.books[?price > 12].title")
titles = [m.value for m in expr3.find(data)]
assert set(titles) == {"B", "C"}, f"Unexpected: {titles}"
EOF
