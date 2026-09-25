#!/bin/sh

[ "$1" = python3-gnupg ] || exit 0

python3 - << 'EOF'
import gnupg

gpg = gnupg.GPG.__new__(gnupg.GPG)
assert gpg is not None
EOF
