#!/bin/sh

[ "$1" = python3-jsonschema-specifications ] || exit 0

python3 - << 'EOF'

from jsonschema_specifications import REGISTRY as SPECIFICATIONS

DRAFT202012_DIALECT_URI = "https://json-schema.org/draft/2020-12/schema"
assert SPECIFICATIONS.contents(DRAFT202012_DIALECT_URI) != ""

EOF
