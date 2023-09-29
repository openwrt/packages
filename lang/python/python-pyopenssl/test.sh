#!/bin/sh

[ "$1" = python3-pyopenssl ] || exit 0

python3 -m OpenSSL.debug
