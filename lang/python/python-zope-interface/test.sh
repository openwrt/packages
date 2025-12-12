#!/bin/sh

[ "$1" = python3-zope-interface ] || exit 0

python3 -c 'import zope.interface'
