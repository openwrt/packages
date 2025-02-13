# banIP shared function library/include - ban incoming and outgoing IPs via named nftables Sets
# Copyright (c) 2018-2025 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# (s)hellcheck exceptions
# shellcheck disable=all

# environment
#
export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

# initial defaults
#
ban_basedir="/tmp"
ban_backupdir="/tmp/banIP-backup"
ban_reportdir="/tmp/banIP-report"
ban_errordir="/tmp/banIP-error"
ban_feedfile="/etc/banip/banip.feeds"
ban_countryfile="/etc/banip/banip.countries"
ban_customfeedfile="/etc/banip/banip.custom.feeds"
ban_allowlist="/etc/banip/banip.allowlist"
ban_blocklist="/etc/banip/banip.blocklist"
ban_mailtemplate="/etc/banip/banip.tpl"
ban_pidfile="/var/run/banip.pid"
ban_rtfile="/var/run/banip_runtime.json"
ban_rdapfile="/var/run/banip_rdap.json"
ban_rdapurl="https://rdap.db.ripe.net/ip/"
ban_lock="/var/run/banip.lock"
ban_logreadfile="/var/log/messages"
ban_logreadcmd=""
ban_mailsender="no-reply@banIP"
ban_mailreceiver=""
ban_mailtopic="banIP notification"
ban_mailprofile="ban_notify"
ban_mailnotification="0"
ban_remotelog="0"
ban_remotetoken=""
ban_nftloglevel="warn"
ban_nftpriority="-100"
ban_nftpolicy="memory"
ban_nftexpiry=""
ban_nftretry="5"
ban_nftcount="0"
ban_icmplimit="10"
ban_synlimit="10"
ban_udplimit="100"
ban_loglimit="100"
ban_logcount="1"
ban_logterm=""
ban_region=""
ban_country=""
ban_countrysplit="0"
ban_asn=""
ban_asnsplit="0"
ban_logprerouting="0"
ban_loginbound="0"
ban_logoutbound="0"
ban_allowurl=""
ban_allowflag=""
ban_allowlistonly="0"
ban_autoallowlist="1"
ban_autoallowuplink="subnet"
ban_autoblocklist="1"
ban_autoblocksubnet="0"
ban_deduplicate="1"
ban_splitsize="0"
ban_autodetect="1"
ban_feed=""
ban_feedin=""
ban_feedout=""
ban_feedinout=""
ban_feedcomplete=""
ban_feedreset=""
ban_blockpolicy="drop"
ban_protov4="0"
ban_protov6="0"
ban_ifv4=""
ban_ifv6=""
ban_dev=""
ban_vlanallow=""
ban_vlanblock=""
ban_uplink=""
ban_fetchcmd=""
ban_fetchparm=""
ban_fetchinsecure=""
ban_fetchretry="5"
ban_rdapparm=""
ban_etagparm=""
ban_cores=""
ban_packages=""
ban_trigger=""
ban_resolver=""
ban_enabled="0"
ban_debug="0"

# gather system information
#
f_system() {
	local cpu core

	if [ -z "${ban_dev}" ]; then
		ban_debug="$(uci_get banip global ban_debug "0")"
		ban_cores="$(uci_get banip global ban_cores)"
	fi
	ban_packages="$("${ban_ubuscmd}" -S call rpc-sys packagelist '{ "all": true }' 2>/dev/null)"
	ban_ver="$(printf "%s" "${ban_packages}" | "${ban_jsoncmd}" -ql1 -e '@.packages.banip')"
	ban_sysver="$("${ban_ubuscmd}" -S call system board 2>/dev/null | "${ban_jsoncmd}" -ql1 -e '@.model' -e '@.release.target' -e '@.release.distribution' -e '@.release.version' -e '@.release.revision' |
		"${ban_awkcmd}" 'BEGIN{RS="";FS="\n"}{printf "%s, %s, %s %s %s %s",$1,$2,$3,$4,$5,$6}')"
	if [ -z "${ban_cores}" ]; then
		cpu="$("${ban_grepcmd}" -c '^processor' /proc/cpuinfo 2>/dev/null)"
		core="$("${ban_grepcmd}" -cm1 '^core id' /proc/cpuinfo 2>/dev/null)"
		[ "${cpu}" = "0" ] && cpu="1"
		[ "${core}" = "0" ] && core="1"
		ban_cores="$((cpu * core))"
		[ "${ban_cores}" -gt "16" ] && ban_cores="16"
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

# create directories
#
f_mkdir() {
	local dir="${1}"

	if [ ! -d "${dir}" ]; then
		rm -f "${dir}"
		mkdir -p "${dir}"
		f_log "debug" "f_mkdir     ::: directory: ${dir}"
	fi
}

# create files
#
f_mkfile() {
	local file="${1}"

	if [ ! -f "${file}" ]; then
		: >"${file}"
		f_log "debug" "f_mkfile    ::: file: ${file}"
	fi
}

# create temporary files and directories
#
f_tmp() {
	f_mkdir "${ban_basedir}"
	ban_tmpdir="$(mktemp -p "${ban_basedir}" -d)"
	ban_tmpfile="$(mktemp -p "${ban_tmpdir}" -tu)"

	f_log "debug" "f_tmp       ::: base_dir: ${ban_basedir:-"-"}, tmp_dir: ${ban_tmpdir:-"-"}"
}

# remove directories
#
f_rmdir() {
	local dir="${1}"

	if [ -d "${dir}" ]; then
		rm -rf "${dir}"
		f_log "debug" "f_rmdir     ::: directory: ${dir}"
	fi
}

# convert chars
#
f_char() {
	local char="${1}"

	if [ "${char}" = "1" ]; then
		printf "%s" "✔"
	elif [ "${char}" = "0" ] || [ -z "${char}" ]; then
		printf "%s" "✘"
	else
		printf "%s" "${char}"
	fi
}

# trim strings
#
f_trim() {
	local string="${1}"

	string="${string#"${string%%[![:space:]]*}"}"
	string="${string%"${string##*[![:space:]]}"}"
	printf "%s" "${string}"
}

# remove log monitor
#
f_rmpid() {
	local ppid pid pids

	ppid="$("${ban_catcmd}" "${ban_pidfile}" 2>/dev/null)"
	if [ -n "${ppid}" ]; then
		pids="$("${ban_pgrepcmd}" -P "${ppid}" 2>/dev/null)"
		for pid in ${pids}; do
			pids="${pids} $("${ban_pgrepcmd}" -P "${pid}" 2>/dev/null)"
		done
		for pid in ${pids}; do
			kill -INT "${pid}" >/dev/null 2>&1
		done
	fi
	: >"${ban_rdapfile}" >"${ban_pidfile}"
}

# write log messages
#
f_log() {
	local class="${1}" log_msg="${2}"

	if [ -n "${log_msg}" ] && { [ "${class}" != "debug" ] || [ "${ban_debug}" = "1" ]; }; then
		if [ -x "${ban_logcmd}" ]; then
			"${ban_logcmd}" -p "${class}" -t "banIP-${ban_ver}[${$}]" "${log_msg::256}"
		else
			printf "%s %s %s\n" "${class}" "banIP-${ban_ver}[${$}]" "${log_msg::256}"
		fi
	fi
	if [ "${class}" = "err" ] || [ "${class}" = "emerg" ]; then
		if [ "${class}" = "err" ]; then
			"${ban_nftcmd}" delete table inet banIP >/dev/null 2>&1
			if [ "$(uci_get banip global ban_enabled)" = "1" ]; then
				f_genstatus "error"
				[ "${ban_mailnotification}" = "1" ] && [ -n "${ban_mailreceiver}" ] && [ -x "${ban_mailcmd}" ] && f_mail
			else
				f_genstatus "disabled"
			fi
		fi
		f_rmdir "${ban_tmpdir}"
		f_rmpid
		rm -rf "${ban_lock}"
		exit 1
	fi
}

# load config
#
f_conf() {
	local rir ccode region country

	unset ban_dev ban_vlanallow ban_vlanblock ban_ifv4 ban_ifv6 ban_feed ban_allowurl ban_feedin ban_feedout ban_feedinout ban_feedreset ban_feedcomplete ban_logterm ban_region ban_country ban_asn
	config_cb() {
		option_cb() {
			local option="${1}" value="${2//\"/\\\"}"

			eval "${option}=\"${value}\""
		}
		list_cb() {
			local option="${1}" value="${2//\"/\\\"}"

			case "${option}" in
				"ban_ifv4")
					eval "${option}=\"$(printf "%s" "${ban_ifv4}")${value} \""
					;;
				"ban_ifv6")
					eval "${option}=\"$(printf "%s" "${ban_ifv6}")${value} \""
					;;
				"ban_dev")
					eval "${option}=\"$(printf "%s" "${ban_dev}")${value} \""
					;;
				"ban_vlanallow")
					eval "${option}=\"$(printf "%s" "${ban_vlanallow}")${value} \""
					;;
				"ban_vlanblock")
					eval "${option}=\"$(printf "%s" "${ban_vlanblock}")${value} \""
					;;
				"ban_trigger")
					eval "${option}=\"$(printf "%s" "${ban_trigger}")${value} \""
					;;
				"ban_feed")
					eval "${option}=\"$(printf "%s" "${ban_feed}")${value} \""
					;;
				"ban_feedin")
					eval "${option}=\"$(printf "%s" "${ban_feedin}")${value} \""
					;;
				"ban_feedout")
					eval "${option}=\"$(printf "%s" "${ban_feedout}")${value} \""
					;;
				"ban_feedinout")
					eval "${option}=\"$(printf "%s" "${ban_feedinout}")${value} \""
					;;
				"ban_feedreset")
					eval "${option}=\"$(printf "%s" "${ban_feedreset}")${value} \""
					;;
				"ban_feedcomplete")
					eval "${option}=\"$(printf "%s" "${ban_feedcomplete}")${value} \""
					;;
				"ban_allowurl")
					eval "${option}=\"$(printf "%s" "${ban_allowurl}")${value} \""
					;;
				"ban_logterm")
					eval "${option}=\"$(printf "%s" "${ban_logterm}")${value}\\|\""
					;;
				"ban_region")
					eval "${option}=\"$(printf "%s" "${ban_region}")${value} \""
					;;
				"ban_country")
					eval "${option}=\"$(printf "%s" "${ban_country}")${value} \""
					;;
				"ban_asn")
					eval "${option}=\"$(printf "%s" "${ban_asn}")${value} \""
					;;
			esac
		}
	}
	config_load banip
	[ -f "${ban_logreadfile}" ] && ban_logreadcmd="$(command -v tail)" || ban_logreadcmd="$(command -v logread)"

	for rir in ${ban_region}; do
		while read -r ccode region country; do
			if [ "${rir}" = "${region}" ] && ! printf "%s" "${ban_country}" | "${ban_grepcmd}" -qw "${ccode}"; then
				ban_country="${ban_country} ${ccode}"
			fi
		done <"${ban_countryfile}"
	done
}

# get nft/monitor actuals
#
f_actual() {
	local nft monitor ppid pids pid

	if "${ban_nftcmd}" -t list table inet banIP >/dev/null 2>&1; then
		nft="$(f_char "1")"
	else
		nft="$(f_char "0")"
	fi

	ppid="$("${ban_catcmd}" "${ban_pidfile}" 2>/dev/null)"
	if [ -n "${ppid}" ]; then
		pids="$("${ban_pgrepcmd}" -P "${ppid}" 2>/dev/null)"
		for pid in ${pids}; do
			if "${ban_pgrepcmd}" -f "${ban_logreadcmd##*/}" -P "${pid}" >/dev/null 2>&1; then
				monitor="$(f_char "1")"
				break
			else
				monitor="$(f_char "0")"
			fi
		done
	else
		monitor="$(f_char "0")"
	fi
	printf "%s" "nft: ${nft}, monitor: ${monitor}"
}

# get fetch utility
#
f_getfetch() {
	local util utils insecure

	ban_fetchcmd="$(command -v "${ban_fetchcmd}")"
	if { [ "${ban_autodetect}" = "1" ] && [ -z "${ban_fetchcmd}" ]; } || [ ! -x "${ban_fetchcmd}" ]; then
		utils="aria2 curl wget-ssl libustream-openssl libustream-wolfssl libustream-mbedtls"
		for util in ${utils}; do
			if printf "%s" "${ban_packages}" | "${ban_jsoncmd}" -ql1 -e "@.packages[\"${util}\"]" >/dev/null 2>&1; then
				case "${util}" in
					"aria2")
						util="aria2c"
						;;
					"wget-ssl")
						util="wget"
						;;
					"libustream-openssl" | "libustream-wolfssl" | "libustream-mbedtls")
						util="uclient-fetch"
						;;
				esac
				if [ -x "$(command -v "${util}")" ]; then
					ban_fetchcmd="$(command -v "${util}")"
					uci_set banip global ban_fetchcmd "${util}"
					uci_commit "banip"
					break
				fi
			fi
		done
	fi

	[ ! -x "${ban_fetchcmd}" ] && f_log "err" "download utility with SSL support not found, please set 'ban_fetchcmd' manually"
	case "${ban_fetchcmd##*/}" in
		"aria2c")
			[ "${ban_fetchinsecure}" = "1" ] && insecure="--check-certificate=false"
			ban_fetchparm="${ban_fetchparm:-"${insecure} --timeout=20 --retry-wait=10 --max-tries=${ban_fetchretry} --max-file-not-found=${ban_fetchretry} --allow-overwrite=true --auto-file-renaming=false --log-level=warn --dir=/ -o"}"
			ban_rdapparm="--timeout=5 --allow-overwrite=true --auto-file-renaming=false --dir=/ -o"
			ban_etagparm="--timeout=5 --allow-overwrite=true --auto-file-renaming=false --dir=/ --dry-run --log -"
			;;
		"curl")
			[ "${ban_fetchinsecure}" = "1" ] && insecure="--insecure"
			ban_fetchparm="${ban_fetchparm:-"${insecure} --connect-timeout 20 --retry-delay 10 --retry ${ban_fetchretry} --retry-max-time $((ban_fetchretry * 20)) --retry-all-errors --fail --silent --show-error --location -o"}"
			ban_rdapparm="--connect-timeout 5 --silent --location -o"
			ban_etagparm="--connect-timeout 5 --silent --location --head"
			;;
		"wget")
			[ "${ban_fetchinsecure}" = "1" ] && insecure="--no-check-certificate"
			ban_fetchparm="${ban_fetchparm:-"${insecure} --no-cache --no-cookies --timeout=20 --waitretry=10 --tries=${ban_fetchretry} --retry-connrefused -O"}"
			ban_rdapparm="--timeout=5 -O"
			ban_etagparm="--timeout=5 --spider --server-response"
			;;
		"uclient-fetch")
			[ "${ban_fetchinsecure}" = "1" ] && insecure="--no-check-certificate"
			ban_fetchparm="${ban_fetchparm:-"${insecure} --timeout=20 -O"}"
			ban_rdapparm="--timeout=5 -O"
			;;
	esac

	f_log "debug" "f_getfetch  ::: auto: ${ban_autodetect}, cmd: ${ban_fetchcmd:-"-"}, fetch_parm: ${ban_fetchparm:-"-"}, rdap_parm: ${ban_rdapparm:-"-"}, etag_parm: ${ban_etagparm:-"-"}"
}

# get wan interfaces
#
f_getif() {
	local iface iface_del update="0"

	if [ "${ban_autodetect}" = "1" ]; then
		network_flush_cache
		network_find_wan iface
		if [ -n "${iface}" ] && [ "${iface}" != "$(f_trim "${ban_ifv4}")" ] && "${ban_ubuscmd}" -t 10 wait_for network.interface."${iface}" >/dev/null 2>&1; then
			for iface_del in ${ban_ifv4}; do
				uci_remove_list banip global ban_ifv4 "${iface_del}"
				f_log "info" "remove IPv4 interface '${iface_del}' from config"
			done
			ban_protov4="1"
			ban_ifv4="${iface}"
			uci_set banip global ban_protov4 "1"
			uci_add_list banip global ban_ifv4 "${iface}"
			f_log "info" "add IPv4 interface '${iface}' to config"
		fi
		network_find_wan6 iface
		if [ -n "${iface}" ] && [ "${iface}" != "$(f_trim "${ban_ifv6}")" ] && "${ban_ubuscmd}" -t 10 wait_for network.interface."${iface}" >/dev/null 2>&1; then
			for iface_del in ${ban_ifv6}; do
				uci_remove_list banip global ban_ifv6 "${iface_del}"
				f_log "info" "remove IPv6 interface '${iface_del}' from config"
			done
			ban_protov6="1"
			ban_ifv6="${iface}"
			uci_set banip global ban_protov6 "1"
			uci_add_list banip global ban_ifv6 "${iface}"
			f_log "info" "add IPv6 interface '${iface}' to config"
		fi
	fi
	if [ -n "$(uci -q changes "banip")" ]; then
		update="1"
		uci_commit "banip"
	else
		for iface in ${ban_ifv4} ${ban_ifv6}; do
			if ! "${ban_ubuscmd}" -t 10 wait_for network.interface."${iface}" >/dev/null 2>&1; then
				f_log "err" "no wan interface '${iface}'"
			fi
		done
	fi
	ban_ifv4="$(f_trim "${ban_ifv4}")"
	ban_ifv6="$(f_trim "${ban_ifv6}")"
	[ -z "${ban_ifv4}" ] && [ -z "${ban_ifv6}" ] && f_log "err" "no wan interfaces"

	f_log "debug" "f_getif     ::: auto/update: ${ban_autodetect}/${update}, interfaces (4/6): ${ban_ifv4}/${ban_ifv6}, protocols (4/6): ${ban_protov4}/${ban_protov6}"
}

# get wan devices
#
f_getdev() {
	local dev dev_del iface update="0"

	if [ "${ban_autodetect}" = "1" ]; then
		network_flush_cache
		dev_del="${ban_dev}"
		for iface in ${ban_ifv4} ${ban_ifv6}; do
			network_get_device dev "${iface}"
			if [ -n "${dev}" ]; then
				dev_del="${dev_del/${dev} / }"
				if ! printf " %s " "${ban_dev}" | "${ban_grepcmd}" -q " ${dev} "; then
					ban_dev="${ban_dev}${dev} "
					uci_add_list banip global ban_dev "${dev}"
					f_log "info" "add device '${dev}' to config"
				fi
			fi
		done
		for dev in ${dev_del}; do
			ban_dev="${ban_dev/${dev} / }"
			uci_remove_list banip global ban_dev "${dev}"
			f_log "info" "remove device '${dev}' from config"
		done
	fi
	if [ -n "$(uci -q changes "banip")" ]; then
		update="1"
		uci_commit "banip"
	fi
	ban_dev="$(f_trim "${ban_dev}")"
	[ -z "${ban_dev}" ] && f_log "err" "no wan devices"

	f_log "debug" "f_getdev    ::: auto/update: ${ban_autodetect}/${update}, wan_devices: ${ban_dev}"
}

# get local uplink
#
f_getuplink() {
	local uplink iface ip

	if [ "${ban_autoallowlist}" = "1" ] && [ "${ban_autoallowuplink}" != "disable" ]; then
		for iface in ${ban_ifv4} ${ban_ifv6}; do
			network_flush_cache
			if [ "${ban_autoallowuplink}" = "subnet" ]; then
				network_get_subnet uplink "${iface}"
			elif [ "${ban_autoallowuplink}" = "ip" ]; then
				network_get_ipaddr uplink "${iface}"
			fi
			if [ -n "${uplink}" ] && ! printf " %s " "${ban_uplink}" | "${ban_grepcmd}" -q " ${uplink} "; then
				ban_uplink="${ban_uplink}${uplink} "
			fi
			if [ "${ban_autoallowuplink}" = "subnet" ]; then
				network_get_subnet6 uplink "${iface}"
			elif [ "${ban_autoallowuplink}" = "ip" ]; then
				network_get_ipaddr6 uplink "${iface}"
			fi
			if [ -n "${uplink%fe80::*}" ] && ! printf " %s " "${ban_uplink}" | "${ban_grepcmd}" -q " ${uplink} "; then
				ban_uplink="${ban_uplink}${uplink} "
			fi
		done
		ban_uplink="$(f_trim "${ban_uplink}")"
		for ip in ${ban_uplink}; do
			if ! "${ban_grepcmd}" -q "${ip} " "${ban_allowlist}"; then
				"${ban_sedcmd}" -i "/# uplink added on /d" "${ban_allowlist}"
				break
			fi
		done
		date="$(date "+%Y-%m-%d %H:%M:%S")"
		for ip in ${ban_uplink}; do
			if ! "${ban_grepcmd}" -q "${ip} " "${ban_allowlist}"; then
				printf "%-45s%s\n" "${ip}" "# uplink added on ${date}" >>"${ban_allowlist}"
				f_log "info" "add uplink '${ip}' to local allowlist"
			fi
		done
	elif [ "${ban_autoallowlist}" = "1" ] && [ "${ban_autoallowuplink}" = "disable" ]; then
		"${ban_sedcmd}" -i "/# uplink added on /d" "${ban_allowlist}"
	fi

	f_log "debug" "f_getuplink ::: auto-allow/auto-uplink: ${ban_autoallowlist}/${ban_autoallowuplink}, uplink: ${ban_uplink:-"-"}"
}

# get feed information
#
f_getfeed() {
	json_init
	if [ -s "${ban_customfeedfile}" ]; then
		if json_load_file "${ban_customfeedfile}" >/dev/null 2>&1; then
			return
		else
			f_log "info" "can't load banIP custom feed file"
		fi
	fi
	if [ -s "${ban_feedfile}" ] && json_load_file "${ban_feedfile}" >/dev/null 2>&1; then
		return
	else
		f_log "err" "can't load banIP feed file"
	fi
}

# get Set elements
#
f_getelements() {
	local file="${1}"

	[ -s "${file}" ] && printf "%s" "elements={ $("${ban_catcmd}" "${file}" 2>/dev/null) };"
}

# handle etag http header
#
f_etag() {
	local http_head http_code etag_id etag_rc out_rc="4" feed="${1}" feed_url="${2}" feed_suffix="${3}"

	if [ -n "${ban_etagparm}" ]; then
		[ ! -f "${ban_backupdir}/banIP.etag" ] && : >"${ban_backupdir}/banIP.etag"
		http_head="$("${ban_fetchcmd}" ${ban_etagparm} "${feed_url}" 2>&1)"
		http_code="$(printf "%s" "${http_head}" | "${ban_awkcmd}" 'tolower($0)~/^http\/[0123\.]+ /{printf "%s",$2}')"
		etag_id="$(printf "%s" "${http_head}" | "${ban_awkcmd}" 'tolower($0)~/^[[:space:]]*etag: /{gsub("\"","");printf "%s",$2}')"
		etag_rc="${?}"

		if [ "${http_code}" = "404" ] || { [ "${etag_rc}" = "0" ] && [ -n "${etag_id}" ] && "${ban_grepcmd}" -q "^${feed}${feed_suffix}[[:space:]]\+${etag_id}\$" "${ban_backupdir}/banIP.etag"; }; then
			out_rc="0"
		elif [ "${etag_rc}" = "0" ] && [ -n "${etag_id}" ] && ! "${ban_grepcmd}" -q "^${feed}${feed_suffix}[[:space:]]\+${etag_id}\$" "${ban_backupdir}/banIP.etag"; then
			"${ban_sedcmd}" -i "/^${feed}${feed_suffix}/d" "${ban_backupdir}/banIP.etag"
			printf "%-20s%s\n" "${feed}${feed_suffix}" "${etag_id}" >>"${ban_backupdir}/banIP.etag"
			out_rc="2"
		fi
	fi

	f_log "debug" "f_etag      ::: feed: ${feed}, suffix: ${feed_suffix:-"-"}, http_code: ${http_code:-"-"}, etag_id: ${etag_id:-"-"} , etag_rc: ${etag_rc:-"-"}, rc: ${out_rc}"
	return "${out_rc}"
}

# load file in nftset
#
f_nftload() {
	local cnt="1" max_cnt="${ban_nftretry:-"5"}" load_rc="4" load_log="" file="${1}" errmsg="${2}"

	while [ "${load_rc}" != "0" ]; do
		load_log="$("${ban_nftcmd}" -f "${file}" 2>&1)"
		load_rc="${?}"
		if [ "${load_rc}" = "0" ]; then
			break
		elif [ "${cnt}" = "${max_cnt}" ]; then
			[ ! -d "${ban_errordir}" ] && f_mkdir "${ban_errordir}"
			"${ban_catcmd}" "${file}" 2>/dev/null >"${ban_errordir}/err.${file##*/}"
			f_log "info" "${errmsg}, ${load_log::256}"
			break
		fi
		cnt="$((cnt + 1))"
	done

	f_log "debug" "f_nftload   ::: file: ${file##*/}, load_rc: ${load_rc}, cnt: ${cnt}, max_cnt: ${max_cnt}"
	return "${load_rc}"
}

# build initial nft file with base table, chains and rules
#
f_nftinit() {
	local wan_dev vlan_allow vlan_block log_ct log_icmp log_syn log_udp log_tcp flag tmp_proto tmp_port allow_dport feed_rc="0" file="${1}"

	wan_dev="$(printf "%s" "${ban_dev}" | "${ban_sedcmd}" 's/^/\"/;s/$/\"/;s/ /\", \"/g')"
	[ -n "${ban_vlanallow}" ] && vlan_allow="$(printf "%s" "${ban_vlanallow%%?}" | "${ban_sedcmd}" 's/^/\"/;s/$/\"/;s/ /\", \"/g')"
	[ -n "${ban_vlanblock}" ] && vlan_block="$(printf "%s" "${ban_vlanblock%%?}" | "${ban_sedcmd}" 's/^/\"/;s/$/\"/;s/ /\", \"/g')"

	for flag in ${ban_allowflag}; do
		case "${flag}" in
			"tcp" | "udp")
				if [ -z "${tmp_proto}" ]; then
					tmp_proto="${flag}"
				elif ! printf "%s" "${tmp_proto}" | "${ban_grepcmd}" -qw "${flag}"; then
					tmp_proto="${tmp_proto}, ${flag}"
				fi
				;;
			"${flag//[![:digit:]-]/}")
				if [ -z "${tmp_port}" ]; then
					tmp_port="${flag}"
				elif ! printf "%s" "${tmp_port}" | "${ban_grepcmd}" -qw "${flag}"; then
					tmp_port="${tmp_port}, ${flag}"
				fi
				;;
		esac
	done
	if [ -n "${tmp_proto}" ] && [ -n "${tmp_port}" ]; then
		allow_dport="meta l4proto { ${tmp_proto} } th dport { ${tmp_port} }"
	fi

	if [ "${ban_logprerouting}" = "1" ]; then
		log_icmp="log level ${ban_nftloglevel} prefix \"banIP/pre-icmp/drop: \""
		log_syn="log level ${ban_nftloglevel} prefix \"banIP/pre-syn/drop: \""
		log_udp="log level ${ban_nftloglevel} prefix \"banIP/pre-udp/drop: \""
		log_tcp="log level ${ban_nftloglevel} prefix \"banIP/pre-tcp/drop: \""
		log_ct="log level ${ban_nftloglevel} prefix \"banIP/pre-ct/drop: \""
	fi

	{
		# nft header (tables, base and regular chains)
		#
		printf "%s\n\n" "#!${ban_nftcmd} -f"
		if "${ban_nftcmd}" -t list table inet banIP >/dev/null 2>&1; then
			printf "%s\n" "delete table inet banIP"
		fi
		printf "%s\n" "add table inet banIP"
		# base chains
		#
		printf "%s\n" "add chain inet banIP pre-routing { type filter hook prerouting priority -199; policy accept; }"
		printf "%s\n" "add chain inet banIP wan-input { type filter hook input priority ${ban_nftpriority}; policy accept; }"
		printf "%s\n" "add chain inet banIP wan-forward { type filter hook forward priority ${ban_nftpriority}; policy accept; }"
		printf "%s\n" "add chain inet banIP lan-forward { type filter hook forward priority ${ban_nftpriority}; policy accept; }"
		# regular chains
		#
		printf "%s\n" "add chain inet banIP _inbound"
		printf "%s\n" "add chain inet banIP _outbound"
		printf "%s\n" "add chain inet banIP _reject"
		# named counter
		#
		printf "%s\n" "add counter inet banIP cnt_icmpflood"
		printf "%s\n" "add counter inet banIP cnt_udpflood"
		printf "%s\n" "add counter inet banIP cnt_synflood"
		printf "%s\n" "add counter inet banIP cnt_tcpinvalid"
		printf "%s\n" "add counter inet banIP cnt_ctinvalid"

		# default reject chain rules
		#
		printf "%s\n" "add rule inet banIP _reject iifname != { ${wan_dev} } meta l4proto tcp reject with tcp reset"
		printf "%s\n" "add rule inet banIP _reject reject with icmpx host-unreachable"

		# default pre-routing rules
		#
		printf "%s\n" "add rule inet banIP pre-routing iifname != { ${wan_dev} } counter accept"
		printf "%s\n" "add rule inet banIP pre-routing ct state invalid ${log_ct} counter name cnt_ctinvalid drop"
		if [ "${ban_icmplimit}" -gt "0" ]; then
			printf "%s\n" "add rule inet banIP pre-routing ip protocol icmp limit rate over ${ban_icmplimit}/second ${log_icmp} counter name cnt_icmpflood drop"
			printf "%s\n" "add rule inet banIP pre-routing ip6 nexthdr icmpv6 limit rate over ${ban_icmplimit}/second ${log_icmp} counter name cnt_icmpflood drop"
		fi
		[ "${ban_udplimit}" -gt "0" ] && printf "%s\n" "add rule inet banIP pre-routing meta l4proto udp ct state new limit rate over ${ban_udplimit}/second ${log_udp} counter name cnt_udpflood drop"
		[ "${ban_synlimit}" -gt "0" ] && printf "%s\n" "add rule inet banIP pre-routing tcp flags & (fin|syn|rst|ack) == syn limit rate over ${ban_synlimit}/second ${log_syn} counter name cnt_synflood drop"
		printf "%s\n" "add rule inet banIP pre-routing tcp flags & (fin|syn) == (fin|syn) ${log_tcp} counter name cnt_tcpinvalid drop"
		printf "%s\n" "add rule inet banIP pre-routing tcp flags & (syn|rst) == (syn|rst) ${log_tcp} counter name cnt_tcpinvalid drop"
		printf "%s\n" "add rule inet banIP pre-routing tcp flags & (fin|syn|rst|psh|ack|urg) < (fin) ${log_tcp} counter name cnt_tcpinvalid drop"
		printf "%s\n" "add rule inet banIP pre-routing tcp flags & (fin|syn|rst|psh|ack|urg) == (fin|psh|urg) ${log_tcp} counter name cnt_tcpinvalid drop"

		# default wan-input rules
		#
		printf "%s\n" "add rule inet banIP wan-input iifname != { ${wan_dev} } counter accept"
		printf "%s\n" "add rule inet banIP wan-input ct state established,related counter accept"
		printf "%s\n" "add rule inet banIP wan-input meta nfproto ipv4 udp sport 67-68 udp dport 67-68 counter accept"
		printf "%s\n" "add rule inet banIP wan-input meta nfproto ipv6 udp sport 547 udp dport 546 counter accept"
		printf "%s\n" "add rule inet banIP wan-input meta nfproto ipv6 icmpv6 type { nd-neighbor-advert, nd-neighbor-solicit, nd-router-advert} ip6 hoplimit 1 counter accept"
		printf "%s\n" "add rule inet banIP wan-input meta nfproto ipv6 icmpv6 type { nd-neighbor-advert, nd-neighbor-solicit, nd-router-advert} ip6 hoplimit 255 counter accept"
		[ -n "${allow_dport}" ] && printf "%s\n" "add rule inet banIP wan-input ${allow_dport} counter accept"
		printf "%s\n" "add rule inet banIP wan-input meta mark set 1"
		printf "%s\n" "add rule inet banIP wan-input counter jump _inbound"

		# default wan-forward rules
		#
		printf "%s\n" "add rule inet banIP wan-forward iifname != { ${wan_dev} } counter accept"
		printf "%s\n" "add rule inet banIP wan-forward ct state established,related counter accept"
		[ -n "${allow_dport}" ] && printf "%s\n" "add rule inet banIP wan-forward ${allow_dport} counter accept"
		printf "%s\n" "add rule inet banIP wan-forward meta mark set 2"
		printf "%s\n" "add rule inet banIP wan-forward counter jump _inbound"

		# default lan-forward rules
		#
		printf "%s\n" "add rule inet banIP lan-forward oifname != { ${wan_dev} } counter accept"
		printf "%s\n" "add rule inet banIP lan-forward ct state established,related counter accept"
		[ -n "${vlan_allow}" ] && printf "%s\n" "add rule inet banIP lan-forward iifname { ${vlan_allow} } counter accept"
		[ -n "${vlan_block}" ] && printf "%s\n" "add rule inet banIP lan-forward iifname { ${vlan_block} } counter goto _reject"
		printf "%s\n" "add rule inet banIP lan-forward counter jump _outbound"
	} >"${file}"

	# load initial banIP table/rules to nftset
	#
	f_nftload "${file}" "can't initialize banIP nftables namespace"
	feed_rc="${?}"
	[ "${feed_rc}" = "0" ] && f_log "info" "initialize banIP nftables namespace"

	f_log "debug" "f_nftinit   ::: wan_dev: ${wan_dev}, vlan_allow: ${vlan_allow:-"-"}, vlan_block: ${vlan_block:-"-"}, allowed_dports: ${allow_dport:-"-"}, priority: ${ban_nftpriority}, policy: ${ban_nftpolicy}, icmp_limit: ${ban_icmplimit}, syn_limit: ${ban_synlimit}, udp_limit: ${ban_udplimit}, loglevel: ${ban_nftloglevel}, rc: ${feed_rc:-"-"}"
	: >"${file}"
	return "${feed_rc}"
}

# handle downloads
#
f_down() {
	local log_inbound log_outbound start_ts end_ts tmp_raw tmp_load tmp_file split_file table_json handle rc etag_rc element_count flag
	local expr cnt_set cnt_dl restore_rc feed_direction feed_policy feed_rc feed_comp feed_complete feed_target feed_dport chain
	local tmp_proto tmp_port asn country feed="${1}" proto="${2}" feed_url="${3}" feed_rule="${4}" feed_chain="${5}" feed_flag="${6}"

	start_ts="$(date +%s)"
	feed="${feed}.v${proto}"
	tmp_load="${ban_tmpfile}.${feed}.load"
	tmp_raw="${ban_tmpfile}.${feed}.raw"
	tmp_split="${ban_tmpfile}.${feed}.split"
	tmp_file="${ban_tmpfile}.${feed}.file"
	tmp_flush="${ban_tmpfile}.${feed}.flush"
	tmp_nft="${ban_tmpfile}.${feed}.nft"
	tmp_allow="${ban_tmpfile}.${feed%.*}"

	# set log target
	#
	[ "${ban_loginbound}" = "1" ] && log_inbound="log level ${ban_nftloglevel} prefix \"banIP/inbound/${ban_blockpolicy}/${feed}: \""
	[ "${ban_logoutbound}" = "1" ] && log_outbound="log level ${ban_nftloglevel} prefix \"banIP/outbound/reject/${feed}: \""

	# set feed target
	#
	if [ "${ban_blockpolicy}" = "reject" ]; then
		feed_target="goto _reject"
	else
		feed_target="drop"
	fi

	# set element counter flag
	#
	if [ "${ban_nftcount}" = "1" ]; then
		element_count="counter"
	fi

	# set feed complete flag
	#
	if printf "%s" "${ban_feedcomplete}" | "${ban_grepcmd}" -q "${feed%%.*}"; then
		feed_complete="true"
	fi

	# set feed direction
	#
	if printf "%s" "${ban_feedin}" | "${ban_grepcmd}" -q "${feed%%.*}"; then
		feed_policy="in"
		feed_direction="inbound"
	elif printf "%s" "${ban_feedout}" | "${ban_grepcmd}" -q "${feed%%.*}"; then
		feed_policy="out"
		feed_direction="outbound"
	elif printf "%s" "${ban_feedinout}" | "${ban_grepcmd}" -q "${feed%%.*}"; then
		feed_policy="inout"
		feed_direction="inbound outbound"
	else
		feed_policy="${feed_chain}"
		case "${feed_chain}" in
			"in")
				feed_direction="inbound"
				;;
			"out")
				feed_direction="outbound"
				;;
			"inout")
				feed_direction="inbound outbound"
				;;
			*)
				feed_direction="inbound"
				;;
		esac
	fi

	# prepare feed flags
	#
	for flag in ${feed_flag}; do
		case "${flag}" in
			"gz")
				feed_comp="${flag}"
				;;
			"tcp" | "udp")
				if [ -z "${tmp_proto}" ]; then
					tmp_proto="${flag}"
				elif ! printf "%s" "${tmp_proto}" | "${ban_grepcmd}" -qw "${flag}"; then
					tmp_proto="${tmp_proto}, ${flag}"
				fi
				;;
			"${flag//[![:digit:]-]/}")
				if [ -z "${tmp_port}" ]; then
					tmp_port="${flag}"
				elif ! printf "%s" "${tmp_port}" | "${ban_grepcmd}" -qw "${flag}"; then
					tmp_port="${tmp_port}, ${flag}"
				fi
				;;
		esac
	done

	if ! printf "%s" "${ban_feedreset}" | "${ban_grepcmd}" -q "${feed%%.*}"; then
		if [ -n "${tmp_proto}" ] && [ -n "${tmp_port}" ]; then
			feed_dport="meta l4proto { ${tmp_proto} } th dport { ${tmp_port} }"
		fi
	fi

	# chain/rule maintenance
	#
	if [ "${ban_action}" = "reload" ] && "${ban_nftcmd}" -t list set inet banIP "${feed}" >/dev/null 2>&1; then
		table_json="$("${ban_nftcmd}" -tja list table inet banIP 2>/dev/null)"
		{
			for chain in _inbound _outbound; do
				for expr in 0 1 2; do
					handle="$(printf "%s\n" "${table_json}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.chain=\"${chain}\"][@.expr[${expr}].match.right=\"@${feed}\"].handle")"
					[ -n "${handle}" ] && printf "%s\n" "delete rule inet banIP ${chain} handle ${handle}"
				done
			done
			printf "%s\n" "flush set inet banIP ${feed}"
			printf "%s\n\n" "delete set inet banIP ${feed}"
		} >"${tmp_flush}"
	fi

	# restore local backups
	#
	if [ "${feed%%.*}" != "blocklist" ]; then
		if [ -n "${ban_etagparm}" ] && [ "${ban_action}" = "reload" ] && [ "${feed_url}" != "local" ] && [ "${feed%%.*}" != "allowlist" ]; then
			etag_rc="0"
			case "${feed%%.*}" in
				"country")
					if [ "${ban_countrysplit}" = "0" ]; then
						for country in ${ban_country}; do
							f_etag "${feed}" "${feed_url}${country}-aggregated.zone" ".${country}"
							rc="${?}"
							etag_rc="$((etag_rc + rc))"
							[ "${rc}" = "4" ] && break
						done
					else
						country="${feed%.*}"
						country="${country#*.}"
						f_etag "${feed}" "${feed_url}${country}-aggregated.zone" ".${country}"
						etag_rc="${?}"
					fi
					;;
				"asn")
					if [ "${ban_asnsplit}" = "0" ]; then
						for asn in ${ban_asn}; do
							f_etag "${feed}" "${feed_url}AS${asn}" ".${asn}"
							rc="${?}"
							etag_rc="$((etag_rc + rc))"
							[ "${rc}" = "4" ] && break
						done
					else
						asn="${feed%.*}"
						asn="${asn#*.}"
						f_etag "${feed}" "${feed_url}AS${asn}" ".${asn}"
						etag_rc="${?}"
					fi
					;;
				*)
					f_etag "${feed}" "${feed_url}"
					etag_rc="${?}"
					;;
			esac
		fi
		if [ "${etag_rc}" = "0" ] || [ "${ban_action}" != "reload" ] || [ "${feed_url}" = "local" ]; then
			if [ "${feed%%.*}" = "allowlist" ] && [ ! -f "${tmp_allow}" ]; then
				f_restore "allowlist" "-" "${tmp_allow}" "${etag_rc}"
			else
				f_restore "${feed}" "${feed_url}" "${tmp_load}" "${etag_rc}"
			fi
			restore_rc="${?}"
			feed_rc="${restore_rc}"
		fi
	fi

	# prepare local/remote allowlist
	#
	if [ "${feed%%.*}" = "allowlist" ] && [ ! -f "${tmp_allow}" ]; then
		"${ban_catcmd}" "${ban_allowlist}" 2>/dev/null >"${tmp_allow}"
		feed_rc="${?}"
		for feed_url in ${ban_allowurl}; do
			if "${ban_fetchcmd}" ${ban_fetchparm} "${tmp_load}" "${feed_url}" >/dev/null 2>&1; then
				if [ -s "${tmp_load}" ]; then
					"${ban_catcmd}" "${tmp_load}" 2>/dev/null >>"${tmp_allow}"
					feed_rc="${?}"
				fi
			else
				f_log "info" "download for feed '${feed%%.*}' failed"
				feed_rc="4"
				break
			fi
		done

		if [ "${feed_rc}" = "0" ]; then
			f_backup "allowlist" "${tmp_allow}"
		elif [ -z "${restore_rc}" ] && [ "${feed_rc}" != "0" ]; then
			f_restore "allowlist" "-" "${tmp_allow}" "${feed_rc}"
		fi
		feed_rc="${?}"
	fi

	# handle local feeds
	#
	if [ "${feed%%.*}" = "allowlist" ]; then
		{
			printf "%s\n\n" "#!${ban_nftcmd} -f"
			[ -s "${tmp_flush}" ] && "${ban_catcmd}" "${tmp_flush}"
			case "${proto}" in
				"4MAC")
					"${ban_awkcmd}" '/^([0-9A-f]{2}:){5}[0-9A-f]{2}(\/([0-9]|[1-3][0-9]|4[0-8]))?([[:space:]]+([1-9][0-9]?[0-9]?\.){1}([0-9]{1,3}\.){2}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])(\/(1?[0-9]|2?[0-9]|3?[0-2]))?([[:space:]]+#.*$|[[:space:]]*$)|[[:space:]]+#.*$|$)/{if(!$2||$2~/#/)$2="0.0.0.0/0";if(!seen[$1]++)printf "%s . %s, ",tolower($1),$2}' "${tmp_allow}" >"${tmp_file}"
					printf "%s\n" "add set inet banIP ${feed} { type ether_addr . ipv4_addr; flags interval; auto-merge; policy ${ban_nftpolicy}; ${element_count}; $(f_getelements "${tmp_file}") }"
					[ -z "${feed_direction##*outbound*}" ] && printf "%s\n" "add rule inet banIP _outbound ether saddr . ip saddr @${feed} counter accept"
					;;
				"6MAC")
					"${ban_awkcmd}" '/^([0-9A-f]{2}:){5}[0-9A-f]{2}(\/([0-9]|[1-3][0-9]|4[0-8]))?([[:space:]]+([0-9A-f]{0,4}:){1,7}[0-9A-f]{0,4}:?(\/(1?[0-2][0-8]|[0-9][0-9]))?([[:space:]]+#.*$|[[:space:]]*$)|[[:space:]]+#.*$|$)/{if(!$2||$2~/#/)$2="::/0";if(!seen[$1]++)printf "%s . %s, ",tolower($1),$2}' "${tmp_allow}" >"${tmp_file}"
					printf "%s\n" "add set inet banIP ${feed} { type ether_addr . ipv6_addr; flags interval; auto-merge; policy ${ban_nftpolicy}; ${element_count}; $(f_getelements "${tmp_file}") }"
					[ -z "${feed_direction##*outbound*}" ] && printf "%s\n" "add rule inet banIP _outbound ether saddr . ip6 saddr @${feed} counter accept"
					;;
				"4")
					"${ban_awkcmd}" '/^127\./{next}/^(([1-9][0-9]?[0-9]?\.){1}([0-9]{1,3}\.){2}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])(\/(1?[0-9]|2?[0-9]|3?[0-2]))?)([[:space:]].*|$)/{printf "%s, ",$1}' "${tmp_allow}" >"${tmp_file}"
					printf "%s\n" "add set inet banIP ${feed} { type ipv4_addr; flags interval; auto-merge; policy ${ban_nftpolicy}; ${element_count}; $(f_getelements "${tmp_file}") }"
					if [ -z "${feed_direction##*inbound*}" ]; then
						if [ "${ban_allowlistonly}" = "1" ]; then
							printf "%s\n" "add rule inet banIP _inbound ip saddr != @${feed} ${log_inbound} counter ${feed_target}"
						else
							printf "%s\n" "add rule inet banIP _inbound ip saddr @${feed} counter accept"
						fi
					fi
					if [ -z "${feed_direction##*outbound*}" ]; then
						if [ "${ban_allowlistonly}" = "1" ]; then
							printf "%s\n" "add rule inet banIP _outbound ip daddr != @${feed} ${log_outbound} counter goto _reject"
						else
							printf "%s\n" "add rule inet banIP _outbound ip daddr @${feed} counter accept"
						fi
					fi
					;;
				"6")
					"${ban_awkcmd}" '!/^([0-9A-f]{2}:){5}[0-9A-f]{2}.*/{printf "%s\n",$1}' "${tmp_allow}" |
						"${ban_awkcmd}" '/^(([0-9A-f]{0,4}:){1,7}[0-9A-f]{0,4}:?(\/(1?[0-2][0-8]|[0-9][0-9]))?)([[:space:]].*|$)/{printf "%s, ",tolower($1)}' >"${tmp_file}"
					printf "%s\n" "add set inet banIP ${feed} { type ipv6_addr; flags interval; auto-merge; policy ${ban_nftpolicy}; ${element_count}; $(f_getelements "${tmp_file}") }"
					if [ -z "${feed_direction##*inbound*}" ]; then
						if [ "${ban_allowlistonly}" = "1" ]; then
							printf "%s\n" "add rule inet banIP _inbound ip6 saddr != @${feed} ${log_inbound} counter ${feed_target}"
						else
							printf "%s\n" "add rule inet banIP _inbound ip6 saddr @${feed} counter accept"
						fi
					fi
					if [ -z "${feed_direction##*outbound*}" ]; then
						if [ "${ban_allowlistonly}" = "1" ]; then
							printf "%s\n" "add rule inet banIP _outbound ip6 daddr != @${feed} ${log_outbound} counter ${feed_target}"
						else
							printf "%s\n" "add rule inet banIP _outbound ip6 daddr @${feed} counter accept"
						fi
					fi
					;;
			esac
		} >"${tmp_nft}"
		: >"${tmp_flush}" >"${tmp_raw}" >"${tmp_file}"
		feed_rc="0"
	elif [ "${feed%%.*}" = "blocklist" ]; then
		{
			printf "%s\n\n" "#!${ban_nftcmd} -f"
			[ -s "${tmp_flush}" ] && "${ban_catcmd}" "${tmp_flush}"
			case "${proto}" in
				"4MAC")
					"${ban_awkcmd}" '/^([0-9A-f]{2}:){5}[0-9A-f]{2}(\/([0-9]|[1-3][0-9]|4[0-8]))?([[:space:]]+([1-9][0-9]?[0-9]?\.){1}([0-9]{1,3}\.){2}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])(\/(1?[0-9]|2?[0-9]|3?[0-2]))?([[:space:]]+#.*$|[[:space:]]*$)|[[:space:]]+#.*$|$)/{if(!$2||$2~/#/)$2="0.0.0.0/0";if(!seen[$1]++)printf "%s . %s, ",tolower($1),$2}' "${ban_blocklist}" >"${tmp_file}"
					printf "%s\n" "add set inet banIP ${feed} { type ether_addr . ipv4_addr; flags interval; auto-merge; policy ${ban_nftpolicy}; ${element_count}; $(f_getelements "${tmp_file}") }"
					[ -z "${feed_direction##*outbound*}" ] && printf "%s\n" "add rule inet banIP _outbound ether saddr . ip saddr @${feed} counter goto _reject"
					;;
				"6MAC")
					"${ban_awkcmd}" '/^([0-9A-f]{2}:){5}[0-9A-f]{2}(\/([0-9]|[1-3][0-9]|4[0-8]))?([[:space:]]+([0-9A-f]{0,4}:){1,7}[0-9A-f]{0,4}:?(\/(1?[0-2][0-8]|[0-9][0-9]))?([[:space:]]+#.*$|[[:space:]]*$)|[[:space:]]+#.*$|$)/{if(!$2||$2~/#/)$2="::/0";if(!seen[$1]++)printf "%s . %s, ",tolower($1),$2}' "${ban_blocklist}" >"${tmp_file}"
					printf "%s\n" "add set inet banIP ${feed} { type ether_addr . ipv6_addr; flags interval; auto-merge; policy ${ban_nftpolicy}; ${element_count}; $(f_getelements "${tmp_file}") }"
					[ -z "${feed_direction##*outbound*}" ] && printf "%s\n" "add rule inet banIP _outbound ether saddr . ip6 saddr @${feed} counter goto _reject"
					;;
				"4")
					"${ban_awkcmd}" '/^127\./{next}/^(([1-9][0-9]?[0-9]?\.){1}([0-9]{1,3}\.){2}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])(\/(1?[0-9]|2?[0-9]|3?[0-2]))?)([[:space:]].*|$)/{printf "%s,\n",$1}' "${ban_blocklist}" |
						"${ban_awkcmd}" '{ORS=" ";print}' >"${tmp_file}"
					printf "%s\n" "add set inet banIP ${feed} { type ipv4_addr; flags interval, timeout; auto-merge; policy ${ban_nftpolicy}; ${element_count}; $(f_getelements "${tmp_file}") }"
					[ -z "${feed_direction##*inbound*}" ] && printf "%s\n" "add rule inet banIP _inbound ip saddr @${feed} ${log_inbound} counter ${feed_target}"
					[ -z "${feed_direction##*outbound*}" ] && printf "%s\n" "add rule inet banIP _outbound ip daddr @${feed} ${log_outbound} counter goto _reject"
					;;
				"6")
					"${ban_awkcmd}" '!/^([0-9A-f]{2}:){5}[0-9A-f]{2}.*/{printf "%s\n",$1}' "${ban_blocklist}" |
						"${ban_awkcmd}" '/^(([0-9A-f]{0,4}:){1,7}[0-9A-f]{0,4}:?(\/(1?[0-2][0-8]|[0-9][0-9]))?)([[:space:]].*|$)/{printf "%s,\n",tolower($1)}' |
						"${ban_awkcmd}" '{ORS=" ";print}' >"${tmp_file}"
					printf "%s\n" "add set inet banIP ${feed} { type ipv6_addr; flags interval, timeout; auto-merge; policy ${ban_nftpolicy}; ${element_count}; $(f_getelements "${tmp_file}") }"
					[ -z "${feed_direction##*inbound*}" ] && printf "%s\n" "add rule inet banIP _inbound ip6 saddr @${feed} ${log_inbound} counter ${feed_target}"
					[ -z "${feed_direction##*outbound*}" ] && printf "%s\n" "add rule inet banIP _outbound ip6 daddr @${feed} ${log_outbound} counter goto _reject"
					;;
			esac
		} >"${tmp_nft}"
		: >"${tmp_flush}" >"${tmp_raw}" >"${tmp_file}"
		feed_rc="0"

	# handle external feeds
	#
	elif [ "${restore_rc}" != "0" ] && [ "${feed_url}" != "local" ]; then
		# handle country downloads
		#
		if [ "${feed%%.*}" = "country" ]; then
			if [ "${ban_countrysplit}" = "0" ]; then
				for country in ${ban_country}; do
					if "${ban_fetchcmd}" ${ban_fetchparm} "${tmp_raw}" "${feed_url}${country}-aggregated.zone" >/dev/null 2>&1; then
						if [ -s "${tmp_raw}" ]; then
							"${ban_catcmd}" "${tmp_raw}" 2>/dev/null >>"${tmp_load}"
							feed_rc="${?}"
						fi
					else
						f_log "info" "download for feed '${feed%%.*}/${country}' failed"
					fi
				done
				: >"${tmp_raw}"
			else
				country="${feed%.*}"
				country="${country#*.}"
				if "${ban_fetchcmd}" ${ban_fetchparm} "${tmp_load}" "${feed_url}${country}-aggregated.zone" >/dev/null 2>&1; then
					feed_rc="${?}"
				else
					feed_rc="4"
				fi
			fi
		# handle asn downloads
		#
		elif [ "${feed%%.*}" = "asn" ]; then
			if [ "${ban_asnsplit}" = "0" ]; then
				for asn in ${ban_asn}; do
					if "${ban_fetchcmd}" ${ban_fetchparm} "${tmp_raw}" "${feed_url}AS${asn}" >/dev/null 2>&1; then
						if [ -s "${tmp_raw}" ]; then
							"${ban_catcmd}" "${tmp_raw}" 2>/dev/null >>"${tmp_load}"
							feed_rc="${?}"
						fi
					else
						f_log "info" "download for feed '${feed%%.*}/${asn}' failed"
					fi
				done
				: >"${tmp_raw}"
			else
				asn="${feed%.*}"
				asn="${asn#*.}"
				if "${ban_fetchcmd}" ${ban_fetchparm} "${tmp_load}" "${feed_url}AS${asn}" >/dev/null 2>&1; then
					feed_rc="${?}"
				else
					feed_rc="4"
				fi
			fi
		# handle compressed downloads
		#
		elif [ "${feed_comp}" = "gz" ]; then
			if "${ban_fetchcmd}" ${ban_fetchparm} "${tmp_raw}" "${feed_url}" >/dev/null 2>&1; then
				if [ -s "${tmp_raw}" ]; then
					"${ban_zcatcmd}" "${tmp_raw}" 2>/dev/null >"${tmp_load}"
					feed_rc="${?}"
				fi
			else
				feed_rc="4"
			fi
			: >"${tmp_raw}"

		# handle normal downloads
		#
		else
			if "${ban_fetchcmd}" ${ban_fetchparm} "${tmp_load}" "${feed_url}" >/dev/null 2>&1; then
				feed_rc="${?}"
			else
				feed_rc="4"
			fi
		fi
	fi
	[ "${feed_rc}" != "0" ] && f_log "info" "download for feed '${feed}' failed, rc: ${feed_rc:-"-"}"

	# backup/restore
	#
	if [ "${restore_rc}" != "0" ] && [ "${feed_rc}" = "0" ] && [ "${feed_url}" != "local" ] && [ ! -s "${tmp_nft}" ]; then
		f_backup "${feed}" "${tmp_load}"
		feed_rc="${?}"
	elif [ -z "${restore_rc}" ] && [ "${feed_rc}" != "0" ] && [ "${feed_url}" != "local" ] && [ ! -s "${tmp_nft}" ]; then
		f_restore "${feed}" "${feed_url}" "${tmp_load}" "${feed_rc}"
		feed_rc="${?}"
	fi

	# final file & Set preparation for regular downloads
	#
	if [ "${feed_rc}" = "0" ] && [ ! -s "${tmp_nft}" ]; then
		# deduplicate Sets
		#
		if [ "${ban_deduplicate}" = "1" ] && [ "${feed_url}" != "local" ] && [ -z "${feed_complete}" ]; then
			"${ban_awkcmd}" '{sub("\r$", "");print}' "${tmp_load}" 2>/dev/null | "${ban_awkcmd}" "${feed_rule}" 2>/dev/null >"${tmp_raw}"
			"${ban_awkcmd}" 'NR==FNR{member[$0];next}!($0 in member)' "${ban_tmpfile}.deduplicate" "${tmp_raw}" 2>/dev/null | tee -a "${ban_tmpfile}.deduplicate" >"${tmp_split}"
			feed_rc="${?}"
		else
			"${ban_awkcmd}" '{sub("\r$", "");print}' "${tmp_load}" 2>/dev/null | "${ban_awkcmd}" "${feed_rule}" 2>/dev/null >"${tmp_split}"
			feed_rc="${?}"
		fi
		: >"${tmp_raw}" >"${tmp_load}"
		# split Sets
		#
		if [ "${feed_rc}" = "0" ]; then
			if [ -n "${ban_splitsize//[![:digit:]]/}" ] && [ "${ban_splitsize//[![:digit:]]/}" -ge "512" ]; then
				if ! "${ban_awkcmd}" "NR%${ban_splitsize//[![:digit:]]/}==1{file=\"${tmp_file}.\"++i;}{ORS=\" \";print > file}" "${tmp_split}" 2>/dev/null; then
					feed_rc="${?}"
					rm -f "${tmp_file}".*
					f_log "info" "can't split nfset '${feed}' to size '${ban_splitsize//[![:digit:]]/}'"
				fi
			else
				"${ban_awkcmd}" '{ORS=" ";print}' "${tmp_split}" 2>/dev/null >"${tmp_file}.1"
				feed_rc="${?}"
			fi
		fi
		# build nft file
		#
		if [ "${feed_rc}" = "0" ] && [ -s "${tmp_file}.1" ]; then
			if [ "${proto}" = "4" ]; then
				{
					# nft header (IPv4 Set) incl. inbound and outbound rules
					#
					printf "%s\n\n" "#!${ban_nftcmd} -f"
					[ -s "${tmp_flush}" ] && "${ban_catcmd}" "${tmp_flush}"
					printf "%s\n" "add set inet banIP ${feed} { type ipv4_addr; flags interval; auto-merge; policy ${ban_nftpolicy}; ${element_count}; $(f_getelements "${tmp_file}.1") }"
					[ -z "${feed_direction##*inbound*}" ] && printf "%s\n" "add rule inet banIP _inbound ${feed_dport} ip saddr @${feed} ${log_inbound} counter ${feed_target}"
					[ -z "${feed_direction##*outbound*}" ] && printf "%s\n" "add rule inet banIP _outbound ${feed_dport} ip daddr @${feed} ${log_outbound} counter goto _reject"
				} >"${tmp_nft}"
			elif [ "${proto}" = "6" ]; then
				{
					# nft header (IPv6 Set) incl. inbound and outbound rules
					#
					printf "%s\n\n" "#!${ban_nftcmd} -f"
					[ -s "${tmp_flush}" ] && "${ban_catcmd}" "${tmp_flush}"
					printf "%s\n" "add set inet banIP ${feed} { type ipv6_addr; flags interval; auto-merge; policy ${ban_nftpolicy}; ${element_count}; $(f_getelements "${tmp_file}.1") }"
					[ -z "${feed_direction##*inbound*}" ] && printf "%s\n" "add rule inet banIP _inbound ${feed_dport} ip6 saddr @${feed} ${log_inbound} counter ${feed_target}"
					[ -z "${feed_direction##*outbound*}" ] && printf "%s\n" "add rule inet banIP _outbound ${feed_dport} ip6 daddr @${feed} ${log_outbound} counter goto _reject"
				} >"${tmp_nft}"
			fi
		fi
		: >"${tmp_flush}" >"${tmp_file}.1"
	fi
	# load generated nft file in banIP table
	#
	if [ "${feed_rc}" = "0" ]; then
		if [ "${feed%%.*}" = "allowlist" ]; then
			cnt_dl="$("${ban_awkcmd}" 'END{printf "%d",NR}' "${tmp_allow}" 2>/dev/null)"
		elif [ "${feed%%.*}" = "blocklist" ]; then
			cnt_dl="$("${ban_awkcmd}" 'END{printf "%d",NR}' "${ban_blocklist}" 2>/dev/null)"
		else
			cnt_dl="$("${ban_awkcmd}" 'END{printf "%d",NR}' "${tmp_split}" 2>/dev/null)"
			: >"${tmp_split}"
		fi
		if [ "${cnt_dl:-"0"}" -gt "0" ] || [ "${feed%%.*}" = "allowlist" ] || [ "${feed%%.*}" = "blocklist" ]; then
			# load initial file to nftset
			#
			f_nftload "${tmp_nft}" "can't load initial file to nfset '${feed}'"
			feed_rc="${?}"
			# load additional split files
			#
			if [ "${feed_rc}" = "0" ]; then
				for split_file in "${tmp_file}".*; do
					if [ -s "${split_file}" ]; then
						"${ban_sedcmd}" -i "1 i #!${ban_nftcmd} -f\nadd element inet banIP "${feed}" { " "${split_file}"
						printf "%s\n" "}" >>"${split_file}"
						# load split file to nftset
						#
						f_nftload "${split_file}" "can't load split file '${split_file##*.}' to nfset '${feed}'"
						feed_rc="${?}"
						: >"${split_file}"
					fi
				done
				cnt_set="$("${ban_nftcmd}" -j list set inet banIP "${feed}" 2>/dev/null | "${ban_jsoncmd}" -qe '@.nftables[*].set.elem[*]' | "${ban_wccmd}" -l 2>/dev/null)"
			fi
		else
			f_log "info" "skip empty feed '${feed}'"
		fi
	fi
	: >"${tmp_nft}"
	end_ts="$(date +%s)"

	f_log "debug" "f_down      ::: feed: ${feed}, policy: ${feed_policy}, complete: ${feed_complete:-"-"}, cnt_dl: ${cnt_dl:-"-"}, cnt_set: ${cnt_set:-"-"}, split_size: ${ban_splitsize:-"-"}, time: $((end_ts - start_ts)), rc: ${feed_rc:-"-"}"
}

# backup feeds
#
f_backup() {
	local backup_rc="4" feed="${1}" feed_file="${2}"

	if [ -s "${feed_file}" ]; then
		"${ban_gzipcmd}" -cf "${feed_file}" >"${ban_backupdir}/banIP.${feed}.gz"
		backup_rc="${?}"
	fi

	f_log "debug" "f_backup    ::: feed: ${feed}, file: banIP.${feed}.gz, rc: ${backup_rc}"
	return "${backup_rc}"
}

# restore feeds
#
f_restore() {
	local tmp_feed restore_rc="4" feed="${1}" feed_url="${2}" feed_file="${3}" in_rc="${4}"

	[ "${feed_url}" = "local" ] && tmp_feed="${feed%.*}.v4" || tmp_feed="${feed}"
	if [ -s "${ban_backupdir}/banIP.${tmp_feed}.gz" ]; then
		"${ban_zcatcmd}" "${ban_backupdir}/banIP.${tmp_feed}.gz" 2>/dev/null >"${feed_file}"
		restore_rc="${?}"
	fi

	f_log "debug" "f_restore   ::: feed: ${feed}, file: banIP.${tmp_feed}.gz, in_rc: ${in_rc:-"-"}, rc: ${restore_rc}"
	return "${restore_rc}"
}

# remove staled Sets
#
f_rmset() {
	local feedlist tmp_del table_json feed country asn table_sets handle expr del_set feed_rc

	f_getfeed
	json_get_keys feedlist
	tmp_del="${ban_tmpfile}.final.delete"
	table_json="$("${ban_nftcmd}" -tj list table inet banIP 2>/dev/null)"
	table_sets="$(printf "%s\n" "${table_json}" | "${ban_jsoncmd}" -qe '@.nftables[@.set.family="inet"].set.name')"
	{
		printf "%s\n\n" "#!${ban_nftcmd} -f"
		for feed in ${table_sets}; do
			if ! printf "%s" "allowlist blocklist ${ban_feed}" | "${ban_grepcmd}" -q "${feed%.*}" ||
				! printf "%s" "allowlist blocklist ${feedlist}" | "${ban_grepcmd}" -q "${feed%.*}" ||
				{ [ "${feed%.*}" = "country" ] && [ "${ban_countrysplit}" = "1" ]; } ||
				{ [ "${feed%.*}" = "asn" ] && [ "${ban_asnsplit}" = "1" ]; }; then
				case "${feed%%.*}" in
					"country")
						country="${feed%.*}"
						country="${country#*.}"
						if [ "${ban_countrysplit}" = "1" ] && printf "%s" "${ban_country}" | "${ban_grepcmd}" -q "${country}"; then
							continue
						fi
						;;
					asn)
						asn="${feed%.*}"
						asn="${asn#*.}"
						if [ "${ban_asnsplit}" = "1" ] && printf "%s" "${ban_asn}" | "${ban_grepcmd}" -q "${asn}"; then
							continue
						fi
						;;
				esac
				[ -z "${del_set}" ] && del_set="${feed}" || del_set="${del_set}, ${feed}"
				rm -f "${ban_backupdir}/banIP.${feed}.gz"
				for chain in _inbound _outbound; do
					for expr in 0 1 2; do
						handle="$(printf "%s\n" "${table_json}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.chain=\"${chain}\"][@.expr[${expr}].match.right=\"@${feed}\"].handle")"
						[ -n "${handle}" ] && printf "%s\n" "delete rule inet banIP ${chain} handle ${handle}"
					done
				done
				printf "%s\n" "flush set inet banIP ${feed}"
				printf "%s\n\n" "delete set inet banIP ${feed}"
			fi
		done
	} >"${tmp_del}"

	if [ -n "${del_set}" ]; then
		if "${ban_nftcmd}" -f "${tmp_del}" >/dev/null 2>&1; then
			feed_rc="${?}"
		else
			feed_rc="4"
		fi
	fi
	: >"${tmp_del}"

	f_log "debug" "f_rmset     ::: nfset: ${del_set:-"-"}, rc: ${feed_rc:-"-"}"
}

# generate status information
#
f_genstatus() {
	local mem_free mem_max nft_ver object end_time duration table_sets cnt_elements="0" custom_feed="0" split="0" status="${1}"

	mem_free="$("${ban_awkcmd}" '/^MemAvailable/{printf "%s",int($2/1024)}' "/proc/meminfo" 2>/dev/null)"
	mem_max="$("${ban_awkcmd}" '/^VmHWM/{printf "%s",int($2)}' /proc/${$}/status 2>/dev/null)"
	nft_ver="$(printf "%s" "${ban_packages}" | "${ban_jsoncmd}" -ql1 -e '@.packages["nftables-json"]')"

	[ -z "${ban_dev}" ] && f_conf
	if [ "${status}" = "active" ]; then
		if [ -n "${ban_starttime}" ] && [ "${ban_action}" != "boot" ]; then
			end_time="$(date "+%s")"
			duration="$(((end_time - ban_starttime) / 60))m $(((end_time - ban_starttime) % 60))s"
		fi
		table_sets="$("${ban_nftcmd}" -tj list table inet banIP 2>/dev/null | "${ban_jsoncmd}" -qe '@.nftables[@.set.family="inet"].set.name')"
		for object in ${table_sets}; do
			cnt_elements="$((cnt_elements + $("${ban_nftcmd}" -j list set inet banIP "${object}" 2>/dev/null | "${ban_jsoncmd}" -qe '@.nftables[*].set.elem[*]' | "${ban_wccmd}" -l 2>/dev/null)))"
		done
		runtime="mode: ${ban_action:-"-"}, period: ${duration:-"-"}, memory: ${mem_free} MB available, ${mem_max} KB max. used, cores: ${ban_cores}, log: ${ban_logreadcmd##*/}, fetch: ${ban_fetchcmd##*/}"
	fi
	[ -s "${ban_customfeedfile}" ] && custom_feed="1"
	[ "${ban_splitsize:-"0"}" -gt "0" ] && split="1"

	: >"${ban_rtfile}"
	json_init
	json_load_file "${ban_rtfile}" >/dev/null 2>&1
	json_add_string "status" "${status}"
	json_add_string "version" "${ban_ver}"
	json_add_string "element_count" "${cnt_elements}"
	json_add_array "active_feeds"
	for object in ${table_sets:-"-"}; do
		json_add_string "${object}" "${object}"
	done
	json_close_array
	json_add_array "wan_devices"
	for object in ${ban_dev:-"-"}; do
		json_add_string "${object}" "${object}"
	done
	json_close_array
	json_add_array "wan_interfaces"
	for object in ${ban_ifv4:-"-"} ${ban_ifv6:-"-"}; do
		json_add_string "${object}" "${object}"
	done
	json_close_array
	json_add_array "vlan_allow"
	for object in ${ban_vlanallow:-"-"}; do
		json_add_string "${object}" "${object}"
	done
	json_close_array
	json_add_array "vlan_block"
	for object in ${ban_vlanblock:-"-"}; do
		json_add_string "${object}" "${object}"
	done
	json_close_array
	json_add_array "active_uplink"
	for object in ${ban_uplink:-"-"}; do
		json_add_string "${object}" "${object}"
	done
	json_close_array
	json_add_string "nft_info" "ver: ${nft_ver:-"-"}, priority: ${ban_nftpriority}, policy: ${ban_nftpolicy}, loglevel: ${ban_nftloglevel}, expiry: ${ban_nftexpiry:-"-"}, limit (icmp/syn/udp): ${ban_icmplimit}/${ban_synlimit}/${ban_udplimit}"
	json_add_string "run_info" "base: ${ban_basedir}, backup: ${ban_backupdir}, report: ${ban_reportdir}, error: ${ban_errordir}"
	json_add_string "run_flags" "auto: $(f_char ${ban_autodetect}), proto (4/6): $(f_char ${ban_protov4})/$(f_char ${ban_protov6}), log (pre/in/out): $(f_char ${ban_logprerouting})/$(f_char ${ban_loginbound})/$(f_char ${ban_logoutbound}), count: $(f_char ${ban_nftcount}), dedup: $(f_char ${ban_deduplicate}), split: $(f_char ${split}), custom feed: $(f_char ${custom_feed}), allowed only: $(f_char ${ban_allowlistonly})"
	json_add_string "last_run" "${runtime:-"-"}"
	json_add_string "system_info" "$(date "+%Y-%m-%d %H:%M:%S"), ${ban_sysver}"
	json_dump >"${ban_rtfile}"
}

# get status information
#
f_getstatus() {
	local key keylist value values

	[ -z "${ban_dev}" ] && f_conf
	json_load_file "${ban_rtfile}" >/dev/null 2>&1
	if json_get_keys keylist; then
		printf "%s\n" "::: banIP runtime information"
		for key in ${keylist}; do
			if [ "${key}" = "active_feeds" ] || [ "${key}" = "active_uplink" ]; then
				json_get_values values "${key}" >/dev/null 2>&1
				value="${values// /, }"
			elif [ "${key}" = "wan_devices" ]; then
				json_get_values values "${key}" >/dev/null 2>&1
				value="wan: ${values// /, } / "
				json_get_values values "wan_interfaces" >/dev/null 2>&1
				value="${value}wan-if: ${values// /, } / "
				json_get_values values "vlan_allow" >/dev/null 2>&1
				value="${value}vlan-allow: ${values// /, } / "
				json_get_values values "vlan_block" >/dev/null 2>&1
				value="${value}vlan-block: ${values// /, }"
				key="active_devices"
			else
				json_get_var value "${key}" >/dev/null 2>&1
				if [ "${key}" = "status" ]; then
					[ "${value}" = "active" ] && value="${value} ($(f_actual))" || value="${value}"
				fi
			fi
			if [ "${key}" != "wan_interfaces" ] && [ "${key}" != "vlan_allow" ] && [ "${key}" != "vlan_block" ]; then
				printf "  + %-17s : %s\n" "${key}" "${value:-"-"}"
			fi
		done
	else
		printf "%s\n" "::: no banIP runtime information available"
	fi
}

# domain lookup
#
f_lookup() {
	local cnt list domain lookup ip elementsv4 elementsv6 start_time end_time duration cnt_domain="0" cnt_ip="0" feed="${1}"

	[ -z "${ban_dev}" ] && f_conf
	start_time="$(date "+%s")"
	if [ "${feed}" = "allowlist" ]; then
		list="$("${ban_awkcmd}" '/^([[:alnum:]_-]{1,63}\.)+[[:alpha:]]+([[:space:]]|$)/{printf "%s ",tolower($1)}' "${ban_allowlist}" 2>/dev/null)"
	elif [ "${feed}" = "blocklist" ]; then
		list="$("${ban_awkcmd}" '/^([[:alnum:]_-]{1,63}\.)+[[:alpha:]]+([[:space:]]|$)/{printf "%s ",tolower($1)}' "${ban_blocklist}" 2>/dev/null)"
	fi

	for domain in ${list}; do
		lookup="$("${ban_lookupcmd}" "${domain}" ${ban_resolver} 2>/dev/null | "${ban_awkcmd}" '/^Address[ 0-9]*: /{if(!seen[$NF]++)printf "%s ",$NF}' 2>/dev/null)"
		for ip in ${lookup}; do
			if [ "${ip%%.*}" = "127" ] || [ "${ip%%.*}" = "0" ] || [ -z "${ip%%::*}" ]; then
				continue
			else
				[ "${ip##*:}" = "${ip}" ] && elementsv4="${elementsv4} ${ip}," || elementsv6="${elementsv6} ${ip},"
				if [ "${feed}" = "allowlist" ] && [ "${ban_autoallowlist}" = "1" ] && ! "${ban_grepcmd}" -q "^${ip}[[:space:]]*#" "${ban_allowlist}"; then
					printf "%-45s%s\n" "${ip}" "# '${domain}' added on $(date "+%Y-%m-%d %H:%M:%S")" >>"${ban_allowlist}"
				elif [ "${feed}" = "blocklist" ] && [ "${ban_autoblocklist}" = "1" ] && ! "${ban_grepcmd}" -q "^${ip}[[:space:]]*#" "${ban_blocklist}"; then
					printf "%-45s%s\n" "${ip}" "# '${domain}' added on $(date "+%Y-%m-%d %H:%M:%S")" >>"${ban_blocklist}"
				fi
				cnt_ip="$((cnt_ip + 1))"
			fi
		done
		cnt_domain="$((cnt_domain + 1))"
	done
	if [ -n "${elementsv4}" ]; then
		if ! "${ban_nftcmd}" add element inet banIP "${feed}.v4" { ${elementsv4} } >/dev/null 2>&1; then
			f_log "info" "can't add lookup file to nfset '${feed}.v4'"
		fi
	fi
	if [ -n "${elementsv6}" ]; then
		if ! "${ban_nftcmd}" add element inet banIP "${feed}.v6" { ${elementsv6} } >/dev/null 2>&1; then
			f_log "info" "can't add lookup file to nfset '${feed}.v6'"
		fi
	fi
	end_time="$(date "+%s")"
	duration="$(((end_time - start_time) / 60))m $(((end_time - start_time) % 60))s"

	f_log "info" "domain lookup finished in ${duration} (${feed}, ${cnt_domain} domains, ${cnt_ip} IPs)"
}

# table statistics
#
f_report() {
	local report_jsn report_txt tmp_val table_json item table_sets set_cnt set_inbound set_outbound set_cntinbound set_cntoutbound set_proto set_dport set_details
	local expr detail jsnval timestamp autoadd_allow autoadd_block sum_sets sum_setinbound sum_setoutbound sum_cntelements sum_cntinbound sum_cntoutbound
	local chain set_elements set_json sum_setelements sum_synflood sum_udpflood sum_icmpflood sum_ctinvalid sum_tcpinvalid output="${1}"

	[ -z "${ban_dev}" ] && f_conf
	f_mkdir "${ban_reportdir}"
	report_jsn="${ban_reportdir}/ban_report.jsn"
	report_txt="${ban_reportdir}/ban_report.txt"

	# json output preparation
	#
	table_json="$("${ban_nftcmd}" -tj list table inet banIP 2>/dev/null)"
	table_sets="$(printf "%s" "${table_json}" | "${ban_jsoncmd}" -qe '@.nftables[@.set.family="inet"].set.name')"
	sum_sets="0"
	sum_cntelements="0"
	sum_setinbound="0"
	sum_setoutbound="0"
	sum_cntinbound="0"
	sum_cntoutbound="0"
	sum_setports="0"
	sum_setelements="0"
	sum_synflood="$(printf "%s" "${table_json}" | "${ban_jsoncmd}" -qe '@.nftables[@.counter.name="cnt_synflood"].*.packets')"
	sum_udpflood="$(printf "%s" "${table_json}" | "${ban_jsoncmd}" -qe '@.nftables[@.counter.name="cnt_udpflood"].*.packets')"
	sum_icmpflood="$(printf "%s" "${table_json}" | "${ban_jsoncmd}" -qe '@.nftables[@.counter.name="cnt_icmpflood"].*.packets')"
	sum_ctinvalid="$(printf "%s" "${table_json}" | "${ban_jsoncmd}" -qe '@.nftables[@.counter.name="cnt_ctinvalid"].*.packets')"
	sum_tcpinvalid="$(printf "%s" "${table_json}" | "${ban_jsoncmd}" -qe '@.nftables[@.counter.name="cnt_tcpinvalid"].*.packets')"
	timestamp="$(date "+%Y-%m-%d %H:%M:%S")"
	: >"${report_jsn}"
	{
		printf "%s\n" "{"
		printf "\t%s\n" '"sets":{'
		for item in ${table_sets}; do
			set_json="$("${ban_nftcmd}" -j list set inet banIP "${item}" 2>/dev/null)"
			set_cnt="$(printf "%s" "${set_json}" | "${ban_jsoncmd}" -qe '@.nftables[*].set.elem[*]' | "${ban_wccmd}" -l 2>/dev/null)"
			sum_cntelements="$((sum_cntelements + set_cnt))"
			set_cntinbound=""
			set_cntoutbound=""
			set_proto=""
			set_dport=""
			for chain in _inbound _outbound; do
				for expr in 0 1 2; do
					if [ "${chain}" = "_inbound" ] && [ -z "${set_cntinbound}" ]; then
						set_cntinbound="$(printf "%s" "${table_json}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.chain=\"${chain}\"][@.expr[${expr}].match.right=\"@${item}\"].expr[*].counter.packets")"
					elif [ "${chain}" = "_outbound" ] && [ -z "${set_cntoutbound}" ]; then
						set_cntoutbound="$(printf "%s" "${table_json}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.chain=\"${chain}\"][@.expr[${expr}].match.right=\"@${item}\"].expr[*].counter.packets")"
					fi
					[ -z "${set_proto}" ] && set_proto="$(printf "%s" "${table_json}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.chain=\"${chain}\"][@.expr[2].match.right=\"@${item}\"].expr[0].match.right.set")"
					[ -z "${set_proto}" ] && set_proto="$(printf "%s" "${table_json}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.chain=\"${chain}\"][@.expr[1].match.right=\"@${item}\"].expr[0].match.left.payload.protocol")"
					[ -z "${set_dport}" ] && set_dport="$(printf "%s" "${table_json}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.chain=\"${chain}\"][@.expr[2].match.right=\"@${item}\"].expr[1].match.right.set")"
					[ -z "${set_dport}" ] && set_dport="$(printf "%s" "${table_json}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.chain=\"${chain}\"][@.expr[2].match.right=\"@${item}\"].expr[1].match.right")"
					[ -z "${set_dport}" ] && set_dport="$(printf "%s" "${table_json}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.chain=\"${chain}\"][@.expr[1].match.right=\"@${item}\"].expr[0].match.right.set")"
					[ -z "${set_dport}" ] && set_dport="$(printf "%s" "${table_json}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.chain=\"${chain}\"][@.expr[1].match.right=\"@${item}\"].expr[0].match.right")"
				done
			done
			if [ -n "${set_proto}" ] && [ -n "${set_dport}" ]; then
				sum_setports="$((sum_setports + 1))"
				set_proto="${set_proto//[\{\}\":]/}"
				set_proto="${set_proto#\[ *}"
				set_proto="${set_proto%* \]}"
				set_dport="${set_dport//[\{\}\":]/}"
				set_dport="${set_dport#\[ *}"
				set_dport="${set_dport%* \]}"
				set_dport="${set_proto}: $(f_trim "${set_dport}")"
			fi
			if [ "${ban_nftcount}" = "1" ]; then
				set_elements="$(printf "%s" "${set_json}" | "${ban_jsoncmd}" -qe '@.nftables[*].set.elem[*][@.counter.packets>0].val' | "${ban_awkcmd}" '{ORS=" "; printf"%s, ",$1}')"
				set_elements="${set_elements//{*/} $(printf "%s" "${set_json}" | "${ban_jsoncmd}" -qe '@.nftables[*].set.elem[*][@.counter.packets>0].val.range[0]' | "${ban_awkcmd}" '{ORS=" "; printf"%s(r), ",$1}')"
				set_elements="$(f_trim "${set_elements%%?}") $(printf "%s" "${set_json}" | "${ban_jsoncmd}" -qe '@.nftables[*].set.elem[*][@.counter.packets>0].val.prefix.addr' | "${ban_awkcmd}" '{ORS=" "; printf"%s(p), ",$1}')"
				set_elements="$(f_trim "${set_elements%%??}")"
				sum_setelements="$((sum_setelements + $(printf "%s" "${set_elements}" | "${ban_wccmd}" -w)))"
			fi
			if [ -n "${set_cntinbound}" ]; then
				set_inbound="ON"
				sum_setinbound="$((sum_setinbound + 1))"
				sum_cntinbound="$((sum_cntinbound + set_cntinbound))"
			else
				set_inbound="-"
				set_cntinbound=""
			fi
			if [ -n "${set_cntoutbound}" ]; then
				set_outbound="ON"
				sum_setoutbound="$((sum_setoutbound + 1))"
				sum_cntoutbound="$((sum_cntoutbound + set_cntoutbound))"
			else
				set_outbound="-"
				set_cntoutbound=""
			fi
			[ "${sum_sets}" -gt "0" ] && printf "%s\n" ","
			printf "\t\t%s\n" "\"${item}\":{"
			printf "\t\t\t%s\n" "\"cnt_elements\": \"${set_cnt}\","
			printf "\t\t\t%s\n" "\"cnt_inbound\": \"${set_cntinbound}\","
			printf "\t\t\t%s\n" "\"inbound\": \"${set_inbound}\","
			printf "\t\t\t%s\n" "\"cnt_outbound\": \"${set_cntoutbound}\","
			printf "\t\t\t%s\n" "\"outbound\": \"${set_outbound}\"",
			printf "\t\t\t%s\n" "\"port\": \"${set_dport:-"-"}\"",
			printf "\t\t\t%s\n" "\"set_elements\": \"${set_elements:-"-"}\""
			printf "\t\t%s" "}"
			sum_sets="$((sum_sets + 1))"
		done
		printf "\n\t%s\n" "},"
		printf "\t%s\n" "\"timestamp\": \"${timestamp}\","
		printf "\t%s\n" "\"autoadd_allow\": \"$("${ban_grepcmd}" -c "added on ${timestamp% *}" "${ban_allowlist}")\","
		printf "\t%s\n" "\"autoadd_block\": \"$("${ban_grepcmd}" -c "added on ${timestamp% *}" "${ban_blocklist}")\","
		printf "\t%s\n" "\"sum_synflood\": \"${sum_synflood}\","
		printf "\t%s\n" "\"sum_udpflood\": \"${sum_udpflood}\","
		printf "\t%s\n" "\"sum_icmpflood\": \"${sum_icmpflood}\","
		printf "\t%s\n" "\"sum_ctinvalid\": \"${sum_ctinvalid}\","
		printf "\t%s\n" "\"sum_tcpinvalid\": \"${sum_tcpinvalid}\","
		printf "\t%s\n" "\"sum_sets\": \"${sum_sets}\","
		printf "\t%s\n" "\"sum_setinbound\": \"${sum_setinbound}\","
		printf "\t%s\n" "\"sum_setoutbound\": \"${sum_setoutbound}\","
		printf "\t%s\n" "\"sum_cntelements\": \"${sum_cntelements}\","
		printf "\t%s\n" "\"sum_cntinbound\": \"${sum_cntinbound}\","
		printf "\t%s\n" "\"sum_cntoutbound\": \"${sum_cntoutbound}\","
		printf "\t%s\n" "\"sum_setports\": \"${sum_setports}\","
		printf "\t%s\n" "\"sum_setelements\": \"${sum_setelements}\""
		printf "%s\n" "}"
	} >>"${report_jsn}"

	# text output preparation
	#
	if [ "${output}" != "json" ] && [ -s "${report_jsn}" ]; then
		: >"${report_txt}"
		json_init
		if json_load_file "${report_jsn}" >/dev/null 2>&1; then
			json_get_var timestamp "timestamp" >/dev/null 2>&1
			json_get_var autoadd_allow "autoadd_allow" >/dev/null 2>&1
			json_get_var autoadd_block "autoadd_block" >/dev/null 2>&1
			json_get_var sum_synflood "sum_synflood" >/dev/null 2>&1
			json_get_var sum_udpflood "sum_udpflood" >/dev/null 2>&1
			json_get_var sum_icmpflood "sum_icmpflood" >/dev/null 2>&1
			json_get_var sum_ctinvalid "sum_ctinvalid" >/dev/null 2>&1
			json_get_var sum_tcpinvalid "sum_tcpinvalid" >/dev/null 2>&1
			json_get_var sum_sets "sum_sets" >/dev/null 2>&1
			json_get_var sum_setinbound "sum_setinbound" >/dev/null 2>&1
			json_get_var sum_setoutbound "sum_setoutbound" >/dev/null 2>&1
			json_get_var sum_cntelements "sum_cntelements" >/dev/null 2>&1
			json_get_var sum_cntinbound "sum_cntinbound" >/dev/null 2>&1
			json_get_var sum_cntoutbound "sum_cntoutbound" >/dev/null 2>&1
			json_get_var sum_setports "sum_setports" >/dev/null 2>&1
			json_get_var sum_setelements "sum_setelements" >/dev/null 2>&1
			{
				printf "%s\n%s\n%s\n" ":::" "::: banIP Set Statistics" ":::"
				printf "%s\n" "    Timestamp: ${timestamp}"
				printf "%s\n" "    ------------------------------"
				printf "%s\n" "    blocked syn-flood packets  : ${sum_synflood}"
				printf "%s\n" "    blocked udp-flood packets  : ${sum_udpflood}"
				printf "%s\n" "    blocked icmp-flood packets : ${sum_icmpflood}"
				printf "%s\n" "    blocked invalid ct packets : ${sum_ctinvalid}"
				printf "%s\n" "    blocked invalid tcp packets: ${sum_tcpinvalid}"
				printf "%s\n" "    ---"
				printf "%s\n" "    auto-added IPs to allowlist: ${autoadd_allow}"
				printf "%s\n\n" "    auto-added IPs to blocklist: ${autoadd_block}"
				json_select "sets" >/dev/null 2>&1
				json_get_keys table_sets >/dev/null 2>&1
				if [ -n "${table_sets}" ]; then
					printf "%-25s%-15s%-24s%-24s%-24s%-24s\n" "    Set" "| Count   " "| Inbound (packets)" "| Outbound (packets)" "| Port/Protocol      " "| Elements           "
					printf "%s\n" "    ---------------------+--------------+-----------------------+-----------------------+-----------------------+------------------------"
					for item in ${table_sets}; do
						printf "    %-21s" "${item}"
						json_select "${item}"
						json_get_keys set_details
						for detail in ${set_details}; do
							json_get_var jsnval "${detail}" >/dev/null 2>&1
							case "${detail}" in
								"cnt_elements")
									printf "%-15s" "| ${jsnval}"
									;;
								"cnt_inbound" | "cnt_outbound")
									[ -n "${jsnval}" ] && tmp_val=": ${jsnval}"
									;;
								"set_elements")
									printf "%-24s" "| ${jsnval:0:24}"
									jsnval="${jsnval:24}" 
									while [ -n "${jsnval}" ]; do
										printf "\n%-25s%-15s%-24s%-24s%-24s%-24s" "" "|" "|" "|" "|" "| ${jsnval:0:24}"
										jsnval="${jsnval:24}"
									done
									;;
								*)
									printf "%-24s" "| ${jsnval}${tmp_val}"
									tmp_val=""
									;;
							esac
						done
						printf "\n"
						json_select ".."
					done
					printf "%s\n" "    ---------------------+--------------+-----------------------+-----------------------+-----------------------+------------------------"
					printf "%-25s%-15s%-24s%-24s%-24s%-24s\n" "    ${sum_sets}" "| ${sum_cntelements}" "| ${sum_setinbound} (${sum_cntinbound})" "| ${sum_setoutbound} (${sum_cntoutbound})" "| ${sum_setports}" "| ${sum_setelements}"
				fi
			} >>"${report_txt}"
		fi
	fi

	# output channel (text|json|mail)
	#
	case "${output}" in
		"text")
			[ -s "${report_txt}" ] && "${ban_catcmd}" "${report_txt}"
			;;
		"json")
			[ -s "${report_jsn}" ] && "${ban_catcmd}" "${report_jsn}"
			;;
		"mail")
			[ -n "${ban_mailreceiver}" ] && [ -x "${ban_mailcmd}" ] && f_mail
			;;
	esac
	: >"${report_txt}"
}

# Set search
#
f_search() {
	local item table_sets ip proto hold cnt result="/var/run/banIP.search" input="${1}"

	if [ -n "${input}" ]; then
		ip="$(printf "%s" "${input}" | "${ban_awkcmd}" 'BEGIN{RS="(([1-9][0-9]{0,2}\\.){1}([0-9]{1,3}\\.){2}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])(\\/(1?[0-9]|2?[0-9]|3?[0-2]))?[[:space:]]*$)"}{printf "%s",RT}')"
		[ -n "${ip}" ] && proto="v4"
		if [ -z "${proto}" ]; then
			ip="$(printf "%s" "${input}" | "${ban_awkcmd}" 'BEGIN{RS="(([0-9A-f]{0,4}:){1,7}[0-9A-f]{0,4}:?(\\/(1?[0-2][0-8]|[0-9][0-9]))?)([[:space:]].*|$)"}{printf "%s",RT}')"
			[ -n "${ip}" ] && proto="v6"
		fi
	fi
	if [ -n "${proto}" ]; then
		table_sets="$("${ban_nftcmd}" -tj list table inet banIP 2>/dev/null | "${ban_jsoncmd}" -qe "@.nftables[@.set.type=\"ip${proto}_addr\"].set.name")"
	else
		printf "%s\n%s\n%s\n" ":::" "::: no valid search input" ":::"
		return
	fi
	cnt="1"
	: >"${result}"
	for item in ${table_sets}; do
		(
			if "${ban_nftcmd}" get element inet banIP "${item}" "{ ${ip} }" >/dev/null 2>&1; then
				printf "%s " "${item}" >>"${result}"
			fi
		) &
		hold="$((cnt % ban_cores))"
		[ "${hold}" = "0" ] && wait
		cnt="$((cnt + 1))"
	done
	wait
	if [ -s "${result}" ]; then
		printf "%s\n%s\n%s\n" ":::" "::: banIP Search" ":::"
		printf "    %s\n" "Looking for IP '${ip}' on $(date "+%Y-%m-%d %H:%M:%S")"
		printf "    %s\n" "---"
		for item in $("${ban_catcmd}" "${result}"); do
			printf "    %s\n" "IP found in Set '${item}'"
		done
		: >"${result}"
	else
		printf "%s\n%s\n%s\n" ":::" "::: banIP Search" ":::"
		printf "    %s\n" "Looking for IP '${ip}' on $(date "+%Y-%m-%d %H:%M:%S")"
		printf "    %s\n" "---"
		printf "    %s\n" "IP not found"
	fi
}

# Set survey
#
f_survey() {
	local set_elements input="${1}"

	if [ -z "${input}" ]; then
		printf "%s\n%s\n%s\n" ":::" "::: no valid survey input" ":::"
		return
	fi
	set_elements="$("${ban_nftcmd}" -j list set inet banIP "${input}" 2>/dev/null | "${ban_jsoncmd}" -qe '@.nftables[*].set.elem[*]')"
	printf "%s\n%s\n%s\n" ":::" "::: banIP Survey" ":::"
	printf "    %s\n" "List of elements in the Set '${input}' on $(date "+%Y-%m-%d %H:%M:%S")"
	printf "    %s\n" "---"
	[ -n "${set_elements}" ] && printf "%s\n" "${set_elements}" || printf "    %s\n" "empty Set"
}

# send status mail
#
f_mail() {
	local msmtp_debug

	# load mail template
	#
	if [ -r "${ban_mailtemplate}" ]; then
		. "${ban_mailtemplate}"
	else
		f_log "info" "no mail template"
	fi
	[ -z "${mail_text}" ] && f_log "info" "no mail content"
	[ "${ban_debug}" = "1" ] && msmtp_debug="--debug"

	# send mail
	#
	ban_mailhead="From: ${ban_mailsender}\nTo: ${ban_mailreceiver}\nSubject: ${ban_mailtopic}\nReply-to: ${ban_mailsender}\nMime-Version: 1.0\nContent-Type: text/html;charset=utf-8\nContent-Disposition: inline\n\n"
	printf "%b" "${ban_mailhead}${mail_text}" | "${ban_mailcmd}" --timeout=10 ${msmtp_debug} -a "${ban_mailprofile}" "${ban_mailreceiver}" >/dev/null 2>&1
	f_log "info" "send status mail (${?})"

	f_log "debug" "f_mail      ::: notification: ${ban_mailnotification}, template: ${ban_mailtemplate}, profile: ${ban_mailprofile}, receiver: ${ban_mailreceiver}, rc: ${?}"
}

# log monitor
#
f_monitor() {
	local daemon logread_cmd loglimit_cmd nft_expiry line proto ip log_raw log_count idx prefix cidr rdap_log rdap_rc rdap_idx rdap_info

	if [ -f "${ban_logreadfile}" ]; then
		logread_cmd="${ban_logreadcmd} -qf ${ban_logreadfile} 2>/dev/null | ${ban_grepcmd} -e \"${ban_logterm%%??}\" 2>/dev/null"
		loglimit_cmd="${ban_logreadcmd} -qn ${ban_loglimit} ${ban_logreadfile} 2>/dev/null"
	else
		logread_cmd="${ban_logreadcmd} -fe \"${ban_logterm%%??}\" 2>/dev/null"
		loglimit_cmd="${ban_logreadcmd} -l ${ban_loglimit} 2>/dev/null"
	fi

	if [ -x "${ban_logreadcmd}" ] && [ -n "${logread_cmd}" ] && [ -n "${loglimit_cmd}" ] && [ -n "${ban_logterm%%??}" ] && [ "${ban_loglimit}" != "0" ]; then
		f_log "info" "start detached banIP log service (${ban_logreadcmd})"
		[ -n "${ban_nftexpiry}" ] && nft_expiry="timeout $(printf "%s" "${ban_nftexpiry}" | "${ban_grepcmd}" -oE "([0-9]+[d|h|m|s])+$")"
		eval "${logread_cmd}" |
			while read -r line; do
				proto=""
				: >"${ban_rdapfile}"
				if [ -z "${daemon}" ]; then
					daemon="$(printf "%s" "${line}" | "${ban_awkcmd}" 'BEGIN{RS="dropbear"}{if(!seen[RT]++)printf "%s",RT}')"
					[ -z "${daemon}" ] && daemon="sshd"
				fi
				ip="$(printf "%s" "${line}" | "${ban_awkcmd}" 'BEGIN{RS="(([1-9][0-9]{0,2}\\.){1}([0-9]{1,3}\\.){2}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5]))+"}{if(!seen[RT]++)printf "%s ",RT}')"
				ip="$(f_trim "${ip}")"
				ip="${ip##* }"
				[ -n "${ip}" ] && [ "${ip%%.*}" != "127" ] && [ "${ip%%.*}" != "0" ] && proto=".v4"
				if [ -z "${proto}" ]; then
					if [ "${daemon}" = "dropbear" ]; then
						ip="$(printf "%s" "${line}" | "${ban_awkcmd}" 'BEGIN{RS="([A-Fa-f0-9]{1,4}::?){3,7}([A-Fa-f0-9]:?)+"}{if(!seen[RT]++)printf "%s ",RT}')"
						ip="${ip%:*}"
					else
						ip="$(printf "%s" "${line}" | "${ban_awkcmd}" 'BEGIN{RS="([A-Fa-f0-9]{1,4}::?){3,7}[A-Fa-f0-9]{1,4}"}{if(!seen[RT]++)printf "%s ",RT}')"
					fi
					ip="$(f_trim "${ip}")"
					ip="${ip##* }"
					[ -n "${ip%%::*}" ] && proto=".v6"
				fi
				if [ -n "${proto}" ] && ! "${ban_nftcmd}" get element inet banIP allowlist"${proto}" "{ ${ip} }" >/dev/null 2>&1 && ! "${ban_nftcmd}" get element inet banIP blocklist"${proto}" "{ ${ip} }" >/dev/null 2>&1; then
					f_log "info" "suspicious IP '${ip}'"
					log_raw="$(eval ${loglimit_cmd})"
					log_count="$(printf "%s\n" "${log_raw}" | "${ban_grepcmd}" -c "suspicious IP '${ip}'")"
					if [ "${log_count}" -ge "${ban_logcount}" ]; then
						if "${ban_nftcmd}" add element inet banIP "blocklist${proto}" { ${ip} ${nft_expiry} } >/dev/null 2>&1; then
							f_log "info" "add IP '${ip}' (expiry: ${ban_nftexpiry:-"-"}) to blocklist${proto} set"
						fi
						if [ "${ban_autoblocksubnet}" = "1" ]; then
							rdap_log="$("${ban_fetchcmd}" ${ban_rdapparm} "${ban_rdapfile}" "${ban_rdapurl}${ip}" 2>&1)"
							rdap_rc="${?}"
							if [ "${rdap_rc}" = "0" ] && [ -s "${ban_rdapfile}" ]; then
								[ "${proto}" = ".v4" ] && rdap_idx="$("${ban_jsoncmd}" -i "${ban_rdapfile}" -qe '@.cidr0_cidrs[@.v4prefix].*' | "${ban_awkcmd}" '{ORS=" "; print}')"
								[ "${proto}" = ".v6" ] && rdap_idx="$("${ban_jsoncmd}" -i "${ban_rdapfile}" -qe '@.cidr0_cidrs[@.v6prefix].*' | "${ban_awkcmd}" '{ORS=" "; print}')"
								rdap_info="$("${ban_jsoncmd}" -l1 -i "${ban_rdapfile}" -qe '@.country' -qe '@.notices[@.title="Source"].description[1]' | "${ban_awkcmd}" 'BEGIN{RS="";FS="\n"}{printf "%s, %s",$1,$2}')"
								[ -z "${rdap_info}" ] && rdap_info="$("${ban_jsoncmd}" -l1 -i "${ban_rdapfile}" -qe '@.notices[0].links[0].value' | "${ban_awkcmd}" 'BEGIN{FS="[/.]"}{printf"%s, %s","n/a",toupper($4)}')"
								for idx in ${rdap_idx}; do
									if [ -z "${prefix}" ]; then
										prefix="${idx}"
										continue
									else
										cidr="${prefix}/${idx}"
										if "${ban_nftcmd}" add element inet banIP "blocklist${proto}" { ${cidr} ${nft_expiry} } >/dev/null 2>&1; then
											f_log "info" "add IP range '${cidr}' (source: ${rdap_info:-"n/a"} ::: expiry: ${ban_nftexpiry:-"-"}) to blocklist${proto} set"
										fi
										prefix=""
									fi
								done
							else
								f_log "info" "rdap request failed (rc: ${rdap_rc:-"-"}/log: ${rdap_log})"
							fi
						fi
						if [ -z "${ban_nftexpiry}" ] && [ "${ban_autoblocklist}" = "1" ] && ! "${ban_grepcmd}" -q "^${ip}" "${ban_blocklist}"; then
							printf "%-45s%s\n" "${ip}" "# added on $(date "+%Y-%m-%d %H:%M:%S")" >>"${ban_blocklist}"
							f_log "info" "add IP '${ip}' to local blocklist"
						fi
					fi
				fi
			done
	else
		f_log "info" "start detached no-op banIP service"
		sleep infinity
	fi
}

# initial sourcing
#
if [ -r "/lib/functions.sh" ] && [ -r "/lib/functions/network.sh" ] && [ -r "/usr/share/libubox/jshn.sh" ]; then
	. "/lib/functions.sh"
	. "/lib/functions/network.sh"
	. "/usr/share/libubox/jshn.sh"
else
	f_log "emerg" "system libraries not found"
fi

# reference required system utilities
#
ban_awkcmd="$(f_cmd gawk awk)"
ban_catcmd="$(f_cmd cat)"
ban_fw4cmd="$(f_cmd fw4)"
ban_grepcmd="$(f_cmd grep)"
ban_jsoncmd="$(f_cmd jsonfilter)"
ban_logcmd="$(f_cmd logger)"
ban_lookupcmd="$(f_cmd nslookup)"
ban_mailcmd="$(f_cmd msmtp optional)"
ban_nftcmd="$(f_cmd nft)"
ban_pgrepcmd="$(f_cmd pgrep)"
ban_sedcmd="$(f_cmd sed)"
ban_ubuscmd="$(f_cmd ubus)"
ban_zcatcmd="$(f_cmd zcat)"
ban_gzipcmd="$(f_cmd gzip)"
ban_wccmd="$(f_cmd wc)"

f_system
if [ "${ban_action}" != "stop" ]; then
	[ ! -d "/etc/banip" ] && f_log "err" "no banIP config directory"
	[ ! -r "/etc/config/banip" ] && f_log "err" "no banIP config"
	[ "$(uci_get banip global ban_enabled)" = "0" ] && f_log "err" "banIP is disabled"
fi
