#!/bin/sh

curr_ver=0.4.7

# Copyright: antonk (antonk.d3v@gmail.com)
# github.com/friendly-bits

checkutil () { command -v "$1" 1>/dev/null; }

enable_owrt_init() {
	init_script="/etc/init.d/${p_name}-init"
	if [ "$no_persist" ]; then
		printf '%s\n\n' "Installed without persistence functionality."
	else
		! check_owrt_init && {
			echo "Enabling the init script... "
			$init_script enable
		}
		printf %s "Checking the init script... "
		check_owrt_init || { echolog -err "$FAIL enable '$init_script'."; return 1; }
		OK
		! check_owrt_include && {
			$init_script start
			reload_owrt_fw
			sleep 1
		}
		printf %s "Checking the firewall include... "
		check_owrt_include || { echolog -err "$FAIL add firewall include."; return 1; }
		OK
	fi
}

check_owrt_init() {
	set +f
	for f in /etc/rc.d/S*"${p_name}-init"; do
		[ -s "$f" ] && { set -f; return 0; }
	done
	set -f
	return 1
}

check_uci_ent() { [ "$(uci -q get firewall."$p_name_c.$1")" = "$2" ]; }

check_owrt_include() {
	check_uci_ent enabled 1 || return 1
	[ "$_OWRTFW" = 4 ] && return 0
	check_uci_ent reload 1
}

rm_owrt_fw_include() {
	echo "Removing the firewall include..."
	uci delete firewall."${p_name%%-*}_${p_name#*-}" 1>/dev/null 2>/dev/null

	echo "Committing fw$_OWRTFW changes..."
	uci commit firewall
	:
}

rm_owrt_init() {
	echo "Deleting the init script..."
	/etc/init.d/${p_name}-init disable 2>/dev/null && rm "/etc/init.d/${p_name}-init" 2>/dev/null
	:
}

restart_owrt_fw() {
	echo "Restarting firewall$_OWRTFW..."
	fw$_OWRTFW -q restart
	:
}

reload_owrt_fw() {
	echo "Reloading firewall$_OWRTFW..."
	fw$_OWRTFW -q reload
	:
}

me="${0##*/}"
p_name_c="${p_name%%-*}_${p_name#*-}"
_OWRTFW=

checkutil uci && checkutil procd && for i in 3 4; do
	[ -x /sbin/fw$i ] && export _OWRTFW="$i"
done

[ -z "$_OWRTFW" ] && {
	logger -s -t "$me" -p user.warn "Warning: Detected procd init but no OpenWrt firewall."
	return 0
}
curr_sh_g="/bin/sh"
:
