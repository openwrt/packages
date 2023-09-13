#!/bin/sh

[ "$1" = python3-cryptography ] || exit 0

python3 - << EOF
import sys
from cryptography.fernet import Fernet
key = Fernet.generate_key()
f = Fernet(key)
token = f.encrypt(b"my deep dark secret")
sys.exit(0 if f.decrypt(token) == b"my deep dark secret" else 1)
EOF
