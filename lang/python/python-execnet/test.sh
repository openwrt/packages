#!/bin/sh

[ "$1" = python3-execnet ] || exit 0

python3 - << 'EOF'

import execnet

# Verify basic module attributes exist
assert hasattr(execnet, 'makegateway')
assert hasattr(execnet, 'MultiChannel')
assert hasattr(execnet, 'Group')
assert execnet.__version__

EOF
