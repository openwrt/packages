# travelmate shared function library/include, a wlan connection manager for travel router
# Copyright (c) 2016-2026 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# set (s)hellcheck exceptions
# shellcheck disable=all

# initial defaults
#
export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"
trm_enabled="0"
trm_debug="0"
trm_laniface=""
trm_captive="1"
trm_proactive="0"
trm_vpn="0"
trm_netcheck="0"
trm_autoadd="0"
trm_randomize="0"
trm_mail="0"
trm_mailtemplate="/etc/travelmate/mail.template"
trm_vpnpgm="/etc/travelmate/travelmate.vpn"
trm_minquality="35"
trm_maxretry="3"
trm_maxwait="30"
trm_maxautoadd="5"
trm_timeout="60"
trm_radio=""
trm_revradio="0"
trm_connection=""
trm_ssidfilter=""
trm_ovpninfolist=""
trm_vpnifacelist=""
trm_vpninfolist=""
trm_stdvpnservice=""
trm_stdvpniface=""
trm_rtfile="/tmp/trm_runtime.json"
trm_captiveurl="http://detectportal.firefox.com"
trm_useragent="Mozilla/5.0 (X11; Linux x86_64; rv:144.0) Gecko/20100101 Firefox/144.0"
trm_ntplock="/var/lock/travelmate.ntp.lock"
trm_vpnfile="/var/state/travelmate.vpn"
trm_mailfile="/var/state/travelmate.mail"
trm_refreshfile="/var/state/travelmate.refresh"
trm_pidfile="/var/run/travelmate.pid"
trm_scanfile="/var/run/travelmate.scan"
trm_tmpfile="/var/run/travelmate.tmp"

# gather system information
#
f_system() {
	trm_packages="$("${trm_ubuscmd}" -S call rpc-sys packagelist '{ "all": true }' 2>/dev/null)"
	trm_fver="$(printf "%s" "${trm_packages}" | "${trm_jsoncmd}" -ql1 -e '@.packages["luci-app-travelmate"]')"
	trm_bver="$(printf "%s" "${trm_packages}" | "${trm_jsoncmd}" -ql1 -e '@.packages.travelmate')"
	trm_sysver="$("${trm_ubuscmd}" -S call system board 2>/dev/null |
		"${trm_jsoncmd}" -ql1 -e '@.model' -e '@.release.target' -e '@.release.distribution' -e '@.release.version' -e '@.release.revision' |
		"${trm_awkcmd}" 'BEGIN{RS="";FS="\n"}{printf "%s, %s, %s %s (%s)",$1,$2,$3,$4,$5}')"

	if [ ! -d "${trm_ntplock}" ]; then
		"${trm_ubuscmd}" -S call hotplug.ntp call '{ "env": [ "ACTION=stratum" ] }' >/dev/null 2>&1
	fi
}

# command selector
#
f_cmd() {
	local cmd pri_cmd="${1}" sec_cmd="${2}"

	cmd="$(command -v "${pri_cmd}" 2>/dev/null)"
	if [ ! -x "${cmd}" ]; then
		if [ -n "${sec_cmd}" ]; then
			[ "${sec_cmd}" = "optional" ] && return
			cmd="$(command -v "${sec_cmd}" 2>/dev/null)"
		fi
		if [ -x "${cmd}" ]; then
			printf "%s" "${cmd}"
		else
			f_log "emerg" "command '${pri_cmd:-"-"}'/'${sec_cmd:-"-"}' not found"
		fi
	else
		printf "%s" "${cmd}"
	fi
}

# load travelmate config
#
f_conf() {
	 unset trm_stalist trm_radiolist trm_uplinklist trm_vpnifacelist trm_uplinkcfg trm_activesta trm_ssidfilter

	 config_cb() {
		option_cb() {
			local option="${1}" value="${2//\"/\\\"}"

			case "${option}" in
				*[!a-zA-Z0-9_]*)
					;;
				*)
					eval "${option}=\"\${value}\""
					;;
			esac
		}
		list_cb() {
			local option="${1}" value="${2//\"/\\\"}"

			 case "${option}" in
				*[!a-zA-Z0-9_]*)
					;;
				*)
					eval "append=\"\${${option}}\""
					if [ -n "${append}" ]; then
						eval "${option}=\"${append} ${value}\""
					else
						eval "${option}=\"${value}\""
					fi
					;;
			esac
		}
	}
	config_load travelmate

	[ "${trm_action}" = "stop" ] && return 0

	if [ "${trm_enabled}" != "1" ]; then
		f_log "info" "travelmate is currently disabled, please set 'trm_enabled' to '1' to use this service"
		/etc/init.d/travelmate stop
	elif [ -z "${trm_iface}" ]; then
		f_log "info" "travelmate is currently not configured, please use the 'Interface Wizard' in LuCI"
		/etc/init.d/travelmate stop
	elif ! "${trm_ubuscmd}" -t "${trm_maxwait}" wait_for network.wireless network.interface."${trm_iface}" >/dev/null 2>&1; then
		f_log "info" "travelmate interface '${trm_iface}' does not appear on ubus, please check your network setup"
		/etc/init.d/travelmate stop
	fi

	config_load wireless
	config_foreach f_setdev "wifi-device"
	if [ -n "$(uci -q changes "wireless")" ]; then
		uci_commit "wireless"
		f_wifi
	fi

	json_load_file "${trm_rtfile}" >/dev/null 2>&1
	if ! json_select data >/dev/null 2>&1; then
		: >"${trm_rtfile}"
		json_init
		json_add_object "data"
	fi

	if [ "${trm_vpn}" = "1" ] && [ -z "${trm_vpninfolist}" ]; then
		config_load network
		config_foreach f_getvpn "interface"
	fi

	trm_fetchparm="--silent --show-error --location --fail --referer http://www.example.com --retry $((trm_maxwait / 6)) --retry-delay $((trm_maxwait / 6)) --max-time $((trm_maxwait / 6))"
	device="$("${trm_ifstatuscmd}" "${trm_iface}" | "${trm_jsoncmd}" -ql1 -e '@.device')"
	[ -n "${device}" ] && trm_fetchparm="${trm_fetchparm} --interface ${device}"

	f_log "debug" "f_conf      ::: frontend: ${trm_fver}, backend: ${trm_bver}, sys_ver: ${trm_sysver}, fetch_parm: ${trm_fetchparm:-"-"}"
}

f_rmpid() {
	local ppid pid

	if [ -s "${trm_pidfile}" ]; then
		ppid="$(< "${trm_pidfile}")"
		if [ -n "${ppid}" ]; then
			pid="$("${trm_pgrepcmd}" -nf "sleep ${trm_timeout} 0" -P ${ppid} 2>/dev/null)"
			[ -n "${pid}" ] && "${trm_killcmd}" -INT ${pid} 2>/dev/null
		fi
	fi
	f_log "debug" "f_rmpid     ::: ppid: ${ppid:-"-"}, pid: ${pid:-"-"}, timeout: ${trm_timeout}"
}

# trim helper function
#
f_trim() {
	local trim="${1}"

	trim="${trim#"${trim%%[![:space:]]*}"}"
	trim="${trim%"${trim##*[![:space:]]}"}"
	printf "%s" "${trim}"
}

# status helper function
#
f_char() {
	local result input="${1}"

	[ "${input}" = "1" ] && result="✔" || result="✘"
	printf "%s" "${result}"
}

# wifi helper function
#
f_wifi() {
	local status radio radio_up timeout="0"

	"${trm_wificmd}" reload
	for radio in ${trm_radiolist}; do
		while :; do
			if [ "${timeout}" -ge "${trm_maxwait}" ]; then
				break 2
			fi
			status="$("${trm_wificmd}" status 2>/dev/null)"
			if [ "$(printf "%s" "${status}" | "${trm_jsoncmd}" -ql1 -e "@.${radio}.up")" != "true" ] ||
				[ "$(printf "%s" "${status}" | "${trm_jsoncmd}" -ql1 -e "@.${radio}.pending")" != "false" ]; then
				if [ "${radio}" != "${radio_up}" ]; then
					"${trm_wificmd}" up "${radio}"
					radio_up="${radio}"
				fi
				timeout="$((timeout + 1))"
				sleep 1
			else
				continue 2
			fi
		done
	done
	if [ "${timeout}" -lt "${trm_maxwait}" ]; then
		sleep "$((trm_maxwait / 6))"
		timeout="$((timeout + (trm_maxwait / 6)))"
	fi
	f_log "debug" "f_wifi      ::: radio_list: ${trm_radiolist}, ssid_filter: ${trm_ssidfilter:-"-"}, radio: ${radio}, timeout: ${timeout}"
}

# vpn helper function
#
f_vpn() {
	local rc info iface vpn vpn_service vpn_iface vpn_instance vpn_status vpn_action="${1}"

	if  [ "${trm_vpn}" = "1" ] && [ -n "${trm_vpninfolist}" ]; then
		vpn="$(f_getval "vpn")"
		vpn_service="$(f_getval "vpnservice")"
		vpn_iface="$(f_getval "vpniface")"

		if [ ! -f "${trm_vpnfile}" ] || { [ -f "${trm_vpnfile}" ] && [ "${vpn_action}" = "enable" ]; }; then
			for info in ${trm_vpninfolist}; do
				iface="${info%%&&*}"
				vpn_status="$("${trm_ifstatuscmd}" "${iface}" | "${trm_jsoncmd}" -ql1 -e '@.up')"
				if [ "${vpn_status}" = "true" ]; then
					/sbin/ifdown "${iface}"
					"${trm_ubuscmd}" -S call network.interface."${iface}" remove >/dev/null 2>&1
					f_log "info" "take down vpn interface '${iface}' (initial)"
				fi
				[ "${iface}" = "${info}" ] && vpn_instance="" || vpn_instance="${info##*&&}"
				if [ -x "/etc/init.d/openvpn" ] && [ -n "${vpn_instance}" ] && /etc/init.d/openvpn running "${vpn_instance}"; then
					/etc/init.d/openvpn stop "${vpn_instance}"
					f_log "info" "take down openvpn instance '${vpn_instance}' (initial)"
				fi
			done
			rm -f "${trm_vpnfile}"
			sleep 1
		elif [ "${vpn}" = "1" ] && [ -n "${vpn_iface}" ] && [ "${vpn_action}" = "enable_keep" ]; then
			for info in ${trm_vpninfolist}; do
				iface="${info%%&&*}"
				[ "${iface}" = "${info}" ] && vpn_instance="" || vpn_instance="${info##*&&}"
				vpn_status="$("${trm_ifstatuscmd}" "${iface}" | "${trm_jsoncmd}" -ql1 -e '@.up')"
				if [ "${vpn_status}" = "true" ] && [ "${iface}" != "${vpn_iface}" ]; then
					/sbin/ifdown "${iface}"
					f_log "info" "take down vpn interface '${iface}' (switch)"
					if [ -x "/etc/init.d/openvpn" ] && [ -n "${vpn_instance}" ] && /etc/init.d/openvpn running "${vpn_instance}"; then
						/etc/init.d/openvpn stop "${vpn_instance}"
						f_log "info" "take down openvpn instance '${vpn_instance}' (switch)"
					fi
					rc="1"
				fi
				if [ "${rc}" = "1" ]; then
					rm -f "${trm_vpnfile}"
					sleep 1
					break
				fi
			done
		fi
		if [ -x "${trm_vpnpgm}" ] && [ -n "${vpn_service}" ] && [ -n "${vpn_iface}" ]; then
			if { [ "${vpn_action}" = "disable" ] && [ -f "${trm_vpnfile}" ]; } ||
				{ [ -d "${trm_ntplock}" ] && { [ "${vpn}" = "1" ] && [ "${vpn_action%%_*}" = "enable" ] && [ ! -f "${trm_vpnfile}" ]; } ||
				{ [ "${vpn}" != "1" ] && [ "${vpn_action%%_*}" = "enable" ] && [ -f "${trm_vpnfile}" ]; }; }; then
					if [ "${trm_connection%%/*}" = "net ok" ] || [ "${vpn_action}" = "disable" ]; then
						for info in ${trm_vpninfolist}; do
							iface="${info%%&&*}"
							if [ "${iface}" = "${vpn_iface}" ]; then
								[ "${iface}" = "${info}" ] && vpn_instance="" || vpn_instance="${info##*&&}"
								break
							fi
						done
						"${trm_vpnpgm}" "${vpn:-"0"}" "${vpn_action}" "${vpn_service}" "${vpn_iface}" "${vpn_instance}" >/dev/null 2>&1
						rc="${?}"
					fi
			fi
			[ -n "${rc}" ] && f_genstatus
		fi
	fi
	f_log "debug" "f_vpn       ::: vpn: ${trm_vpn:-"-"}, enabled: ${vpn:-"-"}, action: ${vpn_action}, vpn_service: ${vpn_service:-"-"}, vpn_iface: ${vpn_iface:-"-"}, vpn_instance: ${vpn_instance:-"-"}, vpn_infolist: ${trm_vpninfolist:-"-"}, connection: ${trm_connection%%/*}, rc: ${rc:-"-"}"
}

# mac helper function
#
f_mac() {
	local raw result ifname macaddr action="${1}" section="${2}"

	if [ "${action}" = "set" ]; then
		macaddr="$(f_getval "macaddr")"
		if [ -n "${macaddr}" ]; then
			result="${macaddr}"
			uci_set "wireless" "${section}" "macaddr" "${result}"
		elif [ "${trm_randomize}" = "1" ]; then
			result="$(hexdump -n6 -ve '/1 "%.02X "' /dev/random 2>/dev/null |
				"${trm_awkcmd}" -v local="2,6,A,E" -v seed="$(date +%s)" 'BEGIN{srand(seed)}NR==1{split(local,b,",");
				seed=int(rand()*4+1);printf "%s%s:%s:%s:%s:%s:%s",substr($1,0,1),b[seed],$2,$3,$4,$5,$6}')"
			uci_set "wireless" "${section}" "macaddr" "${result}"
		else
			uci_remove "wireless" "${section}" "macaddr" 2>/dev/null
			raw="$("${trm_ubuscmd}" -S call network.wireless status 2>/dev/null)"
			ifname="$(printf "%s" "${raw}" | "${trm_jsoncmd}" -ql1 -e '@.*.interfaces[@.config.mode="sta"].ifname')"
			result="$(printf "%s" "${raw}" | "${trm_jsoncmd}" -ql1 -e '@.*.interfaces[@.config.mode="sta"].config.macaddr')"
		fi
	elif [ "${action}" = "get" ]; then
		result="$(uci_get "wireless" "${section}" "macaddr")"
		if [ -z "${result}" ]; then
			raw="$("${trm_ubuscmd}" -S call network.wireless status 2>/dev/null)"
			ifname="$(printf "%s" "${raw}" | "${trm_jsoncmd}" -ql1 -e '@.*.interfaces[@.config.mode="sta"].ifname')"
			result="$(printf "%s" "${raw}" | "${trm_jsoncmd}" -ql1 -e '@.*.interfaces[@.config.mode="sta"].config.macaddr')"
		fi
	fi
	printf "%s" "${result}"
	f_log "debug" "f_mac       ::: action: ${action:-"-"}, section: ${section:-"-"}, macaddr: ${macaddr:-"-"}, result: ${result:-"-"}"
}

# set connection information
#
f_ctrack() {
	local expiry action="${1}"

	if [ -n "${trm_uplinkcfg}" ]; then
		case "${action}" in
			"start")
				uci_remove "travelmate" "${trm_uplinkcfg}" "con_start" 2>/dev/null
				uci_remove "travelmate" "${trm_uplinkcfg}" "con_end" 2>/dev/null
				if [ -d "${trm_ntplock}" ]; then
					uci_set "travelmate" "${trm_uplinkcfg}" "con_start" "$(date "+%Y.%m.%d-%H:%M:%S")"
				fi
				;;
			"refresh")
				if [ -d "${trm_ntplock}" ] && [ -z "$(uci_get "travelmate" "${trm_uplinkcfg}" "con_start")" ]; then
					uci_set "travelmate" "${trm_uplinkcfg}" "con_start" "$(date "+%Y.%m.%d-%H:%M:%S")"
				fi
				;;
			"end")
				if [ -d "${trm_ntplock}" ]; then
					uci_set "travelmate" "${trm_uplinkcfg}" "con_end" "$(date "+%Y.%m.%d-%H:%M:%S")"
				fi
				;;
			"start_expiry")
				if [ -d "${trm_ntplock}" ]; then
					expiry="$(uci_get "travelmate" "${trm_uplinkcfg}" "con_start_expiry")"
					uci_set "travelmate" "${trm_uplinkcfg}" "enabled" "0"
					uci_set "travelmate" "${trm_uplinkcfg}" "con_end" "$(date "+%Y.%m.%d-%H:%M:%S")"
					f_log "info" "uplink '${radio}/${essid}/${bssid:-"-"}' expired after ${expiry} minutes"
				fi
				;;
			"end_expiry")
				if [ -d "${trm_ntplock}" ]; then
					expiry="$(uci_get "travelmate" "${trm_uplinkcfg}" "con_end_expiry")"
					uci_set "travelmate" "${trm_uplinkcfg}" "enabled" "1"
					uci_remove "travelmate" "${trm_uplinkcfg}" "con_start" 2>/dev/null
					uci_remove "travelmate" "${trm_uplinkcfg}" "con_end" 2>/dev/null
					f_log "info" "uplink '${radio}/${essid}/${bssid:-"-"}' re-enabled after ${expiry} minutes"
				fi
				;;
			"disabled")
				uci_set "travelmate" "${trm_uplinkcfg}" "enabled" "0"
				if [ -d "${trm_ntplock}" ]; then
					uci_set "travelmate" "${trm_uplinkcfg}" "con_end" "$(date "+%Y.%m.%d-%H:%M:%S")"
				fi
				;;
		esac
		if [ -n "$(uci -q changes "travelmate")" ]; then
			uci_commit "travelmate"
			if [ ! -f "${trm_refreshfile}" ]; then
				printf "%s" "cfg_reload" >"${trm_refreshfile}"
			fi
		fi
	fi
}

# get openvpn information
#
f_getovpn() {
	local file instance device

	for file in /etc/openvpn/*.conf /etc/openvpn/*.ovpn; do
		if [ -f "${file}" ]; then
			instance="${file##*/}"
			instance="${instance%.conf}"
			instance="${instance%.ovpn}"
			device="$("${trm_awkcmd}" '/^[[:space:]]*dev /{print $2}' "${file}")"
			[ "${device}" = "tun" ] && device="tun0"
			[ "${device}" = "tap" ] && device="tap0"
			if [ -n "${device}" ] && [ -n "${instance}" ] && ! printf "%s" "${trm_ovpninfolist}" | "${trm_grepcmd}" -q "${device}"; then
				trm_ovpninfolist="${trm_ovpninfolist} ${device}&&${instance}"
			fi
		fi
	done

	uci_config() {
		local device section="${1}"

		device="$(uci_get "openvpn" "${section}" "dev")"
		[ "${device}" = "tun" ] && device="tun0"
		[ "${device}" = "tap" ] && device="tap0"
		if [ -n "${device}" ] && ! printf "%s" "${trm_ovpninfolist}" | "${trm_grepcmd}" -q "${device}"; then
			trm_ovpninfolist="${trm_ovpninfolist} ${device}&&${section}"
		fi
	}
	if [ -f "/etc/config/openvpn" ]; then
		config_load openvpn
		config_foreach uci_config "openvpn"
	fi
	f_log "debug" "f_getovpn   ::: ovpn_infolist: ${trm_ovpninfolist:-"-"}"
}

# get logical vpn network interfaces
#
f_getvpn() {
	local info proto device iface="${1}"

	proto="$(uci_get "network" "${iface}" "proto")"
	device="$(uci_get "network" "${iface}" "device")"
	if [ "${proto}" = "wireguard" ]; then
		if [ -z "${trm_vpnifacelist}" ] || printf "%s" "${trm_vpnifacelist}" | "${trm_grepcmd}" -q "${iface}"; then
			if ! printf "%s" "${trm_vpninfolist}" | "${trm_grepcmd}" -q "${iface}"; then
				trm_vpninfolist="$(f_trim "${trm_vpninfolist} ${iface}")"
			fi
		fi
	elif [ "${proto}" = "none" ] && [ -n "${device}" ]; then
		if [ -z "${trm_ovpninfolist}" ]; then
			f_getovpn
		fi
		if [ -z "${trm_vpnifacelist}" ] || printf "%s" "${trm_vpnifacelist}" | "${trm_grepcmd}" -q "${iface}"; then
			for info in ${trm_ovpninfolist}; do
				if [ "${info%%&&*}" = "${device}" ]; then
					if ! printf "%s" "${trm_vpninfolist}" | "${trm_grepcmd}" -q "${iface}"; then
						trm_vpninfolist="$(f_trim "${trm_vpninfolist} ${iface}&&${info##*&&}")"
						break
					fi
				fi
			done
		fi
	fi
	f_log "debug" "f_getvpn    ::: iface: ${iface:-"-"}, proto: ${proto:-"-"}, device: ${device:-"-"}, vpn_ifacelist: ${trm_vpnifacelist:-"-"}, vpn_infolist: ${trm_vpninfolist:-"-"}"
}

# get wan gateway addresses
#
f_getgw() {
	local wan4_if wan4_gw wan6_if wan6_gw result="false"

	network_flush_cache
	network_find_wan wan4_if
	network_find_wan6 wan6_if
	network_get_gateway wan4_gw "${wan4_if}"
	network_get_gateway6 wan6_gw "${wan6_if}"
	if [ -n "${wan4_gw}" ] || [ -n "${wan6_gw}" ]; then
		result="true"
	fi
	printf "%s" "${result}"
	f_log "debug" "f_getgw     ::: wan4_gw: ${wan4_gw:-"-"}, wan6_gw: ${wan6_gw:-"-"}, result: ${result}"
}

# get uplink config section
#
f_getcfg() {
	local t_radio t_essid t_bssid radio="${1}" essid="${2}" bssid="${3}" cnt="0"

	while uci_get "travelmate" "@uplink[${cnt}]" >/dev/null 2>&1; do
		t_radio="$(uci_get "travelmate" "@uplink[${cnt}]" "device")"
		t_essid="$(uci_get "travelmate" "@uplink[${cnt}]" "ssid")"
		t_bssid="$(uci_get "travelmate" "@uplink[${cnt}]" "bssid")"
		if [ -n "${radio}" ] && [ -n "${essid}" ] &&
			[ "${t_radio}" = "${radio}" ] && [ "${t_essid}" = "${essid}" ] && [ "${t_bssid}" = "${bssid}" ]; then
			trm_uplinkcfg="@uplink[${cnt}]"
			break
		fi
		cnt="$((cnt + 1))"
	done
}

# get travelmate option value in 'uplink' sections
#
f_getval() {
	local result t_option="${1}"

	if [ -n "${trm_uplinkcfg}" ]; then
		result="$(uci_get "travelmate" "${trm_uplinkcfg}" "${t_option}")"
		printf "%s" "${result}"
	fi
}

# set 'wifi-device' sections
#
f_setdev() {
	local disabled radio="${1}"

	if { [ -z "${trm_radio}" ] && ! printf "%s" "${trm_radiolist}" | "${trm_grepcmd}" -q "${radio}"; } ||
		{ [ -n "${trm_radio}" ] && printf "%s" "${trm_radio}" | "${trm_grepcmd}" -q "${radio}"; }; then
		if [ "${trm_revradio}" = "1" ]; then
			trm_radiolist="$(f_trim "${radio} ${trm_radiolist}")"
		else
			trm_radiolist="$(f_trim "${trm_radiolist} ${radio}")"
		fi
		disabled="$(uci_get "wireless" "${radio}" "disabled")"
		if [ "${disabled}" = "1" ]; then
			uci_set wireless "${radio}" "disabled" "0"
		fi
	fi
	f_log "debug" "f_setdev    ::: device: ${radio:-"-"}, radio: ${trm_radio:-"-"}, radio_list: ${trm_radiolist:-"-"}, disabled: ${disabled:-"-"}"
}

# set 'wifi-iface' sections
#
f_setif() {
	local mode radio essid bssid enabled disabled d1 d2 d3 con_start con_end con_start_expiry con_end_expiry section="${1}" proactive="${2}"

	radio="$(uci_get "wireless" "${section}" "device")"
	if ! printf "%s" "${trm_radiolist}" | "${trm_grepcmd}" -q "${radio}"; then
		return
	fi
	mode="$(uci_get "wireless" "${section}" "mode")"
	essid="$(uci_get "wireless" "${section}" "ssid")"
	bssid="$(uci_get "wireless" "${section}" "bssid")"
	disabled="$(uci_get "wireless" "${section}" "disabled")"

	f_getcfg "${radio}" "${essid}" "${bssid}"

	enabled="$(f_getval "enabled")"
	con_start="$(f_getval "con_start")"
	con_end="$(f_getval "con_end")"
	con_start_expiry="$(f_getval "con_start_expiry")"
	con_end_expiry="$(f_getval "con_end_expiry")"

	if [ "${enabled}" = "0" ] && [ -n "${con_end}" ] && [ -n "${con_end_expiry}" ] && [ "${con_end_expiry}" != "0" ]; then
		d1="$(date -d "${con_end}" "+%s")"
		d2="$(date "+%s")"
		d3="$(((d2 - d1) / 60))"
		if [ "${d3}" -ge "${con_end_expiry}" ]; then
			enabled="1"
			f_ctrack "end_expiry"
		fi
	elif [ "${enabled}" = "1" ] && [ -n "${con_start}" ] && [ -n "${con_start_expiry}" ] && [ "${con_start_expiry}" != "0" ]; then
		d1="$(date -d "${con_start}" "+%s")"
		d2="$(date "+%s")"
		d3="$((d1 + (con_start_expiry * 60)))"
		if [ "${d2}" -gt "${d3}" ]; then
			enabled="0"
			f_ctrack "start_expiry"
		fi
	fi

	if [ "${mode}" = "sta" ]; then
		if [ "${enabled}" = "0" ] || { { [ -z "${disabled}" ] || [ "${disabled}" = "0" ]; } &&
			{ [ "${proactive}" = "0" ] || [ "${trm_ifstatus}" != "true" ]; }; }; then
			uci_set "wireless" "${section}" "disabled" "1"
		elif [ "${enabled}" = "1" ] && [ "${disabled}" = "0" ] && [ "${trm_ifstatus}" = "true" ] && [ "${proactive}" = "1" ]; then
			if [ -z "${trm_activesta}" ]; then
				trm_activesta="${section}"
			else
				uci_set "wireless" "${section}" "disabled" "1"
			fi
		fi
		if [ "${enabled}" = "1" ]; then
			trm_stalist="$(f_trim "${trm_stalist} ${section}-${radio}")"
		fi
	fi
	f_log "debug" "f_setif     ::: uplink_config: ${trm_uplinkcfg:-"-"}, section: ${section}, enabled: ${enabled}, active_sta: ${trm_activesta:-"-"}"
}

# check router/uplink subnet
#
f_subnet() {
	local lan lan_net wan wan_net

	network_flush_cache
	network_get_subnet wan "${trm_iface:-"trm_wwan"}"
	[ -n "${wan}" ] && wan_net="$("${trm_ipcalccmd}" "${wan}" | "${trm_awkcmd}" 'BEGIN{FS="="}/NETWORK/{printf "%s",$2}')"
	network_get_subnet lan "${trm_laniface:-"lan"}"
	[ -n "${lan}" ] && lan_net="$("${trm_ipcalccmd}" "${lan}" | "${trm_awkcmd}" 'BEGIN{FS="="}/NETWORK/{printf "%s",$2}')"
	if [ -n "${lan_net}" ] && [ -n "${wan_net}" ] && [ "${lan_net}" = "${wan_net}" ]; then
		f_log "info" "uplink network '${wan_net}' conflicts with router LAN network, please adjust your network settings"
	fi
	printf "%s" "${wan_net:-"-"} (lan: ${lan_net:-"-"})"
	f_log "debug" "f_subnet    ::: lan_net: ${lan_net:-"-"}, wan_net: ${wan_net:-"-"}"
}

# add open uplinks
#
f_addsta() {
	local pattern wifi_cfg trm_cfg new_uplink="1" offset="1" radio="${1}" essid="${2}"

	for pattern in ${trm_ssidfilter}; do
		case "${essid}" in
			${pattern})
				f_log "info" "open uplink filtered out '${radio}/${essid}/${pattern}'"
				return 0
				;;
		esac
	done
	if [ "${trm_maxautoadd}" = "0" ] || [ "${trm_autoaddcnt:-0}" -lt "${trm_maxautoadd}" ]; then
		config_cb() {
			local type="${1}" name="${2}"

			if [ "${type}" = "wifi-iface" ]; then
				if [ "$(uci_get "wireless.${name}.ssid")" = "${essid}" ] &&
					[ "$(uci_get "wireless.${name}.device")" = "${radio}" ]; then
					new_uplink="0"
					return 0
				fi
				offset="$((offset + 1))"
			fi
		}
		config_load wireless
	else
		new_uplink="0"
	fi

	if [ "${new_uplink}" = "1" ]; then
		wifi_cfg="trm_uplink$((offset + 1))"
		while [ -n "$(uci_get "wireless.${wifi_cfg}")" ]; do
			offset="$((offset + 1))"
			wifi_cfg="trm_uplink${offset}"
		done
		uci -q batch <<-EOC
			set wireless."${wifi_cfg}"="wifi-iface"
			set wireless."${wifi_cfg}".mode="sta"
			set wireless."${wifi_cfg}".network="${trm_iface}"
			set wireless."${wifi_cfg}".device="${radio}"
			set wireless."${wifi_cfg}".ssid="${essid}"
			set wireless."${wifi_cfg}".encryption="none"
			set wireless."${wifi_cfg}".disabled="1"
		EOC
		trm_cfg="$(uci -q add travelmate uplink)"
		uci -q batch <<-EOC
			set travelmate."${trm_cfg}".device="${radio}"
			set travelmate."${trm_cfg}".ssid="${essid}"
			set travelmate."${trm_cfg}".opensta="1"
			set travelmate."${trm_cfg}".con_start_expiry="0"
			set travelmate."${trm_cfg}".con_end_expiry="0"
			set travelmate."${trm_cfg}".enabled="1"
		EOC
		if [ -n "${trm_stdvpnservice}" ] && [ -n "${trm_stdvpniface}" ]; then
			uci -q batch <<-EOC
				set travelmate."${trm_cfg}".vpnservice="${trm_stdvpnservice}"
				set travelmate."${trm_cfg}".vpniface="${trm_stdvpniface}"
				set travelmate."${trm_cfg}".vpn="1"
			EOC
		fi

		cnt="$(uci_get "travelmate" "global" "trm_autoaddcnt" "0")"
		cnt="$((cnt + 1))"
		uci_set "travelmate" "global" "trm_autoaddcnt" "${cnt}"

		[ -n "$(uci -q changes "travelmate")" ] && uci_commit "travelmate"
		[ -n "$(uci -q changes "wireless")" ] && uci_commit "wireless"
		f_wifi
		if [ ! -f "${trm_refreshfile}" ]; then
			printf "%s" "ui_reload" >"${trm_refreshfile}"
		fi
		f_log "info" "open uplink '${radio}/${essid}' added to wireless config"
		printf "%s" "${wifi_cfg}-${radio}"
	fi
	f_log "debug" "f_addsta    ::: radio: ${radio:-"-"}, essid: ${essid}, autoaddcnt/maxautoadd: ${cnt:-"${trm_autoaddcnt}"}/${trm_maxautoadd:-"-"}, new_uplink: ${new_uplink}, offset: ${offset}"
}

# check net status
#
f_net() {
	local err_msg raw json_raw html_raw html_cp js_cp json_ec json_rc json_cp json_ed result="net nok"

	raw="$("${trm_fetchcmd}" ${trm_fetchparm} --user-agent "${trm_useragent}" --header "Cache-Control: no-cache, no-store, must-revalidate, max-age=0" --write-out "%{json}" "${trm_captiveurl}")"
	json_raw="${raw#*\{}"
	html_raw="${raw%%\{*}"
	if [ -n "${json_raw}" ]; then
		json_ec="$(printf "%s" "{${json_raw}" | "${trm_jsoncmd}" -ql1 -e '@.exitcode')"
		json_rc="$(printf "%s" "{${json_raw}" | "${trm_jsoncmd}" -ql1 -e '@.response_code')"
		json_cp="$(printf "%s" "{${json_raw}" | "${trm_jsoncmd}" -ql1 -e '@.redirect_url' | "${trm_awkcmd}" 'BEGIN{FS="/"}{printf "%s",tolower($3)}')"
		if [ "${json_ec}" = "0" ]; then
			if [ -n "${json_cp}" ]; then
				result="net cp '${json_cp}'"
			else
				if [ "${json_rc}" = "200" ] || [ "${json_rc}" = "204" ]; then
					html_cp="$(printf "%s" "${html_raw}" | "${trm_awkcmd}" 'match(tolower($0),/^.*<meta[ \t]+http-equiv=['\''"]*refresh.*[ \t;]url=/){print substr(tolower($0),RLENGTH+1)}' | "${trm_awkcmd}" 'BEGIN{FS="[:/]"}{printf "%s",$4;exit}')"
					js_cp="$(printf "%s" "${html_raw}" | "${trm_awkcmd}" 'match(tolower($0),/^.*location\.href=['\''"]*/){print substr(tolower($0),RLENGTH+1)}' | "${trm_awkcmd}" 'BEGIN{FS="[:/]"}{printf "%s",$4;exit}')"
					if [ -n "${html_cp}" ]; then
						result="net cp '${html_cp}'"
					elif [ -n "${js_cp}" ]; then
						result="net cp '${js_cp}'"
					else
						result="net ok"
					fi
				fi
			fi
		else
			err_msg="$(printf "%s" "{${json_raw}" | "${trm_jsoncmd}" -ql1 -e '@.errormsg')"
			json_ed="$(printf "%s" "{${err_msg}" | "${trm_awkcmd}" '/([[:alnum:]_-]{1,63}\.)+[[:alpha:]]+$/{printf "%s",tolower($NF)}')"
			if [ "${json_ec}" = "6" ]; then
				if [ -n "${json_ed}" ] && [ "${json_ed}" != "${trm_captiveurl#http*://*}" ]; then
					result="net cp '${json_ed}'"
				fi
			fi
		fi
	fi
	printf "%s" "${result}"
	f_log "debug" "f_net       ::: timeout: $((trm_maxwait / 6)), cp (json/html/js): ${json_cp:-"-"}/${html_cp:-"-"}/${js_cp:-"-"}, result: ${result}, error (rc/msg): ${json_ec}/${err_msg:-"-"}, url: ${trm_captiveurl}"
}

# check interface status
#
f_check() {
	local raw ifname radio dev_status result login_script login_script_args cp_domain wait_time="0" enabled="1" mode="${1}" status="${2}" sta_radio="${3}" sta_essid="${4}" sta_bssid="${5}"

	if [ "${mode}" = "initial" ] || [ "${mode}" = "dev" ]; then
		json_get_var station_id "station_id"
		sta_radio="${station_id%%/*}"
		sta_essid="${station_id%/*}"
		sta_essid="${sta_essid#*/}"
		sta_bssid="${station_id##*/}"
		sta_bssid="${sta_bssid//-/}"
	fi
	f_getcfg "${sta_radio}" "${sta_essid}" "${sta_bssid}"

	if [ "${mode}" != "rev" ] && [ -n "${sta_radio}" ] && [ "${sta_radio}" != "-" ] && [ -n "${sta_essid}" ] && [ "${sta_essid}" != "-" ]; then
		enabled="$(f_getval "enabled")"
	fi
	if { [ "${mode}" != "initial" ] && [ "${mode}" != "dev" ] && [ "${status}" = "false" ]; } ||
		{ [ "${mode}" = "dev" ] && { [ "${status}" = "false" ] || { [ "${trm_ifstatus}" != "${status}" ] && [ "${enabled}" = "0" ]; }; }; }; then
		f_wifi
	fi
	if [ "${mode}" = "sta" ]; then
		"${trm_ubuscmd}" -S call network.interface."${trm_iface}" down >/dev/null 2>&1
		"${trm_ubuscmd}" -S call network.interface."${trm_iface}" up >/dev/null 2>&1
		if ! "${trm_ubuscmd}" -t "$((trm_maxwait / 6))" wait_for network.interface."${trm_iface}" >/dev/null 2>&1; then
			f_log "info" "travelmate interface '${trm_iface}' does not appear on ubus on ifup event"
		fi
		sleep 1
	fi

	while [ "${wait_time}" -le "${trm_maxwait}" ]; do
		[ "${wait_time}" -gt "0" ] && sleep 1
		wait_time="$((wait_time + 1))"
		dev_status="$("${trm_ubuscmd}" -S call network.wireless status 2>/dev/null)"
		if [ -n "${dev_status}" ]; then
			if [ "${mode}" = "dev" ]; then
				if [ "${trm_ifstatus}" != "${status}" ]; then
					trm_ifstatus="${status}"
					f_genstatus
				fi
				if [ "${status}" = "false" ]; then
					sleep "$((trm_maxwait / 6))"
				fi
				break
			elif [ "${mode}" = "rev" ]; then
				trm_connection=""
				trm_ifstatus="${status}"
				break
			else
				ifname="$(printf "%s" "${dev_status}" | "${trm_jsoncmd}" -ql1 -e '@.*.interfaces[@.config.mode="sta"].ifname')"
				if [ -n "${ifname}" ] && [ "${enabled}" = "1" ]; then
					raw="$("${trm_ubuscmd}" -S call iwinfo info "{\"device\":\"${ifname}\"}" 2>/dev/null | "${trm_jsoncmd}" -ql1 -e '@.signal')"
					if [ -n "${raw}" ] && [ "${raw}" -ge "-120" ]; then
						trm_ifquality="$(( 2 * (raw + 100) ))"
						[ "${trm_ifquality}" -gt "100" ] && trm_ifquality="100"
						[ "${trm_ifquality}" -lt "0" ] && trm_ifquality="0"
					fi
					if [ -z "${trm_ifquality}" ]; then
						trm_ifstatus="$("${trm_ubuscmd}" -S call network.interface dump 2>/dev/null | "${trm_jsoncmd}" -ql1 -e "@.interface[@.device=\"${ifname}\"].up")"
						if { [ -n "${trm_connection}" ] && [ "${trm_ifstatus}" = "false" ]; } || [ "${wait_time}" -eq "${trm_maxwait}" ]; then
							if [ -n "${trm_connection}" ] && [ "${trm_ifstatus}" = "false" ]; then
								f_log "info" "no signal from uplink"
							else
								f_log "info" "uplink connection could not be established after ${trm_maxwait} seconds"
							fi
							f_vpn "disable"
							trm_connection=""
							trm_ifstatus="${status}"
							f_ctrack "end"
							f_genstatus
							break
						fi
						continue
					elif [ "${trm_ifquality}" -ge "${trm_minquality}" ]; then
						trm_ifstatus="$("${trm_ubuscmd}" -S call network.interface dump 2>/dev/null | "${trm_jsoncmd}" -ql1 -e "@.interface[@.device=\"${ifname}\"].up")"
						if [ "${trm_ifstatus}" = "true" ]; then
							result="$(f_net)"
							if [ "${trm_captive}" = "1" ]; then
								while :; do
									cp_domain="$(printf "%s" "${result}" | "${trm_awkcmd}" -F '['\''| ]' '/^net cp/{printf "%s",$4}')"
									if [ -x "/etc/init.d/dnsmasq" ] && [ -f "/etc/config/dhcp" ] &&
										[ -n "${cp_domain}" ] && ! uci_get "dhcp" "@dnsmasq[0]" "rebind_domain" | "${trm_grepcmd}" -q "${cp_domain}"; then
										uci_add_list "dhcp" "@dnsmasq[0]" "rebind_domain" "${cp_domain}"
										[ -n "$(uci -q changes "dhcp")" ] && uci_commit "dhcp"
										/etc/init.d/dnsmasq reload
										f_log "info" "captive portal domain '${cp_domain}' added to to dhcp rebind whitelist"
									else
										break
									fi
									result="$(f_net)"
								done
								if [ -n "${cp_domain}" ]; then
									trm_connection="${result:-"-"}/${trm_ifquality}"
									f_genstatus
									login_script="$(f_getval "script")"
									if [ -x "${login_script}" ]; then
										login_script_args="$(f_getval "script_args")"
										"${login_script}" ${login_script_args} >/dev/null 2>&1
										rc="${?}"
										f_log "info" "captive portal login script for '${cp_domain}' has been finished  with rc '${rc}'"
										if [ "${rc}" = "0" ]; then
											result="$(f_net)"
										fi
									fi
								fi
							fi
							if [ "${result}" = "net nok" ]; then
								f_vpn "disable"
								if [ "${trm_netcheck}" = "1" ]; then
									f_log "info" "uplink has no internet"
									trm_ifstatus="${status}"
									f_genstatus
									break
								fi
							fi
							trm_connection="${result:-"-"}/${trm_ifquality}"
							f_genstatus
							break
						fi
					elif [ -n "${trm_connection}" ] && { [ "${trm_netcheck}" = "1" ] || [ "${mode}" = "initial" ]; }; then
						f_log "info" "uplink is out of range (${trm_ifquality}/${trm_minquality})"
						f_vpn "disable"
						trm_connection=""
						trm_ifstatus="${status}"
						f_ctrack "end"
						f_genstatus
						break
					elif [ "${mode}" = "initial" ] || [ "${mode}" = "sta" ]; then
						trm_connection=""
						trm_ifstatus="${status}"
						f_genstatus
						break
					fi
				elif [ -n "${trm_connection}" ]; then
					f_vpn "disable"
					trm_connection=""
					trm_ifstatus="${status}"
					f_genstatus
					break
				elif [ "${mode}" = "initial" ]; then
					trm_ifstatus="${status}"
					f_genstatus
					break
				fi
			fi
		fi
		if [ "${mode}" = "initial" ]; then
			trm_ifstatus="${status}"
			f_genstatus
			break
		fi
	done
	f_log "debug" "f_check     ::: mode: ${mode}, name: ${ifname:-"-"}, status: ${trm_ifstatus}, enabled: ${enabled}, connection: ${trm_connection:-"-"}, wait: ${wait_time}, max_wait: ${trm_maxwait}, min_quality/quality: ${trm_minquality}/${trm_ifquality:-"-"}, captive: ${trm_captive}, netcheck: ${trm_netcheck}"
}

# get status information
#
f_getstatus() {
	local key keylist value rtfile

	rtfile="$(uci_get travelmate global trm_rtfile "/tmp/trm_runtime.json")"
	json_load_file "${rtfile}" >/dev/null 2>&1
	if json_select data >/dev/null 2>&1; then
		printf "%s\n" "::: travelmate runtime information"
		json_get_keys keylist
		for key in ${keylist}; do
			json_get_var value "${key}"
			printf "  + %-18s : %s\n" "${key}" "${value}"
		done
	else
		printf "%s\n" "::: no travelmate runtime information available"
	fi
}

# generate status information
#
f_genstatus() {
	local vpn vpn_iface section last_date sta_iface sta_radio sta_essid sta_bssid sta_mac dev_status status="${trm_ifstatus}" ntp_done="0" vpn_done="0" mail_done="0"

	if [ "${status}" = "true" ]; then
		status="connected, ${trm_connection:-"-"}"
		dev_status="$("${trm_ubuscmd}" -S call network.wireless status 2>/dev/null)"
		section="$(printf "%s" "${dev_status}" | "${trm_jsoncmd}" -ql1 -e '@.*.interfaces[@.config.mode="sta"].section')"
		if [ -n "${section}" ]; then
			sta_iface="$(uci_get "wireless" "${section}" "network")"
			sta_radio="$(uci_get "wireless" "${section}" "device")"
			sta_essid="$(uci_get "wireless" "${section}" "ssid")"
			sta_bssid="$(uci_get "wireless" "${section}" "bssid")"
			sta_mac="$(f_mac "get" "${section}")"
			f_getcfg "${sta_radio}" "${sta_essid}" "${sta_bssid}"
		fi
		json_get_var last_date "last_run"

		vpn="$(f_getval "vpn")"
		if  [ "${trm_vpn}" = "1" ] && [ -n "${trm_vpninfolist}" ] && [ "${vpn}" = "1" ] && [ -f "${trm_vpnfile}" ]; then
			vpn_iface="$(f_getval "vpniface")"
			vpn_done="1"
		fi
	elif [ "${status}" = "error" ]; then
		trm_connection=""
		status="program error"
	else
		trm_connection=""
		status="running, not connected"
	fi
	if [ -z "${last_date}" ]; then
		last_date="$(date "+%Y.%m.%d-%H:%M:%S")"
	fi
	if [ -d "${trm_ntplock}" ]; then
		ntp_done="1"
	fi
	if [ "${trm_mail}" = "1" ] && [ -f "${trm_mailfile}" ]; then
		mail_done="1"
	fi
	json_add_string "travelmate_status" "${status}"
	json_add_string "frontend_ver" "${trm_fver}"
	json_add_string "backend_ver" "${trm_bver}"
	json_add_string "station_id" "${sta_radio:-"-"}/${sta_essid:-"-"}/${sta_bssid:-"-"}"
	json_add_string "station_mac" "${sta_mac:-"-"}"
	json_add_string "station_interfaces" "${sta_iface:-"-"}, ${vpn_iface:-"-"}"
	json_add_string "station_subnet" "$(f_subnet)"
	json_add_string "run_flags" "captive: $(f_char ${trm_captive}), proactive: $(f_char ${trm_proactive}), netcheck: $(f_char ${trm_netcheck}), autoadd: $(f_char ${trm_autoadd}), randomize: $(f_char ${trm_randomize})"
	json_add_string "ext_hooks" "ntp: $(f_char ${ntp_done}), vpn: $(f_char ${vpn_done}), mail: $(f_char ${mail_done})"
	json_add_string "last_run" "${last_date}"
	json_add_string "system" "${trm_sysver}"
	json_dump >"${trm_rtfile}"

	if [ "${status%%, net ok/*}" = "connected" ] && [ "${trm_mail}" = "1" ] &&
		[ -x "${trm_mailcmd}" ] && [ -n "${trm_mailreceiver}" ] && [ "${ntp_done}" = "1" ] && [ "${mail_done}" = "0" ]; then
		if [ "${trm_vpn}" != "1" ] || [ "${vpn}" != "1" ] || [ -z "${trm_vpninfolist}" ] || [ "${vpn_done}" = "1" ]; then
			: >"${trm_mailfile}"
			mail_done="1"
			f_mail
		fi
	fi

	f_log "debug" "f_genstatus ::: section: ${section:-"-"}, status: ${status:-"-"}, sta_iface: ${sta_iface:-"-"}, sta_radio: ${sta_radio:-"-"}, sta_essid: ${sta_essid:-"-"}, sta_bssid: ${sta_bssid:-"-"}, ntp: ${ntp_done}, vpn: ${vpn:-"0"}/${vpn_done}, mail: ${trm_mail}/${mail_done}"
}

# send status mail
#
f_mail() {
	local msmtp_debug mail_text

	# load mail template
	#
	if [ -r "${trm_mailtemplate}" ]; then
		. "${trm_mailtemplate}"
	else
		f_log "info" "no mail template"
	fi
	[ -z "${mail_text}" ] && f_log "info" "no mail content"
	[ "${trm_debug}" = "1" ] && msmtp_debug="--debug"

	# send mail
	#
	trm_mailhead="From: ${trm_mailsender}\nTo: ${trm_mailreceiver}\nSubject: ${trm_mailtopic}\nReply-to: ${trm_mailsender}\nMime-Version: 1.0\nContent-Type: text/html;charset=utf-8\nContent-Disposition: inline\n\n"
	printf "%b" "${trm_mailhead}${mail_text}" | "${trm_mailcmd}" --timeout=10 ${msmtp_debug} -a "${trm_mailprofile}" "${trm_mailreceiver}" >/dev/null 2>&1

	f_log "debug" "f_mail      ::: notification: ${trm_mailnotification}, template: ${trm_mailtemplate}, profile: ${trm_mailprofile}, receiver: ${trm_mailreceiver}, rc: ${?}"
}

# write to syslog
#
f_log() {
	local class="${1}" log_msg="${2}"

	if [ -n "${log_msg}" ] && { [ "${class}" != "debug" ] || [ "${trm_debug}" = "1" ]; }; then
		if [ -x "${trm_logcmd}" ]; then
			"${trm_logcmd}" -p "${class}" -t "trm-${trm_bver}[${$}]" "${log_msg::512}"
		else
			printf "%s %s %s\n" "${class}" "trm-${trm_bver}[${$}]" "${log_msg::512}"
		fi
		if [ "${class}" = "err" ]; then
			trm_ifstatus="error"
			f_genstatus
			: >"${trm_pidfile}"
			exit 1
		fi
	fi
}

# wifi scan function
#
f_scan() {
	local result key keylist ssid bssid quality wpa_arr cipher_arr auth_arr radio="${1}" mode="${2}"

	result="$("${trm_ubuscmd}" -S call iwinfo scan "{\"device\":\"${radio}\"}" 2>/dev/null)"
	[ -z "${result}" ] && return 0

	json_load "${result}" || return 0
	json_select results 2>/dev/null || return 0

	json_get_keys keylist
	for key in ${keylist}; do
		json_select "${key}" 2>/dev/null || continue
		json_get_var bssid bssid
		json_get_var ssid ssid
		json_get_var signal signal
		json_get_var channel channel

		ssid="$(printf "%s" "${ssid}" | "${trm_awkcmd}" '{
			gsub(/[\x00-\x1F\x7F]/, "");  # nur Steuerzeichen entfernen
			sub(/^[ \t]+/, "");
			sub(/[ \t]+$/, "");
			print
		}')"
		if [ -z "${ssid}" ]; then
			ssid="hidden"
		else
			ssid="${ssid//\"/\\\"}"
			ssid="\"${ssid}\""
		fi

		bssid="$(printf "%s" "${bssid}" | "${trm_awkcmd}" '{print toupper($0)}')"

		quality="$(( 2 * (signal + 100) ))"
		[ "${quality}" -gt "100" ] && quality="100"
		[ "${quality}" -lt "0" ] && quality="0"

		json_select encryption 2>/dev/null
		json_get_values wpa_arr wpa 2>/dev/null
		json_get_values cipher_arr ciphers 2>/dev/null
		json_get_values auth_arr authentication 2>/dev/null
		json_select .. 2>/dev/null
		wpa_versions="$(printf "%s" "${wpa_arr:-"-"}" | "${trm_awkcmd}" '
			{
				gsub(/[\[\],]/, "");
				for (i=1; i<=NF; i++) {
					if ($i == 1) out = out "WPA1+";
					if ($i == 2) out = out "WPA2+";
					if ($i == 3) out = out "WPA3+";
				}
				sub(/\+$/, "", out);
				print (out == "" ? "-" : out);
			}
		')"
		cipher="$(printf "%s" "${cipher_arr:-"-"}" | "${trm_awkcmd}" '
			{
				gsub(/[\[\]"]/, "");
				gsub(/,/, " ");
				gsub(/[ \t]+/, " ");
				$0 = toupper($0);
				gsub(/ /, "+");
				print ($0=="" ? "-" : $0)
			}
		')"
		auth="$(printf "%s" "${auth_arr:-"-"}" | "${trm_awkcmd}" '
			{
				gsub(/[\[\]"]/, "");
				gsub(/,/, " ");
				gsub(/[ \t]+/, " ");
				$0 = toupper($0);
				gsub(/ /, "+");
				print ($0=="" ? "-" : $0)
			}
		')"

		case "${mode}" in
			full)
				printf "%s %s %s %s %s %s %s\n" \
					"${quality:-"0"}" "${channel:-"0"}" "${bssid:-"-"}" "${wpa_versions:-"-"}" "${cipher:-"-"}" "${auth:-"-"}" "${ssid}"
			;;
			*)
				printf "%s %s %s %s %s\n" \
					"${quality:-"0"}" "${wpa_versions:-"-"}" "-" "${bssid:-"-"}" "${ssid}"
			;;
		esac
		json_select .. 2>/dev/null
	done
}

# main function for connection handling
#
f_main() {
	local radio radio_num radio_phy cnt retrycnt scan_dev scan_list scan_essid scan_bssid scan_rsn scan_wpa scan_quality scan_open
	local station_id section sta sta_essid sta_bssid sta_radio sta_mac open_sta open_essid config_radio config_essid config_bssid

	f_check "initial" "false"
	if [ "${trm_proactive}" = "0" ]; then
		if [ "${trm_connection%%/*}" = "net ok" ]; then
			f_vpn "enable_keep"
		else
			f_vpn "disable"
		fi
	fi
 	f_log "debug" "f_main-1    ::: status: ${trm_ifstatus}, connection: ${trm_connection%%/*}, proactive: ${trm_proactive}"
	if [ "${trm_ifstatus}" != "true" ] || [ "${trm_proactive}" = "1" ]; then
		config_load wireless
		config_foreach f_setif wifi-iface "${trm_proactive}"
		if [ "${trm_ifstatus}" = "true" ] && [ -n "${trm_activesta}" ] && [ "${trm_proactive}" = "1" ]; then
			json_get_var station_id "station_id"
			config_radio="${station_id%%/*}"
			config_essid="${station_id%/*}"
			config_essid="${config_essid#*/}"
			config_bssid="${station_id##*/}"
			config_bssid="${config_bssid//-/}"
			f_check "dev" "true"
			f_log "debug" "f_main-2    ::: config_radio: ${config_radio}, config_essid: \"${config_essid}\", config_bssid: ${config_bssid:-"-"}"
		else
			[ -n "$(uci -q changes "wireless")" ] && uci_commit "wireless"
			f_check "dev" "false"
		fi
		f_log "debug" "f_main-3    ::: radio_list: ${trm_radiolist:-"-"}, sta_list: ${trm_stalist:-"-"}"

		# radio loop
		#
		for radio in ${trm_radiolist}; do
			if ! printf "%s" "${trm_stalist}" | "${trm_grepcmd}" -q "\\-${radio}"; then
				if [ "${trm_autoadd}" = "0" ]; then
					continue
				fi
			fi
			scan_list=""

			# station loop
			#
			for sta in ${trm_stalist:-"${radio}"}; do
				if [ "${sta}" != "${radio}" ]; then
					section="${sta%%-*}"
					sta_radio="$(uci_get "wireless" "${section}" "device")"
					sta_essid="$(uci_get "wireless" "${section}" "ssid")"
					sta_bssid="$(uci_get "wireless" "${section}" "bssid")"
					sta_mac="$(f_mac "get" "${section}")"
					if [ -z "${sta_radio}" ] || [ -z "${sta_essid}" ]; then
						f_log "info" "invalid wireless section '${section}'"
						continue
					fi
					if [ -n "${trm_connection}" ] && [ "${radio}" = "${config_radio}" ] && [ "${sta_radio}" = "${config_radio}" ] &&
						[ "${sta_essid}" = "${config_essid}" ] && [ "${sta_bssid}" = "${config_bssid}" ]; then
						f_ctrack "refresh"
						f_vpn "enable_keep"
						f_log "debug" "f_main-4    ::: config_radio: ${config_radio}, config_essid: ${config_essid}, config_bssid: ${config_bssid:-"-"}"
						return 0
					fi
					f_log "debug" "f_main-5    ::: sta_radio: ${sta_radio}, sta_essid: \"${sta_essid}\", sta_bssid: ${sta_bssid:-"-"}"
				fi
				if [ -z "${scan_list}" ]; then
					scan_list="$(f_scan "${radio}" | "${trm_sortcmd}" -rn)"
				fi
				if [ -z "${scan_list}" ]; then
					f_log "info" "no scan results on '${radio}'"
					continue 2
				fi

				# scan loop
				#
				while read -r scan_quality scan_rsn scan_wpa scan_bssid scan_essid; do
					if [ "${scan_rsn}" = "-" ] && [ "${scan_wpa}" = "-" ]; then
						scan_open="+"
					else
						scan_open="-"
					fi
					if [ -n "${scan_quality}" ] && [ -n "${scan_open}" ] && [ -n "${scan_bssid}" ] && [ -n "${scan_essid}" ]; then
						f_log "debug" "f_main-6    ::: radio(sta/scan): ${sta_radio}/${radio}, essid(sta/scan): \"${sta_essid}\"/${scan_essid}, bssid(sta/scan): ${sta_bssid}/${scan_bssid}, quality(min/scan): ${trm_minquality}/${scan_quality}, open: ${scan_open}"
						if [ "${scan_quality}" -lt "${trm_minquality}" ]; then
							continue 2
						elif [ "${scan_quality}" -ge "${trm_minquality}" ]; then
							if [ "${trm_autoadd}" = "1" ] && [ "${scan_open}" = "+" ] && [ "${scan_essid}" != "hidden" ]; then
								open_essid="${scan_essid%?}"
								open_essid="${open_essid:1}"
								open_sta="$(f_addsta "${radio}" "${open_essid}")"
								if [ -n "${open_sta}" ]; then
									section="${open_sta%%-*}"
									sta_radio="$(uci_get "wireless" "${section}" "device")"
									sta_essid="$(uci_get "wireless" "${section}" "ssid")"
									sta_bssid=""
									sta_mac=""
								fi
							fi
							if { { [ "${scan_essid}" = "\"${sta_essid}\"" ] && { [ -z "${sta_bssid}" ] || [ "${scan_bssid}" = "${sta_bssid}" ]; }; } ||
								{ [ "${scan_bssid}" = "${sta_bssid}" ] && [ "${scan_essid}" = "hidden" ]; }; } && [ "${radio}" = "${sta_radio}" ]; then
								if [ -n "${config_radio}" ]; then
									f_vpn "disable"
									uci_set "wireless" "${trm_activesta}" "disabled" "1"
									[ -n "$(uci -q changes "wireless")" ] && uci_commit "wireless"
									f_check "rev" "false"
									f_ctrack "end"
									f_log "info" "uplink connection terminated '${config_radio}/${config_essid}/${config_bssid:-"-"}'"
									unset config_radio config_essid config_bssid
								fi

								# retry loop
								#
								retrycnt="1"
								f_getcfg "${sta_radio}" "${sta_essid}" "${sta_bssid}"
								while [ "${retrycnt}" -le "${trm_maxretry}" ]; do
									sta_mac="$(f_mac "set" "${section}")"
									uci_set "wireless" "${section}" "disabled" "0"
									f_check "sta" "false" "${sta_radio}" "${sta_essid}" "${sta_bssid}"
									if [ "${trm_ifstatus}" = "true" ]; then
										rm -f "${trm_mailfile}"
										[ -n "$(uci -q changes "wireless")" ] && uci_commit "wireless"
										f_ctrack "start"
										f_log "info" "connected to uplink '${sta_radio}/${sta_essid}/${sta_bssid:-"-"}' with mac '${sta_mac:-"-"}' (${retrycnt}/${trm_maxretry})"
										f_vpn "enable"
										return 0
									else
										uci -q revert "wireless"
										f_check "rev" "false"
										if [ "${retrycnt}" = "${trm_maxretry}" ]; then
											f_ctrack "disabled"
											f_log "info" "uplink has been disabled '${sta_radio}/${sta_essid}/${sta_bssid:-"-"}' (${retrycnt}/${trm_maxretry})"
											continue 2
										else
											f_genstatus
											f_log "info" "can't connect to uplink '${sta_radio}/${sta_essid}/${sta_bssid:-"-"}' (${retrycnt}/${trm_maxretry})"
										fi
									fi
									retrycnt="$((retrycnt + 1))"
									sleep "$((trm_maxwait / 6))"
								done
							fi
						fi
					fi
				done <<-EOV
					${scan_list}
				EOV
			done
		done
	fi
}

# source required system libraries
#
if [ -r "/lib/functions.sh" ] && [ -r "/lib/functions/network.sh" ] && [ -r "/usr/share/libubox/jshn.sh" ]; then
	. "/lib/functions.sh"
	. "/lib/functions/network.sh"
	. "/usr/share/libubox/jshn.sh"
else
	f_log "err" "system libraries not found"
fi

# reference required system utilities
#
trm_awkcmd="$(f_cmd gawk awk)"
trm_sortcmd="$(f_cmd sort)"
trm_grepcmd="$(f_cmd grep)"
trm_pgrepcmd="$(f_cmd pgrep)"
trm_killcmd="$(f_cmd kill)"
trm_jsoncmd="$(f_cmd jsonfilter)"
trm_lookupcmd="$(f_cmd nslookup)"
trm_ubuscmd="$(f_cmd ubus)"
trm_logcmd="$(f_cmd logger)"
trm_wificmd="$(f_cmd wifi)"
trm_fetchcmd="$(f_cmd curl)"
trm_ifstatuscmd="$(f_cmd ifstatus)"
trm_ipcalccmd="$(f_cmd ipcalc.sh)"
trm_mailcmd="$(f_cmd msmtp optional)"

f_system
if [ "${trm_action}" != "stop" ]; then
	[ ! -d "/etc/travelmate" ] && f_log "err" "no travelmate config directory"
	[ ! -r "/etc/config/travelmate" ] && f_log "err" "no travelmate config"
	[ "$(uci_get travelmate global trm_enabled)" = "0" ] && f_log "err" "travelmate is disabled"
fi
