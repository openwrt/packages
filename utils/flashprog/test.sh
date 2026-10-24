#!/bin/sh

set -e

case "$1" in
flashprog|flashprog-external|flashprog-pci|flashprog-spi) bin=flashprog ;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

"$bin" --version | grep "^flashprog v$2"
dd if=/dev/urandom of="$tmp/in" bs=1k count=4096
"$bin" -p dummy:emulate=SST25VF032B,image="$tmp/rom" -w "$tmp/in"
"$bin" -p dummy:emulate=SST25VF032B,image="$tmp/rom" -r "$tmp/out"
cmp "$tmp/in" "$tmp/out"
