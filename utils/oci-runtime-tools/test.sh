#!/bin/sh

case "$1" in
oci-runtime-tool)
	oci-runtime-tool --version 2>&1 | grep -F "$2"
	;;

oci-runtime-tests)
	# runtimetest and the validation/*.go test binaries installed here have
	# no version flag; probing any of them with one runs the OCI compliance
	# test it implements instead, out of the working directory it expects
	exit 0
	;;

*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
