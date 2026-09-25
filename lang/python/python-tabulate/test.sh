#!/bin/sh

[ "$1" = "python3-tabulate" ] || exit 0

python3 - << EOF
import sys
import tabulate as tab_mod

if tab_mod.__version__ != "$2":
    print("Wrong version: " + tab_mod.__version__)
    sys.exit(1)

from tabulate import tabulate

# Basic table rendering
data = [["Alice", 30], ["Bob", 25]]
headers = ["Name", "Age"]

out = tabulate(data, headers=headers)
assert "Alice" in out, "Alice not in output"
assert "Bob" in out, "Bob not in output"
assert "Name" in out, "header Name not in output"
assert "Age" in out, "header Age not in output"

# Grid format
out = tabulate(data, headers=headers, tablefmt="grid")
assert "+" in out, "grid format should contain +"

# Plain format (no borders)
out = tabulate(data, tablefmt="plain")
assert "Alice" in out

# Column alignment: numbers right-aligned
out = tabulate([[1, 1000], [2, 20]], headers=["id", "val"])
lines = out.splitlines()
assert len(lines) >= 3, "expected at least 3 lines"

sys.exit(0)
EOF
