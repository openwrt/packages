#!/bin/sh
case "$1" in
captest|filecap|netcap|pscap) exit 0 ;;
*) echo "Untested package: $1" >&2; exit 1 ;;
esac
