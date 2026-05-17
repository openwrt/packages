#!/bin/sh

# shellckeck shell=busybox

_version_check() {
	local bin="$1" pkg="$2" ver="$3"
	# apk versions use _ where upstream uses - (e.g. 0.9_rc4 vs 0.9-rc4)
	local upstream_ver
	upstream_ver=$(echo "$ver" | tr '_' '-')
	"$bin" -V 2>&1 | grep -F "$upstream_ver" || {
		echo "FAIL: $bin -V did not print expected version '$upstream_ver'"
		exit 1
	}
}

case "$PKG_NAME" in
avahi-autoipd)
	_version_check avahi-autoipd avahi-autoipd "$PKG_VERSION"
	;;

avahi-dbus-daemon|\
avahi-nodbus-daemon)
	_version_check avahi-daemon avahi-daemon "$PKG_VERSION"
	;;

avahi-dnsconfd)
	_version_check avahi-dnsconfd avahi-dnsconfd "$PKG_VERSION"
	;;

avahi-daemon-service-http|\
avahi-daemon-service-ssh|\
avahi-utils|\
libavahi-client|\
libavahi-dbus-support|\
libavahi-nodbus-support)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
