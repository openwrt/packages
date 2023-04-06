#!/bin/sh
# banIP main service script - ban incoming and outgoing ip addresses/subnets via sets in nftables
# Copyright (c) 2018-2023 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# (s)hellcheck exceptions
# shellcheck disable=all

ban_action="${1}"
ban_starttime="$(date "+%s")"
ban_funlib="/usr/lib/banip-functions.sh"
[ -z "$(command -v "f_system")" ] && . "${ban_funlib}"

# load config and set banIP environment
#
f_conf
f_log "info" "start banIP processing (${ban_action})"
f_genstatus "processing"
f_tmp
f_fetch
f_getif
f_getdev
f_getsub
f_mkdir "${ban_backupdir}"
f_mkfile "${ban_blocklist}"
f_mkfile "${ban_allowlist}"

# firewall check
#
if [ "${ban_action}" != "reload" ]; then
	if [ -x "${ban_fw4cmd}" ]; then
		cnt="0"
		while [ "${cnt}" -lt "30" ] && ! /etc/init.d/firewall status >/dev/null 2>&1; do
			cnt="$((cnt + 1))"
			sleep 1
		done
		if ! /etc/init.d/firewall status >/dev/null 2>&1; then
			f_log "err" "nft based firewall/fw4 not functional"
		fi
	else
		f_log "err" "nft based firewall/fw4 not found"
	fi
fi

# init nft namespace
#
if [ "${ban_action}" != "reload" ] || ! "${ban_nftcmd}" -t list set inet banIP allowlistvMAC >/dev/null 2>&1; then
	if f_nftinit "${ban_tmpfile}".init.nft; then
		f_log "info" "nft namespace initialized"
	else
		f_log "err" "nft namespace can't be initialized"
	fi
fi

# handle downloads
#
f_log "info" "start banIP download processes"
if [ "${ban_allowlistonly}" = "1" ]; then
	ban_feed=""
else
	json_init
	if ! json_load_file "${ban_feedfile}" >/dev/null 2>&1; then
		f_log "err" "banIP feed file can't be loaded"
	fi
	[ "${ban_deduplicate}" = "1" ] && printf "\n" >"${ban_tmpfile}.deduplicate"
fi

cnt="1"
for feed in allowlist ${ban_feed} blocklist; do
	# local feeds
	#
	if [ "${feed}" = "allowlist" ] || [ "${feed}" = "blocklist" ]; then
		for proto in MAC 4 6; do
			[ "${feed}" = "blocklist" ] && wait
			(f_down "${feed}" "${proto}") &
			[ "${feed}" = "blocklist" ] || { [ "${feed}" = "allowlist" ] && [ "${proto}" = "MAC" ]; } && wait
			hold="$((cnt % ban_cores))"
			[ "${hold}" = "0" ] && wait
			cnt="$((cnt + 1))"
		done
		wait
		continue
	fi

	# read external feed information
	#
	if ! json_select "${feed}" >/dev/null 2>&1; then
		continue
	fi
	json_objects="url_4 rule_4 url_6 rule_6 flag"
	for object in ${json_objects}; do
		eval json_get_var feed_"${object}" '${object}' >/dev/null 2>&1
	done
	json_select ..
	# handle IPv4/IPv6 feeds with the same/single download URL
	#
	if [ "${feed_url_4}" = "${feed_url_6}" ]; then
		if [ "${ban_protov4}" = "1" ] && [ -n "${feed_url_4}" ] && [ -n "${feed_rule_4}" ]; then
			(f_down "${feed}" "4" "${feed_url_4}" "${feed_rule_4}" "${feed_flag}") &
			feed_url_6="local"
			wait
		fi
		if [ "${ban_protov6}" = "1" ] && [ -n "${feed_url_6}" ] && [ -n "${feed_rule_6}" ]; then
			(f_down "${feed}" "6" "${feed_url_6}" "${feed_rule_6}" "${feed_flag}") &
			hold="$((cnt % ban_cores))"
			[ "${hold}" = "0" ] && wait
			cnt="$((cnt + 1))"
		fi
		continue
	fi
	# handle IPv4/IPv6 feeds with separated download URLs
	#
	if [ "${ban_protov4}" = "1" ] && [ -n "${feed_url_4}" ] && [ -n "${feed_rule_4}" ]; then
		(f_down "${feed}" "4" "${feed_url_4}" "${feed_rule_4}" "${feed_flag}") &
		hold="$((cnt % ban_cores))"
		[ "${hold}" = "0" ] && wait
		cnt="$((cnt + 1))"
	fi
	if [ "${ban_protov6}" = "1" ] && [ -n "${feed_url_6}" ] && [ -n "${feed_rule_6}" ]; then
		(f_down "${feed}" "6" "${feed_url_6}" "${feed_rule_6}" "${feed_flag}") &
		hold="$((cnt % ban_cores))"
		[ "${hold}" = "0" ] && wait
		cnt="$((cnt + 1))"
	fi
done
wait
f_rmset
f_rmdir "${ban_tmpdir}"
f_genstatus "active"
f_log "info" "finished banIP download processes"

# start domain lookup
#
f_log "info" "start banIP domain lookup"
cnt="1"
for list in allowlist blocklist; do
	(f_lookup "${list}") &
	hold="$((cnt % ban_cores))"
	[ "${hold}" = "0" ] && wait
	cnt="$((cnt + 1))"
done
wait

# end processing
#
if [ "${ban_mailnotification}" = "1" ] && [ -n "${ban_mailreceiver}" ] && [ -x "${ban_mailcmd}" ]; then
	(
		sleep ${ban_triggerdelay}
		f_mail
	) &
fi
rm -rf "${ban_lock}"

# start detached log service
#
if [ -x "${ban_logreadcmd}" ] && [ -n "${ban_logterm%%??}" ]; then
	f_log "info" "start detached banIP log service"

	nft_expiry="$(printf "%s" "${ban_nftexpiry}" | grep -oE "([0-9]+[h|m|s]$)")"
	[ -n "${nft_expiry}" ] && nft_expiry="timeout ${nft_expiry}"

	# read log continuously with given logterms
	#
	"${ban_logreadcmd}" -fe "${ban_logterm%%??}" 2>/dev/null |
		while read -r line; do
			proto=""
			# IPv4 log parsing
			#
			ip="$(printf "%s" "${line}" | "${ban_awkcmd}" 'BEGIN{RS="(([0-9]{1,3}\\.){3}[0-9]{1,3})+"}{if(!seen[RT]++)printf "%s ",RT}')"
			ip="$(f_trim "${ip}")"
			ip="${ip##* }"
			[ -n "${ip}" ] && proto="v4"
			if [ -z "${proto}" ]; then
				# IPv6 log parsing
				#
				ip="$(printf "%s" "${line}" | "${ban_awkcmd}" 'BEGIN{RS="([A-Fa-f0-9]{1,4}::?){3,7}[A-Fa-f0-9]{1,4}"}{if(!seen[RT]++)printf "%s ",RT}')"
				ip="$(f_trim "${ip}")"
				ip="${ip##* }"
				[ -n "${ip}" ] && proto="v6"
			fi
			if [ -n "${proto}" ] && ! "${ban_nftcmd}" get element inet banIP blocklist"${proto}" "{ ${ip} }" >/dev/null 2>&1; then
				f_log "info" "suspicious IP${proto} found '${ip}'"
				log_raw="$("${ban_logreadcmd}" -l "${ban_loglimit}" 2>/dev/null)"
				log_count="$(printf "%s\n" "${log_raw}" | grep -c "found '${ip}'")"
				if [ "${log_count}" -ge "${ban_logcount}" ]; then
					if "${ban_nftcmd}" add element inet banIP "blocklist${proto}" "{ ${ip} ${nft_expiry} }" >/dev/null 2>&1; then
						f_log "info" "added IP${proto} '${ip}' (expiry: ${nft_expiry:-"-"}) to blocklist${proto} set"
						if [ "${ban_autoblocklist}" = "1" ] && ! grep -q "^${ip}" "${ban_blocklist}"; then
							printf "%-42s%s\n" "${ip}" "# added on $(date "+%Y-%m-%d %H:%M:%S")" >>"${ban_blocklist}"
							f_log "info" "added IP${proto} '${ip}' to local blocklist"
						fi
					fi
				fi
			fi
		done

# start detached no-op service loop
#
else
	f_log "info" "start detached no-op banIP service (logterms are missing)"
	while :; do
		sleep 1
	done
fi
