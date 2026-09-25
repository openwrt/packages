#!/bin/sh

[ "$1" = python3-ruamel-yaml ] || exit 0

python3 - << 'EOF'
from ruamel.yaml import YAML
from io import StringIO

yaml = YAML()

# Test basic load/dump
data = yaml.load("key: value\nlist:\n  - a\n  - b\n")
assert data["key"] == "value"
assert data["list"] == ["a", "b"]

out = StringIO()
yaml.dump({"x": 1}, out)
assert "x: 1" in out.getvalue()

# Test roundtrip comment preservation (key ruamel.yaml feature)
doc = "# header\nname: test  # inline\n"
data2 = yaml.load(doc)
assert data2["name"] == "test"
buf = StringIO()
yaml.dump(data2, buf)
assert "# header" in buf.getvalue()
assert "# inline" in buf.getvalue()

print("python3-ruamel-yaml OK")
EOF
