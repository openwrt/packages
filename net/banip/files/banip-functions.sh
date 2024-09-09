# banIP shared function library/include - ban incoming and outgoing IPs via named nftables Sets
# Copyright (c) 2018-2024 Dirk Brenken (dev@brenken.org)
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
ban_reportelements="1"
ban_remotelog="0"
ban_remotetoken=""
ban_nftloglevel="warn"
ban_nftpriority="-100"
ban_nftpolicy="memory"
ban_nftexpiry=""
ban_loglimit="100"
ban_icmplimit="10"
ban_synlimit="10"
ban_udplimit="100"
ban_logcount="1"
ban_logterm=""
ban_region=""
ban_country=""
ban_asn=""
ban_logprerouting="0"
ban_loginput="0"
ban_logforwardwan="0"
ban_logforwardlan="0"
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
ban_blockpolicy=""
ban_blocktype="drop"
ban_blockinput=""
ban_blockforwardwan=""
ban_blockforwardlan=""
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
ban_memory=""
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
	ban_memory="$("${ban_awkcmd}" '/^MemAvailable/{printf "%s",int($2/1000)}' "/proc/meminfo" 2>/dev/null)"
	ban_ver="$(printf "%s" "${ban_packages}" | "${ban_jsoncmd}" -ql1 -e '@.packages.banip')"
	ban_sysver="$("${ban_ubuscmd}" -S call system board 2>/dev/null | "${ban_jsoncmd}" -ql1 -e '@.model' -e '@.release.description' |
		"${ban_awkcmd}" 'BEGIN{RS="";FS="\n"}{printf "%s, %s",$1,$2}')"
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
			"${ban_logcmd}" -p "${class}" -t "banIP-${ban_ver}[${$}]" "${log_msg::512}"
		else
			printf "%s %s %s\n" "${class}" "banIP-${ban_ver}[${$}]" "${log_msg::512}"
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

	unset ban_dev ban_vlanallow ban_vlanblock ban_ifv4 ban_ifv6 ban_feed ban_allowurl ban_blockinput ban_blockforwardwan ban_blockforwardlan ban_logterm ban_region ban_country ban_asn
	config_cb() {
		option_cb() {
			local option="${1}"
			local value="${2}"
			eval "${option}=\"${value}\""
		}
		list_cb() {
			local option="${1}"
			local value="${2}"
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
				"ban_allowurl")
					eval "${option}=\"$(printf "%s" "${ban_allowurl}")${value} \""
					;;
				"ban_blockinput")
					eval "${option}=\"$(printf "%s" "${ban_blockinput}")${value} \""
					;;
				"ban_blockforwardwan")
					eval "${option}=\"$(printf "%s" "${ban_blockforwardwan}")${value} \""
					;;
				"ban_blockforwardlan")
					eval "${option}=\"$(printf "%s" "${ban_blockforwardlan}")${value} \""
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

	if "${ban_nftcmd}" -t list set inet banIP allowlistv4MAC >/dev/null 2>&1; then
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
	local item utils insecure update="0"

	if { [ "${ban_fetchcmd}" = "uclient-fetch" ] && printf "%s" "${ban_packages}" | "${ban_grepcmd}" -q '"libustream-'; } ||
		{ [ "${ban_fetchcmd}" = "wget" ] && printf "%s" "${ban_packages}" | "${ban_grepcmd}" -q '"wget-ssl'; } ||
		[ "${ban_fetchcmd}" = "curl" ] || [ "${ban_fetchcmd}" = "aria2c" ]; then
		ban_fetchcmd="$(f_cmd "${ban_fetchcmd}" "true")"
	fi

	if [ "${ban_autodetect}" = "1" ] && [ ! -x "${ban_fetchcmd}" ]; then
		utils="aria2c curl wget uclient-fetch"
		for item in ${utils}; do
			if { [ "${item}" = "uclient-fetch" ] && printf "%s" "${ban_packages}" | "${ban_grepcmd}" -q '"libustream-'; } ||
				{ [ "${item}" = "wget" ] && printf "%s" "${ban_packages}" | "${ban_grepcmd}" -q '"wget-ssl'; } ||
				[ "${item}" = "curl" ] || [ "${item}" = "aria2c" ]; then
				ban_fetchcmd="$(command -v "${item}")"
				if [ -x "${ban_fetchcmd}" ]; then
					update="1"
					uci_set banip global ban_fetchcmd "${item}"
					uci_commit "banip"
					break
				fi
			fi
		done
	fi

	[ ! -x "${ban_fetchcmd}" ] && f_log "err" "no download utility with SSL support"
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

	f_log "debug" "f_getfetch  ::: auto/update: ${ban_autodetect}/${update}, cmd: ${ban_fetchcmd:-"-"}, fetch_parm: ${ban_fetchparm:-"-"}, rdap_parm: ${ban_rdapparm:-"-"}, etag_parm: ${ban_etagparm:-"-"}"
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
	local uplink iface ip update="0"

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
			if [ -n "${uplink}" ] && ! printf " %s " "${ban_uplink}" | "${ban_grepcmd}" -q " ${uplink} "; then
				ban_uplink="${ban_uplink}${uplink} "
			fi
		done
		for ip in ${ban_uplink}; do
			if ! "${ban_grepcmd}" -q "${ip} " "${ban_allowlist}"; then
				if [ "${update}" = "0" ]; then
					"${ban_sedcmd}" -i "/# uplink added on /d" "${ban_allowlist}"
				fi
				printf "%-42s%s\n" "${ip}" "# uplink added on $(date "+%Y-%m-%d %H:%M:%S")" >>"${ban_allowlist}"
				f_log "info" "add uplink '${ip}' to local allowlist"
				update="1"
			fi
		done
		ban_uplink="$(f_trim "${ban_uplink}")"
	elif [ "${ban_autoallowlist}" = "1" ] && [ "${ban_autoallowuplink}" = "disable" ]; then
		"${ban_sedcmd}" -i "/# uplink added on /d" "${ban_allowlist}"
		update="1"
	fi

	f_log "debug" "f_getuplink ::: auto/update: ${ban_autoallowlist}/${update}, uplink: ${ban_uplink:-"-"}"
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

# build initial nft file with base table, chains and rules
#
f_nftinit() {
	local wan_dev vlan_allow vlan_block log_ct log_icmp log_syn log_udp log_tcp feed_log feed_rc flag tmp_proto tmp_port allow_dport file="${1}"

	wan_dev="$(printf "%s" "${ban_dev}" | "${ban_sedcmd}" 's/^/\"/;s/$/\"/;s/ /\", \"/g')"
	[ -n "${ban_vlanallow}" ] && vlan_allow="$(printf "%s" "${ban_vlanallow%%?}" | "${ban_sedcmd}" 's/^/\"/;s/$/\"/;s/ /\", \"/g')"
	[ -n "${ban_vlanblock}" ] && vlan_block="$(printf "%s" "${ban_vlanblock%%?}" | "${ban_sedcmd}" 's/^/\"/;s/$/\"/;s/ /\", \"/g')"

	for flag in ${ban_allowflag}; do
		if [ "${flag}" = "tcp" ] || [ "${flag}" = "udp" ]; then
			if [ -z "${tmp_proto}" ]; then
				tmp_proto="${flag}"
			elif ! printf "%s" "${tmp_proto}" | "${ban_grepcmd}" -qw "${flag}"; then
				tmp_proto="${tmp_proto}, ${flag}"
			fi
		elif [ -n "${flag//[![:digit:]-]/}" ]; then
			if [ -z "${tmp_port}" ]; then
				tmp_port="${flag}"
			elif ! printf "%s" "${tmp_port}" | "${ban_grepcmd}" -qw "${flag}"; then
				tmp_port="${tmp_port}, ${flag}"
			fi
		fi
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
		# nft header (tables and chains)
		#
		printf "%s\n\n" "#!/usr/sbin/nft -f"
		if "${ban_nftcmd}" -t list set inet banIP allowlistv4MAC >/dev/null 2>&1; then
			printf "%s\n" "delete table inet banIP"
		fi
		printf "%s\n" "add table inet banIP"
		printf "%s\n" "add counter inet banIP cnt-icmpflood"
		printf "%s\n" "add counter inet banIP cnt-udpflood"
		printf "%s\n" "add counter inet banIP cnt-synflood"
		printf "%s\n" "add counter inet banIP cnt-tcpinvalid"
		printf "%s\n" "add counter inet banIP cnt-ctinvalid"
		printf "%s\n" "add chain inet banIP pre-routing { type filter hook prerouting priority -150; policy accept; }"
		printf "%s\n" "add chain inet banIP wan-input { type filter hook input priority ${ban_nftpriority}; policy accept; }"
		printf "%s\n" "add chain inet banIP wan-forward { type filter hook forward priority ${ban_nftpriority}; policy accept; }"
		printf "%s\n" "add chain inet banIP lan-forward { type filter hook forward priority ${ban_nftpriority}; policy accept; }"
		printf "%s\n" "add chain inet banIP reject-chain"

		# default reject chain rules
		#
		printf "%s\n" "add rule inet banIP reject-chain meta l4proto tcp reject with tcp reset"
		printf "%s\n" "add rule inet banIP reject-chain reject"

		# default pre-routing rules
		#
		printf "%s\n" "add rule inet banIP pre-routing iifname != { ${wan_dev} } counter accept"
		printf "%s\n" "add rule inet banIP pre-routing ct state invalid ${log_ct} counter name cnt-ctinvalid drop"
		if [ "${ban_icmplimit}" -gt "0" ]; then
			printf "%s\n" "add rule inet banIP pre-routing ip protocol icmp limit rate over ${ban_icmplimit}/second ${log_icmp} counter name cnt-icmpflood drop"
			printf "%s\n" "add rule inet banIP pre-routing ip6 nexthdr icmpv6 limit rate over ${ban_icmplimit}/second ${log_icmp} counter name cnt-icmpflood drop"
		fi
		[ "${ban_udplimit}" -gt "0" ] && printf "%s\n" "add rule inet banIP pre-routing meta l4proto udp ct state new limit rate over ${ban_udplimit}/second ${log_udp} counter name cnt-udpflood drop"
		[ "${ban_synlimit}" -gt "0" ] && printf "%s\n" "add rule inet banIP pre-routing tcp flags & (fin|syn|rst|ack) == syn limit rate over ${ban_synlimit}/second ${log_syn} counter name cnt-synflood drop"
		printf "%s\n" "add rule inet banIP pre-routing tcp flags & (fin|syn) == (fin|syn) ${log_tcp} counter name cnt-tcpinvalid drop"
		printf "%s\n" "add rule inet banIP pre-routing tcp flags & (syn|rst) == (syn|rst) ${log_tcp} counter name cnt-tcpinvalid drop"
		printf "%s\n" "add rule inet banIP pre-routing tcp flags & (fin|syn|rst|psh|ack|urg) < (fin) ${log_tcp} counter name cnt-tcpinvalid drop"
		printf "%s\n" "add rule inet banIP pre-routing tcp flags & (fin|syn|rst|psh|ack|urg) == (fin|psh|urg) ${log_tcp} counter name cnt-tcpinvalid drop"

		# default wan-input rules
		#
		printf "%s\n" "add rule inet banIP wan-input iifname != { ${wan_dev} } counter accept"
		printf "%s\n" "add rule inet banIP wan-input ct state established,related counter accept"
		printf "%s\n" "add rule inet banIP wan-input meta nfproto ipv4 udp sport 67-68 udp dport 67-68 counter accept"
		printf "%s\n" "add rule inet banIP wan-input meta nfproto ipv6 udp sport 547 udp dport 546 counter accept"
		printf "%s\n" "add rule inet banIP wan-input meta nfproto ipv6 icmpv6 type { nd-neighbor-advert, nd-neighbor-solicit, nd-router-advert} ip6 hoplimit 1 counter accept"
		printf "%s\n" "add rule inet banIP wan-input meta nfproto ipv6 icmpv6 type { nd-neighbor-advert, nd-neighbor-solicit, nd-router-advert} ip6 hoplimit 255 counter accept"
		[ -n "${allow_dport}" ] && printf "%s\n" "add rule inet banIP wan-input ${allow_dport} counter accept"

		# default wan-forward rules
		#
		printf "%s\n" "add rule inet banIP wan-forward iifname != { ${wan_dev} } counter accept"
		printf "%s\n" "add rule inet banIP wan-forward ct state established,related counter accept"
		[ -n "${allow_dport}" ] && printf "%s\n" "add rule inet banIP wan-forward ${allow_dport} counter accept"

		# default lan-forward rules
		#
		printf "%s\n" "add rule inet banIP lan-forward oifname != { ${wan_dev} } counter accept"
		printf "%s\n" "add rule inet banIP lan-forward ct state established,related counter accept"
		[ -n "${vlan_allow}" ] && printf "%s\n" "add rule inet banIP lan-forward iifname { ${vlan_allow} } counter accept"
		[ -n "${vlan_block}" ] && printf "%s\n" "add rule inet banIP lan-forward iifname { ${vlan_block} } counter goto reject-chain"
	} >"${file}"

	# load initial banIP table within nft (atomic load)
	#
	feed_log="$("${ban_nftcmd}" -f "${file}" 2>&1)"
	feed_rc="${?}"

	if [ "${feed_rc}" = "0" ]; then
		f_log "info" "initialize banIP nftables namespace"
	else
		f_log "err" "can't initialize banIP nftables namespace (rc: ${feed_rc}, log: ${feed_log})"
	fi

	f_log "debug" "f_nftinit   ::: wan_dev: ${wan_dev}, vlan_allow: ${vlan_allow:-"-"}, vlan_block: ${vlan_block:-"-"}, allowed_dports: ${allow_dport:-"-"}, priority: ${ban_nftpriority}, policy: ${ban_nftpolicy}, icmp_limit: ${ban_icmplimit}, syn_limit: ${ban_synlimit}, udp_limit: ${ban_udplimit}, loglevel: ${ban_nftloglevel}, rc: ${feed_rc:-"-"}, log: ${feed_log:-"-"}"
	: >"${file}"
	return "${feed_rc}"
}

# handle downloads
#
f_down() {
	local log_input log_forwardwan log_forwardlan start_ts end_ts tmp_raw tmp_load tmp_file split_file ruleset_raw handle rc etag_rc
	local expr cnt_set cnt_dl restore_rc feed_direction feed_rc feed_log feed_comp feed_target feed_dport tmp_proto tmp_port flag
	local feed="${1}" proto="${2}" feed_url="${3}" feed_rule="${4}" feed_flag="${5}"

	start_ts="$(date +%s)"
	feed="${feed}v${proto}"
	tmp_load="${ban_tmpfile}.${feed}.load"
	tmp_raw="${ban_tmpfile}.${feed}.raw"
	tmp_split="${ban_tmpfile}.${feed}.split"
	tmp_file="${ban_tmpfile}.${feed}.file"
	tmp_flush="${ban_tmpfile}.${feed}.flush"
	tmp_nft="${ban_tmpfile}.${feed}.nft"
	tmp_allow="${ban_tmpfile}.${feed%v*}"

	[ "${ban_loginput}" = "1" ] && log_input="log level ${ban_nftloglevel} prefix \"banIP/inp-wan/${ban_blocktype}/${feed}: \""
	[ "${ban_logforwardwan}" = "1" ] && log_forwardwan="log level ${ban_nftloglevel} prefix \"banIP/fwd-wan/${ban_blocktype}/${feed}: \""
	[ "${ban_logforwardlan}" = "1" ] && log_forwardlan="log level ${ban_nftloglevel} prefix \"banIP/fwd-lan/reject/${feed}: \""

	# set feed target
	#
	if [ "${ban_blocktype}" = "reject" ]; then
		feed_target="goto reject-chain"
	else
		feed_target="drop"
	fi

	# set feed block direction
	#
	if [ "${ban_blockpolicy}" = "input" ]; then
		if ! printf "%s" "${ban_blockinput}" | "${ban_grepcmd}" -q "${feed%v*}" &&
			! printf "%s" "${ban_blockforwardwan}" | "${ban_grepcmd}" -q "${feed%v*}" &&
			! printf "%s" "${ban_blockforwardlan}" | "${ban_grepcmd}" -q "${feed%v*}"; then
			ban_blockinput="${ban_blockinput} ${feed%v*}"
		fi
	elif [ "${ban_blockpolicy}" = "forwardwan" ]; then
		if ! printf "%s" "${ban_blockinput}" | "${ban_grepcmd}" -q "${feed%v*}" &&
			! printf "%s" "${ban_blockforwardwan}" | "${ban_grepcmd}" -q "${feed%v*}" &&
			! printf "%s" "${ban_blockforwardlan}" | "${ban_grepcmd}" -q "${feed%v*}"; then
			ban_blockforwardwan="${ban_blockforwardwan} ${feed%v*}"
		fi
	elif [ "${ban_blockpolicy}" = "forwardlan" ]; then
		if ! printf "%s" "${ban_blockinput}" | "${ban_grepcmd}" -q "${feed%v*}" &&
			! printf "%s" "${ban_blockforwardwan}" | "${ban_grepcmd}" -q "${feed%v*}" &&
			! printf "%s" "${ban_blockforwardlan}" | "${ban_grepcmd}" -q "${feed%v*}"; then
			ban_blockforwardlan="${ban_blockforwardlan} ${feed%v*}"
		fi
	fi
	if printf "%s" "${ban_blockinput}" | "${ban_grepcmd}" -q "${feed%v*}"; then
		feed_direction="input"
	fi
	if printf "%s" "${ban_blockforwardwan}" | "${ban_grepcmd}" -q "${feed%v*}"; then
		feed_direction="${feed_direction} forwardwan"
	fi
	if printf "%s" "${ban_blockforwardlan}" | "${ban_grepcmd}" -q "${feed%v*}"; then
		feed_direction="${feed_direction} forwardlan"
	fi

	# prepare feed flags
	#
	for flag in ${feed_flag}; do
		if [ "${flag}" = "gz" ]; then
			feed_comp="${flag}"
		elif [ "${flag}" = "tcp" ] || [ "${flag}" = "udp" ]; then
			if [ -z "${tmp_proto}" ]; then
				tmp_proto="${flag}"
			elif ! printf "%s" "${tmp_proto}" | "${ban_grepcmd}" -qw "${flag}"; then
				tmp_proto="${tmp_proto}, ${flag}"
			fi
		elif [ -n "${flag//[![:digit:]-]/}" ]; then
			if [ -z "${tmp_port}" ]; then
				tmp_port="${flag}"
			elif ! printf "%s" "${tmp_port}" | "${ban_grepcmd}" -qw "${flag}"; then
				tmp_port="${tmp_port}, ${flag}"
			fi
		fi
	done
	if [ -n "${tmp_proto}" ] && [ -n "${tmp_port}" ]; then
		feed_dport="meta l4proto { ${tmp_proto} } th dport { ${tmp_port} }"
	fi

	# chain/rule maintenance
	#
	if [ "${ban_action}" = "reload" ] && "${ban_nftcmd}" -t list set inet banIP "${feed}" >/dev/null 2>&1; then
		ruleset_raw="$("${ban_nftcmd}" -tj list ruleset 2>/dev/null)"
		{
			printf "%s\n" "flush set inet banIP ${feed}"
			for expr in 0 1; do
				handle="$(printf "%s\n" "${ruleset_raw}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.table=\"banIP\"&&@.rule.chain=\"wan-input\"][@.expr[${expr}].match.right=\"@${feed}\"].handle")"
				[ -n "${handle}" ] && printf "%s\n" "delete rule inet banIP wan-input handle ${handle}"
				handle="$(printf "%s\n" "${ruleset_raw}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.table=\"banIP\"&&@.rule.chain=\"wan-forward\"][@.expr[${expr}].match.right=\"@${feed}\"].handle")"
				[ -n "${handle}" ] && printf "%s\n" "delete rule inet banIP wan-forward handle ${handle}"
				handle="$(printf "%s\n" "${ruleset_raw}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.table=\"banIP\"&&@.rule.chain=\"lan-forward\"][@.expr[${expr}].match.right=\"@${feed}\"].handle")"
				[ -n "${handle}" ] && printf "%s\n" "delete rule inet banIP lan-forward handle ${handle}"
			done
		} >"${tmp_flush}"
	fi

	# restore local backups
	#
	if [ "${feed%v*}" != "blocklist" ]; then
		if [ -n "${ban_etagparm}" ] && [ "${ban_action}" = "reload" ] && [ "${feed_url}" != "local" ] && [ "${feed%v*}" != "allowlist" ]; then
			etag_rc="0"
			if [ "${feed%v*}" = "country" ]; then
				for country in ${ban_country}; do
					f_etag "${feed}" "${feed_url}${country}-aggregated.zone" ".${country}"
					rc="${?}"
					[ "${rc}" = "4" ] && break
					etag_rc="$((etag_rc + rc))"
				done
			elif [ "${feed%v*}" = "asn" ]; then
				for asn in ${ban_asn}; do
					f_etag "${feed}" "${feed_url}AS${asn}" ".${asn}"
					rc="${?}"
					[ "${rc}" = "4" ] && break
					etag_rc="$((etag_rc + rc))"
				done
			else
				f_etag "${feed}" "${feed_url}"
				etag_rc="${?}"
			fi
		fi
		if [ "${etag_rc}" = "0" ] || [ "${ban_action}" != "reload" ] || [ "${feed_url}" = "local" ]; then
			if [ "${feed%v*}" = "allowlist" ] && [ ! -f "${tmp_allow}" ]; then
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
	if [ "${feed%v*}" = "allowlist" ] && [ ! -f "${tmp_allow}" ]; then
		"${ban_catcmd}" "${ban_allowlist}" 2>/dev/null >"${tmp_allow}"
		feed_rc="${?}"
		for feed_url in ${ban_allowurl}; do
			feed_log="$("${ban_fetchcmd}" ${ban_fetchparm} "${tmp_load}" "${feed_url}" 2>&1)"
			feed_rc="${?}"
			if [ "${feed_rc}" = "0" ] && [ -s "${tmp_load}" ]; then
				"${ban_catcmd}" "${tmp_load}" 2>/dev/null >>"${tmp_allow}"
			else
				f_log "info" "download for feed '${feed%v*}' failed (rc: ${feed_rc:-"-"}/log: ${feed_log})"
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
	if [ "${feed%v*}" = "allowlist" ]; then
		{
			printf "%s\n\n" "#!/usr/sbin/nft -f"
			[ -s "${tmp_flush}" ] && "${ban_catcmd}" "${tmp_flush}"
			if [ "${proto}" = "4MAC" ]; then
				"${ban_awkcmd}" '/^([0-9A-f]{2}:){5}[0-9A-f]{2}(\/([0-9]|[1-3][0-9]|4[0-8]))?([[:space:]]+([1-9][0-9]?[0-9]?\.){1}([0-9]{1,3}\.){2}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])(\/(1?[0-9]|2?[0-9]|3?[0-2]))?[[:space:]]*$|[[:space:]]+$|$)/{if(!$2)$2="0.0.0.0/0";if(!seen[$1]++)printf "%s . %s, ",tolower($1),$2}' "${tmp_allow}" >"${tmp_file}"
				printf "%s\n" "add set inet banIP ${feed} { type ether_addr . ipv4_addr; flags interval; auto-merge; policy ${ban_nftpolicy}; $(f_getelements "${tmp_file}") }"
				[ -z "${feed_direction##*forwardlan*}" ] && printf "%s\n" "add rule inet banIP lan-forward ether saddr . ip saddr @${feed} counter accept"
			elif [ "${proto}" = "6MAC" ]; then
				"${ban_awkcmd}" '/^([0-9A-f]{2}:){5}[0-9A-f]{2}(\/([0-9]|[1-3][0-9]|4[0-8]))?([[:space:]]+([0-9A-f]{0,4}:){1,7}[0-9A-f]{0,4}:?(\/(1?[0-2][0-8]|[0-9][0-9]))?[[:space:]]*$|[[:space:]]+$|$)/{if(!$2)$2="::/0";if(!seen[$1]++)printf "%s . %s, ",tolower($1),$2}' "${tmp_allow}" >"${tmp_file}"
				printf "%s\n" "add set inet banIP ${feed} { type ether_addr . ipv6_addr; flags interval; auto-merge; policy ${ban_nftpolicy}; $(f_getelements "${tmp_file}") }"
				[ -z "${feed_direction##*forwardlan*}" ] && printf "%s\n" "add rule inet banIP lan-forward ether saddr . ip6 saddr @${feed} counter accept"
			elif [ "${proto}" = "4" ]; then
				"${ban_awkcmd}" '/^127\./{next}/^(([1-9][0-9]?[0-9]?\.){1}([0-9]{1,3}\.){2}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])(\/(1?[0-9]|2?[0-9]|3?[0-2]))?)([[:space:]].*|$)/{printf "%s, ",$1}' "${tmp_allow}" >"${tmp_file}"
				printf "%s\n" "add set inet banIP ${feed} { type ipv4_addr; flags interval; auto-merge; policy ${ban_nftpolicy}; $(f_getelements "${tmp_file}") }"
				if [ -z "${feed_direction##*input*}" ]; then
					if [ "${ban_allowlistonly}" = "1" ]; then
						printf "%s\n" "add rule inet banIP wan-input ip saddr != @${feed} ${log_input} counter ${feed_target}"
					else
						printf "%s\n" "add rule inet banIP wan-input ip saddr @${feed} counter accept"
					fi
				fi
				if [ -z "${feed_direction##*forwardwan*}" ]; then
					if [ "${ban_allowlistonly}" = "1" ]; then
						printf "%s\n" "add rule inet banIP wan-forward ip saddr != @${feed} ${log_forwardwan} counter ${feed_target}"
					else
						printf "%s\n" "add rule inet banIP wan-forward ip saddr @${feed} counter accept"
					fi
				fi
				if [ -z "${feed_direction##*forwardlan*}" ]; then
					if [ "${ban_allowlistonly}" = "1" ]; then
						printf "%s\n" "add rule inet banIP lan-forward ip daddr != @${feed} ${log_forwardlan} counter goto reject-chain"
					else
						printf "%s\n" "add rule inet banIP lan-forward ip daddr @${feed} counter accept"
					fi
				fi
			elif [ "${proto}" = "6" ]; then
				"${ban_awkcmd}" '!/^([0-9A-f]{2}:){5}[0-9A-f]{2}.*/{printf "%s\n",$1}' "${tmp_allow}" |
					"${ban_awkcmd}" '/^(([0-9A-f]{0,4}:){1,7}[0-9A-f]{0,4}:?(\/(1?[0-2][0-8]|[0-9][0-9]))?)([[:space:]].*|$)/{printf "%s, ",tolower($1)}' >"${tmp_file}"
				printf "%s\n" "add set inet banIP ${feed} { type ipv6_addr; flags interval; auto-merge; policy ${ban_nftpolicy}; $(f_getelements "${tmp_file}") }"
				if [ -z "${feed_direction##*input*}" ]; then
					if [ "${ban_allowlistonly}" = "1" ]; then
						printf "%s\n" "add rule inet banIP wan-input ip6 saddr != @${feed} ${log_input} counter ${feed_target}"
					else
						printf "%s\n" "add rule inet banIP wan-input ip6 saddr @${feed} counter accept"
					fi
				fi
				if [ -z "${feed_direction##*forwardwan*}" ]; then
					if [ "${ban_allowlistonly}" = "1" ]; then
						printf "%s\n" "add rule inet banIP wan-forward ip6 saddr != @${feed} ${log_forwardwan} counter ${feed_target}"
					else
						printf "%s\n" "add rule inet banIP wan-forward ip6 saddr @${feed} counter accept"
					fi
				fi
				if [ -z "${feed_direction##*forwardlan*}" ]; then
					if [ "${ban_allowlistonly}" = "1" ]; then
						printf "%s\n" "add rule inet banIP lan-forward ip6 daddr != @${feed} ${log_forwardlan} counter ${feed_target}"
					else
						printf "%s\n" "add rule inet banIP lan-forward ip6 daddr @${feed} counter accept"
					fi
				fi
			fi
		} >"${tmp_nft}"
		: >"${tmp_flush}" >"${tmp_raw}" >"${tmp_file}"
		feed_rc="0"
	elif [ "${feed%v*}" = "blocklist" ]; then
		{
			printf "%s\n\n" "#!/usr/sbin/nft -f"
			[ -s "${tmp_flush}" ] && "${ban_catcmd}" "${tmp_flush}"
			if [ "${proto}" = "4MAC" ]; then
				"${ban_awkcmd}" '/^([0-9A-f]{2}:){5}[0-9A-f]{2}(\/([0-9]|[1-3][0-9]|4[0-8]))?([[:space:]]+([1-9][0-9]?[0-9]?\.){1}([0-9]{1,3}\.){2}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])(\/(1?[0-9]|2?[0-9]|3?[0-2]))?[[:space:]]*$|[[:space:]]+$|$)/{if(!$2)$2="0.0.0.0/0";if(!seen[$1]++)printf "%s . %s, ",tolower($1),$2}' "${ban_blocklist}" >"${tmp_file}"
				printf "%s\n" "add set inet banIP ${feed} { type ether_addr . ipv4_addr; flags interval; auto-merge; policy ${ban_nftpolicy}; $(f_getelements "${tmp_file}") }"
				[ -z "${feed_direction##*forwardlan*}" ] && printf "%s\n" "add rule inet banIP lan-forward ether saddr . ip saddr @${feed} counter goto reject-chain"
			elif [ "${proto}" = "6MAC" ]; then
				"${ban_awkcmd}" '/^([0-9A-f]{2}:){5}[0-9A-f]{2}(\/([0-9]|[1-3][0-9]|4[0-8]))?([[:space:]]+([0-9A-f]{0,4}:){1,7}[0-9A-f]{0,4}:?(\/(1?[0-2][0-8]|[0-9][0-9]))?[[:space:]]*$|[[:space:]]+$|$)/{if(!$2)$2="::/0";if(!seen[$1]++)printf "%s . %s, ",tolower($1),$2}' "${ban_blocklist}" >"${tmp_file}"
				printf "%s\n" "add set inet banIP ${feed} { type ether_addr . ipv6_addr; flags interval; auto-merge; policy ${ban_nftpolicy}; $(f_getelements "${tmp_file}") }"
				[ -z "${feed_direction##*forwardlan*}" ] && printf "%s\n" "add rule inet banIP lan-forward ether saddr . ip6 saddr @${feed} counter goto reject-chain"
			elif [ "${proto}" = "4" ]; then
				if [ "${ban_deduplicate}" = "1" ]; then
					"${ban_awkcmd}" '/^127\./{next}/^(([1-9][0-9]?[0-9]?\.){1}([0-9]{1,3}\.){2}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])(\/(1?[0-9]|2?[0-9]|3?[0-2]))?)([[:space:]].*|$)/{printf "%s,\n",$1}' "${ban_blocklist}" >"${tmp_raw}"
					"${ban_awkcmd}" 'NR==FNR{member[$0];next}!($0 in member)' "${ban_tmpfile}.deduplicate" "${tmp_raw}" 2>/dev/null >"${tmp_split}"
					"${ban_awkcmd}" 'BEGIN{FS="[ ,]"}NR==FNR{member[$1];next}!($1 in member)' "${ban_tmpfile}.deduplicate" "${ban_blocklist}" 2>/dev/null >"${tmp_raw}"
					"${ban_catcmd}" "${tmp_raw}" 2>/dev/null >"${ban_blocklist}"
				else
					"${ban_awkcmd}" '/^127\./{next}/^(([1-9][0-9]?[0-9]?\.){1}([0-9]{1,3}\.){2}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])(\/(1?[0-9]|2?[0-9]|3?[0-2]))?)([[:space:]].*|$)/{printf "%s,\n",$1}' "${ban_blocklist}" >"${tmp_split}"
				fi
				"${ban_awkcmd}" '{ORS=" ";print}' "${tmp_split}" 2>/dev/null >"${tmp_file}"
				printf "%s\n" "add set inet banIP ${feed} { type ipv4_addr; flags interval, timeout; auto-merge; policy ${ban_nftpolicy}; $(f_getelements "${tmp_file}") }"
				[ -z "${feed_direction##*input*}" ] && printf "%s\n" "add rule inet banIP wan-input ip saddr @${feed} ${log_input} counter ${feed_target}"
				[ -z "${feed_direction##*forwardwan*}" ] && printf "%s\n" "add rule inet banIP wan-forward ip saddr @${feed} ${log_forwardwan} counter ${feed_target}"
				[ -z "${feed_direction##*forwardlan*}" ] && printf "%s\n" "add rule inet banIP lan-forward ip daddr @${feed} ${log_forwardlan} counter goto reject-chain"
			elif [ "${proto}" = "6" ]; then
				if [ "${ban_deduplicate}" = "1" ]; then
					"${ban_awkcmd}" '!/^([0-9A-f]{2}:){5}[0-9A-f]{2}.*/{printf "%s\n",$1}' "${ban_blocklist}" |
						"${ban_awkcmd}" '/^(([0-9A-f]{0,4}:){1,7}[0-9A-f]{0,4}:?(\/(1?[0-2][0-8]|[0-9][0-9]))?)([[:space:]].*|$)/{printf "%s,\n",tolower($1)}' >"${tmp_raw}"
					"${ban_awkcmd}" 'NR==FNR{member[$0];next}!($0 in member)' "${ban_tmpfile}.deduplicate" "${tmp_raw}" 2>/dev/null >"${tmp_split}"
					"${ban_awkcmd}" 'BEGIN{FS="[ ,]"}NR==FNR{member[$1];next}!($1 in member)' "${ban_tmpfile}.deduplicate" "${ban_blocklist}" 2>/dev/null >"${tmp_raw}"
					"${ban_catcmd}" "${tmp_raw}" 2>/dev/null >"${ban_blocklist}"
				else
					"${ban_awkcmd}" '!/^([0-9A-f]{2}:){5}[0-9A-f]{2}.*/{printf "%s\n",$1}' "${ban_blocklist}" |
						"${ban_awkcmd}" '/^(([0-9A-f]{0,4}:){1,7}[0-9A-f]{0,4}:?(\/(1?[0-2][0-8]|[0-9][0-9]))?)([[:space:]].*|$)/{printf "%s,\n",tolower($1)}' >"${tmp_split}"
				fi
				"${ban_awkcmd}" '{ORS=" ";print}' "${tmp_split}" 2>/dev/null >"${tmp_file}"
				printf "%s\n" "add set inet banIP ${feed} { type ipv6_addr; flags interval, timeout; auto-merge; policy ${ban_nftpolicy}; $(f_getelements "${tmp_file}") }"
				[ -z "${feed_direction##*input*}" ] && printf "%s\n" "add rule inet banIP wan-input ip6 saddr @${feed} ${log_input} counter ${feed_target}"
				[ -z "${feed_direction##*forwardwan*}" ] && printf "%s\n" "add rule inet banIP wan-forward ip6 saddr @${feed} ${log_forwardwan} counter ${feed_target}"
				[ -z "${feed_direction##*forwardlan*}" ] && printf "%s\n" "add rule inet banIP lan-forward ip6 daddr @${feed} ${log_forwardlan} counter goto reject-chain"
			fi
		} >"${tmp_nft}"
		: >"${tmp_flush}" >"${tmp_raw}" >"${tmp_file}"
		feed_rc="0"

	# handle external feeds
	#
	elif [ "${restore_rc}" != "0" ] && [ "${feed_url}" != "local" ]; then
		# handle country downloads
		#
		if [ "${feed%v*}" = "country" ]; then
			for country in ${ban_country}; do
				feed_log="$("${ban_fetchcmd}" ${ban_fetchparm} "${tmp_raw}" "${feed_url}${country}-aggregated.zone" 2>&1)"
				feed_rc="${?}"
				[ "${feed_rc}" = "0" ] && "${ban_catcmd}" "${tmp_raw}" 2>/dev/null >>"${tmp_load}"
			done
			: >"${tmp_raw}"

		# handle asn downloads
		#
		elif [ "${feed%v*}" = "asn" ]; then
			for asn in ${ban_asn}; do
				feed_log="$("${ban_fetchcmd}" ${ban_fetchparm} "${tmp_raw}" "${feed_url}AS${asn}" 2>&1)"
				feed_rc="${?}"
				[ "${feed_rc}" = "0" ] && "${ban_catcmd}" "${tmp_raw}" 2>/dev/null >>"${tmp_load}"
			done
			: >"${tmp_raw}"

		# handle compressed downloads
		#
		elif [ "${feed_comp}" = "gz" ]; then
			feed_log="$("${ban_fetchcmd}" ${ban_fetchparm} "${tmp_raw}" "${feed_url}" 2>&1)"
			feed_rc="${?}"
			[ "${feed_rc}" = "0" ] && "${ban_zcatcmd}" "${tmp_raw}" 2>/dev/null >"${tmp_load}"
			: >"${tmp_raw}"

		# handle normal downloads
		#
		else
			feed_log="$("${ban_fetchcmd}" ${ban_fetchparm} "${tmp_load}" "${feed_url}" 2>&1)"
			feed_rc="${?}"
		fi
	fi
	[ "${feed_rc}" != "0" ] && f_log "info" "download for feed '${feed}' failed (rc: ${feed_rc:-"-"}/log: ${feed_log})"

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
		if [ "${ban_deduplicate}" = "1" ] && [ "${feed_url}" != "local" ]; then
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
					f_log "info" "can't split Set '${feed}' to size '${ban_splitsize//[![:digit:]]/}'"
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
					# nft header (IPv4 Set) input and forward rules
					#
					printf "%s\n\n" "#!/usr/sbin/nft -f"
					[ -s "${tmp_flush}" ] && "${ban_catcmd}" "${tmp_flush}"
					printf "%s\n" "add set inet banIP ${feed} { type ipv4_addr; flags interval; auto-merge; policy ${ban_nftpolicy}; $(f_getelements "${tmp_file}.1") }"
					[ -z "${feed_direction##*input*}" ] && printf "%s\n" "add rule inet banIP wan-input ${feed_dport} ip saddr @${feed} ${log_input} counter ${feed_target}"
					[ -z "${feed_direction##*forwardwan*}" ] && printf "%s\n" "add rule inet banIP wan-forward ${feed_dport} ip saddr @${feed} ${log_forwardwan} counter ${feed_target}"
					[ -z "${feed_direction##*forwardlan*}" ] && printf "%s\n" "add rule inet banIP lan-forward ${feed_dport} ip daddr @${feed} ${log_forwardlan} counter goto reject-chain"
				} >"${tmp_nft}"
			elif [ "${proto}" = "6" ]; then
				{
					# nft header (IPv6 Set) plus input and forward rules
					#
					printf "%s\n\n" "#!/usr/sbin/nft -f"
					[ -s "${tmp_flush}" ] && "${ban_catcmd}" "${tmp_flush}"
					printf "%s\n" "add set inet banIP ${feed} { type ipv6_addr; flags interval; auto-merge; policy ${ban_nftpolicy}; $(f_getelements "${tmp_file}.1") }"
					[ -z "${feed_direction##*input*}" ] && printf "%s\n" "add rule inet banIP wan-input ${feed_dport} ip6 saddr @${feed} ${log_input} counter ${feed_target}"
					[ -z "${feed_direction##*forwardwan*}" ] && printf "%s\n" "add rule inet banIP wan-forward ${feed_dport} ip6 saddr @${feed} ${log_forwardwan} counter ${feed_target}"
					[ -z "${feed_direction##*forwardlan*}" ] && printf "%s\n" "add rule inet banIP lan-forward ${feed_dport} ip6 daddr @${feed} ${log_forwardlan} counter goto reject-chain"
				} >"${tmp_nft}"
			fi
		fi
		: >"${tmp_flush}" >"${tmp_file}.1"
	fi

	# load generated nft file in banIP table
	#
	if [ "${feed_rc}" = "0" ]; then
		if [ "${feed%v*}" = "allowlist" ]; then
			cnt_dl="$("${ban_awkcmd}" 'END{printf "%d",NR}' "${tmp_allow}" 2>/dev/null)"
		else
			cnt_dl="$("${ban_awkcmd}" 'END{printf "%d",NR}' "${tmp_split}" 2>/dev/null)"
			: >"${tmp_split}"
		fi
		if [ "${cnt_dl:-"0"}" -gt "0" ] || [ "${feed_url}" = "local" ] || [ "${feed%v*}" = "allowlist" ] || [ "${feed%v*}" = "blocklist" ]; then
			feed_log="$("${ban_nftcmd}" -f "${tmp_nft}" 2>&1)"
			feed_rc="${?}"

			# load additional split files
			#
			if [ "${feed_rc}" = "0" ]; then
				for split_file in "${tmp_file}".*; do
					if [ -s "${split_file}" ]; then
						"${ban_sedcmd}" -i "1 i #!/usr/sbin/nft -f\nadd element inet banIP "${feed}" { " "${split_file}"
						printf "%s\n" "}" >>"${split_file}"
						if ! "${ban_nftcmd}" -f "${split_file}" >/dev/null 2>&1; then
							f_log "info" "can't add split file '${split_file##*.}' to Set '${feed}'"
						fi
						: >"${split_file}"
					fi
				done
				if [ "${ban_debug}" = "1" ] && [ "${ban_reportelements}" = "1" ]; then
					cnt_set="$("${ban_nftcmd}" -j list set inet banIP "${feed}" 2>/dev/null | "${ban_jsoncmd}" -qe '@.nftables[*].set.elem[*]' | wc -l 2>/dev/null)"
				fi
			else
				f_log "info" "can't initialize Set for feed '${feed}' (rc: ${feed_rc}, log: ${feed_log})"
			fi
		else
			f_log "info" "skip empty feed '${feed}'"
		fi
	fi
	: >"${tmp_nft}"
	end_ts="$(date +%s)"

	f_log "debug" "f_down      ::: feed: ${feed}, cnt_dl: ${cnt_dl:-"-"}, cnt_set: ${cnt_set:-"-"}, split_size: ${ban_splitsize:-"-"}, time: $((end_ts - start_ts)), rc: ${feed_rc:-"-"}, log: ${feed_log:-"-"}"
}

# backup feeds
#
f_backup() {
	local backup_rc="4" feed="${1}" feed_file="${2}"

	if [ -s "${feed_file}" ]; then
		gzip -cf "${feed_file}" >"${ban_backupdir}/banIP.${feed}.gz"
		backup_rc="${?}"
	fi

	f_log "debug" "f_backup    ::: feed: ${feed}, file: banIP.${feed}.gz, rc: ${backup_rc}"
	return "${backup_rc}"
}

# restore feeds
#
f_restore() {
	local tmp_feed restore_rc="4" feed="${1}" feed_url="${2}" feed_file="${3}" in_rc="${4}"

	[ "${feed_url}" = "local" ] && tmp_feed="${feed%v*}v4" || tmp_feed="${feed}"
	if [ -s "${ban_backupdir}/banIP.${tmp_feed}.gz" ]; then
		"${ban_zcatcmd}" "${ban_backupdir}/banIP.${tmp_feed}.gz" 2>/dev/null >"${feed_file}"
		restore_rc="${?}"
	fi

	f_log "debug" "f_restore   ::: feed: ${feed}, file: banIP.${tmp_feed}.gz, in_rc: ${in_rc:-"-"}, rc: ${restore_rc}"
	return "${restore_rc}"
}

# remove disabled Sets
#
f_rmset() {
	local expr feedlist tmp_del ruleset_raw item table_sets handle del_set feed_log feed_rc

	f_getfeed
	json_get_keys feedlist
	tmp_del="${ban_tmpfile}.final.delete"
	ruleset_raw="$("${ban_nftcmd}" -tj list ruleset 2>/dev/null)"
	table_sets="$(printf "%s\n" "${ruleset_raw}" | "${ban_jsoncmd}" -qe '@.nftables[@.set.table="banIP"&&@.set.family="inet"].set.name')"
	{
		printf "%s\n\n" "#!/usr/sbin/nft -f"
		for item in ${table_sets}; do
			if ! printf "%s" "allowlist blocklist ${ban_feed}" | "${ban_grepcmd}" -q "${item%v*}" ||
				! printf "%s" "allowlist blocklist ${feedlist}" | "${ban_grepcmd}" -q "${item%v*}"; then
				[ -z "${del_set}" ] && del_set="${item}" || del_set="${del_set}, ${item}"
				rm -f "${ban_backupdir}/banIP.${item}.gz"
				printf "%s\n" "flush set inet banIP ${item}"
				for expr in 0 1; do
					handle="$(printf "%s\n" "${ruleset_raw}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.table=\"banIP\"&&@.rule.chain=\"wan-input\"][@.expr[${expr}].match.right=\"@${item}\"].handle")"
					[ -n "${handle}" ] && printf "%s\n" "delete rule inet banIP wan-input handle ${handle}"
					handle="$(printf "%s\n" "${ruleset_raw}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.table=\"banIP\"&&@.rule.chain=\"wan-forward\"][@.expr[${expr}].match.right=\"@${item}\"].handle")"
					[ -n "${handle}" ] && printf "%s\n" "delete rule inet banIP wan-forward handle ${handle}"
					handle="$(printf "%s\n" "${ruleset_raw}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.table=\"banIP\"&&@.rule.chain=\"lan-forward\"][@.expr[${expr}].match.right=\"@${item}\"].handle")"
					[ -n "${handle}" ] && printf "%s\n" "delete rule inet banIP lan-forward handle ${handle}"
				done
				printf "%s\n\n" "delete set inet banIP ${item}"
			fi
		done
	} >"${tmp_del}"

	if [ -n "${del_set}" ]; then
		feed_log="$("${ban_nftcmd}" -f "${tmp_del}" 2>&1)"
		feed_rc="${?}"
	fi
	: >"${tmp_del}"

	f_log "debug" "f_rmset     ::: Set: ${del_set:-"-"}, rc: ${feed_rc:-"-"}, log: ${feed_log:-"-"}"
}

# generate status information
#
f_genstatus() {
	local object end_time duration table_sets cnt_elements="0" custom_feed="0" split="0" status="${1}"

	[ -z "${ban_dev}" ] && f_conf
	if [ "${status}" = "active" ]; then
		if [ -n "${ban_starttime}" ] && [ "${ban_action}" != "boot" ]; then
			end_time="$(date "+%s")"
			duration="$(((end_time - ban_starttime) / 60))m $(((end_time - ban_starttime) % 60))s"
		fi
		table_sets="$("${ban_nftcmd}" -tj list ruleset 2>/dev/null | "${ban_jsoncmd}" -qe '@.nftables[@.set.table="banIP"&&@.set.family="inet"].set.name')"
		if [ "${ban_reportelements}" = "1" ]; then
			for object in ${table_sets}; do
				cnt_elements="$((cnt_elements + $("${ban_nftcmd}" -j list set inet banIP "${object}" 2>/dev/null | "${ban_jsoncmd}" -qe '@.nftables[*].set.elem[*]' | wc -l 2>/dev/null)))"
			done
		fi
		runtime="action: ${ban_action:-"-"}, log: ${ban_logreadcmd##*/}, fetch: ${ban_fetchcmd##*/}, duration: ${duration:-"-"}, date: $(date "+%Y-%m-%d %H:%M:%S")"
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
	json_add_string "nft_info" "priority: ${ban_nftpriority}, policy: ${ban_nftpolicy}, loglevel: ${ban_nftloglevel}, expiry: ${ban_nftexpiry:-"-"}, limit (icmp/syn/udp): ${ban_icmplimit}/${ban_synlimit}/${ban_udplimit}"
	json_add_string "run_info" "base: ${ban_basedir}, backup: ${ban_backupdir}, report: ${ban_reportdir}"
	json_add_string "run_flags" "auto: $(f_char ${ban_autodetect}), proto (4/6): $(f_char ${ban_protov4})/$(f_char ${ban_protov6}), log (pre/inp/fwd/lan): $(f_char ${ban_logprerouting})/$(f_char ${ban_loginput})/$(f_char ${ban_logforwardwan})/$(f_char ${ban_logforwardlan}), dedup: $(f_char ${ban_deduplicate}), split: $(f_char ${split}), custom feed: $(f_char ${custom_feed}), allowed only: $(f_char ${ban_allowlistonly})"
	json_add_string "last_run" "${runtime:-"-"}"
	json_add_string "system_info" "cores: ${ban_cores}, memory: ${ban_memory}, device: ${ban_sysver}"
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
					printf "%-42s%s\n" "${ip}" "# '${domain}' added on $(date "+%Y-%m-%d %H:%M:%S")" >>"${ban_allowlist}"
				elif [ "${feed}" = "blocklist" ] && [ "${ban_autoblocklist}" = "1" ] && ! "${ban_grepcmd}" -q "^${ip}[[:space:]]*#" "${ban_blocklist}"; then
					printf "%-42s%s\n" "${ip}" "# '${domain}' added on $(date "+%Y-%m-%d %H:%M:%S")" >>"${ban_blocklist}"
				fi
				cnt_ip="$((cnt_ip + 1))"
			fi
		done
		cnt_domain="$((cnt_domain + 1))"
	done
	if [ -n "${elementsv4}" ]; then
		if ! "${ban_nftcmd}" add element inet banIP "${feed}v4" { ${elementsv4} } >/dev/null 2>&1; then
			f_log "info" "can't add lookup file to Set '${feed}v4'"
		fi
	fi
	if [ -n "${elementsv6}" ]; then
		if ! "${ban_nftcmd}" add element inet banIP "${feed}v6" { ${elementsv6} } >/dev/null 2>&1; then
			f_log "info" "can't add lookup file to Set '${feed}v6'"
		fi
	fi
	end_time="$(date "+%s")"
	duration="$(((end_time - start_time) / 60))m $(((end_time - start_time) % 60))s"

	f_log "info" "domain lookup finished in ${duration} (${feed}, ${cnt_domain} domains, ${cnt_ip} IPs)"
}

# table statistics
#
f_report() {
	local report_jsn report_txt tmp_val ruleset_raw item table_sets set_cnt set_input set_forwardwan set_forwardlan set_cntinput set_cntforwardwan set_cntforwardlan set_proto set_dport set_details
	local expr detail jsnval timestamp autoadd_allow autoadd_block sum_sets sum_setinput sum_setforwardwan sum_setforwardlan sum_setelements sum_cntinput sum_cntforwardwan sum_cntforwardlan
	local sum_synflood sum_udpflood sum_icmpflood sum_ctinvalid sum_tcpinvalid output="${1}"

	[ -z "${ban_dev}" ] && f_conf
	f_mkdir "${ban_reportdir}"
	report_jsn="${ban_reportdir}/ban_report.jsn"
	report_txt="${ban_reportdir}/ban_report.txt"

	# json output preparation
	#
	ruleset_raw="$("${ban_nftcmd}" -tj list ruleset 2>/dev/null)"
	table_sets="$(printf "%s" "${ruleset_raw}" | "${ban_jsoncmd}" -qe '@.nftables[@.set.table="banIP"&&@.set.family="inet"].set.name')"
	sum_sets="0"
	sum_setinput="0"
	sum_setforwardwan="0"
	sum_setforwardlan="0"
	sum_setelements="0"
	sum_cntinput="0"
	sum_cntforwardwan="0"
	sum_cntforwardlan="0"
	sum_synflood="$(printf "%s" "${ruleset_raw}" | "${ban_jsoncmd}" -qe '@.nftables[@.counter.name="cnt-synflood"].*.packets')"
	sum_udpflood="$(printf "%s" "${ruleset_raw}" | "${ban_jsoncmd}" -qe '@.nftables[@.counter.name="cnt-udpflood"].*.packets')"
	sum_icmpflood="$(printf "%s" "${ruleset_raw}" | "${ban_jsoncmd}" -qe '@.nftables[@.counter.name="cnt-icmpflood"].*.packets')"
	sum_ctinvalid="$(printf "%s" "${ruleset_raw}" | "${ban_jsoncmd}" -qe '@.nftables[@.counter.name="cnt-ctinvalid"].*.packets')"
	sum_tcpinvalid="$(printf "%s" "${ruleset_raw}" | "${ban_jsoncmd}" -qe '@.nftables[@.counter.name="cnt-tcpinvalid"].*.packets')"
	timestamp="$(date "+%Y-%m-%d %H:%M:%S")"
	: >"${report_jsn}"
	{
		printf "%s\n" "{"
		printf "\t%s\n" '"sets":{'
		for item in ${table_sets}; do
			set_cntinput=""
			set_cntforwardwan=""
			set_cntforwardlan=""
			set_proto=""
			set_dport=""
			for expr in 0 1; do
				[ -z "${set_cntinput}" ] && set_cntinput="$(printf "%s" "${ruleset_raw}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.table=\"banIP\"&&@.rule.chain=\"wan-input\"][@.expr[${expr}].match.right=\"@${item}\"].expr[*].counter.packets")"
				[ "${expr}" = "1" ] && [ -z "${set_dport}" ] && set_dport="$(printf "%s" "${ruleset_raw}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.table=\"banIP\"&&@.rule.chain=\"wan-input\"][@.expr[${expr}].match.right=\"@${item}\"].expr[*].match.right.set")"
				[ "${expr}" = "1" ] && [ -z "${set_proto}" ] && set_proto="$(printf "%s" "${ruleset_raw}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.table=\"banIP\"&&@.rule.chain=\"wan-input\"][@.expr[${expr}].match.right=\"@${item}\"].expr[*].match.left.payload.protocol")"
				[ -z "${set_cntforwardwan}" ] && set_cntforwardwan="$(printf "%s" "${ruleset_raw}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.table=\"banIP\"&&@.rule.chain=\"wan-forward\"][@.expr[${expr}].match.right=\"@${item}\"].expr[*].counter.packets")"
				[ "${expr}" = "1" ] && [ -z "${set_dport}" ] && set_dport="$(printf "%s" "${ruleset_raw}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.table=\"banIP\"&&@.rule.chain=\"wan-forward\"][@.expr[${expr}].match.right=\"@${item}\"].expr[*].match.right.set")"
				[ "${expr}" = "1" ] && [ -z "${set_proto}" ] && set_proto="$(printf "%s" "${ruleset_raw}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.table=\"banIP\"&&@.rule.chain=\"wan-forward\"][@.expr[${expr}].match.right=\"@${item}\"].expr[*].match.left.payload.protocol")"
				[ -z "${set_cntforwardlan}" ] && set_cntforwardlan="$(printf "%s" "${ruleset_raw}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.table=\"banIP\"&&@.rule.chain=\"lan-forward\"][@.expr[${expr}].match.right=\"@${item}\"].expr[*].counter.packets")"
				[ "${expr}" = "1" ] && [ -z "${set_dport}" ] && set_dport="$(printf "%s" "${ruleset_raw}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.table=\"banIP\"&&@.rule.chain=\"lan-forward\"][@.expr[${expr}].match.right=\"@${item}\"].expr[*].match.right.set")"
				[ "${expr}" = "1" ] && [ -z "${set_proto}" ] && set_proto="$(printf "%s" "${ruleset_raw}" | "${ban_jsoncmd}" -ql1 -e "@.nftables[@.rule.table=\"banIP\"&&@.rule.chain=\"lan-forward\"][@.expr[${expr}].match.right=\"@${item}\"].expr[*].match.left.payload.protocol")"
			done
			if [ "${ban_reportelements}" = "1" ]; then
				set_cnt="$("${ban_nftcmd}" -j list set inet banIP "${item}" 2>/dev/null | "${ban_jsoncmd}" -qe '@.nftables[*].set.elem[*]' | wc -l 2>/dev/null)"
				sum_setelements="$((sum_setelements + set_cnt))"
			else
				set_cnt=""
				sum_setelements="n/a"
			fi
			if [ -n "${set_dport}" ]; then
				set_dport="${set_dport//[\{\}\":]/}"
				set_dport="${set_dport#\[ *}"
				set_dport="${set_dport%* \]}"
				set_dport="${set_proto}: $(f_trim "${set_dport}")"
			fi
			if [ -n "${set_cntinput}" ]; then
				set_input="ON"
				sum_setinput="$((sum_setinput + 1))"
				sum_cntinput="$((sum_cntinput + set_cntinput))"
			else
				set_input="-"
				set_cntinput=""
			fi
			if [ -n "${set_cntforwardwan}" ]; then
				set_forwardwan="ON"
				sum_setforwardwan="$((sum_setforwardwan + 1))"
				sum_cntforwardwan="$((sum_cntforwardwan + set_cntforwardwan))"
			else
				set_forwardwan="-"
				set_cntforwardwan=""
			fi
			if [ -n "${set_cntforwardlan}" ]; then
				set_forwardlan="ON"
				sum_setforwardlan="$((sum_setforwardlan + 1))"
				sum_cntforwardlan="$((sum_cntforwardlan + set_cntforwardlan))"
			else
				set_forwardlan="-"
				set_cntforwardlan=""
			fi
			[ "${sum_sets}" -gt "0" ] && printf "%s\n" ","
			printf "\t\t%s\n" "\"${item}\":{"
			printf "\t\t\t%s\n" "\"cnt_elements\": \"${set_cnt}\","
			printf "\t\t\t%s\n" "\"cnt_input\": \"${set_cntinput}\","
			printf "\t\t\t%s\n" "\"input\": \"${set_input}\","
			printf "\t\t\t%s\n" "\"cnt_forwardwan\": \"${set_cntforwardwan}\","
			printf "\t\t\t%s\n" "\"wan_forward\": \"${set_forwardwan}\","
			printf "\t\t\t%s\n" "\"cnt_forwardlan\": \"${set_cntforwardlan}\","
			printf "\t\t\t%s\n" "\"lan_forward\": \"${set_forwardlan}\"",
			printf "\t\t\t%s\n" "\"port\": \"${set_dport:-"-"}\""
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
		printf "\t%s\n" "\"sum_setinput\": \"${sum_setinput}\","
		printf "\t%s\n" "\"sum_setforwardwan\": \"${sum_setforwardwan}\","
		printf "\t%s\n" "\"sum_setforwardlan\": \"${sum_setforwardlan}\","
		printf "\t%s\n" "\"sum_setelements\": \"${sum_setelements}\","
		printf "\t%s\n" "\"sum_cntinput\": \"${sum_cntinput}\","
		printf "\t%s\n" "\"sum_cntforwardwan\": \"${sum_cntforwardwan}\","
		printf "\t%s\n" "\"sum_cntforwardlan\": \"${sum_cntforwardlan}\""
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
			json_get_var sum_setinput "sum_setinput" >/dev/null 2>&1
			json_get_var sum_setforwardwan "sum_setforwardwan" >/dev/null 2>&1
			json_get_var sum_setforwardlan "sum_setforwardlan" >/dev/null 2>&1
			json_get_var sum_setelements "sum_setelements" >/dev/null 2>&1
			json_get_var sum_cntinput "sum_cntinput" >/dev/null 2>&1
			json_get_var sum_cntforwardwan "sum_cntforwardwan" >/dev/null 2>&1
			json_get_var sum_cntforwardlan "sum_cntforwardlan" >/dev/null 2>&1
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
					printf "%-25s%-15s%-24s%-24s%-24s%s\n" "    Set" "| Elements" "| WAN-Input (packets)" "| WAN-Forward (packets)" "| LAN-Forward (packets)" "| Port/Protocol Limit"
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
								"cnt_input" | "cnt_forwardwan" | "cnt_forwardlan")
									[ -n "${jsnval}" ] && tmp_val=": ${jsnval}"
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
					printf "%-25s%-15s%-24s%-24s%s\n" "    ${sum_sets}" "| ${sum_setelements}" "| ${sum_setinput} (${sum_cntinput})" "| ${sum_setforwardwan} (${sum_cntforwardwan})" "| ${sum_setforwardlan} (${sum_cntforwardlan})"
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
	local item table_sets ip proto hold cnt result_flag="/var/run/banIP.search" input="${1}"

	if [ -n "${input}" ]; then
		ip="$(printf "%s" "${input}" | "${ban_awkcmd}" 'BEGIN{RS="(([1-9][0-9]{0,2}\\.){1}([0-9]{1,3}\\.){2}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])(\\/(1?[0-9]|2?[0-9]|3?[0-2]))?[[:space:]]*$)"}{printf "%s",RT}')"
		[ -n "${ip}" ] && proto="v4"
		if [ -z "${proto}" ]; then
			ip="$(printf "%s" "${input}" | "${ban_awkcmd}" 'BEGIN{RS="(([0-9A-f]{0,4}:){1,7}[0-9A-f]{0,4}:?(\\/(1?[0-2][0-8]|[0-9][0-9]))?)([[:space:]].*|$)"}{printf "%s",RT}')"
			[ -n "${ip}" ] && proto="v6"
		fi
	fi
	if [ -n "${proto}" ]; then
		table_sets="$("${ban_nftcmd}" -tj list ruleset 2>/dev/null | "${ban_jsoncmd}" -qe "@.nftables[@.set.table=\"banIP\"&&@.set.type=\"ip${proto}_addr\"].set.name")"
	else
		printf "%s\n%s\n%s\n" ":::" "::: no valid search input" ":::"
		return
	fi
	cnt="1"
	for item in ${table_sets}; do
		[ -f "${result_flag}" ] && break
		(
			if "${ban_nftcmd}" get element inet banIP "${item}" "{ ${ip} }" >/dev/null 2>&1; then
				printf "%s\n%s\n%s\n" ":::" "::: banIP Search" ":::"
				printf "    %s\n" "Looking for IP '${ip}' on $(date "+%Y-%m-%d %H:%M:%S")"
				printf "    %s\n" "---"
				printf "    %s\n" "IP found in Set '${item}'"
				: >"${result_flag}"
			fi
		) &
		hold="$((cnt % ban_cores))"
		[ "${hold}" = "0" ] && wait
		cnt="$((cnt + 1))"
	done
	wait
	if [ -f "${result_flag}" ]; then
		rm -f "${result_flag}"
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
	elif printf "%s" "${ban_packages}" | "${ban_grepcmd}" -q '"logd'; then
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
				[ -n "${ip}" ] && [ "${ip%%.*}" != "127" ] && [ "${ip%%.*}" != "0" ] && proto="v4"
				if [ -z "${proto}" ]; then
					if [ "${daemon}" = "dropbear" ]; then
						ip="$(printf "%s" "${line}" | "${ban_awkcmd}" 'BEGIN{RS="([A-Fa-f0-9]{1,4}::?){3,7}([A-Fa-f0-9]:?)+"}{if(!seen[RT]++)printf "%s ",RT}')"
						ip="${ip%:*}"
					else
						ip="$(printf "%s" "${line}" | "${ban_awkcmd}" 'BEGIN{RS="([A-Fa-f0-9]{1,4}::?){3,7}[A-Fa-f0-9]{1,4}"}{if(!seen[RT]++)printf "%s ",RT}')"
					fi
					ip="$(f_trim "${ip}")"
					ip="${ip##* }"
					[ -n "${ip%%::*}" ] && proto="v6"
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
								[ "${proto}" = "v4" ] && rdap_idx="$("${ban_jsoncmd}" -i "${ban_rdapfile}" -qe '@.cidr0_cidrs[@.v4prefix].*' | "${ban_awkcmd}" '{ORS=" "; print}')"
								[ "${proto}" = "v6" ] && rdap_idx="$("${ban_jsoncmd}" -i "${ban_rdapfile}" -qe '@.cidr0_cidrs[@.v6prefix].*' | "${ban_awkcmd}" '{ORS=" "; print}')"
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
							printf "%-42s%s\n" "${ip}" "# added on $(date "+%Y-%m-%d %H:%M:%S")" >>"${ban_blocklist}"
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

f_system
if [ "${ban_action}" != "stop" ]; then
	[ ! -d "/etc/banip" ] && f_log "err" "no banIP config directory"
	[ ! -r "/etc/config/banip" ] && f_log "err" "no banIP config"
	[ "$(uci_get banip global ban_enabled)" = "0" ] && f_log "err" "banIP is disabled"
fi
