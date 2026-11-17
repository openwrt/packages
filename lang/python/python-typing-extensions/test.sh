#!/bin/sh

[ "$1" = python3-typing-extensions ] || exit 0

python3 -c 'import typing_extensions'
