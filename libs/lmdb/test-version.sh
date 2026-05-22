#!/bin/sh

pkg=$1
ver=$2

case "$pkg" in
lmdb)
	exit 0
	;;
lmdb-test)
	exit 0
	;;
lmdb-utils)
	mdb_dump -V 2>&1 | grep -qF "LMDB $ver" || exit 1
	exit 0
	;;
*)
	echo "test-version.sh: unhandled sub-package '$pkg'" >&2
	exit 1
	;;
esac
