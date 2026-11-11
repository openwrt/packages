#!/bin/sh
# Publish under fw4 -> chilli locks; release both before invoking fw4.

TUNTAP="${DEV##*/}"
. /etc/chilli/functions
. /usr/share/coova-chilli/fw4.sh

{
	flock -x 8
	flock -x 9
	chilli_fw4_block || chilli_fw4_warn 'cannot block previous chilli firewall chains'
	chilli_fw4_unregister "$TUNTAP" || chilli_fw4_warn "cannot retire previous firewall rules for $TUNTAP"
	chilli_fw4_register; rc=$?
	[ "$rc" != 1 ] || chilli_fw4_warn "cannot register firewall rules for $TUNTAP"
	[ "$rc" != 2 ] || chilli_fw4_warn "firewall rules for $TUNTAP registered; drops pending"
} 8>/var/run/fw4.lock 9>/tmp/.chilli-flock
chilli_fw4_reload
# Judge the loaded ruleset, not the steps: a later retry may have succeeded.
{
	flock -x 8
	flock -x 9
	chilli_fw4_guarded
} 8>/var/run/fw4.lock 9>/tmp/.chilli-flock; rc=$?
[ "$rc" = 0 ] || chilli_fw4_err "no chilli drops loaded for $DHCPIF ($TUNTAP); clients may bypass the portal"

[ -n "$KNAME" ] && [ -n "$DHCPLISTEN" ] && ifconfig "$DHCPIF" "$DHCPLISTEN"
[ ! -e /etc/chilli/ipup.sh ] || . /etc/chilli/ipup.sh
exit "$rc"
