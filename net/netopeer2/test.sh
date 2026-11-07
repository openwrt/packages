#!/bin/sh

case "$1" in
	netopeer2-server)
		netopeer2-server -V | grep -F "$2"
		;;
	netopeer2-cli)
		# Interactive shell, no -V flag; only presence can be checked.
		[ -x /usr/bin/netopeer2-cli ] || {
			echo "netopeer2-cli not found" >&2
			exit 1
		}
		;;
	*)
		echo "Unsupported test target: $1" >&2
		exit 1
		;;
esac
