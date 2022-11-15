#!/bin/sh
# BCP38 filtering implementation for CeroWrt.
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Author: Toke Høiland-Jørgensen <toke@toke.dk>

STOP=$1

TABLE=bcp38
FAMILY=ip
MATCHSET=bcp38-match
NOMATCHSET=bcp38-nomatch
CHAIN=bcp38

. /lib/functions.sh

config_load bcp38

add_bcp38_rule()
{
	local subnet="$1"
	local action="$2"

	setname="$MATCHSET"
	[ "$action" == "nomatch" ] && setname="$NOMATCHSET"
	nft add element "$FAMILY" "$TABLE" "$setname" { "$subnet" }
}

detect_upstream_subnet()
{
	local interface="$1"

	subnets=$(ip route show dev "$interface"  | grep 'scope link' | awk '{print $1}')
	for subnet in $subnets; do
		#test for that; add as exception if there's a match
		nft get element "$FAMILY" "$TABLE" "$MATCHSET" { $subnet } >/dev/null 2>/dev/null && add_bcp38_rule $subnet nomatch
	done
}

run() {
	local section="$1"
	local enabled
	local interface
	local priority
	local detect_upstream
	config_get_bool enabled "$section" enabled 0
	config_get interface "$section" interface
	config_get detect_upstream "$section" detect_upstream
	config_get priority "$section" priority "2"

	if [ "$enabled" -eq "1" -a -n "$interface" -a -z "$STOP" ] ; then
		setup_table
		setup_sets
		setup_chains "$interface" "$priority"
		config_list_foreach "$section" match add_bcp38_rule match
		config_list_foreach "$section" nomatch add_bcp38_rule nomatch
		[ "$detect_upstream" -eq "1" ] && detect_upstream_subnet "$interface"
	fi
	exit 0
}

setup_table()
{
	nft add table "$FAMILY" "$TABLE"
}

setup_sets()
{
	#create and flush sets
	nft add set "$FAMILY" "$TABLE" "$MATCHSET" '{ type ipv4_addr; flags interval; }'
	nft flush set "$FAMILY" "$TABLE" "$MATCHSET"
	nft add set "$FAMILY" "$TABLE" "$NOMATCHSET" '{ type ipv4_addr; flags interval; }'
	nft flush set "$FAMILY" "$TABLE" "$NOMATCHSET"
}

setup_chains()
{
	local interface="$1"
	local priority="$2"

	nft add chain "$FAMILY" "$TABLE" "$CHAIN" 2>/dev/null
	nft flush chain "$FAMILY" "$TABLE" "$CHAIN" 2>/dev/null

	nft add rule "$FAMILY" "$TABLE" "$CHAIN" udp dport {67,68} udp sport {67,68} counter return comment \"always accept DHCP traffic\"
	nft add rule "$FAMILY" "$TABLE" "$CHAIN" oifname $interface ip daddr @"$MATCHSET" ip daddr != @"$NOMATCHSET" counter reject with icmp type host-unreachable
	nft add rule "$FAMILY" "$TABLE" "$CHAIN" iifname $interface ip saddr @"$MATCHSET" ip saddr != @"$NOMATCHSET" counter drop

	nft add chain "$FAMILY" "$TABLE" input "{ type filter hook input priority $priority; policy accept; comment \"bcp38 filter\"; }"
	nft add chain "$FAMILY" "$TABLE" forward "{ type filter hook forward priority $priority; policy accept; comment \"bcp38 filter\"; }"
	nft add chain "$FAMILY" "$TABLE" output "{ type filter hook output priority $priority; policy accept; comment \"bcp38 filter\"; }"

	nft insert rule "$FAMILY" "$TABLE" input ct state new jump "$CHAIN"
	nft insert rule "$FAMILY" "$TABLE" forward ct state new jump "$CHAIN"
	nft insert rule "$FAMILY" "$TABLE" output ct state new jump "$CHAIN"
}

destroy_table()
{
	if [ "$TABLE" != "fw4" ]; then
		#as of kernel 3.18 we can delete a table without need to flush it
		nft delete table "$FAMILY" "$TABLE" 2>/dev/null
	fi
}

destroy_table
config_foreach run bcp38

exit 0
