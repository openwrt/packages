#!/bin/sh

[ "$1" = python3-chardet ] || exit 0

python3 - << 'EOF'
import chardet

result = chardet.detect(b'Hello, World!')
assert result['encoding'] is not None

result = chardet.detect('Привет мир'.encode('utf-8'))
assert result['encoding'] is not None
EOF
