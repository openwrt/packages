#!/bin/sh

# shellcheck shell=busybox
#
# Generic version-check override.
#
# The CI test framework (test_entrypoint.sh) runs this once per sub-package
# with PKG_NAME / PKG_VERSION exported. Returning 0 means "version OK / not
# applicable"; a non-zero exit fails the package.
#
# Most lxc-* tool binaries print only the bare version number (e.g. "7.0.0")
# on --version via the shared tools/arguments.c parser, which we match below.
# The exceptions, which expose no usable version string, are skipped:
#   lxc-config       - custom arg parser, no --version (prints config items)
#   lxc-usernsexec   - plain getopt ("m:hsu:g:"), no --version flag
#   lxc-checkconfig  - shell script, prints no machine-readable version
#   lxc-monitord     - libexec helper, no --version flag
#   lxc-user-nic     - libexec helper, no --version flag
#
# Meta/library/script packages that ship no versioned executable are also
# skipped; their functionality is covered by the build itself.

case "$PKG_NAME" in
lxc|\
lxc-common|\
lxc-hooks|\
lxc-templates|\
lxc-configs|\
lxc-init|\
lxc-auto|\
lxc-unprivileged|\
liblxc|\
lxc-checkconfig|\
lxc-config|\
lxc-usernsexec|\
lxc-monitord|\
lxc-user-nic)
	# No machine-readable version output; skip generic version check.
	exit 0
	;;

lxc-attach|\
lxc-autostart|\
lxc-cgroup|\
lxc-copy|\
lxc-console|\
lxc-create|\
lxc-destroy|\
lxc-device|\
lxc-execute|\
lxc-freeze|\
lxc-info|\
lxc-monitor|\
lxc-snapshot|\
lxc-start|\
lxc-stop|\
lxc-unfreeze|\
lxc-unshare|\
lxc-wait|\
lxc-top|\
lxc-ls)
	# These binaries print just the version number to stdout on --version.
	"$PKG_NAME" --version | grep -F "$PKG_VERSION"
	;;

*)
	echo "test-version.sh: unhandled sub-package '$PKG_NAME'" >&2
	exit 1
	;;
esac
