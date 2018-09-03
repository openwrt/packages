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

# where are we?
UB_LIBDIR=/usr/lib/unbound
UB_VARDIR=/var/lib/unbound
UB_PIDFILE=/var/run/unbound.pid

# conf deconstructed
UB_TOTAL_CONF=$UB_VARDIR/unbound.conf
UB_CORE_CONF=$UB_VARDIR/server.conf.tmp
UB_HOST_CONF=$UB_VARDIR/host.conf.tmp
UB_DHCP_CONF=$UB_VARDIR/dhcp.conf
UB_ZONE_CONF=$UB_VARDIR/zone.conf.tmp
UB_CTRL_CONF=$UB_VARDIR/ctrl.conf.tmp
UB_SRVMASQ_CONF=$UB_VARDIR/dnsmasq_srv.conf.tmp
UB_EXTMASQ_CONF=$UB_VARDIR/dnsmasq_ext.conf.tmp
UB_SRV_CONF=$UB_VARDIR/unbound_srv.conf
UB_EXT_CONF=$UB_VARDIR/unbound_ext.conf

# TLS keys
UB_TLS_KEY_FILE="TLS server UCI not implemented"
UB_TLS_PEM_FILE="TLS server UCI not implemented"
UB_TLS_FWD_FILE=$UB_VARDIR/ca-certificates.crt
UB_TLS_ETC_FILE=/etc/ssl/certs/ca-certificates.crt

# start files
UB_RKEY_FILE=$UB_VARDIR/root.key
UB_RHINT_FILE=$UB_VARDIR/root.hints
UB_TIME_FILE=$UB_VARDIR/hotplug.time
UB_SKIP_FILE=$UB_VARDIR/skip.time

# control app keys
UB_CTLKEY_FILE=$UB_VARDIR/unbound_control.key
UB_CTLPEM_FILE=$UB_VARDIR/unbound_control.pem
UB_SRVKEY_FILE=$UB_VARDIR/unbound_server.key
UB_SRVPEM_FILE=$UB_VARDIR/unbound_server.pem

# similar default SOA / NS RR as Unbound uses for private ARPA zones
UB_XSER=$(( $( date +%s ) / 60 ))
UB_XSOA="7200 IN SOA localhost. nobody.invalid. $UB_XSER 3600 1200 9600 300"
UB_XNS="7200 IN NS localhost."
UB_XTXT="7200 IN TXT \"comment=local intranet dns zone\""
UB_MTXT="7200 IN TXT \"comment=masked internet dns zone\""
UB_LTXT="7200 IN TXT \"comment=rfc6762 multicast dns zone\""

# helper apps
UB_ANCHOR=/usr/sbin/unbound-anchor
UB_CONTROL=/usr/sbin/unbound-control
UB_CONTROL_CFG="$UB_CONTROL -c $UB_TOTAL_CONF"

##############################################################################

