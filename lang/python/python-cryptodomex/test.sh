#!/bin/sh

[ "$1" = python3-pycryptodomex ] || exit 0

python3 - << 'EOF'
from Cryptodome.Cipher import AES
from Cryptodome.Random import get_random_bytes
from Cryptodome.Hash import SHA256

# AES-GCM encrypt/decrypt
key = get_random_bytes(16)
cipher = AES.new(key, AES.MODE_GCM)
ciphertext, tag = cipher.encrypt_and_digest(b"hello, world!")

cipher2 = AES.new(key, AES.MODE_GCM, nonce=cipher.nonce)
plaintext = cipher2.decrypt_and_verify(ciphertext, tag)
assert plaintext == b"hello, world!"

# SHA256
h = SHA256.new(b"test data")
digest = h.hexdigest()
assert len(digest) == 64
EOF
