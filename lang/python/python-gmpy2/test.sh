#!/bin/sh

[ "$1" = python3-gmpy2 ] || exit 0

python3 -c 'import gmpy2'
