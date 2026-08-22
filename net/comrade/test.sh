#!/bin/sh
#
# comrade: no package-specific test -- the generic checks (executable,
#   version banner, no hardcoded paths, stripped, linked libs) already cover
#   this binary; there is no comrade-specific behaviour worth grepping
#   arbitrary --help/show text for, which is free to change independently of
#   this file.
# comrade-tests: run the deterministic unit test suite (run-unit-tests.sh).
#   The end-to-end scenarios shipped alongside it are not run here: they need
#   real network/multicast conditions this CI's QEMU emulation cannot
#   promise, and several also need a live DHT. They are for manual use on
#   real hardware, see the comrade-tests package description.

# shellcheck shell=busybox

set -e

case "$1" in
comrade)
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
