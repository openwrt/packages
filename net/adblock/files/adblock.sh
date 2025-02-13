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
adb_forcedns="0"
adb_dnsflush="0"
adb_dnstimeout="20"
adb_safesearch="0"
adb_safesearchmod="0"
adb_report="0"
adb_trigger=""
adb_triggerdelay="5"
adb_backup="1"
adb_mail="0"
adb_mailcnt="0"
adb_jail="0"
adb_tld="1"
adb_dns=""
adb_dnsprefix="adb_list"
adb_locallist="blacklist whitelist iplist"
adb_tmpbase="/tmp"
adb_backupdir="${adb_tmpbase}/adblock-Backup"
adb_reportdir="${adb_tmpbase}/adblock-Report"
adb_jaildir="/tmp"
adb_pidfile="/var/run/adblock.pid"
adb_blacklist="/etc/adblock/adblock.blacklist"
adb_whitelist="/etc/adblock/adblock.whitelist"
adb_mailservice="/etc/adblock/adblock.mail"
adb_dnsfile="${adb_dnsprefix}.overall"
adb_dnsjail="${adb_dnsprefix}.jail"
adb_srcarc="/etc/adblock/adblock.sources.gz"
adb_srcfile="${adb_tmpbase}/adb_sources.json"
adb_rtfile="${adb_tmpbase}/adb_runtime.json"
adb_fetchutil=""
adb_fetchinsecure=""
adb_repiface=""
adb_replisten="53"
adb_repchunkcnt="5"
adb_repchunksize="1"
adb_represolve="0"
adb_lookupdomain="example.com"
adb_action="${1:-"start"}"
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
	adb_sysver="$("${adb_ubuscmd}" -S call system board 2>/dev/null | "${adb_jsoncmd}" -ql1  -e '@.model' -e '@.release.target' -e '@.release.distribution' -e '@.release.version' -e '@.release.revision' |
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
		if [ "${adb_report}" = "0" ] || { [ -n "${bg_pid}" ] && { [ "${adb_action}" = "stop" ] || [ "${adb_action}" = "restart" ]; }; }; then
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
				[ -n "${iface}" ] && adb_repiface="${iface}"
				[ -n "${adb_repiface}" ] && { uci_set adblock global adb_repiface "${adb_repiface}"; f_uci "adblock"; }
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
	local mem_free

	adb_starttime="$(date "+%s")"
	mem_free="$("${adb_awkcmd}" '/^MemAvailable/{printf "%s",int($2/1000)}' "/proc/meminfo" 2>/dev/null)"

	f_log "info" "adblock instance started ::: action: ${adb_action}, priority: ${adb_nice:-"0"}, pid: ${$}"
	f_jsnup "running"
	f_extconf
	f_temp

	if [ "${adb_dnsflush}" = "1" ] || [ "${mem_free}" -lt "64" ]; then
		printf "%b" "${adb_dnsheader}" >"${adb_dnsdir}/${adb_dnsfile}"
		f_dnsup
	fi

	if [ ! -r "${adb_srcfile}" ]; then
		if [ -r "${adb_srcarc}" ]; then
			"${adb_zcatcmd}" "${adb_srcarc}" >"${adb_srcfile}"
		else
			f_log "err" "adblock source archive not found"
		fi
	fi
	if [ -r "${adb_srcfile}" ] && [ "${adb_action}" != "report" ]; then
		json_init
		json_load_file "${adb_srcfile}"
	else
		f_log "err" "adblock source file not found"
	fi
}

# load adblock config
#
f_conf() {
	unset adb_sources adb_hag_sources adb_hst_sources adb_stb_sources adb_utc_sources adb_denyip adb_allowip adb_safesearchlist adb_zonelist adb_portlist

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
				"adb_sources")
					eval "${option}=\"$(printf "%s" "${adb_sources}") ${value}\""
					;;
				"adb_hag_sources")
					eval "${option}=\"$(printf "%s" "${adb_hag_sources}") ${value}\""
					;;
				"adb_hst_sources")
					eval "${option}=\"$(printf "%s" "${adb_hst_sources}") ${value}\""
					;;
				"adb_stb_sources")
					eval "${option}=\"$(printf "%s" "${adb_stb_sources}") ${value}\""
					;;
				"adb_utc_sources")
					eval "${option}=\"$(printf "%s" "${adb_utc_sources}") ${value}\""
					;;
				"adb_denyip")
					eval "${option}=\"$(printf "%s" "${adb_denyip}") ${value}\""
					;;
				"adb_allowip")
					eval "${option}=\"$(printf "%s" "${adb_allowip}") ${value}\""
					;;
				"adb_safesearchlist")
					eval "${option}=\"$(printf "%s" "${adb_safesearchlist}") ${value}\""
					;;
				"adb_zonelist")
					eval "${option}=\"$(printf "%s" "${adb_zonelist}") ${value}\""
					;;
				"adb_portlist")
					eval "${option}=\"$(printf "%s" "${adb_portlist}") ${value}\""
					;;
			esac
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
	local util utils

	if [ "${adb_action}" = "start" ] && [ -z "${adb_trigger}" ]; then
		sleep ${adb_triggerdelay}
	fi

	if [ -z "${adb_dns}" ]; then
		utils="knot-resolver bind-server unbound-daemon smartdns dnsmasq-full dnsmasq-dhcpv6 dnsmasq"
		for util in ${utils}; do
			if printf "%s" "${adb_packages}" | "${adb_jsoncmd}" -ql1 -e "@.packages[\"${util}\"]" >/dev/null 2>&1; then
				case "${util}" in
					"knot-resolver")
						util="kresd"
						;;
					"bind-server")
						util="named"
						;;
					"unbound-daemon")
						util="unbound"
						;;
					"dnsmasq-full" | "dnsmasq-dhcpv6")
						util="dnsmasq"
						;;
				esac

				if [ -x "$(command -v "${util}")" ]; then
					adb_dns="${util}"
					uci_set adblock global adb_dns "${util}"
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
			adb_dnsdir="${adb_dnsdir:-"/tmp/dnsmasq.d"}"
			adb_dnsheader="${adb_dnsheader:-""}"
			adb_dnsdeny="${adb_dnsdeny:-"${adb_awkcmd} '{print \"local=/\"\$0\"/\"}'"}"
			adb_dnsallow="${adb_dnsallow:-"${adb_awkcmd} '{print \"local=/\"\$0\"/#\"}'"}"
			adb_dnssafesearch="${adb_dnssafesearch:-"${adb_awkcmd} -v item=\"\$item\" '{print \"address=/\"\$0\"/\"item\"\";print \"local=/\"\$0\"/\"}'"}"
			adb_dnsstop="${adb_dnsstop:-"address=/#/\nlocal=/#/"}"
			;;
		"unbound")
			adb_dnscachecmd="$(command -v unbound-control || printf "%s" "-")"
			adb_dnsinstance="${adb_dnsinstance:-"0"}"
			adb_dnsuser="${adb_dnsuser:-"unbound"}"
			adb_dnsdir="${adb_dnsdir:-"/var/lib/unbound"}"
			adb_dnsheader="${adb_dnsheader:-""}"
			adb_dnsdeny="${adb_dnsdeny:-"${adb_awkcmd} '{print \"local-zone: \\042\"\$0\"\\042 always_nxdomain\"}'"}"
			adb_dnsallow="${adb_dnsallow:-"${adb_awkcmd} '{print \"local-zone: \\042\"\$0\"\\042 always_transparent\"}'"}"
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
			adb_dnsdir="${adb_dnsdir:-"/etc/kresd"}"
			adb_dnsheader="${adb_dnsheader:-"\$TTL 2h\n@ IN SOA localhost. root.localhost. (1 6h 1h 1w 2h)\n"}"
			adb_dnsdeny="${adb_dnsdeny:-"${adb_awkcmd} '{print \"\"\$0\" CNAME .\\n*.\"\$0\" CNAME .\"}'"}"
			adb_dnsallow="${adb_dnsallow:-"${adb_awkcmd} '{print \"\"\$0\" CNAME rpz-passthru.\\n*.\"\$0\" CNAME rpz-passthru.\"}'"}"
			adb_dnssafesearch="${adb_dnssafesearch:-"${adb_awkcmd} -v item=\"\$item\" '{type=\"AAAA\";if(match(item,/^([0-9]{1,3}\.){3}[0-9]{1,3}$/)){type=\"A\"}}{print \"\"\$0\" \"type\" \"item\"\"}'"}"
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
			adb_dnssafesearch="${adb_dnssafesearch:-"${adb_awkcmd} -v item=\"\$item\" '{print \"cname /\"\$0\"/\"item\"\"}'"}"
			adb_dnsstop="${adb_dnsstop:-"0"}"
			;;
		"raw")
			adb_dnscachecmd="-"
			adb_dnsinstance="${adb_dnsinstance:-"0"}"
			adb_dnsuser="${adb_dnsuser:-"root"}"
			adb_dnsdir="${adb_dnsdir:-"/tmp"}"
			adb_dnsheader="${adb_dnsheader:-""}"
			adb_dnsdeny="${adb_dnsdeny:-"0"}"
			adb_dnsallow="${adb_dnsallow:-"1"}"
			adb_dnssafesearch="${adb_dnssafesearch:-"0"}"
			adb_dnsstop="${adb_dnsstop:-"0"}"
			;;
	esac

	if [ "${adb_action}" != "stop" ]; then
		[ ! -d "${adb_dnsdir}" ] && mkdir -p "${adb_dnsdir}"
		[ "${adb_jail}" = "1" ] && [ ! -d "${adb_jaildir}" ] && mkdir -p "${adb_jaildir}"
		[ "${adb_backup}" = "1" ] && [ ! -d "${adb_backupdir}" ] && mkdir -p "${adb_backupdir}"
		[ ! -f "${adb_dnsdir}/${adb_dnsfile}" ] && printf "%b" "${adb_dnsheader}" >"${adb_dnsdir}/${adb_dnsfile}"
	fi

	f_log "debug" "f_dns    ::: dns: ${adb_dns}, dns_dir: ${adb_dnsdir}, dns_file: ${adb_dnsfile}, dns_user: ${adb_dnsuser}, dns_instance: ${adb_dnsinstance}, backup_dir: ${adb_backupdir}, jail_dir: ${adb_jaildir}"
}

# load fetch utility
#
f_fetch() {
	local util utils insecure

	adb_fetchutil="$(command -v "${adb_fetchutil}")"
	if [ ! -x "${adb_fetchutil}" ]; then
		utils="aria2 curl wget-ssl libustream-openssl libustream-wolfssl libustream-mbedtls"
		for util in ${utils}; do
			if printf "%s" "${adb_packages}" | "${adb_jsoncmd}" -ql1 -e "@.packages[\"${util}\"]" >/dev/null 2>&1; then
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
					adb_fetchutil="$(command -v "${util}")"
					uci_set adblock global adb_fetchutil "${util}"
					f_uci "adblock"
					break
				fi
			fi
		done
	fi

	[ ! -x "${adb_fetchutil}" ] && f_log "err" "download utility with SSL support not found, please set 'adb_fetchutil' manually"

	case "${adb_fetchutil##*/}" in
		"aria2c")
			[ "${adb_fetchinsecure}" = "1" ] && insecure="--check-certificate=false"
			adb_fetchparm="${adb_fetchparm:-"${insecure} --timeout=20 --allow-overwrite=true --auto-file-renaming=false --log-level=warn --dir=/ -o"}"
			;;
		"curl")
			[ "${adb_fetchinsecure}" = "1" ] && insecure="--insecure"
			adb_fetchparm="${adb_fetchparm:-"${insecure} --connect-timeout 20 --fail --silent --show-error --location -o"}"
			;;
		"uclient-fetch")
			[ "${adb_fetchinsecure}" = "1" ] && insecure="--no-check-certificate"
			adb_fetchparm="${adb_fetchparm:-"${insecure} --timeout=20 -O"}"
			;;
		"wget")
			[ "${adb_fetchinsecure}" = "1" ] && insecure="--no-check-certificate"
			adb_fetchparm="${adb_fetchparm:-"${insecure} --no-cache --no-cookies --max-redirect=0 --timeout=20 -O"}"
			;;
	esac

	f_log "debug" "f_fetch  ::: fetch_util: ${adb_fetchutil:-"-"}, fetch_parm: ${adb_fetchparm:-"-"}"
}

# create temporary files, directories and set dependent options
#
f_temp() {
	if [ -d "${adb_tmpbase}" ]; then
		adb_tmpdir="$(mktemp -p "${adb_tmpbase}" -d)"
		adb_tmpload="$(mktemp -p "${adb_tmpdir}" -tu)"
		adb_tmpfile="$(mktemp -p "${adb_tmpdir}" -tu)"
		adb_srtopts="--temporary-directory=${adb_tmpdir} --compress-program=gzip --parallel=${adb_cores}"
	else
		f_log "err" "the temp base directory '${adb_tmpbase}' does not exist/is not mounted yet, please create the directory or raise the 'adb_triggerdelay' to defer the adblock start"
	fi
	[ ! -s "${adb_pidfile}" ] && printf "%s" "${$}" >"${adb_pidfile}"
}

# remove temporary files and directories
#
f_rmtemp() {
	rm -rf "${adb_tmpdir}" "${adb_srcfile}"
	: >"${adb_pidfile}"
}

# remove dns related files
#
f_rmdns() {
	if "${adb_ubuscmd}" -S call service list '{"name":"adblock"}' | "${adb_jsoncmd}" -ql1 -e '@["adblock"].instances.*.running' >/dev/null; then
		: >"${adb_rtfile}"
		if [ "${adb_backup}" = "0" ] || [ "${adb_action}" = "stop" ]; then
			rm -f "${adb_backupdir}/${adb_dnsprefix}".*.gz
		fi
		printf "%b" "${adb_dnsheader}" >"${adb_dnsdir}/${adb_dnsfile}"
		f_dnsup 4
	fi
	f_rmtemp
}

# commit uci changes
#
f_uci() {
	local change config="${1}"

	if [ -n "${config}" ]; then
		change="$(uci -q changes "${config}" | "${adb_awkcmd}" '{ORS=" "; print $0}')"
		if [ -n "${change}" ]; then
			uci_commit "${config}"
			case "${config}" in
				"firewall")
					"/etc/init.d/firewall" reload >/dev/null 2>&1
					;;
				"resolver")
					printf "%b" "${adb_dnsheader}" >"${adb_dnsdir}/${adb_dnsfile}"
					f_count
					f_jsnup "running"
					"/etc/init.d/${adb_dns}" reload >/dev/null 2>&1
					;;
			esac
		fi
		f_log "debug" "f_uci    ::: config: ${config}, change: ${change}"
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
				if [ -s "${adb_tmpdir}/tmp.add.whitelist" ]; then
					adb_cnt="$((adb_cnt - $("${adb_wccmd}" -l 2>/dev/null <"${adb_tmpdir}/tmp.add.whitelist")))"
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
	local config config_option section zone port fwcfg

	case "${adb_dns}" in
		"dnsmasq")
			config="dhcp"
			config_option="$(uci_get ${config} "@dnsmasq[${adb_dnsinstance}]" confdir | "${adb_grepcmd}" -Fo "${adb_dnsdir}")"
			if [ "${adb_enabled}" = "1" ] && [ -z "${config_option}" ]; then
				uci_set dhcp "@dnsmasq[${adb_dnsinstance}]" confdir "${adb_dnsdir}" 2>/dev/null
			fi
			;;
		"kresd")
			config="resolver"
			config_option="$(uci_get ${config} kresd rpz_file | "${adb_grepcmd}" -Fo "${adb_dnsdir}/${adb_dnsfile}")"
			if [ "${adb_enabled}" = "1" ] && [ -z "${config_option}" ]; then
				uci -q add_list resolver.kresd.rpz_file="${adb_dnsdir}/${adb_dnsfile}"
			elif [ "${adb_enabled}" = "0" ] && [ -n "${config_option}" ]; then
				uci -q del_list resolver.kresd.rpz_file="${adb_dnsdir}/${adb_dnsfile}"
			fi
			;;
		"smartdns")
			config="smartdns"
			config_option="$(uci_get ${config} smartdns conf_files | "${adb_grepcmd}" -Fo "${adb_dnsdir}/${adb_dnsfile}")"
			if [ "${adb_enabled}" = "1" ] && [ -z "${config_option}" ]; then
				uci -q add_list smartdns.@smartdns[${adb_dnsinstance}].conf_files="${adb_dnsdir}/${adb_dnsfile}"
			elif [ "${adb_enabled}" = "0" ] && [ -n "${config_option}" ]; then
				uci -q del_list smartdns.@smartdns[${adb_dnsinstance}].conf_files="${adb_dnsdir}/${adb_dnsfile}"
			fi
			;;
	esac
	f_uci "${config}"

	config="firewall"
	fwcfg="$(uci -qNX show "${config}" | "${adb_awkcmd}" 'BEGIN{FS="[.=]"};/adblock_/{if(zone==$2){next}else{ORS=" ";zone=$2;print zone}}')"
	if [ "${adb_enabled}" = "1" ] && [ "${adb_forcedns}" = "1" ] &&
		/etc/init.d/firewall enabled; then
		for zone in ${adb_zonelist}; do
			for port in ${adb_portlist}; do
				if ! printf "%s" "${fwcfg}" | "${adb_grepcmd}" -q "adblock_${zone}${port}[ |\$]"; then
					uci -q batch <<-EOC
						set firewall."adblock_${zone}${port}"="redirect"
						set firewall."adblock_${zone}${port}".name="Adblock DNS (${zone}, ${port})"
						set firewall."adblock_${zone}${port}".src="${zone}"
						set firewall."adblock_${zone}${port}".proto="tcp udp"
						set firewall."adblock_${zone}${port}".src_dport="${port}"
						set firewall."adblock_${zone}${port}".dest_port="${port}"
						set firewall."adblock_${zone}${port}".target="DNAT"
						set firewall."adblock_${zone}${port}".family="any"
					EOC
				fi
				fwcfg="${fwcfg/adblock_${zone}${port}[ |\$]/}"
			done
		done
		fwcfg="${fwcfg#"${fwcfg%%[![:space:]]*}"}"
		fwcfg="${fwcfg%"${fwcfg##*[![:space:]]}"}"
	fi
	if [ "${adb_enabled}" = "0" ] || [ "${adb_forcedns}" = "0" ] || [ -n "${fwcfg}" ]; then
		for section in ${fwcfg}; do
			uci_remove firewall "${section}"
		done
	fi
	f_uci "${config}"
}

# restart dns backend
#
f_dnsup() {
	local rset dns_service dns_up dns_pid restart_rc cnt="0" out_rc="4" in_rc="${1:-0}"

	if [ "${adb_dns}" = "raw" ] || [ -z "${adb_dns}" ]; then
		out_rc="0"
	else
		if [ "${in_rc}" = "0" ] && [ "${adb_dnsflush}" = "0" ]; then
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
		rset="/^(([[:alnum:]_-]{1,63}\\.)+[[:alnum:]-]+|[[:alnum:]-]+)([[:space:]]|$)/{print tolower(\$1)}"
		while [ "${cnt}" -le "${adb_dnstimeout}" ]; do
			dns_service="$("${adb_ubuscmd}" -S call service list "{\"name\":\"${adb_dns}\"}")"
			dns_up="$(printf "%s" "${dns_service}" | "${adb_jsoncmd}" -l1 -e "@[\"${adb_dns}\"].instances.*.running")"
			dns_pid="$(printf "%s" "${dns_service}" | "${adb_jsoncmd}" -l1 -e "@[\"${adb_dns}\"].instances.*.pid")"
			if [ "${dns_up}" = "true" ] && [ -n "${dns_pid}" ] && ! ls "/proc/${dns_pid}/fd/${adb_dnsdir}/${adb_dnsfile}" >/dev/null 2>&1; then
				if [ -x "${adb_lookupcmd}" ] && [ "${adb_lookupdomain}" != "false" ] && [ -n "$(printf "%s" "${adb_lookupdomain}" | "${adb_awkcmd}" "${rset}")" ]; then
					if "${adb_lookupcmd}" "${adb_lookupdomain}" >/dev/null 2>&1; then
						out_rc="0"
						break
					fi
				else
					sleep ${adb_dnstimeout}
					cnt=${adb_dnstimeout}
					out_rc="0"
					break
				fi
			fi
			cnt="$((cnt + 1))"
			sleep 1
		done
		if [ "${out_rc}" = "0" ] && [ "${adb_dns}" = "unbound" ]; then
			if [ -x "${adb_dnscachecmd}" ] && [ -d "${adb_tmpdir}" ] && [ -s "${adb_tmpdir}/adb_cache.dump" ]; then
				"${adb_dnscachecmd}" -c "${adb_dnsdir}/unbound.conf" load_cache <"${adb_tmpdir}/adb_cache.dump" >/dev/null 2>&1
				restart_rc="${?}"
			fi
		fi
	fi

	f_log "debug" "f_dnsup  ::: dns: ${adb_dns}, cache_cmd: ${adb_dnscachecmd:-"-"}, lookup_cmd: ${adb_lookupcmd:-"-"}, lookup_domain: ${adb_lookupdomain:-"-"}, restart_rc: ${restart_rc:-"-"}, dns_flush: ${adb_dnsflush}, dns_timeout: ${adb_dnstimeout}, dns_cnt: ${cnt}, in_rc: ${in_rc}, out_rc: ${out_rc}"
	return "${out_rc}"
}

# backup/restore/remove blocklists
#
f_list() {
	local hold file rset item array safe_url safe_ips safe_cname safe_domains ip out_rc file_name cnt mode="${1}" src_name="${2:-"${src_name}"}" in_rc="${src_rc:-0}" use_cname="0" ffiles="-maxdepth 1 -name ${adb_dnsprefix}.*.gz"

	case "${mode}" in
		"iplist")
			src_name="${mode}"
			file_name="${adb_tmpdir}/tmp.add.${src_name}"
			if [ "${adb_dns}" = "named" ]; then
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
		"blacklist" | "whitelist")
			src_name="${mode}"
			if [ "${src_name}" = "blacklist" ] && [ -f "${adb_blacklist}" ]; then
				file_name="${adb_tmpfile}.${src_name}"
				rset="/^(([[:alnum:]_-]{1,63}\\.)+[[:alnum:]-]+|[[:alnum:]-]+)([[:space:]]|$)/{print tolower(\$1)}"
				"${adb_awkcmd}" "${rset}" "${adb_blacklist}" >"${adb_tmpdir}/tmp.raw.${src_name}"
				if [ -s "${adb_whitelist}" ]; then
					"${adb_awkcmd}" 'NR==FNR{member[$1];next}!($1 in member)' "${adb_whitelist}" "${adb_tmpdir}/tmp.raw.${src_name}" >"${adb_tmpdir}/tmp.deduplicate.${src_name}"
				else
					"${adb_catcmd}" "${adb_tmpdir}/tmp.raw.${src_name}" >"${adb_tmpdir}/tmp.deduplicate.${src_name}"
				fi
				"${adb_awkcmd}" 'BEGIN{FS="."}{for(f=NF;f>1;f--)printf "%s.",$f;print $1}' "${adb_tmpdir}/tmp.deduplicate.${src_name}" >"${adb_tmpdir}/tmp.raw.${src_name}"
				"${adb_sortcmd}" ${adb_srtopts} -u "${adb_tmpdir}/tmp.raw.${src_name}" 2>/dev/null >"${file_name}"
				out_rc="${?}"
			elif [ "${src_name}" = "whitelist" ] && [ -f "${adb_whitelist}" ]; then
				file_name="${adb_tmpdir}/tmp.raw.${src_name}"
				[ "${adb_lookupdomain}" != "false" ] && printf "%s\n" "${adb_lookupdomain}" | "${adb_awkcmd}" "${rset}" >"${file_name}"
				rset="/^(([[:alnum:]_-]{1,63}\\.)+[[:alnum:]-]+|[[:alnum:]-]+)([[:space:]]|$)/{print tolower(\$1)}"
				"${adb_awkcmd}" "${rset}" "${adb_whitelist}" >>"${file_name}"
				out_rc="${?}"
				if [ "${out_rc}" = "0" ]; then
					"${adb_awkcmd}" "${rset}" "${adb_tmpdir}/tmp.raw.${src_name}" >"${adb_tmpdir}/tmp.rem.${src_name}"
					out_rc="${?}"
					if [ "${out_rc}" = "0" ] && [ "${adb_dnsallow}" != "1" ]; then
						eval "${adb_dnsallow}" "${adb_tmpdir}/tmp.raw.${src_name}" >"${adb_tmpdir}/tmp.add.${src_name}"
						out_rc="${?}"
						if [ "${out_rc}" = "0" ] && [ "${adb_jail}" = "1" ] && [ "${adb_dnsstop}" != "0" ]; then
							rm -f "${adb_jaildir}/${adb_dnsjail}"
							[ -n "${adb_dnsheader}" ] && printf "%b" "${adb_dnsheader}" >>"${adb_jaildir}/${adb_dnsjail}"
							"${adb_catcmd}" "${adb_tmpdir}/tmp.add.${src_name}" >>"${adb_jaildir}/${adb_dnsjail}"
							printf "%b\n" "${adb_dnsstop}" >>"${adb_jaildir}/${adb_dnsjail}"
						fi
					fi
				fi
			fi
			;;
		"safesearch")
			file_name="${adb_tmpdir}/tmp.safesearch.${src_name}"
			if [ "${adb_dns}" = "named" ] || [ "${adb_dns}" = "smartdns" ]; then
				use_cname="1"
			fi
			case "${src_name}" in
				"google")
					rset="/^\\.([[:alnum:]_-]{1,63}\\.)+[[:alpha:]]+([[:space:]]|$)/{printf \"%s\n%s\n\",tolower(\"www\"\$1),tolower(substr(\$1,2,length(\$1)))}"
					safe_url="https://www.google.com/supported_domains"
					safe_cname="forcesafesearch.google.com"
					if [ "${adb_backup}" = "1" ] && [ -s "${adb_backupdir}/safesearch.${src_name}.gz" ]; then
						"${adb_zcatcmd}" "${adb_backupdir}/safesearch.${src_name}.gz" >"${adb_tmpdir}/tmp.load.safesearch.${src_name}"
					else
						"${adb_fetchutil}" ${adb_fetchparm} "${adb_tmpdir}/tmp.load.safesearch.${src_name}" "${safe_url}" 2>/dev/null
						if [ "${adb_backup}" = "1" ] && [ -s "${adb_tmpdir}/tmp.load.safesearch.${src_name}" ]; then
							"${adb_gzipcmd}" -cf "${adb_tmpdir}/tmp.load.safesearch.${src_name}" >"${adb_backupdir}/safesearch.${src_name}.gz"
						fi
					fi
					safe_domains="$("${adb_awkcmd}" "${rset}" "${adb_tmpdir}/tmp.load.safesearch.${src_name}")"
					;;
				"bing")
					safe_cname="strict.bing.com"
					safe_domains="www.bing.com"
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
					if [ "${adb_safesearchmod}" = "0" ]; then
						safe_cname="restrict.youtube.com"
					else
						safe_cname="restrictmoderate.youtube.com"
					fi
					safe_domains="www.youtube.com m.youtube.com youtubei.googleapis.com youtube.googleapis.com www.youtube-nocookie.com"
					;;
			esac
			if [ -n "${safe_domains}" ] && [ -n "${safe_cname}" ]; then
				if [ -x "${adb_lookupcmd}" ] && [ "${use_cname}" = "0" ]; then
					safe_ips="$("${adb_lookupcmd}" "${safe_cname}" 2>/dev/null | "${adb_awkcmd}" '/^Address[ 0-9]*: /{ORS=" ";print $NF}')"
				fi
				if [ -n "${safe_ips}" ] || [ "${use_cname}" = "1" ]; then
					printf "%s\n" ${safe_domains} >"${adb_tmpdir}/tmp.raw.safesearch.${src_name}"	
					[ "${use_cname}" = "1" ] &&	array="${safe_cname}" || array="${safe_ips}"
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
				out_rc="${?}"
				: >"${adb_tmpdir}/tmp.raw.safesearch.${src_name}"
			fi
			;;
		"download")
			file_name="${src_tmpfile}"
			;;
		"backup")
			file_name="${src_tmpfile}"
			"${adb_gzipcmd}" -cf "${src_tmpfile}" >"${adb_backupdir}/${adb_dnsprefix}.${src_name}.gz"
			out_rc="${?}"
			;;
		"restore")
			file_name="${src_tmpfile}"
			if [ -n "${src_name}" ] && [ -s "${adb_backupdir}/${adb_dnsprefix}.${src_name}.gz" ]; then
				"${adb_zcatcmd}" "${adb_backupdir}/${adb_dnsprefix}.${src_name}.gz" >"${src_tmpfile}"
				out_rc="${?}"
			elif [ -z "${src_name}" ]; then
				cnt="1"
				for file in "${adb_backupdir}/${adb_dnsprefix}".*.gz; do
					if [ -r "${file}" ]; then
						name="${file##*/}"
						name="${name%.*}"
						"${adb_zcatcmd}" "${file}" >"${adb_tmpfile}.${name}" &
						hold="$((cnt % adb_cores))"
						if [ "${hold}" = "0" ]; then
							wait
						fi
						cnt="$((cnt + 1))"
					fi
				done
				wait
				out_rc="${?}"
			else
				out_rc=4
			fi
			if [ "${adb_action}" != "start" ] && [ "${adb_action}" != "resume" ] && [ -n "${src_name}" ] && [ "${out_rc}" != "0" ]; then
				adb_sources="${adb_sources/${src_name}}"
			fi
			;;
		"remove")
			[ "${adb_backup}" = "1" ] && rm "${adb_backupdir}/${adb_dnsprefix}.${src_name}.gz" 2>/dev/null
			out_rc="${?}"
			adb_sources="${adb_sources/${src_name}}"
			;;
		"merge")
			src_name=""
			file_name="${adb_tmpdir}/${adb_dnsfile}"
			if [ "${adb_backup}" = "1" ]; then
				for file in ${adb_sources}; do
					ffiles="${ffiles} -a ! -name ${adb_dnsprefix}.${file}.gz"
				done
				if [ "${adb_safesearch}" = "1" ] && [ "${adb_dnssafesearch}" != "0" ]; then
					ffiles="${ffiles} -a ! -name safesearch.google.gz"
				fi
				find "${adb_backupdir}" ${ffiles} -print0 2>/dev/null | xargs -0 rm 2>/dev/null
			fi
			"${adb_sortcmd}" ${adb_srtopts} -mu "${adb_tmpfile}".* 2>/dev/null >"${file_name}"
			out_rc="${?}"
			rm -f "${adb_tmpfile}".*
			;;
		"final")
			src_name=""
			file_name="${adb_dnsdir}/${adb_dnsfile}"
			: >"${file_name}"
			[ -n "${adb_dnsheader}" ] && printf "%b" "${adb_dnsheader}" >>"${file_name}"
			[ -s "${adb_tmpdir}/tmp.add.iplist" ] && "${adb_catcmd}" "${adb_tmpdir}/tmp.add.iplist" >>"${file_name}"
			[ -s "${adb_tmpdir}/tmp.add.whitelist" ] && "${adb_catcmd}" "${adb_tmpdir}/tmp.add.whitelist" >>"${file_name}"
			"${adb_catcmd}" "${adb_tmpdir}/tmp.safesearch".* 2>/dev/null >>"${file_name}"
			if [ "${adb_dnsdeny}" != "0" ]; then
				eval "${adb_dnsdeny}" "${adb_tmpdir}/${adb_dnsfile}" >>"${file_name}"
			else
				"${adb_catcmd}" "${adb_tmpdir}/${adb_dnsfile}" >>"${file_name}"
			fi
			out_rc="${?}"
			;;
	esac
	[ "${adb_debug}" = "1" ] || [ "${mode}" = "final" ] && f_count "${mode}" "${file_name}"
	out_rc="${out_rc:-"${in_rc}"}"

	f_log "debug" "f_list   ::: name: ${src_name:-"-"}, mode: ${mode}, cnt: ${adb_cnt}, in_rc: ${in_rc}, out_rc: ${out_rc}"
	return "${out_rc}"
}

# top level domain compression
#
f_tld() {
	local cnt cnt_tld cnt_rem source="${1}" temp_tld="${1}.tld"

	if "${adb_awkcmd}" '{if(NR==1){tld=$NF};while(getline){if(index($NF,tld".")==0){print tld;tld=$NF}}print tld}' "${source}" |
		"${adb_awkcmd}" 'BEGIN{FS="."}{for(f=NF;f>1;f--)printf "%s.",$f;print $1}' >"${temp_tld}"; then
		[ "${adb_debug}" = "1" ] && cnt_tld="$(f_count tld "${temp_tld}" "var")"
		if [ -s "${adb_tmpdir}/tmp.rem.whitelist" ]; then
			"${adb_awkcmd}" 'NR==FNR{del[$0];next};!($0 in del)' "${adb_tmpdir}/tmp.rem.whitelist" "${temp_tld}" >"${source}"
			[ "${adb_debug}" = "1" ] && cnt_rem="$(f_count tld "${source}" "var")"
		else
			"${adb_catcmd}" "${temp_tld}" >"${source}"
		fi
	fi
	: > "${temp_tld}"

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
	if [ "${mode}" = "suspend" ] && [ "${status}" = "enabled" ]; then
		f_env
		printf "%b" "${adb_dnsheader}" >"${adb_dnsdir}/${adb_dnsfile}"
		if [ "${adb_jail}" = "1" ] && [ "${adb_jaildir}" = "${adb_dnsdir}" ]; then
			printf "%b" "${adb_dnsheader}" >"${adb_jaildir}/${adb_dnsjail}"
		elif [ -f "${adb_dnsdir}/${adb_dnsjail}" ]; then
			rm -f "${adb_dnsdir}/${adb_dnsjail}"
		fi
		f_count
		done="true"
	elif [ "${mode}" = "resume" ] && [ "${status}" = "paused" ]; then
		f_env
		f_main
		done="true"
	fi
	if [ "${done}" = "true" ]; then
		[ "${mode}" = "suspend" ] && f_dnsup
		f_jsnup "${mode}"
		f_log "info" "${mode} adblock processing"
	fi
	f_rmtemp
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
				prefix="local=.*[\\/\\.]"
				suffix="\\/"
				field="2"
				;;
			"unbound")
				prefix="local-zone: .*[\"\\.]"
				suffix="\" always_nxdomain"
				field="3"
				;;
			"named")
				prefix=""
				suffix=" CNAME \\."
				field="1"
				;;
			"kresd")
				prefix=""
				suffix=" CNAME \\."
				field="1"
				;;
			"smartdns")
				prefix="address .*.*[\\/\\.]"
				suffix="\\/#"
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
			result="$("${adb_awkcmd}" -F '/|\"|\t| ' "/^(${prefix}${search}${suffix})$/{i++;if(i<=9){printf \"  + %s\n\",\$${field}}else if(i==10){printf \"  + %s\n\",\"[...]\";exit}}" "${adb_dnsdir}/${adb_dnsfile}")"
			printf "%s\n%s\n%s\n" ":::" "::: domain '${domain}' in active blocklist" ":::"
			printf "%s\n\n" "${result:-"  - no match"}"
			[ "${domain}" = "${tld}" ] && break
			domain="${tld}"
			tld="${domain#*.}"
		done
		if [ "${adb_backup}" = "1" ] && [ -d "${adb_backupdir}" ]; then
			search="${1//[+*~%\$&\"\']/}"
			search="${search//./\\.}"
			printf "%s\n%s\n%s\n" ":::" "::: domain '${1}' in backups and black-/whitelist" ":::"
			for file in "${adb_backupdir}/${adb_dnsprefix}".*.gz "${adb_blacklist}" "${adb_whitelist}"; do
				suffix="${file##*.}"
				if [ "${suffix}" = "gz" ]; then
					"${adb_zcatcmd}" "${file}" 2>/dev/null |
						"${adb_awkcmd}" 'BEGIN{FS="."}{for(f=NF;f>1;f--)printf "%s.",$f;print $1}' | "${adb_awkcmd}" -v f="${file##*/}" "BEGIN{rc=1};/^($search|.*\\.${search})$/{i++;if(i<=3){printf \"  + %-30s%s\n\",f,\$1;rc=0}else if(i==4){printf \"  + %-30s%s\n\",f,\"[...]\"}};END{exit rc}"
				else
					"${adb_awkcmd}" -v f="${file##*/}" "BEGIN{rc=1};/^($search|.*\\.${search})$/{i++;if(i<=3){printf \"  + %-30s%s\n\",f,\$1;rc=0}else if(i==4){printf \"  + %-30s%s\n\",f,\"[...]\"}};END{exit rc}" "${file}"
				fi
				if [ "${?}" = "0" ]; then
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
	local object sources runtime utils mem_free mem_max status="${1:-"enabled"}"

	mem_free="$("${adb_awkcmd}" '/^MemAvailable/{printf "%s",int($2/1024)}' "/proc/meminfo" 2>/dev/null)"
	mem_max="$("${adb_awkcmd}" '/^VmHWM/{printf "%s",int($2)}' /proc/${$}/status 2>/dev/null)"

	case "${status}" in
		"enabled" | "error")
			adb_endtime="$(date "+%s")"
			if [ "$(((adb_endtime - adb_starttime) / 60))" -lt 60 ]; then
				runtime="${adb_action}, $(((adb_endtime - adb_starttime) / 60))m $(((adb_endtime - adb_starttime) % 60))s, ${mem_free:-0} MB available, ${mem_max:-0} KB max. used, $(date -Iseconds)"
			else
				runtime="${adb_action}, n/a, ${mem_free:-0} MB available, ${mem_max:-0} KB max. used, $(date -Iseconds)"
			fi
			[ "${status}" = "error" ] && adb_cnt="0"
			;;
		"suspend")
			status="paused"
			;;
		"resume")
			status=""
			;;
	esac
	json_init
	if json_load_file "${adb_rtfile}" >/dev/null 2>&1; then
		utils="download: $(readlink -fn "${adb_fetchutil}"), sort: $(readlink -fn "${adb_sortcmd}"), awk: $(readlink -fn "${adb_awkcmd}")"
		[ -z "${adb_cnt}" ] && { json_get_var adb_cnt "blocked_domains"; adb_cnt="${adb_cnt%% *}"; }
		[ -z "${runtime}" ] && json_get_var runtime "last_run"
	fi
	if [ "${adb_jail}" = "1" ] && [ "${adb_jaildir}" = "${adb_dnsdir}" ]; then
		adb_cnt="0"
		sources="restrictive_jail"
	else
		sources="$(printf "%s\n" ${adb_sources} | "${adb_sortcmd}" | "${adb_awkcmd}" '{ORS=" ";print $0}')"
	fi

	: >"${adb_rtfile}"
	json_init
	json_load_file "${adb_rtfile}" >/dev/null 2>&1
	json_add_string "adblock_status" "${status:-"enabled"}"
	json_add_string "adblock_version" "${adb_ver}"
	json_add_string "blocked_domains" "${adb_cnt:-0}"
	json_add_array "active_sources"
	for object in ${sources:-"-"}; do
		json_add_string "${object}" "${object}"
	done
	json_close_array
	json_add_string "dns_backend" "${adb_dns:-"-"} (${adb_dnscachecmd##*/}), ${adb_dnsdir:-"-"}"
	json_add_string "run_utils" "${utils:-"-"}"
	json_add_string "run_ifaces" "trigger: ${adb_trigger:-"-"}, report: ${adb_repiface:-"-"}"
	json_add_string "run_directories" "base: ${adb_tmpbase}, backup: ${adb_backupdir}, report: ${adb_reportdir}, jail: ${adb_jaildir}"
	json_add_string "run_flags" "backup: $(f_char ${adb_backup}), tld: $(f_char ${adb_tld}), force: $(f_char ${adb_forcedns}), flush: $(f_char ${adb_dnsflush}), search: $(f_char ${adb_safesearch}), report: $(f_char ${adb_report}), mail: $(f_char ${adb_mail}), jail: $(f_char ${adb_jail})"
	json_add_string "last_run" "${runtime:-"-"}"
	json_add_string "system" "${adb_sysver}"
	json_dump >"${adb_rtfile}"

	if [ "${adb_mail}" = "1" ] && [ -x "${adb_mailservice}" ] &&
		[ "${status}" = "enabled" ] && [ "${adb_cnt}" -le "${adb_mailcnt}" ]; then
		"${adb_mailservice}" >/dev/null 2>&1
	fi
}

# write to syslog
#
f_log() {
	local class="${1}" log_msg="${2}"

	if [ -n "${log_msg}" ] && { [ "${class}" != "debug" ] || [ "${adb_debug}" = "1" ]; }; then
		[ -x "${adb_loggercmd}" ] && "${adb_loggercmd}" -p "${class}" -t "adblock-${adb_ver}[${$}]" "${log_msg}" || \
			printf "%s %s %s\n" "${class}" "adblock-${adb_ver}[${$}]" "${log_msg}"
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
	local src_tmpload src_tmpfile src_name src_rset src_url src_log src_arc src_cat src_item src_list src_entries src_suffix src_rc entry cnt

	# white- and blacklist preparation
	#
	for entry in ${adb_locallist}; do
		(f_list "${entry}" "${entry}") &
	done

	if [ "${adb_dns}" != "raw" ] && [ "${adb_jail}" = "1" ] && [ "${adb_jaildir}" = "${adb_dnsdir}" ]; then
		printf "%b" "${adb_dnsheader}" >"${adb_dnsdir}/${adb_dnsfile}"
		chown "${adb_dnsuser}" "${adb_jaildir}/${adb_dnsjail}" 2>/dev/null
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
	elif [ -f "${adb_dnsdir}/${adb_dnsjail}" ]; then
		rm -f "${adb_dnsdir}/${adb_dnsjail}"
		f_dnsup
	fi

	# safe search preparation
	#
	if [ "${adb_safesearch}" = "1" ] && [ "${adb_dnssafesearch}" != "0" ]; then
		[ -z "${adb_safesearchlist}" ] && adb_safesearchlist="google bing duckduckgo pixabay yandex youtube"
		cnt="1"
		for entry in ${adb_safesearchlist}; do
			(f_list safesearch "${entry}") &
			hold="$((cnt % adb_cores))"
			[ "${hold}" = "0" ] && wait
			cnt="$((cnt + 1))"
		done
	fi
	wait

	# main loop
	#
	cnt="1"
	for src_name in ${adb_sources}; do
		if ! json_select "${src_name}" >/dev/null 2>&1; then
			adb_sources="${adb_sources/${src_name}/}"
			continue
		fi
		json_get_var src_url "url" >/dev/null 2>&1
		json_get_var src_rset "rule" >/dev/null 2>&1
		json_select ..
		src_tmpcat="${adb_tmpload}.${src_name}.cat"
		src_tmpload="${adb_tmpload}.${src_name}.load"
		src_tmpfile="${adb_tmpfile}.${src_name}"
		src_rc=4

		# basic pre-checks
		#
		if [ -z "${src_url}" ] || [ -z "${src_rset}" ]; then
			f_list remove
			continue
		fi

		# backup/restore mode
		#
		if [ "${adb_backup}" = "1" ] && { [ "${adb_action}" = "start" ] || [ "${adb_action}" = "restart" ] || [ "${adb_action}" = "resume" ]; }; then
			if f_list restore && [ -s "${src_tmpfile}" ]; then
				continue
			fi
		fi

		# download queue processing
		#
		unset src_cat src_entries
		if [ "${src_name}" = "utcapitole" ] && [ -n "${adb_utc_sources}" ]; then
			src_cat="${adb_utc_sources}"
			if [ -n "${src_cat}" ]; then
				(
					src_arc="${adb_tmpdir}/${src_url##*/}"
					src_log="$("${adb_fetchutil}" ${adb_fetchparm} "${src_arc}" "${src_url}" 2>&1)"
					src_rc="${?}"
					if [ "${src_rc}" = "0" ] && [ -s "${src_arc}" ]; then
						src_suffix="$(eval printf "%s" \"\$\{adb_src_suffix_${src_name}:-\"domains\"\}\")"
						src_list="$(tar -tzf "${src_arc}" 2>/dev/null)"
						for src_item in ${src_cat}; do
							src_entries="${src_entries} $(printf "%s" "${src_list}" | "${adb_grepcmd}" -E "${src_item}/${src_suffix}$")"
						done
						if [ -n "${src_entries}" ]; then
							tar -xOzf "${src_arc}" ${src_entries} 2>/dev/null >"${src_tmpload}"
							src_rc="${?}"
						fi
						: >"${src_arc}"
					else
						src_log="$(printf "%s" "${src_log}" | "${adb_awkcmd}" '{ORS=" ";print $0}')"
						f_log "info" "download of '${src_name}' failed, url: ${src_url}, rule: ${src_rset:-"-"}, categories: ${src_cat:-"-"}, rc: ${src_rc}, log: ${src_log:-"-"}"
					fi
					if [ "${src_rc}" = "0" ] && [ -s "${src_tmpload}" ]; then
						"${adb_awkcmd}" "${src_rset}" "${src_tmpload}" | "${adb_sedcmd}" "s/\r//g" |
							"${adb_awkcmd}" 'BEGIN{FS="."}{for(f=NF;f>1;f--)printf "%s.",$f;print $1}' |
							"${adb_sortcmd}" ${adb_srtopts} -u 2>/dev/null >"${src_tmpfile}"
						src_rc="${?}"
						if [ "${src_rc}" = "0" ] && [ -s "${src_tmpfile}" ]; then
							f_list download
							[ "${adb_backup}" = "1" ] && f_list backup
						elif [ "${adb_backup}" = "1" ] && [ "${adb_action}" != "start" ]; then
							f_log "info" "archive preparation of '${src_name}' failed, categories: ${src_cat:-"-"}, entries: ${src_entries}, rc: ${src_rc}"
							f_list restore
							: >"${src_tmpfile}"
						fi
					elif [ "${adb_backup}" = "1" ] && [ "${adb_action}" != "start" ]; then
						f_log "info" "archive extraction of '${src_name}' failed, categories: ${src_cat:-"-"}, entries: ${src_entries}, rc: ${src_rc}"
						f_list restore
					fi
				) &
			fi
		else
			case "${src_name}" in
				"1hosts")
					[ -n "${adb_hst_sources}" ] && src_cat="${adb_hst_sources}" || continue
					;;
				"hagezi")
					[ -n "${adb_hag_sources}" ] && src_cat="${adb_hag_sources}" || continue
					;;
				"stevenblack")
					[ -n "${adb_stb_sources}" ] && src_cat="${adb_stb_sources}" || continue
					;;
			esac
			(
				for suffix in ${src_cat:-${src_url}}; do
					if [ "${src_url}" != "${suffix}" ]; then
						src_log="$("${adb_fetchutil}" ${adb_fetchparm} "${src_tmpcat}" "${src_url}${suffix}" 2>&1)"
						src_rc="${?}"
						if [ "${src_rc}" = "0" ] && [ -s "${src_tmpcat}" ]; then
							"${adb_catcmd}" "${src_tmpcat}" >>"${src_tmpload}"
							: >"${src_tmpcat}"
						fi
					else
						src_log="$("${adb_fetchutil}" ${adb_fetchparm} "${src_tmpload}" "${src_url}" 2>&1)"
						src_rc="${?}"
					fi
				done
				if [ "${src_rc}" = "0" ] && [ -s "${src_tmpload}" ]; then
					"${adb_awkcmd}" "${src_rset}" "${src_tmpload}" | "${adb_sedcmd}" "s/\r//g" |
						"${adb_awkcmd}" 'BEGIN{FS="."}{for(f=NF;f>1;f--)printf "%s.",$f;print $1}' |
						"${adb_sortcmd}" ${adb_srtopts} -u >"${src_tmpfile}"
					src_rc="${?}"
					if [ "${src_rc}" = "0" ] && [ -s "${src_tmpfile}" ]; then
						f_list download
						[ "${adb_backup}" = "1" ] && f_list backup
					elif [ "${adb_backup}" = "1" ] && [ "${adb_action}" != "start" ]; then
						f_log "info" "preparation of '${src_name}' failed, rc: ${src_rc}"
						f_list restore
						: >"${src_tmpfile}"
					fi
				else
					src_log="$(printf "%s" "${src_log}" | "${adb_awkcmd}" '{ORS=" ";print $0}')"
					f_log "info" "download of '${src_name}' failed, url: ${src_url}, rule: ${src_rset:-"-"}, categories: ${src_cat:-"-"}, rc: ${src_rc}, log: ${src_log:-"-"}"
					[ "${adb_backup}" = "1" ] && [ "${adb_action}" != "start" ] && f_list restore
				fi
			) &
		fi
		hold="$((cnt % adb_cores))"
		[ "${hold}" = "0" ] && wait
		cnt="$((cnt + 1))"
	done
	wait

	# tld compression and dns restart
	#
	if f_list merge && [ -s "${adb_tmpdir}/${adb_dnsfile}" ]; then
		[ "${adb_tld}" = "1" ] && f_tld "${adb_tmpdir}/${adb_dnsfile}"
		f_list final
	else
		printf "%b" "${adb_dnsheader}" >"${adb_dnsdir}/${adb_dnsfile}"
	fi
	chown "${adb_dnsuser}" "${adb_dnsdir}/${adb_dnsfile}" 2>/dev/null
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
	local report_raw report_txt content status total start end start_date start_time end_date end_time blocked percent top_list top array item index hold ports value key key_list cnt="0" resolve="-nn" action="${1}" top_count="${2:-"10"}" res_count="${3:-"50"}" search="${4:-"+"}"

	report_raw="${adb_reportdir}/adb_report.raw"
	report_srt="${adb_reportdir}/adb_report.srt"
	report_jsn="${adb_reportdir}/adb_report.json"
	report_txt="${adb_reportdir}/adb_mailreport.txt"

	# build json file
	#
	if [ "${action}" != "json" ]; then
		: >"${report_raw}"
		: >"${report_srt}"
		: >"${report_txt}"
		: >"${report_jsn}"
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
			hold="$((cnt % adb_cores))"
			[ "${hold}" = "0" ] && wait
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
	if [ "${action}" = "cli" ]; then
		printf "%s\n" "${content}"
	elif [ "${action}" = "json" ]; then
		"${adb_catcmd}" "${report_jsn}"
	elif [ "${action}" = "mail" ] && [ "${adb_mail}" = "1" ] && [ -x "${adb_mailservice}" ]; then
		"${adb_mailservice}" "${content}" >/dev/null 2>&1
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
adb_wccmd="$(f_cmd wc)"
adb_catcmd="$(f_cmd cat)"
adb_zcatcmd="$(f_cmd zcat)"
adb_awkcmd="$(f_cmd gawk awk)"
adb_sortcmd="$(f_cmd sort)"
adb_grepcmd="$(f_cmd grep)"
adb_gzipcmd="$(f_cmd gzip)"
adb_pgrepcmd="$(f_cmd pgrep)"
adb_sedcmd="$(f_cmd sed)"
adb_jsoncmd="$(f_cmd jsonfilter)"
adb_ubuscmd="$(f_cmd ubus)"
adb_loggercmd="$(f_cmd logger)"
adb_dumpcmd="$(f_cmd tcpdump optional)"
adb_lookupcmd="$(f_cmd nslookup)"
adb_mailcmd="$(f_cmd msmtp optional)"
adb_stringscmd="$(f_cmd strings optional)"
adb_logreadcmd="$(f_cmd logread optional)"

# handle different adblock actions
#
f_load
case "${adb_action}" in
	"stop")
		f_rmdns
		;;
	"restart")
		f_rmdns
		f_env
		f_main
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
	"start" | "reload")
		f_env
		f_main
		;;
esac
