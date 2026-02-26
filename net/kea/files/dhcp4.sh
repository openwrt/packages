#!/bin/sh

NL=$'\n'
WS=$'[\t ]'
TTL=3600
PREFIX="update add"

prog="$(basename $0)"

dyndir=/var/run/dhcp
keadir=/var/lib/kea

session_key_name=local-ddns

getvar() {
	local __dest="$1" _var="$2"
	eval "export -n -- \"$__dest=\${$_var}\""
}

setvar() {
	local __dest="$1" _val="$2"
	eval "export -n -- \"$__dest=$_val\""
}

#### delete me -- these should all be in jshn.sh

json_add_names() {
	local _name

	for _name in "$@"; do
		json_push_string "$_name"
	done
}

#### delete me

time2seconds() {
	local _var="$1" _timestring="$2"
	local _multiplier _number _suffix

	_suffix="${_timestring//[0-9 ]}"
	_number="${_timestring%%$_suffix}"
	[ "$_number$_suffix" != "$_timestring" ] && return 1
	case "$_suffix" in
		"" | s)
			_multiplier=1
			;;
		m)
			_multiplier=60
			;;
		h)
			_multiplier=3600
			;;
		d)
			_multiplier=86400
			;;
		w)
			_multiplier=604800
			;;
		*)
			return 1
			;;
	esac

	setvar "$_var" "$((_number * _multiplier))"
}

explode_dotted() {
	local _var="$1" _val="${2//\./ }"

	setvar "$_var" "$_val"
}

is_decimal() {
	local _val="$1"

	[ -z "${_val//[0-9]/}" ]
}

is_hex() {
	local _val="$1"

	[ -z "${_val//[0-9a-f]/}" ]
}

trim() {
	local _var="$1" _str="$2" _prev

	while true; do
		_prev="$_str"
		_str="${_str%%$WS}"
		[ "$_str" = "$_prev" ] && break
	done
	while true; do
		_prev="$_str"
		_str="${_str##$WS}"
		[ "$_str" = "$_prev" ] && break
	done

	setvar "$_var" "$_str"
}

mangle() {
	local _var="$1" _name="${2//[^A-Za-z0-9]/_}"

	setvar "$_var" "$_name"
}

rfc1918_prefix() {
	local _var="$1" _subnet="${2%/*}" _exploded
	explode_dotted _exploded "$_subnet"
	set -- $_exploded

	case "$1.$2" in
	10.*)
		setvar "$_var" "$1" ;;
	172.1[6789]|172.2[0-9]|172.3[01]|192.168)
		setvar "$_var" "$1.$2" ;;
	*)
		setvar "$_var" "" ;;
	esac
}

no_ipv6() {
	[ -n "$(named-checkconf -px \
		| sed -r -ne '1N; N; /^\tlisten-on-v6  ?\{\n\t\t"none";\n\t\};$/{ p; q; }; D')" ]
}

subnet_of() {
	local _var="$1" _ip
	str2ip _ip "$2" || return 1
	local _ifname _pfx _start _end

	for _ifname in $dhcp_ifs; do
		mangle _pfx "$_ifname"

		getvar _start "${_pfx}_start"
		getvar _end "${_pfx}_end"

		if [ $_start -le $_ip ] && [ $_ip -le $_end ]; then
			setvar "$_var" "$_ifname"
			return 0
		fi
	done
	return 1
}

# duplicated from dnsmasq init script
hex_to_hostid() {
	local _var="$1"
	local _hex="${2#0x}" # strip optional "0x" prefix

	if ! is_hex "$_hex"; then
		echo "Invalid hostid: $_hex" >&2
		return 1
	fi

	# convert into host id
	setvar "$_var" "$(
		printf "%0x:%0x" \
		$(((0x$_hex >> 16) % 65536)) \
		$(( 0x$_hex        % 65536))
		)"

	return 0
}

update() {
	local _lhs="$1" _family="$2" _type="$3"
	shift 3

	[ $dynamicdns -eq 1 ] && \
		echo -e "$PREFIX" "$_lhs $_family $_type $@\nsend" >> "$dyn_file"
}

rev_str() {
	local _var="$1" _str="$2" _delim="$3"
	local _frag _result=""

	for _frag in ${_str//$_delim/ }; do
		prepend _result "$_frag" "$_delim"
	done

	setvar "$_var" "$_result"
}

write_empty_zone() {
	local zpath
	zpath="$1"

	cat > "$zpath" <<\EOF
;
; BIND empty zone created by Kea dhcp4.sh plugin
;
$TTL   604800
@	IN      SOA     localhost. root.localhost. (
			     1         ; Serial
			604800         ; Refresh
			 86400         ; Retry
			419200         ; Expire
			604800 )       ; Negative Cache TTL
;
@	IN	NS	localhost.
EOF
}

create_empty_zone() {
	local zone error zpath command
	zone="$1"
	zpath="$dyndir/db.$zone"

	if [ ! -d "$dyndir" ]; then
		mkdir -p "$dyndir" || return 1
		chown bind:bind "$dyndir" || return 1
	fi

	write_empty_zone "$zpath"
	chown bind:bind "$zpath" || return 1
	chmod 0664 "$zpath" || return 1

	# if the zone doesn't exist, or a RFC-1918 in-addr.arpa zone, then
	# we need to add it, otherwise we need to modify it.
	if ! rndc zonestatus $zone >/dev/null 2>&1; then
		command="addzone"
	else
		command="modzone"
	fi

	case "$zone" in
	10.in-addr.arpa|1[6789].172.in-addr.arpa|2[0-9].172.in-addr.arpa|3[01].172.in-addr.arpa|168.192.in-addr.arpa)
		command="addzone" ;;
	esac

	if ! error=$(rndc $command $zone "{
		type primary;
		file \"$zpath\";
		update-policy {
			grant $session_key_name zonesub any;
		};
	};" 2>&1); then
		case "$error" in
			*"already exists"*)
				;;
			*)
				logger -p info -t "$prog" "Failed to add zone $zone: $error"
				return 1
				;;
		esac
	fi
}

option_def() {
	local name="$1" code="$2" type="$3"

	case "$type" in
	binary|boolean|empty|fqdn|ipv4-address|ipv6-address|ipv6-prefix|psid|string|tuple|uint8|uint16|uint32|int8|int16|int32)
		;;
	record)
		echo "Not yet supported: $type" >&2
		exit 1
		;;
	*)
		echo "Unknown option type: $type" >&2
		exit 1
		;;
	esac

	if ! json_get_type type "option-def"; then
		json_add_array "option-def"
	else
		json_select "option-def"
	fi
	json_add_object
	json_add_fields "name:string=$name" "code:int=$code" "type:string=$type"
	json_close_object

	json_select ".."		# option-def
}

option_data() {
	local arg value type

	# if the option-data array doesn't exist, create it since
	# this is the first time through. otherwise, select it.
	if ! json_get_type type "option-data"; then
		json_add_array "option-data"
	else
		json_select "option-data"
	fi

	json_add_object

	while [ $# -ge 1 ]; do
		arg="$1"
		shift

		case "$arg" in
		name:*)
			value="${arg#name:}"
			json_add_string "name" "$value"
			;;
		space:*)
			value="${arg#space:}"
			json_add_string "space" "$value"
			;;
		code:*)
			value="${arg#code:}"
			if is_decimal "$value"; then
				json_add_int "code" $value
			else
				echo "Bad code '$value' in DHCP options" >&2
			fi
			;;
		csv-format:true)
			json_add_boolean "csv-format" 1
			;;
		csv-format:false)
			json_add_boolean "csv-format" 0
			;;
		data:*)
			value="$arg"
			json_add_fields "$value"
			;;
		always-send:true)
			json_add_boolean "always-send" 1
			;;
		*)
			echo "Unexpected argument '$arg' to option_data" >&2
			;;
		esac
	done

	json_close_object

	json_select ..			# option-data
}

is_force_send() {
	local forced="$1" option="$2"
	list_contains forced "$option" && echo "always-send:true"
}

append_routes() {
	local tuple
	local network prefix router subnet

	trim tuple "$1"

	subnet="${tuple%%$WS*}"

	network="${subnet%/[0-9]*}"

	prefix="${subnet#*/}"

	router="${tuple#${subnet}$WS}"

	append routes "$subnet - $router" ", "
}

append_dhcp_options() {
	local tuple="$1"

	# strip redundant "option:" prefix
	tuple="${tuple#option:}"

	local tag="${tuple%%,*}"
	local values="${tuple#$tag,}"

	case "$tag" in
	routers|time-servers|name-servers|domain-name-servers|log-servers|static-routes|ntp-servers|domain-search)
		option_data "name:$tag" "data:string=$values"
		;;
	dhcp-renewal-time)
		if ! is_decimal "$values"; then
			echo "Expected a decimal integer: $tag" >&2
			exit 1
		fi
		## option_data "name:$tag" "data:int=$values"
		option_data "name:$tag" "data:string=$values"
		;;
	*)
		echo "Unhandled option: $tag" >&2
		;;
	esac
}

static_cname_add() {
	local cfg="$1"
	local cname target

	config_get cname "$cfg" "cname"
	[ -n "$cname" ] || return 0
	config_get target "$cfg" "target"
	[ -n "$target" ] || return 0

	case "$target" in
	*.*)
		;;
	*)
		target="$target.$g_domain"
		;;
	esac

	update "$cname.$g_domain." IN CNAME "$target."
}

static_cnames() {
	config_foreach static_cname_add cname "$@"
}

static_domain_add() {
	local cfg="$1"
	local name ip ips revip octets

	config_get name "$cfg" "name"
	[ -n "$name" ] || return 0
	config_get ip "$cfg" "ip"
	[ -n "$ip" ] || return 0

	ips="$ip"
	for ip in $ips; do
		rev_str revip "$ip" "."

		update "$name.$g_domain." IN A "$ip"
		rfc1918_prefix octets "$ip"
		[ -n "$octets" ] && \
			update "$revip.in-addr.arpa." IN PTR "$name.$g_domain."
	done
}

static_domains() {
	config_foreach static_domain_add domain "$@"
}

static_mxhost_add() {
	local cfg="$1"
	local h_domain relay pref

	config_get h_domain "$cfg" "domain"
	[ -n "$h_domain" ] || return 0
	config_get relay "$cfg" "relay"
	[ -n "$relay" ] || return 0
	config_get pref "$cfg" "pref"
	[ -n "$pref" ] || return 0

	case "$relay" in
	*.*)
		;;
	*)
		relay="$relay.$g_domain"
		;;
	esac

	if [ "$h_domain" = "@" ]; then
		update "$g_domain." IN MX "$pref" "$relay."
	else
		update "$h_domain.$g_domain." IN MX "$pref" "$relay."
	fi
}

static_mxhosts() {
	config_foreach static_mxhost_add mxhost "$@"
}

static_srvhost_add() {
	local cfg="$1"
	local srv target port priority weight

	config_get srv "$cfg" "srv"
	[ -n "$srv" ] || return 0
	config_get target "$cfg" "target"
	[ -n "$target" ] || return 0
	config_get port "$cfg" "port"
	[ -n "$port" ] || return 0
	config_get priority "$cfg" "priority"
	[ -n "$priority" ] || return 0
	config_get weight "$cfg" "weight"
	[ -n "$weight" ] || return 0

	case "$target" in
	*.*)
		;;
	*)
		target="$target.$g_domain"
		;;
	esac

	update "$srv.$g_domain." IN SRV "$priority" "$weight" "$port" "$target."
}

static_srvhosts() {
	config_foreach static_srvhost_add srvhost "$@"
}

static_host_add() {
	local cfg="$1"
	local broadcast hostid id macn macs mac name net ip ips revip leasetime
	local h_domain s_domain defaultroute renewal_time s_renewal_time
	local h_gateway s_gateway
	local force_send always index

	config_get macs "$cfg" "mac"
	[ -n "$macs" ] || return 0
	config_get name "$cfg" "name"
	[ -n "$name" ] || return 0
	config_get ip "$cfg" "ip"
	[ -n "$ip" ] || return 0

	# needs to match a provisioned subnet
	local ifname pfx
	if ! subnet_of ifname "$ip"; then
		echo "$name's address $ip doesn't match any subnet" >&2
		return 1
	fi
	mangle pfx "$ifname"
	getvar net "${pfx}_ifname"
	getvar index "${net}_subnet4_index"

	local h_gateway s_gateway
	getvar s_gateway "${pfx}_gateway"

	config_get_bool broadcast "$cfg" "broadcast" 0
	config_get dns "$cfg" "dns"
	config_get h_gateway "$cfg" "gateway" "$s_gateway"
	config_get leasetime "$cfg" "leasetime"
	if [ -n "$leasetime" ]; then
		time2seconds leasetime "$leasetime" || return 1
	fi

	config_get hostid "$cfg" "hostid"
	if [ -n "$hostid" ]; then
		hex_to_hostid hostid "$hostid" || return 1
	fi

	local s_defaultroute
	getvar s_defaultroute "${pfx}_defaultroute"

	# if provisioned, otherwise default to subnet value
	config_get_bool defaultroute "$cfg" "default_route" $s_defaultroute

	config_get force_send "$cfg" "force_send"
	force_send="${force_send//,/ }"

	local s_domain
	getvar s_domain "${pfx}_domain"

	config_get h_domain "$cfg" "domain" "$s_domain"

	getvar s_renewal_time "${pfx}_renewal_time"

	config_get renewal_time "$cfg" "renewal_time"

	json_select "$index"		# why "$index" and not "$pfx"?
	json_select "reservations"

	#	rebinding-time)

	macn=0
	for mac in $macs; do
		macn=$(( macn + 1 ))
	done

	for mac in $macs; do
		local secname="$name"
		if [ $macn -gt 1 ]; then
			secname="${name}-${mac//:}"
		fi

		json_add_object "$mac"

		json_add_fields "hostname:string=$name" "hw-address:string=$mac" "ip-address:string=$ip"

		[ -n "$hostid" ] && json_add_fields "client-id:string=$hostid"

		### redundant...
		always="$(is_force_send "$force_send" "hostname")"
		option_data "name:host-name" "data:string=$name" $always

		local routes=
		config_list_foreach "$cfg" "routes" append_routes

		always="$(is_force_send "$force_send" "routes")"
		if [ -n "$routes" -o -n "$always" ]; then
			option_data "name:classless-static-route" "code:121" "data:string=$routes" $always
		fi

		always="$(is_force_send "$force_send" "domain-name")"
		if [ "$h_domain" != "$s_domain" -o -n "$always" ]; then
			option_data "name:domain-name" "data:string=$h_domain" $always
		fi

		always="$(is_force_send "$force_send" "fqdn")"
		[ -n "$always" ] && option_data "name:host-name" "data:string=$name.$h_domain" $always

		if [ -n "$dns" ]; then
			always="$(is_force_send "$force_send" "domain-name-servers")"
			option_data "name:domain-name-servers" "data:string=$dns" $always
		fi

		if [ "$h_gateway" != "$s_gateway" -a $defaultroute -eq 1 ]; then
			always="$(is_force_send "$force_send" "routers")"
			option_data "name:routers" "data:string=$h_gateway" $always
		fi

		always="$(is_force_send "$force_send" "renewal-time")"
		if [ -n "$renewal_time" ]; then
			option_data "name:dhcp-renewal-time" "data:string=$renewal_time" $always
		elif [ -n "$always" ]; then
			option_data "name:dhcp-renewal-time" "data:string=$s_renewal_time" $always
		fi

		### need special handling for list dhcp_option 'option:xxx,yyy'
		config_list_foreach "$cfg" "dhcp_option" append_dhcp_options

		# other options here
		### always-broadcast
		### default-lease-time
		### max-lease-time

		json_close_object	# $mac
	done

	json_select ..			# reservations
	json_select ..			# $index

	ips="$ip"
	for ip in $ips; do
		rev_str revip "$ip" "."

		update "$name.$h_domain." IN A "$ip"
		update "$revip.in-addr.arpa." IN PTR "$name.$h_domain."
	done
}

static_hosts() {
	config_foreach static_host_add host "$@"
}

gen_dhcp_subnet() {
	local cfg="$1" index

	json_add_object "$cfg"

	json_get_index index

	subnet4_id=$((subnet4_id + 1))
	json_add_int "id" $subnet4_id
	setvar "${cfg}_subnet4_id" "$subnet4_id"

	setvar "${cfg}_subnet4_index" "$index"

	json_add_fields "subnet:string=$NETWORK/$PREFIX"

	if [ -n "$START" ] && [ -n "$END" ]; then
		json_add_array "pools"
		json_add_object
		json_add_fields "pool:string=$START - $END"
		json_close_object
		json_close_array	# pools
	fi

	if [ -n "$leasetime" ]; then
		json_add_fields "valid-lifetime:int=$leasetime" "max-valid-lifetime:int=$leasetime"
	fi

	option_data "name:subnet-mask" "data:string=$NETMASK"

	if [ -n "$BROADCAST" ] && [ "$BROADCAST" != "0.0.0.0" ]; then
		option_data "name:broadcast-address" "data:string=$BROADCAST"
	fi

	if [ $defaultroute -eq 1 ]; then
		option_data "name:routers" "data:string=$gateway"
	fi

	if [ -n "$DNS" ]; then
		option_data "name:domain-name-servers" "data:string=$DNS"
	fi

	if [ "$s_domain" != "$g_domain" ]; then
		option_data "name:domain-name" "data:string=$s_domain"
	fi

	[ -n "$ntp_servers" ] && option_data "name:ntp-servers" "data:string=$ntp_servers"

	[ -n "$routes" ] && option_data "name:classless-ipv4-route" "code:121" "csv-format:false" "data:string=$routes"

	if [ $dynamicdhcp -eq 0 ]; then

		if [ $authoritative -eq 1 ]; then
			# see:
			# https://gitlab.isc.org/isc-projects/kea/-/issues/4110
			# echo " deny unknown-clients;"
			:
		else
			# echo " ignore unknown-clients;"
			json_add_array "client-classes"
			json_add_object
			json_add_fields "name:string=DROP" "test:string=not(member('KNOWN'))"
			json_close_object
			json_close_array	# client-classes
		fi
	fi

	config_list_foreach "$cfg" "dhcp_option" append_dhcp_options

	json_add_array "reservations"
	json_close_array			# reservations

	json_close_object		# $cfg
}

dhcpd_add() {
	local cfg="$1"
	local dhcp6range="::"
	local dynamicdhcp defaultroute dnsserv dnsserver end
	local gateway ifname ignore ntp_servers
	local leasetime
	local limit net netmask networkid octets pfx proto
	local routes start subnet s_domain s_renewal_time
	local IP NETMASK BROADCAST NETWORK PREFIX DNS START END

	config_get_bool ignore "$cfg" "ignore" 0

	[ $ignore -eq 1 ] && return 0

	config_get net "$cfg" "interface"
	[ -n "$net" ] || return 0

	config_get start "$cfg" "start"
	config_get limit "$cfg" "limit"

	case "$start:$limit" in
	:)
		;;
	:*|*:)
		echo "In pool $cfg start/limit must be used together" >&2
		return 0
		;;
	*:*)
		# In Kea, this is done implicitly by not having a pool
		# for unknown clients defined.
		if [ $boot_unknown_clients -eq 1 ]; then
			echo "To not boot unknown clients, remove the pool start and limit for $cfg" >&2
		fi
		;;
	esac

	network_get_subnet subnet "$net" || return 0
	network_get_device ifname "$net" || return 0
	network_get_protocol proto "$net" || return 0

	mangle pfx "$ifname"

	setvar "${pfx}_ifname" "$net"

	# only operate on statically provisioned interfaces
	[ "$proto" != "static" ] && return 0

	append dhcp_ifs "$ifname"

	rfc1918_prefix octets "$subnet"

	[ -n "$octets" ] && append rfc1918_nets "$octets"

	config_get_bool dynamicdhcp "$cfg" "dynamicdhcp" 1

	config_get_bool defaultroute "$cfg" "default_route" 1
	setvar "${pfx}_defaultroute" $defaultroute

	ipcalc -d $subnet $start $limit

	setvar "${pfx}_start" "$NETWORK"
	setvar "${pfx}_end" "$BROADCAST"

	ip2str IP "$IP"
	ip2str NETMASK "$NETMASK"
	ip2str NETWORK "$NETWORK"
	ip2str BROADCAST "$BROADCAST"
	[ -n "${START:+x}" ] && ip2str START "$START"
	[ -n "${END:+x}" ] && ip2str END "$END"

	config_get netmask "$cfg" "netmask" "$NETMASK"
	NETMASK="$netmask"

	config_get s_domain "$cfg" "domain" "$g_domain"
	setvar "${pfx}_domain" "$s_domain"

	config_get ntp_servers "$cfg" "ntp_servers" ""

	config_get s_renewal_time "$cfg" "renewal_time"
	if [ -n "$s_renewal_time" ]; then
		time2seconds s_renewal_time "$s_renewal_time" || exit 1
	else
		s_renewal_time="$g_renewal_time"
	fi
	setvar "${pfx}_renewal_time" "$s_renewal_time"

	config_get leasetime "$cfg" "leasetime"
	if [ -n "$leasetime" ]; then
		time2seconds leasetime "$leasetime" || return 1
		setvar "${pfx}_leasetime" "$leasetime"
	fi

	if network_get_dnsserver dnsserver "$net" ; then
		for dnsserv in $dnsserver; do
			append DNS "$dnsserv" ","
		done
	else
		DNS="$IP"
	fi

	if ! network_get_gateway gateway "$net" ; then
		gateway="$IP"
	fi
	setvar "${pfx}_gateway" $gateway

	routes=
	config_list_foreach "$cfg" "routes" append_routes

	gen_dhcp_subnet "$cfg"
}

general_config() {
	local always_broadcast boot_unknown_clients log_facility
	local default_lease_time max_lease_time intf

	config_get_bool always_broadcast "isc_dhcpd" "always_broadcast" 0
	config_get_bool authoritative "isc_dhcpd" "authoritative" 1
	config_get_bool boot_unknown_clients "isc_dhcpd" "boot_unknown_clients" 1
	config_get default_lease_time "isc_dhcpd" "default_lease_time" 3600

	config_get max_lease_time "isc_dhcpd" "max_lease_time" 86400

	config_get g_renewal_time "isc_dhcpd" "renewal_time"

	config_get log_facility "isc_dhcpd" "log_facility"

	config_get g_domain "isc_dhcpd" "domain"

	config_get_bool dynamicdns "isc_dhcpd" dynamicdns 0

	time2seconds default_lease_time "$default_lease_time" || return 1
	time2seconds max_lease_time "$max_lease_time" || return 1

	if [ -n "$g_renewal_time" ]; then
		time2seconds g_renewal_time "$g_renewal_time" || return 1
	else
		g_renewal_time=$((default_lease_time / 2))
	fi

	setvar g_max_lease_time "$max_lease_time"
	setvar g_lease_time "$default_lease_time"
	setvar g_renewal_time "$g_renewal_time"

	json_add_object "lease-database"
	json_add_string "type" "memfile"
	json_add_boolean "persist" 1
	json_add_string "name" "$keadir/kea-leases4.csv"
	json_add_int "lfc-interval" 900
	json_add_int "max-row-errors" 1
	json_close_object

	json_add_object "interfaces-config"
	json_add_array "interfaces"
	# will populate later
	json_close_array		# interfaces

	json_add_boolean "re-detect" 0
	json_add_string "dhcp-socket-type" "raw"
	json_add_string "outbound-interface" "same-as-inbound"
	json_close_object		# interfaces-config

	## option_def "renew-timer" 58 "uint32"

	[ $authoritative -eq 1 ] && json_add_boolean "authoritative" "1"

	json_add_boolean "ip-reservations-unique" "0"

	if [ $dynamicdns -eq 1 ]; then
		json_add_fields "ddns-qualifying-suffix:string=$g_domain." "ddns-send-updates:boolean=1"
	fi

	json_add_fields "valid-lifetime:int=$default_lease_time" "max-valid-lifetime:int=$g_max_lease_time" "renew-timer:int=$g_renewal_time"

	option_data "name:domain-name" "data:string=$g_domain"

	### see:
	### https://gitlab.isc.org/isc-projects/kea/-/issues/241
	if [ $always_broadcast -eq 1 ]; then
		echo "This option is deprecated and being ignored: always-broadcast" >&2
	fi
}

write_zones() {
	if [ $dynamicdns -eq 1 ]; then
		rndc freeze

		create_empty_zone "$g_domain"

		local mynet

		for mynet in $rfc1918_nets; do
			rev_str mynet "$mynet" "."
			create_empty_zone "$mynet.in-addr.arpa"
		done

		rndc thaw
	fi

	rm -f /tmp/resolv.conf
	echo "# This file is generated by the DHCPD service" > /tmp/resolv.conf
	[ -n "$g_domain" ] && echo "domain $g_domain" >> /tmp/resolv.conf
	echo "nameserver 127.0.0.1" >> /tmp/resolv.conf
}

main() {
	# values parsed by general_config that we need to persist
	# for subsequent subnet and host configurations
	local g_domain dhcp_ifs= dynamicdns=0 authoritative=1
	local g_renewal_time g_max_lease_time g_lease_time
	local rfc1918_nets=""

	local config_file="$1"

	if [ ! -f /etc/config/dhcp ]; then
		return 0
	fi

	local dyn_file="$(mktemp -u /tmp/dhcpd.XXXXXX)"

	. /lib/functions.sh
	. /lib/functions/ipv4.sh
	. /lib/functions/network.sh
	. /usr/share/libubox/jshn.sh

	mkdir -p "$keadir"

	config_load dhcp

	json_init
	json_add_object "Dhcp4"

	general_config

	if [ $dynamicdns -eq 1 ]; then
		cat <<EOF > "$dyn_file"
; Generated by $prog at $(date)

ttl $TTL

EOF
	fi

	local subnet4_id=0
	json_add_array "subnet4"

	config_foreach dhcpd_add dhcp

	static_hosts

	json_close_array	# subnet4

	json_add_array "host-reservation-identifiers"
	json_add_names "hw-address" "client-id"
	json_close_array	# host-reservation-identifiers

	# json_add_string "reservation-mode" "global"

	json_add_boolean "reservations-in-subnet" 1

	# plug the interfaces back in
	json_select "interfaces-config"
	json_select "interfaces"
	json_add_names $dhcp_ifs
	json_select ..
	json_select ..

	json_close_object	# Dhcp4

	# the rest just generate DNS records
	static_cnames

	static_domains

	static_mxhosts

	static_srvhosts

	write_zones

	# not running on any interfaces
	[ -z "$dhcp_ifs" ] && return 1

	rfc1918_nets="${rfc1918_nets// /$NL}"
	rfc1918_nets="$(echo "$rfc1918_nets" | sort -V | uniq)"
	rfc1918_nets="${rfc1918_nets//$NL/ }"

	if [ $dynamicdns -eq 1 ]; then
		local args=

		no_ipv6 && args="-4"

		nsupdate -l -v $args "$dyn_file"

	fi

	rm -f "$dyn_file"

	json_pretty
	json_dump | sed 's/\t/  /g' > "$config_file"

	return 0
}

main "$@"

