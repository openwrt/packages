#!/bin/sh
[ "$1" = python3-ruamel-yaml ] || exit 0

python3 - << 'EOF'
import io
import ruamel.yaml

yaml = ruamel.yaml.YAML()

# Round-trip load and dump preserving comments
data_str = """\
# top comment
name: test  # inline comment
values:
  - 1
  - 2
  - 3
"""
buf = io.StringIO(data_str)
data = yaml.load(buf)
assert data['name'] == 'test'
assert data['values'] == [1, 2, 3]

# Dump back and verify structure is preserved
out = io.StringIO()
yaml.dump(data, out)
result = out.getvalue()
assert 'name: test' in result
assert 'top comment' in result

# Safe load
yaml_safe = ruamel.yaml.YAML(typ='safe')
simple = yaml_safe.load('key: value')
assert simple['key'] == 'value'

print("ruamel.yaml OK")
EOF
