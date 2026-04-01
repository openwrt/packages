#!/bin/sh

[ "$1" = python3-markdown ] || exit 0

python3 - << 'EOF'

import markdown

# Basic conversion
result = markdown.markdown("# Hello World")
assert result == "<h1>Hello World</h1>", f"got: {result}"

# Bold and italic
result = markdown.markdown("**bold** and *italic*")
assert "<strong>bold</strong>" in result
assert "<em>italic</em>" in result

# List
result = markdown.markdown("- item1\n- item2")
assert "<ul>" in result
assert "<li>item1</li>" in result

EOF
