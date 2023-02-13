# banIP shared function library/include
# Copyright (c) 2018-2023 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# (s)hellcheck exceptions
# shellcheck disable=all

# set initial defaults
#
export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

ban_basedir="/tmp"
ban_backupdir="${ban_basedir}/banIP-backup"
ban_reportdir="${ban_basedir}/banIP-report"
ban_feedarchive="/etc/banip/banip.feeds.gz"
ban_pidfile="/var/run/banip.pid"
ban_lock="/var/run/banip.lock"
ban_blocklist="/etc/banip/banip.blocklist"
ban_allowlist="/etc/banip/banip.allowlist"
ban_fetchcmd=""
ban_logreadcmd="$(command -v logread)"
ban_logcmd="$(command -v logger)"
ban_ubuscmd="$(command -v ubus)"
ban_nftcmd="$(command -v nft)"
ban_fw4cmd="$(command -v fw4)"
ban_awkcmd="$(command -v awk)"
ban_grepcmd="$(command -v grep)"
ban_lookupcmd="$(command -v nslookup)"
ban_mailcmd="$(command -v msmtp)"
ban_mailsender="no-reply@banIP"
ban_mailreceiver=""
ban_mailtopic="banIP notification"
ban_mailprofile="ban_notify"
ban_mailtemplate="/etc/banip/banip.tpl"
ban_nftpriority="-200"
ban_nftexpiry=""
ban_loglevel="warn"
ban_loglimit="100"
ban_logcount="1"
ban_logterm=""
ban_country=""
ban_asn=""
ban_loginput="0"
ban_logforward="0"
ban_allowlistonly="0"
ban_autoallowlist="1"
ban_autoblocklist="1"
ban_deduplicate="1"
ban_splitsize="0"
ban_autodetect=""
ban_feed=""
ban_blockinput=""
ban_blockforward=""
ban_protov4="0"
ban_protov6="0"
ban_ifv4=""
ban_ifv6=""
ban_dev=""
ban_sub=""
ban_fetchinsecure=""
ban_cores=""
ban_memory=""
ban_trigger=""
ban_triggerdelay="10"
ban_resolver=""
ban_enabled="0"
ban_debug="0"

# gather system information
#
f_system() {
	local cpu core

	ban_memory="$("${ban_awkcmd}" '/^MemAvailable/{printf "%s",int($2/1000)}' "/proc/meminfo" 2>/dev/null)"
	ban_ver="$(${ban_ubuscmd} -S call rpc-sys packagelist 2>/dev/null | jsonfilter -ql1 -e '@.packages.banip')"
	ban_sysver="$(${ban_ubuscmd} -S call system board 2>/dev/null | jsonfilter -ql1 -e '@.model' -e '@.release.description' |
		"${ban_awkcmd}" 'BEGIN{RS="";FS="\n"}{printf "%s, %s",$1,$2}')"
	if [ -z "${ban_cores}" ]; then
		cpu="$("${ban_grepcmd}" -c '^processor' /proc/cpuinfo 2>/dev/null)"
		core="$("${ban_grepcmd}" -cm1 '^core id' /proc/cpuinfo 2>/dev/null)"
		[ "${cpu}" = "0" ] && cpu="1"
		[ "${core}" = "0" ] && core="1"
		ban_cores="$((cpu * core))"
	fi

	f_log "debug" "f_system  ::: system: ${ban_sysver:-"n/a"}, version: ${ban_ver:-"n/a"}, memory: ${ban_memory:-"0"}, cpu_cores: ${ban_cores}"
}

# create directories
#
f_mkdir() {
	local dir="${1}"

	if [ ! -d "${dir}" ]; then
		rm -f "${dir}"
		mkdir -p "${dir}"
		f_log "debug" "f_mkdir   ::: created directory: ${dir}"
	fi
}

# create files
#
f_mkfile() {
	local file="${1}"

	if [ ! -f "${file}" ]; then
		: >"${file}"
		f_log "debug" "f_mkfile  ::: created file: ${file}"
	fi
}

# create temporary files and directories
#
f_tmp() {
	f_mkdir "${ban_basedir}"
	ban_tmpdir="$(mktemp -p "${ban_basedir}" -d)"
	ban_tmpfile="$(mktemp -p "${ban_tmpdir}" -tu)"

	f_log "debug" "f_tmp     ::: base_dir: ${ban_basedir:-"-"}, tmp_dir: ${ban_tmpdir:-"-"}"
}

# remove directories
#
f_rmdir() {
	local dir="${1}"

	if [ -d "${dir}" ]; then
		rm -rf "${dir}"
		f_log "debug" "f_rmdir   ::: deleted directory: ${dir}"
	fi
}

# convert chars
#
f_char() {
	local char="${1}"

	[ "${char}" = "1" ] && printf "%s" "✔" || printf "%s" "✘"
}

# trim strings
#
f_trim() {
	local string="${1}"

	string="${string#"${string%%[![:space:]]*}"}"
	string="${string%"${string##*[![:space:]]}"}"
	printf "%s" "${string}"
}

# write log messages
#
f_log() {
	local class="${1}" log_msg="${2}"

	if [ -n "${log_msg}" ] && { [ "${class}" != "debug" ] || [ "${ban_debug}" = "1" ]; }; then
		if [ -x "${ban_logcmd}" ]; then
			"${ban_logcmd}" -p "${class}" -t "banIP-${ban_ver}[${$}]" "${log_msg}"
		else
			printf "%s %s %s\n" "${class}" "banIP-${ban_ver}[${$}]" "${log_msg}"
		fi
	fi
	if [ "${class}" = "err" ]; then
		f_genstatus "error"
		f_rmdir "${ban_tmpdir}"
		rm -rf "${ban_lock}"
		exit 1
	fi
}

# load config
#
f_conf() {
	unset ban_dev ban_ifv4 ban_ifv6 ban_feed ban_blockinput ban_blockforward ban_logterm ban_country ban_asn
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
				"ban_dev")
					eval "${option}=\"$(printf "%s" "${ban_dev}")${value} \""
					;;
				"ban_ifv4")
					eval "${option}=\"$(printf "%s" "${ban_ifv4}")${value} \""
					;;
				"ban_ifv6")
					eval "${option}=\"$(printf "%s" "${ban_ifv6}")${value} \""
					;;
				"ban_feed")
					eval "${option}=\"$(printf "%s" "${ban_feed}")${value} \""
					;;
				"ban_blockinput")
					eval "${option}=\"$(printf "%s" "${ban_blockinput}")${value} \""
					;;
				"ban_blockforward")
					eval "${option}=\"$(printf "%s" "${ban_blockforward}")${value} \""
					;;
				"ban_logterm")
					eval "${option}=\"$(printf "%s" "${ban_logterm}")${value}\\|\""
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

	[ "${ban_action}" = "boot" ] && [ -z "${ban_trigger}" ] && sleep ${ban_triggerdelay}
}

# prepare fetch utility
#
f_fetch() {
	local ut utils packages insecure

	if [ -z "${ban_fetchcmd}" ] || [ ! -x "${ban_fetchcmd}" ]; then
		packages="$(${ban_ubuscmd} -S call rpc-sys packagelist 2>/dev/null)"
		[ -z "${packages}" ] && f_log "err" "local opkg package repository is not available, please set the download utility 'ban_fetchcmd' manually"
		utils="aria2c curl wget uclient-fetch"
		for ut in ${utils}; do
			if { [ "${ut}" = "uclient-fetch" ] && printf "%s" "${packages}" | "${ban_grepcmd}" -q '"libustream-'; } ||
				{ [ "${ut}" = "wget" ] && printf "%s" "${packages}" | "${ban_grepcmd}" -q '"wget-ssl'; } ||
				[ "${ut}" = "curl" ] || [ "${ut}" = "aria2c" ]; then
				ban_fetchcmd="$(command -v "${ut}")"
				if [ -x "${ban_fetchcmd}" ]; then
					uci_set banip global ban_fetchcmd "${ban_fetchcmd##*/}"
					uci_commit "banip"
					break
				fi
			fi
		done
	fi
	[ ! -x "${ban_fetchcmd}" ] && f_log "err" "download utility with SSL support not found"
	case "${ban_fetchcmd##*/}" in
		"aria2c")
			[ "${ban_fetchinsecure}" = "1" ] && insecure="--check-certificate=false"
			ban_fetchparm="${ban_fetchparm:-"${insecure} --timeout=20 --allow-overwrite=true --auto-file-renaming=false --log-level=warn --dir=/ -o"}"
			;;
		"curl")
			[ "${ban_fetchinsecure}" = "1" ] && insecure="--insecure"
			ban_fetchparm="${ban_fetchparm:-"${insecure} --connect-timeout 20 --fail --silent --show-error --location -o"}"
			;;
		"uclient-fetch")
			[ "${ban_fetchinsecure}" = "1" ] && insecure="--no-check-certificate"
			ban_fetchparm="${ban_fetchparm:-"${insecure} --timeout=20 -O"}"
			;;
		"wget")
			[ "${ban_fetchinsecure}" = "1" ] && insecure="--no-check-certificate"
			ban_fetchparm="${ban_fetchparm:-"${insecure} --no-cache --no-cookies --max-redirect=0 --timeout=20 -O"}"
			;;
	esac

	f_log "debug" "f_fetch   ::: fetch_cmd: ${ban_fetchcmd:-"-"}, fetch_parm: ${ban_fetchparm:-"-"}"
}

# remove logservice
#
f_rmpid() {
	local ppid pid pids

	ppid="$(cat "${ban_pidfile}" 2>/dev/null)"
	[ -n "${ppid}" ] && pids="$(pgrep -P "${ppid}" 2>/dev/null)" || return 0
	for pid in ${pids}; do
		kill -INT "${pid}" >/dev/null 2>&1
	done
	: >"${ban_pidfile}"
}

# get wan interfaces
#
f_getif() {
	local iface

	"${ban_ubuscmd}" -t 5 wait_for network.device network.interface 2>/dev/null
	if [ "${ban_autodetect}" = "1" ]; then
		if [ -z "${ban_ifv4}" ]; then
			network_find_wan iface
			if [ -n "${iface}" ] && ! printf "%s" "${ban_ifv4}" | "${ban_grepcmd}" -q "${iface}"; then
				ban_protov4="1"
				ban_ifv4="${ban_ifv4}${iface} "
				uci_set banip global ban_protov4 "1"
				uci_add_list banip global ban_ifv4 "${iface}"
			fi
		fi
		if [ -z "${ban_ifv6}" ]; then
			network_find_wan6 iface
			if [ -n "${iface}" ] && ! printf "%s" "${ban_ifv6}" | "${ban_grepcmd}" -q "${iface}"; then
				ban_protov6="1"
				ban_ifv6="${ban_ifv6}${iface} "
				uci_set banip global ban_protov6 "1"
				uci_add_list banip global ban_ifv6 "${iface}"
			fi
		fi
		ban_ifv4="${ban_ifv4%%?}"
		ban_ifv6="${ban_ifv6%%?}"
		[ -n "$(uci -q changes "banip")" ] && uci_commit "banip"
	fi
	[ -z "${ban_ifv4}" ] && [ -z "${ban_ifv6}" ] && f_log "err" "wan interfaces not found, please check your configuration"

	f_log "debug" "f_getif   ::: auto_detect: ${ban_autodetect}, interfaces (4/6): ${ban_ifv4}/${ban_ifv6}, protocols (4/6): ${ban_protov4}/${ban_protov6}"
}

# get wan devices
#
f_getdev() {
	local dev iface

	if [ "${ban_autodetect}" = "1" ] && [ -z "${ban_dev}" ]; then
		for iface in ${ban_ifv4} ${ban_ifv6}; do
			network_get_device dev "${iface}"
			if [ -n "${dev}" ] && ! printf "%s" "${ban_dev}" | "${ban_grepcmd}" -q "${dev}"; then
				ban_dev="${ban_dev}${dev} "
				uci_add_list banip global ban_dev "${dev}"
			else
				network_get_physdev dev "${iface}"
				if [ -n "${dev}" ] && ! printf "%s" "${ban_dev}" | "${ban_grepcmd}" -q "${dev}"; then
					ban_dev="${ban_dev}${dev} "
					uci_add_list banip global ban_dev "${dev}"
				fi
			fi
		done
		ban_dev="${ban_dev%%?}"
		[ -n "$(uci -q changes "banip")" ] && uci_commit "banip"
	fi
	[ -z "${ban_dev}" ] && f_log "err" "wan devices not found, please check your configuration"

	f_log "debug" "f_getdev  ::: auto_detect: ${ban_autodetect}, devices: ${ban_dev}"
}

# get local subnets
#
f_getsub() {
	local sub iface ip

	for iface in ${ban_ifv4} ${ban_ifv6}; do
		network_get_subnet sub "${iface}"
		if [ -n "${sub}" ] && ! printf "%s" "${ban_sub}" | "${ban_grepcmd}" -q "${sub}"; then
			ban_sub="${ban_sub} ${sub}"
		fi
		network_get_subnet6 sub "${iface}"
		if [ -n "${sub}" ] && ! printf "%s" "${ban_sub}" | "${ban_grepcmd}" -q "${sub}"; then
			ban_sub="${ban_sub} ${sub}"
		fi
	done
	if [ "${ban_autoallowlist}" = "1" ]; then
		for ip in ${ban_sub}; do
			if ! "${ban_grepcmd}" -q "${ip}" "${ban_allowlist}"; then
				printf "%-42s%s\n" "${ip}" "added on $(date "+%Y-%m-%d %H:%M:%S")" >>"${ban_allowlist}"
				f_log "info" "add subnet '${ip}' to local allowlist"
			fi
		done
	fi
	[ -z "${ban_sub}" ] && f_log "err" "wan subnet(s) not found, please check your configuration"

	f_log "debug" "f_getsub  ::: auto_allowlist: ${ban_autoallowlist}, subnet(s): ${ban_sub:-"-"}"
}

# get set elements
#
f_getelements() {
	local file="${1}"

	[ -s "${file}" ] && printf "%s" "elements={ $(cat "${file}") };"
}

# build initial nft file with base table, chains and rules
#
f_nftinit() {
	local feed_log feed_rc file="${1}"

	{
		# nft header (tables and chains)
		#
		printf "%s\n\n" "#!/usr/sbin/nft -f"
		if "${ban_nftcmd}" -t list table inet banIP >/dev/null 2>&1; then
			printf "%s\n" "delete table inet banIP"
		fi
		printf "%s\n" "add table inet banIP"
		printf "%s\n" "add chain inet banIP wan-input { type filter hook input priority ${ban_nftpriority}; policy accept; }"
		printf "%s\n" "add chain inet banIP lan-forward { type filter hook forward priority ${ban_nftpriority}; policy accept; }"

		# default input rules
		#
		printf "%s\n" "add rule inet banIP wan-input ct state established,related counter accept"
		printf "%s\n" "add rule inet banIP wan-input iifname != { ${ban_dev// /, } } counter accept"
		printf "%s\n" "add rule inet banIP wan-input meta nfproto ipv4 icmp type { echo-request } limit rate 1000/second counter accept"
		printf "%s\n" "add rule inet banIP wan-input meta nfproto ipv6 icmpv6 type { echo-request } limit rate 1000/second counter accept"
		printf "%s\n" "add rule inet banIP wan-input meta nfproto ipv6 icmpv6 type { nd-neighbor-advert, nd-neighbor-solicit, nd-router-advert} limit rate 1000/second ip6 hoplimit 1 counter accept"
		printf "%s\n" "add rule inet banIP wan-input meta nfproto ipv6 icmpv6 type { nd-neighbor-advert, nd-neighbor-solicit, nd-router-advert} limit rate 1000/second ip6 hoplimit 255 counter accept"

		# default forward rules
		#
		printf "%s\n" "add rule inet banIP lan-forward ct state established,related counter accept"
		printf "%s\n" "add rule inet banIP lan-forward oifname != { ${ban_dev// /, } } counter accept"
	} >"${file}"

	# load initial banIP table within nft (atomic load)
	#
	feed_log="$("${ban_nftcmd}" -f "${file}" 2>&1)"
	feed_rc="${?}"

	f_log "debug" "f_nftinit ::: devices: ${ban_dev}, priority: ${ban_nftpriority}, rc: ${feed_rc:-"-"}, log: ${feed_log:-"-"}"
	return ${feed_rc}
}

f_down() {
	local nft_loginput nft_logforward start_ts end_ts tmp_raw tmp_load tmp_file split_file input_handles forward_handles handle
	local cnt_set cnt_dl restore_rc feed_direction feed_rc feed_log feed="${1}" proto="${2}" feed_url="${3}" feed_rule="${4}" feed_flag="${5}"

	start_ts="$(date +%s)"
	feed="${feed}v${proto}"
	tmp_load="${ban_tmpfile}.${feed}.load"
	tmp_raw="${ban_tmpfile}.${feed}.raw"
	tmp_split="${ban_tmpfile}.${feed}.split"
	tmp_file="${ban_tmpfile}.${feed}.file"
	tmp_flush="${ban_tmpfile}.${feed}.flush"
	tmp_nft="${ban_tmpfile}.${feed}.nft"

	[ "${ban_loginput}" = "1" ] && nft_loginput="limit rate 2/second log level ${ban_loglevel} prefix \"banIP_drp/${feed}: \""
	[ "${ban_logforward}" = "1" ] && nft_logforward="limit rate 2/second log level ${ban_loglevel} prefix \"banIP_rej/${feed}: \""

	# set source block direction
	#
	if printf "%s" "${ban_blockinput}" | "${ban_grepcmd}" -q "${feed%v*}"; then
		feed_direction="input"
	elif printf "%s" "${ban_blockforward}" | "${ban_grepcmd}" -q "${feed%v*}"; then
		feed_direction="forward"
	fi

	# chain/rule maintenance
	#
	if [ "${ban_action}" = "reload" ] && "${ban_nftcmd}" -t list set inet banIP "${feed}" >/dev/null 2>&1; then
		input_handles="$("${ban_nftcmd}" -t --handle --numeric list chain inet banIP wan-input 2>/dev/null)"
		forward_handles="$("${ban_nftcmd}" -t --handle --numeric list chain inet banIP lan-forward 2>/dev/null)"
		{
			printf "%s\n" "flush set inet banIP ${feed}"
			handle="$(printf "%s\n" "${input_handles}" | "${ban_awkcmd}" "/@${feed} /{print \$NF}")"
			[ -n "${handle}" ] && printf "%s\n" "delete rule inet banIP wan-input handle ${handle}"
			handle="$(printf "%s\n" "${forward_handles}" | "${ban_awkcmd}" "/@${feed} /{print \$NF}")"
			[ -n "${handle}" ] && printf "%s\n" "delete rule inet banIP lan-forward handle ${handle}"
		} >"${tmp_flush}"
	fi

	# restore local backups during init
	#
	if { [ "${ban_action}" != "reload" ] || [ "${feed_url}" = "local" ]; } && [ "${feed%v*}" != "allowlist" ] && [ "${feed%v*}" != "blocklist" ]; then
		f_restore "${feed}" "${feed_url}" "${tmp_load}"
		restore_rc="${?}"
		feed_rc="${restore_rc}"
	fi

	# handle local lists
	#
	if [ "${feed%v*}" = "allowlist" ]; then
		{
			printf "%s\n\n" "#!/usr/sbin/nft -f"
			[ -s "${tmp_flush}" ] && cat "${tmp_flush}"
			if [ "${proto}" = "MAC" ]; then
				"${ban_awkcmd}" '/^([0-9A-f]{2}:){5}[0-9A-f]{2}([[:space:]]|$)/{printf "%s, ",tolower($1)}' "${ban_allowlist}" >"${tmp_file}"
				printf "%s\n" "add set inet banIP ${feed} { type ether_addr; policy memory; $(f_getelements "${tmp_file}") }"
				if [ "${feed_direction}" != "input" ]; then
					printf "%s\n" "add rule inet banIP lan-forward ether saddr @${feed} counter accept"
				fi
			elif [ "${proto}" = "4" ]; then
				"${ban_awkcmd}" '/^(([0-9]{1,3}\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])(\/(1?[0-9]|2?[0-9]|3?[0-2]))?)([[:space:]]|$)/{printf "%s, ",$1}' "${ban_allowlist}" >"${tmp_file}"
				printf "%s\n" "add set inet banIP ${feed} { type ipv4_addr; flags interval; auto-merge; policy memory; $(f_getelements "${tmp_file}") }"
				if [ "${feed_direction}" != "forward" ]; then
					if [ "${ban_allowlistonly}" = "1" ]; then
						printf "%s\n" "add rule inet banIP wan-input ip saddr != @${feed} ${nft_loginput} counter drop"
					else
						printf "%s\n" "add rule inet banIP wan-input ip saddr @${feed} counter accept"
					fi
				fi
				if [ "${feed_direction}" != "input" ]; then
					if [ "${ban_allowlistonly}" = "1" ]; then
						printf "%s\n" "add rule inet banIP lan-forward ip daddr != @${feed} ${nft_logforward} counter reject with icmp type admin-prohibited"
					else
						printf "%s\n" "add rule inet banIP lan-forward ip daddr @${feed} counter accept"
					fi
				fi
			elif [ "${proto}" = "6" ]; then
				"${ban_awkcmd}" '!/^([0-9A-f]{2}:){5}[0-9A-f]{2}([[:space:]]|$)/{printf "%s\n",$1}' "${ban_allowlist}" |
					"${ban_awkcmd}" '/^(([0-9A-f]{0,4}:){1,7}[0-9A-f]{0,4}:?(\/(1?[0-2][0-8]|[0-9][0-9]))?)([[:space:]]|$)/{printf "%s, ",tolower($1)}' >"${tmp_file}"
				printf "%s\n" "add set inet banIP ${feed} { type ipv6_addr; flags interval; auto-merge; policy memory; $(f_getelements "${tmp_file}") }"
				if [ "${feed_direction}" != "forward" ]; then
					if [ "${ban_allowlistonly}" = "1" ]; then
						printf "%s\n" "add rule inet banIP wan-input ip6 saddr != @${feed} ${nft_loginput} counter drop"
					else
						printf "%s\n" "add rule inet banIP wan-input ip6 saddr @${feed} counter accept"
					fi
				fi
				if [ "${feed_direction}" != "input" ]; then
					if [ "${ban_allowlistonly}" = "1" ]; then
						printf "%s\n" "add rule inet banIP lan-forward ip6 daddr != @${feed} ${nft_logforward} counter reject with icmpv6 type admin-prohibited"
					else
						printf "%s\n" "add rule inet banIP lan-forward ip6 daddr @${feed} counter accept"
					fi
				fi
			fi
		} >"${tmp_nft}"
		feed_rc="${?}"
	elif [ "${feed%v*}" = "blocklist" ]; then
		{
			printf "%s\n\n" "#!/usr/sbin/nft -f"
			[ -s "${tmp_flush}" ] && cat "${tmp_flush}"
			if [ "${proto}" = "MAC" ]; then
				"${ban_awkcmd}" '/^([0-9A-f]{2}:){5}[0-9A-f]{2}([[:space:]]|$)/{printf "%s, ",tolower($1)}' "${ban_blocklist}" >"${tmp_file}"
				printf "%s\n" "add set inet banIP ${feed} { type ether_addr; policy memory; $(f_getelements "${tmp_file}") }"
				if [ "${feed_direction}" != "input" ]; then
					printf "%s\n" "add rule inet banIP lan-forward ether saddr @${feed} ${nft_logforward} counter reject"
				fi
			elif [ "${proto}" = "4" ]; then
				if [ "${ban_deduplicate}" = "1" ]; then
					"${ban_awkcmd}" '/^(([0-9]{1,3}\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])(\/(1?[0-9]|2?[0-9]|3?[0-2]))?)([[:space:]]|$)/{printf "%s,\n",$1}' "${ban_blocklist}" >"${tmp_raw}"
					"${ban_awkcmd}" 'NR==FNR{member[$0];next}!($0 in member)' "${ban_tmpfile}.deduplicate" "${tmp_raw}" 2>/dev/null >"${tmp_split}"
					"${ban_awkcmd}" 'BEGIN{FS="[ ,]"}NR==FNR{member[$1];next}!($1 in member)' "${ban_tmpfile}.deduplicate" "${ban_blocklist}" 2>/dev/null >"${tmp_raw}"
					cat "${tmp_raw}" 2>/dev/null >"${ban_blocklist}"
				else
					"${ban_awkcmd}" '/^(([0-9]{1,3}\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])(\/(1?[0-9]|2?[0-9]|3?[0-2]))?)([[:space:]]|$)/{printf "%s,\n",$1}' "${ban_blocklist}" >"${tmp_split}"
				fi
				"${ban_awkcmd}" '{ORS=" ";print}' "${tmp_split}" 2>/dev/null >"${tmp_file}"
				printf "%s\n" "add set inet banIP ${feed} { type ipv4_addr; flags interval, timeout; auto-merge; policy memory; $(f_getelements "${tmp_file}") }"
				if [ "${feed_direction}" != "forward" ]; then
					printf "%s\n" "add rule inet banIP wan-input ip saddr @${feed} ${nft_loginput} counter drop"
				fi
				if [ "${feed_direction}" != "input" ]; then
					printf "%s\n" "add rule inet banIP lan-forward ip daddr @${feed} ${nft_logforward} counter reject with icmp type admin-prohibited"
				fi
			elif [ "${proto}" = "6" ]; then
				if [ "${ban_deduplicate}" = "1" ]; then
					"${ban_awkcmd}" '!/^([0-9A-f]{2}:){5}[0-9A-f]{2}([[:space:]]|$)/{printf "%s\n",$1}' "${ban_blocklist}" |
						"${ban_awkcmd}" '/^(([0-9A-f]{0,4}:){1,7}[0-9A-f]{0,4}:?(\/(1?[0-2][0-8]|[0-9][0-9]))?)([[:space:]]|$)/{printf "%s,\n",tolower($1)}' >"${tmp_raw}"
					"${ban_awkcmd}" 'NR==FNR{member[$0];next}!($0 in member)' "${ban_tmpfile}.deduplicate" "${tmp_raw}" 2>/dev/null >"${tmp_split}"
					"${ban_awkcmd}" 'BEGIN{FS="[ ,]"}NR==FNR{member[$1];next}!($1 in member)' "${ban_tmpfile}.deduplicate" "${ban_blocklist}" 2>/dev/null >"${tmp_raw}"
					cat "${tmp_raw}" 2>/dev/null >"${ban_blocklist}"
				else
					"${ban_awkcmd}" '!/^([0-9A-f]{2}:){5}[0-9A-f]{2}([[:space:]]|$)/{printf "%s\n",$1}' "${ban_blocklist}" |
						"${ban_awkcmd}" '/^(([0-9A-f]{0,4}:){1,7}[0-9A-f]{0,4}:?(\/(1?[0-2][0-8]|[0-9][0-9]))?)([[:space:]]|$)/{printf "%s,\n",tolower($1)}' >"${tmp_split}"
				fi
				"${ban_awkcmd}" '{ORS=" ";print}' "${tmp_split}" 2>/dev/null >"${tmp_file}"
				printf "%s\n" "add set inet banIP ${feed} { type ipv6_addr; flags interval, timeout; auto-merge; policy memory; $(f_getelements "${tmp_file}") }"
				if [ "${feed_direction}" != "forward" ]; then
					printf "%s\n" "add rule inet banIP wan-input ip6 saddr @${feed} ${nft_loginput} counter drop"
				fi
				if [ "${feed_direction}" != "input" ]; then
					printf "%s\n" "add rule inet banIP lan-forward ip6 daddr @${feed} ${nft_logforward} counter reject with icmpv6 type admin-prohibited"
				fi
			fi
		} >"${tmp_nft}"
		feed_rc="${?}"
	# handle external downloads
	#
	elif [ "${restore_rc}" != "0" ] && [ "${feed_url}" != "local" ]; then
		# handle country downloads
		#
		if [ "${feed%v*}" = "country" ]; then
			for country in ${ban_country}; do
				feed_log="$("${ban_fetchcmd}" ${ban_fetchparm} "${tmp_raw}" "${feed_url}${country}-aggregated.zone" 2>&1)"
				feed_rc="${?}"
				[ "${feed_rc}" = "0" ] && cat "${tmp_raw}" 2>/dev/null >>"${tmp_load}"
			done
			rm -f "${tmp_raw}"

		# handle asn downloads
		#
		elif [ "${feed%v*}" = "asn" ]; then
			for asn in ${ban_asn}; do
				feed_log="$("${ban_fetchcmd}" ${ban_fetchparm} "${tmp_raw}" "${feed_url}AS${asn}" 2>&1)"
				feed_rc="${?}"
				[ "${feed_rc}" = "0" ] && cat "${tmp_raw}" 2>/dev/null >>"${tmp_load}"
			done
			rm -f "${tmp_raw}"

		# handle compressed downloads
		#
		elif [ -n "${feed_flag}" ]; then
			case "${feed_flag}" in
				"gz")
					feed_log="$("${ban_fetchcmd}" ${ban_fetchparm} "${tmp_raw}" "${feed_url}" 2>&1)"
					feed_rc="${?}"
					if [ "${feed_rc}" = "0" ]; then
						zcat "${tmp_raw}" 2>/dev/null >"${tmp_load}"
						feed_rc="${?}"
					fi
					rm -f "${tmp_raw}"
					;;
			esac

		# handle normal downloads
		#
		else
			feed_log="$("${ban_fetchcmd}" ${ban_fetchparm} "${tmp_load}" "${feed_url}" 2>&1)"
			feed_rc="${?}"
		fi
	fi

	# backup/restore
	#
	if [ "${restore_rc}" != "0" ] && [ "${feed_rc}" = "0" ] && [ "${feed_url}" != "local" ] && [ ! -s "${tmp_nft}" ]; then
		f_backup "${feed}" "${tmp_load}"
		feed_rc="${?}"
	elif [ -z "${restore_rc}" ] && [ "${feed_rc}" != "0" ] && [ "${feed_url}" != "local" ] && [ ! -s "${tmp_nft}" ]; then
		f_restore "${feed}" "${feed_url}" "${tmp_load}" "${feed_rc}"
		feed_rc="${?}"
	fi

	# build nft file with set and rules for regular downloads
	#
	if [ "${feed_rc}" = "0" ] && [ ! -s "${tmp_nft}" ]; then
		# deduplicate sets
		#
		if [ "${ban_deduplicate}" = "1" ] && [ "${feed_url}" != "local" ]; then
			"${ban_awkcmd}" "${feed_rule}" "${tmp_load}" 2>/dev/null >"${tmp_raw}"
			"${ban_awkcmd}" 'NR==FNR{member[$0];next}!($0 in member)' "${ban_tmpfile}.deduplicate" "${tmp_raw}" 2>/dev/null | tee -a "${ban_tmpfile}.deduplicate" >"${tmp_split}"
		else
			"${ban_awkcmd}" "${feed_rule}" "${tmp_load}" 2>/dev/null >"${tmp_split}"
		fi
		feed_rc="${?}"
		# split sets
		#
		if [ "${feed_rc}" = "0" ]; then
			if [ -n "${ban_splitsize//[![:digit]]/}" ] && [ "${ban_splitsize//[![:digit]]/}" -gt "0" ]; then
				if ! "${ban_awkcmd}" "NR%${ban_splitsize//[![:digit]]/}==1{file=\"${tmp_file}.\"++i;}{ORS=\" \";print > file}" "${tmp_split}" 2>/dev/null; then
					rm -f "${tmp_file}".*
					f_log "info" "failed to split ${feed} set to size '${ban_splitsize//[![:digit]]/}'"
				fi
			else
				"${ban_awkcmd}" '{ORS=" ";print}' "${tmp_split}" 2>/dev/null >"${tmp_file}.1"
			fi
			feed_rc="${?}"
		fi
		rm -f "${tmp_raw}" "${tmp_load}"
		if [ "${feed_rc}" = "0" ] && [ "${proto}" = "4" ]; then
			{
				# nft header (IPv4 set)
				#
				printf "%s\n\n" "#!/usr/sbin/nft -f"
				[ -s "${tmp_flush}" ] && cat "${tmp_flush}"
				printf "%s\n" "add set inet banIP ${feed} { type ipv4_addr; flags interval; auto-merge; policy memory; $(f_getelements "${tmp_file}.1") }"

				# input and forward rules
				#
				if [ "${feed_direction}" != "forward" ]; then
					printf "%s\n" "add rule inet banIP wan-input ip saddr @${feed} ${nft_loginput} counter drop"
				fi
				if [ "${feed_direction}" != "input" ]; then
					printf "%s\n" "add rule inet banIP lan-forward ip daddr @${feed} ${nft_logforward} counter reject with icmp type admin-prohibited"
				fi
			} >"${tmp_nft}"
		elif [ "${feed_rc}" = "0" ] && [ "${proto}" = "6" ]; then
			{
				# nft header (IPv6 set)
				#
				printf "%s\n\n" "#!/usr/sbin/nft -f"
				[ -s "${tmp_flush}" ] && cat "${tmp_flush}"
				printf "%s\n" "add set inet banIP ${feed} { type ipv6_addr; flags interval; auto-merge; policy memory; $(f_getelements "${tmp_file}.1") }"

				# input and forward rules
				#
				if [ "${feed_direction}" != "forward" ]; then
					printf "%s\n" "add rule inet banIP wan-input ip6 saddr @${feed} ${nft_loginput} counter drop"
				fi
				if [ "${feed_direction}" != "input" ]; then
					printf "%s\n" "add rule inet banIP lan-forward ip6 daddr @${feed} ${nft_logforward} counter reject with icmpv6 type admin-prohibited"
				fi
			} >"${tmp_nft}"
		fi
	fi

	# load generated nft file in banIP table
	#
	if [ "${feed_rc}" = "0" ]; then
		cnt_dl="$("${ban_awkcmd}" 'END{printf "%d",NR}' "${tmp_split}" 2>/dev/null)"
		if [ "${cnt_dl:-"0"}" -gt "0" ] || [ "${feed_url}" = "local" ] || [ "${feed%v*}" = "allowlist" ] || [ "${feed%v*}" = "blocklist" ]; then
			feed_log="$("${ban_nftcmd}" -f "${tmp_nft}" 2>&1)"
			feed_rc="${?}"
			# load additional split files
			#
			if [ "${feed_rc}" = "0" ]; then
				for split_file in "${tmp_file}".*; do
					[ ! -f "${split_file}" ] && break
					if [ "${split_file##*.}" = "1" ]; then
						rm -f "${split_file}"
						continue
					fi
					if ! "${ban_nftcmd}" add element inet banIP "${feed}" "{ $(cat "${split_file}") }" >/dev/null 2>&1; then
						f_log "info" "failed to add split file '${split_file##*.}' to ${feed} set"
					fi
					rm -f "${split_file}"
				done
				cnt_set="$("${ban_nftcmd}" -j list set inet banIP "${feed}" 2>/dev/null | jsonfilter -qe '@.nftables[*].set.elem[*]' | wc -l 2>/dev/null)"
			fi
		else
			f_log "info" "empty feed ${feed} will be skipped"
		fi
	fi
	rm -f "${tmp_split}" "${tmp_nft}"
	end_ts="$(date +%s)"

	f_log "debug" "f_down    ::: name: ${feed}, cnt_dl: ${cnt_dl:-"-"}, cnt_set: ${cnt_set:-"-"}, split_size: ${ban_splitsize:-"-"}, time: $((end_ts - start_ts)), rc: ${feed_rc:-"-"}, log: ${feed_log:-"-"}"
}

# backup feeds
#
f_backup() {
	local backup_rc feed="${1}" feed_file="${2}"

	gzip -cf "${feed_file}" >"${ban_backupdir}/banIP.${feed}.gz"
	backup_rc="${?}"

	f_log "debug" "f_backup  ::: name: ${feed}, source: ${feed_file##*/}, target: banIP.${feed}.gz, rc: ${backup_rc}"
	return ${backup_rc}
}

# restore feeds
#
f_restore() {
	local tmp_feed restore_rc="1" feed="${1}" feed_url="${2}" feed_file="${3}" feed_rc="${4:-"0"}"

	[ "${feed_rc}" != "0" ] && restore_rc="${feed_rc}"
	[ "${feed_url}" = "local" ] && tmp_feed="${feed%v*}v4" || tmp_feed="${feed}"
	if [ -f "${ban_backupdir}/banIP.${tmp_feed}.gz" ]; then
		zcat "${ban_backupdir}/banIP.${tmp_feed}.gz" 2>/dev/null >"${feed_file}"
		restore_rc="${?}"
	fi

	f_log "debug" "f_restore ::: name: ${feed}, source: banIP.${tmp_feed}.gz, target: ${feed_file##*/}, in_rc: ${feed_rc}, rc: ${restore_rc}"
	return ${restore_rc}
}

# remove disabled feeds
#
f_rmset() {
	local tmp_del table_sets input_handles forward_handles handle sets feed feed_log feed_rc

	tmp_del="${ban_tmpfile}.final.delete"
	table_sets="$("${ban_nftcmd}" -t list table inet banIP 2>/dev/null | "${ban_awkcmd}" '/^[[:space:]]+set [[:alnum:]]+ /{printf "%s ",$2}' 2>/dev/null)"
	input_handles="$("${ban_nftcmd}" -t --handle --numeric list chain inet banIP wan-input 2>/dev/null)"
	forward_handles="$("${ban_nftcmd}" -t --handle --numeric list chain inet banIP lan-forward 2>/dev/null)"
	{
		printf "%s\n\n" "#!/usr/sbin/nft -f"
		for feed in ${table_sets}; do
			if ! printf "%s" "allowlist blocklist ${ban_feed}" | "${ban_grepcmd}" -q "${feed%v*}"; then
				sets="${sets}${feed}/"
				rm -f "${ban_backupdir}/banIP.${feed}.gz"
				printf "%s\n" "flush set inet banIP ${feed}"
				handle="$(printf "%s\n" "${input_handles}" | "${ban_awkcmd}" "/@${feed} /{print \$NF}" 2>/dev/null)"
				[ -n "${handle}" ] && printf "%s\n" "delete rule inet banIP wan-input handle ${handle}"
				handle="$(printf "%s\n" "${forward_handles}" | "${ban_awkcmd}" "/@${feed} /{print \$NF}" 2>/dev/null)"
				[ -n "${handle}" ] && printf "%s\n" "delete rule inet banIP lan-forward handle ${handle}"
				printf "%s\n\n" "delete set inet banIP ${feed}"
			fi
		done
	} >"${tmp_del}"

	if [ -n "${sets}" ]; then
		feed_log="$("${ban_nftcmd}" -f "${tmp_del}" 2>&1)"
		feed_rc="${?}"
	fi
	rm -f "${tmp_del}"

	f_log "debug" "f_rmset   ::: sets: ${sets:-"-"}, tmp: ${tmp_del}, rc: ${feed_rc:-"-"}, log: ${feed_log:-"-"}"
}

# generate status information
#
f_genstatus() {
	local object duration nft_table nft_feeds cnt_elements="0" split="0" status="${1}"

	[ -z "${ban_dev}" ] && f_conf
	if [ "${status}" = "active" ]; then
		if [ -n "${ban_starttime}" ]; then
			ban_endtime="$(date "+%s")"
			duration="$(((ban_endtime - ban_starttime) / 60))m $(((ban_endtime - ban_starttime) % 60))s"
		fi
		nft_table="$("${ban_nftcmd}" -t list table inet banIP 2>/dev/null)"
		nft_feeds="$(f_trim "$(printf "%s\n" "${nft_table}" | "${ban_awkcmd}" '/^[[:space:]]+set [[:alnum:]]+ /{printf "%s ",$2}')")"
		for object in ${nft_feeds}; do
			cnt_elements="$((cnt_elements + $("${ban_nftcmd}" -j list set inet banIP "${object}" 2>/dev/null | jsonfilter -qe '@.nftables[*].set.elem[*]' | wc -l 2>/dev/null)))"
		done
		runtime="action: ${ban_action:-"-"}, duration: ${duration:-"-"}, date: $(date "+%Y-%m-%d %H:%M:%S")"
	fi
	f_system
	[ ${ban_splitsize:-"0"} -gt "0" ] && split="1"

	: >"${ban_basedir}/ban_runtime.json"
	json_init
	json_load_file "${ban_basedir}/ban_runtime.json" >/dev/null 2>&1
	json_add_string "status" "${status}"
	json_add_string "version" "${ban_ver}"
	json_add_string "element_count" "${cnt_elements}"
	json_add_array "active_feeds"
	if [ "${status}" != "active" ]; then
		json_add_object
		json_add_string "feed" "-"
		json_close_object
	else
		for object in ${nft_feeds}; do
			json_add_object
			json_add_string "feed" "${object}"
			json_close_object
		done
	fi
	json_close_array
	json_add_array "active_devices"
	if [ "${status}" != "active" ]; then
		json_add_object
		json_add_string "device" "-"
		json_close_object
	else
		for object in ${ban_dev}; do
			json_add_object
			json_add_string "device" "${object}"
			json_close_object
		done
	fi
	json_close_array
	json_add_array "active_interfaces"
	if [ "${status}" != "active" ]; then
		json_add_object
		json_add_string "interface" "-"
		json_close_object
	else
		for object in ${ban_ifv4} ${ban_ifv6}; do
			json_add_object
			json_add_string "interface" "${object}"
			json_close_object
		done
	fi
	json_close_array
	json_add_array "active_subnets"
	if [ "${status}" != "active" ]; then
		json_add_object
		json_add_string "subnet" "-"
		json_close_object
	else
		for object in ${ban_sub}; do
			json_add_object
			json_add_string "subnet" "${object}"
			json_close_object
		done
	fi
	json_close_array
	json_add_string "run_info" "base_dir: ${ban_basedir}, backup_dir: ${ban_backupdir}, report_dir: ${ban_reportdir}, feed_archive: ${ban_feedarchive}"
	json_add_string "run_flags" "protocol (4/6): $(f_char ${ban_protov4})/$(f_char ${ban_protov6}), log (inp/fwd): $(f_char ${ban_loginput})/$(f_char ${ban_logforward}), deduplicate: $(f_char ${ban_deduplicate}), split: $(f_char ${split}), allowed only: $(f_char ${ban_allowlistonly})"
	json_add_string "last_run" "${runtime:-"-"}"
	json_add_string "system_info" "cores: ${ban_cores}, memory: ${ban_memory}, device: ${ban_sysver}"
	json_dump >"${ban_basedir}/ban_runtime.json"
}

# get status information
#
f_getstatus() {
	local key keylist type value index_value

	[ -z "${ban_dev}" ] && f_conf
	json_load_file "${ban_basedir}/ban_runtime.json" >/dev/null 2>&1
	if json_get_keys keylist; then
		printf "%s\n" "::: banIP runtime information"
		for key in ${keylist}; do
			json_get_var value "${key}" >/dev/null 2>&1
			if [ "${key%_*}" = "active" ]; then
				json_select "${key}" >/dev/null 2>&1
				index=1
				while json_get_type type "${index}" && [ "${type}" = "object" ]; do
					json_get_values index_value "${index}" >/dev/null 2>&1
					if [ "${index}" = "1" ]; then
						value="${index_value}"
					else
						value="${value}, ${index_value}"
					fi
					index=$((index + 1))
				done
				json_select ".."
			fi
			value="$(
				printf "%s" "${value}" |
					awk '{NR=1;max=98;if(length($0)>max+1)while($0){if(NR==1){print substr($0,1,max)}else{printf"%-24s%s\n","",substr($0,1,max)}{$0=substr($0,max+1);NR=NR+1}}else print}'
			)"
			printf "  + %-17s : %s\n" "${key}" "${value:-"-"}"
		done
	else
		printf "%s\n" "::: no banIP runtime information available"
	fi
}

# domain lookup
#
f_lookup() {
	local cnt list domain lookup ip start_time end_time duration cnt_domain="0" cnt_ip="0" feed="${1}"

	start_time="$(date "+%s")"
	if [ "${feed}" = "allowlist" ]; then
		list="$("${ban_awkcmd}" '/^([[:alnum:]_-]{1,63}\.)+[[:alpha:]]+([[:space:]]|$)/{printf "%s ",tolower($1)}' "${ban_allowlist}" 2>/dev/null)"
	elif [ "${feed}" = "blocklist" ]; then
		list="$("${ban_awkcmd}" '/^([[:alnum:]_-]{1,63}\.)+[[:alpha:]]+([[:space:]]|$)/{printf "%s ",tolower($1)}' "${ban_blocklist}" 2>/dev/null)"
	fi

	for domain in ${list}; do
		lookup="$("${ban_lookupcmd}" "${domain}" ${ban_resolver} 2>/dev/null | "${ban_awkcmd}" '/^Address[ 0-9]*: /{if(!seen[$NF]++)printf "%s ",$NF}' 2>/dev/null)"
		for ip in ${lookup}; do
			if [ "${ip%%.*}" = "0" ] || [ -z "${ip%%::*}" ]; then
				continue
			else
				if { [ "${feed}" = "allowlist" ] && ! "${ban_grepcmd}" -q "^${ip}" "${ban_allowlist}"; } ||
					{ [ "${feed}" = "blocklist" ] && ! "${ban_grepcmd}" -q "^${ip}" "${ban_blocklist}"; }; then
					cnt_ip="$((cnt_ip + 1))"
					if [ "${ip##*:}" = "${ip}" ]; then
						if ! "${ban_nftcmd}" add element inet banIP "${feed}v4" "{ ${ip} }" >/dev/null 2>&1; then
							f_log "info" "failed to add IP '${ip}' (${domain}) to ${feed}v4 set"
							continue
						fi
					else
						if ! "${ban_nftcmd}" add element inet banIP "${feed}v6" "{ ${ip} }" >/dev/null 2>&1; then
							f_log "info" "failed to add IP '${ip}' (${domain}) to ${feed}v6 set"
							continue
						fi
					fi
					if [ "${feed}" = "allowlist" ] && [ "${ban_autoallowlist}" = "1" ]; then
						printf "%-42s%s\n" "${ip}" "# ip of '${domain}' added on $(date "+%Y-%m-%d %H:%M:%S")" >>"${ban_allowlist}"
					elif [ "${feed}" = "blocklist" ] && [ "${ban_autoblocklist}" = "1" ]; then
						printf "%-42s%s\n" "${ip}" "# ip of '${domain}' added on $(date "+%Y-%m-%d %H:%M:%S")" >>"${ban_blocklist}"
					fi
				fi
			fi
		done
		cnt_domain="$((cnt_domain + 1))"
	done
	end_time="$(date "+%s")"
	duration="$(((end_time - start_time) / 60))m $(((end_time - start_time) % 60))s"

	f_log "debug" "f_lookup  ::: name: ${feed}, cnt_domain: ${cnt_domain}, cnt_ip: ${cnt_ip}, duration: ${duration}"
}

# banIP table statistics
#
f_report() {
	local report_jsn report_txt set nft_raw nft_sets set_cnt set_input set_forward set_cntinput set_cntforward output="${1}"
	local detail set_details jsnval timestamp autoadd_allow autoadd_block sum_sets sum_setinput sum_setforward sum_setelements sum_cntinput sum_cntforward

	[ -z "${ban_dev}" ] && f_conf
	f_mkdir "${ban_reportdir}"
	report_jsn="${ban_reportdir}/ban_report.jsn"
	report_txt="${ban_reportdir}/ban_report.txt"

	# json output preparation
	#
	nft_raw="$("${ban_nftcmd}" -tj list table inet banIP 2>/dev/null)"
	nft_sets="$(printf "%s" "${nft_raw}" | jsonfilter -qe '@.nftables[*].set.name')"
	sum_sets="0"
	sum_setinput="0"
	sum_setforward="0"
	sum_setelements="0"
	sum_cntinput="0"
	sum_cntforward="0"
	timestamp="$(date "+%Y-%m-%d %H:%M:%S")"
	: >"${report_jsn}"
	{
		printf "%s\n" "{"
		printf "\t%s\n" '"sets": {'
		for set in ${nft_sets}; do
			set_cnt="$("${ban_nftcmd}" -j list set inet banIP "${set}" 2>/dev/null | jsonfilter -qe '@.nftables[*].set.elem[*]' | wc -l 2>/dev/null)"
			sum_setelements="$((sum_setelements + set_cnt))"
			set_cntinput="$(printf "%s" "${nft_raw}" | jsonfilter -qe "@.nftables[@.rule.chain=\"wan-input\"][@.expr[*].match.right=\"@${set}\"].expr[*].counter.packets")"
			set_cntforward="$(printf "%s" "${nft_raw}" | jsonfilter -qe "@.nftables[@.rule.chain=\"lan-forward\"][@.expr[*].match.right=\"@${set}\"].expr[*].counter.packets")"
			if [ -n "${set_cntinput}" ]; then
				set_input="OK"
				sum_setinput="$((sum_setinput + 1))"
				sum_cntinput="$((sum_cntinput + set_cntinput))"
			else
				set_input="n/a"
				set_cntinput="n/a"
			fi
			if [ -n "${set_cntforward}" ]; then
				set_forward="OK"
				sum_setforward="$((sum_setforward + 1))"
				sum_cntforward="$((sum_cntforward + set_cntforward))"
			else
				set_forward="n/a"
				set_cntforward="n/a"
			fi
			[ "${sum_sets}" -gt "0" ] && printf "%s\n" ","
			printf "\t\t%s\n" "\"${set}\": {"
			printf "\t\t\t%s\n" "\"cnt_elements\": \"${set_cnt}\","
			printf "\t\t\t%s\n" "\"input\": \"${set_input}\","
			printf "\t\t\t%s\n" "\"forward\": \"${set_forward}\","
			printf "\t\t\t%s\n" "\"cnt_input\": \"${set_cntinput}\","
			printf "\t\t\t%s\n" "\"cnt_forward\": \"${set_cntforward}\""
			printf "\t\t%s" "}"
			sum_sets="$((sum_sets + 1))"
		done
		printf "\n\t%s\n" "},"
		printf "\t%s\n" "\"timestamp\": \"${timestamp}\","
		printf "\t%s\n" "\"autoadd_allow\": \"$("${ban_grepcmd}" -c "added on ${timestamp% *}" "${ban_allowlist}")\","
		printf "\t%s\n" "\"autoadd_block\": \"$("${ban_grepcmd}" -c "added on ${timestamp% *}" "${ban_blocklist}")\","
		printf "\t%s\n" "\"sum_sets\": \"${sum_sets}\","
		printf "\t%s\n" "\"sum_setinput\": \"${sum_setinput}\","
		printf "\t%s\n" "\"sum_setforward\": \"${sum_setforward}\","
		printf "\t%s\n" "\"sum_setelements\": \"${sum_setelements}\","
		printf "\t%s\n" "\"sum_cntinput\": \"${sum_cntinput}\","
		printf "\t%s\n" "\"sum_cntforward\": \"${sum_cntforward}\""
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
			json_get_var sum_sets "sum_sets" >/dev/null 2>&1
			json_get_var sum_setinput "sum_setinput" >/dev/null 2>&1
			json_get_var sum_setforward "sum_setforward" >/dev/null 2>&1
			json_get_var sum_setelements "sum_setelements" >/dev/null 2>&1
			json_get_var sum_cntinput "sum_cntinput" >/dev/null 2>&1
			json_get_var sum_cntforward "sum_cntforward" >/dev/null 2>&1
			{
				printf "%s\n%s\n%s\n" ":::" "::: banIP Set Statistics" ":::"
				printf "%s\n" "    Timestamp: ${timestamp}"
				printf "%s\n" "    ------------------------------"
				printf "%s\n" "    auto-added to allowlist: ${autoadd_allow}"
				printf "%s\n\n" "    auto-added to blocklist: ${autoadd_block}"
				json_select "sets" >/dev/null 2>&1
				json_get_keys nft_sets >/dev/null 2>&1
				if [ -n "${nft_sets}" ]; then
					printf "%-25s%-16s%-16s%-16s%-16s%s\n" "    Set" "| Set Elements" "| Chain Input" "| Chain Forward" "| Input Packets" "| Forward Packets"
					printf "%s\n" "    ---------------------+---------------+---------------+---------------+---------------+----------------"
					for set in ${nft_sets}; do
						printf "    %-21s" "${set}"
						json_select "${set}"
						json_get_keys set_details
						for detail in ${set_details}; do
							json_get_var jsnval "${detail}" >/dev/null 2>&1
							printf "%-16s" "| ${jsnval}"
						done
						printf "\n"
						json_select ".."
					done
					printf "%s\n" "    ---------------------+---------------+---------------+---------------+---------------+----------------"
					printf "%-25s%-16s%-16s%-16s%-16s%s\n" "    ${sum_sets}" "| ${sum_setelements}" "| ${sum_setinput}" "| ${sum_setforward}" "| ${sum_cntinput}" "| ${sum_cntforward}"
				fi
			} >>"${report_txt}"
		fi
	fi

	# output channel (text|json|mail)
	#
	case "${output}" in
		"text")
			[ -s "${report_txt}" ] && cat "${report_txt}"
			;;
		"json")
			[ -s "${report_jsn}" ] && cat "${report_jsn}"
			;;
		"mail")
			[ -x "${ban_mailcmd}" ] && f_mail
			;;
	esac
}

# banIP set search
#
f_search() {
	local nft_sets ip proto run_search search="${1}"

	f_system
	run_search="/var/run/banIP.search"

	if [ -n "${search}" ]; then
		ip="$(printf "%s" "${search}" | "${ban_awkcmd}" 'BEGIN{RS="(([0-9]{1,3}\\.){3}[0-9]{1,3})+"}{printf "%s",RT}')"
		[ -n "${ip}" ] && proto="v4"
		if [ -z "${proto}" ]; then
			ip="$(printf "%s" "${search}" | "${ban_awkcmd}" 'BEGIN{RS="([A-Fa-f0-9]{1,4}::?){3,7}[A-Fa-f0-9]{1,4}"}{printf "%s",RT}')"
			[ -n "${ip}" ] && proto="v6"
		fi
		if [ -n "${proto}" ]; then
			nft_sets="$("${ban_nftcmd}" -tj list table inet banIP 2>/dev/null | jsonfilter -qe "@.nftables[@.set.type=\"ip${proto}_addr\"].set.name")"
		else
			printf "%s\n%s\n%s\n" ":::" "::: no valid search input (single IPv4/IPv6 address)" ":::"
			return
		fi
	else
		printf "%s\n%s\n%s\n" ":::" "::: no valid search input (single IPv4/IPv6 address)" ":::"
		return
	fi
	printf "%s\n%s\n%s\n" ":::" "::: banIP Search" ":::"
	printf "%s\n" "    Looking for IP ${ip} on $(date "+%Y-%m-%d %H:%M:%S")"
	printf "%s\n" "    ---"
	cnt=1
	for set in ${nft_sets}; do
		(
			if "${ban_nftcmd}" get element inet banIP "${set}" "{ ${ip} }" >/dev/null 2>&1; then
				printf "%s\n" "    IP found in set ${set}"
				: >"${run_search}"
			fi
		) &
		hold="$((cnt % ban_cores))"
		[ "${hold}" = "0" ] && wait
		cnt="$((cnt + 1))"
	done
	wait
	[ ! -f "${run_search}" ] && printf "%s\n" "    IP not found"
	rm -f "${run_search}"
}

# send status mails
#
f_mail() {
	local msmtp_debug

	# load mail template
	#
	[ ! -r "${ban_mailtemplate}" ] && f_log "err" "the mail template is missing"
	. "${ban_mailtemplate}"

	[ -z "${ban_mailreceiver}" ] && f_log "err" "the option 'ban_mailreceiver' is missing"
	[ -z "${mail_text}" ] && f_log "err" "the 'mail_text' is empty"
	[ "${ban_debug}" = "1" ] && msmtp_debug="--debug"

	# send mail
	#
	ban_mailhead="From: ${ban_mailsender}\nTo: ${ban_mailreceiver}\nSubject: ${ban_mailtopic}\nReply-to: ${ban_mailsender}\nMime-Version: 1.0\nContent-Type: text/html;charset=utf-8\nContent-Disposition: inline\n\n"
	if printf "%b" "${ban_mailhead}${mail_text}" | "${ban_mailcmd}" --timeout=10 ${msmtp_debug} -a "${ban_mailprofile}" "${ban_mailreceiver}" >/dev/null 2>&1; then
		f_log "info" "status mail was sent successfully"
	else
		f_log "info" "failed to send status mail (${?})"
	fi

	f_log "debug" "f_mail    ::: template: ${ban_mailtemplate}, profile: ${ban_mailprofile}, receiver: ${ban_mailreceiver}, rc: ${?}"
}

# check banIP availability and initial sourcing
#
if [ "${ban_action}" != "stop" ]; then
	if [ -r "/lib/functions.sh" ] && [ -r "/lib/functions/network.sh" ] && [ -r "/usr/share/libubox/jshn.sh" ]; then
		. "/lib/functions.sh"
		. "/lib/functions/network.sh"
		. "/usr/share/libubox/jshn.sh"
	else
		f_log "err" "system libraries not found"
	fi
	[ ! -d "/etc/banip" ] && f_log "err" "banIP config directory not found, please re-install the package"
	[ ! -r "/etc/config/banip" ] && f_log "err" "banIP config not found, please re-install the package"
	[ ! -r "/etc/banip/banip.feeds.gz" ] || ! zcat "$(uci_get banip global ban_feedarchive "/etc/banip/banip.feeds.gz")" >"$(uci_get banip global ban_basedir "/tmp")/ban_feeds.json" && f_log "err" "banIP feed archive not found, please re-install the package"
	[ "$(uci_get banip global ban_enabled)" = "0" ] && f_log "err" "banIP is currently disabled, please set the config option 'ban_enabled' to '1' to use this service"
fi
