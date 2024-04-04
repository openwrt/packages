#!/bin/sh

curr_ver=0.4.7

# Copyright: antonk (antonk.d3v@gmail.com)
# github.com/friendly-bits

kill_geo_pids() {
	i_kgp=0 _parent="$(grep -o "${p_name}[^[:space:]]*" "/proc/$PPID/comm")"
	while true; do
		i_kgp=$((i_kgp+1)); _killed=
		_geo_ps="$(pgrep -fa "(${p_name}\-|$ripe_url_stats|$ripe_url_api|$ipdeny_ipv4_url|$ipdeny_ipv6_url)" | grep -v pgrep)"
		newifs "$_nl" kgp
		for _p in $_geo_ps; do
			_pid="${_p% *}"
			_p="$p_name${_p##*"$p_name"}"
			_p="${_p%% *}"
			case "$_pid" in "$$"|"$PPID"|*[!0-9]*) continue; esac
			[ "$_p" = "$_parent" ] && continue
			IFS=' '
			for g in run fetch apply cronsetup backup detect-lan; do
				case "$_p" in *${p_name}-$g*)
					kill "$_pid" 2>/dev/null
					_killed=1
				esac
			done
		done
		oldifs kgp
		[ ! "$_killed" ] || [ $i_kgp -gt 10 ] && break
	done
	unisleep
}

rm_iplists_rules() {
	echo "Removing $p_name ip lists and firewall rules..."

	kill_geo_pids

	rm_lock

	rm_all_georules || return 1

	set +f
	rm -f "${iplist_dir:?}"/*.iplist 2>/dev/null
	rm -rf "${datadir:?}"/* 2>/dev/null
	set -f
	:
}

rm_cron_jobs() {
	echo "Removing cron jobs..."
	crontab -u root -l 2>/dev/null | grep -v "${p_name}-run.sh" | crontab -u root -
	:
}

rm_geodir() {
	[ "$1" ] && [ -d "$1" ] && {
		printf '%s\n' "Deleting the $2 directory '$1'..."
		rm -rf "$1"
	}
}

rm_data() {
	rm_geodir "$datadir" data
	:
}

rm_symlink() {
	rm -f "${install_dir}/${p_name}" 2>/dev/null
}

rm_scripts() {
	printf '%s\n' "Deleting the main $p_name scripts from $install_dir..."
	for script_name in fetch apply manage cronsetup run backup mk-fw-include fw-include detect-lan uninstall geoinit; do
		rm -f "${install_dir}/${p_name}-$script_name.sh" 2>/dev/null
	done

	rm_geodir "$lib_dir" "library scripts"
	:
}

rm_config() {
	rm_geodir "$conf_dir" config
	:
}
