#!/bin/sh

[ "$1" = python3-cryptography ] || exit 0

python3 - << 'EOF'

from cryptography.fernet import Fernet
key = Fernet.generate_key()
f = Fernet(key)
msg = b"my deep dark secret"
token = f.encrypt(msg)
assert f.decrypt(token) == msg

EOF
