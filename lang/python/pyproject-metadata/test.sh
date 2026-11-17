#!/bin/sh

[ "$1" = python3-pyproject-metadata ] || exit 0

python3 - << 'EOF'
from pyproject_metadata import StandardMetadata

data = {
    "project": {
        "name": "test-pkg",
        "version": "0.1.0",
        "description": "A test package",
        "requires-python": ">=3.8",
    }
}
m = StandardMetadata.from_pyproject(data)
assert m.name == "test-pkg"
assert str(m.version) == "0.1.0"
assert m.description == "A test package"

data2 = {
    "project": {
        "name": "other-pkg",
        "version": "2.0.0",
        "dependencies": ["requests>=2.0"],
    }
}
m2 = StandardMetadata.from_pyproject(data2)
assert m2.name == "other-pkg"
assert str(m2.version) == "2.0.0"
assert len(m2.dependencies) == 1
EOF
