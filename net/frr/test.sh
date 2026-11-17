#!/bin/sh

case "$1" in
	frr)
		[ -x /usr/bin/vtysh ] || {
			echo "vtysh not found" >&2
			exit 1
		}
		[ -e /usr/lib/libfrr.so ] || {
			echo "libfrr.so not found" >&2
			exit 1
		}
		# vtysh has no --version; the release shows up in --help.
		vtysh --help 2>&1 | grep -F "$2"
		;;
	frr-watchfrr)
		[ -x /usr/sbin/watchfrr ] || {
			echo "watchfrr not found" >&2
			exit 1
		}
		;;
	frr-zebra)
		[ -x /usr/sbin/zebra ] || {
			echo "zebra not found" >&2
			exit 1
		}
		;;
	frr-babeld|frr-bfdd|frr-bgpd|frr-eigrpd|frr-fabricd|frr-isisd|\
	frr-ldpd|frr-nhrpd|frr-ospfd|frr-ospf6d|frr-pathd|frr-pbrd|\
	frr-pimd|frr-pim6d|frr-ripd|frr-ripngd|frr-staticd|frr-vrrpd)
		_daemon=${1#frr-}
		[ -x "/usr/sbin/${_daemon}" ] || {
			echo "${_daemon} not found" >&2
			exit 1
		}
		;;
	frr-pythontools)
		[ -x /usr/sbin/frr-reload ] || {
			echo "frr-reload not found" >&2
			exit 1
		}
		;;
	*)
		echo "Unsupported test target: $1" >&2
		exit 1
		;;
esac
