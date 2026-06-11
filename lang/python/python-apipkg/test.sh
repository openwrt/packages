#!/bin/sh

[ "$1" = python3-apipkg ] || exit 0

python3 -c 'import apipkg'
