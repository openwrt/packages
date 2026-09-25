#!/bin/sh

[ "$1" = python3-mako ] || exit 0

python3 - << 'EOF'
from mako.template import Template

# Basic variable rendering
t = Template("Hello, ${name}!")
result = t.render(name="World")
assert result == "Hello, World!", f"Unexpected: {result!r}"

# Control flow
t = Template("""
% for item in items:
- ${item}
% endfor
""".strip())
result = t.render(items=["a", "b", "c"])
assert "- a" in result
assert "- b" in result
assert "- c" in result

# Expression evaluation
t = Template("${2 + 2}")
result = t.render()
assert result.strip() == "4", f"Unexpected: {result!r}"
EOF
