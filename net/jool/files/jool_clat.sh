#!/bin/sh
#
# netifd proto helper for 464XLAT CLAT using Jool SIIT in a network namespace.

JOOL_CLAT_STATE_DIR="/var/run/jool-clat-proto"
JOOL_DEFAULT_VETH_HOST_V4="192.0.2.0/31"
JOOL_DEFAULT_VETH_NS_V4="192.0.2.1/31"

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

jool_clat_proto_log() {
	local cfg="$1"
	shift

	logger -t "jool-clat-proto[$cfg]" -- "$*"
}

jool_clat_proto_fail() {
	local cfg="$1"
	local code="$2"
	shift 2

	[ "$#" -gt 0 ] && jool_clat_proto_log "$cfg" "$*"
	proto_notify_error "$cfg" "$code"
	proto_block_restart "$cfg"
	proto_setup_failed "$cfg"
	return 1
}

jool_clat_proto_wait_linklocal() {
	local netns="$1"
	local ifname="$2"
	local addr tries=0

	while [ "$tries" -lt 5 ]; do
		if [ -n "$netns" ]; then
			addr="$(ip netns exec "$netns" ip -6 -o addr show scope link dev "$ifname" | awk '$0 !~ / tentative( |$)/ { print $4; exit }' | cut -d/ -f1)"
		else
			addr="$(ip -6 -o addr show scope link dev "$ifname" | awk '$0 !~ / tentative( |$)/ { print $4; exit }' | cut -d/ -f1)"
		fi
		[ -n "$addr" ] && {
			echo "$addr"
			return 0
		}

		tries=$((tries + 1))
		sleep 1
	done

	return 1
}

jool_clat_proto_word_count() {
	local count=0
	local word

	for word in $1; do
		count=$((count + 1))
	done

	echo "$count"
}

jool_clat_proto_run() {
	local cfg="$1"
	local message="$2"
	shift 2

	"$@" || {
		jool_clat_proto_log "$cfg" "$message"
		return 1
	}
}

jool_clat_proto_cleanup() {
	local cfg="$1"
	local veth_host_ifname="$2"
	local netns="$3"

	[ -n "$netns" ] && ip netns exec "$netns" jool_siit instance remove >/dev/null 2>&1
	[ -n "$netns" ] && ip netns del "$netns" >/dev/null 2>&1
	[ -n "$veth_host_ifname" ] && ip link del dev "$veth_host_ifname" >/dev/null 2>&1
	rm -f "$JOOL_CLAT_STATE_DIR/$cfg.state"
}

jool_clat_proto_setup_instance() {
	local cfg="$1"
	local plat_prefix="$2"
	local veth_host_v4="$3"
	local veth_ns_v4="$4"
	local veth_host_ifname="$5"
	local veth_ns_ifname="$6"
	local netns="$7"
	local clat_v4="$8"
	local clat_v6="$9"
	local state_file="${10}"
	local veth_host_v6 veth_ns_v6 veth_host_mac veth_ns_mac
	local prefix4 prefix6

	# Ref: https://blog.lingxh.com/post/464xlat/
	#      https://www.jool.mx/en/464xlat.html

	# Set up netns and veth pair.
	jool_clat_proto_run "$cfg" "failed to create namespace '$netns'" \
		ip netns add "$netns" || return 1
	jool_clat_proto_run "$cfg" "failed to create veth pair '$veth_host_ifname'/'$veth_ns_ifname'" \
		ip link add name "$veth_host_ifname" type veth peer name "$veth_ns_ifname" || return 1
	jool_clat_proto_run "$cfg" "failed to move '$veth_ns_ifname' into '$netns'" \
		ip link set dev "$veth_ns_ifname" netns "$netns" || return 1
	# Bring the host veth up now so we can learn its link-local address before
	# handing the interface to netifd.
	jool_clat_proto_run "$cfg" "failed to bring up '$veth_host_ifname'" \
		ip link set dev "$veth_host_ifname" up || return 1
	jool_clat_proto_run "$cfg" "failed to bring up loopback in '$netns'" \
		ip netns exec "$netns" ip link set dev lo up || return 1
	jool_clat_proto_run "$cfg" "failed to bring up '$veth_ns_ifname' in '$netns'" \
		ip netns exec "$netns" ip link set dev "$veth_ns_ifname" up || return 1

	veth_host_v6="$(jool_clat_proto_wait_linklocal "" "$veth_host_ifname")" || {
		jool_clat_proto_log "$cfg" "failed to discover link-local IPv6 on '$veth_host_ifname'"
		return 1
	}
	veth_ns_v6="$(jool_clat_proto_wait_linklocal "$netns" "$veth_ns_ifname")" || {
		jool_clat_proto_log "$cfg" "failed to discover link-local IPv6 on '$veth_ns_ifname'"
		return 1
	}

	veth_host_mac="$(cat "/sys/class/net/$veth_host_ifname/address")" || {
		jool_clat_proto_log "$cfg" "failed to read MAC address for '$veth_host_ifname'"
		return 1
	}
	veth_ns_mac="$(ip netns exec "$netns" cat "/sys/class/net/$veth_ns_ifname/address")" || {
		jool_clat_proto_log "$cfg" "failed to read MAC address for '$veth_ns_ifname' in '$netns'"
		return 1
	}

	# Prepopulate the namespace-side neighbor entry to avoid relying on NDP,
	# which may require extra firewall rules.
	# The host-side neighbor entry is populated later via proto_add_ipv6_neighbor.
	jool_clat_proto_run "$cfg" "failed to populate namespace neighbor entry for '$veth_host_v6'" \
		ip netns exec "$netns" ip -6 neigh replace "$veth_host_v6" lladdr "$veth_host_mac" dev "$veth_ns_ifname" nud permanent || return 1
	jool_clat_proto_run "$cfg" "failed to assign '$veth_ns_v4' to '$veth_ns_ifname'" \
		ip netns exec "$netns" ip addr add "$veth_ns_v4" dev "$veth_ns_ifname" || return 1
	# Route translated 4to6 traffic back to the host, where it is expected to be
	# routed toward the PLAT.
	jool_clat_proto_run "$cfg" "failed to install namespace default route" \
		ip netns exec "$netns" ip -6 route replace default via "$veth_host_v6" dev "$veth_ns_ifname" || return 1

	# Route translated 6to4 return traffic back to the host.
	for prefix4 in $clat_v4; do
		[ "$prefix4" = "$veth_host_v4" ] && continue
		jool_clat_proto_run "$cfg" "failed to install namespace route for '$prefix4'" \
			ip netns exec "$netns" ip route replace "$prefix4" via "${veth_host_v4%/*}" dev "$veth_ns_ifname" || return 1
	done

	jool_clat_proto_run "$cfg" "failed to enable namespace IPv4 forwarding" \
		ip netns exec "$netns" sysctl -q -w net.ipv4.conf.all.forwarding=1 || return 1
	jool_clat_proto_run "$cfg" "failed to enable namespace IPv6 forwarding" \
		ip netns exec "$netns" sysctl -q -w net.ipv6.conf.all.forwarding=1 || return 1

	jool_clat_proto_run "$cfg" "failed to create jool_siit instance in '$netns'" \
		ip netns exec "$netns" jool_siit instance add --netfilter --pool6 "$plat_prefix" || return 1

	# Prefix counts are validated earlier, so each IPv4 prefix maps to the
	# next IPv6 prefix in order.
	set -- $clat_v6
	for prefix4 in $clat_v4; do
		prefix6="$1"
		shift
		jool_clat_proto_run "$cfg" "failed to map '$prefix4' to '$prefix6'" \
			ip netns exec "$netns" jool_siit eamt add --force "$prefix4" "$prefix6" || return 1
	done

	cat >"$state_file" <<-EOF
		VETH_HOST_IFNAME='$veth_host_ifname'
		VETH_NS_IFNAME='$veth_ns_ifname'
		NETNS='$netns'
	EOF

	JOOL_CLAT_VETH_NS_V6="$veth_ns_v6"
	JOOL_CLAT_VETH_NS_MAC="$veth_ns_mac"
	return 0
}

proto_jool_clat_init_config() {
	available=1
	no_device=1

	proto_config_add_string "plat_prefix"
	proto_config_add_array "clat_v4:list(string)"
	proto_config_add_array "clat_v6:list(string)"
	proto_config_add_string "veth_host_v4"
	proto_config_add_string "veth_ns_v4"
	proto_config_add_string "veth_host_ifname"
	proto_config_add_string "veth_ns_ifname"
	proto_config_add_string "netns"
	proto_config_add_boolean "defaultroute"
	proto_config_add_int "metric"
}

proto_jool_clat_setup() {
	local cfg="$1"
	local plat_prefix veth_host_v4 veth_ns_v4 veth_host_ifname veth_ns_ifname netns defaultroute metric
	local clat_v4 clat_v6
	local prefix_count4 prefix_count6 prefix6 state_file
	local route_src=""

	json_get_vars plat_prefix veth_host_v4 veth_ns_v4 veth_host_ifname veth_ns_ifname netns defaultroute metric
	json_get_values clat_v4 clat_v4
	json_get_values clat_v6 clat_v6

	[ -n "$plat_prefix" ] || {
		jool_clat_proto_fail "$cfg" MISSING_PLAT_PREFIX "missing required option plat_prefix"
		return 1
	}
	veth_host_v4="${veth_host_v4:-$JOOL_DEFAULT_VETH_HOST_V4}"
	veth_ns_v4="${veth_ns_v4:-$JOOL_DEFAULT_VETH_NS_V4}"

	veth_host_ifname="${veth_host_ifname:-veth-$cfg}"
	veth_ns_ifname="${veth_ns_ifname:-$veth_host_ifname-peer}"
	netns="${netns:-ns-$cfg}"
	defaultroute="${defaultroute:-1}"
	route_src="${veth_host_v4%/*}"
	clat_v4="${clat_v4:-$veth_host_v4}"

	prefix_count6="$(jool_clat_proto_word_count "$clat_v6")"
	[ "$prefix_count6" -gt 0 ] || {
		jool_clat_proto_fail "$cfg" MISSING_CLAT_V6 "at least one clat_v6 is required"
		return 1
	}

	prefix_count4="$(jool_clat_proto_word_count "$clat_v4")"
	[ "$prefix_count4" -eq "$prefix_count6" ] || {
		jool_clat_proto_fail "$cfg" PREFIX_COUNT_MISMATCH "clat_v4 and clat_v6 must have the same number of entries"
		return 1
	}

	if [ -e "/sys/class/net/$veth_host_ifname" ]; then
		jool_clat_proto_fail "$cfg" HOST_IF_EXISTS "host interface '$veth_host_ifname' already exists"
		return 1
	fi
	if ip netns list | awk '{ print $1 }' | grep -Fxq "$netns"; then
		jool_clat_proto_fail "$cfg" NETNS_EXISTS "network namespace '$netns' already exists"
		return 1
	fi

	modprobe jool_siit >/dev/null 2>&1
	[ -x /usr/bin/jool_siit ] || {
		jool_clat_proto_fail "$cfg" MISSING_BINARY "missing /usr/bin/jool_siit"
		return 1
	}

	mkdir -p "$JOOL_CLAT_STATE_DIR" || {
		jool_clat_proto_fail "$cfg" STATE_DIR_FAILED "failed to create $JOOL_CLAT_STATE_DIR"
		return 1
	}
	state_file="$JOOL_CLAT_STATE_DIR/$cfg.state"

	jool_clat_proto_setup_instance \
		"$cfg" "$plat_prefix" "$veth_host_v4" "$veth_ns_v4" "$veth_host_ifname" "$veth_ns_ifname" \
		"$netns" "$clat_v4" "$clat_v6" "$state_file" || {
		jool_clat_proto_cleanup "$cfg" "$veth_host_ifname" "$netns"
		jool_clat_proto_fail "$cfg" SETUP_FAILED "setup failed; see logread for details"
		return 1
	}

	proto_init_update "$veth_host_ifname" 1
	proto_add_ipv4_address "${veth_host_v4%/*}" 31
	[ "$defaultroute" = 0 ] || proto_add_ipv4_route "0.0.0.0" 0 "${veth_ns_v4%/*}" "$route_src" "$metric"
	proto_add_ipv6_neighbor "$JOOL_CLAT_VETH_NS_V6" "$JOOL_CLAT_VETH_NS_MAC"

	for prefix6 in $clat_v6; do
		proto_add_ipv6_route "${prefix6%/*}" "${prefix6#*/}" "$JOOL_CLAT_VETH_NS_V6"
	done

	proto_send_update "$cfg"
}

proto_jool_clat_teardown() {
	local cfg="$1"
	local veth_host_ifname veth_ns_ifname netns state_file

	state_file="$JOOL_CLAT_STATE_DIR/$cfg.state"
	if [ -f "$state_file" ]; then
		. "$state_file"
		veth_host_ifname="$VETH_HOST_IFNAME"
		veth_ns_ifname="$VETH_NS_IFNAME"
		netns="$NETNS"
	else
		json_get_vars veth_host_ifname veth_ns_ifname netns
		veth_host_ifname="${veth_host_ifname:-veth-$cfg}"
		veth_ns_ifname="${veth_ns_ifname:-$veth_host_ifname-peer}"
		netns="${netns:-ns-$cfg}"
	fi

	jool_clat_proto_cleanup "$cfg" "$veth_host_ifname" "$netns"
}

[ -n "$INCLUDE_ONLY" ] || {
	add_protocol jool_clat
}
