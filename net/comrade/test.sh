#!/bin/sh
#
# comrade: run comrade --help/show as a smoke test.
# comrade-tests: run the deterministic unit test suite (run-unit-tests.sh).
#   The end-to-end scenarios shipped alongside it are not run here: they need
#   real network/multicast conditions this CI's QEMU emulation cannot
#   promise, and several also need a live DHT. They are for manual use on
#   real hardware, see the comrade-tests package description.

# shellcheck shell=busybox

set -e

case "$1" in
comrade)
	comrade --help 2>&1 | grep -q "start a shared session"
	comrade show 2>&1 | grep -q "no running session"
	;;

comrade-tests)
	/usr/share/comrade/tests/run-unit-tests.sh
	;;

*)
	echo "test.sh: unknown subpackage '$1' -- refusing to silently pass" >&2
	echo "test.sh: update net/comrade/test.sh to cover this subpackage" >&2
	exit 1
	;;
esac
