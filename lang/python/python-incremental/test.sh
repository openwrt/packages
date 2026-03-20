#!/bin/sh

[ "$1" = python3-incremental ] || exit 0

python3 -c 'import incremental'
