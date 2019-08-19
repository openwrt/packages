#!/bin/sh
# dns based ad/abuse domain blocking
# written by Dirk Brenken (dev@brenken.org)

# This is free software, licensed under the GNU General Public License v3.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# set initial defaults
#
LC_ALL=C
PATH="/usr/sbin:/usr/bin:/sbin:/bin"
adb_ver="3.8.1"
adb_sysver="unknown"
adb_enabled=0
adb_debug=0
adb_forcedns=0
adb_maxqueue=4
adb_mail=0
adb_mcnt=0
adb_trigger="wan"
adb_triggerdelay=0
adb_backupdir="/tmp"
adb_fetchutil="uclient-fetch"
adb_dns="dnsmasq"
adb_dnsvariant="nxdomain"
adb_dnsprefix="adb_list"
adb_dnsfile="${adb_dnsprefix}.overall"
adb_dnsfilereset="false"
adb_dnsflush=0
adb_blacklist="/etc/adblock/adblock.blacklist"
adb_whitelist="/etc/adblock/adblock.whitelist"
adb_rtfile="/tmp/adb_runtime.json"
adb_report=0
adb_repiface="br-lan"
adb_replisten="53"
adb_repdir="/tmp"
adb_reputil="$(command -v tcpdump)"
adb_repchunkcnt="5"
adb_repchunksize="1"
adb_cnt=""
adb_rc=0
adb_action="${1:-"start"}"
adb_pidfile="/var/run/adblock.pid"
adb_ubusservice="/etc/adblock/adblock.service"
adb_mailservice="/etc/adblock/adblock.mail"
adb_sources=""

# load adblock environment
#
f_load()
{
	local dns_up sys_call sys_desc sys_model cnt=0

	# get system information
	#
	sys_call="$(ubus -S call system board 2>/dev/null)"
	if [ -n "${sys_call}" ]
	then
		sys_desc="$(printf "%s" "${sys_call}" | jsonfilter -e '@.release.description')"
		sys_model="$(printf "%s" "${sys_call}" | jsonfilter -e '@.model')"
		adb_sysver="${sys_model}, ${sys_desc}"
	fi

	# parse 'global' and 'extra' section by callback
	#
	config_cb()
	{
		local type="${1}"
		if [ "${type}" = "adblock" ]
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
		local value opt section="${1}" options="enabled adb_src adb_src_rset adb_src_cat"
		eval "adb_sources=\"${adb_sources} ${section}\""
		for opt in ${options}
		do
			config_get value "${section}" "${opt}"
			if [ -n "${value}" ]
			then
				eval "${opt}_${section}=\"${value}\""
			fi
		done
	}

	# load adblock config
	#
	config_load adblock
	config_foreach parse_config source

	# version check
	#
	if [ -z "${adb_basever}" ] || [ "${adb_ver%.*}" != "${adb_basever}" ]
	then
		f_log "info" "your adblock config seems to be too old, please update your config with the '--force-maintainer' opkg option"
		exit 0
	fi

	# set dns backend
	#
	case "${adb_dns}" in
		"dnsmasq")
			adb_dnsinstance="${adb_dnsinstance:-"0"}"
			adb_dnsuser="${adb_dnsuser:-"dnsmasq"}"
			adb_dnsdir="${adb_dnsdir:-"/tmp"}"
			adb_dnsheader=""
			if [ "${adb_dnsvariant}" = "nxdomain" ]
			then
				adb_dnsdeny="awk '{print \"server=/\"\$0\"/\"}'"
				adb_dnsallow="awk '{print \"server=/\"\$0\"/#\"}'"
			elif [ "${adb_dnsvariant}" = "null (IPv4)" ]
			then
				adb_dnsdeny="awk '{print \"0.0.0.0\\t\"\$0\"\"}'"
			elif [ "${adb_dnsvariant}" = "null (IPv4/IPv6)" ]
			then
				adb_dnsdeny="awk '{print \"0.0.0.0\\t\"\$0\"\\n::\\t\"\$0\"\"}'"
			fi
			adb_dnsallow=""
		;;
		"unbound")
			adb_dnsinstance="${adb_dnsinstance:-"0"}"
			adb_dnsuser="${adb_dnsuser:-"unbound"}"
			adb_dnsdir="${adb_dnsdir:-"/var/lib/unbound"}"
			adb_dnsheader=""
			adb_dnsdeny="awk '{print \"local-zone: \\042\"\$0\"\\042 static\"}'"
			adb_dnsallow="awk '{print \"local-zone: \\042\"\$0\"\\042 transparent\"}'"
		;;
		"named")
			adb_dnsinstance="${adb_dnsinstance:-"0"}"
			adb_dnsuser="${adb_dnsuser:-"bind"}"
			adb_dnsdir="${adb_dnsdir:-"/var/lib/bind"}"
			adb_dnsheader="\$TTL 2h"$'\n'"@ IN SOA localhost. root.localhost. (1 6h 1h 1w 2h)"$'\n'"  IN NS localhost."
			adb_dnsdeny="awk '{print \"\"\$0\" CNAME .\\n*.\"\$0\" CNAME .\"}'"
			adb_dnsallow="awk '{print \"\"\$0\" CNAME rpz-passthru.\\n*.\"\$0\" CNAME rpz-passthru.\"}'"
		;;
		"kresd")
			adb_dnsinstance="${adb_dnsinstance:-"0"}"
			adb_dnsuser="${adb_dnsuser:-"root"}"
			adb_dnsdir="${adb_dnsdir:-"/etc/kresd"}"
			adb_dnsheader="\$TTL 2h"$'\n'"@ IN SOA localhost. root.localhost. (1 6h 1h 1w 2h)"$'\n'"  IN NS  localhost."
			adb_dnsdeny="awk '{print \"\"\$0\" CNAME .\\n*.\"\$0\" CNAME .\"}'"
			adb_dnsallow="awk '{print \"\"\$0\" CNAME rpz-passthru.\\n*.\"\$0\" CNAME rpz-passthru.\"}'"
		;;
	esac

	# status check
	#
	if [ "${adb_enabled}" -eq 0 ]
	then
		f_extconf
		f_temp
		f_rmdns
		f_jsnup "disabled"
		f_log "info" "adblock is currently disabled, please set the config option 'adb_enabled' to '1' to use this service"
		exit 0
	fi

	# dns backend check
	#
	if [ -d "${adb_dnsdir}" ] && [ ! -f "${adb_dnsdir}/${adb_dnsfile}" ]
	then
		printf "%s\\n" "${adb_dnsheader}" > "${adb_dnsdir}/${adb_dnsfile}"
	fi

	if [ "${adb_action}" = "start" ] && [ "${adb_trigger}" = "timed" ]
	then
		sleep ${adb_triggerdelay}
	fi

	while [ "${cnt}" -le 30 ]
	do
		dns_up="$(ubus -S call service list "{\"name\":\"${adb_dns}\"}" 2>/dev/null | jsonfilter -l1 -e "@[\"${adb_dns}\"].instances.*.running" 2>/dev/null)"
		if [ "${dns_up}" = "true" ]
		then
			break
		fi
		sleep 1
		cnt=$((cnt+1))
	done

	if [ "${dns_up}" != "true" ] || [ -z "${adb_dns}" ] || [ ! -x "$(command -v ${adb_dns})" ]
	then
		f_log "err" "'${adb_dns}' not running or executable"
	elif [ ! -d "${adb_dnsdir}" ]
	then
		f_log "err" "'${adb_dnsdir}' backend directory not found"
	fi
}

# check & set environment
#
f_env()
{
	local ssl_lib

	f_log "info" "adblock instance started ::: action: ${adb_action}, priority: ${adb_nice:-"0"}, pid: ${$}"
	f_jsnup "running"
	f_extconf

	# check backup directory
	#
	if [ ! -d "${adb_backupdir}" ]
	then
		f_log "err" "the backup directory '${adb_backupdir}' does not exist/is not mounted yet, please create the directory or raise the 'adb_triggerdelay' to defer the adblock start"
	fi

	# check fetch utility
	#
	case "${adb_fetchutil}" in
		uclient-fetch)
			if [ -f "/lib/libustream-ssl.so" ]
			then
				adb_fetchparm="${adb_fetchparm:-"--timeout=10 --no-check-certificate -O"}"
				ssl_lib="libustream-ssl"
			else
				adb_fetchparm="${adb_fetchparm:-"--timeout=10 -O"}"
			fi
		;;
		wget)
			adb_fetchparm="${adb_fetchparm:-"--no-cache --no-cookies --max-redirect=0 --timeout=10 --no-check-certificate -O"}"
			ssl_lib="built-in"
		;;
		wget-nossl)
			adb_fetchparm="${adb_fetchparm:-"--no-cache --no-cookies --max-redirect=0 --timeout=10 -O"}"
		;;
		busybox)
			adb_fetchparm="${adb_fetchparm:-"-O"}"
		;;
		curl)
			adb_fetchparm="${adb_fetchparm:-"--connect-timeout 10 --insecure -o"}"
			ssl_lib="built-in"
		;;
		aria2c)
			adb_fetchparm="${adb_fetchparm:-"--timeout=10 --allow-overwrite=true --auto-file-renaming=false --check-certificate=false -o"}"
			ssl_lib="built-in"
		;;
	esac
	adb_fetchutil="$(command -v "${adb_fetchutil}")"

	if [ ! -x "${adb_fetchutil}" ] || [ -z "${adb_fetchutil}" ] || [ -z "${adb_fetchparm}" ]
	then
		f_log "err" "download utility not found, please install 'uclient-fetch' with 'libustream-mbedtls' or the full 'wget' package"
	fi
	adb_fetchinfo="${adb_fetchutil} (${ssl_lib:-"-"})"
	f_temp
}

# create temporary files and directories
#
f_temp()
{
	if [ -d "/tmp" ] && [ -z "${adb_tmpdir}" ]
	then
		adb_tmpdir="$(mktemp -p /tmp -d)"
		adb_tmpload="$(mktemp -p "${adb_tmpdir}" -tu)"
		adb_tmpfile="$(mktemp -p "${adb_tmpdir}" -tu)"
	elif [ ! -d "/tmp" ]
	then
		f_log "err" "the temp directory '/tmp' does not exist/is not mounted yet, please create the directory or raise the 'adb_triggerdelay' to defer the adblock start"
	fi
	if [ ! -s "${adb_pidfile}" ]
	then
		printf "%s" "${$}" > "${adb_pidfile}"
	fi
}

# remove temporary files and directories
#
f_rmtemp()
{
	if [ -d "${adb_tmpdir}" ]
	then
		rm -rf "${adb_tmpdir}"
	fi
	> "${adb_pidfile}"
}

# remove dns related files, services and directories
#
f_rmdns()
{
	if [ -n "${adb_dns}" ]
	then
		printf "%s\\n" "${adb_dnsheader}" > "${adb_dnsdir}"/"${adb_dnsfile}"
		> "${adb_rtfile}"
		rm -f "${adb_backupdir}"/"${adb_dnsprefix}"*".gz"
		f_dnsup
		f_rmtemp
	fi
	f_log "debug" "f_rmdns  ::: dns: ${adb_dns}, dns_dir: ${adb_dnsdir}, dns_prefix: ${adb_dnsprefix}, dns_file: ${adb_dnsfile}, rt_file: ${adb_rtfile}, backup_dir: ${adb_backupdir}"
}

# commit uci changes
#
f_uci()
{
	local change config="${1}"

	if [ -n "${config}" ]
	then
		change="$(uci -q changes "${config}" | awk '{ORS=" "; print $0}')"
		if [ -n "${change}" ]
		then
			uci_commit "${config}"
			case "${config}" in
				"firewall")
					/etc/init.d/firewall reload >/dev/null 2>&1
				;;
				*)
					/etc/init.d/"${adb_dns}" reload >/dev/null 2>&1
				;;
			esac
		fi
		f_log "debug" "f_uci    ::: config: ${config}, change: ${change}"
	fi
}

# list/overall count
#
f_count()
{
	local mode="${1}"

	adb_cnt=0
	if [ -s "${adb_dnsdir}/${adb_dnsfile}" ] && { [ -z "${mode}" ] || [ "${mode}" = "final" ]; }
	then
		adb_cnt="$(wc -l 2>/dev/null < "${adb_dnsdir}/${adb_dnsfile}")"
		if [ -s "${adb_tmpdir}/tmp.add.whitelist" ]
		then
			adb_cnt="$((adb_cnt-$(wc -l 2>/dev/null < "${adb_tmpdir}/tmp.add.whitelist")))"
		fi
		if [ "${adb_dns}" = "named" ] || [ "${adb_dns}" = "kresd" ] || { [ "${adb_dns}" = "dnsmasq" ] && [ "${adb_dnsvariant}" = "null (IPv4/IPv6)" ]; }
		then
			adb_cnt="$(((adb_cnt-$(printf "%s" "${adb_dnsheader}" | grep -c "^"))/2))"
		fi
	elif [ "${mode}" = "blacklist" ] && [ -s "${adb_tmpfile}.blacklist" ]
	then
		adb_cnt="$(wc -l 2>/dev/null < "${adb_tmpfile}.blacklist")"
	elif [ "${mode}" = "whitelist" ] && [ -s "${adb_tmpdir}/tmp.raw.whitelist" ]
	then
		adb_cnt="$(wc -l 2>/dev/null < "${adb_tmpdir}/tmp.raw.whitelist")"
	elif [ -s "${adb_tmpfile}" ]
	then
		adb_cnt="$(wc -l 2>/dev/null < "${adb_tmpfile}")"
	fi
}

# set external config options
#
f_extconf()
{
	local uci_config port port_list="53 853 5353"

	case "${adb_dns}" in
		"dnsmasq")
			uci_config="dhcp"
			if [ "${adb_dnsvariant}" = "nxdomain" ]
			then
				if [ "${adb_enabled}" -eq 1 ] && [ -z "$(uci_get dhcp "@dnsmasq[${adb_dnsinstance}]" serversfile | grep -Fo "${adb_dnsdir}/${adb_dnsfile}")" ]
				then
					uci_set dhcp "@dnsmasq[${adb_dnsinstance}]" serversfile "${adb_dnsdir}/${adb_dnsfile}"
					if [ "${adb_enabled}" -eq 1 ] && [ -n "$(uci_get dhcp "@dnsmasq[${adb_dnsinstance}]" addnhosts | grep -Fo "${adb_dnsdir}/${adb_dnsfile}")" ]
					then
						uci -q del_list dhcp.@dnsmasq[${adb_dnsinstance}].addnhosts="${adb_dnsdir}/${adb_dnsfile}"
					fi
				elif [ "${adb_enabled}" -eq 0 ] && [ -n "$(uci_get dhcp "@dnsmasq[${adb_dnsinstance}]" serversfile | grep -Fo "${adb_dnsdir}/${adb_dnsfile}")" ]
				then
					uci_remove dhcp "@dnsmasq[${adb_dnsinstance}]" serversfile
				fi
			elif [ "${adb_dnsvariant% *}" = "null" ]
			then
				if [ "${adb_enabled}" -eq 1 ] && [ -z "$(uci_get dhcp "@dnsmasq[${adb_dnsinstance}]" addnhosts | grep -Fo "${adb_dnsdir}/${adb_dnsfile}")" ]
				then
					uci -q add_list dhcp.@dnsmasq[${adb_dnsinstance}].addnhosts="${adb_dnsdir}/${adb_dnsfile}"
					if [ "${adb_enabled}" -eq 1 ] && [ -n "$(uci_get dhcp "@dnsmasq[${adb_dnsinstance}]" serversfile | grep -Fo "${adb_dnsdir}/${adb_dnsfile}")" ]
					then
						uci_remove dhcp "@dnsmasq[${adb_dnsinstance}]" serversfile
					fi
				elif [ "${adb_enabled}" -eq 0 ] && [ -n "$(uci_get dhcp "@dnsmasq[${adb_dnsinstance}]" addnhosts | grep -Fo "${adb_dnsdir}/${adb_dnsfile}")" ]
				then
					uci_remove dhcp "@dnsmasq[${adb_dnsinstance}]" addnhosts
				fi
			fi
		;;
		"kresd")
			uci_config="resolver"
			if [ "${adb_enabled}" -eq 1 ] && [ -z "$(uci_get resolver kresd rpz_file | grep -Fo "${adb_dnsdir}/${adb_dnsfile}")" ]
			then
				uci -q add_list resolver.kresd.rpz_file="${adb_dnsdir}/${adb_dnsfile}"
			elif [ "${adb_enabled}" -eq 0 ] && [ -n "$(uci_get resolver kresd rpz_file | grep -Fo "${adb_dnsdir}/${adb_dnsfile}")" ]
			then
				uci -q del_list resolver.kresd.rpz_file="${adb_dnsdir}/${adb_dnsfile}"
			fi
			if [ "${adb_enabled}" -eq 1 ] && [ "${adb_dnsflush}" -eq 0 ] && [ "$(uci_get resolver kresd keep_cache)" != "1" ]
			then
				uci_set resolver kresd keep_cache "1"
			elif [ "${adb_enabled}" -eq 0 ] || { [ "${adb_dnsflush}" -eq 1 ] && [ "$(uci_get resolver kresd keep_cache)" = "1" ]; }
			then
				uci_set resolver kresd keep_cache "0"
			fi
		;;
	esac
	f_uci "${uci_config}"

	uci_config="firewall"
	if [ "${adb_enabled}" -eq 1 ] && [ "${adb_forcedns}" -eq 1 ] && \
		[ -z "$(uci_get firewall adblock_dns_53)" ] && [ "$(/etc/init.d/firewall enabled; printf "%u" ${?})" -eq 0 ]
	then
		for port in ${port_list}
		do
			uci_add firewall "redirect" "adblock_dns_${port}"
			uci_set firewall "adblock_dns_${port}" "name" "Adblock DNS, port ${port}"
			uci_set firewall "adblock_dns_${port}" "src" "lan"
			uci_set firewall "adblock_dns_${port}" "proto" "tcp udp"
			uci_set firewall "adblock_dns_${port}" "src_dport" "${port}"
			uci_set firewall "adblock_dns_${port}" "dest_port" "${port}"
			uci_set firewall "adblock_dns_${port}" "target" "DNAT"
		done
	elif [ -n "$(uci_get firewall adblock_dns_53)" ] && { [ "${adb_enabled}" -eq 0 ] || [ "${adb_forcedns}" -eq 0 ]; }
	then
		for port in ${port_list}
		do
			uci_remove firewall "adblock_dns_${port}"
		done
	fi
	f_uci "${uci_config}"
}

# restart of the dns backend
#
f_dnsup()
{
	local dns_service dns_up dns_pid dns_procfile cache_util cache_rc cnt=0

	if [ "${adb_dnsflush}" -eq 0 ] && [ "${adb_enabled}" -eq 1 ] && [ "${adb_rc}" -eq 0 ]
	then
		case "${adb_dns}" in
			"dnsmasq")
				killall -q -HUP "${adb_dns}"
				cache_rc=${?}
			;;
			"unbound")
				cache_util="$(command -v unbound-control)"
				if [ -x "${cache_util}" ] && [ -d "${adb_tmpdir}" ] && [ -f "${adb_dnsdir}"/unbound.conf ]
				then
					"${cache_util}" -c "${adb_dnsdir}"/unbound.conf dump_cache > "${adb_tmpdir}"/adb_cache.dump 2>/dev/null
				fi
				"/etc/init.d/${adb_dns}" restart >/dev/null 2>&1
			;;
			"kresd")
				cache_util="keep_cache"
				"/etc/init.d/${adb_dns}" restart >/dev/null 2>&1
				cache_rc=${?}
			;;
			"named")
				cache_util="$(command -v rndc)"
				if [ -x "${cache_util}" ] && [ -f /etc/bind/rndc.conf ]
				then
					"${cache_util}" -c /etc/bind/rndc.conf reload >/dev/null 2>&1
					cache_rc=${?}
				else
					"/etc/init.d/${adb_dns}" restart >/dev/null 2>&1
				fi
			;;
		esac
	fi

	adb_rc=1
	while [ "${cnt}" -le 10 ]
	do
		dns_service="$(ubus -S call service list "{\"name\":\"${adb_dns}\"}")"
		dns_up="$(printf "%s" "${dns_service}" | jsonfilter -l1 -e "@[\"${adb_dns}\"].instances.*.running")"
		dns_pid="$(printf "%s" "${dns_service}" | jsonfilter -l1 -e "@[\"${adb_dns}\"].instances.*.pid")"
		dns_procfile="$(ls -l /proc/${dns_pid}/fd 2>/dev/null | grep -Fo "${adb_dnsdir}/${adb_dnsfile}")"
		if [ "${dns_up}" = "true" ] && [ -n "${dns_pid}" ] && [ -z "${dns_procfile}" ]
		then
			case "${adb_dns}" in
				"unbound")
					cache_util="$(command -v unbound-control)"
					if [ -x "${cache_util}" ] && [ -d "${adb_tmpdir}" ] && [ -s "${adb_tmpdir}"/adb_cache.dump ]
					then
						while [ "${cnt}" -le 10 ]
						do
							"${cache_util}" -c "${adb_dnsdir}"/unbound.conf load_cache < "${adb_tmpdir}"/adb_cache.dump >/dev/null 2>&1
							cache_rc=${?}
							if [ "${cache_rc}" -eq 0 ]
							then
								break
							fi
							cnt=$((cnt+1))
							sleep 1
						done
					fi
				;;
			esac
			sleep 1
			adb_rc=0
			break
		fi
		cnt=$((cnt+1))
		sleep 1
	done
	f_log "debug" "f_dnsup  ::: cache_util: ${cache_util:-"-"}, cache_rc: ${cache_rc:-"-"}, cache_flush: ${adb_dnsflush}, cache_cnt: ${cnt}, rc: ${adb_rc}"
	return ${adb_rc}
}

# backup/restore/remove blocklists
#
f_list()
{
	local file name tmp_file="${adb_tmpfile}" mode="${1}" in_rc="${adb_rc}"

	case "${mode}" in
		"blacklist")
			if [ -s "${adb_blacklist}" ]
			then
				src_name="${mode}"
				adb_blacklist_rset="/^([[:alnum:]_-]+\\.)+[[:alpha:]]+([[:space:]]|$)/{print tolower(\$1)}"
				awk "${adb_blacklist_rset}" "${adb_blacklist}" > "${adb_tmpfile}"."${src_name}"
			fi
		;;
		"whitelist")
			if [ -s "${adb_whitelist}" ]
			then
				src_name="${mode}"
				adb_whitelist_rset="/^([[:alnum:]_-]+\\.)+[[:alpha:]]+([[:space:]]|$)/{print tolower(\$1)}"
				awk "${adb_whitelist_rset}" "${adb_whitelist}" > "${adb_tmpdir}"/tmp.raw."${src_name}"
				
				adb_whitelist_rset="/^([[:alnum:]_-]+\\.)+[[:alpha:]]+([[:space:]]|$)/{gsub(\"\\\.\",\"\\\.\",\$1);print tolower(\"^\"\$1\"\\\|\\\.\"\$1)}"
				awk "${adb_whitelist_rset}" "${adb_tmpdir}"/tmp.raw."${src_name}" > "${adb_tmpdir}"/tmp.rem."${src_name}"

				if [ -n "${adb_dnsallow}" ]
				then
					eval "${adb_dnsallow}" "${adb_tmpdir}"/tmp.raw."${src_name}" > "${adb_tmpdir}"/tmp.add."${src_name}"
				fi
			fi
		;;
		"backup")
			if [ -d "${adb_backupdir}" ]
			then
				gzip -cf "${adb_tmpfile}" 2>/dev/null > "${adb_backupdir}/${adb_dnsprefix}.${src_name}.gz"
				adb_rc=${?}
			fi
		;;
		"restore")
			if [ -d "${adb_backupdir}" ]
			then
				if [ -n "${src_name}" ] && [ -f "${adb_backupdir}/${adb_dnsprefix}.${src_name}.gz" ]
				then
					zcat "${adb_backupdir}/${adb_dnsprefix}.${src_name}.gz" 2>/dev/null > "${adb_tmpfile}"
				else
					for file in "${adb_backupdir}/${adb_dnsprefix}."*".gz"
					do
						name="${file##*/}"
						name="${name%.*}"
						zcat "${file}" 2>/dev/null > "${adb_tmpfile}"."${name}"
					done
				fi
				adb_rc=${?}
			fi
		;;
		"remove")
			if [ -d "${adb_backupdir}" ]
			then
				rm -f "${adb_backupdir}/${adb_dnsprefix}.${src_name}.gz"
			fi
			adb_rc=${?}
		;;
		"merge")
			for file in "${adb_tmpfile}".*
			do
				cat "${file}" 2>/dev/null >> "${adb_tmpdir}/${adb_dnsfile}"
				if [ "${?}" -ne 0 ]
				then
					adb_rc=${?}
					break
				fi
				rm -f "${file}"
			done
			adb_tmpfile="${adb_tmpdir}/${adb_dnsfile}"
		;;
		"final")
			> "${adb_dnsdir}/${adb_dnsfile}"

			if [ -s "${adb_tmpdir}/tmp.add.whitelist" ]
			then
				cat "${adb_tmpdir}/tmp.add.whitelist" >> "${adb_dnsdir}/${adb_dnsfile}"
			fi

			if [ -s "${adb_tmpdir}/tmp.rem.whitelist" ]
			then
				grep -vf "${adb_tmpdir}/tmp.rem.whitelist" "${adb_tmpdir}/${adb_dnsfile}" | eval "${adb_dnsdeny}" >> "${adb_dnsdir}/${adb_dnsfile}"
			else
				eval "${adb_dnsdeny}" "${adb_tmpdir}/${adb_dnsfile}" >> "${adb_dnsdir}/${adb_dnsfile}"
			fi

			if [ "${?}" -eq 0 ] && [ -n "${adb_dnsheader}" ]
			then
				printf "%s\\n" "${adb_dnsheader}" | cat - "${adb_dnsdir}/${adb_dnsfile}" > "${adb_tmpdir}/${adb_dnsfile}"
				mv -f "${adb_tmpdir}/${adb_dnsfile}" "${adb_dnsdir}/${adb_dnsfile}"
			fi
			adb_rc=${?}
		;;
	esac
	f_count "${mode}"
	f_log "debug" "f_list   ::: name: ${src_name:-"-"}, mode: ${mode}, cnt: ${adb_cnt}, in_rc: ${in_rc}, out_rc: ${adb_rc}"
}

# top level domain compression
#
f_tld()
{
	local cnt cnt_srt cnt_tld source="${1}" temp_tld="${1}.tld" tld_ok="false"

	cnt="$(wc -l 2>/dev/null < "${source}")"
	if [ "${adb_dns}" != "dnsmasq" ] && [ "${adb_dnsvariant% *}" != "null" ]
	then
		awk 'BEGIN{FS="."}{for(f=NF;f>1;f--)printf "%s.",$f;print $1}' "${source}" > "${temp_tld}"
		if [ "${?}" -eq 0 ]
		then
			sort -u "${temp_tld}" > "${source}"
			if [ "${?}" -eq 0 ]
			then
				cnt_srt="$(wc -l 2>/dev/null < "${source}")"
				awk '{if(NR==1){tld=$NF};while(getline){if($NF!~tld"\\."){print tld;tld=$NF}}print tld}' "${source}" > "${temp_tld}"
				if [ "${?}" -eq 0 ]
				then
					awk 'BEGIN{FS="."}{for(f=NF;f>1;f--)printf "%s.",$f;print $1}' "${temp_tld}" > "${source}"
					if [ "${?}" -eq 0 ]
					then
						rm -f "${temp_src}" "${temp_tld}"
						cnt_tld="$(wc -l 2>/dev/null < "${source}")"
						tld_ok="true"
					fi
				fi
			fi
		fi
	else
		sort -u "${source}" > "${temp_tld}"
		if [ "${?}" -eq 0 ]
		then
			mv -f "${temp_tld}" "${source}"
			cnt_srt="$(wc -l 2>/dev/null < "${source}")"
			tld_ok="true"
		fi
	fi
	if [ "${tld_ok}" = "false" ]
	then
		unset cnt_srt cnt_tld
		rm -f "${temp_tld}"
		f_list blacklist
		f_list whitelist
		f_list restore
		f_list merge
		f_list final
		cnt="$(wc -l 2>/dev/null < "${adb_tmpdir}"/"${adb_dnsfile}")"
	fi
	f_log "debug" "f_tld    ::: source: ${source}, cnt: ${cnt:-"-"}, cnt_srt: ${cnt_srt:-"-"}, cnt_tld: ${cnt_tld:-"-"}, tld_ok: ${tld_ok}"
}

# suspend/resume adblock processing
#
f_switch()
{
	local status done="false" mode="${1}"

	json_load_file "${adb_rtfile}" >/dev/null 2>&1
	json_select "data" >/dev/null 2>&1
	json_get_var status "adblock_status"
	f_temp
	if [ "${mode}" = "suspend" ] && [ "${status}" = "enabled" ]
	then
		> "${adb_dnsdir}/${adb_dnsfile}"
		if [ -n "${adb_dnsheader}" ]
		then
			printf "%s\\n" "${adb_dnsheader}" > "${adb_dnsdir}/${adb_dnsfile}"
		fi
		done="true"
	elif [ "${mode}" = "resume" ] && [ "${status}" = "paused" ]
	then
		f_list blacklist
		f_list whitelist
		f_list restore
		f_list merge
		f_tld "${adb_tmpdir}"/"${adb_dnsfile}"
		f_list final
		done="true"
	fi
	if [ "${done}" = "true" ]
	then
		if [ "${mode}" = "suspend" ]
		then
			f_bgserv "stop"
		fi
		f_dnsup
		if [ "${mode}" = "resume" ]
		then
			f_bgserv "start"
		fi
		f_jsnup "${mode}"
		f_log "info" "${mode} adblock processing"
	fi
	f_rmtemp
}

# query blocklist for certain (sub-)domains
#
f_query()
{
	local search result prefix suffix field domain="${1}" tld="${1#*.}"

	if [ -z "${domain}" ] || [ "${domain}" = "${tld}" ]
	then
		printf "%s\\n" "::: invalid domain input, please submit a single domain, e.g. 'doubleclick.net'"
	else
		case "${adb_dns}" in
			"dnsmasq")
				if [ "${adb_dnsvariant}" = "nxdomain" ]
				then
					prefix=".*[\\/\\.]"
					suffix="(\\/)"
					field=2
				elif [ "${adb_dnsvariant% *}" = "null" ]
				then
					prefix=".*[\\t\\.]"
					suffix=""
					field=2
				fi
			;;
			"unbound")
				prefix=".*[\"\\.]"
				suffix="(static)"
				field=3
			;;
			"named")
				prefix="[^\\*].*[\\.]"
				suffix="( \\.)"
				field=1
			;;
			"kresd")
				prefix="[^\\*].*[\\.]"
				suffix="( \\.)"
				field=1
			;;
		esac
		if [ "${adb_dnsfilereset}" = "false" ]
		then
			while [ "${domain}" != "${tld}" ]
			do
				search="${domain//./\\.}"
				search="${search//[+*~%\$&\"\']/}"
				result="$(awk -F '/|\"|\t| ' "/^(${prefix}+${search}.*${suffix}$)/{i++;{printf(\"  + %s\\n\",\$${field})};if(i>9){printf(\"  + %s\\n\",\"[...]\");exit}}" "${adb_dnsdir}/${adb_dnsfile}")"
				printf "%s\\n%s\\n%s\\n" ":::" "::: results for domain '${domain}' in active blocklist" ":::"
				printf "%s\n\n" "${result:-"  - no match"}"
				domain="${tld}"
				tld="${domain#*.}"
			done
		fi
		if [ -d "${adb_backupdir}" ]
		then
			search="${1//./\\.}"
			search="${search//[+*~%\$&\"\']/}"
			printf "%s\\n%s\\n%s\\n" ":::" "::: results for domain '${1}' in backups and black-/whitelist" ":::"
			for file in "${adb_backupdir}"/"${adb_dnsprefix}".*.gz "${adb_blacklist}" "${adb_whitelist}"
			do
				suffix="${file##*.}"
				if [ "${suffix}" = "gz" ]
				then
					zcat "${file}" 2>/dev/null | awk -v f="${file##*/}" "/^($search|.*\\.${search})/{i++;{printf(\"  + %-30s%s\\n\",f,\$1)};if(i>=3){printf(\"  + %-30s%s\\n\",f,\"[...]\");exit}}"
				else
					cat "${file}" 2>/dev/null | awk -v f="${file##*/}" "/^($search|.*\\.${search})/{i++;{printf(\"  + %-30s%s\\n\",f,\$1)};if(i>=3){printf(\"  + %-30s%s\\n\",f,\"[...]\");exit}}"
				fi
			done
		fi
	fi
}

# update runtime information
#
f_jsnup()
{
	local run_time bg_pid status="${1:-"enabled"}"

	if [ "${adb_rc}" -gt 0 ]
	then
		status="error"
		run_time="$(/bin/date "+%d.%m.%Y %H:%M:%S")"
	fi
	if [ "${status}" = "enabled" ]
	then
		run_time="$(/bin/date "+%d.%m.%Y %H:%M:%S")"
	fi
	if [ "${status}" = "suspend" ]
	then
		status="paused"
	fi
	if [ "${status}" = "resume" ]
	then
		status=""
	fi

	json_load_file "${adb_rtfile}" >/dev/null 2>&1
	json_select "data" >/dev/null 2>&1
	if [ "${?}" -eq 0 ]
	then
		if [ -z "${adb_fetchinfo}" ]
		then
			json_get_var adb_fetchinfo "fetch_utility"
		fi
		if [ -z "${adb_cnt}" ]
		then
			json_get_var adb_cnt "overall_domains"
			adb_cnt="${adb_cnt%% *}"
		fi
		if [ -z "${run_time}" ]
		then
			json_get_var run_time "last_rundate"
		fi
	fi

	> "${adb_rtfile}"
	json_load_file "${adb_rtfile}" >/dev/null 2>&1
	json_init
	json_add_object "data"
	json_add_string "adblock_status" "${status:-"enabled"}"
	json_add_string "adblock_version" "${adb_ver}"
	json_add_string "overall_domains" "${adb_cnt:-0}"
	json_add_string "fetch_utility" "${adb_fetchinfo:-"-"}"
	json_add_string "dns_backend" "${adb_dns}, ${adb_dnsdir}"
	json_add_string "dns_variant" "${adb_dnsvariant}, ${adb_dnsfilereset:-"false"}"
	json_add_string "backup_dir" "${adb_backupdir}"
	json_add_string "last_rundate" "${run_time:-"-"}"
	json_add_string "system_release" "${adb_sysver}"
	json_close_object
	json_dump > "${adb_rtfile}"

	if [ ${adb_mail} -eq 1 ] && [ -x "${adb_mailservice}" ] && \
		{ [ "${status}" = "error" ] || { [ "${status}" = "enabled" ] && [ "${adb_cnt}" -le "${adb_mcnt}" ]; } }
	then
		("${adb_mailservice}" >/dev/null 2>&1)&
		bg_pid=${!}
	fi
	f_log "debug" "f_jsnup  ::: status: ${status:-"-"}, cnt: ${adb_cnt}, mail: ${adb_mail}, mail_service: ${adb_mailservice}, mail_cnt: ${adb_mcnt}, mail_pid: ${bg_pid:-"-"}"
}

# write to syslog
#
f_log()
{
	local class="${1}" log_msg="${2}"

	if [ -n "${log_msg}" ] && { [ "${class}" != "debug" ] || [ ${adb_debug} -eq 1 ]; }
	then
		logger -p "${class}" -t "adblock-${adb_ver}[${$}]" "${log_msg}"
		if [ "${class}" = "err" ]
		then
			f_rmdns
			f_jsnup
			logger -p "${class}" -t "adblock-${adb_ver}[${$}]" "Please also check 'https://github.com/openwrt/packages/blob/master/net/adblock/files/README.md'"
			exit 1
		fi
	fi
}

# start ubus monitor service to trace dns backend events
#
f_bgserv()
{
	local bg_pid status="${1}"

	bg_pid="$(pgrep -f "^/bin/sh ${adb_ubusservice}|^/bin/ubus -S -M r -m invoke monitor|^grep -qF \"method\":\"set\",\"data\":\\{\"name\":\"${adb_dns}\"" | awk '{ORS=" "; print $1}')"
	if [ -z "${bg_pid}" ] && [ "${status}" = "start" ] \
		&& [ -x "${adb_ubusservice}" ] && [ "${adb_dnsfilereset}" = "true" ]
	then
		( "${adb_ubusservice}" &)
	elif [ -n "${bg_pid}" ] && [ "${status}" = "stop" ] 
	then
		kill -HUP ${bg_pid} 2>/dev/null
	fi
	f_log "debug" "f_bgserv ::: status: ${status:-"-"}, bg_pid: ${bg_pid:-"-"}, dns_filereset: ${adb_dnsfilereset:-"-"}, ubus_service: ${adb_ubusservice:-"-"}"
}

# main function for blocklist processing
#
f_main()
{
	local tmp_load tmp_file src_name src_rset src_url src_log src_arc src_cat cat list entry suffix mem_total mem_free enabled cnt=1

	mem_total="$(awk '/^MemTotal/ {print int($2/1000)}' "/proc/meminfo" 2>/dev/null)"
	mem_free="$(awk '/^MemFree/ {print int($2/1000)}' "/proc/meminfo" 2>/dev/null)"
	tmp_load="${adb_tmpload}"
	tmp_file="${adb_tmpfile}"
	f_log "debug" "f_main   ::: dns: ${adb_dns}, fetch_util: ${adb_fetchinfo}, force_dns: ${adb_forcedns}, mem_total: ${mem_total:-0}, mem_free: ${mem_free:-0}, max_queue: ${adb_maxqueue}"
	
	# main loop
	#
	f_list blacklist
	f_list whitelist
	for src_name in ${adb_sources}
	do
		enabled="$(eval printf "%s" \"\$\{enabled_${src_name}\}\")"
		src_url="$(eval printf "%s" \"\$\{adb_src_${src_name}\}\")"
		src_rset="$(eval printf "%s" \"\$\{adb_src_rset_${src_name}\}\")"
		src_cat="$(eval printf "%s" \"\$\{adb_src_cat_${src_name}\}\")"
		adb_tmpload="${tmp_load}"."${src_name}"
		adb_tmpfile="${tmp_file}"."${src_name}"

		# basic pre-checks
		#
		f_log "debug" "f_main   ::: name: ${src_name}, enabled: ${enabled}"
		if [ "${enabled}" != "1" ] || [ -f "${src_url}" ] || [ -z "${src_url}" ] || [ -z "${src_rset}" ]
		then
			f_list remove
			continue
		fi

		# backup mode
		#
		if [ "${adb_action}" = "start" ]
		then
			f_list restore
			if [ "${adb_rc}" -eq 0 ] && [ -s "${adb_tmpfile}" ]
			then
				continue
			fi
		fi

		# download queue processing
		#
		if [ -n "${src_cat}" ]
		then
			(
				src_arc="${adb_tmpdir}"/"${src_url##*/}"
				src_log="$("${adb_fetchutil}" ${adb_fetchparm} "${src_arc}" "${src_url}" 2>&1)"
				adb_rc=${?}
				if [ "${adb_rc}" -eq 0 ] && [ -s "${src_arc}" ]
				then
					list="$(tar -tzf "${src_arc}")"
					suffix="$(eval printf "%s" \"\$\{adb_src_suffix_${src_name}:-\"domains\"\}\")"
					for cat in ${src_cat}
					do
						entry="$(printf "%s" "${list}" | grep -E "[\\^/]+${cat}/${suffix}")"
						if [ -n "${entry}" ]
						then
							tar -xOzf "${src_arc}" "${entry}" >> "${adb_tmpload}"
							adb_rc=${?}
							if [ "${adb_rc}" -ne 0 ]
							then
								break
							fi
						fi
					done
				else
					src_log="$(printf "%s" "${src_log}" | awk '{ORS=" ";print $0}')"
					f_log "debug" "f_main   ::: name: ${src_name}, url: ${src_url}, rc: ${adb_rc}, log: ${src_log:-"-"}"
				fi
				if [ "${adb_rc}" -eq 0 ] && [ -s "${adb_tmpload}" ]
				then
					rm -f "${src_arc}"
					awk "${src_rset}" "${adb_tmpload}" 2>/dev/null > "${adb_tmpfile}"
					adb_rc=${?}
					if [ "${adb_rc}" -eq 0 ] && [ -s "${adb_tmpfile}" ]
					then
						rm -f "${adb_tmpload}"
						f_list download
						f_list backup
					else
						f_list restore
					fi
				else
					f_list restore
				fi
			) &
		else
			(
				src_log="$("${adb_fetchutil}" ${adb_fetchparm} "${adb_tmpload}" "${src_url}" 2>&1)"
				adb_rc=${?}
				if [ ${adb_rc} -eq 0 ] && [ -s "${adb_tmpload}" ]
				then
					awk "${src_rset}" "${adb_tmpload}" 2>/dev/null > "${adb_tmpfile}"
					adb_rc=${?}
					if [ "${adb_rc}" -eq 0 ] && [ -s "${adb_tmpfile}" ]
					then
						rm -f "${adb_tmpload}"
						f_list download
						f_list backup
					else
						f_list restore
					fi
				else
					src_log="$(printf "%s" "${src_log}" | awk '{ORS=" ";print $0}')"
					f_log "debug" "f_main   ::: name: ${src_name}, url: ${src_url}, rc: ${adb_rc}, log: ${src_log:-"-"}"
					f_list restore
				fi
			) &
		fi
		hold=$((cnt%adb_maxqueue))
		if [ "${hold}" -eq 0 ]
		then
			wait
		fi
		cnt=$((cnt+1))
	done

	# list merge
	#
	wait
	src_name="overall"
	adb_tmpfile="${tmp_file}"
	f_list merge

	# overall sort and dns restart
	#
	if [ -s "${adb_tmpdir}"/"${adb_dnsfile}" ]
	then
		f_tld "${adb_tmpdir}"/"${adb_dnsfile}"
		f_list final
	else
		> "${adb_dnsdir}"/"${adb_dnsfile}"
	fi
	chown "${adb_dnsuser}" "${adb_dnsdir}"/"${adb_dnsfile}" 2>/dev/null
	f_dnsup
	f_jsnup
	if [ "${?}" -eq 0 ]
	then
		if [ "${adb_dnsfilereset}" = "true" ]
		then
			> "${adb_dnsdir}"/"${adb_dnsfile}"
			f_log "info" "blocklist with overall ${adb_cnt} domains loaded successfully and reset afterwards (${adb_sysver})"
			f_bgserv "start"
		else
			f_log "info" "blocklist with overall ${adb_cnt} domains loaded successfully (${adb_sysver})"
		fi
	else
		f_log "err" "dns backend restart with active blocklist failed"
	fi
	f_rmtemp
	exit ${adb_rc}
}

# trace dns queries via tcpdump and prepare a report
#
f_report()
{
	local bg_pid status total blocked percent rep_clients rep_domains rep_blocked index hold ports cnt=0 search="${1}" count="${2}" filter="${3}" print="${4}"

	if [ "${adb_report}" -eq 1 ] && [ ! -x "${adb_reputil}" ]
	then
		f_log "info" "Please install the package 'tcpdump' or 'tcpdump-mini' to use the adblock reporting feature!"
	elif [ "${adb_report}" -eq 0 ] && [ "${adb_action}" = "report" ]
	then
		f_log "info" "Please enable the extra option 'adb_report' to use the adblock reporting feature!"
	fi

	if [ -x "${adb_reputil}" ]
	then
		bg_pid="$(pgrep -f "^${adb_reputil}.*adb_report\\.pcap$" | awk '{ORS=" "; print $1}')"
		if [ "${adb_report}" -eq 0 ] || { [ -n "${bg_pid}" ] && { [ "${adb_action}" = "stop" ] || [ "${adb_action}" = "restart" ]; } }
		then
			if [ -n "${bg_pid}" ]
			then
				kill -HUP ${bg_pid} 2>/dev/null
				while $(kill -0 ${bg_pid} 2>/dev/null)
				do
					sleep 1
				done
				unset bg_pid
			fi
		fi
	fi

	if [ -x "${adb_reputil}" ] && [ "${adb_report}" -eq 1 ]
	then
		if [ -z "${bg_pid}" ] && [ "${adb_action}" != "report" ] && [ "${adb_action}" != "stop" ]
		then
			for port in ${adb_replisten}
			do
				if [ -z "${ports}" ]
				then
					ports="port ${port}"
				else
					ports="${ports} or port ${port}"
				fi
			done
			( "${adb_reputil}" -nn -s0 -l -i ${adb_repiface} ${ports} -C${adb_repchunksize} -W${adb_repchunkcnt} -w "${adb_repdir}"/adb_report.pcap >/dev/null 2>&1 & )
			bg_pid="$(pgrep -f "^${adb_reputil}.*adb_report\\.pcap$" | awk '{ORS=" "; print $1}')"
		fi

		if [ "${adb_action}" = "report" ] && [ "${filter}" = "false" ]
		then
			> "${adb_repdir}"/adb_report.raw
			for file in "${adb_repdir}"/adb_report.pcap*
			do
				(
					"${adb_reputil}" -tttt -r "${file}" 2>/dev/null | \
						awk -v cnt=${cnt} '!/\.lan\. /&&/ A[\? ]+|NXDomain|0\.0\.0\.0/{a=$1;b=substr($2,0,8);c=$4;sub(/\.[0-9]+$/,"",c); \
						d=cnt $7;sub(/\*$/,"",d);e=$(NF-1);sub(/[0-9]\/[0-9]\/[0-9]|0\.0\.0\.0/,"NX",e);sub(/\.$/,"",e);sub(/([0-9]{1,3}\.){3}[0-9]{1,3}/,"OK",e);printf("%s\t%s\t%s\t%s\t%s\n", a,b,c,d,e)}' >> "${adb_repdir}/adb_report.raw"
				)&
				hold=$((cnt%adb_maxqueue))
				if [ "${hold}" -eq 0 ]
				then
					wait
				fi
				cnt=$((cnt+1))
			done
			wait

			if [ -s "${adb_repdir}"/adb_report.raw ]
			then
				awk '{printf("%s\t%s\t%s\t%s\t%s\t%s\n", $4,$5,$1,$2,$3,$4)}' "${adb_repdir}/adb_report.raw" | \
					sort -ur | uniq -uf2 | awk '{currA=($6+0);currB=$6;currC=substr($6,length($6),1); \
					if(reqA==currB){reqA=0;printf("%s\t%s\n",d,$2)}else if(currC=="+"){reqA=currA;d=$3"\t"$4"\t"$5"\t"$2}}' | sort -ur > "${adb_repdir}/adb_report"
			fi

			if [ -s "${adb_repdir}"/adb_report ]
			then
				total="$(wc -l < "${adb_repdir}"/adb_report)"
				blocked="$(awk '{if($5=="NX")print $4}' "${adb_repdir}"/adb_report | wc -l)"
				percent="$(awk -v t="${total}" -v b="${blocked}" 'BEGIN{printf("%.2f %s\n",b/t*100, "%")}')"
				rep_clients="$(awk '{print $3}' "${adb_repdir}"/adb_report | sort | uniq -c | sort -r | awk '{ORS=" ";if(NR<=10) printf("%s_%s ",$1,$2)}')"
				rep_domains="$(awk '{if($5!="NX")print $4}' "${adb_repdir}"/adb_report | sort | uniq -c | sort -r | awk '{ORS=" ";if(NR<=10)printf("%s_%s ",$1,$2)}')"
				rep_blocked="$(awk '{if($5=="NX")print $4}' "${adb_repdir}"/adb_report | sort | uniq -c | sort -r | awk '{ORS=" ";if(NR<=10)printf("%s_%s ",$1,$2)}')"

				> "${adb_repdir}"/adb_report.json
				json_load_file "${adb_repdir}"/adb_report.json >/dev/null 2>&1
				json_init
				json_add_object "data"
				json_add_string "start_date" "$(awk 'END{printf("%s",$1)}' "${adb_repdir}"/adb_report)"
				json_add_string "start_time" "$(awk 'END{printf("%s",$2)}' "${adb_repdir}"/adb_report)"
				json_add_string "end_date" "$(awk 'NR==1{printf("%s",$1)}' "${adb_repdir}"/adb_report)"
				json_add_string "end_time" "$(awk 'NR==1{printf("%s",$2)}' "${adb_repdir}"/adb_report)"
				json_add_string "total" "${total}"
				json_add_string "blocked" "${blocked}"
				json_add_string "percent" "${percent}"
				json_close_array
				json_add_array "top_clients"
				for client in ${rep_clients}
				do
					json_add_object
					json_add_string "count" "${client%%_*}"
					json_add_string "address" "${client#*_}"
					json_close_object
				done
				json_close_array
				json_add_array "top_domains"
				for domain in ${rep_domains}
				do
					json_add_object
					json_add_string "count" "${domain%%_*}"
					json_add_string "address" "${domain#*_}"
					json_close_object
				done
				json_close_array
				json_add_array "top_blocked"
				for block in ${rep_blocked}
				do
					json_add_object
					json_add_string "count" "${block%%_*}"
					json_add_string "address" "${block#*_}"
					json_close_object
				done
				json_close_object
				json_dump > "${adb_repdir}"/adb_report.json
			fi
			rm -f "${adb_repdir}"/adb_report.raw
		fi

		if [ -s "${adb_repdir}"/adb_report ]
		then
			search="${search//./\\.}"
			search="${search//[+*~%\$&\"\' ]/}"
			> "${adb_repdir}"/adb_report.final
			awk "BEGIN{i=0}/(${search})/{i++;if(i<=${count}){printf \"%s\\t%s\\t%s\\t%s\\t%s\\n\",\$1,\$2,\$3,\$4,\$5}}" "${adb_repdir}"/adb_report > "${adb_repdir}"/adb_report.final
			if [ ! -s "${adb_repdir}"/adb_report.final ]
			then
				printf "%s\\t%s\\t%s\\t%s\\t%s\\n" "-" "-" "-" "-" "-" > "${adb_repdir}"/adb_report.final
			fi
		fi

		if [ "${print}" = "true" ]
		then
			if [ -s "${adb_repdir}"/adb_report.json ]
			then
				printf "%s\\n%s\\n%s\\n" ":::" "::: Adblock DNS-Query Report" ":::"
				json_load_file "${adb_repdir}"/adb_report.json
				json_select "data"
				json_get_keys keylist
				for key in ${keylist}
				do
					json_get_var value "${key}"
					eval "${key}=\"${value}\""
				done
				printf "  + %s\\n  + %s\\n" "Start    ::: ${start_date}, ${start_time}" "End      ::: ${end_date}, ${end_time}"
				printf "  + %s\\n  + %s %s\\n" "Total    ::: ${total}" "Blocked  ::: ${blocked}" "(${percent})"
				json_select ".."
				if json_get_type status "top_clients" && [ "${status}" = "array" ]
				then
					printf "%s\\n%s\\n%s\\n" ":::" "::: Top 10 Clients" ":::"
					json_select "top_clients"
					index=1
					while json_get_type status "${index}" && [ "${status}" = "object" ]
					do
						json_get_values client "${index}"
						printf "  + %-9s::: %s\\n" ${client}
						index=$((index+1))
					done
				fi
				json_select ".."
				if json_get_type status "top_domains" && [ "${status}" = "array" ]
				then
					printf "%s\\n%s\\n%s\\n" ":::" "::: Top 10 Domains" ":::"
					json_select "top_domains"
					index=1
					while json_get_type status "${index}" && [ "${status}" = "object" ]
					do
						json_get_values domain "${index}"
						printf "  + %-9s::: %s\\n" ${domain}
						index=$((index+1))
					done
				fi
				json_select ".."
				if json_get_type status "top_blocked" && [ "${status}" = "array" ]
				then
					printf "%s\\n%s\\n%s\\n" ":::" "::: Top 10 Blocked Domains" ":::"
					json_select "top_blocked"
					index=1
					while json_get_type status "${index}" && [ "${status}" = "object" ]
					do
						json_get_values blocked "${index}"
						printf "  + %-9s::: %s\\n" ${blocked}
						index=$((index+1))
					done
				fi
				if [ -s "${adb_repdir}"/adb_report.final ]
				then
					printf "%s\\n%s\\n%s\\n" ":::" "::: Latest DNS Queries" ":::"
					printf "%-15s%-15s%-45s%-50s%s\\n" "Date" "Time" "Client" "Domain" "Answer"
					awk '{printf "%-15s%-15s%-45s%-50s%s\n",$1,$2,$3,$4,$5}' "${adb_repdir}"/adb_report.final
				fi
			else
				printf "%s\\n%s\\n%s\\n" ":::" "::: no reporting data available yet" ":::"
			fi
		fi
	fi
	f_log "debug" "f_report ::: action: ${adb_action}, report: ${adb_report}, search: ${1}, count: ${2}, filter: ${3}, print: ${4}, reputil: ${adb_reputil}, repdir: ${adb_repdir}, repiface: ${adb_repiface}, replisten: ${adb_replisten}, repchunksize: ${adb_repchunksize}, repchunkcnt: ${adb_repchunkcnt}, bg_pid: ${bg_pid}"
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

# handle different adblock actions
#
f_load
case "${adb_action}" in
	stop)
		f_bgserv "stop"
		f_report "+" "50" "false" "false"
		f_rmdns
	;;
	restart)
		f_bgserv "stop"
		f_report "+" "50" "false" "false"
		f_rmdns
		f_env
		f_main
	;;
	suspend)
		f_switch suspend
	;;
	resume)
		f_switch resume
	;;
	report)
		f_report "${2}" "${3}" "${4}" "${5}"
	;;
	query)
		f_query "${2}"
	;;
	start|reload)
		f_bgserv "stop"
		f_report "+" "50" "false" "false"
		f_env
		f_main
	;;
esac
