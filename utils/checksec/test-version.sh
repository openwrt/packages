#!/bin/sh

# shellcheck shell=busybox

# checksec.bash reports a version unrelated to the release it ships in:
# SCRIPT_MAJOR, SCRIPT_MINOR and SCRIPT_REVISION have not been bumped since
# before 3.0.0, so 3.2.0 still prints "checksec v2.7.1". Upstream will not fix
# it, the bash implementation is legacy and is being replaced by a Go rewrite:
# https://github.com/slimm609/checksec.sh/issues/352
#
# Matching that hardcoded string asserts nothing about the installed package,
# so only require that the tool runs. The override itself has to stay: without
# it the generic probe fails the package for not reporting $PKG_VERSION.

case "$PKG_NAME" in
checksec)
	checksec --version
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
