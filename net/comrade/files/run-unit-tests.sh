#!/bin/sh
# Runs comrade's deterministic unit test binaries, installed next to this
# script by the comrade-tests package. Not the end-to-end scenarios, and
# not the few *_test binaries in SKIP below: all of those need real
# network/timing conditions QEMU CI can't promise, and are meant for
# manual runs on real hardware instead (see the comrade-tests package
# description).
#
# A test exiting 77 is the CTest/Automake skip convention (sig_rebuild_test
# uses it when it cannot get a socket); this script honours the same
# convention rather than treating it as a failure.
#
# What to run is discovered from what comrade-tests/install in the Makefile
# actually put next to this script (every *_test binary), not a separate
# list kept here: the two can never disagree about what was installed.

# shellcheck shell=busybox

set -u

DIR=$(dirname "$0")

# QEMU-emulated CI can hang or run too slow for these: stream_cc_test
# asserts a throughput floor, natstream_test does real ICE/NAT gathering.
# Manual runs on real hardware can opt back in with COMRADE_SKIP= (an
# explicitly empty value, not just unset, so the default below still
# applies).
SKIP="${COMRADE_SKIP-stream_cc_test natstream_test}"
skip_seen=""

# sig_rebuild_test persists its node cache under XDG_DATA_HOME; give it a
# throwaway directory instead of whatever this shell's real one is.
XDG_DATA_HOME=$(mktemp -d)
export XDG_DATA_HOME
cleanup() { rm -rf "$XDG_DATA_HOME"; }
trap cleanup EXIT INT TERM

failed=0
skipped=0
passed=0

for t in "$DIR"/*_test; do
	[ -e "$t" ] || continue
	name=$(basename "$t")

	case " $SKIP " in
	*" $name "*)
		echo "SKIP $name (needs real hardware)"
		skipped=$((skipped + 1))
		skip_seen="$skip_seen $name"
		continue
		;;
	esac

	if [ ! -x "$t" ]; then
		echo "FAIL $name (not executable)"
		failed=$((failed + 1))
		continue
	fi

	# A wedged test must fail in minutes and by name, not hang CI to the
	# job's six-hour limit. 600s is 5x upstream's largest CTest TIMEOUT
	# (120s), with margin for QEMU emulation of the slowest targets.
	timeout 600 "$t"
	ret=$?
	if [ "$ret" -eq 0 ]; then
		echo "PASS $name"
		passed=$((passed + 1))
	elif [ "$ret" -eq 77 ]; then
		echo "SKIP $name"
		skipped=$((skipped + 1))
	else
		echo "FAIL $name (exit $ret)"
		failed=$((failed + 1))
	fi
done

# A SKIP entry that never matched an installed binary is itself drift: a
# rename or removal upstream, silently leaving the entry to skip nothing.
for s in $SKIP; do
	case " $skip_seen " in
	*" $s "*) ;;
	*) echo "warn: SKIP entry '$s' matched no installed *_test binary" >&2 ;;
	esac
done

echo
echo "$passed passed, $skipped skipped, $failed failed"

# A glob that matched nothing looks identical to an all-pass run otherwise
# ($failed stays 0) -- refuse to report success for a suite that never ran.
if [ "$((passed + skipped + failed))" -eq 0 ]; then
	echo "no *_test binaries found next to $0" >&2
	exit 1
fi

[ "$failed" -eq 0 ]
