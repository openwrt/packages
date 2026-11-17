#!/bin/sh

[ "$1" = python3-argcomplete ] || exit 0

python3 -c 'import argcomplete'
