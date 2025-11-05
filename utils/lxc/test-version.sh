#!/bin/sh

# shellcheck shell=busybox
#
# Generic version-check override.
#
# Most lxc-* binaries print only the bare version number (e.g. "6.0.6")
# via --version, which the framework's generic probe picks up correctly.
# The exceptions are:
#   lxc-checkconfig  - shell script, prints no machine-readable version
#   lxc-config       - binary but version output not matched by generic probe
#   lxc-monitord     - libexec helper, no --version flag
#   lxc-user-nic     - libexec helper, no --version flag
#
# Packages that do expose a usable version string are probed directly.
# Meta/library/script packages that do not are skipped here; functionality
# is covered by the build itself.

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
lxc-monitord|\
lxc-user-nic|\
lxc-usernsexec)
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
