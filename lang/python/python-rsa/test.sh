#!/bin/sh

[ "$1" = python3-rsa ] || exit 0

python3 - << 'EOF'

import rsa

# Generate keys
(pub, priv) = rsa.newkeys(512)

# Sign and verify
message = b"Hello OpenWrt"
signature = rsa.sign(message, priv, "SHA-256")
verified = rsa.verify(message, signature, pub)
assert verified == "SHA-256", f"expected SHA-256, got {verified}"

# Encrypt and decrypt
encrypted = rsa.encrypt(message, pub)
decrypted = rsa.decrypt(encrypted, priv)
assert decrypted == message, f"decryption failed"

EOF
