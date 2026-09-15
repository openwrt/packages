#!/bin/sh
#
# Functional smoke tests for openthread-br.

set -e

case "$PKG_NAME" in
openthread-br)
	# Exercises otbr-agent's option parser and its full runtime closure.
	# --version prints and exits without touching the RCP or the network.
	# The Makefile passes OTBR_VERSION=$(PKG_VERSION), so this is also
	# the string the generic version check matches.
	otbr-agent --version

	# Use -h rather than --version here: ot-ctl has no version option at
	# this release (openthread/openthread#13424 adds one, but the openthread
	# bundled here predates it), so -h is the option that exits inside the
	# parser. The older hazard -- a segfault on any unrecognized long
	# option, from a getopt_long() array missing its terminating entry --
	# is fixed in the openthread this release bundles
	# (openthread/openthread#13423).
	# A usage exit of 0 or 1 both mean the parser ran to completion;
	# anything else (a crash reports 128+signal) is what this catches.
	# Only stdout is dropped: ot-ctl's own diagnostics belong in the CI
	# log, where they say what went wrong next to the status below.
	set +e
	ot-ctl -h >/dev/null
	rc=$?
	set -e
	case $rc in
	0|1) ;;
	*)
		echo "test.sh: ot-ctl -h exited with status $rc" >&2
		exit 1
		;;
	esac
	;;

*)
	echo "test.sh: unknown package '$PKG_NAME', refusing to silently pass" >&2
	echo "test.sh: update net/openthread-br/test.sh to cover this package" >&2
	exit 1
	;;
esac
