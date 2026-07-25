#!/bin/sh

[ "$1" = python3-jsonpath-ng ] || exit 0

python3 - "$2" << 'EOF'
import sys
import jsonpath_ng
from jsonpath_ng import parse
from jsonpath_ng.ext import parse as ext_parse

# The jsonpath_ng CLI has no version flag, so the generic version check is
# overridden (test-version.sh); confirm the package version here instead.
if jsonpath_ng.__version__ != sys.argv[1]:
    print("Wrong version: " + jsonpath_ng.__version__)
    sys.exit(1)

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

# Filter expression (ext parser, exercises the vendored ply lexer/parser)
expr3 = ext_parse("store.books[?price > 12].title")
titles = [m.value for m in expr3.find(data)]
assert set(titles) == {"B", "C"}, f"Unexpected: {titles}"
EOF
[ $? -eq 0 ] || exit 1

# Verify the jsonpath_ng command-line tool (reads JSON from stdin)
result=$(echo '{"a": {"b": 42}}' | jsonpath_ng 'a.b')
[ "$result" = "42" ] || {
	echo "jsonpath_ng returned '$result', expected 42"
	exit 1
}
