#!/bin/sh
# banIP - ban incoming and outgoing ip adresses/subnets via ipset
# written by Dirk Brenken (dev@brenken.org)

# This is free software, licensed under the GNU General Public License v3.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# (s)hellcheck exceptions
# shellcheck disable=1091 disable=2039 disable=2143 disable=2181 disable=2188

# set initial defaults
#
LC_ALL=C
PATH="/usr/sbin:/usr/bin:/sbin:/bin"
ban_ver="0.2.1"
ban_enabled=0
ban_automatic="1"
ban_sources=""
ban_iface=""
ban_debug=0
ban_backupdir="/mnt"
ban_maxqueue=4
ban_autoblacklist=1
ban_autowhitelist=1
ban_fetchutil="uclient-fetch"
ban_ip="$(command -v ip)"
ban_ipt="$(command -v iptables)"
ban_ipt_save="$(command -v iptables-save)"
ban_ipt_restore="$(command -v iptables-restore)"
ban_ipt6="$(command -v ip6tables)"
ban_ipt6_save="$(command -v ip6tables-save)"
ban_ipt6_restore="$(command -v ip6tables-restore)"
ban_ipset="$(command -v ipset)"
ban_chain="banIP"
ban_action="${1:-"start"}"
ban_pidfile="/var/run/banip.pid"
ban_rtfile="/tmp/ban_runtime.json"
ban_sshdaemon="dropbear"
ban_setcnt=0
ban_cnt=0

# load environment
#
f_envload()
{
	# get system information
	#
	ban_sysver="$(ubus -S call system board 2>/dev/null | jsonfilter -e '@.model' -e '@.release.description' | \
		awk 'BEGIN{ORS=", "}{print $0}' | awk '{print substr($0,1,length($0)-2)}')"

	# parse 'global' and 'extra' section by callback
	#
	config_cb()
	{
		local type="${1}"
		if [ "${type}" = "banip" ]
		then
			option_cb()
			{
				local option="${1}"
				local value="${2}"
				eval "${option}=\"${value}\""
			}
		else
			reset_cb
		fi
	}

	# parse 'source' typed sections
	#
	parse_config()
	{
		local value opt section="${1}" options="ban_src ban_src_6 ban_src_rset ban_src_rset_6 ban_src_settype ban_src_ruletype ban_src_on ban_src_on_6 ban_src_cat"
		for opt in ${options}
		do
			config_get value "${section}" "${opt}"
			if [ -n "${value}" ]
			then
				eval "${opt}_${section}=\"${value}\""
				if [ "${opt}" = "ban_src" ]
				then
					eval "ban_sources=\"${ban_sources} ${section}\""
				elif [ "${opt}" = "ban_src_6" ]
				then
					eval "ban_sources=\"${ban_sources} ${section}_6\""
				fi
			fi
		done
	}

	# load config
	#
	config_load banip
	config_foreach parse_config source

	# create temp directory & files
	#
	f_temp

	# check status
	#
	if [ "${ban_enabled}" -eq 0 ]
	then
		f_jsnup disabled
		f_ipset destroy
		f_rmbackup
		f_rmtemp
		f_log "info" "banIP is currently disabled, please set ban_enabled to '1' to use this service"
		exit 0
	fi
}

# check environment
#
f_envcheck()
{
	local ssl_lib tmp

	# check backup directory
	#
	if [ ! -d "${ban_backupdir}" ]
	then
		f_log "err" "the backup directory '${ban_backupdir}' does not exist/is not mounted yet, please create the directory or raise the 'ban_triggerdelay' to defer the banIP start"
	fi

	# check fetch utility
	#
	case "${ban_fetchutil}" in
		"uclient-fetch")
			if [ -f "/lib/libustream-ssl.so" ]
			then
				ban_fetchparm="${ban_fetchparm:-"--timeout=20 --no-check-certificate -O"}"
				ssl_lib="libustream-ssl"
			fi
		;;
		"wget")
			ban_fetchparm="${ban_fetchparm:-"--no-cache --no-cookies --max-redirect=0 --timeout=20 --no-check-certificate -O"}"
			ssl_lib="built-in"
		;;
		"curl")
			ban_fetchparm="${ban_fetchparm:-"--connect-timeout 20 --insecure -o"}"
			ssl_lib="built-in"
		;;
		"aria2c")
			ban_fetchparm="${ban_fetchparm:-"--timeout=20 --allow-overwrite=true --auto-file-renaming=false --check-certificate=false -o"}"
			ssl_lib="built-in"
		;;
	esac
	ban_fetchutil="$(command -v "${ban_fetchutil}")"
	ban_fetchinfo="${ban_fetchutil:-"-"} (${ssl_lib:-"-"})"

	if [ ! -x "${ban_fetchutil}" ] || [ -z "${ban_fetchutil}" ] || [ -z "${ban_fetchparm}" ]
	then
		f_log "err" "download utility not found, please install 'uclient-fetch' with the 'libustream-mbedtls' ssl library or the full 'wget' package"
	fi

	# get wan device and wan subnets
	#
	if [ "${ban_automatic}" = "1" ]
	then
		network_find_wan ban_iface
		if [ -z "${ban_iface}" ]
		then
			network_find_wan6 ban_iface
		fi
	fi

	for iface in ${ban_iface}
	do
		network_get_device tmp "${iface}"
		if [ -n "${tmp}" ]
		then
			ban_dev="${ban_dev} ${tmp}"
		else
			network_get_physdev tmp "${iface}"
			if [ -n "${tmp}" ]
			then
				ban_dev="${ban_dev} ${tmp}"
			fi
		fi
		network_get_subnets tmp "${iface}"
		if [ -n "${tmp}" ]
		then
			ban_subnets="${ban_subnets} ${tmp}"
		fi
		network_get_subnets6 tmp "${iface}"
		if [ -n "${tmp}" ]
		then
			ban_subnets6="${ban_subnets6} ${tmp}"
		fi
	done

	if [ -z "${ban_iface}" ] || [ -z "${ban_dev}" ]
	then
		f_log "err" "wan interface(s)/device(s) (${ban_iface:-"-"}/${ban_dev:-"-"}) not found, please please check your configuration"
	fi
	ban_dev_all="$(${ban_ip} link show | awk 'BEGIN{FS="[@: ]"}/^[0-9:]/{if(($3!="lo")&&($3!="br-lan")){print $3}}')"
	uci_set banip global ban_iface "${ban_iface}"
	uci_commit banip

	f_jsnup "running"
	f_log "info" "start banIP processing (${ban_action})"
}

# create temporary files and directories
#
f_temp()
{
	if [ -d "/tmp" ] && [ -z "${ban_tmpdir}" ]
	then
		ban_tmpdir="$(mktemp -p /tmp -d)"
		ban_tmpload="$(mktemp -p "${ban_tmpdir}" -tu)"
		ban_tmpfile="$(mktemp -p "${ban_tmpdir}" -tu)"
	elif [ ! -d "/tmp" ]
	then
		f_log "err" "the temp directory '/tmp' does not exist/is not mounted yet, please create the directory or raise the 'ban_triggerdelay' to defer the banIP start"
	fi

	if [ ! -s "${ban_pidfile}" ]
	then
		printf "%s" "${$}" > "${ban_pidfile}"
	fi
}

# remove temporary files and directories
#
f_rmtemp()
{
	if [ -d "${ban_tmpdir}" ]
	then
		rm -rf "${ban_tmpdir}"
	fi
	> "${ban_pidfile}"
}

# remove backup files
#
f_rmbackup()
{
	if [ -d "${ban_backupdir}" ]
	then
		rm -f "${ban_backupdir}"/banIP.*.gz
	fi
}

# iptables rules engine
#
f_iptrule()
{
	local rc timeout="-w 5" action="${1}" rule="${2}"

	if [ "${src_name##*_}" = "6" ]
	then
		if [ -x "${ban_ipt6}" ]
		then
			rc="$("${ban_ipt6}" "${timeout}" -C ${rule} 2>/dev/null; printf "%u" ${?})"

			if { [ "${rc}" -ne 0 ] && { [ "${action}" = "-A" ] || [ "${action}" = "-I" ]; } } || \
				{ [ "${rc}" -eq 0 ] && [ "${action}" = "-D" ]; }
			then
				"${ban_ipt6}" "${timeout}" "${action}" ${rule}
			fi
		fi
	else
		if [ -x "${ban_ipt}" ]
		then
			rc="$("${ban_ipt}" "${timeout}" -C ${rule} 2>/dev/null; printf "%u" ${?})"

			if { [ "${rc}" -ne 0 ] && { [ "${action}" = "-A" ] || [ "${action}" = "-I" ]; } } || \
				{ [ "${rc}" -eq 0 ] && [ "${action}" = "-D" ]; }
			then
				"${ban_ipt}" "${timeout}" "${action}" ${rule}
			fi
		fi
	fi
}

# remove/add iptables rules
#
f_iptadd()
{
	local rm="${1}" dev

	for dev in ${ban_dev_all}
	do
		f_iptrule "-D" "${ban_chain} -i ${dev} -m conntrack --ctstate NEW -m set --match-set ${src_name} src -j ${target_src}"
		f_iptrule "-D" "${ban_chain} -o ${dev} -m conntrack --ctstate NEW -m set --match-set ${src_name} dst -j ${target_dst}"
	done

	if [ -z "${rm}" ] && [ "${cnt}" -gt 0 ]
	then
		if [ "${src_ruletype}" != "dst" ]
		then
			if [ "${src_name##*_}" = "6" ]
			then
				# dummy, special IPv6 rules
				/bin/true
			else
				f_iptrule "-I" "${wan_input} -p udp --dport 67:68 --sport 67:68 -j RETURN"
			fi
			f_iptrule "-A" "${wan_input} -j ${ban_chain}"
			f_iptrule "-A" "${wan_forward} -j ${ban_chain}"
			for dev in ${ban_dev}
			do
				f_iptrule "${action:-"-A"}" "${ban_chain} -i ${dev} -m conntrack --ctstate NEW -m set --match-set ${src_name} src -j ${target_src}"
			done
		fi
		if [ "${src_ruletype}" != "src" ]
		then
			if [ "${src_name##*_}" = "6" ]
			then
				# dummy, special IPv6 rules
				/bin/true
			else
				f_iptrule "-I" "${lan_input} -p udp --dport 67:68 --sport 67:68 -j RETURN"
			fi
			f_iptrule "-A" "${lan_input} -j ${ban_chain}"
			f_iptrule "-A" "${lan_forward} -j ${ban_chain}"
			for dev in ${ban_dev}
			do
				f_iptrule "${action:-"-A"}" "${ban_chain} -o ${dev} -m conntrack --ctstate NEW -m set --match-set ${src_name} dst -j ${target_dst}"
			done
		fi
	else
		if [ -x "${ban_ipset}" ] && [ -n "$("${ban_ipset}" -q -n list "${src_name}")" ]
		then
			"${ban_ipset}" -q destroy "${src_name}"
		fi
	fi
}

# ipset/iptables actions
#
f_ipset()
{
	local out_rc source action ruleset ruleset_6 rule cnt=0 cnt_ip=0 cnt_cidr=0 timeout="-w 5" mode="${1}" in_rc="${src_rc:-0}"

	if [ "${src_name%_6*}" = "whitelist" ]
	then
		target_src="RETURN"
		target_dst="RETURN"
		action="-I"
	fi

	case "${mode}" in
		"backup")
			gzip -cf "${tmp_load}" 2>/dev/null > "${ban_backupdir}/banIP.${src_name}.gz"
			out_rc="${?:-"${in_rc}"}"
			f_log "debug" "f_ipset ::: name: ${src_name:-"-"}, mode: ${mode:-"-"}, out_rc: ${out_rc}"
			return "${out_rc}"
		;;
		"restore")
			if [ -f "${ban_backupdir}/banIP.${src_name}.gz" ]
			then
				zcat "${ban_backupdir}/banIP.${src_name}.gz" 2>/dev/null > "${tmp_load}"
				out_rc="${?}"
			fi
			out_rc="${out_rc:-"${in_rc}"}"
			f_log "debug" "f_ipset ::: name: ${src_name:-"-"}, mode: ${mode:-"-"}, out_rc: ${out_rc}"
			return "${out_rc}"
		;;
		"remove")
			if [ -f "${ban_backupdir}/banIP.${src_name}.gz" ]
			then
				rm -f "${ban_backupdir}/banIP.${src_name}.gz"
				out_rc="${?}"
			fi
			out_rc="${out_rc:-"${in_rc}"}"
			f_log "debug" "f_ipset ::: name: ${src_name:-"-"}, mode: ${mode:-"-"}, out_rc: ${out_rc}"
			return "${out_rc}"
		;;
		"initial")
			if [ -x "${ban_ipt}" ] && [ -z "$("${ban_ipt}" "${timeout}" -nL "${ban_chain}" 2>/dev/null)" ]
			then
				"${ban_ipt}" "${timeout}" -N "${ban_chain}"
			elif [ -x "${ban_ipt}" ]
			then
				src_name="ruleset"
				ruleset="${ban_wan_input_chain:-"input_wan_rule"} ${ban_wan_forward_chain:-"forwarding_wan_rule"} ${ban_lan_input_chain:-"input_lan_rule"} ${ban_lan_forward_chain:-"forwarding_lan_rule"}"
				for rule in ${ruleset}
				do
					f_iptrule "-D" "${rule} -j ${ban_chain}"
				done
			fi
			if [ -x "${ban_ipt6}" ] && [ -z "$("${ban_ipt6}" "${timeout}" -nL "${ban_chain}" 2>/dev/null)" ]
			then
				"${ban_ipt6}" "${timeout}" -N "${ban_chain}"
			elif [ -x "${ban_ipt6}" ]
			then
				src_name="ruleset_6"
				ruleset_6="${ban_wan_input_chain_6:-"input_wan_rule"} ${ban_wan_forward_chain_6:-"forwarding_wan_rule"} ${ban_lan_input_chain_6:-"input_lan_rule"} ${ban_lan_forward_chain_6:-"forwarding_lan_rule"}"
				for rule in ${ruleset_6}
				do
					f_iptrule "-D" "${rule} -j ${ban_chain}"
				done
			fi
			f_log "debug" "f_ipset ::: name: -, mode: ${mode:-"-"}, chain: ${ban_chain:-"-"}, ruleset: ${ruleset:-"-"}, ruleset_6: ${ruleset_6:-"-"}"
		;;
		"create")
			if [ -x "${ban_ipset}" ]
			then
				if [ -s "${tmp_file}" ] && [ -z "$("${ban_ipset}" -q -n list "${src_name}")" ]
				then
					"${ban_ipset}" -q create "${src_name}" hash:"${src_settype}" hashsize 64 maxelem 262144 family "${src_setipv}" counters
				else
					"${ban_ipset}" -q flush "${src_name}"
				fi
				if [ -s "${tmp_file}" ]
				then
					"${ban_ipset}" -! restore < "${tmp_file}"
					out_rc="${?}"
					"${ban_ipset}" -q save "${src_name}" > "${tmp_file}"
					cnt="$(($(wc -l 2>/dev/null < "${tmp_file}")-1))"
					cnt_cidr="$(grep -cF "/" "${tmp_file}")"
					cnt_ip="$((cnt-cnt_cidr))"
					printf "%s\\n" "1" > "${tmp_set}"
					printf "%s\\n" "${cnt}" > "${tmp_cnt}"
				fi
				f_iptadd
			fi
			end_ts="$(date +%s)"
			out_rc="${out_rc:-"${in_rc}"}"
			f_log "debug" "f_ipset ::: name: ${src_name:-"-"}, mode: ${mode:-"-"}, settype: ${src_settype:-"-"}, setipv: ${src_setipv:-"-"}, ruletype: ${src_ruletype:-"-"}, count(sum/ip/cidr): ${cnt}/${cnt_ip}/${cnt_cidr}, time: $((end_ts-start_ts)), out_rc: ${out_rc}"
		;;
		"refresh")
			if [ -x "${ban_ipset}" ] && [ -n "$("${ban_ipset}" -q -n list "${src_name}")" ]
			then
				"${ban_ipset}" -q save "${src_name}" > "${tmp_file}"
				out_rc="${?}"
				if [ -s "${tmp_file}" ]
				then
					cnt="$(($(wc -l 2>/dev/null < "${tmp_file}")-1))"
					cnt_cidr="$(grep -cF "/" "${tmp_file}")"
					cnt_ip="$((cnt-cnt_cidr))"
					printf "%s\\n" "1" > "${tmp_set}"
					printf "%s\\n" "${cnt}" > "${tmp_cnt}"
				fi
				f_iptadd
			fi
			end_ts="$(date +%s)"
			out_rc="${out_rc:-"${in_rc}"}"
			f_log "debug" "f_ipset ::: name: ${src_name:-"-"}, mode: ${mode:-"-"}, count: ${cnt}/${cnt_ip}/${cnt_cidr}, time: $((end_ts-start_ts)), out_rc: ${out_rc}"
			return "${out_rc}"
		;;
		"flush")
			f_iptadd "remove"

			if [ -x "${ban_ipset}" ] && [ -n "$("${ban_ipset}" -q -n list "${src_name}")" ]
			then
				"${ban_ipset}" -q flush "${src_name}"
				"${ban_ipset}" -q destroy "${src_name}"
			fi
			f_log "debug" "f_ipset ::: name: ${src_name:-"-"}, mode: ${mode:-"-"}"
		;;
		"destroy")
			if [ -x "${ban_ipt}" ] && [ -x "${ban_ipt_save}" ] && [ -x "${ban_ipt_restore}" ] && \
				[ -n "$("${ban_ipt}" "${timeout}" -nL "${ban_chain}" 2>/dev/null)" ]
			then
				"${ban_ipt_save}" | grep -v -- "-j ${ban_chain}" | "${ban_ipt_restore}"
				"${ban_ipt}" "${timeout}" -F "${ban_chain}"
				"${ban_ipt}" "${timeout}" -X "${ban_chain}"
			fi
			if [ -x "${ban_ipt6}" ] && [ -x "${ban_ipt6_save}" ] && [ -x "${ban_ipt6_restore}" ] && \
				[ -n "$("${ban_ipt6}" "${timeout}" -nL "${ban_chain}" 2>/dev/null)" ]
			then
				"${ban_ipt6_save}" | grep -v -- "-j ${ban_chain}" | "${ban_ipt6_restore}"
				"${ban_ipt6}" "${timeout}" -F "${ban_chain}"
				"${ban_ipt6}" "${timeout}" -X "${ban_chain}"
			fi
			for source in ${ban_sources}
			do
				if [ -x "${ban_ipset}" ] && [ -n "$("${ban_ipset}" -q -n list "${source}")" ]
				then
					"${ban_ipset}" -q destroy "${source}"
				fi
			done
			f_log "debug" "f_ipset ::: name: ${src_name:-"-"}, mode: ${mode:-"-"}"
		;;
	esac
}

# write to syslog
#
f_log()
{
	local class="${1}" log_msg="${2}"

	if [ -n "${log_msg}" ] && { [ "${class}" != "debug" ] || [ "${ban_debug}" -eq 1 ]; }
	then
		logger -p "${class}" -t "banIP-[${ban_ver}]" "${log_msg}"
		if [ "${class}" = "err" ]
		then
			f_jsnup error
			f_ipset destroy
			f_rmbackup
			f_rmtemp
			logger -p "${class}" -t "banIP-[${ban_ver}]" "Please also check 'https://github.com/openwrt/packages/blob/master/net/banip/files/README.md'"
			exit 1
		fi
	fi
}

# main function for banIP processing
#
f_main()
{
	local pid pid_list start_ts end_ts ip tmp_raw tmp_cnt tmp_load tmp_file mem_total mem_free cnt=1
	local src_name src_on src_url src_rset src_setipv src_settype src_ruletype src_cat src_log src_addon src_rc
	local wan_input wan_forward lan_input lan_forward target_src target_dst log_content

	log_content="$(logread -e "${ban_sshdaemon}")"
	mem_total="$(awk '/^MemTotal/ {print int($2/1000)}' "/proc/meminfo" 2>/dev/null)"
	mem_free="$(awk '/^MemFree/ {print int($2/1000)}' "/proc/meminfo" 2>/dev/null)"
	f_log "debug" "f_main  ::: fetch_util: ${ban_fetchinfo:-"-"}, fetch_parm: ${ban_fetchparm:-"-"}, ssh_daemon: ${ban_sshdaemon}, interface(s): ${ban_iface:-"-"}, device(s): ${ban_dev:-"-"}, all_devices: ${ban_dev_all:-"-"}, backup_dir: ${ban_backupdir:-"-"}, mem_total: ${mem_total:-0}, mem_free: ${mem_free:-0}, max_queue: ${ban_maxqueue}"

	f_ipset initial

	# main loop
	#
	for src_name in ${ban_sources}
	do
		unset src_on
		if [ "${src_name##*_}" = "6" ]
		then
			if [ -x "${ban_ipt6}" ]
			then
				src_on="$(eval printf "%s" \"\$\{ban_src_on_6_${src_name%_6*}\}\")"
				src_url="$(eval printf "%s" \"\$\{ban_src_6_${src_name%_6*}\}\")"
				src_rset="$(eval printf "%s" \"\$\{ban_src_rset_6_${src_name%_6*}\}\")"
				src_setipv="inet6"
				wan_input="${ban_wan_input_chain_6:-"input_wan_rule"}"
				wan_forward="${ban_wan_forward_chain_6:-"forwarding_wan_rule"}"
				lan_input="${ban_lan_input_chain_6:-"input_lan_rule"}"
				lan_forward="${ban_lan_forward_chain_6:-"forwarding_lan_rule"}"
				target_src="${ban_target_src_6:-"DROP"}"
				target_dst="${ban_target_dst_6:-"REJECT"}"
			fi
		else
			if [ -x "${ban_ipt}" ]
			then
				src_on="$(eval printf "%s" \"\$\{ban_src_on_${src_name}\}\")"
				src_url="$(eval printf "%s" \"\$\{ban_src_${src_name}\}\")"
				src_rset="$(eval printf "%s" \"\$\{ban_src_rset_${src_name}\}\")"
				src_setipv="inet"
				wan_input="${ban_wan_input_chain:-"input_wan_rule"}"
				wan_forward="${ban_wan_forward_chain:-"forwarding_wan_rule"}"
				lan_input="${ban_lan_input_chain:-"input_lan_rule"}"
				lan_forward="${ban_lan_forward_chain:-"forwarding_lan_rule"}"
				target_src="${ban_target_src:-"DROP"}"
				target_dst="${ban_target_dst:-"REJECT"}"
			fi
		fi
		src_settype="$(eval printf "%s" \"\$\{ban_src_settype_${src_name%_6*}\}\")"
		src_ruletype="$(eval printf "%s" \"\$\{ban_src_ruletype_${src_name%_6*}\}\")"
		src_cat="$(eval printf "%s" \"\$\{ban_src_cat_${src_name%_6*}\}\")"
		src_addon=""
		src_rc=4
		tmp_load="${ban_tmpload}.${src_name}"
		tmp_file="${ban_tmpfile}.${src_name}"
		tmp_raw="${tmp_load}.raw"
		tmp_cnt="${tmp_file}.cnt"
		tmp_set="${tmp_file}.setcnt"

		# basic pre-checks
		#
		f_log "debug" "f_main  ::: name: ${src_name}, src_on: ${src_on:-"-"}"

		if [ -z "${src_on}" ] || [ "${src_on}" != "1" ] || [ -z "${src_url}" ] || \
			[ -z "${src_rset}" ] || [ -z "${src_settype}" ] || [ -z "${src_ruletype}" ]
		then
			f_ipset flush
			f_ipset remove
			continue
		elif [ "${ban_action}" = "refresh" ] && [ ! -f "${src_url}" ]
		then
			start_ts="$(date +%s)"
			f_ipset refresh
			if [ "${?}" -eq 0 ]
			then
				continue
			fi
		fi

		# download queue processing
		#
		(
			start_ts="$(date +%s)"
			if [ "${ban_action}" = "start" ] && [ ! -f "${src_url}" ]
			then
				f_ipset restore
			fi
			src_rc="${?}"
			if [ "${src_rc}" -ne 0 ] || [ ! -s "${tmp_load}" ]
			then
				if [ -f "${src_url}" ]
				then
					src_log="$(cat "${src_url}" 2>/dev/null > "${tmp_load}")"
					src_rc="${?}"
					case "${src_name}" in
						"whitelist")
							src_addon="${ban_subnets}"
						;;
						"whitelist_6")
							src_addon="${ban_subnets6}"
						;;
						"blacklist")
							if [ "${ban_sshdaemon}" = "dropbear" ]
							then
								pid_list="$(printf "%s\\n" "${log_content}" | grep -F "Exit before auth" | awk 'match($0,/(\[[0-9]+\])/){ORS=" ";print substr($0,RSTART,RLENGTH)}')"
								for pid in ${pid_list}
								do
									src_addon="${src_addon} $(printf "%s\\n" "${log_content}" | grep -F "${pid}" | awk 'match($0,/([0-9]{1,3}\.){3}[0-9]{1,3}/){ORS=" ";print substr($0,RSTART,RLENGTH)}')"
								done
							elif [ "${ban_sshdaemon}" = "sshd" ]
							then
								src_addon="$(printf "%s\\n" "${log_content}" | grep -E "[0-9]+ \[preauth\]$" | awk 'match($0,/([0-9]{1,3}\.){3}[0-9]{1,3}/){ORS=" ";print substr($0,RSTART,RLENGTH)}')"
							fi
						;;
						"blacklist_6")
							if [ "${ban_sshdaemon}" = "dropbear" ]
							then
								pid_list="$(printf "%s\\n" "${log_content}" | grep -F "Exit before auth" | awk 'match($0,/(\[[0-9]+\])/){ORS=" ";print substr($0,RSTART,RLENGTH)}')"
								for pid in ${pid_list}
								do
									src_addon="${src_addon} $(printf "%s\\n" "${log_content}" | grep -F "${pid}" | awk 'match($0,/([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}/){ORS=" ";print substr($0,RSTART,RLENGTH)}')"
								done
							elif [ "${ban_sshdaemon}" = "sshd" ]
							then
								src_addon="$(printf "%s\\n" "${log_content}" | grep -E "[0-9]+ \[preauth\]$" | awk 'match($0,/([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}/){ORS=" ";print substr($0,RSTART,RLENGTH)}')"
							fi
						;;
					esac
					for ip in ${src_addon}
					do
						if [ -z "$(grep -F "${ip}" "${src_url}")" ]
						then
							printf "%s\\n" "${ip}" >> "${tmp_load}"
							if { [ "${src_name//_*/}" = "blacklist" ] && [ "${ban_autoblacklist}" -eq 1 ]; } || \
								{ [ "${src_name//_*/}" = "whitelist" ] && [ "${ban_autowhitelist}" -eq 1 ]; }
							then
								printf "%s\\n" "${ip}" >> "${src_url}"
							fi
						fi
					done
				elif [ -n "${src_cat}" ]
				then
					if [ "${src_cat//[0-9]/}" != "${src_cat}" ]
					then
						for as in ${src_cat}
						do
							src_log="$("${ban_fetchutil}" ${ban_fetchparm} "${tmp_raw}" "${src_url}AS${as}" 2>&1)"
							src_rc="${?}"
							if [ "${src_rc}" -eq 0 ]
							then
								jsonfilter -i "${tmp_raw}" -e '@.data.prefixes.*.prefix' 2>/dev/null >> "${tmp_load}"
							else
								break
							fi
						done
						if [ "${src_rc}" -eq 0 ]
						then
							f_ipset backup
						elif [ "${ban_action}" != "start" ]
						then
							f_ipset restore
						fi
					else
						for co in ${src_cat}
						do
							src_log="$("${ban_fetchutil}" ${ban_fetchparm} "${tmp_raw}" "${src_url}${co}&v4_format=prefix" 2>&1)"
							src_rc="${?}"
							if [ "${src_rc}" -eq 0 ]
							then
								if [ "${src_name##*_}" = "6" ]
								then
									jsonfilter -i "${tmp_raw}" -e '@.data.resources.ipv6.*' 2>/dev/null >> "${tmp_load}"
								else
									jsonfilter -i "${tmp_raw}" -e '@.data.resources.ipv4.*' 2>/dev/null >> "${tmp_load}"
								fi
							else
								break
							fi
						done
						if [ "${src_rc}" -eq 0 ]
						then
							f_ipset backup
						elif [ "${ban_action}" != "start" ]
						then
							f_ipset restore
						fi
					fi
				else
					src_log="$("${ban_fetchutil}" ${ban_fetchparm} "${tmp_raw}" "${src_url}" 2>&1)"
					src_rc="${?}"
					if [ "${src_rc}" -eq 0 ]
					then
						zcat "${tmp_raw}" 2>/dev/null > "${tmp_load}"
						src_rc="${?}"
						if [ "${src_rc}" -ne 0 ]
						then
							mv -f "${tmp_raw}" "${tmp_load}"
							src_rc="${?}"
						fi
						if [ "${src_rc}" -eq 0 ]
						then
							f_ipset backup
							src_rc="${?}"
						fi
					elif [ "${ban_action}" != "start" ]
					then
						f_ipset restore
						src_rc="${?}"
					fi
				fi
			fi

			if [ "${src_rc}" -eq 0 ]
			then
				awk "${src_rset}" "${tmp_load}" 2>/dev/null > "${tmp_file}"
				src_rc="${?}"
				if [ "${src_rc}" -eq 0 ]
				then
					f_ipset create
					src_rc="${?}"
				elif [ "${ban_action}" != "refresh" ]
				then
					f_ipset refresh
					src_rc="${?}"
				fi
			else
				src_log="$(printf "%s" "${src_log}" | awk '{ORS=" ";print $0}')"
				if [ "${ban_action}" != "refresh" ]
				then
					f_ipset refresh
					src_rc="${?}"
				fi
				f_log "debug" "f_main  ::: name: ${src_name}, url: ${src_url}, rc: ${src_rc}, log: ${src_log:-"-"}"
			fi
		)&
		hold="$((cnt%ban_maxqueue))"
		if [ "${hold}" -eq 0 ]
		then
			wait
		fi
		cnt="$((cnt+1))"
	done
	wait

	for cnt in $(cat "${ban_tmpfile}".*.setcnt 2>/dev/null)
	do
		ban_setcnt="$((ban_setcnt+cnt))"
	done
	for cnt in $(cat "${ban_tmpfile}".*.cnt 2>/dev/null)
	do
		ban_cnt="$((ban_cnt+cnt))"
	done
	f_log "info" "${ban_setcnt} IPSets with overall ${ban_cnt} IPs/Prefixes loaded successfully (${ban_sysver})"
	f_jsnup
	f_rmtemp
}

# update runtime information
#
f_jsnup()
{
	local rundate status="${1:-"enabled"}"

	rundate="$(/bin/date "+%d.%m.%Y %H:%M:%S")"
	ban_cntinfo="${ban_setcnt} IPSets with overall ${ban_cnt} IPs/Prefixes"

	> "${ban_rtfile}"
	json_load_file "${ban_rtfile}" >/dev/null 2>&1
	json_init
	json_add_object "data"
	json_add_string "status" "${status}"
	json_add_string "version" "${ban_ver}"
	json_add_string "fetch_info" "${ban_fetchinfo:-"-"}"
	json_add_string "ipset_info" "${ban_cntinfo:-"-"}"
	json_add_string "backup_dir" "${ban_backupdir}"
	json_add_string "last_run" "${rundate:-"-"}"
	json_add_string "system" "${ban_sysver}"
	json_close_object
	json_dump > "${ban_rtfile}"
	f_log "debug" "f_jsnup ::: status: ${status}, setcnt: ${ban_setcnt}, cnt: ${ban_cnt}"
}

# source required system libraries
#
if [ -r "/lib/functions.sh" ] && [ -r "/lib/functions/network.sh" ] && [ -r "/usr/share/libubox/jshn.sh" ]
then
	. "/lib/functions.sh"
	. "/lib/functions/network.sh"
	. "/usr/share/libubox/jshn.sh"
else
	f_log "err" "system libraries not found"
fi

# handle different banIP actions
#
f_envload
case "${ban_action}" in
	"stop")
		f_jsnup stopped
		f_ipset destroy
		f_rmbackup
		f_rmtemp
	;;
	"start"|"restart"|"reload"|"refresh")
		f_envcheck
		f_main
	;;
esac
