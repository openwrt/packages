#!/bin/sh
# travelmate, a wlan connection manager for travel router
# Copyright (c) 2016-2020 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# set (s)hellcheck exceptions
# shellcheck disable=1091,2016,2039,2059,2086,2143,2181,2188

# set initial defaults
#
LC_ALL=C
PATH="/usr/sbin:/usr/bin:/sbin:/bin"
trm_ver="1.5.5"
trm_enabled=0
trm_debug=0
trm_iface="trm_wwan"
trm_captive=1
trm_proactive=1
trm_netcheck=0
trm_autoadd=0
trm_captiveurl="http://captive.apple.com"
trm_scanbuffer=1024
trm_minquality=35
trm_maxretry=5
trm_maxwait=30
trm_timeout=60
trm_listexpiry=0
trm_radio=""
trm_connection=""
trm_rtfile="/tmp/trm_runtime.json"
trm_wifi="$(command -v wifi)"
trm_wificmd="reload"
trm_fetch="$(command -v uclient-fetch)"
trm_iwinfo="$(command -v iwinfo)"
trm_wpa="$(command -v wpa_supplicant)"
trm_logger="$(command -v logger)"
trm_action="${1:-"start"}"
trm_pidfile="/var/run/travelmate.pid"

# load travelmate environment
#
f_env()
{
	local IFS check wpa_checks

	# (re-)initialize global list variables
	#
	unset trm_devlist trm_stalist trm_radiolist trm_active_sta

	# get system information
	#
	trm_sysver="$(ubus -S call system board 2>/dev/null | jsonfilter -e '@.model' -e '@.release.description' | \
		awk 'BEGIN{ORS=", "}{print $0}' | awk '{print substr($0,1,length($0)-2)}')"

	# load config and check 'enabled' option
	#
	config_cb()
	{
		local name="${1}" type="${2}"
		if [ "${name}" = "travelmate" ] && [ "${type}" = "global" ]
		then
			option_cb()
			{
				local option="${1}" value="${2}"
				eval "${option}=\"${value}\""
			}
		else
			option_cb()
			{
				return 0
			}
		fi
	}
	config_load travelmate

	if [ "${trm_enabled}" -ne 1 ]
	then
		f_log "info" "travelmate is currently disabled, please set 'trm_enabled' to '1' to use this service"
		> "${trm_pidfile}"
		exit 0
	fi

	# get wpa_supplicant capabilities
	#
	wpa_checks="eap sae owe"
	for check in ${wpa_checks}
	do
		if [ -x "${trm_wpa}" ]
		then
			eval "trm_${check}check=\"$("${trm_wpa}" -v${check} >/dev/null 2>&1; printf "%u" "${?}")\""
		else
			eval "trm_${check}check=\"1\""
		fi
	done

	# get wifi reconf capabilities
	#
	if [ -n "$(grep -F "reconf" "${trm_wifi}" 2>/dev/null)" ]
	then
		trm_wificmd="reconf"
	fi

	# enable 'disabled' wifi devices
	#
	config_load wireless
	config_foreach f_prepdev wifi-device
	if [ -n "$(uci -q changes "wireless")" ]
	then
		uci_commit "wireless"
		"${trm_wifi}" "${trm_wificmd}"
		sleep $((trm_maxwait/6))
	fi

	# validate input ranges
	#
	if [ "${trm_minquality}" -lt 20 ] || [ "${trm_minquality}" -gt 80 ]
	then
		trm_minquality=35
	fi
	if [ "${trm_listexpiry}" -lt 0 ] || [ "${trm_listexpiry}" -gt 300 ]
	then
		trm_listexpiry=0
	fi
	if [ "${trm_maxretry}" -lt 1 ] || [ "${trm_maxretry}" -gt 10 ]
	then
		trm_maxretry=5
	fi
	if [ "${trm_maxwait}" -lt 20 ] || [ "${trm_maxwait}" -gt 40 ] || [ "${trm_maxwait}" -ge "${trm_timeout}" ]
	then
		trm_maxwait=30
	fi
	if [ "${trm_timeout}" -lt 30 ] || [ "${trm_timeout}" -gt 300 ] || [ "${trm_timeout}" -le "${trm_maxwait}" ]
	then
		trm_timeout=60
	fi

	# load json runtime file
	#
	json_load_file "${trm_rtfile}" >/dev/null 2>&1
	json_select data >/dev/null 2>&1
	if [ "${?}" -ne 0 ]
	then
		> "${trm_rtfile}"
		json_init
		json_add_object "data"
	fi
	f_log "debug" "f_env     ::: trm_eapcheck: ${trm_eapcheck:-"-"}, trm_saecheck: ${trm_saecheck:-"-"}, trm_owecheck: ${trm_owecheck:-"-"}, trm_wificmd: ${trm_wificmd}"
}

# trim leading and trailing whitespace characters
#
f_trim()
{
	local IFS trim="${1}"

	trim="${trim#"${trim%%[![:space:]]*}"}"
	trim="${trim%"${trim##*[![:space:]]}"}"
	printf '%s' "${trim}"
}

# prepare the 'wifi-device' sections
#
f_prepdev()
{
	local IFS disabled config="${1}"

	disabled="$(uci_get "wireless" "${config}" "disabled")"
	if [ "${disabled}" = "1" ]
	then
		uci_set wireless "${config}" disabled 0
	fi
	f_log "debug" "f_prepdev ::: config: ${config}, disabled: ${disabled:-"-"}"
}

# prepare the 'wifi-iface' sections
#
f_prepif()
{
	local IFS mode network radio encryption eaptype disabled config="${1}" proactive="${2}"

	mode="$(uci_get "wireless" "${config}" "mode")"
	network="$(uci_get "wireless" "${config}" "network")"
	radio="$(uci_get "wireless" "${config}" "device")"
	encryption="$(uci_get "wireless" "${config}" "encryption")"
	eaptype="$(uci_get "wireless" "${config}" "eap_type")"
	disabled="$(uci_get "wireless" "${config}" "disabled")"
	if [ -n "${config}" ] && [ -n "${radio}" ] && [ -n "${mode}" ] && [ -n "${network}" ]
	then
		if [ -z "${trm_radio}" ] && [ -z "$(printf "%s" "${trm_radiolist}" | grep -Fo "${radio}")" ]
		then
			trm_radiolist="$(f_trim "${trm_radiolist} ${radio}")"
		elif [ -n "${trm_radio}" ] && [ -z "${trm_radiolist}" ]
		then
			trm_radiolist="$(f_trim "$(printf "%s" "${trm_radio}" | \
				awk '{while(match(tolower($0),/[a-z0-9]+/)){ORS=" ";print substr(tolower($0),RSTART,RLENGTH);$0=substr($0,RSTART+RLENGTH)}}')")"
		fi
		if [ "${mode}" = "sta" ] && [ "${network}" = "${trm_iface}" ]
		then
			if { [ -z "${disabled}" ] || [ "${disabled}" = "0" ]; } && { [ "${proactive}" -eq 0 ] || [ "${trm_ifstatus}" != "true" ]; }
			then
				uci_set wireless "${config}" disabled 1
			elif [ "${disabled}" = "0" ] && [ "${trm_ifstatus}" = "true" ] && [ "${proactive}" -eq 1 ]
			then
				if [ -z "${trm_active_sta}" ]
				then
					trm_active_sta="${config}"
				else
					uci_set wireless "${config}" disabled 1
				fi
			fi
			if [ -z "${eaptype}" ] || { [ -n "${eaptype}" ] && [ "${trm_eapcheck}" -eq 0 ]; }
			then
				if { [ "${encryption%-*}" != "sae" ] && [ "${encryption%-*}" != "wpa3" ] && [ "${encryption}" != "owe" ]; } || \
					{ { [ "${encryption%-*}" = "sae" ] || [ "${encryption%-*}" = "wpa3" ]; } && [ "${trm_saecheck}" -eq 0 ]; } || \
					{ [ "${encryption}" = "owe" ] && [ "${trm_owecheck}" -eq 0 ]; }
				then
					trm_stalist="$(f_trim "${trm_stalist} ${config}-${radio}")"
				fi
			fi
		fi
	fi
	f_log "debug" "f_prepif  ::: config: ${config}, mode: ${mode}, network: ${network}, radio: ${radio}, trm_radio: ${trm_radio:-"-"}, trm_active_sta: ${trm_active_sta:-"-"}, proactive: ${proactive}, disabled: ${disabled}"
}

# check net status
#
f_net()
{
	local IFS raw result

	raw="$(${trm_fetch} --timeout=$((trm_maxwait/6)) "${trm_captiveurl}" -O /dev/null 2>&1 | tail -n 1)"
	raw="$(printf "%s" "${raw//[\?\$\%\&\+\|\'\"\:\*\=\/]/ }")"
	result="$(printf "%s" "${raw}" | awk '/^Failed to redirect|^Redirected/{printf "%s","net cp";exit}/^Download completed/{printf "%s","net ok";exit}/^Failed|Connection error/{printf "%s","net nok";exit}')"
	if [ "${result}" = "net cp" ]
	then
		result="$(printf "%s" "${raw//*on /}" | awk 'match($0,/^([[:alnum:]_-]+\.)+[[:alpha:]]+/){printf "%s","net cp \047"substr(tolower($0),RSTART,RLENGTH)"\047"}')"
	fi
	printf "%s" "${result}"
	f_log "debug" "f_net     ::: fetch: ${trm_fetch}, timeout: $((trm_maxwait/6)), url: ${trm_captiveurl}, result: ${result}"
}

# check interface status
#
f_check()
{
	local IFS ifname radio dev_status result uci_section login_command login_command_args wait_time=1 mode="${1}" status="${2:-"false"}" cp_domain="${3:-"false"}"

	if [ "${mode}" != "initial" ] && [ "${status}" = "false" ]
	then
		"${trm_wifi}" "${trm_wificmd}"
		sleep $((trm_maxwait/6))
	fi

	while [ "${wait_time}" -le "${trm_maxwait}" ]
	do
		dev_status="$(ubus -S call network.wireless status 2>/dev/null)"
		if [ -n "${dev_status}" ]
		then
			if [ "${mode}" = "dev" ]
			then
				if [ "${trm_ifstatus}" != "${status}" ]
				then
					trm_ifstatus="${status}"
					f_jsnup
				fi
				for radio in ${trm_radiolist}
				do
					result="$(printf "%s" "${dev_status}" | jsonfilter -l1 -e "@.${radio}.up")"
					if [ "${result}" = "true" ] && [ -z "$(printf "%s" "${trm_devlist}" | grep -Fo "${radio}")" ]
					then
						trm_devlist="$(f_trim "${trm_devlist} ${radio}")"
					fi
				done
				if [ "${trm_devlist}" = "${trm_radiolist}" ] || [ "${wait_time}" -eq "${trm_maxwait}" ]
				then
					ifname="${trm_devlist}"
					break
				else
					unset trm_devlist
				fi
			elif [ "${mode}" = "rev" ]
			then
				break
			else
				ifname="$(printf "%s" "${dev_status}" | jsonfilter -l1 -e '@.*.interfaces[@.config.mode="sta"].ifname')"
				if [ -n "${ifname}" ]
				then
					trm_ifquality="$(${trm_iwinfo} "${ifname}" info 2>/dev/null | awk -F "[ ]" '/Link Quality:/{split($NF,var0,"/");printf "%i\n",(var0[1]*100/var0[2])}')"
					if [ "${mode}" = "initial" ] && [ "${trm_captive}" -eq 1 ]
					then
						result="$(f_net)"
						if [ "${cp_domain}" = "true" ]
						then
							cp_domain="$(printf "%s" "${result}" | awk -F "[\\'| ]" '/^net cp/{printf "%s" $4}')"
							uci_section="$(printf "%s" "${dev_status}" | jsonfilter -l1 -e '@.*.interfaces[@.config.mode="sta"].section')"
						fi
					fi
					if [ "${trm_ifquality}" -ge "${trm_minquality}" ] && [ "${result}" != "net nok" ]
					then
						trm_ifstatus="$(ubus -S call network.interface dump 2>/dev/null | jsonfilter -l1 -e "@.interface[@.device=\"${ifname}\"].up")"
						if [ "${trm_ifstatus}" = "true" ]
						then
							if [ "${mode}" = "sta" ] && [ "${trm_captive}" -eq 1 ]
							then
								while true
								do
									result="$(f_net)"
									cp_domain="$(printf "%s" "${result}" | awk -F "[\\'| ]" '/^net cp/{printf "%s" $4}')"
									uci_section="$(printf "%s" "${dev_status}" | jsonfilter -l1 -e '@.*.interfaces[@.config.mode="sta"].section')"
									if [ "${trm_netcheck}" -eq 1 ] && [ "${result}" = "net nok" ]
									then
										trm_ifstatus="${status}"
										f_jsnup
										break 2
									fi
									if [ -z "${cp_domain}" ] || [ -n "$(uci_get "dhcp" "@dnsmasq[0]" "rebind_domain" | grep -Fo "${cp_domain}")" ]
									then
										break
									fi
									uci -q add_list dhcp.@dnsmasq[0].rebind_domain="${cp_domain}"
									f_log "info" "captive portal domain '${cp_domain}' added to to dhcp rebind whitelist"
									if [ -z "$(uci_get "travelmate" "${uci_section}")" ]
									then
										uci_add travelmate "login" "${uci_section}"
										uci_set travelmate "${uci_section}" "command" "none"
										f_log "info" "captive portal login section '${uci_section}' added to travelmate config section"
									fi
								done
								if [ -n "$(uci -q changes "dhcp")" ]
								then
									uci_commit "dhcp"
									/etc/init.d/dnsmasq reload
								fi
								if [ -n "$(uci -q changes "travelmate")" ]
								then
									uci_commit "travelmate"
								fi
							fi
							if [ -n "${cp_domain}" ] && [ "${cp_domain}" != "false" ] && [ -n "${uci_section}" ] && [ "${trm_captive}" -eq 1 ]
							then
								trm_connection="${result:-"-"}/${trm_ifquality}"
								f_jsnup
								login_command="$(uci_get "travelmate" "${uci_section}" "command")"
								if [ -x "${login_command}" ]
								then
									login_command_args="$(uci_get "travelmate" "${uci_section}" "command_args")"
									"${login_command}" ${login_command_args} >/dev/null 2>&1
									rc=${?}
									f_log "info" "captive portal login '${login_command:0:40} ${login_command_args:0:20}' for '${cp_domain}' has been executed with rc '${rc}'"
									if [ "${rc}" -eq 0 ]
									then
										result="$(f_net)"
									fi
								fi
							fi
							trm_connection="${result:-"-"}/${trm_ifquality}"
							f_jsnup
							break
						fi
					elif [ -n "${trm_connection}" ]
					then
						uci_section="$(printf "%s" "${dev_status}" | jsonfilter -l1 -e '@.*.interfaces[@.config.mode="sta"].section')"
						if [ "${trm_ifquality}" -lt "${trm_minquality}" ]
						then
							unset trm_connection
							trm_ifstatus="${status}"
							f_log "info" "uplink '${uci_section}' is out of range (${trm_ifquality}/${trm_minquality})"
						elif [ "${trm_netcheck}" -eq 1 ] && [ "${result}" = "net nok" ]
						then
							unset trm_connection
							trm_ifstatus="${status}"
							f_log "info" "uplink '${uci_section}' has no internet (${result})"
						fi
						f_jsnup
						break
					elif [ "${mode}" = "initial" ]
					then
						f_jsnup
						break
					fi
				elif [ -n "${trm_connection}" ]
				then
					unset trm_connection
					trm_ifstatus="${status}"
					f_jsnup
					break
				elif [ "${mode}" = "initial" ]
				then
					f_jsnup
					break
				fi
			fi
		fi
		wait_time=$((wait_time+1))
		sleep 1
	done
	f_log "debug" "f_check   ::: mode: ${mode}, name: ${ifname:-"-"}, status: ${trm_ifstatus}, connection: ${trm_connection:-"-"}, wait: ${wait_time}, max_wait: ${trm_maxwait}, min_quality: ${trm_minquality}, captive: ${trm_captive}, netcheck: ${trm_netcheck}"
}

# update runtime information
#
f_jsnup()
{
	local IFS uci_section d1 d2 d3 last_date last_station sta_iface sta_radio sta_essid sta_bssid last_status dev_status wpa_status status="${trm_ifstatus}" faulty_list faulty_station="${1}"

	dev_status="$(ubus -S call network.wireless status 2>/dev/null)"
	if [ -n "${dev_status}" ]
	then
		uci_section="$(printf "%s" "${dev_status}" | jsonfilter -l1 -e '@.*.interfaces[@.config.mode="sta"].section')"
		if [ -n "${uci_section}" ]
		then
			sta_iface="$(uci_get "wireless" "${uci_section}" "network")"
			sta_radio="$(uci_get "wireless" "${uci_section}" "device")"
			sta_essid="$(uci_get "wireless" "${uci_section}" "ssid")"
			sta_bssid="$(uci_get "wireless" "${uci_section}" "bssid")"
		fi
	fi

	json_get_var last_date "last_rundate"
	json_get_var last_station "station_id"
	if [ "${status}" = "true" ]
	then
		status="connected (${trm_connection:-"-"})"
		json_get_var last_status "travelmate_status"
		if [ "${last_status}" = "running / not connected" ] || [ "${last_station}" != "${sta_radio:-"-"}/${sta_essid:-"-"}/${sta_bssid:-"-"}" ]
		then
			last_date="$(date "+%Y.%m.%d-%H:%M:%S")"
		fi
	elif [ "${status}" = "error" ]
	then
		unset trm_connection
		status="program error"
	else
		unset trm_connection
		status="running / not connected"
	fi
	if [ -z "${last_date}" ]
	then
		last_date="$(date "+%Y.%m.%d-%H:%M:%S")"
	fi

	json_get_var faulty_list "faulty_stations"
	if [ -n "${faulty_list}" ] && [ "${trm_listexpiry}" -gt 0 ]
	then
		d1="$(date -d "${last_date}" "+%s")"
		d2="$(date "+%s")"
		d3=$(((d2 - d1)/60))
		if [ "${d3}" -ge "${trm_listexpiry}" ]
		then
			faulty_list=""
		fi
	fi

	if [ -n "${faulty_station}" ]
	then
		if [ -z "$(printf "%s" "${faulty_list}" | grep -Fo "${faulty_station}")" ]
		then
			faulty_list="$(f_trim "${faulty_list} ${faulty_station}")"
			last_date="$(date "+%Y.%m.%d-%H:%M:%S")"
		fi
	fi

	if [ "${trm_eapcheck}" -eq 0 ]
	then
		wpa_status="EAP"
	else
		wpa_status="-"
	fi
	if [ "${trm_saecheck}" -eq 0 ]
	then
		wpa_status="${wpa_status}/SAE"
	else
		wpa_status="${wpa_status}/-"
	fi
	if [ "${trm_owecheck}" -eq 0 ]
	then
		wpa_status="${wpa_status}/OWE"
	else
		wpa_status="${wpa_status}/-"
	fi
	json_add_string "travelmate_status" "${status}"
	json_add_string "travelmate_version" "${trm_ver}"
	json_add_string "station_id" "${sta_radio:-"-"}/${sta_essid:-"-"}/${sta_bssid:-"-"}"
	json_add_string "station_interface" "${sta_iface:-"-"}"
	json_add_string "faulty_stations" "${faulty_list}"
	json_add_string "wpa_capabilities" "${wpa_status:-"-"}"
	json_add_string "last_rundate" "${last_date}"
	json_add_string "system" "${trm_sysver}"
	json_dump > "${trm_rtfile}"
	f_log "debug" "f_jsnup   ::: uci_section: ${uci_section:-"-"}, status: ${status:-"-"}, sta_iface: ${sta_iface:-"-"}, sta_radio: ${sta_radio:-"-"}, sta_essid: ${sta_essid:-"-"}, sta_bssid: ${sta_bssid:-"-"}, faulty_list: ${faulty_list:-"-"}, list_expiry: ${trm_listexpiry}"
}

# write to syslog
#
f_log()
{
	local IFS class="${1}" log_msg="${2}"

	if [ -n "${log_msg}" ] && { [ "${class}" != "debug" ] || [ "${trm_debug}" -eq 1 ]; }
	then
		if [ -x "${trm_logger}" ]
		then
			"${trm_logger}" -p "${class}" -t "travelmate-${trm_ver}[${$}]" "${log_msg}"
		else
			printf "%s %s %s\\n" "${class}" "travelmate-${trm_ver}[${$}]" "${log_msg}"
		fi
		if [ "${class}" = "err" ]
		then
			trm_ifstatus="error"
			f_jsnup
			> "${trm_pidfile}"
			exit 1
		fi
	fi
}

# main function for connection handling
#
f_main()
{
	local IFS cnt dev config spec scan_dev scan_list scan_essid scan_bssid scan_open scan_quality uci_essid cfg_essid faulty_list
	local station_id sta sta_essid sta_bssid sta_radio sta_iface active_essid active_bssid active_radio

	f_check "initial" "false" "true"
	f_log "debug" "f_main    ::: status: ${trm_ifstatus}, proactive: ${trm_proactive}"
	if [ "${trm_ifstatus}" != "true" ] || [ "${trm_proactive}" -eq 1 ]
	then
		config_load wireless
		config_foreach f_prepif wifi-iface ${trm_proactive}
		if [ "${trm_ifstatus}" = "true" ] && [ -n "${trm_active_sta}" ] && [ "${trm_proactive}" -eq 1 ]
		then
			json_get_var station_id "station_id"
			active_radio="${station_id%%/*}"
			active_essid="${station_id%/*}"
			active_essid="${active_essid#*/}"
			active_bssid="${station_id##*/}"
			f_check "dev" "true"
			f_log "debug" "f_main    ::: active_radio: ${active_radio}, active_essid: \"${active_essid}\", active_bssid: ${active_bssid:-"-"}"
		else
			uci_commit "wireless"
			f_check "dev"
		fi
		json_get_var faulty_list "faulty_stations"
		f_log "debug" "f_main    ::: iwinfo: ${trm_iwinfo:-"-"}, dev_list: ${trm_devlist:-"-"}, sta_list: ${trm_stalist:0:${trm_scanbuffer}}, faulty_list: ${faulty_list:-"-"}"
		# radio loop
		#
		for dev in ${trm_devlist}
		do
			if [ -z "$(printf "%s" "${trm_stalist}" | grep -o "\\-${dev}")" ]
			then
				f_log "debug" "f_main    ::: no station on '${dev}' - continue"
				continue
			fi
			# station loop
			#
			for sta in ${trm_stalist}
			do
				config="${sta%%-*}"
				sta_radio="${sta##*-}"
				sta_essid="$(uci_get "wireless" "${config}" "ssid")"
				sta_bssid="$(uci_get "wireless" "${config}" "bssid")"
				sta_iface="$(uci_get "wireless" "${config}" "network")"
				json_get_var faulty_list "faulty_stations"
				if [ -n "$(printf "%s" "${faulty_list}" | grep -Fo "${sta_radio}/${sta_essid}/${sta_bssid}")" ]
				then
					f_log "debug" "f_main    ::: faulty station '${sta_radio}/${sta_essid}/${sta_bssid:-"-"}' - continue"
					continue
				fi
				if [ "${dev}" = "${active_radio}" ] && [ "${sta_essid}" = "${active_essid}" ] && [ "${sta_bssid:-"-"}" = "${active_bssid}" ]
				then
					f_log "debug" "f_main    ::: active station prioritized '${active_radio}/${active_essid}/${active_bssid:-"-"}' - break"
					break 2
				fi
				f_log "debug" "f_main    ::: sta_radio: ${sta_radio}, sta_essid: \"${sta_essid}\", sta_bssid: ${sta_bssid:-"-"}"
				if [ -z "${scan_list}" ]
				then
					scan_dev="$(ubus -S call network.wireless status 2>/dev/null | jsonfilter -l1 -e "@.${dev}.interfaces[0].ifname")"
					scan_list="$("${trm_iwinfo}" "${scan_dev:-${dev}}" scan 2>/dev/null | \
						awk 'BEGIN{FS="[[:space:]]"}/Address:/{var1=$NF}/ESSID:/{var2="";for(i=12;i<=NF;i++)if(var2==""){var2=$i}else{var2=var2" "$i};
						gsub(/,/,".",var2)}/Quality:/{split($NF,var0,"/")}/Encryption:/{if($NF=="none"){var3="+"}else{var3="-"};printf "%i,%s,%s,%s\n",(var0[1]*100/var0[2]),var1,var2,var3}' | \
						sort -rn | awk -v buf="${trm_scanbuffer}" 'BEGIN{ORS=","}{print substr($0,1,buf)}')"
					f_log "debug" "f_main    ::: scan_radio: ${dev}, scan_device: ${scan_dev:-"-"}, scan_buffer: ${trm_scanbuffer}, scan_list: ${scan_list:-"-"}"
					if [ -z "${scan_list}" ]
					then
						f_log "debug" "f_main    ::: no scan results on '${dev}/${scan_dev:-"-"}' - continue"
						continue 2
					fi
				fi
				# scan loop
				#
				IFS=","
				for spec in ${scan_list}
				do
					if [ -z "${scan_quality}" ]
					then
						scan_quality="${spec}"
					elif [ -z "${scan_bssid}" ]
					then
						scan_bssid="${spec}"
					elif [ -z "${scan_essid}" ]
					then
						scan_essid="${spec}"
					elif [ -z "${scan_open}" ]
					then
						scan_open="${spec}"
					fi
					if [ -n "${scan_quality}" ] && [ -n "${scan_bssid}" ] && [ -n "${scan_essid}" ] && [ -n "${scan_open}" ]
					then
						if [ "${scan_quality}" -ge "${trm_minquality}" ]
						then
							if { { [ "${scan_essid}" = "\"${sta_essid//,/.}\"" ] && { [ -z "${sta_bssid}" ] || [ "${scan_bssid}" = "${sta_bssid}" ]; } } || \
								{ [ "${scan_bssid}" = "${sta_bssid}" ] && [ "${scan_essid}" = "unknown" ]; } } && [ "${dev}" = "${sta_radio}" ]
							then
								f_log "debug" "f_main    ::: scan_quality: ${scan_quality}, scan_essid: ${scan_essid}, scan_bssid: ${scan_bssid:-"-"}, scan_open: ${scan_open}"
								if [ -n "${active_radio}" ]
								then
									uci_set "wireless" "${trm_active_sta}" "disabled" "1"
									uci_commit "wireless"
									f_log "debug" "f_main    ::: active uplink connection '${active_radio}/${active_essid}/${active_bssid:-"-"}' terminated"
									unset trm_connection active_radio active_essid active_bssid
								fi
								# retry loop
								#
								cnt=1
								while [ "${cnt}" -le "${trm_maxretry}" ]
								do
									uci_set "wireless" "${config}" "disabled" "0"
									trm_radio="${sta_radio}"
									f_check "sta"
									if [ "${trm_ifstatus}" = "true" ]
									then
										unset IFS scan_list
										uci_commit "wireless"
										f_log "info" "connected to uplink '${sta_radio}/${sta_essid}/${sta_bssid:-"-"}' (${cnt}/${trm_maxretry}, ${trm_sysver})"
										return 0
									else
										uci -q revert "wireless"
										f_check "rev"
										if [ "${cnt}" -eq "${trm_maxretry}" ]
										then
											faulty_station="${sta_radio}/${sta_essid}/${sta_bssid:-"-"}"
											f_jsnup "${faulty_station}"
											f_log "info" "uplink disabled '${sta_radio}/${sta_essid}/${sta_bssid:-"-"}' (${cnt}/${trm_maxretry}, ${trm_sysver})"
											break 2
										else
											f_jsnup
											f_log "info" "can't connect to uplink '${sta_radio}/${sta_essid}/${sta_bssid:-"-"}' (${cnt}/${trm_maxretry}, ${trm_sysver})"
										fi
									fi
									cnt=$((cnt+1))
									sleep $((trm_maxwait/6))
								done
							elif [ "${trm_autoadd}" -eq 1 ] && [ "${scan_open}" = "+" ] && [ "${scan_essid}" != "unknown" ]
							then
								cfg_essid="${scan_essid#*\"}"
								cfg_essid="${cfg_essid%\"*}"
								uci_essid="${cfg_essid//[^[:alnum:]_]/_}"
								if [ -z "$(uci_get "wireless" "trm_${uci_essid}")" ]
								then
									uci_add "wireless" "wifi-iface" "trm_${uci_essid}"
									uci_set "wireless" "trm_${uci_essid}" "mode" "sta"
									uci_set "wireless" "trm_${uci_essid}" "network" "${trm_iface}"
									uci_set "wireless" "trm_${uci_essid}" "device" "${sta_radio}"
									uci_set "wireless" "trm_${uci_essid}" "ssid" "${cfg_essid}"
									uci_set "wireless" "trm_${uci_essid}" "encryption" "none"
									uci_set "wireless" "trm_${uci_essid}" "disabled" "1"
									uci_commit "wireless"
									f_log "info" "open uplink '${sta_radio}/${cfg_essid}' added to wireless config"
								fi
							fi
							unset scan_quality scan_bssid scan_essid scan_open
							continue
						else
							unset scan_quality scan_bssid scan_essid scan_open
							continue
						fi
					fi
				done
				unset IFS scan_quality scan_bssid scan_essid scan_open
			done
			unset scan_list
		done
	fi
}

# source required system libraries
#
if [ -r "/lib/functions.sh" ] && [ -r "/usr/share/libubox/jshn.sh" ]
then
	. "/lib/functions.sh"
	. "/usr/share/libubox/jshn.sh"
else
	f_log "err" "system libraries not found"
fi

# control travelmate actions
#
f_env
while true
do
	if [ -z "${trm_action}" ]
	then
		rc=0
		while true
		do
			if [ "${rc}" -eq 0 ]
			then
				f_check "initial"
			fi
			sleep ${trm_timeout} 0
			rc=${?}
			if [ "${rc}" -ne 0 ]
			then
				f_check "initial"
			fi
			if [ "${rc}" -eq 0 ] || { [ "${rc}" -ne 0 ] && [ "${trm_ifstatus}" = "false" ]; }
			then
				break
			fi
		done
	elif [ "${trm_action}" = "stop" ]
	then
		f_log "info" "travelmate instance stopped ::: action: ${trm_action}, pid: $(cat ${trm_pidfile} 2>/dev/null)"
		> "${trm_rtfile}"
		> "${trm_pidfile}"
		exit 0
	else
		f_log "info" "travelmate instance started ::: action: ${trm_action}, pid: ${$}"
		unset trm_action
	fi
	json_cleanup
	f_env
	f_main
done
