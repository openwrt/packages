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
# This crosses over to the dnsmasq UCI file "dhcp" and parses it for fields
# that will allow Unbound to request local host DNS of dnsmasq. We need to look
# at the interfaces in "dhcp" and get their subnets. The Unbound conf syntax
# makes this a little difficult. First in "server:" we need to create private
# zones for the domain and PTR records. Then we need to create numerous
# "forward:" clauses to forward those zones to dnsmasq.
#
##############################################################################

dnsmasq_local_zone() {
  local cfg="$1"
  local fwd_port fwd_domain wan_fqdn

  # dnsmasq domain and interface assignment settings will control config
  config_get fwd_domain "$cfg" domain
  config_get fwd_port "$cfg" port
  config_get wan_fqdn "$cfg" add_wan_fqdn


  if [ -n "$wan_fqdn" ] ; then
    UNBOUND_D_WAN_FQDN=$wan_fqdn
  fi


  if [ -n "$fwd_domain" -a -n "$fwd_port" -a ! "$fwd_port" -eq 53 ] ; then
    # dnsmasq localhost listening ports (possible multiple instances)
    UNBOUND_N_FWD_PORTS="$UNBOUND_N_FWD_PORTS $fwd_port"
    UNBOUND_TXT_FWD_ZONE="$UNBOUND_TXT_FWD_ZONE $fwd_domain"

    {
      # This creates DOMAIN local privledges
      echo "  private-domain: \"$fwd_domain\""
      echo "  local-zone: \"$fwd_domain.\" transparent"
      echo "  domain-insecure: \"$fwd_domain\""
      echo
    } >> $UNBOUND_CONFFILE
  fi
}

##############################################################################

dnsmasq_local_arpa() {
  local cfg="$1"
  local logint dhcpv4 dhcpv6 ignore
  local subnets subnets4 subnets6
  local forward arpa
  local validip4 validip6 privateip

  config_get logint "$cfg" interface
  config_get dhcpv4 "$cfg" dhcpv4
  config_get dhcpv6 "$cfg" dhcpv6
  config_get_bool ignore "$cfg" ignore 0

  # Find the list of addresses assigned to a logical interface
  # Its typical to have a logical gateway split NAME and NAME6
  network_get_subnets  subnets4 "$logint"
  network_get_subnets6 subnets6 "$logint"
  subnets="$subnets4 $subnets6"

  network_get_subnets  subnets4 "${logint}6"
  network_get_subnets6 subnets6 "${logint}6"
  subnets="$subnets $subnets4 $subnets6"


  if [ -z "$subnets" ] ; then
    forward=""

  elif [ -z "$UNBOUND_N_FWD_PORTS" ] ; then
    forward=""

  elif [ "$ignore" -gt 0 ] ; then
    if [ "$UNBOUND_D_WAN_FQDN" -gt 0 ] ; then
      # Only forward the one gateway host.
      forward="host"

    else
      forward=""
    fi

  else
    # Forward the entire private subnet.
    forward="domain"
  fi


  if [ -n "$forward" ] ; then
    for subnet in $subnets ; do
      validip4=$( valid_subnet4 $subnet )
      validip6=$( valid_subnet6 $subnet )
      privateip=$( private_subnet $subnet )


      if [ "$validip4" = "ok" -a "$dhcpv4" != "disable" ] ; then
        if [ "$forward" = "domain" ] ; then
          arpa=$( domain_ptr_ip4 "$subnet" )
        else
          arpa=$( host_ptr_ip4 "$subnet" )
        fi

      elif [ "$validip6" = "ok" -a "$dhcpv6" != "disable" ] ; then
        if [ "$forward" = "domain" ] ; then
          arpa=$( domain_ptr_ip6 "$subnet" )
        else
          arpa=$( host_ptr_ip6 "$subnet" )
        fi

      else
        arpa=""
      fi


      if [ -n "$arpa" ] ; then
        if [ "$privateip" = "ok" ] ; then
          {
            # This creates ARPA local zone privledges
            echo "  local-zone: \"$arpa.\" transparent"
            echo "  domain-insecure: \"$arpa\""
            echo
          } >> $UNBOUND_CONFFILE
        fi


        UNBOUND_TXT_FWD_ZONE="$UNBOUND_TXT_FWD_ZONE $arpa"
      fi
    done
  fi
}

##############################################################################

dnsmasq_forward_zone() {
  if [ -n "$UNBOUND_N_FWD_PORTS" -a -n "$UNBOUND_TXT_FWD_ZONE" ] ; then
    for fwd_domain in $UNBOUND_TXT_FWD_ZONE ; do
      {
        # This is derived of dnsmasq_local_zone/arpa
        # but forward: clauses need to be seperate
        echo "forward-zone:"
        echo "  name: \"$fwd_domain.\""

        for port in $UNBOUND_N_FWD_PORTS ; do
          echo "  forward-addr: 127.0.0.1@$port"
        done

        echo
      } >> $UNBOUND_CONFFILE
    done
  fi
}

##############################################################################

dnsmasq_link() {
  # Forward to dnsmasq on same host for DHCP lease hosts
  echo "  do-not-query-localhost: no" >> $UNBOUND_CONFFILE
  # Look at dnsmasq settings
  config_load dhcp
  # Zone for DHCP / SLAAC-PING DOMAIN
  config_foreach dnsmasq_local_zone dnsmasq
  # Zone for DHCP / SLAAC-PING ARPA
  config_foreach dnsmasq_local_arpa dhcp
  # Now create ALL seperate forward: clauses
  dnsmasq_forward_zone
}

##############################################################################

