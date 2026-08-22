#!/bin/sh
# Runs comrade's deterministic unit test binaries, installed next to this
# script by the comrade-tests package. Not the end-to-end scenarios: those
# need real network/multicast conditions this script does not try to
# provide, and are meant for manual runs on real hardware instead (see the
# comrade-tests package description).
#
# A test exiting 77 is the CTest/Automake skip convention (sig_rebuild_test
# uses it when it cannot get a socket); this script honours the same
# convention rather than treating it as a failure.

# shellcheck shell=busybox

set -u

DIR=$(dirname "$0")

TESTS="
	token_test
	tokgen_test
	termfilter_test
	ctlproto_test
	netmon_test
	path_test
	candpolicy_test
	candpack_test
	mailbox_test
	roauth_test
	bep44_test
	bep44_pin_test
	sig_rebuild_test
	natstream_test
	sshloop_test
	sshfwd_test
	sshexit_test
	sshro_test
	sshkcp_test
	sshctl_test
"

# sig_rebuild_test persists its node cache under XDG_DATA_HOME; give it a
# throwaway directory instead of whatever this shell's real one is.
XDG_DATA_HOME=$(mktemp -d)
export XDG_DATA_HOME
cleanup() { rm -rf "$XDG_DATA_HOME"; }
trap cleanup EXIT INT TERM

failed=0
skipped=0
passed=0

for t in $TESTS; do
	if [ ! -x "$DIR/$t" ]; then
		echo "FAIL $t (not installed)"
		failed=$((failed + 1))
		continue
	fi

	"$DIR/$t"
	ret=$?
	if [ "$ret" -eq 0 ]; then
		echo "PASS $t"
		passed=$((passed + 1))
	elif [ "$ret" -eq 77 ]; then
		echo "SKIP $t"
		skipped=$((skipped + 1))
	else
		echo "FAIL $t (exit $ret)"
		failed=$((failed + 1))
	fi
done

echo
echo "$passed passed, $skipped skipped, $failed failed"

[ "$failed" -eq 0 ]
