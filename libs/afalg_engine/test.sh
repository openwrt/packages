#!/bin/sh

test_afalg_engine() {
	apk add openssl-util
	openssl engine -t -c -v -pre DUMP_INFO afalg
}

case "$1" in
	libopenssl-afalg_sync)
		test_afalg_engine
		;;
	*)
		echo "Unexpected package '$1'" >&2
		exit 1
		;;
esac
