#!/bin/sh

# shellcheck shell=busybox

# klish reports an internal client help version, not the package release:
# "Version : 1.0.0" for the 3.2.0 upstream release.
package_name="${PKG_NAME:-$1}"

case "$package_name" in
klish3|\
libklish3|\
libtinyrl3|\
klish3-db-libxml2|\
klish3-db-ischeme|\
klish3-plugin-klish|\
klish3-plugin-script)
	exit 0
	;;
*)
	echo "Untested package: $package_name" >&2
	exit 1
	;;
esac
