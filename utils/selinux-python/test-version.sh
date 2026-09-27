#!/bin/sh

# shellcheck shell=busybox

# None of the selinux-python tools print the package version.
# Skip the generic version probe.

case "$PKG_NAME" in
python3-seobject|\
python3-seobject-src|\
python3-sepolgen|\
python3-sepolgen-src|\
python3-sepolicy|\
python3-sepolicy-src|\
selinux-audit2allow|\
selinux-chcat|\
selinux-python|\
selinux-semanage|\
selinux-sepolgen-ifgen|\
selinux-sepolicy)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
