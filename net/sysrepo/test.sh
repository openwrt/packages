#!/bin/sh

case "$1" in
	libsysrepo)
		[ -e /usr/lib/libsysrepo.so ] || {
			echo "libsysrepo.so not found" >&2
			exit 1
		}
		[ -e /usr/lib/libsysrepo.so.8 ] || {
			echo "libsysrepo.so.8 not found" >&2
			exit 1
		}
		;;
	sysrepo)
		[ -x /usr/bin/sysrepo-plugind ] || {
			echo "sysrepo-plugind not found" >&2
			exit 1
		}
		;;
	sysrepoctl)
		sysrepoctl --version | grep -F "$2"
		;;
	sysrepocfg)
		sysrepocfg --version | grep -F "$2"
		;;
	*)
		echo "Unsupported test target: $1" >&2
		exit 1
		;;
esac
