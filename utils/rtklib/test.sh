#!/bin/sh
#
# Functional smoke test for the RTKLIB command-line tools.
#
# Each tool prints a usage/synopsis block (containing its own name) to stderr
# when invoked with an unrecognized option, then exits 0. We confirm the
# binary runs in the target environment and produces the expected synopsis.

bin="/usr/bin/$1"

case "$1" in
convbin|pos2kml|rnx2rtkp|rtkrcv|str2str)
	[ -x "$bin" ] || {
		echo "FAIL: $bin not found or not executable"
		exit 1
	}

	# Any unknown '-' option triggers printhelp()/printusage(); rtkrcv
	# exits 0, the others may exit non-zero — capture both streams and
	# ignore the exit code, then look for the binary name in the output.
	out=$("$bin" -? 2>&1 || true)
	echo "$out" | grep -qF "$1" || {
		echo "FAIL: $1 synopsis did not mention '$1'"
		echo "$out"
		exit 1
	}
	echo "$1: synopsis OK"
	;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
