#!/bin/sh

# shellcheck shell=busybox

IPKG_INSTROOT=${IPKG_INSTROOT:-}
export IPKG_INSTROOT

. /lib/functions.sh
. /lib/mwan3/mwan3.sh

set -e

mwan3_init

sanitize_route()
{
	printf '%s\n' "$1" | sed -ne "$MWAN3_ROUTE_LINE_EXP"
}

expected='192.0.2.0/24 dev eth0 scope link src 192.0.2.1 '

for flags in 'dead linkdown' 'linkdown dead' 'dead' 'linkdown'; do
	actual=$(sanitize_route "$expected$flags")
	[ "$actual" = "$expected" ] || {
		echo "failed to sanitize route flags: $flags" >&2
		echo "expected: '$expected'" >&2
		echo "actual:   '$actual'" >&2
		exit 1
	}
done

ipv6_route='fd00:1::/64 via fe80::dead dev eth0 proto static metric 1024 pref medium'
actual=$(sanitize_route "$ipv6_route")
[ "$actual" = "$ipv6_route" ] || {
	echo "failed to preserve an IPv6 address ending in dead" >&2
	echo "expected: '$ipv6_route'" >&2
	echo "actual:   '$actual'" >&2
	exit 1
}

# Check that empty, missing and invalid rpcd state becomes zero.
# Numeric values must be preserved.
ucode -S "$(dirname "$0")/test-rpcd.uc"

# Delegated-source regression: no root, interface changes or Python needed.
# The full CIDR must reach ip; its selected address must retain every digit.
(
	mwan3_get_true_iface() { export "$1=$2"; }
	config_get() { export "$1=ipv6"; }
	network_get_ipaddr6() { export "$1="; }
	network_get_prefix6() { export "$1=$test_pd_prefix"; }
	network_get_device() { export "$1=pd-wan"; }
	LOG() { :; }
	mwan3_test_pd_ip()
	{
		[ "$*" = "address ls to $test_pd_prefix scope global" ] || return 1
		printf '    inet6 %s/64 scope global\n' "$test_pd_address"
	}
	IP6=mwan3_test_pd_ip
	for test_pd_prefix in '2001:db8:abcd::/56' '2001:0DB8:ABCD:0000::/56'; do
		for test_pd_digit in 7 8 9; do
			test_pd_address="2001:db8:abcd:ab::$test_pd_digit"
			mwan3_get_src_ip actual wan
			[ "$actual" = "$test_pd_address" ] || {
				echo "failed delegated source for $test_pd_prefix: '$actual'" >&2
				exit 1
			}
		done
	done
)
