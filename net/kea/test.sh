#!/bin/sh

set -e

# kea's `-t` validator requires the control-socket parent dir (mirrors kea.init).
mkdir -p -m 0750 /var/run/kea

case "$1" in
kea-dhcp4)
	# Validate the shipped DHCPv4 config; the QEMU mips netlink path
	# aborts after parsing succeeds, so tolerate that exact signature.
	if ! out=$(kea-dhcp4 -t /etc/kea/kea-dhcp4.conf 2>&1); then
		case "$out" in
		*"Failed to parse RTATTR in netlink message"*) ;;
		*) printf '%s\n' "$out" >&2; exit 1 ;;
		esac
	fi
	;;

kea-dhcp6)
	# Same as kea-dhcp4 but for the DHCPv6 server config / parser;
	# same QEMU netlink caveat applies.
	if ! out=$(kea-dhcp6 -t /etc/kea/kea-dhcp6.conf 2>&1); then
		case "$out" in
		*"Failed to parse RTATTR in netlink message"*) ;;
		*) printf '%s\n' "$out" >&2; exit 1 ;;
		esac
	fi
	;;

kea-dhcp-ddns)
	# Validate the shipped DDNS config; exercises the D2 parser
	# and its TSIG / DNS-update library closure.
	kea-dhcp-ddns -t /etc/kea/kea-dhcp-ddns.conf
	;;

kea-ctrl)
	# Exercise the keactrl wrapper.
	keactrl -v >/dev/null
	;;

kea-admin)
	# kea-admin sources admin-utils.sh before usage(); --help proves
	# both the script and helper are packaged. -h is reserved in 3.0.x.
	kea-admin --help >/dev/null
	;;

kea-shell)
	# Python wrapper that imports kea_conn / kea_connector3; --help
	# exercises the interpreter, path rewrite and module imports.
	kea-shell --help >/dev/null
	;;

kea-lfc)
	# Exercise kea-lfc's argv parser and its libkea-util / libstdc++
	# runtime closure.
	kea-lfc -h >/dev/null
	;;

kea-perfdhcp)
	# Exercise perfdhcp's argv parser; loads the libkea-dhcp / asio
	# runtime closure used by every kea binary.
	perfdhcp -h >/dev/null
	;;

kea-dhcp4-helper)
	# Pure shell script under /usr/lib/kea/importers/; confirm it
	# was packaged and is executable.
	test -x /usr/lib/kea/importers/dhcp4.sh
	;;

kea-hook-ha)
	# Hook is a .so loaded by kea-dhcp{4,6}; confirm it was packaged.
	# Generic ELF / SONAME checks cover its dynamic linkage.
	test -f /usr/lib/kea/hooks/libdhcp_ha.so
	;;

kea-hook-lease-cmds)
	# Same shape as kea-hook-ha.
	test -f /usr/lib/kea/hooks/libdhcp_lease_cmds.so
	;;

kea-uci)
	# UCI integration: config defaults + init script. Confirm both
	# were packaged at the expected paths.
	test -f /etc/config/kea
	test -x /etc/init.d/kea
	;;

kea-libs)
	# Pure shared-library subpackage; the generic ELF / SONAME /
	# linked-libraries checks already cover it.
	;;

*)
	echo "test.sh: unknown subpackage '$1' — refusing to silently pass" >&2
	echo "test.sh: update net/kea/test.sh to cover this subpackage" >&2
	exit 1
	;;
esac
