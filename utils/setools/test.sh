#!/bin/sh

[ "$1" = python3-setools ] || exit 0

python3 - << 'EOF'
import setools

# Verify the module loads and basic query classes are accessible
assert hasattr(setools, 'SELinuxPolicy'), \
    "setools missing SELinuxPolicy class"
assert hasattr(setools, 'BoolQuery'), \
    "setools missing BoolQuery class"
assert hasattr(setools, 'TypeQuery'), \
    "setools missing TypeQuery class"
assert hasattr(setools, 'RoleQuery'), \
    "setools missing RoleQuery class"
assert hasattr(setools, 'UserQuery'), \
    "setools missing UserQuery class"
EOF
