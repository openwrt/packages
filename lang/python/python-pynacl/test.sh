#!/bin/sh

[ "$1" = python3-pynacl ] || exit 0

python3 - << 'EOF'
import nacl.secret
import nacl.utils
import nacl.public

# Secret-key encryption (SecretBox)
key = nacl.utils.random(nacl.secret.SecretBox.KEY_SIZE)
box = nacl.secret.SecretBox(key)
message = b"secret message"
encrypted = box.encrypt(message)
decrypted = box.decrypt(encrypted)
assert decrypted == message

# Public-key encryption (Box)
alice_priv = nacl.public.PrivateKey.generate()
bob_priv = nacl.public.PrivateKey.generate()
alice_box = nacl.public.Box(alice_priv, bob_priv.public_key)
bob_box = nacl.public.Box(bob_priv, alice_priv.public_key)

msg = b"hello bob"
enc = alice_box.encrypt(msg)
dec = bob_box.decrypt(enc)
assert dec == msg
EOF
