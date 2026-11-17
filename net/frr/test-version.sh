#!/bin/sh

# shellcheck shell=busybox

# frr-pythontools ships no binary carrying FRR_VERSION; test.sh covers
# the version probes that do work.
case "$PKG_NAME" in
frr|\
frr-watchfrr|\
frr-zebra|\
frr-pythontools|\
frr-babeld|\
frr-bfdd|\
frr-bgpd|\
frr-eigrpd|\
frr-fabricd|\
frr-isisd|\
frr-ldpd|\
frr-nhrpd|\
frr-ospfd|\
frr-ospf6d|\
frr-pathd|\
frr-pbrd|\
frr-pimd|\
frr-pim6d|\
frr-ripd|\
frr-ripngd|\
frr-staticd|\
frr-vrrpd)
	exit 0
	;;
*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
