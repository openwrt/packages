#!/bin/sh /etc/rc.common
# Copyright (C) 2008-2017 OpenWrt.org

START=65

SERVICE_DAEMONIZE=1
SERVICE_WRITE_PID=1

OLSRD_OLSRD_SCHEMA='ignore:internal config_file:internal DebugLevel=0 AllowNoInt=yes'
OLSRD_IPCCONNECT_SCHEMA='ignore:internal Host:list Net:list2'
OLSRD_LOADPLUGIN_SCHEMA='ignore:internal library:internal Host4:list Net4:list2 Host:list Net:list2 Host6:list Net6:list2 Ping:list redistribute:list NonOlsrIf:list name:list lat lon latlon_infile HNA:list2 hosts:list2 ipv6only:bool'
OLSRD_INTERFACE_SCHEMA='ignore:internal interface:internal AutoDetectChanges:bool LinkQualityMult:list2'
OLSRD_INTERFACE_DEFAULTS_SCHEMA='AutoDetectChanges:bool'

T='	'
N='
'

log() {
	logger -t olsrd -p daemon.info -s "${initscript}: $*"
}

error() {
        logger -t olsrd -p daemon.err -s "${initscript}: ERROR: $*"
}

warn() {
        logger -t olsrd -p daemon.warn -s "${initscript}: WARNING: $*"
}

validate_varname() {
	local varname="$1"
	[ -z "$varname" -o "$varname" != "${varname%%[!A-Za-z0-9_]*}" ] && return 1
	return 0
}

validate_olsrd_option() {
	local str="$1"
	[ -z "$str" -o "$str" != "${str%%[! 	0-9A-Za-z.%/|:_-]*}" ] && return 1
	return 0
}

system_config() {
	local cfg="$1"
	local cfgt hostname latlon oldIFS

	config_get cfgt "$cfg" TYPE

	if [ "$cfgt" = "system" ]; then
		config_get hostname "$cfg" hostname
		hostname="${hostname:-OpenWrt}"
		SYSTEM_HOSTNAME="$hostname"
	fi

	if [ -z "$SYSTEM_LAT" -o -z "$SYSTEM_LON" ]; then
		config_get latlon "$cfg" latlon
		oldIFS="$IFS"; IFS=" ${T}${N},"; set -- $latlon; IFS="$oldIFS"
		SYSTEM_LAT="$1"
		SYSTEM_LON="$2"
	fi

	if [ -z "$SYSTEM_LAT" -o -z "$SYSTEM_LON" ]; then
		config_get latlon "$cfg" latitude
		SYSTEM_LAT="$latlon"
		config_get latlon "$cfg" longitude
		SYSTEM_LON="$latlon"
	fi
}

olsrd_find_config_file() {
	local cfg="$1"
	validate_varname "$cfg" || return 0

	config_get_bool ignore "$cfg" ignore 0
	[ "$ignore" -ne 0 ] && return 0
	config_get OLSRD_CONFIG_FILE "$cfg" config_file

	return 0
}

warning_invalid_value() {
	local funcname="warning_invalid_value"
	local package="$1"
	validate_varname "$package" || package=
	local config="$2"
	validate_varname "$config" || config=
	local option="$3"
	validate_varname "$option" || option=

	if [ -n "$package" -a -n "$config" ]; then
		log "$funcname() in option '$package.$config${option:+.}$option', skipped"
	else
		log "$funcname() skipped"
	fi

	return 0
}

olsrd_write_option() {
	local param="$1"
	local cfg="$2"
	validate_varname "$cfg" || return 1
	local option="$3"
	validate_varname "$option" || return 1
	local value="$4"
	local option_type="$5"

	if [ "$option_type" = bool ]; then
		case "$value" in
			1|on|true|enabled|yes) value=yes;;
			0|off|false|disabled|no) value=no;;
			*) warning_invalid_value olsrd "$cfg" "$option"; return 1;;
		esac
	fi

	if ! validate_olsrd_option "$value"; then
		warning_invalid_value olsrd "$cfg" "$option"
		return 1
	fi

	if [ "$value" != "${value%%[G-Zg-z_-]*}" ]; then
		if [ "$option" != "Ip6AddrType" -a "$option" != "LinkQualityMult" -a "$value" != "yes" -a "$value" != "no" ]; then
			value="\"$value\""
		fi
	fi

	printf '%s' "${N}$param$option $value"
}

olsrd_write_plparam() {
	local funcname="olsrd_write_plparam"
	local param="$1"
	local cfg="$2"
	local option="$3"
	local value="$4"
	local option_type="$5"
	local _option oldIFS

	validate_varname "$cfg" || return 1
	validate_varname "$option" || return 1

	if [ "$option_type" = bool ]; then
		case "$value" in
			1|on|true|enabled|yes) value=yes;;
			0|off|false|disabled|no) value=no;;
			*) warning_invalid_value olsrd "$cfg" "$option"; return 1;;
		esac
	fi

	if ! validate_olsrd_option "$value"; then
		warning_invalid_value olsrd "$cfg" "$option"
		return 1
	fi

	oldIFS="$IFS"
	IFS='-_'
	set -- $option
	option="$*"
	IFS="$oldIFS"
	_option="$option"

	if [ "$option" = 'hosts' ]; then
		set -- $value
		option="$1"
		shift
		value="$*"
	fi

	if [ "$option" = 'NonOlsrIf' ]; then
		if validate_varname "$value"; then
			if network_get_device ifname "$value"; then
				log "$funcname() Info: mdns Interface '$value' ifname '$ifname' found"
			else
				log "$funcname() Warning: mdns Interface '$value' not found, skipped"
			fi
		else
			warning_invalid_value olsrd "$cfg" "NonOlsrIf"
		fi

		[ -z "$ifname" ] || value=$ifname
	fi

	printf '%s' "${N}${param}PlParam \"$option\" \"$value\""
}

config_update_schema() {
	local schema_varname="$1"
	local command="$2"
	local option="$3"
	local value="$4"
	local schema
	local cur_option

	validate_varname "$schema_varname" || return 1
	validate_varname "$command" || return 1
	validate_varname "$option" || return 1

	case "$varname" in
		*_LENGTH) return 0;;
		*_ITEM*) return 0;;
	esac

	eval "export -n -- \"schema=\${$schema_varname}\""

	for cur_option in $schema; do
		[ "${cur_option%%[:=]*}" = "$option" ] && return 0
	done

	if [ "$command" = list ]; then
		set -- $value
		if [ "$#" -ge "3" ]; then
			schema_entry="$option:list3"
		elif [ "$#" -ge "2" ]; then
			schema_entry="$option:list2"
		else
			schema_entry="$option:list"
		fi
	else
		schema_entry="$option"
	fi

	append "$schema_varname" "$schema_entry"

	return 0
}

config_write_options() {
	local funcname="config_write_options"
	local schema="$1"
	local cfg="$2"
	validate_varname "$cfg" || return 1
	local write_func="$3"
	[ -z "$write_func" ] && output_func=echo
	local write_param="$4"

	local schema_entry option option_length option_type default value list_size list_item list_value i position speed oldIFS
	local list_speed_vars="HelloInterval HelloValidityTime TcInterval TcValidityTime MidInterval MidValidityTime HnaInterval HnaValidityTime"

	get_value_for_entry()
	{
		local schema_entry="$1"

		default="${schema_entry#*[=]}"
		[ "$default" = "$schema_entry" ] && default=
		option="${schema_entry%%[=]*}"

		oldIFS="$IFS"; IFS=':'; set -- $option; IFS="$oldIFS"
		option="$1"
		option_type="$2"

		validate_varname "$option" || return 1
		[ -z "$option_type" ] || validate_varname "$option_type" || return 1
		[ "$option_type" = internal ] && return 1

		config_get value "$cfg" "$option"
		[ "$option" = "speed" ] && return 1

		return 0
	}

	already_in_schema()
	{
		case " $schema " in
			*" $1 "*)
				return 0
			;;
			*)
				return 1
			;;
		esac
	}

	already_in_schema "speed" && {
		get_value_for_entry "speed"

		if test 2>/dev/null "$value" -gt 0 -a "$value" -le 20 ; then
			speed="$value"
		else
			log "$funcname() Warning: invalid speed-value: '$value' - allowed integers: 1...20, fallback to 6"
			speed=6
		fi

		for schema_entry in $list_speed_vars; do {
			already_in_schema "$schema_entry" || schema="$schema $schema_entry"
		} done
	}

	for schema_entry in $schema; do
		if [ -n "$speed" ]; then		# like sven-ola freifunk firmware fff-1.7.4
			case "$schema_entry" in
				HelloInterval)
					value="$(( speed / 2 + 1 )).0"
				;;
				HelloValidityTime)
					value="$(( speed * 25 )).0"
				;;
				TcInterval)	# todo: not fisheye? -> $(( speed * 2 ))
					value=$(( speed / 2 ))
					[ $value -eq 0 ] && value=1
					value="$value.0"
				;;
				TcValidityTime)
					value="$(( speed * 100 )).0"
				;;
				MidInterval)
					value="$(( speed * 5 )).0"
				;;
				MidValidityTime)
					value="$(( speed * 100 )).0"
				;;
				HnaInterval)
					value="$(( speed * 2 )).0"
				;;
				HnaValidityTime)
					value="$(( speed * 25 )).0"
				;;
				*)
					get_value_for_entry "$schema_entry" || continue
				;;
			esac

			is_speed_var()
			{
				case " $list_speed_vars " in
					*" $1 "*)
						return 0
					;;
					*)
						return 1
					;;
				esac
			}

			is_speed_var "$schema_entry" && option="$schema_entry"
		else
			get_value_for_entry "$schema_entry" || continue
		fi

		if [ -z "$value" ]; then
			oldIFS="$IFS"; IFS='+'; set -- $default; IFS="$oldIFS"
			value=$*
		elif [ "$value" = '-' -a -n "$default" ]; then
			continue
		fi

		[ -z "$value" ] && continue

		case "$option_type" in
			list) list_size=1;;
			list2) list_size=2;;
			list3) list_size=3;;
			*) list_size=0;;
		esac

		if [ "$list_size" -gt 0 ]; then
			config_get option_length "$cfg" "${option}_LENGTH"
			if [ -n "$option_length" ]; then
				i=1
				while [ "$i" -le "$option_length" ]; do
					config_get list_value "$cfg" "${option}_ITEM$i"
					"$write_func" "$write_param" "$cfg" "$option" "$list_value" "$option_type" || break
					i=$((i + 1))
				done
			else
				list_value=
				i=0
				for list_item in $value; do
					append "list_value" "$list_item"
					i=$((i + 1))
					position=$((i % list_size))
					if [ "$position" -eq 0 ]; then
						"$write_func" "$write_param" "$cfg" "$option" "$list_value" "$option_type" || break
						list_value=
					fi
				done
				[ "$position" -ne 0 ] && "$write_func" "$write_param" "$cfg" "$option" "$list_value" "$option_type"
			fi
		else
			"$write_func" "$write_param" "$cfg" "$option" "$value" "$option_type"
		fi
	done

	return 0
}

olsrd_write_olsrd() {
	local cfg="$1"
	validate_varname "$cfg" || return 0
	local ignore

	config_get_bool ignore "$cfg" ignore 0
	[ "$ignore" -ne 0 ] && return 0

	[ "$OLSRD_COUNT" -gt 0 ] && return 0

	config_get smartgateway "$cfg" SmartGateway
	config_get smartgatewayuplink "$cfg" SmartGatewayUplink
	export smartgateway
	export smartgatewayuplink

	config_write_options "$OLSRD_OLSRD_SCHEMA" "$cfg" olsrd_write_option
	echo
	OLSRD_COUNT=$((OLSRD_COUNT + 1))
	return 0
}

olsrd_write_ipcconnect() {
	local cfg="$1"
	validate_varname "$cfg" || return 0
	local ignore

	config_get_bool ignore "$cfg" ignore 0
	[ "$ignore" -ne 0 ] && return 0

	[ "$IPCCONNECT_COUNT" -gt 0 ] && return 0

	printf '%s' "${N}IpcConnect${N}{"
	config_write_options "$OLSRD_IPCCONNECT_SCHEMA" "$cfg" olsrd_write_option "${T}"
	echo "${N}}"
	IPCCONNECT_COUNT=$((IPCCONNECT_COUNT + 1))
}

olsrd_write_hna4() {
	local cfg="$1"
	validate_varname "$cfg" || return 0
	local ignore

	config_get_bool ignore "$cfg" ignore 0
	[ "$ignore" -ne 0 ] && return 0

	config_get netaddr "$cfg" netaddr
	if ! validate_olsrd_option "$netaddr"; then
		warning_invalid_value olsrd "$cfg" "netaddr"
		return 0
	fi

	config_get netmask "$cfg" netmask
	if ! validate_olsrd_option "$netmask"; then
		warning_invalid_value olsrd "$cfg" "netmask"
		return 0
	fi

	[ "$HNA4_COUNT" -le 0 ] && printf '%s' "${N}Hna4${N}{"
	printf '%s' "${N}${T}${T}$netaddr $netmask"
	HNA4_COUNT=$((HNA4_COUNT + 1))
}

olsrd_write_hna6() {
	local cfg="$1"
	validate_varname "$cfg" || return 0
	local ignore

	config_get_bool ignore "$cfg" ignore 0
	[ "$ignore" -ne 0 ] && return 0

	config_get netaddr "$cfg" netaddr
	if ! validate_olsrd_option "$netaddr"; then
		warning_invalid_value olsrd "$cfg" "netaddr"
		return 0
	fi

	config_get prefix "$cfg" prefix
	if ! validate_olsrd_option "$prefix"; then
		warning_invalid_value olsrd "$cfg" "prefix"
		return 0
	fi

	[ "$HNA6_COUNT" -le 0 ] && printf '%s' "${N}Hna6${N}{"
	printf '%s' "${N}${T}${T}$netaddr $prefix"
	HNA6_COUNT=$((HNA6_COUNT + 1))
}

find_most_recent_plugin_libary()
{
	local library="$1"	# e.g. 'olsrd_dyn_gw' or 'olsrd_txtinfo.so.1.1'
	local file file_fullpath unixtime

	for file in "/lib/$library"* "/usr/lib/$library"* "/usr/local/lib/$library"*; do {
		[ -f "$file" ] && {
			file_fullpath="$file"
			file="$( basename "$file" )"
			# make sure that we do not select
			# 'olsrd_dyn_gw_plain.so.0.4' if user wants
			# 'olsrd_dyn_gw.so.0.5' -> compare part before 1st dot
			[ "${library%%.*}" = "${file%%.*}" ] && {
				unixtime="$( date +%s -r "$file_fullpath" )"
				echo "$unixtime $file"
			}
		}
	} done | sort -n | tail -n1 | cut -d' ' -f2
}

olsrd_write_loadplugin()
{
	local funcname='olsrd_write_loadplugin'
	local cfg="$1"
	local ignore name suffix lat lon latlon_infile

	validate_varname "$cfg" || return 0

	config_get_bool ignore "$cfg" ignore 0
	[ "$ignore" -ne 0 ] && return 0

	# e.g. olsrd_txtinfo.so.1.1 or 'olsrd_txtinfo'
	config_get library "$cfg" library

	library="$( find_most_recent_plugin_libary "$library" )"
	if [ -z "$library" ]; then
		log "$funcname() Warning: Plugin library '$library' not found, skipped"
		return 0
	else
		library="$( basename "$library" )"
	fi

	validate_olsrd_option "$library" || {
		warning_invalid_value olsrd "$cfg" 'library'
		return 0
	}

	case "$library" in
		'olsrd_nameservice.'*)
			config_get name "$cfg" name
			[ -z "$name" ] && config_set "$cfg" name $SYSTEM_HOSTNAME

			config_get suffix "$cfg" suffix
			[ -z "$suffix" ] && config_set "$cfg" suffix '.olsr'

			config_get lat "$cfg" lat
			config_get lon "$cfg" lon
			config_get latlon_infile "$cfg" latlon_infile
			if [ \( -z "$lat" -o -z "$lat" \) -a -z "$latlon_infile" ]; then
				if [ -f '/var/run/latlon.txt' ]; then
					config_set "$cfg" lat ''
					config_set "$cfg" lon ''
					config_set "$cfg" latlon_infile '/var/run/latlon.txt'
				else
					config_set "$cfg" lat "$SYSTEM_LAT"
					config_set "$cfg" lon "$SYSTEM_LON"
				fi
			fi

			for f in latlon_file hosts_file services_file resolv_file macs_file; do
				config_get $f "$cfg" $f
			done

			[ -z "$latlon_file" ] && config_set "$cfg" latlon_file '/var/run/latlon.js'
		;;
		'olsrd_watchdog.'*)
			config_get wd_file "$cfg" file
		;;
	esac

	printf '%s' "${N}LoadPlugin \"$library\"${N}{"
	config_write_options "$OLSRD_LOADPLUGIN_SCHEMA" "$cfg" olsrd_write_plparam "${T}"
	echo "${N}}"
}

olsrd_write_interface() {
	local funcname="olsrd_write_interface"
	local cfg="$1"
	validate_varname "$cfg" || return 0
	local ignore
	local interfaces
	local interface
	local ifnames

	config_get_bool ignore "$cfg" ignore 0
	[ "$ignore" -ne 0 ] && return 0

	ifnames=
	config_get interfaces "$cfg" interface

	for interface in $interfaces; do
		if validate_varname "$interface"; then
			if network_get_device IFNAME "$interface"; then
				ifnames="$ifnames \"$IFNAME\""
				ifsglobal="$ifsglobal $IFNAME"
			elif network_get_physdev IFNAME "$interface"; then
				local proto="$(uci -q get network.${interface}.proto)"
				if [ "$proto" = "static" -o "$proto" = "none" ]; then
					ifnames="$ifnames \"$IFNAME\""
					ifsglobal="$ifsglobal $IFNAME"
				fi
			else
				log "$funcname() Warning: Interface '$interface' not found, skipped"
			fi
		else
			warning_invalid_value olsrd "$cfg" "interface"
		fi
	done

	[ -z "$ifnames" ] && return 0

	printf '%s' "${N}Interface$ifnames${N}{"
	config_write_options "$OLSRD_INTERFACE_SCHEMA" "$cfg" olsrd_write_option "${T}"
	echo "${N}}"
	INTERFACES_COUNT=$((INTERFACES_COUNT + 1))
}

olsrd_write_interface_defaults() {
	local cfg="$1"
	validate_varname "$cfg" || return 0

	printf '%s' "${N}InterfaceDefaults$ifnames${N}{"
	config_write_options "$OLSRD_INTERFACE_DEFAULTS_SCHEMA" "$cfg" olsrd_write_option "${T}"
	echo "${N}}"

	return 1
}

olsrd_update_schema() {
	local command="$1"
	local varname="$2"
	local value="$3"
	local cfg="$CONFIG_SECTION"
	local cfgt

	validate_varname "$command" || return 0
	validate_varname "$varname" || return 0

	config_get cfgt "$cfg" TYPE
	case "$cfgt" in
		olsrd) config_update_schema OLSRD_OLSRD_SCHEMA "$command" "$varname" "$value";;
		IpcConnect) config_update_schema OLSRD_IPCCONNECT_SCHEMA "$command" "$varname" "$value";;
		LoadPlugin) config_update_schema OLSRD_LOADPLUGIN_SCHEMA "$command" "$varname" "$value";;
		Interface) config_update_schema OLSRD_INTERFACE_SCHEMA "$command" "$varname" "$value";;
		InterfaceDefaults) config_update_schema OLSRD_INTERFACE_DEFAULTS_SCHEMA "$command" "$varname" "$value";;
	esac

	return 0
}

olsrd_write_config() {
	OLSRD_COUNT=0
	config_foreach olsrd_write_olsrd olsrd
	IPCCONNECT_COUNT=0
	config_foreach olsrd_write_ipcconnect IpcConnect
	HNA4_COUNT=0
	config_foreach olsrd_write_hna4 Hna4
	[ "$HNA4_COUNT" -gt 0 ] && echo "${N}}"
	HNA6_COUNT=0
	config_foreach olsrd_write_hna6 Hna6
	[ "$HNA6_COUNT" -gt 0 ] && echo "${N}}"
	config_foreach olsrd_write_loadplugin LoadPlugin
	INTERFACES_COUNT=0
	config_foreach olsrd_write_interface_defaults InterfaceDefaults
	config_foreach olsrd_write_interface Interface
	echo

	return 0
}

get_wan_ifnames()
{
	local wanifnames word catch_next

	command -v ip >/dev/null || return 1

	set -- $( ip route list exact 0.0.0.0/0 table all )
	for word in $*; do
		case "$word" in
			dev)
				catch_next="true"
			;;
			*)
				[ -n "$catch_next" ] && {
					case "$wanifnames" in
						*" $word "*)
						;;
						*)
							wanifnames="$wanifnames $word "
						;;
					esac

					catch_next=
				}
			;;
		esac
	done

	echo "$wanifnames"
}

olsrd_setup_smartgw_rules() {
	local funcname="olsrd_setup_smartgw_rules"
	local file=

	for file in /etc/modules.d/[0-9]*-ipip; do :; done
	[ -e "$file" ] || {
		log "$funcname() Warning: kmod-ipip is missing. SmartGateway will not work until you install it."
		return 1
	}

	local wanifnames="$( get_wan_ifnames )"

	if [ -z "$wanifnames" ]; then
		nowan=1
	else
		nowan=0
	fi

	IP4T="$( command -v iptables )"
	IP6T="$( command -v ip6tables )"

	# Delete smartgw firewall rules first
	if [ "$UCI_CONF_NAME" = "olsrd6" ]; then
		while $IP6T -D forwarding_rule -o tnl_+ -j ACCEPT 2> /dev/null; do :;done
		for IFACE in $wanifnames; do
			while $IP6T -D forwarding_rule -i tunl0 -o $IFACE -j ACCEPT 2> /dev/null; do :; done
		done
		for IFACE in $ifsglobal; do
			while $IP6T -D input_rule -i $IFACE -p 4 -j ACCEPT 2> /dev/null; do :; done
		done
	else
		while $IP4T -D forwarding_rule -o tnl_+ -j ACCEPT 2> /dev/null; do :;done
		for IFACE in $wanifnames; do
			while $IP4T -D forwarding_rule -i tunl0 -o $IFACE -j ACCEPT 2> /dev/null; do :; done
		done
		for IFACE in $ifsglobal; do
			while $IP4T -D input_rule -i $IFACE -p 4 -j ACCEPT 2> /dev/null; do :; done
		done
		while $IP4T -t nat -D postrouting_rule -o tnl_+ -j MASQUERADE 2> /dev/null; do :;done
	fi

	# var 'smartgateway' + 'smartgatewayuplink' build in olsrd_write_olsrd()
	if [ "$smartgateway" = "yes" ]; then
		log "$funcname() Notice: Inserting firewall rules for SmartGateway"

		if [ ! "$smartgatewayuplink" = "none" ]; then
			if [ "$smartgatewayuplink" = "ipv4" ]; then
				# Allow everything to be forwarded to tnl_+ and use NAT for it
				$IP4T -I forwarding_rule -o tnl_+ -j ACCEPT
				$IP4T -t nat -I postrouting_rule -o tnl_+ -j MASQUERADE
				# Allow forwarding from tunl0 to (all) wan-interfaces
				if [ "$nowan" = '0' ]; then
					for IFACE in $wanifnames; do
						$IP4T -A forwarding_rule -i tunl0 -o $IFACE -j ACCEPT
					done
				fi
				# Allow incoming ipip on all olsr-interfaces
				for IFACE in $ifsglobal; do
					$IP4T -I input_rule -i $IFACE -p 4 -j ACCEPT
				done
			elif [ "$smartgatewayuplink" = "ipv6" ]; then
				$IP6T -I forwarding_rule -o tnl_+ -j ACCEPT
				if [ "$nowan" = '0' ]; then
					for IFACE in $wanifnames; do
						$IP6T -A forwarding_rule -i tunl0 -o $IFACE -j ACCEPT
					done
				fi
				for IFACE in $ifsglobal; do
					$IP6T -I input_rule -i $IFACE -p 4 -j ACCEPT
				done
			else
				$IP4T -t nat -I postrouting_rule -o tnl_+ -j MASQUERADE
				for IPT in $IP4T $IP6T; do
					$IPT -I forwarding_rule -o tnl_+ -j ACCEPT
					if [ "$nowan" = '0' ]; then
						for IFACE in $wanifnames; do
							$IPT -A forwarding_rule -i tunl0 -o $IFACE -j ACCEPT
						done
					fi
					for IFACE in $ifsglobal; do
						$IPT -I input_rule -i $IFACE -p 4 -j ACCEPT
					done
				done
			fi
		fi
	fi
}

start() {
	SYSTEM_HOSTNAME=
	SYSTEM_LAT=
	SYSTEM_LON=
	config_load system
	config_foreach system_config system

	option_cb() {
		olsrd_update_schema "option" "$@"
	}

	list_cb() {
		olsrd_update_schema "list" "$@"
	}

	. /lib/functions/network.sh

	config_load $UCI_CONF_NAME
	reset_cb

	OLSRD_CONFIG_FILE=
	config_foreach olsrd_find_config_file olsrd

	if [ -z "$OLSRD_CONFIG_FILE" ]; then
		mkdir -p -- /var/etc/
		olsrd_write_config > /var/etc/$UCI_CONF_NAME.conf || return 1
		if [ "$INTERFACES_COUNT" -gt 0 -a "$OLSRD_COUNT" -gt 0 ]; then
			OLSRD_CONFIG_FILE=/var/etc/$UCI_CONF_NAME.conf
		fi
	fi

	[ -z "$OLSRD_CONFIG_FILE" ] && return 1

	SERVICE_PID_FILE="$PID"
	if service_check /usr/sbin/olsrd; then
		error "there is already an instance of $UCI_CONF_NAME running (pid: '$(cat $PID)'), not starting."
		return 1
	else
		service_start /usr/sbin/olsrd -f "$OLSRD_CONFIG_FILE" -nofork
		sleep 1
		service_check /usr/sbin/olsrd || {
			log "startup-error: check via: '/usr/sbin/olsrd -f \"$OLSRD_CONFIG_FILE\" -nofork'"
		}
	fi

	olsrd_setup_smartgw_rules
}

stop() {
	SERVICE_PID_FILE="$PID"
	service_stop /usr/sbin/olsrd
}
