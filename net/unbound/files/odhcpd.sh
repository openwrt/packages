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
#
# This script facilitates alternate installation of Unbound+odhcpd and no
# need for dnsmasq. There are some limitations, but it works and is small.
# The lease file is parsed to make "zone-data:" and "local-data:" entries.
#
# config odhcpd 'odhcpd'
#   option leasetrigger '/usr/lib/unbound/odhcpd.sh'
#
##############################################################################

# Common file location definitions
. /usr/lib/unbound/unbound.sh

##############################################################################

odhcpd_settings() {
  # This trigger is out of normal init context, so we need to read some UCI.
  local cfg="$1"
  config_get UNBOUND_D_DHCP_LINK  "$cfg" dhcp_link none
  config_get_bool UNBOUND_B_SLAAC6_MAC "$cfg" dhcp4_slaac6 0
  config_get UNBOUND_TXT_DOMAIN "$cfg" domain lan
}

##############################################################################

odhcpd_zonedata() {
  local dns_ls_add=$UNBOUND_VARDIR/dhcp_dns.add
  local dns_ls_del=$UNBOUND_VARDIR/dhcp_dns.del
  local dhcp_ls_new=$UNBOUND_VARDIR/dhcp_lease.new
  local dhcp_ls_old=$UNBOUND_VARDIR/dhcp_lease.old
  local dhcp_ls_add=$UNBOUND_VARDIR/dhcp_lease.add
  local dhcp_ls_del=$UNBOUND_VARDIR/dhcp_lease.del
  local dhcp_origin=$( uci get dhcp.@odhcpd[0].leasefile )

  config_load unbound
  config_foreach odhcpd_settings unbound


  if [ "$UNBOUND_D_DHCP_LINK" = "odhcpd" -a -f "$dhcp_origin" ] ; then
    # Capture the lease file which could be changing often
    cat $dhcp_origin | sort > $dhcp_ls_new
    touch $dhcp_ls_old
    sort $dhcp_ls_new $dhcp_ls_old $dhcp_ls_old | uniq -u > $dhcp_ls_add
    sort $dhcp_ls_old $dhcp_ls_new $dhcp_ls_new | uniq -u > $dhcp_ls_del

    # Go through the messy business of coding up A, AAAA, and PTR records
    # This static conf will be available if Unbound restarts asynchronously
    awk -v hostfile=$UNBOUND_DHCP_CONF -v domain=$UNBOUND_TXT_DOMAIN \
        -v bslaac=$UNBOUND_B_SLAAC6_MAC -v bisolt=0 -v bconf=1 \
        -f /usr/lib/unbound/odhcpd.awk $dhcp_ls_new

    # Deleting and adding all records into Unbound can be a burden in a
    # high density environment. Use unbound-control incrementally.
    awk -v hostfile=$dns_ls_del -v domain=$UNBOUND_TXT_DOMAIN \
        -v bslaac=$UNBOUND_B_SLAAC6_MAC -v bisolt=0 -v bconf=0 \
        -f /usr/lib/unbound/odhcpd.awk $dhcp_ls_del

    awk -v hostfile=$dns_ls_add -v domain=$UNBOUND_TXT_DOMAIN \
        -v bslaac=$UNBOUND_B_SLAAC6_MAC -v bisolt=0 -v bconf=0 \
        -f /usr/lib/unbound/odhcpd.awk $dhcp_ls_add


    if [ -f "$dns_ls_del" ] ; then
      cat $dns_ls_del | $UNBOUND_CONTROL_CFG local_datas_remove
    fi


    if [ -f "$dns_ls_add" ] ; then
      cat $dns_ls_add | $UNBOUND_CONTROL_CFG local_datas
    fi


    # prepare next round
    mv $dhcp_ls_new $dhcp_ls_old
    rm -f $dns_ls_del $dns_ls_add $dhcp_ls_del $dhcp_ls_add
  fi
}

##############################################################################

odhcpd_zonedata

##############################################################################

