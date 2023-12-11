#!/bin/sh

. "${IPKG_INSTROOT}/usr/share/libubox/jshn.sh"
. "${IPKG_INSTROOT}/lib/mwan3/common.sh"

CONNTRACK_FILE="/proc/net/nf_conntrack"
IPv6_REGEX="([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|"
IPv6_REGEX="${IPv6_REGEX}([0-9a-fA-F]{1,4}:){1,7}:|"
IPv6_REGEX="${IPv6_REGEX}([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|"
IPv6_REGEX="${IPv6_REGEX}([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|"
IPv6_REGEX="${IPv6_REGEX}([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|"
IPv6_REGEX="${IPv6_REGEX}([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|"
IPv6_REGEX="${IPv6_REGEX}([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|"
IPv6_REGEX="${IPv6_REGEX}[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|"
IPv6_REGEX="${IPv6_REGEX}:((:[0-9a-fA-F]{1,4}){1,7}|:)|"
IPv6_REGEX="${IPv6_REGEX}fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|"
IPv6_REGEX="${IPv6_REGEX}::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|"
IPv6_REGEX="${IPv6_REGEX}([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])"
IPv4_REGEX="((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"

DEFAULT_LOWEST_METRIC=256

mwan3_push_update()
{
	# helper function to build an update string to pass on to
	# IPTR or IPS RESTORE. Modifies the 'update' variable in
	# the local scope.
	update="$update"$'\n'"$*";
}

mwan3_update_dev_to_table()
{
	local _tid
	# shellcheck disable=SC2034
	mwan3_dev_tbl_ipv4=" "
	# shellcheck disable=SC2034
	mwan3_dev_tbl_ipv6=" "

	update_table()
	{
		local family curr_table device enabled
		let _tid++
		config_get family "$1" family ipv4
		network_get_device device "$1"
		[ -z "$device" ] && return
		config_get enabled "$1" enabled
		[ "$enabled" -eq 0 ] && return
		curr_table=$(eval "echo	 \"\$mwan3_dev_tbl_${family}\"")
		export "mwan3_dev_tbl_$family=${curr_table}${device}=$_tid "
	}
	network_flush_cache
	config_foreach update_table interface
}

mwan3_update_iface_to_table()
{
	local _tid
	mwan3_iface_tbl=" "
	update_table()
	{
		let _tid++
		export mwan3_iface_tbl="${mwan3_iface_tbl}${1}=$_tid "
	}
	config_foreach update_table interface
}

mwan3_route_line_dev()
{
	# must have mwan3 config already loaded
	# arg 1 is route device
	local _tid route_line route_device route_family entry curr_table
	route_line=$2
	route_family=$3
	route_device=$(echo "$route_line" | sed -ne "s/.*dev \([^ ]*\).*/\1/p")
	unset "$1"
	[ -z "$route_device" ] && return

	curr_table=$(eval "echo \"\$mwan3_dev_tbl_${route_family}\"")
	for entry in $curr_table; do
		if [ "${entry%%=*}" = "$route_device" ]; then
			_tid=${entry##*=}
			export "$1=$_tid"
			return
		fi
	done
}

# counts how many bits are set to 1
# n&(n-1) clears the lowest bit set to 1
mwan3_count_one_bits()
{
	local count n
	count=0
	n=$(($1))
	while [ "$n" -gt "0" ]; do
		n=$((n&(n-1)))
		count=$((count+1))
	done
	echo $count
}

mwan3_get_iface_id()
{
	local _tmp
	[ -z "$mwan3_iface_tbl" ] && mwan3_update_iface_to_table
	_tmp="${mwan3_iface_tbl##* ${2}=}"
	_tmp=${_tmp%% *}
	export "$1=$_tmp"
}

mwan3_set_custom_ipset_v4()
{
	local custom_network_v4

	for custom_network_v4 in $($IP4 route list table "$1" | awk '{print $1}' | grep -E "$IPv4_REGEX"); do
		LOG notice "Adding network $custom_network_v4 from table $1 to mwan3_custom_v4 ipset"
		mwan3_push_update -! add mwan3_custom_ipv4 "$custom_network_v4"
	done
}

mwan3_set_custom_ipset_v6()
{
	local custom_network_v6

	for custom_network_v6 in $($IP6 route list table "$1" | awk '{print $1}' | grep -E "$IPv6_REGEX"); do
		LOG notice "Adding network $custom_network_v6 from table $1 to mwan3_custom_v6 ipset"
		mwan3_push_update -! add mwan3_custom_ipv6 "$custom_network_v6"
	done
}

mwan3_set_custom_ipset()
{
	local update=""

	mwan3_push_update -! create mwan3_custom_ipv4 hash:net
	mwan3_push_update flush mwan3_custom_ipv4
	config_list_foreach "globals" "rt_table_lookup" mwan3_set_custom_ipset_v4

	if [ $NO_IPV6 -eq 0 ]; then
		mwan3_push_update -! create mwan3_custom_ipv6 hash:net family inet6
		mwan3_push_update flush mwan3_custom_ipv6
		config_list_foreach "globals" "rt_table_lookup" mwan3_set_custom_ipset_v6
	fi

	echo "$update" > "${MWAN3_STATUS_IPTABLES_LOG_DIR}/ipset-set_custom_ipset.dump"
	error=$(echo "$update" | $IPS restore 2>&1) || LOG error "set_custom_ipset: $error"
}


mwan3_set_connected_ipv4()
{
	local connected_network_v4 error
	local candidate_list cidr_list
	local update=""

	mwan3_push_update -! create mwan3_connected_ipv4 hash:net
	mwan3_push_update flush mwan3_connected_ipv4

	candidate_list=""
	cidr_list=""
	route_lists()
	{
		$IP4 route | awk '{print $1}'
		$IP4 route list table 0 | awk '{print $2}'
	}
	for connected_network_v4 in $(route_lists | grep -E "$IPv4_REGEX"); do
		if [ -z "${connected_network_v4##*/*}" ]; then
			cidr_list="$cidr_list $connected_network_v4"
		else
			candidate_list="$candidate_list $connected_network_v4"
		fi
	done

	for connected_network_v4 in $cidr_list; do
		mwan3_push_update -! add mwan3_connected_ipv4 "$connected_network_v4"
	done
	for connected_network_v4 in $candidate_list; do
		mwan3_push_update -! add mwan3_connected_ipv4 "$connected_network_v4"
	done

	mwan3_push_update add mwan3_connected_ipv4 224.0.0.0/3

	echo "$update" > "${MWAN3_STATUS_IPTABLES_LOG_DIR}/ipset-set_connected_ipv4.dump"
	error=$(echo "$update" | $IPS restore 2>&1) || LOG error "set_connected_ipv4: $error"
}

mwan3_set_connected_ipv6()
{
	local connected_network_v6 error
	local update=""
	[ $NO_IPV6 -eq 0 ] || return

	mwan3_push_update -! create mwan3_connected_ipv6 hash:net family inet6
	mwan3_push_update flush mwan3_connected_ipv6

	for connected_network_v6 in $($IP6 route | awk '{print $1}' | grep -E "$IPv6_REGEX"); do
		mwan3_push_update -! add mwan3_connected_ipv6 "$connected_network_v6"
	done

	echo "$update" > "${MWAN3_STATUS_IPTABLES_LOG_DIR}/ipset-set_connected_ipv6.dump"
	error=$(echo "$update" | $IPS restore 2>&1) || LOG error "set_connected_ipv6: $error"
}

mwan3_set_connected_ipset()
{
	local error
	local update=""

	mwan3_push_update -! create mwan3_connected_ipv4 hash:net
	mwan3_push_update flush mwan3_connected_ipv4

	if [ $NO_IPV6 -eq 0 ]; then
		mwan3_push_update -! create mwan3_connected_ipv6 hash:net family inet6
		mwan3_push_update flush mwan3_connected_ipv6
	fi

	echo "$update" > "${MWAN3_STATUS_IPTABLES_LOG_DIR}/ipset-set_connected_ipset.dump"
	error=$(echo "$update" | $IPS restore 2>&1) || LOG error "set_connected_ipset: $error"
}

mwan3_set_dynamic_ipset()
{
	local error
	local update=""

	mwan3_push_update -! create mwan3_dynamic_ipv4 list:set
	mwan3_push_update flush mwan3_dynamic_ipv4

	if [ $NO_IPV6 -eq 0 ]; then
		mwan3_push_update -! create mwan3_dynamic_ipv6 hash:net family inet6
		mwan3_push_update flush mwan3_dynamic_ipv6
	fi

	echo "$update" > "${MWAN3_STATUS_IPTABLES_LOG_DIR}/ipset-set_dynamic_ipset.dump"
	error=$(echo "$update" | $IPS restore 2>&1) || LOG error "set_dynamic_ipset: $error"
}

mwan3_set_general_rules()
{
	local IP

	for IP in "$IP4" "$IP6"; do
		[ "$IP" = "$IP6" ] && [ $NO_IPV6 -ne 0 ] && continue
		RULE_NO=$((MM_BLACKHOLE+2000))
		if [ -z "$($IP rule list | awk -v var="$RULE_NO:" '$1 == var')" ]; then
			$IP rule add pref $RULE_NO fwmark $MMX_BLACKHOLE/$MMX_MASK blackhole
		fi

		RULE_NO=$((MM_UNREACHABLE+2000))
		if [ -z "$($IP rule list | awk -v var="$RULE_NO:" '$1 == var')" ]; then
			$IP rule add pref $RULE_NO fwmark $MMX_UNREACHABLE/$MMX_MASK unreachable
		fi
	done
}

mwan3_set_general_iptables()
{
	local IPT current update error family

	for IPT in "$IPT4" "$IPT6"; do
		[ "$IPT" = "$IPT6" ] && [ $NO_IPV6 -ne 0 ] && continue
		current="$($IPT -S)"$'\n'
		update="*mangle"
		if [ -n "${current##*-N mwan3_ifaces_in*}" ]; then
			mwan3_push_update -N mwan3_ifaces_in
		fi

		if [ "$IPT" = "$IPT6" ]; then
			family="ipv6"
		else
			family="ipv4"
		fi

		for chain in custom connected dynamic; do
			echo "${current}" | grep -q "\-N mwan3_${chain}_${family}$"
			local ret="$?"
			if [ "$ret" = 1 ]; then
				mwan3_push_update -N mwan3_${chain}_${family}
				mwan3_push_update -A mwan3_${chain}_${family} \
					-m set --match-set mwan3_${chain}_${family} dst \
					-j MARK --set-xmark $MMX_DEFAULT/$MMX_MASK
			fi
		done

		if [ -n "${current##*-N mwan3_rules*}" ]; then
			mwan3_push_update -N mwan3_rules
		fi

		if [ -n "${current##*-N mwan3_hook*}" ]; then
			mwan3_push_update -N mwan3_hook
			# do not mangle ipv6 ra service
			if [ "$IPT" = "$IPT6" ]; then
				mwan3_push_update -A mwan3_hook \
						  -p ipv6-icmp \
						  -m icmp6 --icmpv6-type 133 \
						  -j RETURN
				mwan3_push_update -A mwan3_hook \
						  -p ipv6-icmp \
						  -m icmp6 --icmpv6-type 134 \
						  -j RETURN
				mwan3_push_update -A mwan3_hook \
						  -p ipv6-icmp \
						  -m icmp6 --icmpv6-type 135 \
						  -j RETURN
				mwan3_push_update -A mwan3_hook \
						  -p ipv6-icmp \
						  -m icmp6 --icmpv6-type 136 \
						  -j RETURN
				mwan3_push_update -A mwan3_hook \
						  -p ipv6-icmp \
						  -m icmp6 --icmpv6-type 137 \
						  -j RETURN

			fi
			mwan3_push_update -A mwan3_hook \
					  -m mark --mark 0x0/$MMX_MASK \
					  -j CONNMARK --restore-mark --nfmask "$MMX_MASK" --ctmask "$MMX_MASK"
			mwan3_push_update -A mwan3_hook \
					  -m mark --mark 0x0/$MMX_MASK \
					  -j mwan3_ifaces_in

			for chain in custom connected dynamic; do
				mwan3_push_update -A mwan3_hook \
					-m mark --mark 0x0/$MMX_MASK \
					-j mwan3_${chain}_${family}
			done

			mwan3_push_update -A mwan3_hook \
					  -m mark --mark 0x0/$MMX_MASK \
					  -j mwan3_rules
			mwan3_push_update -A mwan3_hook \
					  -j CONNMARK --save-mark --nfmask "$MMX_MASK" --ctmask "$MMX_MASK"

			for chain in custom connected dynamic; do
				mwan3_push_update -A mwan3_hook \
					-m mark ! --mark $MMX_DEFAULT/$MMX_MASK \
					-j mwan3_${chain}_${family}
			done
		fi

		if [ -n "${current##*-A PREROUTING -j mwan3_hook*}" ]; then
			mwan3_push_update -A PREROUTING -j mwan3_hook
		fi
		if [ -n "${current##*-A OUTPUT -j mwan3_hook*}" ]; then
			mwan3_push_update -A OUTPUT -j mwan3_hook
		fi
		mwan3_push_update COMMIT
		mwan3_push_update ""

		echo "$update" > "${MWAN3_STATUS_IPTABLES_LOG_DIR}/iptables-set_general_iptables-${family}.dump"
		if [ "$IPT" = "$IPT4" ]; then
			error=$(echo "$update" | $IPT4R 2>&1) || LOG error "set_general_iptables (${family}): $error"
		else
			error=$(echo "$update" | $IPT6R 2>&1) || LOG error "set_general_iptables (${family}): $error"
		fi
	done
}

mwan3_create_iface_iptables()
{
	local id family IPT IPTR current update error

	config_get family "$1" family ipv4
	mwan3_get_iface_id id "$1"

	[ -n "$id" ] || return 0

	if [ "$family" = "ipv4" ]; then
		IPT="$IPT4"
		IPTR="$IPT4R"
	elif [ "$family" = "ipv6" ] && [ $NO_IPV6 -eq 0 ]; then
		IPT="$IPT6"
		IPTR="$IPT6R"
	else
		return
	fi

	current="$($IPT -S)"$'\n'
	update="*mangle"
	if [ -n "${current##*-N mwan3_ifaces_in*}" ]; then
		mwan3_push_update -N mwan3_ifaces_in
	fi

	if [ -n "${current##*-N mwan3_iface_in_$1$'\n'*}" ]; then
		mwan3_push_update -N "mwan3_iface_in_$1"
	else
		mwan3_push_update -F "mwan3_iface_in_$1"
	fi

	for chain in custom connected dynamic; do
		mwan3_push_update -A "mwan3_iface_in_$1" \
			-i "$2" \
			-m set --match-set mwan3_${chain}_${family} src \
			-m mark --mark "0x0/$MMX_MASK" \
			-m comment --comment "default" \
			-j MARK --set-xmark "$MMX_DEFAULT/$MMX_MASK"
	done
	mwan3_push_update -A "mwan3_iface_in_$1" \
			  -i "$2" \
			  -m mark --mark "0x0/$MMX_MASK" \
			  -m comment --comment "$1" \
			  -j MARK --set-xmark "$(mwan3_id2mask id MMX_MASK)/$MMX_MASK"

	if [ -n "${current##*-A mwan3_ifaces_in -m mark --mark 0x0/$MMX_MASK -j mwan3_iface_in_${1}$'\n'*}" ]; then
		mwan3_push_update -A mwan3_ifaces_in \
				  -m mark --mark 0x0/$MMX_MASK \
				  -j "mwan3_iface_in_$1"
		LOG debug "create_iface_iptables: mwan3_iface_in_$1 not in iptables, adding"
	else
		LOG debug "create_iface_iptables: mwan3_iface_in_$1 already in iptables, skip"
	fi

	mwan3_push_update COMMIT
	mwan3_push_update ""

	echo "$update" > "${MWAN3_STATUS_IPTABLES_LOG_DIR}/iptables-create_iface_iptables-${1}.dump"
	error=$(echo "$update" | $IPTR 2>&1) || LOG error "create_iface_iptables (${1}): $error"
}

mwan3_delete_iface_iptables()
{
	local IPT update
	config_get family "$1" family ipv4

	if [ "$family" = "ipv4" ]; then
		IPT="$IPT4"
	fi

	if [ "$family" = "ipv6" ]; then
		[ $NO_IPV6 -ne 0 ] && return
		IPT="$IPT6"
	fi

	update="*mangle"

	mwan3_push_update -D mwan3_ifaces_in \
		-m mark --mark 0x0/$MMX_MASK \
		-j "mwan3_iface_in_$1" &> /dev/null
	mwan3_push_update -F "mwan3_iface_in_$1" &> /dev/null
	mwan3_push_update -X "mwan3_iface_in_$1" &> /dev/null

	mwan3_push_update COMMIT
	mwan3_push_update ""

	echo "$update" > "${MWAN3_STATUS_IPTABLES_LOG_DIR}/iptables-delete_iface_iptables-${1}.dump"
	error=$(echo "$update" | $IPTR 2>&1) || LOG error "delete_iface_iptables (${1}): $error"
}

mwan3_extra_tables_routes()
{
	$IP route list table "$1"
}

mwan3_get_routes()
{
	{
		$IP route list table main
		config_list_foreach "globals" "rt_table_lookup" mwan3_extra_tables_routes
	} | sed -ne "$MWAN3_ROUTE_LINE_EXP" | sort -u
}

mwan3_create_iface_route()
{
	local tid route_line family IP id tbl
	config_get family "$1" family ipv4
	mwan3_get_iface_id id "$1"

	[ -n "$id" ] || return 0

	if [ "$family" = "ipv4" ]; then
		IP="$IP4"
	elif [ "$family" = "ipv6" ]; then
		IP="$IP6"
	fi

	tbl=$($IP route list table $id 2>/dev/null)$'\n'
	mwan3_update_dev_to_table
	mwan3_get_routes | while read -r route_line; do
		mwan3_route_line_dev "tid" "$route_line" "$family"
		{ [ -z "${route_line##default*}" ] || [ -z "${route_line##fe80::/64*}" ]; } && [ "$tid" != "$id" ] && continue
		if [ -z "$tid" ] || [ "$tid" = "$id" ]; then
			# possible that routes are already in the table
			# if 'connected' was called after 'ifup'
			[ -n "$tbl" ] && [ -z "${tbl##*$route_line$'\n'*}" ] && continue
			$IP route add table $id $route_line ||
				LOG debug "Route '$route_line' already added to table $id"
		fi

	done
}

mwan3_delete_iface_route()
{
	local id family

	config_get family "$1" family ipv4
	mwan3_get_iface_id id "$1"

	if [ -z "$id" ]; then
		LOG warn "delete_iface_route: could not find table id for interface $1"
		return 0
	fi

	if [ "$family" = "ipv4" ]; then
		$IP4 route flush table "$id"
	elif [ "$family" = "ipv6" ] && [ $NO_IPV6 -eq 0 ]; then
		$IP6 route flush table "$id"
	fi
}

mwan3_create_iface_rules()
{
	local id family IP

	config_get family "$1" family ipv4
	mwan3_get_iface_id id "$1"

	[ -n "$id" ] || return 0

	if [ "$family" = "ipv4" ]; then
		IP="$IP4"
	elif [ "$family" = "ipv6" ] && [ $NO_IPV6 -eq 0 ]; then
		IP="$IP6"
	else
		return
	fi

	mwan3_delete_iface_rules "$1"

	$IP rule add pref $((id+1000)) iif "$2" lookup "$id"
	$IP rule add pref $((id+2000)) fwmark "$(mwan3_id2mask id MMX_MASK)/$MMX_MASK" lookup "$id"
	$IP rule add pref $((id+3000)) fwmark "$(mwan3_id2mask id MMX_MASK)/$MMX_MASK" unreachable
}

mwan3_delete_iface_rules()
{
	local id family IP rule_id

	config_get family "$1" family ipv4
	mwan3_get_iface_id id "$1"

	[ -n "$id" ] || return 0

	if [ "$family" = "ipv4" ]; then
		IP="$IP4"
	elif [ "$family" = "ipv6" ] && [ $NO_IPV6 -eq 0 ]; then
		IP="$IP6"
	else
		return
	fi

	for rule_id in $(ip rule list | awk '$1 % 1000 == '$id' && $1 > 1000 && $1 < 4000 {print substr($1,0,4)}'); do
		$IP rule del pref $rule_id
	done
}

mwan3_delete_iface_ipset_entries()
{
	local id setname entry

	mwan3_get_iface_id id "$1"

	[ -n "$id" ] || return 0

	for setname in $(ipset -n list | grep ^mwan3_rule_); do
		for entry in $(ipset list "$setname" | grep "$(mwan3_id2mask id MMX_MASK | awk '{ printf "0x%08x", $1; }')" | cut -d ' ' -f 1); do
			$IPS del "$setname" $entry ||
				LOG notice "failed to delete $entry from $setname"
		done
	done
}


mwan3_set_policy()
{
	local id iface family metric probability weight device is_lowest is_offline IPT IPTR total_weight current update error

	is_lowest=0
	config_get iface "$1" interface
	config_get metric "$1" metric 1
	config_get weight "$1" weight 1

	[ -n "$iface" ] || return 0
	network_get_device device "$iface"
	[ "$metric" -gt $DEFAULT_LOWEST_METRIC ] && LOG warn "Member interface $iface has >$DEFAULT_LOWEST_METRIC metric. Not appending to policy" && return 0

	mwan3_get_iface_id id "$iface"

	[ -n "$id" ] || return 0

	[ "$(mwan3_get_iface_hotplug_state "$iface")" = "online" ]
	is_offline=$?

	config_get family "$iface" family ipv4

	if [ "$family" = "ipv4" ]; then
		IPT="$IPT4"
		IPTR="$IPT4R"
	elif [ "$family" = "ipv6" ]; then
		IPT="$IPT6"
		IPTR="$IPT6R"
	fi
	current="$($IPT -S)"$'\n'
	update="*mangle"

	if [ "$family" = "ipv4" ] && [ $is_offline -eq 0 ]; then
		if [ "$metric" -lt "$lowest_metric_v4" ]; then
			is_lowest=1
			total_weight_v4=$weight
			lowest_metric_v4=$metric
		elif [ "$metric" -eq "$lowest_metric_v4" ]; then
			total_weight_v4=$((total_weight_v4+weight))
			total_weight=$total_weight_v4
		else
			return
		fi
	elif [ "$family" = "ipv6" ] && [ $NO_IPV6 -eq 0 ] && [ $is_offline -eq 0 ]; then
		if [ "$metric" -lt "$lowest_metric_v6" ]; then
			is_lowest=1
			total_weight_v6=$weight
			lowest_metric_v6=$metric
		elif [ "$metric" -eq "$lowest_metric_v6" ]; then
			total_weight_v6=$((total_weight_v6+weight))
			total_weight=$total_weight_v6
		else
			return
		fi
	fi
	if [ $is_lowest -eq 1 ]; then
		mwan3_push_update -F "mwan3_policy_$policy"
		mwan3_push_update -A "mwan3_policy_$policy" \
				  -m mark --mark 0x0/$MMX_MASK \
				  -m comment --comment \"$iface $weight $weight\" \
				  -j MARK --set-xmark "$(mwan3_id2mask id MMX_MASK)/$MMX_MASK"
	elif [ $is_offline -eq 0 ]; then
		probability=$((weight*1000/total_weight))
		if [ "$probability" -lt 10 ]; then
			probability="0.00$probability"
		elif [ $probability -lt 100 ]; then
			probability="0.0$probability"
		elif [ $probability -lt 1000 ]; then
			probability="0.$probability"
		else
			probability="1"
		fi

		mwan3_push_update -I "mwan3_policy_$policy" \
				  -m mark --mark 0x0/$MMX_MASK \
				  -m statistic \
				  --mode random \
				  --probability "$probability" \
				  -m comment --comment \"$iface $weight $total_weight\" \
				  -j MARK --set-xmark "$(mwan3_id2mask id MMX_MASK)/$MMX_MASK"
	elif [ -n "$device" ]; then
		echo "$current" | grep -q "^-A mwan3_policy_$policy.*--comment .* [0-9]* [0-9]*" ||
			mwan3_push_update -I "mwan3_policy_$policy" \
					  -o "$device" \
					  -m mark --mark 0x0/$MMX_MASK \
					  -m comment --comment \"out $iface $device\" \
					  -j MARK --set-xmark $MMX_DEFAULT/$MMX_MASK
	fi
	mwan3_push_update COMMIT
	mwan3_push_update ""

	echo "$update" > "${MWAN3_STATUS_IPTABLES_LOG_DIR}/iptables-set_policy-${1}.dump"
	error=$(echo "$update" | $IPTR 2>&1) || LOG error "set_policy ($1): $error"
}

mwan3_create_policies_iptables()
{
	local last_resort lowest_metric_v4 lowest_metric_v6 total_weight_v4 total_weight_v6 policy IPT current update error

	policy="$1"

	config_get last_resort "$1" last_resort unreachable

	if [ "$1" != "$(echo "$1" | cut -c1-15)" ]; then
		LOG warn "Policy $1 exceeds max of 15 chars. Not setting policy" && return 0
	fi

	for IPT in "$IPT4" "$IPT6"; do
		[ "$IPT" = "$IPT6" ] && [ $NO_IPV6 -ne 0 ] && continue
		current="$($IPT -S)"$'\n'
		update="*mangle"
		if [ -n "${current##*-N mwan3_policy_$1$'\n'*}" ]; then
			mwan3_push_update -N "mwan3_policy_$1"
		fi

		mwan3_push_update -F "mwan3_policy_$1"

		case "$last_resort" in
			blackhole)
				mwan3_push_update -A "mwan3_policy_$1" \
						  -m mark --mark 0x0/$MMX_MASK \
						  -m comment --comment "blackhole" \
						  -j MARK --set-xmark $MMX_BLACKHOLE/$MMX_MASK
				;;
			default)
				mwan3_push_update -A "mwan3_policy_$1" \
						  -m mark --mark 0x0/$MMX_MASK \
						  -m comment --comment "default" \
						  -j MARK --set-xmark $MMX_DEFAULT/$MMX_MASK
				;;
			*)
				mwan3_push_update -A "mwan3_policy_$1" \
						  -m mark --mark 0x0/$MMX_MASK \
						  -m comment --comment "unreachable" \
						  -j MARK --set-xmark $MMX_UNREACHABLE/$MMX_MASK
				;;
		esac
		mwan3_push_update COMMIT
		mwan3_push_update ""

		echo "$update" > "${MWAN3_STATUS_IPTABLES_LOG_DIR}/iptables-create_policies_iptables-${1}.dump"
		if [ "$IPT" = "$IPT4" ]; then
			error=$(echo "$update" | $IPT4R 2>&1) || LOG error "create_policies_iptables ($1): $error"
		else
			error=$(echo "$update" | $IPT6R 2>&1) || LOG error "create_policies_iptables ($1): $error"
		fi
	done

	lowest_metric_v4=$DEFAULT_LOWEST_METRIC
	total_weight_v4=0

	lowest_metric_v6=$DEFAULT_LOWEST_METRIC
	total_weight_v6=0

	config_list_foreach "$1" use_member mwan3_set_policy
}

mwan3_set_policies_iptables()
{
	config_foreach mwan3_create_policies_iptables policy
}

mwan3_set_sticky_iptables()
{
	local interface="${1}"
	local rule="${2}"
	local ipv="${3}"
	local policy="${4}"

	local id iface
	for iface in $(echo "$current" | grep "^-A $policy" | cut -s -d'"' -f2 | awk '{print $1}'); do
		if [ "$iface" = "$interface" ]; then

			mwan3_get_iface_id id "$iface"

			[ -n "$id" ] || return 0
			if [ -z "${current##*-N mwan3_iface_in_${iface}$'\n'*}" ]; then
				mwan3_push_update -I "mwan3_rule_$rule" \
						  -m mark --mark "$(mwan3_id2mask id MMX_MASK)/$MMX_MASK" \
						  -m set ! --match-set "mwan3_rule_${ipv}_${rule}" src,src \
						  -j MARK --set-xmark "0x0/$MMX_MASK"
				mwan3_push_update -I "mwan3_rule_$rule" \
						  -m mark --mark "0/$MMX_MASK" \
						  -j MARK --set-xmark "$(mwan3_id2mask id MMX_MASK)/$MMX_MASK"
			fi
		fi
	done
}

mwan3_set_sticky_ipset()
{
	local rule="$1"
	local mmx="$2"
	local timeout="$3"

	local error
	local update=""

	mwan3_push_update -! create "mwan3_rule_ipv4_$rule" \
		hash:ip,mark markmask "$mmx" \
		timeout "$timeout"

	[ $NO_IPV6 -eq 0 ] &&
		mwan3_push_update -! create "mwan3_rule_ipv6_$rule" \
			hash:ip,mark markmask "$mmx" \
			timeout "$timeout" family inet6

	echo "$update" > "${MWAN3_STATUS_IPTABLES_LOG_DIR}/ipset-set_sticky_ipset-${rule}.dump"
	error=$(echo "$update" | $IPS restore 2>&1) || LOG error "set_sticky_ipset (${rule}): $error"
}

mwan3_set_user_iptables_rule()
{
	local ipset family proto policy src_ip src_port src_iface src_dev
	local sticky dest_ip dest_port use_policy timeout policy
	local global_logging rule_logging loglevel rule_policy rule ipv

	rule="$1"
	ipv="$2"
	rule_policy=0
	config_get sticky "$1" sticky 0
	config_get timeout "$1" timeout 600
	config_get ipset "$1" ipset
	config_get proto "$1" proto all
	config_get src_ip "$1" src_ip
	config_get src_iface "$1" src_iface
	config_get src_port "$1" src_port
	config_get dest_ip "$1" dest_ip
	config_get dest_port "$1" dest_port
	config_get use_policy "$1" use_policy
	config_get family "$1" family any
	config_get rule_logging "$1" logging 0
	config_get global_logging globals logging 0
	config_get loglevel globals loglevel notice

	[ "$ipv" = "ipv6" ] && [ $NO_IPV6 -ne 0 ] && return
	[ "$family" = "ipv4" ] && [ "$ipv" = "ipv6" ] && return
	[ "$family" = "ipv6" ] && [ "$ipv" = "ipv4" ] && return

	for ipaddr in "$src_ip" "$dest_ip"; do
		if [ -n "$ipaddr" ] && { { [ "$ipv" = "ipv4" ] && echo "$ipaddr" | grep -qE "$IPv6_REGEX"; } ||
						 { [ "$ipv" = "ipv6" ] && echo "$ipaddr" | grep -qE $IPv4_REGEX; } }; then
			LOG warn "invalid $ipv address $ipaddr specified for rule $rule"
			return
		fi
	done

	if [ -n "$src_iface" ]; then
		network_get_device src_dev "$src_iface"
		if [ -z "$src_dev" ]; then
			LOG notice "could not find device corresponding to src_iface $src_iface for rule $1"
			return
		fi
	fi

	[ -z "$dest_ip" ] && unset dest_ip
	[ -z "$src_ip" ] && unset src_ip
	[ -z "$ipset" ] && unset ipset
	[ -z "$src_port" ] && unset src_port
	[ -z "$dest_port" ] && unset dest_port
	if [ "$proto" != 'tcp' ] && [ "$proto" != 'udp' ]; then
		[ -n "$src_port" ] && {
			LOG warn "src_port set to '$src_port' but proto set to '$proto' not tcp or udp. src_port will be ignored"
		}

		[ -n "$dest_port" ] && {
			LOG warn "dest_port set to '$dest_port' but proto set to '$proto' not tcp or udp. dest_port will be ignored"
		}
		unset src_port
		unset dest_port
	fi

	if [ "$1" != "$(echo "$1" | cut -c1-15)" ]; then
		LOG warn "Rule $1 exceeds max of 15 chars. Not setting rule" && return 0
	fi

	if [ -n "$ipset" ]; then
		ipset="-m set --match-set $ipset dst"
	fi

	if [ -z "$use_policy" ]; then
		return
	fi

	if [ "$use_policy" = "default" ]; then
		policy="MARK --set-xmark $MMX_DEFAULT/$MMX_MASK"
	elif [ "$use_policy" = "unreachable" ]; then
		policy="MARK --set-xmark $MMX_UNREACHABLE/$MMX_MASK"
	elif [ "$use_policy" = "blackhole" ]; then
		policy="MARK --set-xmark $MMX_BLACKHOLE/$MMX_MASK"
	else
		rule_policy=1
		policy="mwan3_policy_$use_policy"
		if [ "$sticky" -eq 1 ]; then
			mwan3_set_sticky_ipset "$rule" "$MMX_MASK" "$timeout"
		fi
	fi

	if [ $rule_policy -eq 1 ] && [ -n "${current##*-N $policy$'\n'*}" ]; then
		mwan3_push_update -N "$policy"
	fi

	if [ $rule_policy -eq 1 ] && [ "$sticky" -eq 1 ]; then
		if [ -n "${current##*-N mwan3_rule_$1$'\n'*}" ]; then
			mwan3_push_update -N "mwan3_rule_$1"
		fi

		mwan3_push_update -F "mwan3_rule_$1"
		config_foreach mwan3_set_sticky_iptables interface "$rule" "$ipv" "$policy"


		mwan3_push_update -A "mwan3_rule_$1" \
				  -m mark --mark 0/$MMX_MASK \
				  -j "$policy"
		mwan3_push_update -A "mwan3_rule_$1" \
				  -m mark ! --mark 0xfc00/0xfc00 \
				  -j SET --del-set "mwan3_rule_${ipv}_${rule}" src,src
		mwan3_push_update -A "mwan3_rule_$1" \
				  -m mark ! --mark 0xfc00/0xfc00 \
				  -j SET --add-set "mwan3_rule_${ipv}_${rule}" src,src
		policy="mwan3_rule_$1"
	fi
	if [ "$global_logging" = "1" ] && [ "$rule_logging" = "1" ]; then
		mwan3_push_update -A mwan3_rules \
				  -p "$proto" \
				  ${src_ip:+-s} $src_ip \
				  ${src_dev:+-i} $src_dev \
				  ${dest_ip:+-d} $dest_ip \
				  $ipset \
				  ${src_port:+-m} ${src_port:+multiport} ${src_port:+--sports} $src_port \
				  ${dest_port:+-m} ${dest_port:+multiport} ${dest_port:+--dports} $dest_port \
				  -m mark --mark 0/$MMX_MASK \
				  -m comment --comment "$1" \
				  -j LOG --log-level "$loglevel" --log-prefix "MWAN3($1)"
	fi

	mwan3_push_update -A mwan3_rules \
			  -p "$proto" \
			  ${src_ip:+-s} $src_ip \
			  ${src_dev:+-i} $src_dev \
			  ${dest_ip:+-d} $dest_ip \
			  $ipset \
			  ${src_port:+-m} ${src_port:+multiport} ${src_port:+--sports} $src_port \
			  ${dest_port:+-m} ${dest_port:+multiport} ${dest_port:+--dports} $dest_port \
			  -m mark --mark 0/$MMX_MASK \
			  -j $policy

}

mwan3_set_user_iface_rules()
{
	local current iface update family error device is_src_iface
	iface=$1
	device=$2

	if [ -z "$device" ]; then
		LOG notice "set_user_iface_rules: could not find device corresponding to iface $iface"
		return
	fi

	config_get family "$iface" family ipv4

	if [ "$family" = "ipv4" ]; then
		IPT="$IPT4"
		IPTR="$IPT4R"
	elif [ "$family" = "ipv6" ]; then
		IPT="$IPT6"
		IPTR="$IPT6R"
	fi
	$IPT -S | grep -q "^-A mwan3_rules.*-i $device" && return

	is_src_iface=0

	iface_rule()
	{
		local src_iface
		config_get src_iface "$1" src_iface
		[ "$src_iface" = "$iface" ] && is_src_iface=1
	}
	config_foreach iface_rule rule
	[ $is_src_iface -eq 1 ] && mwan3_set_user_rules
}

mwan3_set_user_rules()
{
	local IPT IPTR ipv
	local current update error

	for ipv in ipv4 ipv6; do
		if [ "$ipv" = "ipv4" ]; then
			IPT="$IPT4"
			IPTR="$IPT4R"
		elif [ "$ipv" = "ipv6" ]; then
			IPT="$IPT6"
			IPTR="$IPT6R"
		fi
		[ "$ipv" = "ipv6" ] && [ $NO_IPV6 -ne 0 ] && continue
		update="*mangle"
		current="$($IPT -S)"$'\n'


		if [ -n "${current##*-N mwan3_rules*}" ]; then
			mwan3_push_update -N "mwan3_rules"
		fi

		mwan3_push_update -F mwan3_rules

		config_foreach mwan3_set_user_iptables_rule rule "$ipv"

		mwan3_push_update COMMIT
		mwan3_push_update ""

		echo "$update" > "${MWAN3_STATUS_IPTABLES_LOG_DIR}/iptables-set_user_rules-${ipv}.dump"
		error=$(echo "$update" | $IPTR 2>&1) || LOG error "set_user_rules (${ipv}): $error"
	done


}

mwan3_interface_hotplug_shutdown()
{
	local interface status device ifdown
	interface="$1"
	ifdown="$2"
	[ -f $MWAN3TRACK_STATUS_DIR/$interface/STATUS ] && {
		status=$(cat $MWAN3TRACK_STATUS_DIR/$interface/STATUS)
	}

	[ "$status" != "online" ] && [ "$ifdown" != 1 ] && return

	if [ "$ifdown" = 1 ]; then
		env -i ACTION=ifdown \
			INTERFACE=$interface \
			DEVICE=$device \
			sh /etc/hotplug.d/iface/15-mwan3
	else
		[ "$status" = "online" ] && {
			env -i MWAN3_SHUTDOWN="1" \
				ACTION="disconnected" \
				INTERFACE="$interface" \
				DEVICE="$device" /sbin/hotplug-call iface
		}
	fi

}

mwan3_interface_shutdown()
{
	mwan3_interface_hotplug_shutdown $1
	mwan3_track_clean $1
}

mwan3_ifup()
{
	local interface=$1
	local caller=$2

	local up l3_device status true_iface

	if [ "${caller}" = "cmd" ]; then
		# It is not necessary to obtain a lock here, because it is obtained in the hotplug
		# script, but we still want to do the check to print a useful error message
		/etc/init.d/mwan3 running || {
			echo 'The service mwan3 is global disabled.'
			echo 'Please execute "/etc/init.d/mwan3 start" first.'
			exit 1
		}
		config_load mwan3
	fi
	mwan3_get_true_iface true_iface $interface
	status=$(ubus -S call network.interface.$true_iface status)

	[ -n "$status" ] && {
		json_load "$status"
		json_get_vars up l3_device
	}
	hotplug_startup()
	{
		env -i MWAN3_STARTUP=$caller ACTION=ifup \
		    INTERFACE=$interface DEVICE=$l3_device \
		    sh /etc/hotplug.d/iface/15-mwan3
	}

	if [ "$up" != "1" ] || [ -z "$l3_device" ]; then
		return
	fi

	if [ "${caller}" = "init" ]; then
		hotplug_startup &
		hotplug_pids="$hotplug_pids $!"
	else
		hotplug_startup
	fi

}

mwan3_set_iface_hotplug_state() {
	local iface=$1
	local state=$2

	echo "$state" > "$MWAN3_STATUS_DIR/iface_state/$iface"
}

mwan3_get_iface_hotplug_state() {
	local iface=$1

	cat "$MWAN3_STATUS_DIR/iface_state/$iface" 2>/dev/null || echo "offline"
}

mwan3_report_iface_status()
{
	local device result tracking IP IPT
	local status online uptime result

	mwan3_get_iface_id id "$1"
	network_get_device device "$1"
	config_get enabled "$1" enabled 0
	config_get family "$1" family ipv4

	if [ "$family" = "ipv4" ]; then
		IP="$IP4"
		IPT="$IPT4"
	fi

	if [ "$family" = "ipv6" ]; then
		IP="$IP6"
		IPT="$IPT6"
	fi

	if [ -f "$MWAN3TRACK_STATUS_DIR/${1}/STATUS" ]; then
		status="$(cat "$MWAN3TRACK_STATUS_DIR/${1}/STATUS")"
	else
		status="unknown"
	fi

	if [ "$status" = "online" ]; then
		online=$(get_online_time "$1")
		network_get_uptime uptime "$1"
		online="$(printf '%02dh:%02dm:%02ds\n' $((online/3600)) $((online%3600/60)) $((online%60)))"
		uptime="$(printf '%02dh:%02dm:%02ds\n' $((uptime/3600)) $((uptime%3600/60)) $((uptime%60)))"
		result="$(mwan3_get_iface_hotplug_state $1) $online, uptime $uptime"
	else
		result=0
		[ -n "$($IP rule | awk '$1 == "'$((id+1000)):'"')" ] ||
			result=$((result+1))
		[ -n "$($IP rule | awk '$1 == "'$((id+2000)):'"')" ] ||
			result=$((result+2))
		[ -n "$($IP rule | awk '$1 == "'$((id+3000)):'"')" ] ||
			result=$((result+4))
		[ -n "$($IPT -S mwan3_iface_in_$1 2> /dev/null)" ] ||
			result=$((result+8))
		[ -n "$($IP route list table $id default dev $device 2> /dev/null)" ] ||
			result=$((result+16))
		[ "$result" = "0" ] && result=""
	fi

	tracking="$(mwan3_get_mwan3track_status $1)"
	if [ -n "$result" ]; then
		echo " interface $1 is $status and tracking is $tracking ($result)"
	else
		echo " interface $1 is $status and tracking is $tracking"
	fi
}

mwan3_report_policies()
{
	local ipt="$1"
	local policy="$2"

	local percent total_weight weight iface

	total_weight=$($ipt -S "$policy" | grep -v '.*--comment "out .*" .*$' | cut -s -d'"' -f2 | head -1 | awk '{print $3}')

	if [ -n "${total_weight##*[!0-9]*}" ]; then
		for iface in $($ipt -S "$policy" | grep -v '.*--comment "out .*" .*$' | cut -s -d'"' -f2 | awk '{print $1}'); do
			weight=$($ipt -S "$policy" | grep -v '.*--comment "out .*" .*$' | cut -s -d'"' -f2 | awk '$1 == "'$iface'"' | awk '{print $2}')
			percent=$((weight*100/total_weight))
			echo " $iface ($percent%)"
		done
	else
		echo " $($ipt -S "$policy" | grep -v '.*--comment "out .*" .*$' | sed '/.*--comment \([^ ]*\) .*$/!d;s//\1/;q')"
	fi
}

mwan3_report_policies_v4()
{
	local policy

	for policy in $($IPT4 -S | awk '{print $2}' | grep mwan3_policy_ | sort -u); do
		echo "$policy:" | sed 's/mwan3_policy_//'
		mwan3_report_policies "$IPT4" "$policy"
	done
}

mwan3_report_policies_v6()
{
	local policy

	for policy in $($IPT6 -S | awk '{print $2}' | grep mwan3_policy_ | sort -u); do
		echo "$policy:" | sed 's/mwan3_policy_//'
		mwan3_report_policies "$IPT6" "$policy"
	done
}

mwan3_report_connected_v4()
{
	if [ -n "$($IPT4 -S mwan3_connected_ipv4 2> /dev/null)" ]; then
		$IPS -o save list mwan3_connected_ipv4 | grep add | cut -d " " -f 3
	fi
}

mwan3_report_connected_v6()
{
	if [ -n "$($IPT6 -S mwan3_connected_ipv6 2> /dev/null)" ]; then
		$IPS -o save list mwan3_connected_ipv6 | grep add | cut -d " " -f 3
	fi
}

mwan3_report_rules_v4()
{
	if [ -n "$($IPT4 -S mwan3_rules 2> /dev/null)" ]; then
		$IPT4 -L mwan3_rules -n -v 2> /dev/null | tail -n+3 | sed 's/mark.*//' | sed 's/mwan3_policy_/- /' | sed 's/mwan3_rule_/S /'
	fi
}

mwan3_report_rules_v6()
{
	if [ -n "$($IPT6 -S mwan3_rules 2> /dev/null)" ]; then
		$IPT6 -L mwan3_rules -n -v 2> /dev/null | tail -n+3 | sed 's/mark.*//' | sed 's/mwan3_policy_/- /' | sed 's/mwan3_rule_/S /'
	fi
}

mwan3_flush_conntrack()
{
	local interface="$1"
	local action="$2"

	handle_flush() {
		local flush_conntrack="$1"
		local action="$2"

		if [ "$action" = "$flush_conntrack" ]; then
			echo f > ${CONNTRACK_FILE}
			LOG info "Connection tracking flushed for interface '$interface' on action '$action'"
		fi
	}

	if [ -e "$CONNTRACK_FILE" ]; then
		config_list_foreach "$interface" flush_conntrack handle_flush "$action"
	fi
}

mwan3_track_clean()
{
	rm -rf "${MWAN3_STATUS_DIR:?}/${1}" &> /dev/null
	rmdir --ignore-fail-on-non-empty "$MWAN3_STATUS_DIR"
}
