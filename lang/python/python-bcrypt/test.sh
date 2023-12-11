#!/bin/sh

[ "$1" = python3-bcrypt ] || exit 0

python3 - << 'EOF'

import bcrypt
password = b"super secret password"
hashed = bcrypt.hashpw(password, bcrypt.gensalt())
assert bcrypt.checkpw(password, hashed)

EOF
