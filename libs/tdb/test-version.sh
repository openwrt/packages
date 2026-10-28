#!/bin/sh
# The tdb tools have no option that prints the version.
case "$1" in
tdb)
	ls "/usr/lib/libtdb.so.$2"
	;;
esac
