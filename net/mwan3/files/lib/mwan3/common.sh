#!/bin/sh

IP4="ip -4"
IP6="ip -6"
SCRIPTNAME="$(basename "$0")"

MWAN3_STATUS_DIR="/var/run/mwan3"
MWAN3_STATUS_IPTABLES_LOG_DIR="${MWAN3_STATUS_DIR}/iptables_log"
MWAN3TRACK_STATUS_DIR="/var/run/mwan3track"

MWAN3_INTERFACE_MAX=""

MMX_MASK=""
MMX_DEFAULT=""
MMX_BLACKHOLE=""
MM_BLACKHOLE=""

MMX_UNREACHABLE=""
MM_UNREACHABLE=""
MAX_SLEEP=$(((1<<31)-1))

command -v ip6tables > /dev/null
NO_IPV6=$?

IPS="ipset"
IPT4="iptables -t mangle -w"
IPT6="ip6tables -t mangle -w"
IPT4R="iptables-restore -T mangle -w -n"
IPT6R="ip6tables-restore -T mangle -w -n"

LOG()
{
	local facility=$1; shift
	# in development, we want to show 'debug' level logs
	# when this release is out of beta, the comment in the line below
	# should be removed
	[ "$facility" = "debug" ] && return
	logger -t "${SCRIPTNAME}[$$]" -p $facility "$*"
}

mwan3_get_true_iface()
{
	local family V
	_true_iface=$2
	config_get family "$2" family ipv4
	if [ "$family" = "ipv4" ]; then
		V=4
	elif [ "$family" = "ipv6" ]; then
		V=6
	fi
	ubus call "network.interface.${2}_${V}" status &>/dev/null && _true_iface="${2}_${V}"
	export "$1=$_true_iface"
}

mwan3_get_src_ip()
{
	local family _src_ip interface true_iface device addr_cmd default_ip IP sed_str
	interface=$2
	mwan3_get_true_iface true_iface $interface

	unset "$1"
	config_get family "$interface" family ipv4
	if [ "$family" = "ipv4" ]; then
		addr_cmd='network_get_ipaddr'
		default_ip="0.0.0.0"
		sed_str='s/ *inet \([^ \/]*\).*/\1/;T; pq'
		IP="$IP4"
	elif [ "$family" = "ipv6" ]; then
		addr_cmd='network_get_ipaddr6'
		default_ip="::"
		sed_str='s/ *inet6 \([^ \/]*\).* scope.*/\1/;T; pq'
		IP="$IP6"
	fi

	$addr_cmd _src_ip "$true_iface"
	if [ -z "$_src_ip" ]; then
		network_get_device device $true_iface
		_src_ip=$($IP address ls dev $device 2>/dev/null | sed -ne "$sed_str")
		if [ -n "$_src_ip" ]; then
			LOG warn "no src $family address found from netifd for interface '$true_iface' dev '$device' guessing $_src_ip"
		else
			_src_ip="$default_ip"
			LOG warn "no src $family address found for interface '$true_iface' dev '$device'"
		fi
	fi
	export "$1=$_src_ip"
}

mwan3_get_mwan3track_status()
{
	local track_ips pid
	mwan3_list_track_ips()
	{
		track_ips="$1 $track_ips"
	}
	config_list_foreach "$1" track_ip mwan3_list_track_ips

	if [ -n "$track_ips" ]; then
		pid="$(pgrep -f "mwan3track $1$")"
		if [ -n "$pid" ]; then
			if [ "$(cat /proc/"$(pgrep -P $pid)"/cmdline)" = "sleep${MAX_SLEEP}" ]; then
				tracking="paused"
			else
				tracking="active"
			fi
		else
			tracking="down"
		fi
	else
		tracking="not enabled"
	fi
	echo "$tracking"
}

mwan3_init()
{
	local bitcnt mmdefault source_routing

	config_load mwan3

	[ -d $MWAN3_STATUS_DIR ] || mkdir -p $MWAN3_STATUS_DIR/iface_state
	[ -d "$MWAN3_STATUS_IPTABLES_LOG_DIR" ] || mkdir -p "$MWAN3_STATUS_IPTABLES_LOG_DIR"

	# mwan3's MARKing mask (at least 3 bits should be set)
	if [ -e "${MWAN3_STATUS_DIR}/mmx_mask" ]; then
		MMX_MASK=$(cat "${MWAN3_STATUS_DIR}/mmx_mask")
		MWAN3_INTERFACE_MAX=$(uci_get_state mwan3 globals iface_max)
	else
		config_get MMX_MASK globals mmx_mask '0x3F00'
		echo "$MMX_MASK"| tr 'A-F' 'a-f' > "${MWAN3_STATUS_DIR}/mmx_mask"
		LOG debug "Using firewall mask ${MMX_MASK}"

		bitcnt=$(mwan3_count_one_bits MMX_MASK)
		mmdefault=$(((1<<bitcnt)-1))
		MWAN3_INTERFACE_MAX=$((mmdefault-3))
		uci_toggle_state mwan3 globals iface_max "$MWAN3_INTERFACE_MAX"
		LOG debug "Max interface count is ${MWAN3_INTERFACE_MAX}"
	fi

	# remove "linkdown", expiry and source based routing modifiers from route lines
	config_get_bool source_routing globals source_routing 0
	[ $source_routing -eq 1 ] && unset source_routing
	MWAN3_ROUTE_LINE_EXP="s/offload//; s/linkdown //; s/expires [0-9]\+sec//; s/error [0-9]\+//; ${source_routing:+s/default\(.*\) from [^ ]*/default\1/;} p"

	# mark mask constants
	bitcnt=$(mwan3_count_one_bits MMX_MASK)
	mmdefault=$(((1<<bitcnt)-1))
	MM_BLACKHOLE=$((mmdefault-2))
	MM_UNREACHABLE=$((mmdefault-1))

	# MMX_DEFAULT should equal MMX_MASK
	MMX_DEFAULT=$(mwan3_id2mask mmdefault MMX_MASK)
	MMX_BLACKHOLE=$(mwan3_id2mask MM_BLACKHOLE MMX_MASK)
	MMX_UNREACHABLE=$(mwan3_id2mask MM_UNREACHABLE MMX_MASK)
}

# maps the 1st parameter so it only uses the bits allowed by the bitmask (2nd parameter)
# which means spreading the bits of the 1st parameter to only use the bits that are set to 1 in the 2nd parameter
# 0 0 0 0 0 1 0 1 (0x05) 1st parameter
# 1 0 1 0 1 0 1 0 (0xAA) 2nd parameter
#     1   0   1          result
mwan3_id2mask()
{
	local bit_msk bit_val result
	bit_val=0
	result=0
	for bit_msk in $(seq 0 31); do
		if [ $((($2>>bit_msk)&1)) = "1" ]; then
			if [ $((($1>>bit_val)&1)) = "1" ]; then
				result=$((result|(1<<bit_msk)))
			fi
			bit_val=$((bit_val+1))
		fi
	done
	printf "0x%x" $result
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

get_uptime() {
	local uptime=$(cat /proc/uptime)
	echo "${uptime%%.*}"
}

get_online_time() {
	local time_n time_u iface
	iface="$1"
	time_u="$(cat "$MWAN3TRACK_STATUS_DIR/${iface}/ONLINE" 2>/dev/null)"
	[ -z "${time_u}" ] || [ "${time_u}" = "0" ] || {
		time_n="$(get_uptime)"
		echo $((time_n-time_u))
	}
}
