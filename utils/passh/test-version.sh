#!/bin/sh

out=`$1 --version`
if [ "$out" != "$1 $2" ]; then
    exit 1
fi
