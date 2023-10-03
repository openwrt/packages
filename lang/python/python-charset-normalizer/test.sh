#!/bin/sh

[ "$1" = python3-charset-normalizer ] || exit 0

python3 - << EOF
import sys
from charset_normalizer import from_bytes
s = 'Bсеки човек има право на образование.'
byte_str = s.encode('cp1251')
result = from_bytes(byte_str).best()
sys.exit(0 if str(result) == s else 1)
EOF
