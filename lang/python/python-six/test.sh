#!/bin/sh

[ "$1" = python3-six ] || exit 0

python3 - <<'EOF'
import six

# Check version
assert six.PY3, "Expected PY3 to be True"
assert not six.PY2, "Expected PY2 to be False"

# Test string types
assert six.string_types == (str,)
assert six.text_type == str
assert six.binary_type == bytes
assert six.integer_types == (int,)

# Test moves
from six.moves import range
assert list(range(3)) == [0, 1, 2]

# Test b() and u() helpers
assert six.b('hello') == b'hello'
assert six.u('hello') == 'hello'

# Test ensure_str / ensure_binary / ensure_text
assert six.ensure_str('hello') == 'hello'
assert six.ensure_binary('hello') == b'hello'
assert six.ensure_text(b'hello') == 'hello'

print("python-six OK")
EOF
