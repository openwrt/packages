#!/bin/sh
# banIP main service script - ban incoming and outgoing IPs via named nftables Sets
# Copyright (c) 2018-2025 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

# (s)hellcheck exceptions
# shellcheck disable=all

ban_action="${1}"
ban_starttime="$(date "+%s")"
ban_funlib="/usr/lib/banip-functions.sh"
[ -z "${ban_ver}" ] && . "${ban_funlib}"

# load config and set banIP environment
#
[ "${ban_action}" = "boot" ] && sleep "$(uci_get banip global ban_triggerdelay "20")"
f_conf
f_log "info" "start banIP processing (${ban_action}, ${ban_ver:-"n/a"})"
f_genstatus "processing"
f_tmp
f_getfetch
f_getif
f_getdev
f_getuplink
f_mkdir "${ban_backupdir}"
f_mkfile "${ban_allowlist}"
f_mkfile "${ban_blocklist}"
f_rmdir "${ban_errordir}"

# firewall/fw4 pre-check
#
if [ ! -x "${ban_fw4cmd}" ] || [ ! -x "/etc/init.d/firewall" ]; then
	f_log "err" "firewall/fw4 not found"
elif ! /etc/init.d/firewall status >/dev/null 2>&1; then
	f_log "info" "firewall/fw4 is not running"
fi

# init banIP nftables namespace
#
if [ "${ban_action}" != "reload" ] || ! "${ban_nftcmd}" list chain inet banIP pre-routing >/dev/null 2>&1; then
	f_nftinit "${ban_tmpfile}".init.nft
fi

# handle downloads
#
f_log "info" "start banIP download processes"
if [ "${ban_allowlistonly}" = "1" ]; then
	ban_feed=""
else
	f_getfeed
fi
[ "${ban_deduplicate}" = "1" ] && printf "\n" >"${ban_tmpfile}.deduplicate"

cnt="1"
for feed in allowlist ${ban_feed} blocklist; do
	# local feeds (sequential processing)
	#
	if [ "${feed}" = "allowlist" ] || [ "${feed}" = "blocklist" ]; then
		for proto in 4MAC 6MAC 4 6; do
			[ "${feed}" = "blocklist" ] && wait
			f_down "${feed}" "${proto}" "-" "-" "inout"
		done
		continue
	fi

	# external feeds (parallel processing on multicore hardware)
	#
	if ! json_select "${feed}" >/dev/null 2>&1; then
		f_log "info" "remove unknown feed '${feed}'"
		uci_remove_list banip global ban_feed "${feed}"
		uci_commit "banip"
		continue
	fi
	json_objects="url_4 rule_4 url_6 rule_6 chain flag"
	for object in ${json_objects}; do
		eval json_get_var feed_"${object}" '${object}' >/dev/null 2>&1
	done
	json_select ..

	# skip incomplete feeds
	#
	if { { [ -n "${feed_url_4}" ] && [ -z "${feed_rule_4}" ]; } || { [ -z "${feed_url_4}" ] && [ -n "${feed_rule_4}" ]; }; } ||
		{ { [ -n "${feed_url_6}" ] && [ -z "${feed_rule_6}" ]; } || { [ -z "${feed_url_6}" ] && [ -n "${feed_rule_6}" ]; }; } ||
		{ [ -z "${feed_url_4}" ] && [ -z "${feed_rule_4}" ] && [ -z "${feed_url_6}" ] && [ -z "${feed_rule_6}" ]; }; then
		f_log "info" "skip incomplete feed '${feed}'"
		continue
	fi

	# handle IPv4/IPv6 feeds
	#
	if [ "${ban_protov4}" = "1" ] && [ -n "${feed_url_4}" ] && [ -n "${feed_rule_4}" ]; then
		if [ "${feed}" = "country" ] && [ "${ban_countrysplit}" = "1" ]; then
			for country in ${ban_country}; do
				f_down "${feed}.${country}" "4" "${feed_url_4}" "${feed_rule_4}" "${feed_chain:-"in"}" "${feed_flag}"
			done
		elif [ "${feed}" = "asn" ] && [ "${ban_asnsplit}" = "1" ]; then
			for asn in ${ban_asn}; do
				f_down "${feed}.${asn}" "4" "${feed_url_4}" "${feed_rule_4}" "${feed_chain:-"in"}" "${feed_flag}"
			done
		else
			(f_down "${feed}" "4" "${feed_url_4}" "${feed_rule_4}" "${feed_chain:-"in"}" "${feed_flag}") &
		fi
		if [ "${feed_url_4}" = "${feed_url_6}" ]; then
			feed_url_6="local"
			wait
		else
			hold="$((cnt % ban_cores))"
			[ "${hold}" = "0" ] && wait
			cnt="$((cnt + 1))"
		fi
	fi
	if [ "${ban_protov6}" = "1" ] && [ -n "${feed_url_6}" ] && [ -n "${feed_rule_6}" ]; then
		if [ "${feed}" = "country" ] && [ "${ban_countrysplit}" = "1" ]; then
			for country in ${ban_country}; do
				f_down "${feed}.${country}" "6" "${feed_url_6}" "${feed_rule_6}" "${feed_chain:-"in"}" "${feed_flag}"
			done
		elif [ "${feed}" = "asn" ] && [ "${ban_asnsplit}" = "1" ]; then
			for asn in ${ban_asn}; do
				f_down "${feed}.${asn}" "6" "${feed_url_6}" "${feed_rule_6}" "${feed_chain:-"in"}" "${feed_flag}"
			done
		else
			(f_down "${feed}" "6" "${feed_url_6}" "${feed_rule_6}" "${feed_chain:-"in"}" "${feed_flag}") &
		fi
		cnt="$((cnt + 1))"
		hold="$((cnt % ban_cores))"
		[ "${hold}" = "0" ] && wait
	fi
done
wait
f_rmset
f_rmdir "${ban_tmpdir}"
f_genstatus "active"

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
(
	sleep 5
	if [ "${ban_mailnotification}" = "1" ] && [ -n "${ban_mailreceiver}" ] && [ -x "${ban_mailcmd}" ]; then
		f_mail
	fi
	json_cleanup
	rm -rf "${ban_lock}"
) &

# start detached log service (infinite loop)
#
f_monitor
