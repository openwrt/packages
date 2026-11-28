#!/bin/sh
# Revoke registration before reload; failed removal keeps the coova drops.

TUNTAP="${DEV##*/}"
. /etc/chilli/functions
. /usr/share/coova-chilli/fw4.sh

{
	flock -x 8
	flock -x 9
	chilli_fw4_unregister "$TUNTAP" || chilli_fw4_warn "cannot unregister firewall rules for $TUNTAP"
	chilli_fw4_sync || chilli_fw4_warn "cannot synchronize firewall teardown for $TUNTAP"
} 8>/var/run/fw4.lock 9>/tmp/.chilli-flock
chilli_fw4_reload
{
	flock -x 8
	flock -x 9
	chilli_fw4_cleanup || chilli_fw4_warn "coova drops retained after teardown for $TUNTAP"
} 8>/var/run/fw4.lock 9>/tmp/.chilli-flock

[ ! -e /etc/chilli/ipdown.sh ] || . /etc/chilli/ipdown.sh
exit 0
