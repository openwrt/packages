#!/bin/sh

[ "$1" = python3-bcrypt ] || exit 0

python3 - << EOF
import sys
import bcrypt
password = b"super secret password"
hashed = bcrypt.hashpw(password, bcrypt.gensalt())
sys.exit(0 if bcrypt.checkpw(password, hashed) else 1)
EOF
