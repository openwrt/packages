#!/bin/sh
##############################################################################
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# Copyright (C) 2016 Eric Luehrsen
#
##############################################################################

UNBOUND_LIBDIR=/usr/lib/unbound
UNBOUND_VARDIR=/var/lib/unbound

UNBOUND_PIDFILE=/var/run/unbound.pid

UNBOUND_SRV_CONF=$UNBOUND_VARDIR/unbound_srv.conf
UNBOUND_EXT_CONF=$UNBOUND_VARDIR/unbound_ext.conf
UNBOUND_DHCP_CONF=$UNBOUND_VARDIR/unbound_dhcp.conf
UNBOUND_CONFFILE=$UNBOUND_VARDIR/unbound.conf

UNBOUND_KEYFILE=$UNBOUND_VARDIR/root.key
UNBOUND_HINTFILE=$UNBOUND_VARDIR/root.hints
UNBOUND_TIMEFILE=$UNBOUND_VARDIR/hotplug.time

UNBOUND_CTLKEY_FILE=$UNBOUND_VARDIR/unbound_control.key
UNBOUND_CTLPEM_FILE=$UNBOUND_VARDIR/unbound_control.pem
UNBOUND_SRVKEY_FILE=$UNBOUND_VARDIR/unbound_server.key
UNBOUND_SRVPEM_FILE=$UNBOUND_VARDIR/unbound_server.pem

##############################################################################

UNBOUND_ANCHOR=/usr/sbin/unbound-anchor
UNBOUND_CONTROL=/usr/sbin/unbound-control
UNBOUND_CONTROL_CFG="$UNBOUND_CONTROL -c $UNBOUND_CONFFILE"

##############################################################################

