#!/bin/sh
case "$1" in
fatresize) exit 0 ;;
*) echo "Untested package: $1" >&2; exit 1 ;;
esac
