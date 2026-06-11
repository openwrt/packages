#!/bin/sh

[ "$1" = python3-slugify ] || exit 0

python3 - << 'EOF'
from slugify import slugify

# Basic ASCII
assert slugify('Hello World') == 'hello-world', f"got: {slugify('Hello World')}"

# Unicode transliteration
assert slugify('Héllo Wörld') == 'hello-world', f"got: {slugify('Héllo Wörld')}"

# Special characters stripped
assert slugify('Hello, World!') == 'hello-world', f"got: {slugify('Hello, World!')}"

# Numbers preserved
assert slugify('test 123') == 'test-123', f"got: {slugify('test 123')}"

# Custom separator
assert slugify('Hello World', separator='_') == 'hello_world'

# Max length
result = slugify('a very long title that should be truncated', max_length=10)
assert len(result) <= 10, f"length {len(result)} > 10"

print("python-slugify OK")
EOF
