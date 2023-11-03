#!/bin/sh

[ "$1" = python3-twisted ] || exit 0

python3 -c 'from twisted.internet import reactor'
