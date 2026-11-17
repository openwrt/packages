#!/bin/sh

test_oqsprovider() {
	RET=0
	apk add openssl-util
	openssl list -all-algorithms | grep oqsprovider || RET=1
	openssl genpkey -verbose -algorithm mayo1 -text || RET=1
	exit $RET
}

case "$1" in
	libopenssl-oqsprovider)
		test_oqsprovider
		;;
	*)
		echo "Unexpected package '$1'" >&2
		exit 1
		;;
esac
