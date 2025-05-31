#!/bin/sh
# dns based ad/abuse domain blocking
# Copyright (c) 2015-2025 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# (s)hellcheck exceptions
# shellcheck disable=all

# set initial defaults
#
export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

adb_enabled="0"
adb_debug="0"
adb_dnsforce="0"
adb_dnsshift="0"
adb_dnsflush="0"
adb_dnstimeout="20"
adb_safesearch="0"
adb_report="0"
adb_trigger=""
adb_triggerdelay="5"
adb_mail="0"
adb_jail="0"
adb_map="0"
adb_tld="1"
adb_dns=""
adb_dnspid=""
adb_locallist="allowlist blocklist iplist"
adb_basedir="/tmp"
adb_finaldir=""
adb_backupdir="/tmp/adblock-backup"
adb_reportdir="/tmp/adblock-report"
adb_jaildir="/tmp"
adb_pidfile="/var/run/adblock.pid"
adb_allowlist="/etc/adblock/adblock.allowlist"
adb_blocklist="/etc/adblock/adblock.blocklist"
adb_mailservice="/etc/adblock/adblock.mail"
adb_dnsfile="adb_list.overall"
adb_dnsjail="adb_list.jail"
adb_feedfile="/etc/adblock/adblock.feeds"
adb_customfeedfile="/etc/adblock/adblock.custom.feeds"
adb_rtfile="/var/run/adb_runtime.json"
adb_fetchcmd=""
adb_fetchinsecure=""
adb_fetchparm=""
adb_etagparm=""
adb_geoparm=""
adb_geourl="http://ip-api.com/json"
adb_repiface=""
adb_replisten="53"
adb_repchunkcnt="5"
adb_repchunksize="1"
adb_represolve="0"
adb_lookupdomain="localhost"
adb_action="${1}"
adb_packages=""
adb_cnt=""

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

# load adblock environment
#
f_load() {
	local bg_pid iface port ports cpu core

	adb_packages="$("${adb_ubuscmd}" -S call rpc-sys packagelist '{ "all": true }' 2>/dev/null)"
	adb_ver="$(printf "%s" "${adb_packages}" | "${adb_jsoncmd}" -ql1 -e '@.packages.adblock')"
	adb_sysver="$("${adb_ubuscmd}" -S call system board 2>/dev/null |
		"${adb_jsoncmd}" -ql1 -e '@.model' -e '@.release.target' -e '@.release.distribution' -e '@.release.version' -e '@.release.revision' |
		"${adb_awkcmd}" 'BEGIN{RS="";FS="\n"}{printf "%s, %s, %s %s %s %s",$1,$2,$3,$4,$5,$6}')"
	f_conf

	if [ -z "${adb_cores}" ]; then
		cpu="$("${adb_grepcmd}" -c '^processor' /proc/cpuinfo 2>/dev/null)"
		core="$("${adb_grepcmd}" -cm1 '^core id' /proc/cpuinfo 2>/dev/null)"
		[ "${cpu}" = "0" ] && cpu="1"
		[ "${core}" = "0" ] && core="1"
		adb_cores="$((cpu * core))"
		[ "${adb_cores}" -gt "16" ] && adb_cores="16"
	fi

	if [ "${adb_enabled}" = "0" ]; then
		f_extconf
		f_temp
		f_rmdns
		f_jsnup "disabled"
		f_log "info" "adblock is currently disabled, please set the config option 'adb_enabled' to '1' to use this service"
		exit 0
	fi

	if [ "${adb_action}" != "report" ] && [ "${adb_action}" != "mail" ]; then
		f_dns
		f_fetch
	fi

	if [ "${adb_report}" = "1" ] && [ ! -x "${adb_dumpcmd}" ]; then
		f_log "info" "Please install the package 'tcpdump' or 'tcpdump-mini' to use the reporting feature"
	elif [ -x "${adb_dumpcmd}" ]; then
		bg_pid="$("${adb_pgrepcmd}" -f "^${adb_dumpcmd}.*adb_report\\.pcap$" | "${adb_awkcmd}" '{ORS=" "; print $1}')"
		if [ "${adb_report}" = "0" ] || { [ -n "${bg_pid}" ] && [ "${adb_action}" = "stop" ]; }; then
			if [ -n "${bg_pid}" ]; then
				kill -HUP "${bg_pid}" 2>/dev/null
				while kill -0 "${bg_pid}" 2>/dev/null; do
					sleep 1
				done
				unset bg_pid
			fi
			rm -f "${adb_reportdir}"/adb_report.pcap*
		fi

		if [ "${adb_report}" = "1" ] && [ -z "${bg_pid}" ] && [ "${adb_action}" != "report" ] && [ "${adb_action}" != "stop" ]; then
			[ ! -d "${adb_reportdir}" ] && mkdir -p "${adb_reportdir}"

			for port in ${adb_replisten}; do
				[ -z "${ports}" ] && ports="port ${port}" || ports="${ports} or port ${port}"
			done
			if [ -z "${adb_repiface}" ]; then
				network_get_device iface "lan"
				[ -z "${iface}" ] && network_get_physdev iface "lan"
				if [ -n "${iface}" ]; then
					adb_repiface="${iface}"
					uci_set adblock global adb_repiface "${adb_repiface}"
					f_uci "adblock"
				fi
			fi

			if [ -n "${adb_repiface}" ] && [ -d "${adb_reportdir}" ]; then
				("${adb_dumpcmd}" --immediate-mode -nn -p -s0 -l -i ${adb_repiface} ${ports} -C${adb_repchunksize} -W${adb_repchunkcnt} -w "${adb_reportdir}/adb_report.pcap" >/dev/null 2>&1 &)
				bg_pid="$("${adb_pgrepcmd}" -f "^${adb_dumpcmd}.*adb_report\\.pcap$" | "${adb_awkcmd}" '{ORS=" "; print $1}')"
			else
				f_log "info" "Please set the name of the reporting network device 'adb_repiface' manually"
			fi
		fi
	fi
}

# check & set environment
#
f_env() {
	adb_starttime="$(date "+%s")"
	f_log "info" "adblock instance started ::: action: ${adb_action}, priority: ${adb_nicelimit:-"0"}, pid: ${$}"
	f_jsnup "running"
	f_extconf
	f_temp
	json_init
	if [ -s "${adb_customfeedfile}" ]; then
		if json_load_file "${adb_customfeedfile}" >/dev/null 2>&1; then
			return
		else
			f_log "info" "can't load adblock custom feed file"
		fi
	fi
	if [ -s "${adb_feedfile}" ] && json_load_file "${adb_feedfile}" >/dev/null 2>&1; then
		return
	else
		f_log "err" "can't load adblock feed file"
	fi
}

# load adblock config
#
f_conf() {
	config_cb() {
		option_cb() {
			local option="${1}" value="${2//\"/\\\"}"

			eval "${option}=\"${value}\""
		}
		list_cb() {
			local append option="${1}" value="${2//\"/\\\"}"

			eval "append=\"\${${option}}\""
			eval "${option}=\"${append}${value} \""
		}
	}
	config_load adblock
}

# status helper function
#
f_char() {
	local result input="${1}"

	if [ "${input}" = "1" ]; then
		result="✔"
	else
		result="✘"
	fi
	printf "%s" "${result}"
}

# load dns backend config
#
f_dns() {
	local dns dns_list dns_section dns_info free_mem dir

	free_mem="$("${adb_awkcmd}" '/^MemAvailable/{printf "%s",int($2/1000)}' "/proc/meminfo" 2>/dev/null)"
	if [ "${adb_action}" = "boot" ] && [ -z "${adb_trigger}" ]; then
		sleep ${adb_triggerdelay:-"5"}
	fi

	if [ -z "${adb_dns}" ]; then
		dns_list="knot-resolver bind-server unbound-daemon smartdns dnsmasq-full dnsmasq-dhcpv6 dnsmasq"
		for dns in ${dns_list}; do
			if printf "%s" "${adb_packages}" | "${adb_jsoncmd}" -ql1 -e "@.packages[\"${dns}\"]" >/dev/null 2>&1; then
				case "${dns}" in
					"knot-resolver")
						dns="kresd"
						;;
					"bind-server")
						dns="named"
						;;
					"unbound-daemon")
						dns="unbound"
						;;
					"dnsmasq-full" | "dnsmasq-dhcpv6")
						dns="dnsmasq"
						;;
				esac

				if [ -x "$(command -v "${dns}")" ]; then
					adb_dns="${dns}"
					uci_set adblock global adb_dns "${dns}"
					f_uci "adblock"
					break
				fi
			fi
		done
	fi

	if [ "${adb_dns}" != "raw" ] && [ ! -x "$(command -v "${adb_dns}")" ]; then
		f_log "err" "dns backend not found, please set 'adb_dns' manually"
	fi

	case "${adb_dns}" in
		"dnsmasq")
			adb_dnscachecmd="-"
			adb_dnsinstance="${adb_dnsinstance:-"0"}"
			adb_dnsuser="${adb_dnsuser:-"dnsmasq"}"
			adb_dnsdir="${adb_dnsdir:-""}"
			adb_dnsheader="${adb_dnsheader:-""}"
			adb_dnsdeny="${adb_dnsdeny:-"${adb_awkcmd} '{print \"local=/\"\$0\"/\"}'"}"
			adb_dnsallow="${adb_dnsallow:-"${adb_awkcmd} '{print \"local=/\"\$0\"/#\"}'"}"
			adb_dnssafesearch="${adb_dnssafesearch:-"${adb_awkcmd} -v item=\"\$item\" '{print \"address=/\"\$0\"/\"item\"\";print \"local=/\"\$0\"/\"}'"}"
			adb_dnsstop="${adb_dnsstop:-"address=/#/\nlocal=/#/"}"
			if [ -z "${adb_dnsdir}" ]; then
				dns_section="$("${adb_ubuscmd}" -S call uci get "{\"config\":\"dhcp\", \"section\":\"@dnsmasq[${adb_dnsinstance}]\", \"type\":\"dnsmasq\"}" 2>/dev/null)"
				dns_info="$(printf "%s" "${dns_section}" | "${adb_jsoncmd}" -l1 -e '@.values["confdir"]')"
				if [ -n "${dns_info}" ]; then
					adb_dnsdir="${dns_info}"
				else
					dns_info="$(printf "%s" "${dns_section}" | "${adb_jsoncmd}" -l1 -e '@.values[".name"]')"
					[ -n "${dns_info}" ] && adb_dnsdir="/tmp/dnsmasq.${dns_info}.d"
				fi
			fi
			;;
		"unbound")
			adb_dnscachecmd="$(command -v unbound-control || printf "%s" "-")"
			adb_dnsinstance="${adb_dnsinstance:-"0"}"
			adb_dnsuser="${adb_dnsuser:-"unbound"}"
			adb_dnsdir="${adb_dnsdir:-"/var/lib/unbound"}"
			adb_dnsheader="${adb_dnsheader:-""}"
			adb_dnsdeny="${adb_dnsdeny:-"${adb_awkcmd} '{print \"local-zone: \\042\"\$0\"\\042 always_nxdomain\"}'"}"
			adb_dnsallow="${adb_dnsallow:-"${adb_awkcmd} '{print \"local-zone: \\042\"\$0\"\\042 always_transparent\"}'"}"
			adb_dnsdenyip="${adb_dnsdenyip:-"0"}"
			adb_dnsallowip="${adb_dnsallowip:-"0"}"
			adb_dnssafesearch="${adb_dnssafesearch:-"${adb_awkcmd} -v item=\"\$item\" '{type=\"AAAA\";if(match(item,/^([0-9]{1,3}\.){3}[0-9]{1,3}$/)){type=\"A\"}}{print \"local-data: \\042\"\$0\" \"type\" \"item\"\\042\"}'"}"
			adb_dnsstop="${adb_dnsstop:-"local-zone: \".\" always_nxdomain"}"
			;;
		"named")
			adb_dnscachecmd="$(command -v rndc || printf "%s" "-")"
			adb_dnsinstance="${adb_dnsinstance:-"0"}"
			adb_dnsuser="${adb_dnsuser:-"bind"}"
			adb_dnsdir="${adb_dnsdir:-"/var/lib/bind"}"
			adb_dnsheader="${adb_dnsheader:-"\$TTL 2h\n@ IN SOA localhost. root.localhost. (1 6h 1h 1w 2h)\n  IN NS  localhost.\n"}"
			adb_dnsdeny="${adb_dnsdeny:-"${adb_awkcmd} '{print \"\"\$0\" CNAME .\\n*.\"\$0\" CNAME .\"}'"}"
			adb_dnsallow="${adb_dnsallow:-"${adb_awkcmd} '{print \"\"\$0\" CNAME rpz-passthru.\\n*.\"\$0\" CNAME rpz-passthru.\"}'"}"
			adb_dnsdenyip="${adb_dnsdenyip:-"${adb_awkcmd} '{print \"\"\$0\".rpz-client-ip CNAME .\"}'"}"
			adb_dnsallowip="${adb_dnsallowip:-"${adb_awkcmd} '{print \"\"\$0\".rpz-client-ip CNAME rpz-passthru.\"}'"}"
			adb_dnssafesearch="${adb_dnssafesearch:-"${adb_awkcmd} -v item=\"\$item\" '{print \"\"\$0\" CNAME \"item\".\\n*.\"\$0\" CNAME \"item\".\"}'"}"
			adb_dnsstop="${adb_dnsstop:-"* CNAME ."}"
			;;
		"kresd")
			adb_dnscachecmd="-"
			adb_dnsinstance="${adb_dnsinstance:-"0"}"
			adb_dnsuser="${adb_dnsuser:-"root"}"
			adb_dnsdir="${adb_dnsdir:-"/tmp/kresd"}"
			adb_dnsheader="${adb_dnsheader:-"\$TTL 2h\n@ IN SOA localhost. root.localhost. (1 6h 1h 1w 2h)\n"}"
			adb_dnsdeny="${adb_dnsdeny:-"${adb_awkcmd} '{print \"\"\$0\" CNAME .\\n*.\"\$0\" CNAME .\"}'"}"
			adb_dnsallow="${adb_dnsallow:-"${adb_awkcmd} '{print \"\"\$0\" CNAME rpz-passthru.\\n*.\"\$0\" CNAME rpz-passthru.\"}'"}"
			adb_dnsdenyip="${adb_dnsdenyip:-"0"}"
			adb_dnsallowip="${adb_dnsallowip:-"0"}"
			adb_dnssafesearch="${adb_dnssafesearch:-"${adb_awkcmd} -v item=\"\$item\" '{print \"\"\$0\" CNAME \"item\".\\n*.\"\$0\" CNAME \"item\".\"}'"}"
			adb_dnsstop="${adb_dnsstop:-"* CNAME ."}"
			;;
		"smartdns")
			adb_dnscachecmd="-"
			adb_dnsinstance="${adb_dnsinstance:-"0"}"
			adb_dnsuser="${adb_dnsuser:-"root"}"
			adb_dnsdir="${adb_dnsdir:-"/tmp/smartdns"}"
			adb_dnsheader="${adb_dnsheader:-""}"
			adb_dnsdeny="${adb_dnsdeny:-"${adb_awkcmd} '{print \"address /\"\$0\"/#\"}'"}"
			adb_dnsallow="${adb_dnsallow:-"${adb_awkcmd} '{print \"address /\"\$0\"/-\"}'"}"
			adb_dnsdenyip="${adb_dnsdenyip:-"0"}"
			adb_dnsallowip="${adb_dnsallowip:-"0"}"
			adb_dnssafesearch="${adb_dnssafesearch:-"${adb_awkcmd} -v item=\"\$item\" '{print \"cname /\"\$0\"/\"item\"\"}'"}"
			adb_dnsstop="${adb_dnsstop:-"address #"}"
			;;
		"raw")
			adb_dnscachecmd="-"
			adb_dnsinstance="${adb_dnsinstance:-"0"}"
			adb_dnsuser="${adb_dnsuser:-"root"}"
			adb_dnsdir="${adb_dnsdir:-"/tmp"}"
			adb_dnsheader="${adb_dnsheader:-""}"
			adb_dnsdeny="${adb_dnsdeny:-"0"}"
			adb_dnsallow="${adb_dnsallow:-"0"}"
			adb_dnsdenyip="${adb_dnsdenyip:-"0"}"
			adb_dnsallowip="${adb_dnsallowip:-"0"}"
			adb_dnssafesearch="${adb_dnssafesearch:-"0"}"
			adb_dnsstop="${adb_dnsstop:-"0"}"
			;;
	esac

	if [ "${adb_dnsshift}" = "0" ]; then
		adb_finaldir="${adb_dnsdir}"
	else
		adb_finaldir="${adb_backupdir}"
	fi
	if [ "${adb_action}" != "stop" ]; then
		for dir in "${adb_dnsdir:-"/tmp"}" "${adb_backupdir:-"/tmp"}" "${adb_jaildir:-"/tmp"}"; do
			[ ! -d "${dir}" ] && mkdir -p "${dir}"
		done
		if [ "${adb_dnsflush}" = "1" ] || [ "${free_mem}" -lt "64" ]; then
			printf "%b" "${adb_dnsheader}" >"${adb_finaldir}/${adb_dnsfile}"
			f_dnsup
		elif [ ! -f "${adb_finaldir}/${adb_dnsfile}" ]; then
			printf "%b" "${adb_dnsheader}" >"${adb_finaldir}/${adb_dnsfile}"
		fi
	fi

	f_log "debug" "f_dns    ::: dns: ${adb_dns}, dns_instance: ${adb_dnsinstance}, dns_user: ${adb_dnsuser}, dns_dir: ${adb_dnsdir}, backup_dir: ${adb_backupdir}, final_dir: ${adb_finaldir}, jail_dir: ${adb_jaildir}"
}

# load fetch utility
#
f_fetch() {
	local fetch fetch_list insecure update="0"

	adb_fetchcmd="$(command -v "${adb_fetchcmd}")"
	if [ ! -x "${adb_fetchcmd}" ]; then
		fetch_list="curl wget-ssl libustream-openssl libustream-wolfssl libustream-mbedtls"
		for fetch in ${fetch_list}; do
			if printf "%s" "${adb_packages}" | "${adb_grepcmd}" -q "\"${fetch}"; then
				case "${fetch}" in
					"wget-ssl")
						fetch="wget"
						;;
					"libustream-openssl" | "libustream-wolfssl" | "libustream-mbedtls")
						fetch="uclient-fetch"
						;;
				esac
				if [ -x "$(command -v "${fetch}")" ]; then
					update="1"
					adb_fetchcmd="$(command -v "${fetch}")"
					uci_set adblock global adb_fetchcmd "${fetch}"
					f_uci "adblock"
					break
				fi
			fi
		done
	fi

	[ ! -x "${adb_fetchcmd}" ] && f_log "err" "download utility with SSL support not found, please set 'adb_fetchcmd' manually"

	case "${adb_fetchcmd##*/}" in
		"curl")
			[ "${adb_fetchinsecure}" = "1" ] && insecure="--insecure"
			adb_fetchparm="${adb_fetchparm:-"${insecure} --connect-timeout 20 --fail --silent --show-error --location -o"}"
			adb_etagparm="--connect-timeout 5 --silent --location --head"
			adb_geoparm="--connect-timeout 5 --silent --location"
			;;
		"wget")
			[ "${adb_fetchinsecure}" = "1" ] && insecure="--no-check-certificate"
			adb_fetchparm="${adb_fetchparm:-"${insecure} --no-cache --no-cookies --max-redirect=0 --timeout=20 -O"}"
			adb_etagparm="--timeout=5 --spider --server-response"
			adb_geoparm="--timeout=5 --quiet -O-"
			;;
		"uclient-fetch")
			[ "${adb_fetchinsecure}" = "1" ] && insecure="--no-check-certificate"
			adb_fetchparm="${adb_fetchparm:-"${insecure} --timeout=20 -O"}"
			adb_geoparm="--timeout=5 --quiet -O-"
			;;
	esac

	f_log "debug" "f_fetch  ::: update: ${update}, cmd: ${adb_fetchcmd:-"-"}"
}

# create temporary files, directories and set dependent options
#
f_temp() {
	if [ -d "${adb_basedir}" ]; then
		adb_tmpdir="$(mktemp -p "${adb_basedir}" -d)"
		adb_tmpload="$(mktemp -p "${adb_tmpdir}" -tu)"
		adb_tmpfile="$(mktemp -p "${adb_tmpdir}" -tu)"
		adb_srtopts="--temporary-directory=${adb_tmpdir} --compress-program=gzip --parallel=${adb_cores}"
	else
		f_log "err" "the base directory '${adb_basedir}' does not exist/is not mounted yet, please create the directory or raise the 'adb_triggerdelay' to defer the adblock start"
	fi
	[ ! -s "${adb_pidfile}" ] && printf "%s" "${$}" >"${adb_pidfile}"
}

# remove temporary files and directories
#
f_rmtemp() {
	rm -rf "${adb_tmpdir}"
	: >"${adb_pidfile}"
}

# remove dns related files
#
f_rmdns() {
	printf "%b" "${adb_dnsheader}" >"${adb_finaldir}/${adb_dnsfile}"
	f_dnsup
	f_rmtemp
}

# commit uci changes
#
f_uci() {
	local config="${1}"

	if [ -n "${config}" ]; then
		uci_commit "${config}"
		case "${config}" in
			"firewall")
				"/etc/init.d/firewall" reload >/dev/null 2>&1
				;;
			"resolver")
				printf "%b" "${adb_dnsheader}" >"${adb_finaldir}/${adb_dnsfile}"
				adb_cnt="0"
				f_jsnup "running"
				"/etc/init.d/${adb_dns}" reload >/dev/null 2>&1
				;;
		esac
	fi
}

# get list counter
#
f_count() {
	local mode="${1}" file="${2}" var="${3}"

	adb_cnt="0"
	if [ -s "${file}" ]; then
		adb_cnt="$("${adb_wccmd}" -l 2>/dev/null <"${file}")"
		if [ -n "${var}" ]; then
			printf "%s" "${adb_cnt}"
		else
			if [ "${mode}" = "final" ]; then
				if [ -s "${adb_tmpdir}/tmp.add.allowlist" ]; then
					adb_cnt="$((adb_cnt - $("${adb_wccmd}" -l 2>/dev/null <"${adb_tmpdir}/tmp.add.allowlist")))"
				fi
				for file in "${adb_tmpdir}/tmp.safesearch".*; do
					if [ -r "${file}" ]; then
						adb_cnt="$((adb_cnt - $("${adb_wccmd}" -l 2>/dev/null <"${file}")))"
					fi
				done
				[ -n "${adb_dnsheader}" ] && adb_cnt="$(((adb_cnt - $(printf "%b" "${adb_dnsheader}" | "${adb_grepcmd}" -c "^")) / 2))"
			fi
		fi
	fi
}

# set external config options
#
f_extconf() {
	local config section zone port fwcfg

	case "${adb_dns}" in
		"dnsmasq")
			config="dhcp"
			if [ "${adb_dnsshift}" = "1" ] &&
				! uci_get ${config} @dnsmasq[${adb_dnsinstance}] addnmount | "${adb_grepcmd}" -q "${adb_backupdir}"; then
				uci -q add_list ${config}.@dnsmasq[${adb_dnsinstance}].addnmount="${adb_backupdir}"
			elif [ "${adb_dnsshift}" = "0" ] &&
				uci_get ${config} @dnsmasq[${adb_dnsinstance}] addnmount | "${adb_grepcmd}" -q "${adb_backupdir}"; then
				uci -q del_list ${config}.@dnsmasq[${adb_dnsinstance}].addnmount="${adb_backupdir}"
			fi
			;;
		"kresd")
			config="resolver"
			if [ "${adb_enabled}" = "1" ] &&
				! uci_get ${config} kresd rpz_file | "${adb_grepcmd}" -q "${adb_dnsdir}/${adb_dnsfile}"; then
				uci -q add_list ${config}.kresd.rpz_file="${adb_dnsdir}/${adb_dnsfile}"
			elif [ "${adb_enabled}" = "0" ] &&
				uci_get ${config} kresd rpz_file | "${adb_grepcmd}" -q "${adb_dnsdir}/${adb_dnsfile}"; then
				uci -q del_list ${config}.kresd.rpz_file="${adb_dnsdir}/${adb_dnsfile}"
			fi
			;;
		"smartdns")
			config="smartdns"
			if [ "${adb_enabled}" = "1" ] &&
				! uci_get ${config} @${config}[${adb_dnsinstance}] conf_files | "${adb_grepcmd}" -q "${adb_dnsdir}/${adb_dnsfile}"; then
				uci -q add_list ${config}.@${config}[${adb_dnsinstance}].conf_files="${adb_dnsdir}/${adb_dnsfile}"
			elif [ "${adb_enabled}" = "0" ] &&
				uci_get ${config} @${config}[${adb_dnsinstance}] conf_files | "${adb_grepcmd}" -q "${adb_dnsdir}/${adb_dnsfile}"; then
				uci -q del_list ${config}.@${config}[${adb_dnsinstance}].conf_files="${adb_dnsdir}/${adb_dnsfile}"
			fi
			;;
	esac
	f_uci "${config}"

	fwcfg="$(uci -qNX show "firewall" | "${adb_awkcmd}" 'BEGIN{FS="[.=]"};/adblock_/{if(zone==$2){next}else{ORS=" ";zone=$2;print zone}}')"
	if [ "${adb_enabled}" = "1" ] && [ "${adb_dnsforce}" = "1" ] &&
		/etc/init.d/firewall enabled; then
		for zone in ${adb_zonelist}; do
			for port in ${adb_portlist}; do
				if ! printf "%s" "${fwcfg}" | "${adb_grepcmd}" -q "adblock_${zone}${port}"; then
					config="firewall"
					if "${adb_lookupcmd}" "localhost." "127.0.0.1:${port}" >/dev/null 2>&1; then
						uci -q batch <<-EOC
							set firewall."adblock_${zone}${port}"="redirect"
							set firewall."adblock_${zone}${port}".name="Adblock DNS (${zone}, ${port})"
							set firewall."adblock_${zone}${port}".src="${zone}"
							set firewall."adblock_${zone}${port}".proto="tcp udp"
							set firewall."adblock_${zone}${port}".src_dport="53"
							set firewall."adblock_${zone}${port}".dest_port="${port}"
							set firewall."adblock_${zone}${port}".target="DNAT"
							set firewall."adblock_${zone}${port}".family="any"
						EOC
					else
						uci -q batch <<-EOC
							set firewall."adblock_${zone}${port}"="rule"
							set firewall."adblock_${zone}${port}".name="Adblock DNS (${zone}, ${port})"
							set firewall."adblock_${zone}${port}".src="${zone}"
							set firewall."adblock_${zone}${port}".proto="tcp udp"
							set firewall."adblock_${zone}${port}".dest_port="${port}"
							set firewall."adblock_${zone}${port}".target="REJECT"
							set firewall."adblock_${zone}${port}".dest="*"
						EOC
					fi
				fi
				fwcfg="${fwcfg/adblock_${zone}${port}[ |\$]/}"
			done
		done
		fwcfg="${fwcfg#"${fwcfg%%[![:space:]]*}"}"
		fwcfg="${fwcfg%"${fwcfg##*[![:space:]]}"}"
	fi
	if [ "${adb_enabled}" = "0" ] || [ "${adb_dnsforce}" = "0" ] || [ -n "${fwcfg}" ]; then
		config="firewall"
		for section in ${fwcfg}; do
			uci_remove firewall "${section}"
		done
	fi
	f_uci "${config}"
}

# restart dns backend
#
f_dnsup() {
	local restart_rc cnt="0" out_rc="4"

	adb_dnspid=""
	if [ "${adb_dns}" = "raw" ] || [ -z "${adb_dns}" ]; then
		out_rc="0"
	else
		if [ "${adb_dnsflush}" = "0" ]; then
			case "${adb_dns}" in
				"unbound")
					if [ -x "${adb_dnscachecmd}" ] && [ -d "${adb_tmpdir}" ] && [ -f "${adb_dnsdir}/unbound.conf" ]; then
						"${adb_dnscachecmd}" -c "${adb_dnsdir}/unbound.conf" dump_cache >"${adb_tmpdir}/adb_cache.dump" 2>/dev/null
					fi
					"/etc/init.d/${adb_dns}" restart >/dev/null 2>&1
					restart_rc="${?}"
					;;
				"named")
					if [ -x "${adb_dnscachecmd}" ] && [ -f "/etc/bind/rndc.conf" ]; then
						"${adb_dnscachecmd}" -c "/etc/bind/rndc.conf" reload >/dev/null 2>&1
						restart_rc="${?}"
					fi
					if [ -z "${restart_rc}" ] || { [ -n "${restart_rc}" ] && [ "${restart_rc}" != "0" ]; }; then
						"/etc/init.d/${adb_dns}" restart >/dev/null 2>&1
						restart_rc="${?}"
					fi
					;;
				*)
					"/etc/init.d/${adb_dns}" restart >/dev/null 2>&1
					restart_rc="${?}"
					;;
			esac
		fi
		if [ -z "${restart_rc}" ]; then
			"/etc/init.d/${adb_dns}" restart >/dev/null 2>&1
			restart_rc="${?}"
		fi
	fi
	if [ "${restart_rc}" = "0" ]; then
		while [ "${cnt}" -le "${adb_dnstimeout}" ]; do
			if "${adb_lookupcmd}" "${adb_lookupdomain}." >/dev/null 2>&1; then
				out_rc="0"
				break
			fi
			cnt="$((cnt + 1))"
			sleep 2
		done
		if [ "${out_rc}" = "0" ] && [ "${adb_dns}" = "unbound" ]; then
			if [ -x "${adb_dnscachecmd}" ] && [ -d "${adb_tmpdir}" ] && [ -s "${adb_tmpdir}/adb_cache.dump" ]; then
				"${adb_dnscachecmd}" -c "${adb_dnsdir}/unbound.conf" load_cache <"${adb_tmpdir}/adb_cache.dump" >/dev/null 2>&1
				restart_rc="${?}"
			fi
		fi
	fi
	adb_dnspid="$("${adb_ubuscmd}" -S call service list 2>/dev/null | "${adb_jsoncmd}" -l1 -e "@[\"${adb_dns}\"].instances.*.pid")"

	f_log "debug" "f_dnsup  ::: dns: ${adb_dns}, cache_cmd: ${adb_dnscachecmd:-"-"}, lookup_domain: ${adb_lookupdomain:-"-"}, restart_rc: ${restart_rc:-"-"}, dns_flush: ${adb_dnsflush}, dns_timeout: ${adb_dnstimeout}, dns_pid: ${adb_dnspid}, dns_cnt: ${cnt}, rc: ${out_rc}"
	return "${out_rc}"
}

# handle etag http header
#
f_etag() {
	local http_head http_code etag_id etag_cnt out_rc="4" feed="${1}" feed_url="${2}" feed_suffix="${3}" feed_cnt="${4:-"1"}"

	[ ! -f "${adb_backupdir}/adblock.etag" ] && : >"${adb_backupdir}/adblock.etag"
	http_head="$("${adb_fetchcmd}" ${adb_etagparm} "${feed_url}${feed_suffix}" 2>&1)"
	http_code="$(printf "%s" "${http_head}" | "${adb_awkcmd}" 'tolower($0)~/^http\/[0123\.]+ /{printf "%s",$2}')"
	etag_id="$(printf "%s" "${http_head}" | "${adb_awkcmd}" 'tolower($0)~/^[[:space:]]*etag: /{gsub("\"","");printf "%s",$2}')"
	if [ -z "${etag_id}" ]; then
		etag_id="$(printf "%s" "${http_head}" | "${adb_awkcmd}" 'tolower($0)~/^[[:space:]]*last-modified: /{gsub(/[Ll]ast-[Mm]odified:|[[:space:]]|,|:/,"");printf "%s\n",$1}')"
	fi
	etag_cnt="$("${adb_grepcmd}" -c "^${feed} " "${adb_backupdir}/adblock.etag")"
	if [ "${http_code}" = "200" ] && [ "${etag_cnt}" = "${feed_cnt}" ] && [ -n "${etag_id}" ] &&
		"${adb_grepcmd}" -q "^${feed} ${feed_suffix}[[:space:]]\+${etag_id}\$" "${adb_backupdir}/adblock.etag"; then
		out_rc="0"
	elif [ -n "${etag_id}" ]; then
		if [ "${feed_cnt}" -lt "${etag_cnt}" ]; then
			"${adb_sedcmd}" -i "/^${feed} /d" "${adb_backupdir}/adblock.etag"
		else
			"${adb_sedcmd}" -i "/^${feed} ${feed_suffix//\//\\/}/d" "${adb_backupdir}/adblock.etag"
		fi
		printf "%-80s%s\n" "${feed} ${feed_suffix}" "${etag_id}" >>"${adb_backupdir}/adblock.etag"
		out_rc="2"
	fi

	f_log "debug" "f_etag   ::: feed: ${feed}, suffix: ${feed_suffix:-"-"}, http_code: ${http_code:-"-"}, feed/etag: ${feed_cnt}/${etag_cnt:-"0"}, rc: ${out_rc}"
	return "${out_rc}"
}

# backup/restore/remove blocklists
#
f_list() {
	local file rset item array safe_url safe_ips safe_cname safe_domains ip out_rc file_name mode="${1}" src_name="${2:-"${src_name}"}" in_rc="${src_rc:-0}" use_cname="0" ffiles="-maxdepth 1 -name adb_list.*.gz"

	case "${mode}" in
		"iplist")
			src_name="${mode}"
			file_name="${adb_tmpdir}/tmp.add.${src_name}"
			if [ "${adb_dnsallowip}" != "0" ] && [ "${adb_dnsdenyip}" != "0" ]; then
				rset="BEGIN{FS=\"[.:]\";pfx=\"32\"}{if(match(\$0,/:/))pfx=\"128\"}{printf \"%s.\",pfx;for(seg=NF;seg>=1;seg--)if(seg==1)printf \"%s\n\",\$seg;else if(\$seg>=0)printf \"%s.\",\$seg; else printf \"%s.\",\"zz\"}"
				if [ -n "${adb_allowip}" ]; then
					: >"${adb_tmpdir}/tmp.raw.${src_name}"
					for ip in ${adb_allowip}; do
						printf "%s" "${ip}" | "${adb_awkcmd}" "${rset}" >>"${adb_tmpdir}/tmp.raw.${src_name}"
					done
					eval "${adb_dnsallowip}" "${adb_tmpdir}/tmp.raw.${src_name}" >"${file_name}"
					out_rc="${?}"
				fi
				if [ -n "${adb_denyip}" ] && { [ -z "${out_rc}" ] || [ "${out_rc}" = "0" ]; }; then
					: >"${adb_tmpdir}/tmp.raw.${src_name}"
					for ip in ${adb_denyip}; do
						printf "%s" "${ip}" | "${adb_awkcmd}" "${rset}" >>"${adb_tmpdir}/tmp.raw.${src_name}"
					done
					eval "${adb_dnsdenyip}" "${adb_tmpdir}/tmp.raw.${src_name}" >>"${file_name}"
					out_rc="${?}"
				fi
				: >"${adb_tmpdir}/tmp.raw.${src_name}"
			fi
			;;
		"blocklist" | "allowlist")
			src_name="${mode}"
			rset="/^([[:alnum:]_-]{1,63}\\.)+[[:alpha:]]+([[:space:]]|$)/{print tolower(\$1)}"
			case "${src_name}" in
				"blocklist")
					if [ -f "${adb_blocklist}" ]; then
						file_name="${adb_tmpfile}.${src_name}"
						"${adb_awkcmd}" "${rset}" "${adb_blocklist}" >"${adb_tmpdir}/tmp.raw.${src_name}"
						if [ -s "${adb_allowlist}" ]; then
							"${adb_awkcmd}" 'NR==FNR{member[$1];next}!($1 in member)' "${adb_allowlist}" "${adb_tmpdir}/tmp.raw.${src_name}" >"${adb_tmpdir}/tmp.deduplicate.${src_name}"
						else
							"${adb_catcmd}" "${adb_tmpdir}/tmp.raw.${src_name}" >"${adb_tmpdir}/tmp.deduplicate.${src_name}"
						fi
						if [ "${adb_tld}" = "1" ]; then
							"${adb_awkcmd}" 'BEGIN{FS="."}{for(f=NF;f>1;f--)printf "%s.",$f;print $1}' "${adb_tmpdir}/tmp.deduplicate.${src_name}" |
								"${adb_sortcmd}" ${adb_srtopts} -u >"${file_name}"
							out_rc="${?}"
						else
							"${adb_sortcmd}" ${adb_srtopts} -u "${adb_tmpdir}/tmp.deduplicate.${src_name}" 2>/dev/null >"${file_name}"
							out_rc="${?}"
						fi
					fi
					;;
				"allowlist")
					if [ -f "${adb_allowlist}" ] && [ "${adb_dnsallow}" != "0" ]; then
						file_name="${adb_tmpdir}/tmp.raw.${src_name}"
						printf "%s\n" "${adb_lookupdomain}" | "${adb_awkcmd}" "${rset}" >"${file_name}"
						"${adb_awkcmd}" "${rset}" "${adb_allowlist}" >>"${file_name}"
						"${adb_awkcmd}" "${rset}" "${file_name}" >"${adb_tmpdir}/tmp.rem.${src_name}"
						eval "${adb_dnsallow}" "${file_name}" >"${adb_tmpdir}/tmp.add.${src_name}"
						out_rc="${?}"
						if [ "${adb_jail}" = "1" ] && [ "${adb_dnsstop}" != "0" ]; then
							printf "%b" "${adb_dnsheader}" >"${adb_tmpdir}/${adb_dnsjail}"
							"${adb_catcmd}" "${adb_tmpdir}/tmp.add.${src_name}" >>"${adb_tmpdir}/${adb_dnsjail}"
							printf "%b\n" "${adb_dnsstop}" >>"${adb_tmpdir}/${adb_dnsjail}"
						fi
					fi
					;;
			esac
			;;
		"safesearch")
			file_name="${adb_tmpdir}/tmp.safesearch.${src_name}"
			if [ "${adb_dns}" = "named" ] || [ "${adb_dns}" = "kresd" ] || [ "${adb_dns}" = "smartdns" ]; then
				use_cname="1"
			fi
			case "${src_name}" in
				"google")
					rset="/^\\.([[:alnum:]_-]{1,63}\\.)+[[:alpha:]]+([[:space:]]|$)/{printf \"%s\n%s\n\",tolower(\"www\"\$1),tolower(substr(\$1,2,length(\$1)))}"
					safe_url="https://www.google.com/supported_domains"
					safe_cname="forcesafesearch.google.com"
					if [ -s "${adb_backupdir}/safesearch.${src_name}.gz" ]; then
						"${adb_zcatcmd}" "${adb_backupdir}/safesearch.${src_name}.gz" >"${adb_tmpdir}/tmp.load.safesearch.${src_name}"
					else
						"${adb_fetchcmd}" ${adb_fetchparm} "${adb_tmpdir}/tmp.load.safesearch.${src_name}" "${safe_url}" 2>/dev/null
						if [ -s "${adb_tmpdir}/tmp.load.safesearch.${src_name}" ]; then
							"${adb_gzipcmd}" -cf "${adb_tmpdir}/tmp.load.safesearch.${src_name}" >"${adb_backupdir}/safesearch.${src_name}.gz"
						fi
					fi
					[ -s "${adb_tmpdir}/tmp.load.safesearch.${src_name}" ] && safe_domains="$("${adb_awkcmd}" "${rset}" "${adb_tmpdir}/tmp.load.safesearch.${src_name}")"
					;;
				"bing")
					safe_cname="strict.bing.com"
					safe_domains="www.bing.com"
					;;
				"brave")
					safe_cname="forcesafe.search.brave.com"
					safe_domains="search.brave.com"
					;;
				"duckduckgo")
					safe_cname="safe.duckduckgo.com"
					safe_domains="duckduckgo.com"
					;;
				"pixabay")
					safe_cname="safesearch.pixabay.com"
					safe_domains="pixabay.com"
					;;
				"yandex")
					safe_cname="familysearch.yandex.ru"
					safe_domains="ya.ru yandex.ru yandex.com yandex.com.tr yandex.ua yandex.by yandex.ee yandex.lt yandex.lv yandex.md yandex.uz yandex.tm yandex.tj yandex.az yandex.kz"
					;;
				"youtube")
					safe_cname="restrict.youtube.com"
					safe_domains="www.youtube.com m.youtube.com youtubei.googleapis.com youtube.googleapis.com www.youtube-nocookie.com"
					;;
			esac
			if [ -n "${safe_domains}" ] && [ -n "${safe_cname}" ]; then
				if [ "${use_cname}" = "0" ]; then
					safe_ips="$("${adb_lookupcmd}" "${safe_cname}" 2>/dev/null | "${adb_awkcmd}" '/^Address[ 0-9]*: /{ORS=" ";print $NF}')"
				fi
				if [ -n "${safe_ips}" ] || [ "${use_cname}" = "1" ]; then
					printf "%s\n" ${safe_domains} >"${adb_tmpdir}/tmp.raw.safesearch.${src_name}"
					[ "${use_cname}" = "1" ] && array="${safe_cname}" || array="${safe_ips}"
				fi
			fi
			if [ -s "${adb_tmpdir}/tmp.raw.safesearch.${src_name}" ]; then
				: >"${file_name}"
				for item in ${array}; do
					if ! eval "${adb_dnssafesearch}" "${adb_tmpdir}/tmp.raw.safesearch.${src_name}" >>"${file_name}"; then
						: >"${file_name}"
						break
					fi
				done
				: >"${adb_tmpdir}/tmp.raw.safesearch.${src_name}"
				out_rc="0"
			fi
			;;
		"prepare")
			file_name="${src_tmpfile}"
			if [ -s "${src_tmpload}" ]; then
				"${adb_awkcmd}" "${src_rset}" "${src_tmpload}" | "${adb_sedcmd}" "s/\r//g" |
					{ [ "${adb_tld}" = "1" ] && "${adb_awkcmd}" 'BEGIN{FS="."}{for(f=NF;f>1;f--)printf "%s.",$f;print $1}' || "${adb_catcmd}"; } |
					"${adb_sortcmd}" ${adb_srtopts} -u >"${src_tmpfile}" 2>/dev/null
				out_rc="${?}"
				if [ "${out_rc}" = "0" ] && [ -s "${src_tmpfile}" ]; then
					f_list backup
				elif [ "${adb_action}" != "boot" ] && [ "${adb_action}" != "start" ]; then
					f_log "info" "preparation of '${src_name}' failed, rc: ${src_rc}"
					f_list restore
					out_rc="${?}"
					: >"${src_tmpfile}"
				fi
			else
				f_log "info" "download of '${src_name}' failed, url: ${src_url}, rule: ${src_rset:-"-"}, categories: ${src_cat:-"-"}, rc: ${src_rc}"
				if [ "${adb_action}" != "boot" ] && [ "${adb_action}" != "start" ]; then
					f_list restore
					out_rc="${?}"
				fi
			fi
			;;
		"backup")
			file_name="${src_tmpfile}"
			"${adb_gzipcmd}" -cf "${src_tmpfile}" >"${adb_backupdir}/adb_list.${src_name}.gz"
			out_rc="${?}"
			;;
		"restore")
			file_name="${src_tmpfile}"
			if [ -n "${src_name}" ] && [ -s "${adb_backupdir}/adb_list.${src_name}.gz" ]; then
				"${adb_zcatcmd}" "${adb_backupdir}/adb_list.${src_name}.gz" >"${src_tmpfile}"
				out_rc="${?}"
			elif [ -z "${src_name}" ]; then
				for file in "${adb_backupdir}/adb_list."*.gz; do
					if [ -r "${file}" ]; then
						name="${file##*/}"
						name="${name%.*}"
						"${adb_zcatcmd}" "${file}" >"${adb_tmpfile}.${name}"
						out_rc="${?}"
						[ "${out_rc}" != "0" ] && break
					fi
				done
			else
				out_rc=4
			fi
			if [ "${adb_action}" != "boot" ] && [ "${adb_action}" != "start" ] && [ "${adb_action}" != "restart" ] &&
				[ "${adb_action}" != "resume" ] && [ -n "${src_name}" ] && [ "${out_rc}" != "0" ]; then
				adb_feed="${adb_feed/${src_name}/}"
			fi
			;;
		"remove")
			rm "${adb_backupdir}/adb_list.${src_name}.gz" 2>/dev/null
			out_rc="${?}"
			adb_feed="${adb_feed/${src_name}/}"
			;;
		"merge")
			src_name=""
			file_name="${adb_tmpdir}/${adb_dnsfile}"
			for file in ${adb_feed}; do
				ffiles="${ffiles} -a ! -name adb_list.${file}.gz"
			done
			if [ "${adb_safesearch}" = "1" ] && [ "${adb_dnssafesearch}" != "0" ]; then
				ffiles="${ffiles} -a ! -name safesearch.google.gz"
			fi
			"${adb_findcmd}" "${adb_backupdir}" ${ffiles} -print0 2>/dev/null | xargs -0 rm 2>/dev/null
			"${adb_sortcmd}" ${adb_srtopts} -mu "${adb_tmpfile}".* 2>/dev/null >"${file_name}"
			out_rc="${?}"
			rm -f "${adb_tmpfile}".*
			;;
		"final")
			src_name=""
			file_name="${adb_finaldir}/${adb_dnsfile}"
			rm -f "${file_name}"
			[ -n "${adb_dnsheader}" ] && printf "%b" "${adb_dnsheader}" >>"${file_name}"
			[ -s "${adb_tmpdir}/tmp.add.iplist" ] && "${adb_catcmd}" "${adb_tmpdir}/tmp.add.iplist" >>"${file_name}"
			[ -s "${adb_tmpdir}/tmp.add.allowlist" ] && "${adb_catcmd}" "${adb_tmpdir}/tmp.add.allowlist" >>"${file_name}"
			[ "${adb_safesearch}" = "1" ] && "${adb_catcmd}" "${adb_tmpdir}/tmp.safesearch."* 2>/dev/null >>"${file_name}"
			if [ "${adb_dnsdeny}" != "0" ]; then
				eval "${adb_dnsdeny}" "${adb_tmpdir}/${adb_dnsfile}" >>"${file_name}"
			else
				"${adb_catcmd}" "${adb_tmpdir}/${adb_dnsfile}" >>"${file_name}"
			fi
			if [ "${adb_dnsshift}" = "1" ] && [ ! -L "${adb_dnsdir}/${adb_dnsfile}" ]; then
				ln -fs "${file_name}" "${adb_dnsdir}/${adb_dnsfile}"
			elif [ "${adb_dnsshift}" = "0" ] && [ -s "${adb_backupdir}/${adb_dnsfile}" ]; then
				rm -f "${adb_backupdir}/${adb_dnsfile}"
			fi
			out_rc="0"
			;;
	esac
	f_count "${mode}" "${file_name}"
	out_rc="${out_rc:-"${in_rc}"}"

	f_log "debug" "f_list   ::: name: ${src_name:-"-"}, mode: ${mode}, cnt: ${adb_cnt}, in_rc: ${in_rc}, out_rc: ${out_rc}"
	return "${out_rc}"
}

# top level domain compression
#
f_tld() {
	local cnt_tld cnt_rem source="${1}" temp_tld="${1}.tld"

	if "${adb_awkcmd}" '{if(NR==1){tld=$NF};while(getline){if(index($NF,tld".")==0){print tld;tld=$NF}}print tld}' "${source}" |
		"${adb_awkcmd}" 'BEGIN{FS="."}{for(f=NF;f>1;f--)printf "%s.",$f;print $1}' >"${temp_tld}"; then
		[ "${adb_debug}" = "1" ] && cnt_tld="$(f_count tld "${temp_tld}" "var")"
		if [ -s "${adb_tmpdir}/tmp.rem.allowlist" ]; then
			"${adb_awkcmd}" 'NR==FNR{del[$0];next};!($0 in del)' "${adb_tmpdir}/tmp.rem.allowlist" "${temp_tld}" >"${source}"
			[ "${adb_debug}" = "1" ] && cnt_rem="$(f_count tld "${source}" "var")"
		else
			"${adb_catcmd}" "${temp_tld}" >"${source}"
		fi
	fi
	: >"${temp_tld}"

	f_log "debug" "f_tld    ::: name: -, cnt: ${adb_cnt:-"-"}, cnt_tld: ${cnt_tld:-"-"}, cnt_rem: ${cnt_rem:-"-"}"
}

# suspend/resume adblock processing
#
f_switch() {
	local status entry done="false" mode="${1}"

	json_init
	json_load_file "${adb_rtfile}" >/dev/null 2>&1
	json_select "data" >/dev/null 2>&1
	json_get_var status "adblock_status"
	f_env
	if [ "${mode}" = "suspend" ] && [ "${status}" = "enabled" ]; then
		if [ "${adb_dnsshift}" = "0" ] && [ -f "${adb_finaldir}/${adb_dnsfile}" ]; then
			mv -f "${adb_finaldir}/${adb_dnsfile}" "${adb_backupdir}/${adb_dnsfile}"
			printf "%b" "${adb_dnsheader}" >"${adb_finaldir}/${adb_dnsfile}"
			done="true"
		elif [ "${adb_dnsshift}" = "1" ] && [ -L "${adb_dnsdir}/${adb_dnsfile}" ]; then
			rm -f "${adb_dnsdir}/${adb_dnsfile}"
			printf "%b" "${adb_dnsheader}" >"${adb_dnsdir}/${adb_dnsfile}"
			done="true"
		fi
	elif [ "${mode}" = "resume" ] && [ "${status}" = "paused" ]; then
		if [ "${adb_dnsshift}" = "0" ] && [ -f "${adb_backupdir}/${adb_dnsfile}" ]; then
			mv -f "${adb_backupdir}/${adb_dnsfile}" "${adb_finaldir}/${adb_dnsfile}"
			f_count "resume" "${adb_finaldir}/${adb_dnsfile}"
			done="true"
		elif [ "${adb_dnsshift}" = "1" ] && [ ! -L "${adb_finaldir}/${adb_dnsfile}" ]; then
			ln -fs "${adb_finaldir}/${adb_dnsfile}" "${adb_dnsdir}/${adb_dnsfile}"
			f_count "resume" "${adb_finaldir}/${adb_dnsfile}"
			done="true"
		fi
	fi
	if [ "${done}" = "true" ]; then
		f_dnsup
		f_jsnup "${mode}"
		f_log "info" "${mode} adblock service"
		f_rmtemp
	else
		f_jsnup "stopped"
		f_rmdns
	fi
}

# query blocklist for certain (sub-)domains
#
f_query() {
	local search result prefix suffix field query_start query_end query_timeout=30 domain="${1}" tld="${1#*.}"

	if [ -z "${domain}" ]; then
		printf "%s\n" "::: invalid input, please submit a single (sub-)domain :::"
	else
		case "${adb_dns}" in
			"dnsmasq")
				prefix='local=.*[\/\.]'
				suffix='\/'
				field="2"
				;;
			"unbound")
				prefix='local-zone: .*["\.]'
				suffix='" always_nxdomain'
				field="3"
				;;
			"named")
				prefix=""
				suffix=' CNAME \.'
				field="1"
				;;
			"kresd")
				prefix=""
				suffix=' CNAME \.'
				field="1"
				;;
			"smartdns")
				prefix='address .*.*[\/\.]'
				suffix='\/#'
				field="3"
				;;
			"raw")
				prefix=""
				suffix=""
				field="1"
				;;
		esac
		query_start="$(date "+%s")"
		while :; do
			search="${domain//[+*~%\$&\"\']/}"
			search="${search//./\\.}"
			result="$("${adb_awkcmd}" -F '/|\"|\t| ' "/^(${prefix}${search}${suffix})$/{i++;if(i<=9){printf \"  + %s\n\",\$${field}}else if(i==10){printf \"  + %s\n\",\"[...]\";exit}}" "${adb_finaldir}/${adb_dnsfile}")"
			printf "%s\n%s\n%s\n" ":::" "::: domain '${domain}' in active blocklist" ":::"
			printf "%s\n\n" "${result:-"  - no match"}"
			[ "${domain}" = "${tld}" ] && break
			domain="${tld}"
			tld="${domain#*.}"
		done
		if [ -d "${adb_backupdir}" ]; then
			search="${1//[+*~%\$&\"\']/}"
			search="${search//./\\.}"
			printf "%s\n%s\n%s\n" ":::" "::: domain '${1}' in backups and in local block-/allowlist" ":::"
			for file in "${adb_backupdir}/adb_list".*.gz "${adb_blocklist}" "${adb_allowlist}"; do
				suffix="${file##*.}"
				if [ "${suffix}" = "gz" ]; then
					"${adb_zcatcmd}" "${file}" 2>/dev/null |
						{ [ "${adb_tld}" = "1" ] && "${adb_awkcmd}" 'BEGIN{FS="."}{for(f=NF;f>1;f--)printf "%s.",$f;print $1}' || :"${adb_catcmd}"; } |
						"${adb_awkcmd}" -v f="${file##*/}" "BEGIN{rc=1};/^($search|.*\\.${search})$/{i++;if(i<=3){printf \"  + %-30s%s\n\",f,\$1;rc=0}else if(i==4){printf \"  + %-30s%s\n\",f,\"[...]\"}};END{exit rc}"
					rc="${?}"
				else
					"${adb_awkcmd}" -v f="${file##*/}" "BEGIN{rc=1};/^($search|.*\\.${search})$/{i++;if(i<=3){printf \"  + %-30s%s\n\",f,\$1;rc=0}else if(i==4){printf \"  + %-30s%s\n\",f,\"[...]\"}};END{exit rc}" "${file}"
					rc="${?}"
				fi
				if [ "${rc}" = "0" ]; then
					result="true"
					query_end="$(date "+%s")"
					if [ "$((query_end - query_start))" -gt "${query_timeout}" ]; then
						printf "%s\n\n" "  - [...]"
						break
					fi
				fi
			done
			[ "${result}" != "true" ] && printf "%s\n\n" "  - no match"
		fi
	fi
}

# update runtime information
#
f_jsnup() {
	local pids object feeds end_time runtime dns dns_ver dns_mem free_mem custom_feed="0" status="${1:-"enabled"}"

	if [ -n "${adb_dnspid}" ]; then
		pids="$("${adb_pgrepcmd}" -P "${adb_dnspid}" 2>/dev/null)"
		for pid in ${adb_dnspid} ${pids}; do
			dns_mem="$((dns_mem + $("${adb_awkcmd}" '/^VmSize/{printf "%s", $2}' "/proc/${pid}/status" 2>/dev/null)))"
		done
		case "${adb_dns}" in
			"kresd")
				dns="knot-resolver"
				;;
			"named")
				dns="bind-server"
				;;
			"unbound")
				dns="unbound-daemon"
				;;
			"dnsmasq")
				dns='dnsmasq", "dnsmasq-full", "dnsmasq-dhcpv6'
				;;
		esac
		dns_ver="$(printf "%s" "${adb_packages}" | "${adb_jsoncmd}" -ql1 -e "@.packages[\"${dns:-"${adb_dns}"}\"]")"
		dns_mem="$("${adb_awkcmd}" -v mem="${dns_mem}" 'BEGIN{printf "%.2f", mem/1024}' 2>/dev/null)"
	fi
	free_mem="$("${adb_awkcmd}" '/^MemAvailable/{printf "%.2f", $2/1024}' "/proc/meminfo" 2>/dev/null)"
	adb_cnt="$("${adb_awkcmd}" -v cnt="${adb_cnt}" 'BEGIN{res="";pos=0;for(i=length(cnt);i>0;i--){res=substr(cnt,i,1)res;pos++;if(pos==3&&i>1){res=" "res;pos=0;}}; printf"%s",res}')"
	[ -s "${adb_customfeedfile}" ] && custom_feed="1"

	case "${status}" in
		"enabled")
			if [ -n "${adb_starttime}" ] && [ "${adb_action}" != "boot" ]; then
				end_time="$(date "+%s")"
				duration="$(((end_time - adb_starttime) / 60))m $(((end_time - adb_starttime) % 60))s"
			fi
			runtime="mode: ${adb_action}, $(date -Iseconds), duration: ${duration:-"-"}, ${free_mem:-0} MB available"
			;;
		"resume")
			status="enabled"
			;;
		"suspend")
			adb_cnt="0"
			status="paused"
			;;
		*)
			adb_cnt="0"
			;;
	esac

	json_init
	if json_load_file "${adb_rtfile}" >/dev/null 2>&1; then
		[ -z "${adb_cnt}" ] && json_get_var adb_cnt "blocked_domains"
		[ -z "${runtime}" ] && json_get_var runtime "last_run"
		if [ "${status}" = "enabled" ]; then
			if [ "${adb_jail}" = "1" ] && [ "${adb_jaildir}" = "${adb_dnsdir}" ]; then
				adb_cnt="0"
				feeds="restrictive_jail"
			else
				feeds="$(printf "%s\n" ${adb_feed} | "${adb_sortcmd}" | "${adb_awkcmd}" '{ORS=" ";print $0}')"
			fi
		fi
	fi
	printf "%s\n" "{}" >"${adb_rtfile}"
	json_init
	json_load_file "${adb_rtfile}" >/dev/null 2>&1
	json_add_string "adblock_status" "${status}"
	json_add_string "adblock_version" "${adb_ver}"
	json_add_string "blocked_domains" "${adb_cnt:-"0"}"
	json_add_array "active_feeds"
	for object in ${feeds:-"-"}; do
		json_add_string "${object}" "${object}"
	done
	json_close_array
	json_add_string "dns_backend" "${adb_dns:-"-"} (${dns_ver:-"-"}), ${adb_finaldir:-"-"}, ${dns_mem:-"0"} MB"
	json_add_string "run_ifaces" "trigger: ${adb_trigger:-"-"}, report: ${adb_repiface:-"-"}"
	json_add_string "run_directories" "base: ${adb_basedir}, dns: ${adb_dnsdir}, backup: ${adb_backupdir}, report: ${adb_reportdir}, jail: ${adb_jaildir:-"-"}"
	json_add_string "run_flags" "shift: $(f_char ${adb_dnsshift}), custom feed: $(f_char ${custom_feed}), force: $(f_char ${adb_dnsforce}), flush: $(f_char ${adb_dnsflush}), tld: $(f_char ${adb_tld}), search: $(f_char ${adb_safesearch}), report: $(f_char ${adb_report}), mail: $(f_char ${adb_mail}), jail: $(f_char ${adb_jail})"
	json_add_string "last_run" "${runtime:-"-"}"
	json_add_string "system_info" "cores: ${adb_cores}, fetch: ${adb_fetchcmd##*/}, ${adb_sysver}"
	json_dump >"${adb_rtfile}"

	if [ "${adb_mail}" = "1" ] && [ -x "${adb_mailservice}" ] && [ "${status}" = "enabled" ]; then
		"${adb_mailservice}" >/dev/null 2>&1
	fi
}

# write to syslog
#
f_log() {
	local class="${1}" log_msg="${2}"

	if [ -n "${log_msg}" ] && { [ "${class}" != "debug" ] || [ "${adb_debug}" = "1" ]; }; then
		[ -x "${adb_loggercmd}" ] && "${adb_loggercmd}" -p "${class}" -t "adblock-${adb_ver}[${$}]" "${log_msg::256}" ||
			printf "%s %s %s\n" "${class}" "adblock-${adb_ver}[${$}]" "${log_msg::256}"
		if [ "${class}" = "err" ] || [ "${class}" = "emerg" ]; then
			[ "${adb_action}" != "mail" ] && f_rmdns
			f_jsnup "error"
			exit 1
		fi
	fi
}

# main function for blocklist processing
#
f_main() {
	local src_tmpload src_tmpfile src_name src_rset src_url src_cat src_item src_list src_entries src_suffix src_rc entry cnt

	# allow- and blocklist preparation
	#
	cnt="1"
	for entry in ${adb_locallist}; do
		(
			f_list "${entry}" "${entry}"
		) &
		[ "${cnt}" -gt "${adb_cores}" ] && wait -n
		cnt="$((cnt + 1))"
	done
	wait

	# jail mode preparation
	#
	if [ "${adb_jail}" = "1" ] && [ "${adb_dnsstop}" != "0" ]; then
		if [ "${adb_jaildir}" = "${adb_dnsdir}" ]; then
			"${adb_catcmd}" "${adb_tmpdir}/${adb_dnsjail}" >"${adb_finaldir}/${adb_dnsfile}"
			chown "${adb_dnsuser}" "${adb_finaldir}/${adb_dnsfile}" 2>/dev/null
			if [ "${adb_dnsshift}" = "1" ] && [ ! -L "${adb_dnsdir}/${adb_dnsfile}" ]; then
				ln -fs "${adb_finaldir}/${adb_dnsfile}" "${adb_dnsdir}/${adb_dnsfile}"
			elif [ "${adb_dnsshift}" = "0" ] && [ -s "${adb_backupdir}/${adb_dnsfile}" ]; then
				rm -f "${adb_backupdir}/${adb_dnsfile}"
			fi
			if f_dnsup; then
				if [ "${adb_action}" != "resume" ]; then
					f_jsnup "enabled"
				fi
				f_log "info" "restrictive jail mode enabled successfully (${adb_sysver})"
			else
				f_log "err" "dns backend restart in jail mode failed"
			fi
			f_rmtemp
			return
		else
			"${adb_catcmd}" "${adb_tmpdir}/${adb_dnsjail}" >"${adb_jaildir}/${adb_dnsjail}"
			chown "${adb_dnsuser}" "${adb_jaildir}/${adb_dnsjail}" 2>/dev/null
			f_log "info" "additional restrictive jail blocklist placed in ${adb_jaildir}"
		fi
	fi

	# safe search preparation
	#
	if [ "${adb_safesearch}" = "1" ] && [ "${adb_dnssafesearch}" != "0" ]; then
		[ -z "${adb_safesearchlist}" ] && adb_safesearchlist="google bing brave duckduckgo pixabay yandex youtube"
		cnt="1"
		for entry in ${adb_safesearchlist}; do
			(
				f_list safesearch "${entry}"
			) &
			[ "${cnt}" -gt "${adb_cores}" ] && wait -n
			cnt="$((cnt + 1))"
		done
		wait
	fi

	# main loop
	#
	cnt="1"
	for src_name in ${adb_feed}; do
		if ! json_select "${src_name}" >/dev/null 2>&1; then
			adb_feed="${adb_feed/${src_name}/}"
			continue
		fi
		json_get_var src_url "url" >/dev/null 2>&1
		json_get_var src_rset "rule" >/dev/null 2>&1
		json_select ..
		src_tmpcat="${adb_tmpload}.${src_name}.cat"
		src_tmpload="${adb_tmpload}.${src_name}.load"
		src_tmparchive="${adb_tmpload}.${src_name}.archive"
		src_tmpfile="${adb_tmpfile}.${src_name}"

		src_rc=4

		# basic pre-checks
		#
		if [ -z "${src_url}" ] || [ -z "${src_rset}" ]; then
			f_list remove
			continue
		fi

		# download queue processing
		#
		src_cat=""
		src_entries=""
		[ "${src_name}" = "1hosts" ] && src_cat="${adb_hst_feed}"
		[ "${src_name}" = "hagezi" ] && src_cat="${adb_hag_feed}"
		[ "${src_name}" = "stevenblack" ] && src_cat="${adb_stb_feed}"
		if [ -n "${src_cat}" ]; then
			(
				# restore handling on boot, resume or (re-)start
				#
				if [ "${adb_action}" = "boot" ] || [ "${adb_action}" = "start" ] || [ "${adb_action}" = "restart" ] || [ "${adb_action}" = "resume" ]; then
					if f_list restore && [ -s "${src_tmpfile}" ]; then
						continue
					fi
				fi
				# etag handling on reload
				#
				if [ -n "${adb_etagparm}" ] && [ "${adb_action}" = "reload" ]; then
					etag_rc="0"
					src_cnt="$(printf "%s" "${src_cat}" | "${adb_wccmd}" -w)"
					for suffix in ${src_cat}; do
						if ! f_etag "${src_name}" "${src_url}" "${suffix}" "${src_cnt}"; then
							etag_rc="$((etag_rc + 1))"
						fi
					done
					if [ "${etag_rc}" = "0" ]; then
						if f_list restore; then
							continue
						fi
					fi
				fi
				# normal download
				#
				for suffix in ${src_cat}; do
					"${adb_fetchcmd}" ${adb_fetchparm} "${src_tmpcat}" "${src_url}${suffix}" >/dev/null 2>&1
					src_rc="${?}"
					if [ "${src_rc}" = "0" ] && [ -s "${src_tmpcat}" ]; then
						"${adb_catcmd}" "${src_tmpcat}" >>"${src_tmpload}"
						: >"${src_tmpcat}"
					fi
				done
				f_list prepare
			) &
		else
			(
				[ "${src_name}" = "utcapitole" ] && src_cat="${adb_utc_feed}"
				# restore handling on boot, resume or (re-)start
				#
				if [ "${adb_action}" = "boot" ] || [ "${adb_action}" = "start" ] || [ "${adb_action}" = "restart" ] || [ "${adb_action}" = "resume" ]; then
					if f_list restore && [ -s "${src_tmpfile}" ]; then
						continue
					fi
				fi
				# etag handling on reload
				#
				if [ -n "${adb_etagparm}" ] && [ "${adb_action}" = "reload" ]; then
					if f_etag "${src_name}" "${src_url}"; then
						if f_list restore && [ -s "${src_tmpfile}" ]; then
							continue
						fi
					fi
				fi
				# normal download
				#
				if [ "${src_name}" = "utcapitole" ]; then
					if [ -n "${src_cat}" ]; then
						"${adb_fetchcmd}" ${adb_fetchparm} "${src_tmparchive}" "${src_url}" >/dev/null 2>&1
						src_rc="${?}"
						if [ "${src_rc}" = "0" ] && [ -s "${src_tmparchive}" ]; then
							src_suffix="$(eval printf "%s" \"\$\{adb_src_suffix_${src_name}:-\"domains\"\}\")"
							src_list="$(tar -tzf "${src_tmparchive}" 2>/dev/null)"
							for src_item in ${src_cat}; do
								src_entries="${src_entries} $(printf "%s" "${src_list}" | "${adb_grepcmd}" -E "${src_item}/${src_suffix}$")"
							done
							if [ -n "${src_entries}" ]; then
								tar -xOzf "${src_tmparchive}" ${src_entries} 2>/dev/null >"${src_tmpload}"
								src_rc="${?}"
							fi
							: >"${src_tmparchive}"
						fi
					fi
				else
					"${adb_fetchcmd}" ${adb_fetchparm} "${src_tmpload}" "${src_url}" >/dev/null 2>&1
					src_rc="${?}"
				fi
				f_list prepare
			) &
		fi
		[ "${cnt}" -gt "${adb_cores}" ] && wait -n
		cnt="$((cnt + 1))"
	done
	wait

	# tld compression and dns restart
	#
	if f_list merge && [ -s "${adb_tmpdir}/${adb_dnsfile}" ]; then
		[ "${adb_tld}" = "1" ] && f_tld "${adb_tmpdir}/${adb_dnsfile}"
		f_list final
	else
		printf "%b" "${adb_dnsheader}" >"${adb_finaldir}/${adb_dnsfile}"
	fi
	chown "${adb_dnsuser}" "${adb_finaldir}/${adb_dnsfile}" 2>/dev/null
	if f_dnsup; then
		[ "${adb_action}" != "resume" ] && f_jsnup "enabled"
		f_log "info" "blocklist with overall ${adb_cnt} blocked domains loaded successfully (${adb_sysver})"
	else
		f_log "err" "dns backend restart with adblock blocklist failed"
	fi
	f_rmtemp
}

# trace dns queries via tcpdump and prepare a report
#
f_report() {
	local report_raw report_txt content status total start end start_date start_time end_date end_time blocked percent top_list top array item index ports value key key_list
	local ip request requests iface_v4 iface_v6 ip_v4 ip_v6 map_jsn cnt="0" resolve="-nn" action="${1}" top_count="${2:-"10"}" res_count="${3:-"50"}" search="${4:-"+"}"

	report_raw="${adb_reportdir}/adb_report.raw"
	report_srt="${adb_reportdir}/adb_report.srt"
	report_jsn="${adb_reportdir}/adb_report.jsn"
	report_txt="${adb_reportdir}/adb_mailreport.txt"
	map_jsn="${adb_reportdir}/adb_map.jsn"

	# build json file
	#
	if [ "${action}" != "json" ]; then
		: >"${report_raw}" >"${report_srt}" >"${report_txt}" >"${report_jsn}"
		[ "${adb_represolve}" = "1" ] && resolve=""
		for file in "${adb_reportdir}/adb_report.pcap"*; do
			(
				if [ "${adb_repiface}" = "any" ]; then
					"${adb_dumpcmd}" "${resolve}" --immediate-mode -T domain -tttt -r "${file}" 2>/dev/null |
						"${adb_awkcmd}" -v cnt="${cnt}" '!/\.lan\. |PTR\? | SOA\? | Flags /&&/ A[A]*\? |NXDomain|0\.0\.0\.0|[0-9]\/[0-9]\/[0-9]/{sub(/\.[0-9]+$/,"",$6);
						type=substr($(NF-1),length($(NF-1)));
						if(type=="."&&$(NF-2)!="CNAME")
							{domain=substr($(NF-1),1,length($(NF-1))-1);type="RQ"}
						else
							{if($(NF-2)~/NXDomain/||$(NF-1)=="0.0.0.0"){type="NX"}else{type="OK"};domain=""};
							if(int($9)>0)
								printf "%08d\t%s\t%s\t%s\t%-25s\t%s\n",$9,type,$1,substr($2,1,8),$6,domain}' >>"${report_raw}"
				else
					"${adb_dumpcmd}" "${resolve}" --immediate-mode -T domain -tttt -r "${file}" 2>/dev/null |
						"${adb_awkcmd}" -v cnt="${cnt}" '!/\.lan\. |PTR\? | SOA\? | Flags /&&/ A[A]*\? |NXDomain|0\.0\.0\.0|[0-9]\/[0-9]\/[0-9]/{sub(/\.[0-9]+$/,"",$4);
						type=substr($(NF-1),length($(NF-1)));
						if(type=="."&&$(NF-2)!="CNAME")
							{domain=substr($(NF-1),1,length($(NF-1))-1);type="RQ"}
						else
							{if($(NF-2)~/NXDomain/||$(NF-1)=="0.0.0.0"){type="NX"}else{type="OK"};domain=""};
							if(int($7)>0)
								printf "%08d\t%s\t%s\t%s\t%-25s\t%s\n",$7,type,$1,substr($2,1,8),$4,domain}' >>"${report_raw}"
				fi
			) &
			[ "${cnt}" -gt "${adb_cores}" ] && wait -n
			cnt="$((cnt + 1))"
		done
		wait
		if [ -s "${report_raw}" ]; then
			"${adb_sortcmd}" ${adb_srtopts} -k3,3 -k4,4 -k1,1 -k2,2 -u -r "${report_raw}" |
				"${adb_awkcmd}" '{currA=($1+0);currB=$1;currC=$2;if(reqA==currB){reqA=0;printf "%-90s\t%s\n",d,$2}else if(currC=="RQ"){reqA=currA;d=$3"\t"$4"\t"$5"\t"$6}}' |
				"${adb_grepcmd}" -v "RQ" | "${adb_sortcmd}" ${adb_srtopts} -u -r >"${report_srt}"
			: >"${report_raw}"
		fi

		if [ -s "${report_srt}" ]; then
			start="$("${adb_awkcmd}" 'END{printf "%s_%s",$1,$2}' "${report_srt}")"
			end="$("${adb_awkcmd}" 'NR==1{printf "%s_%s",$1,$2}' "${report_srt}")"
			total="$(f_count tld "${report_srt}" "var")"
			blocked="$("${adb_awkcmd}" '{if($5=="NX")cnt++}END{printf "%s",cnt}' "${report_srt}")"
			percent="$("${adb_awkcmd}" -v t="${total}" -v b="${blocked}" 'BEGIN{printf "%.2f%s",b/t*100,"%"}')"
			: >"${report_jsn}"
			{
				printf "%s\n" "{ "
				printf "\t%s\n" "\"start_date\": \"${start%_*}\", "
				printf "\t%s\n" "\"start_time\": \"${start#*_}\", "
				printf "\t%s\n" "\"end_date\": \"${end%_*}\", "
				printf "\t%s\n" "\"end_time\": \"${end#*_}\", "
				printf "\t%s\n" "\"total\": \"${total}\", "
				printf "\t%s\n" "\"blocked\": \"${blocked}\", "
				printf "\t%s\n" "\"percent\": \"${percent}\", "
			} >>"${report_jsn}"
			top_list="top_clients top_domains top_blocked"
			for top in ${top_list}; do
				printf "\t%s" "\"${top}\": [ " >>"${report_jsn}"
				case "${top}" in
					"top_clients")
						"${adb_awkcmd}" '{print $3}' "${report_srt}" | "${adb_sortcmd}" ${adb_srtopts} | uniq -c |
							"${adb_sortcmd}" ${adb_srtopts} -nr |
							"${adb_awkcmd}" "{ORS=\" \";if(NR==1)printf \"\n\t\t{\n\t\t\t\\\"count\\\": \\\"%s\\\",\n\t\t\t\\\"address\\\": \\\"%s\\\"\n\t\t}\",\$1,\$2; else if(NR<=${top_count})printf \",\n\t\t{\n\t\t\t\\\"count\\\": \\\"%s\\\",\n\t\t\t\\\"address\\\": \\\"%s\\\"\n\t\t}\",\$1,\$2}" >>"${report_jsn}"
						;;
					"top_domains")
						"${adb_awkcmd}" '{if($5!="NX")print $4}' "${report_srt}" | "${adb_sortcmd}" ${adb_srtopts} | uniq -c |
							"${adb_sortcmd}" ${adb_srtopts} -nr |
							"${adb_awkcmd}" "{ORS=\" \";if(NR==1)printf \"\n\t\t{\n\t\t\t\\\"count\\\": \\\"%s\\\",\n\t\t\t\\\"address\\\": \\\"%s\\\"\n\t\t}\",\$1,\$2; else if(NR<=${top_count})printf \",\n\t\t{\n\t\t\t\\\"count\\\": \\\"%s\\\",\n\t\t\t\\\"address\\\": \\\"%s\\\"\n\t\t}\",\$1,\$2}" >>"${report_jsn}"
						;;
					"top_blocked")
						"${adb_awkcmd}" '{if($5=="NX")print $4}' "${report_srt}" |
							"${adb_sortcmd}" ${adb_srtopts} | uniq -c | "${adb_sortcmd}" ${adb_srtopts} -nr |
							"${adb_awkcmd}" "{ORS=\" \";if(NR==1)printf \"\n\t\t{\n\t\t\t\\\"count\\\": \\\"%s\\\",\n\t\t\t\\\"address\\\": \\\"%s\\\"\n\t\t}\",\$1,\$2; else if(NR<=${top_count})printf \",\n\t\t{\n\t\t\t\\\"count\\\": \\\"%s\\\",\n\t\t\t\\\"address\\\": \\\"%s\\\"\n\t\t}\",\$1,\$2}" >>"${report_jsn}"
						;;
				esac
				printf "\n\t%s\n" "]," >>"${report_jsn}"
			done
			search="${search//./\\.}"
			search="${search//[+*~%\$&\"\' ]/}"
			"${adb_awkcmd}" "BEGIN{i=0;printf \"\t\\\"requests\\\": [\n\"}/(${search})/{i++;if(i==1)printf \"\n\t\t{\n\t\t\t\\\"date\\\": \\\"%s\\\",\n\t\t\t\\\"time\\\": \\\"%s\\\",\n\t\t\t\\\"client\\\": \\\"%s\\\",\n\t\t\t\\\"domain\\\": \\\"%s\\\",\n\t\t\t\\\"rc\\\": \\\"%s\\\"\n\t\t}\",\$1,\$2,\$3,\$4,\$5;else if(i<=${res_count})printf \",\n\t\t{\n\t\t\t\\\"date\\\": \\\"%s\\\",\n\t\t\t\\\"time\\\": \\\"%s\\\",\n\t\t\t\\\"client\\\": \\\"%s\\\",\n\t\t\t\\\"domain\\\": \\\"%s\\\",\n\t\t\t\\\"rc\\\": \\\"%s\\\"\n\t\t}\",\$1,\$2,\$3,\$4,\$5}END{printf \"\n\t]\n}\n\"}" "${adb_reportdir}/adb_report.srt" >>"${report_jsn}"
			: >"${report_srt}"
		fi

		# retrieve/prepare map data
		#
		if [ "${adb_map}" = "1" ] && [ -s "${report_jsn}" ]; then
			cnt="1"
			network_find_wan iface_v4
			network_get_ipaddr ip_v4 "${iface_v4}"
			network_find_wan6 iface_v6
			network_get_ipaddr6 ip_v6 "${iface_v6}"
			printf "%s" ",[{}" >"${map_jsn}"
			f_fetch
			for ip in ${ip_v4} ${ip_v6}; do
				"${adb_fetchcmd}" ${adb_geoparm} "${adb_geourl}/${ip}" 2>/dev/null |
					"${adb_awkcmd}" -v feed="homeIP" '{printf ",{\"%s\": %s}\n",feed,$0}' >>"${map_jsn}"
				cnt="$((cnt + 1))"
			done
			if [ -s "${map_jsn}" ] && [ "${cnt}" -lt "45" ] && [ "$("${adb_catcmd}" "${map_jsn}")" != ",[{}" ]; then
				json_init
				if json_load_file "${report_jsn}" >/dev/null 2>&1; then
					json_select "requests" >/dev/null 2>&1
					json_get_keys requests >/dev/null 2>&1
					for request in ${requests}; do
						json_select "${request}" >/dev/null 2>&1
						json_get_keys details >/dev/null 2>&1
						json_get_var rc "rc" >/dev/null 2>&1
						json_get_var domain "domain" >/dev/null 2>&1
						if [ "${rc}" = "NX" ] && ! "${adb_catcmd}" "${map_jsn}" 2>/dev/null | "${adb_grepcmd}" -q "${domain}"; then
							(
								"${adb_fetchcmd}" ${adb_geoparm} "${adb_geourl}/${domain}" 2>/dev/null |
									"${adb_awkcmd}" -v feed="${domain}" '{printf ",{\"%s\": %s}\n",feed,$0}' >>"${map_jsn}"
							) &
							[ "${cnt}" -gt "${adb_cores}" ] && wait -n
							cnt="$((cnt + 1))"
							[ "${cnt}" -ge "45" ] && break
						fi
						json_select ".."
					done
					wait
				fi
			fi
		fi
	fi

	# output preparation
	#
	if [ -s "${report_jsn}" ] && { [ "${action}" = "cli" ] || [ "${action}" = "mail" ]; }; then
		printf "%s\n%s\n%s\n" ":::" "::: Adblock DNS-Query Report" ":::" >>"${report_txt}"
		json_init
		json_load_file "${report_jsn}"
		json_get_keys key_list
		for key in ${key_list}; do
			json_get_var value "${key}"
			eval "${key}=\"${value}\""
		done
		printf "  + %s\n  + %s\n" "Start    ::: ${start_date}, ${start_time}" "End      ::: ${end_date}, ${end_time}" >>"${report_txt}"
		printf "  + %s\n  + %s %s\n" "Total    ::: ${total}" "Blocked  ::: ${blocked}" "(${percent})" >>"${report_txt}"
		top_list="top_clients top_domains top_blocked requests"
		for top in ${top_list}; do
			case "${top}" in
				"top_clients")
					item="::: Top Clients"
					;;
				"top_domains")
					item="::: Top Domains"
					;;
				"top_blocked")
					item="::: Top Blocked Domains"
					;;
			esac
			if json_get_type status "${top}" && [ "${top}" != "requests" ] && [ "${status}" = "array" ]; then
				printf "%s\n%s\n%s\n" ":::" "${item}" ":::" >>"${report_txt}"
				json_select "${top}"
				index="1"
				item=""
				while json_get_type status "${index}" && [ "${status}" = "object" ]; do
					json_get_values item "${index}"
					printf "  + %-9s::: %s\n" ${item} >>"${report_txt}"
					index="$((index + 1))"
				done
			elif json_get_type status "${top}" && [ "${top}" = "requests" ] && [ "${status}" = "array" ]; then
				printf "%s\n%s\n%s\n" ":::" "::: Latest DNS Queries" ":::" >>"${report_txt}"
				printf "%-15s%-15s%-45s%-80s%s\n" "Date" "Time" "Client" "Domain" "Answer" >>"${report_txt}"
				json_select "${top}"
				index="1"
				while json_get_type status "${index}" && [ "${status}" = "object" ]; do
					json_get_values item "${index}"
					printf "%-15s%-15s%-45s%-80s%s\n" ${item} >>"${report_txt}"
					index="$((index + 1))"
				done
			fi
			json_select ".."
		done
		content="$("${adb_catcmd}" "${report_txt}" 2>/dev/null)"
		: >"${report_txt}"
	fi

	# report output
	#
	case "${action}" in
		"cli")
			printf "%s\n" "${content}"
			;;
		"json")
			if [ "${adb_map}" = "1" ]; then
				jsn="$("${adb_catcmd}" ${report_jsn} ${map_jsn} 2>/dev/null)"
				[ -n "${jsn}" ] && printf "[%s]]\n" "${jsn}"
			else
				jsn="$("${adb_catcmd}" ${report_jsn} 2>/dev/null)"
				[ -n "${jsn}" ] && printf "[%s]\n" "${jsn}"
			fi
			;;
		"mail")
			[ "${adb_mail}" = "1" ] && [ -x "${adb_mailservice}" ] && "${adb_mailservice}" "${content}" >/dev/null 2>&1
			: >"${report_txt}"
			;;
	esac
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
adb_wccmd="$(f_cmd wc)"
adb_catcmd="$(f_cmd cat)"
adb_zcatcmd="$(f_cmd zcat)"
adb_awkcmd="$(f_cmd gawk awk)"
adb_sortcmd="$(f_cmd sort)"
adb_grepcmd="$(f_cmd grep)"
adb_gzipcmd="$(f_cmd gzip)"
adb_pgrepcmd="$(f_cmd pgrep)"
adb_sedcmd="$(f_cmd sed)"
adb_findcmd="$(f_cmd find)"
adb_jsoncmd="$(f_cmd jsonfilter)"
adb_ubuscmd="$(f_cmd ubus)"
adb_loggercmd="$(f_cmd logger)"
adb_lookupcmd="$(f_cmd nslookup)"
adb_dumpcmd="$(f_cmd tcpdump optional)"
adb_mailcmd="$(f_cmd msmtp optional)"
adb_logreadcmd="$(f_cmd logread optional)"

# handle different adblock actions
#
f_load
case "${adb_action}" in
	"stop")
		f_jsnup "stopped"
		f_rmdns
		;;
	"suspend")
		[ "${adb_dns}" != "raw" ] && f_switch suspend
		;;
	"resume")
		[ "${adb_dns}" != "raw" ] && f_switch resume
		;;
	"report")
		f_report "${2}" "${3}" "${4}" "${5}"
		;;
	"query")
		f_query "${2}"
		;;
	"boot" | "start" | "reload")
		f_env
		f_main
		;;
	"restart")
		f_jsnup "running"
		f_rmdns
		f_env
		f_main
		;;
esac
