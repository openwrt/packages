#!/bin/sh
# Copyright (C) 2016-2019 Aleksander Morgado <aleksander@aleksander.es>

[ -x /usr/bin/mmcli ] || exit 0
[ -x /usr/sbin/pppd ] || exit 0

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. ../netifd-proto.sh
	. ./ppp.sh
	. /usr/share/ModemManager/modemmanager.common
	init_proto "$@"
}

cdr2mask ()
{
	# Number of args to shift, 255..255, first non-255 byte, zeroes
	set -- $(( 5 - ($1 / 8) )) 255 255 255 255 $(( (255 << (8 - ($1 % 8))) & 255 )) 0 0 0
	if [ "$1" -gt 1 ]
	then
		shift "$1"
	else
		shift
	fi
	echo "${1-0}"."${2-0}"."${3-0}"."${4-0}"
}

modemmanager_cleanup_connection() {
	local modemstatus="$1"

	local bearercount idx bearerpath

	bearercount=$(modemmanager_get_field "${modemstatus}" "modem.generic.bearers.length")

	# do nothing if no bearers reported
	[ -n "${bearercount}" ] && [ "$bearercount" -ge 1 ] && {
		# explicitly disconnect just in case
		mmcli --modem="${device}" --simple-disconnect >/dev/null 2>&1
		# and remove all bearer objects, if any found
		idx=1
		while [ $idx -le "$bearercount" ]; do
			bearerpath=$(modemmanager_get_field "${modemstatus}" "modem.generic.bearers.value\[$idx\]")
			mmcli --modem "${device}" --delete-bearer="${bearerpath}" >/dev/null 2>&1
			idx=$((idx + 1))
		done
	}
}

modemmanager_connected_method_ppp_ipv4() {
	local interface="$1"
	local ttyname="$2"
	local username="$3"
	local password="$4"
	local allowedauth="$5"

	# all auth types are allowed unless a user given list is given
	local authopts
	local pap=1
	local chap=1
	local mschap=1
	local mschapv2=1
	local eap=1

	[ -n "$allowedauth" ] && {
		pap=0 chap=0 mschap=0 mschapv2=0 eap=0
		for auth in $allowedauth; do
			case $auth in
				"pap") pap=1 ;;
				"chap") chap=1 ;;
				"mschap") mschap=1 ;;
				"mschapv2") mschapv2=1 ;;
				"eap") eap=1 ;;
				*) ;;
			esac
		done
	}

	[ $pap -eq 1 ] || append authopts "refuse-pap"
	[ $chap -eq 1 ] || append authopts "refuse-chap"
	[ $mschap -eq 1 ] || append authopts "refuse-mschap"
	[ $mschapv2 -eq 1 ] || append authopts "refuse-mschap-v2"
	[ $eap -eq 1 ] || append authopts "refuse-eap"

	proto_run_command "${interface}" /usr/sbin/pppd \
		"${ttyname}" \
		ifname "ppp-${interface}" \
		115200 \
		nodetach \
		noaccomp \
		nobsdcomp \
		nopcomp \
		novj \
		noauth \
		$authopts \
		${username:+ user "$username"} \
		${password:+ password "$password"} \
		lcp-echo-failure 5 \
		lcp-echo-interval 15 \
		lock \
		crtscts \
		nodefaultroute \
		usepeerdns \
		ipparam "${interface}" \
		ip-up-script /lib/netifd/ppp-up \
		ip-down-script /lib/netifd/ppp-down
}

modemmanager_disconnected_method_ppp_ipv4() {
	local interface="$1"

	echo "running disconnection (ppp method)"

	[ -n "${ERROR}" ] && {
		local errorstring
		errorstring=$(ppp_exitcode_tostring "${ERROR}")
		case "$ERROR" in
			0)
				;;
			2)
				proto_notify_error "$interface" "$errorstring"
				proto_block_restart "$interface"
				;;
			*)
				proto_notify_error "$interface" "$errorstring"
				;;
		esac
	} || echo "pppd result code not given"

	proto_kill_command "$interface"
}

modemmanager_connected_method_dhcp_ipv4() {
	local interface="$1"
	local wwan="$2"
	local metric="$3"

	proto_init_update "${wwan}" 1
	proto_set_keep 1
	proto_send_update "${interface}"

	json_init
	json_add_string name "${interface}_4"
	json_add_string ifname "@${interface}"
	json_add_string proto "dhcp"
	proto_add_dynamic_defaults
	[ -n "$metric" ] && json_add_int metric "${metric}"
	json_close_object
	ubus call network add_dynamic "$(json_dump)"
}

modemmanager_connected_method_static_ipv4() {
	local interface="$1"
	local wwan="$2"
	local address="$3"
	local prefix="$4"
	local gateway="$5"
	local mtu="$6"
	local dns1="$7"
	local dns2="$8"
	local metric="$9"

	local mask=""

	[ -n "${address}" ] || {
		proto_notify_error "${interface}" ADDRESS_MISSING
		return
	}

	[ -n "${prefix}" ] || {
		proto_notify_error "${interface}" PREFIX_MISSING
		return
	}
	mask=$(cdr2mask "${prefix}")

	[ -n "${mtu}" ] && /sbin/ip link set dev "${wwan}" mtu "${mtu}"

	proto_init_update "${wwan}" 1
	proto_set_keep 1
	echo "adding IPv4 address ${address}, netmask ${mask}"
	proto_add_ipv4_address "${address}" "${mask}"
	[ -n "${gateway}" ] && {
		echo "adding default IPv4 route via ${gateway}"
		proto_add_ipv4_route "0.0.0.0" "0" "${gateway}" "${address}"
	}
	[ -n "${dns1}" ] && {
		echo "adding primary DNS at ${dns1}"
		proto_add_dns_server "${dns1}"
	}
	[ -n "${dns2}" ] && {
		echo "adding secondary DNS at ${dns2}"
		proto_add_dns_server "${dns2}"
	}
	[ -n "$metric" ] && json_add_int metric "${metric}"
	proto_send_update "${interface}"
}

modemmanager_connected_method_dhcp_ipv6() {
	local interface="$1"
	local wwan="$2"
	local metric="$3"

	proto_init_update "${wwan}" 1
	proto_set_keep 1
	proto_send_update "${interface}"

	json_init
	json_add_string name "${interface}_6"
	json_add_string ifname "@${interface}"
	json_add_string proto "dhcpv6"
	proto_add_dynamic_defaults
	json_add_string extendprefix 1 # RFC 7278: Extend an IPv6 /64 Prefix to LAN
	[ "$sourcefilter" = "0" ] && json_add_boolean sourcefilter "0"
	[ -n "$metric" ] && json_add_int metric "${metric}"
	json_close_object
	ubus call network add_dynamic "$(json_dump)"
}

modemmanager_connected_method_static_ipv6() {
	local interface="$1"
	local wwan="$2"
	local address="$3"
	local prefix="$4"
	local gateway="$5"
	local mtu="$6"
	local dns1="$7"
	local dns2="$8"
	local metric="$9"

	[ -n "${address}" ] || {
		proto_notify_error "${interface}" ADDRESS_MISSING
		return
	}

	[ -n "${prefix}" ] || {
		proto_notify_error "${interface}" PREFIX_MISSING
		return
	}

	[ -n "${mtu}" ] && /sbin/ip link set dev "${wwan}" mtu "${mtu}"

	proto_init_update "${wwan}" 1
	proto_set_keep 1
	echo "adding IPv6 address ${address}, prefix ${prefix}"
	proto_add_ipv6_address "${address}" "128"
	proto_add_ipv6_prefix "${address}/${prefix}"
	[ -n "${gateway}" ] && {
		echo "adding default IPv6 route via ${gateway}"
		proto_add_ipv6_route "${gateway}" "128"
		[ "$sourcefilter" = "0" ] && {
			proto_add_ipv6_route "::0" "0" "${gateway}"
		} || {
			proto_add_ipv6_route "::0" "0" "${gateway}" "" "" "${address}/${prefix}"
		}
	}
	[ -n "${dns1}" ] && {
		echo "adding primary DNS at ${dns1}"
		proto_add_dns_server "${dns1}"
	}
	[ -n "${dns2}" ] && {
		echo "adding secondary DNS at ${dns2}"
		proto_add_dns_server "${dns2}"
	}
	[ -n "$metric" ] && json_add_int metric "${metric}"
	proto_send_update "${interface}"
}

proto_modemmanager_init_config() {
	available=1
	no_device=1
	proto_config_add_string device
	proto_config_add_string apn
	proto_config_add_string 'allowedauth:list(string)'
	proto_config_add_string username
	proto_config_add_string password
	proto_config_add_string allowedmode
	proto_config_add_string preferredmode
	proto_config_add_string pincode
	proto_config_add_string iptype
	proto_config_add_boolean sourcefilter
	proto_config_add_string plmn
	proto_config_add_int signalrate
	proto_config_add_boolean lowpower
	proto_config_add_boolean allow_roaming
	proto_config_add_boolean force_connection
	proto_config_add_string init_epsbearer
	proto_config_add_string init_iptype
	proto_config_add_string 'init_allowedauth:list(string)'
	proto_config_add_string init_password
	proto_config_add_string init_user
	proto_config_add_string init_apn
	proto_config_add_defaults
}

# Append param to the global 'connectargs' variable.
append_param() {
	local param="$1"

	[ -z "$param" ] && return
	[ -z "$connectargs" ] || connectargs="${connectargs},"
	connectargs="${connectargs}${param}"
}

modemmanager_set_allowed_mode() {
	local device="$1"
	local interface="$2"
	local allowedmode="$3"

	echo "setting allowed mode to '${allowedmode}'"
	mmcli --modem="${device}" --set-allowed-modes="${allowedmode}" || {
		proto_notify_error "${interface}" MM_INVALID_ALLOWED_MODES_LIST
		proto_block_restart "${interface}"
		return 1
	}
}

modemmanager_check_state_failed() {
	local device="$1"
	local interface="$2"
	local modemstatus="$3"

	local reason

	reason="$(modemmanager_get_field "${modemstatus}" "modem.generic.state-failed-reason")"

	case "$reason" in
		"sim-missing")
			echo "SIM missing"
			proto_notify_error "${interface}" MM_FAILED_REASON_SIM_MISSING
			proto_block_restart "${interface}"
			return 1
			;;
		*)
			proto_notify_error "${interface}" MM_FAILED_REASON_UNKNOWN
			proto_block_restart "${interface}"
			return 1
			;;
	esac
}

modemmanager_check_state_lock_simpin() {
	local interface="$1"
	local unlock_value="$2"

	[ $unlock_value -ge 2 ] && return 0

	echo "please check PIN (remaining attempts: ${unlock_value})"
	proto_notify_error "${interface}" MM_CHECK_UNLOCK_PIN
	proto_block_restart "${interface}"
	return 1
}

modemmanager_check_state_lock_simpuk() {
	local interface="$1"
	local unlock_value="$2"

	echo "unlock with PUK required (remaining attempts: ${unlock_value})"
	proto_notify_error "${interface}" MM_CHECK_UNLOCK_PIN
	proto_block_restart "${interface}"
	return 1
}

modemmanager_check_state_lock_sim() {
	local interface="$1"
	local unlock_lock="$2"
	local unlock_value="$3"

	case "$unlock_lock" in
		"sim-pin")
			modemmanager_check_state_lock_simpin \
				"$interface" \
				"$unlock_value"
			[ "$?" -ne "0" ] && return 1
			;;
		"sim-puk")
			modemmanager_check_state_lock_simpuk \
				"$interface" \
				"$unlock_value"
			[ "$?" -ne "0" ] && return 1
			;;
		*)
			echo "PIN/PUK check '$unlock_lock' not implemented"
			;;
	esac

	return 0
}

modemmanager_check_state_locked() {
	local device="$1"
	local interface="$2"
	local modemstatus="$3"
	local pincode="$4"

	local unlock_required unlock_retries unlock_retry unlock_lock
	local unlock_value unlock_match
	local sim_path

	if [ -z "$pincode" ]; then
		echo "PIN required"
		proto_notify_error "${interface}" MM_PINCODE_REQUIRED
		proto_block_restart "${interface}"
		return 1
	fi

	unlock_required="$(modemmanager_get_field "${modemstatus}" "modem.generic.unlock-required")"
	unlock_retries="$(modemmanager_get_multivalue_field "${modemstatus}" "modem.generic.unlock-retries")"

	# Output of unlock-retries:
	#   'sim-pin (3), sim-puk (10), sim-pin2 (3), sim-puk2 (10)'
	# Replace alle '<spaces>' of unlock-retures with '', so we could
	# iterate in the for loop. Replace result is:
	#   'sim-pin(3),sim-puk(10),sim-pin2(3),sim-puk2(10)'
	unlock_match=0
	for unlock_retry in $(echo "${unlock_retries// /}" | tr "," "\n"); do
		unlock_lock="${unlock_retry%%(*}"

		# extract x value from 'sim-puk(x)' || 'sim-pin(x)'
		unlock_value="${unlock_retry##*(}"
		unlock_value="${unlock_value:0:-1}"

		[ "$unlock_lock" = "$unlock_required" ] && {
			unlock_match=1
			modemmanager_check_state_lock_sim \
				"$interface" \
				"$unlock_lock" \
				"$unlock_value"
				[ "$?" -ne "0" ] && return 1
		}
	done

	if [ "$unlock_match" = "0" ]; then
		echo "unable to check PIN/PUK attempts"
		proto_notify_error "${interface}" MM_CHECK_UNLOCK_UNKNOWN
		proto_block_restart "${interface}"
		return 1
	fi

	sim_path="$(modemmanager_get_field "${modemstatus}" "modem.generic.sim")"
	mmcli --modem="${device}" -i "${sim_path}" --pin=${pincode} || {
		proto_notify_error "${interface}" MM_PINCODE_WRONG
		proto_block_restart "${interface}"
		return 1
	}

	# Give the modem time to change to the initializing state after
	# unlocking 
	sleep 1

	return 0
}

modemmanager_check_pin_state() {
	local device="$1"
	local interface="$2"
	local modemstatus="$3"
	local pincode="$4"

	local state modemstatus

	local timeout=20
	local count=0

	state="$(modemmanager_get_field "${modemstatus}" "modem.generic.state")"

	case "$state" in
		"failed")
			modemmanager_check_state_failed "$device" \
				"$interface" \
				"$modemstatus"
			[ "$?" -ne "0" ] && return 1
			;;
		"locked")
			modemmanager_check_state_locked "$device" \
				"$interface" \
				"$modemstatus" \
				"$pincode"
			[ "$?" -ne "0" ] && return 1
			;;
	esac

	# After the SIM has been successfully unlocked, it is initialized.
	# This can take longer on some modems, so we must wait until the
	# modem is ready to execute the next commands.
	while [ $count -lt "$timeout" ]; do
		modemstatus=$(mmcli --modem="${device}" --output-keyvalue)
		state="$(modemmanager_get_field "${modemstatus}" "modem.generic.state")"

		[ "$state" != "initializing" ] && return 0
		count=$((count + 1))
		echo "waiting for SIM initializing (${count}s)"
		sleep 1
	done
}

modemmanager_set_preferred_mode() {
	local device="$1"
	local interface="$2"
	local allowedmode="$3"
	local preferredmode="$4"

	[ -z "${preferredmode}" ] && {
		echo "no preferred mode configured"
		proto_notify_error "${interface}" MM_NO_PREFERRED_MODE_CONFIGURED
		proto_block_restart "${interface}"
		return 1
	}

	[ -z "${allowedmode}" ] && {
		echo "no allowed mode configured"
		proto_notify_error "${interface}" MM_NO_ALLOWED_MODE_CONFIGURED
		proto_block_restart "${interface}"
		return 1
	}

	echo "setting preferred mode to '${preferredmode}' (${allowedmode})"
	mmcli --modem="${device}" \
		--set-preferred-mode="${preferredmode}" \
		--set-allowed-modes="${allowedmode}" || {
		proto_notify_error "${interface}" MM_FAILED_SETTING_PREFERRED_MODE
		proto_block_restart "${interface}"
		return 1
	}
}

modemmanager_init_epsbearer() {
	local eps="$1"
	local device="$2"
	local connectargs="$3"
	local apn="$4"

	if [ "$eps" = "none" ]; then
		echo "Deleting inital EPS bearer..."
	else
		echo "Setting '$eps' inital EPS bearer apn to '$apn'..."
	fi

	mmcli --modem="${device}" \
		--timeout 120 \
		--3gpp-set-initial-eps-bearer-settings="${connectargs}" || {
		proto_notify_error "${interface}" MM_INIT_EPS_BEARER_SET_FAILED
		proto_block_restart "${interface}"
		return 1
	}

	# Wait here so that the modem can set the init EPS bearer
	# for registration
	sleep 2
}

modemmanager_set_plmn() {
	local device="$1"
	local interface="$2"
	local plmn="$3"
	local force_connection="$4"

	mmcli --modem="${device}" \
		--timeout 120 \
		--3gpp-register-in-operator="${plmn}" || {
		if [ -n "${force_connection}" ] && [ "${force_connection}" -eq 1 ]; then
			echo "3GPP operator registration failed -> attempting restart"
				proto_notify_error "${interface}" MM_INTERFACE_RESTART
			else
				proto_notify_error "${interface}" MM_3GPP_OPERATOR_REGISTRATION_FAILED
				proto_block_restart "${interface}"
		fi
		return 1
	}
}

proto_modemmanager_setup() {
	local interface="$1"

	local modempath modemstatus bearercount bearerpath connectargs bearerstatus beareriface
	local bearermethod_ipv4 bearermethod_ipv6 auth cliauth
	local operatorname operatorid registration accesstech signalquality
	local allowedmode preferredmode

	local device apn allowedauth username password pincode
	local iptype plmn metric signalrate allow_roaming
	local force_connection

	local init_epsbearer
	local init_iptype init_allowedauth
	local init_password init_user init_apn

	local address prefix gateway mtu dns1 dns2

	json_get_vars device apn allowedauth username password
	json_get_vars pincode iptype sourcefilter plmn metric signalrate allow_roaming
	json_get_vars allowedmode preferredmode force_connection

	json_get_vars init_epsbearer
	json_get_vars init_iptype init_allowedauth
	json_get_vars init_password init_user init_apn

	# validate sysfs path given in config
	[ -n "${device}" ] || {
		echo "No device specified"
		proto_notify_error "${interface}" NO_DEVICE
		proto_set_available "${interface}" 0
		return 1
	}

	# validate that ModemManager is handling the modem at the sysfs path
	modemstatus=$(mmcli --modem="${device}" --output-keyvalue)
	modempath=$(modemmanager_get_field "${modemstatus}" "modem.dbus-path")
	[ -n "${modempath}" ] || {
		echo "Device not managed by ModemManager"
		proto_notify_error "${interface}" DEVICE_NOT_MANAGED
		proto_set_available "${interface}" 0
		return 1
	}
	echo "modem available at ${modempath}"

	modemmanager_check_pin_state "$device" "$interface" "${modemstatus}" "$pincode"
	[ "$?" -ne "0" ] && return 1

	# always cleanup before attempting a new connection, just in case
	modemmanager_cleanup_connection "${modemstatus}"

	mmcli --modem="${device}" --timeout 120 --enable || {
		proto_notify_error "${interface}" MM_MODEM_DISABLED
		return 1
	}

	# set initial eps bearer settings
	if [ -z "${init_epsbearer}" ]; then
		modemmanager_init_epsbearer "none" "$device" "" "$apn"
	else
		case "$init_epsbearer" in
			"default")
				cliauth=""
				for auth in $allowedauth; do
					cliauth="${cliauth}${cliauth:+|}$auth"
				done
				connectargs=""
				append_param "apn=${apn}"
				append_param "${iptype:+ip-type=${iptype}}"
				append_param "${cliauth:+allowed-auth=${cliauth}}"
				append_param "${username:+user=${username}}"
				append_param "${password:+password=${password}}"
				modemmanager_init_epsbearer "default" \
					"$device" "${connectargs}" "$apn"
				;;
			"custom")
				cliauth=""
				for auth in $init_allowedauth; do
					cliauth="${cliauth}${cliauth:+|}$auth"
				done
				connectargs=""
				append_param "apn=${init_apn}"
				append_param "${init_iptype:+ip-type=${init_iptype}}"
				append_param "${cliauth:+allowed-auth=${cliauth}}"
				append_param "${init_username:+user=${init_username}}"
				append_param "${init_password:+password=${init_password}}"
				modemmanager_init_epsbearer "custom" \
					"$device" "${connectargs}" "$init_apn"
				;;
		esac
		# check error for init_epsbearer function call
		[ "$?" -ne "0" ] && return 1
	fi

	if [ -z "${allowedmode}" ]; then
		modemmanager_set_allowed_mode "$device" "$interface" "any"
	else
		case "$allowedmode" in
			"2g")
				modemmanager_set_allowed_mode "$device" \
					"$interface" "2g"
				;;
			"3g")
				modemmanager_set_allowed_mode "$device" \
					"$interface" "3g"
				;;
			"4g")
				modemmanager_set_allowed_mode "$device" \
					"$interface" "4g"
				;;
			"5g")
				modemmanager_set_allowed_mode "$device" \
					"$interface" "5g"
				;;
			"any")
				modemmanager_set_allowed_mode "$device" \
					"$interface" "any"
				;;
			*)
				modemmanager_set_preferred_mode "$device" \
					"$interface" "${allowedmode}" "${preferredmode}"
				;;
		esac
		# check error for allowed_mode and preferred_mode function call
		[ "$?" -ne "0" ] && return 1
	fi

	if [ -z "${plmn}" ]; then
		modemmanager_set_plmn "$device" "$interface" "" "$force_connection"
		[ "$?" -ne "0" ] && return 1
	else
		echo "starting network registration with plmn '${plmn}'..."
		modemmanager_set_plmn "$device" "$interface" "$plmn" "$force_connection"
		[ "$?" -ne "0" ] && return 1
	fi

	# setup connect args; APN mandatory (even if it may be empty)
	echo "starting connection with apn '${apn}'..."

	# setup allow-roaming parameter
	if [ -n "${allow_roaming}" ] && [ "${allow_roaming}" -eq 0 ];then
		allow_roaming="no"
	else
		# allowed unless a user set the opposite
		allow_roaming="yes"
	fi

	cliauth=""
	for auth in $allowedauth; do
		cliauth="${cliauth}${cliauth:+|}$auth"
	done
	# Append options to 'connectargs' variable
	connectargs=""
	append_param "apn=${apn}"
	append_param "allow-roaming=${allow_roaming}"
	append_param "${iptype:+ip-type=${iptype}}"
	append_param "${plmn:+operator-id=${plmn}}"
	append_param "${cliauth:+allowed-auth=${cliauth}}"
	append_param "${username:+user=${username}}"
	append_param "${password:+password=${password}}"

	mmcli --modem="${device}" --timeout 120 --simple-connect="${connectargs}" || {
		if [ -n "${force_connection}" ] && [ "${force_connection}" -eq 1 ]; then
			echo "Connection failed -> attempting restart"
			proto_notify_error "${interface}" MM_INTERFACE_RESTART
		else
			proto_notify_error "${interface}" MM_CONNECT_FAILED
			proto_block_restart "${interface}"
		fi
		return 1
	}

	# check if Signal refresh rate is set
	if [ -n "${signalrate}" ] && [ "${signalrate}" -eq "${signalrate}" ] 2>/dev/null; then
		echo "setting signal refresh rate to ${signalrate} seconds"
		mmcli --modem="${device}" --signal-setup="${signalrate}"
	else
		echo "signal refresh rate is not set"
	fi

	# log additional useful information
	modemstatus=$(mmcli --modem="${device}" --output-keyvalue)
	operatorname=$(modemmanager_get_field "${modemstatus}" "modem.3gpp.operator-name")
	[ -n "${operatorname}" ] && echo "network operator name: ${operatorname}"
	operatorid=$(modemmanager_get_field "${modemstatus}" "modem.3gpp.operator-code")
	[ -n "${operatorid}" ] && echo "network operator MCCMNC: ${operatorid}"
	registration=$(modemmanager_get_field "${modemstatus}" "modem.3gpp.registration-state")
	[ -n "${registration}" ] && echo "registration type: ${registration}"
	accesstech=$(modemmanager_get_multivalue_field "${modemstatus}" "modem.generic.access-technologies")
	[ -n "${accesstech}" ] && echo "access technology: ${accesstech}"
	signalquality=$(modemmanager_get_field "${modemstatus}" "modem.generic.signal-quality.value")
	[ -n "${signalquality}" ] && echo "signal quality: ${signalquality}%"

	# we won't like it if there are more than one bearers, as that would mean the
	# user manually created them, and that's unsupported by this proto
	bearercount=$(modemmanager_get_field "${modemstatus}" "modem.generic.bearers.length")
	[ -n "${bearercount}" ] && [ "$bearercount" -eq 1 ] || {
		proto_notify_error "${interface}" INVALID_BEARER_LIST
		return 1
	}

	# load connected bearer information
	bearerpath=$(modemmanager_get_field "${modemstatus}" "modem.generic.bearers.value\[1\]")
	bearerstatus=$(mmcli --bearer "${bearerpath}" --output-keyvalue)

	# load network interface and method information
	beareriface=$(modemmanager_get_field "${bearerstatus}" "bearer.status.interface")
	bearermethod_ipv4=$(modemmanager_get_field "${bearerstatus}" "bearer.ipv4-config.method")
	bearermethod_ipv6=$(modemmanager_get_field "${bearerstatus}" "bearer.ipv6-config.method")

	# setup IPv4
	[ -n "${bearermethod_ipv4}" ] && {
		echo "IPv4 connection setup required in interface ${interface}: ${bearermethod_ipv4}"
		case "${bearermethod_ipv4}" in
		"dhcp")
			modemmanager_connected_method_dhcp_ipv4 "${interface}" "${beareriface}" "${metric}"
			;;
		"static")
			address=$(modemmanager_get_field "${bearerstatus}" "bearer.ipv4-config.address")
			prefix=$(modemmanager_get_field "${bearerstatus}" "bearer.ipv4-config.prefix")
			gateway=$(modemmanager_get_field "${bearerstatus}" "bearer.ipv4-config.gateway")
			mtu=$(modemmanager_get_field "${bearerstatus}" "bearer.ipv4-config.mtu")
			dns1=$(modemmanager_get_field "${bearerstatus}" "bearer.ipv4-config.dns.value\[1\]")
			dns2=$(modemmanager_get_field "${bearerstatus}" "bearer.ipv4-config.dns.value\[2\]")
			modemmanager_connected_method_static_ipv4 "${interface}" "${beareriface}" "${address}" "${prefix}" "${gateway}" "${mtu}" "${dns1}" "${dns2}" "${metric}"
			;;
		"ppp")
			modemmanager_connected_method_ppp_ipv4 "${interface}" "${beareriface}" "${username}" "${password}" "${allowedauth}"
			;;
		*)
			proto_notify_error "${interface}" UNKNOWN_METHOD
			return 1
			;;
		esac
	}

	# setup IPv6
	# note: if using ipv4v6, both IPv4 and IPv6 settings will have the same MTU and metric values reported
	[ -n "${bearermethod_ipv6}" ] && {
		echo "IPv6 connection setup required in interface ${interface}: ${bearermethod_ipv6}"
		case "${bearermethod_ipv6}" in
		"dhcp")
			modemmanager_connected_method_dhcp_ipv6 "${interface}" "${beareriface}" "${metric}"
			;;
		"static")
			address=$(modemmanager_get_field "${bearerstatus}" "bearer.ipv6-config.address")
			prefix=$(modemmanager_get_field "${bearerstatus}" "bearer.ipv6-config.prefix")
			gateway=$(modemmanager_get_field "${bearerstatus}" "bearer.ipv6-config.gateway")
			mtu=$(modemmanager_get_field "${bearerstatus}" "bearer.ipv6-config.mtu")
			dns1=$(modemmanager_get_field "${bearerstatus}" "bearer.ipv6-config.dns.value\[1\]")
			dns2=$(modemmanager_get_field "${bearerstatus}" "bearer.ipv6-config.dns.value\[2\]")
			modemmanager_connected_method_static_ipv6 "${interface}" "${beareriface}" "${address}" "${prefix}" "${gateway}" "${mtu}" "${dns1}" "${dns2}" "${metric}"
			;;
		"ppp")
			proto_notify_error "${interface}" "unsupported method"
			return 1
			;;
		*)
			proto_notify_error "${interface}" UNKNOWN_METHOD
			return 1
			;;
		esac
	}

	return 0
}

proto_modemmanager_teardown() {
	local interface="$1"

	local modemstatus bearerpath errorstring
	local bearermethod_ipv4 bearermethod_ipv6

	local device lowpower iptype
	json_get_vars device lowpower iptype

	echo "stopping network"

	# load connected bearer information, just the first one should be ok
	modemstatus=$(mmcli --modem="${device}" --output-keyvalue)
	bearerpath=$(modemmanager_get_field "${modemstatus}" "modem.generic.bearers.value\[1\]")
	[ -n "${bearerpath}" ] || {
		echo "couldn't load bearer path: disconnecting anyway"
		mmcli --modem="${device}" --simple-disconnect >/dev/null 2>&1
		return
	}

	# load bearer connection methods
	bearerstatus=$(mmcli --bearer "${bearerpath}" --output-keyvalue)
	bearermethod_ipv4=$(modemmanager_get_field "${bearerstatus}" "bearer.ipv4-config.method")
	[ -n "${bearermethod_ipv4}" ] &&
		echo "IPv4 connection teardown required in interface ${interface}: ${bearermethod_ipv4}"
	bearermethod_ipv6=$(modemmanager_get_field "${bearerstatus}" "bearer.ipv6-config.method")
	[ -n "${bearermethod_ipv6}" ] &&
		echo "IPv6 connection teardown required in interface ${interface}: ${bearermethod_ipv6}"

	# disconnection handling only requires special treatment in IPv4/PPP
	[ "${bearermethod_ipv4}" = "ppp" ] && modemmanager_disconnected_method_ppp_ipv4 "${interface}"

	# disconnect
	mmcli --modem="${device}" --simple-disconnect ||
		proto_notify_error "${interface}" DISCONNECT_FAILED

	# Variable is set to '1' if modem should be disabled on ifdown,
	# otherwise it stays connected.
	local disable="$(uci_get network "$interface" disable_modem "1")"
	if [ "${disable}" -eq 0 ]; then
		echo "Skipping modem disable"
	else
		mmcli --modem="${device}" --disable
	fi

	# low power, only if requested
	[ "${lowpower:-0}" -lt 1 ] ||
		mmcli --modem="${device}" --set-power-state-low
}

[ -n "$INCLUDE_ONLY" ] || {
	add_protocol modemmanager
}
