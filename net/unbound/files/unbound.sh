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
# This builds the basic UCI components currently supported for Unbound. It is
# intentionally NOT comprehensive and bundles a lot of options. The UCI is to
# be a simpler presentation of the total Unbound conf set.
#
##############################################################################

UNBOUND_B_CONTROL=0
UNBOUND_B_SLAAC6_MAC=0
UNBOUND_B_DNSSEC=0
UNBOUND_B_DNS64=0
UNBOUND_B_GATE_NAME=0
UNBOUND_B_HIDE_BIND=1
UNBOUND_B_LOCL_BLCK=0
UNBOUND_B_LOCL_SERV=1
UNBOUND_B_MAN_CONF=0
UNBOUND_B_NTP_BOOT=1
UNBOUND_B_PRIV_BLCK=1
UNBOUND_B_QUERY_MIN=0
UNBOUND_B_QRY_MINST=0

UNBOUND_D_DOMAIN_TYPE=static
UNBOUND_D_DHCP_LINK=none
UNBOUND_D_LAN_FQDN=0
UNBOUND_D_PROTOCOL=mixed
UNBOUND_D_RESOURCE=small
UNBOUND_D_RECURSION=passive
UNBOUND_D_WAN_FQDN=0

UNBOUND_IP_DNS64="64:ff9b::/96"

UNBOUND_N_EDNS_SIZE=1280
UNBOUND_N_FWD_PORTS=""
UNBOUND_N_RX_PORT=53
UNBOUND_N_ROOT_AGE=9

UNBOUND_TTL_MIN=120

UNBOUND_TXT_DOMAIN=lan
UNBOUND_TXT_FWD_ZONE=""
UNBOUND_TXT_HOSTNAME=thisrouter

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
UNBOUND_TIMEFILE=$UNBOUND_VARDIR/unbound.time

##############################################################################

UNBOUND_ANCHOR=/usr/sbin/unbound-anchor
UNBOUND_CONTROL=/usr/sbin/unbound-control
UNBOUND_CONTROL_CFG="$UNBOUND_CONTROL -c $UNBOUND_CONFFILE"

##############################################################################

. /lib/functions.sh
. /lib/functions/network.sh

. $UNBOUND_LIBDIR/dnsmasq.sh
. $UNBOUND_LIBDIR/iptools.sh
. $UNBOUND_LIBDIR/rootzone.sh

##############################################################################

copy_dash_update() {
  # TODO: remove this function and use builtins when this issues is resovled.
  # Due to OpenWrt/LEDE divergence "cp -u" isn't yet universally available.
  local filetime keeptime


  if [ -f $UNBOUND_KEYFILE.keep ] ; then
    # root.key.keep is reused if newest
    filetime=$( date -r $UNBOUND_KEYFILE +%s )
    keeptime=$( date -r $UNBOUND_KEYFILE.keep +%s )


    if [ $keeptime -gt $filetime ] ; then
      cp $UNBOUND_KEYFILE.keep $UNBOUND_KEYFILE
    fi


    rm -f $UNBOUND_KEYFILE.keep
  fi
}

##############################################################################

create_interface_dns() {
  local cfg="$1"
  local ipcommand logint ignore ifname ifdashname
  local name names address addresses
  local ulaprefix if_fqdn host_fqdn mode mode_ptr

  # Create local-data: references for this hosts interfaces (router).
  config_get logint "$cfg" interface
  config_get_bool ignore "$cfg" ignore 0
  network_get_device ifname "$cfg"

  ifdashname="${ifname//./-}"
  ipcommand="ip -o address show $ifname"
  addresses="$($ipcommand | awk '/inet/{sub(/\/.*/,"",$4); print $4}')"
  ulaprefix="$(uci_get network @globals[0] ula_prefix)"
  host_fqdn="$UNBOUND_TXT_HOSTNAME.$UNBOUND_TXT_DOMAIN"
  if_fqdn="$ifdashname.$host_fqdn"


  if [ -z "${ulaprefix%%:/*}" ] ; then
    # Nonsense so this option isn't globbed below
    ulaprefix="fdno:such:addr::/48"
  fi


  if [ "$ignore" -gt 0 ] ; then
    mode="$UNBOUND_D_WAN_FQDN"
  else
    mode="$UNBOUND_D_LAN_FQDN"
  fi


  case "$mode" in
  3)
    mode_ptr="$host_fqdn"
    names="$host_fqdn  $UNBOUND_TXT_HOSTNAME"
    ;;

  4)
    if [ -z "$ifdashname" ] ; then
      # race conditions at init can rarely cause a blank device return
      # the record format is invalid and Unbound won't load the conf file
      mode_ptr="$host_fqdn"
      names="$host_fqdn  $UNBOUND_TXT_HOSTNAME"
    else
      mode_ptr="$if_fqdn"
      names="$if_fqdn  $host_fqdn  $UNBOUND_TXT_HOSTNAME"
    fi
    ;;

  *)
    mode_ptr="$UNBOUND_TXT_HOSTNAME"
    names="$UNBOUND_TXT_HOSTNAME"
    ;;
  esac


  if [ "$mode" -gt 1 ] ; then
    {
      for address in $addresses ; do
        case $address in
        fe80:*|169.254.*)
          echo "  # note link address $address"
          ;;

        [1-9a-f]*:*[0-9a-f])
          # GA and ULA IP6 for HOST IN AAA records (ip command is robust)
          for name in $names ; do
            echo "  local-data: \"$name. 120 IN AAAA $address\""
          done
          echo "  local-data-ptr: \"$address 120 $mode_ptr\""
          ;;

        [1-9]*.*[0-9])
          # Old fashioned HOST IN A records
          for name in $names ; do
            echo "  local-data: \"$name. 120 IN A $address\""
          done
          echo "  local-data-ptr: \"$address 120 $mode_ptr\""
          ;;
        esac
      done
      echo
    } >> $UNBOUND_CONFFILE

  elif [ "$mode" -gt 0 ] ; then
    {
      for address in $addresses ; do
        case $address in
        fe80:*|169.254.*)
          echo "  # note link address $address"
          ;;

        "${ulaprefix%%:/*}"*)
          # Only this networks ULA and only hostname
          echo "  local-data: \"$UNBOUND_TXT_HOSTNAME. 120 IN AAAA $address\""
          echo "  local-data-ptr: \"$address 120 $UNBOUND_TXT_HOSTNAME\""
          ;;

        [1-9]*.*[0-9])
          echo "  local-data: \"$UNBOUND_TXT_HOSTNAME. 120 IN A $address\""
          echo "  local-data-ptr: \"$address 120 $UNBOUND_TXT_HOSTNAME\""
          ;;
        esac
      done
      echo
    } >> $UNBOUND_CONFFILE
  fi
}

##############################################################################

create_access_control() {
  local cfg="$1"
  local subnets subnets4 subnets6
  local validip4 validip6

  network_get_subnets  subnets4 "$cfg"
  network_get_subnets6 subnets6 "$cfg"
  subnets="$subnets4 $subnets6"


  if [ -n "$subnets" ] ; then
    for subnet in $subnets ; do
      validip4=$( valid_subnet4 $subnet )
      validip6=$( valid_subnet6 $subnet )


      if [ "$validip4" = "ok" -o "$validip6" = "ok" ] ; then
        # For each "network" UCI add "access-control:" white list for queries
        echo "  access-control: $subnet allow" >> $UNBOUND_CONFFILE
      fi
    done
  fi
}

##############################################################################

create_domain_insecure() {
  echo "  domain-insecure: \"$1\"" >> $UNBOUND_CONFFILE
}

##############################################################################

unbound_mkdir() {
  local resolvsym=0
  local dhcp_origin=$( uci get dhcp.@odhcpd[0].leasefile )
  local dhcp_dir=$( dirname "$dhcp_origin" )
  local filestuff


  if [ ! -x /usr/sbin/dnsmasq -o ! -x /etc/init.d/dnsmasq ] ; then
    resolvsym=1
  else
    /etc/init.d/dnsmasq enabled || resolvsym=1
  fi


  if [ "$resolvsym" -gt 0 ] ; then
    rm -f /tmp/resolv.conf


    {
      # Set resolver file to local but not if /etc/init.d/dnsmasq will do it.
      echo "nameserver 127.0.0.1"
      echo "nameserver ::1"
      echo "search $UNBOUND_TXT_DOMAIN"
    } > /tmp/resolv.conf
  fi


  if [ "$UNBOUND_D_DHCP_LINK" = "odhcpd" -a ! -d "$dhcp_dir" ] ; then
    # make sure odhcpd has a directory to write (not done itself, yet)
    mkdir -p "$dhcp_dir"
  fi


  if [ -f $UNBOUND_KEYFILE ] ; then
    filestuff=$( cat $UNBOUND_KEYFILE )


    case "$filestuff" in
      *"state=2 [  VALID  ]"*)
        # Lets not lose RFC 5011 tracking if we don't have to
        cp -p $UNBOUND_KEYFILE $UNBOUND_KEYFILE.keep
        ;;
    esac
  fi


  # Blind copy /etc/ to /var/lib/
  mkdir -p $UNBOUND_VARDIR
  rm -f $UNBOUND_VARDIR/dhcp_*
  touch $UNBOUND_CONFFILE
  touch $UNBOUND_SRV_CONF
  touch $UNBOUND_EXT_CONF
  cp -p /etc/unbound/* $UNBOUND_VARDIR/


  if [ ! -f $UNBOUND_HINTFILE ] ; then
    if [ -f /usr/share/dns/root.hints ] ; then
      # Debian-like package dns-root-data
      cp -p /usr/share/dns/root.hints $UNBOUND_HINTFILE

    elif [ ! -f "$UNBOUND_TIMEFILE" ] ; then
      logger -t unbound -s "iterator will use built-in root hints"
    fi
  fi


  if [ ! -f $UNBOUND_KEYFILE ] ; then
    if [ -f /usr/share/dns/root.key ] ; then
      # Debian-like package dns-root-data
      cp -p /usr/share/dns/root.key $UNBOUND_KEYFILE

    elif [ -x $UNBOUND_ANCHOR ] ; then
      $UNBOUND_ANCHOR -a $UNBOUND_KEYFILE

    elif [ ! -f "$UNBOUND_TIMEFILE" ] ; then
      logger -t unbound -s "validator will use built-in trust anchor"
    fi
  fi


  copy_dash_update


  # Ensure access and prepare to jail
  chown -R unbound:unbound $UNBOUND_VARDIR
  chmod 775 $UNBOUND_VARDIR
  chmod 664 $UNBOUND_VARDIR/*
}

##############################################################################

unbound_control() {
  if [ "$UNBOUND_B_CONTROL" -gt 0 ] ; then
    {
      # Enable remote control tool, but only at local host for security
      # You can hand write fancier encrypted access with /etc/..._ext.conf
      echo "remote-control:"
      echo "  control-enable: yes"
      echo "  control-use-cert: no"
      echo "  control-interface: 127.0.0.1"
      echo "  control-interface: ::1"
      echo
    } >> $UNBOUND_CONFFILE
  fi


  {
    # Amend your own extended clauses here like forward zones or disable
    # above (local, no encryption) and amend your own remote encrypted control
    echo
    echo "include: $UNBOUND_EXT_CONF" >> $UNBOUND_CONFFILE
    echo
  } >> $UNBOUND_CONFFILE
}

##############################################################################

unbound_conf() {
  local cfg="$1"
  local rt_mem rt_conn modulestring


  {
    # Make fresh conf file
    echo "# $UNBOUND_CONFFILE generated by UCI $( date )"
    echo
  } > $UNBOUND_CONFFILE


  {
    # No threading
    echo "server:"
    echo "  username: unbound"
    echo "  num-threads: 1"
    echo "  msg-cache-slabs: 1"
    echo "  rrset-cache-slabs: 1"
    echo "  infra-cache-slabs: 1"
    echo "  key-cache-slabs: 1"
    echo
  } >> $UNBOUND_CONFFILE


  {
    # Logging
    echo "  verbosity: 1"
    echo "  statistics-interval: 0"
    echo "  statistics-cumulative: no"
    echo "  extended-statistics: no"
    echo
  } >> $UNBOUND_CONFFILE


  {
    # Interfaces (access contol "option local_service")
    echo "  interface: 0.0.0.0"
    echo "  interface: ::0"
    echo "  outgoing-interface: 0.0.0.0"
    echo "  outgoing-interface: ::0"
    echo
  } >> $UNBOUND_CONFFILE


  case "$UNBOUND_D_PROTOCOL" in
    ip4_only)
      {
        echo "  do-ip4: yes"
        echo "  do-ip6: no"
      } >> $UNBOUND_CONFFILE
      ;;

    ip6_only)
      {
        echo "  do-ip4: no"
        echo "  do-ip6: yes"
      } >> $UNBOUND_CONFFILE
      ;;

    ip6_prefer)
      {
        echo "  do-ip4: yes"
        echo "  do-ip6: yes"
        echo "  prefer-ip6: yes"
      } >> $UNBOUND_CONFFILE
      ;;

    *)
      {
        echo "  do-ip4: yes"
        echo "  do-ip6: yes"
      } >> $UNBOUND_CONFFILE
      ;;
  esac


  {
    # protocol level tuning
    echo "  edns-buffer-size: $UNBOUND_N_EDNS_SIZE"
    echo "  msg-buffer-size: 8192"
    echo "  port: $UNBOUND_N_RX_PORT"
    echo "  outgoing-port-permit: 10240-65535"
    echo
  } >> $UNBOUND_CONFFILE


  {
    # Other harding and options for an embedded router
    echo "  harden-short-bufsize: yes"
    echo "  harden-large-queries: yes"
    echo "  harden-glue: yes"
    echo "  harden-below-nxdomain: no"
    echo "  harden-referral-path: no"
    echo "  use-caps-for-id: no"
    echo
  } >> $UNBOUND_CONFFILE


  {
    # Default Files
    echo "  use-syslog: yes"
    echo "  chroot: \"$UNBOUND_VARDIR\""
    echo "  directory: \"$UNBOUND_VARDIR\""
    echo "  pidfile: \"$UNBOUND_PIDFILE\""
  } >> $UNBOUND_CONFFILE


  if [ -f "$UNBOUND_HINTFILE" ] ; then
    # Optional hints if found
    echo "  root-hints: \"$UNBOUND_HINTFILE\"" >> $UNBOUND_CONFFILE
  fi


  if [ "$UNBOUND_B_DNSSEC" -gt 0 -a -f "$UNBOUND_KEYFILE" ] ; then
    {
      echo "  auto-trust-anchor-file: \"$UNBOUND_KEYFILE\""
      echo
    } >> $UNBOUND_CONFFILE

  else
    echo >> $UNBOUND_CONFFILE
  fi


  case "$UNBOUND_D_RESOURCE" in
    # Tiny - Unbound's recommended cheap hardware config
    tiny)   rt_mem=1  ; rt_conn=1 ;;
    # Small - Half RRCACHE and open ports
    small)  rt_mem=8  ; rt_conn=5 ;;
    # Medium - Nearly default but with some added balancintg
    medium) rt_mem=16 ; rt_conn=10 ;;
    # Large - Double medium
    large)  rt_mem=32 ; rt_conn=10 ;;
    # Whatever unbound does
    *) rt_mem=0 ; rt_conn=0 ;;
  esac


  if [ "$rt_mem" -gt 0 ] ; then
    {
      # Set memory sizing parameters
      echo "  outgoing-range: $(($rt_conn*64))"
      echo "  num-queries-per-thread: $(($rt_conn*32))"
      echo "  outgoing-num-tcp: $(($rt_conn))"
      echo "  incoming-num-tcp: $(($rt_conn))"
      echo "  rrset-cache-size: $(($rt_mem*256))k"
      echo "  msg-cache-size: $(($rt_mem*128))k"
      echo "  key-cache-size: $(($rt_mem*128))k"
      echo "  neg-cache-size: $(($rt_mem*64))k"
      echo "  infra-cache-numhosts: $(($rt_mem*256))"
      echo
    } >> $UNBOUND_CONFFILE

  elif [ ! -f "$UNBOUND_TIMEFILE" ] ; then
    logger -t unbound -s "default memory resource consumption"
  fi

  # Assembly of module-config: options is tricky; order matters
  modulestring="iterator"


  if [ "$UNBOUND_B_DNSSEC" -gt 0 ] ; then
    if [ ! -f "$UNBOUND_TIMEFILE" -a "$UNBOUND_B_NTP_BOOT" -gt 0 ] ; then
      # DNSSEC chicken and egg with getting NTP time
      echo "  val-override-date: -1" >> $UNBOUND_CONFFILE
    fi


    {
      echo "  harden-dnssec-stripped: yes"
      echo "  val-clean-additional: yes"
      echo "  ignore-cd-flag: yes"
    } >> $UNBOUND_CONFFILE


    modulestring="validator $modulestring"
  fi


  if [ "$UNBOUND_B_DNS64" -gt 0 ] ; then
    echo "  dns64-prefix: $UNBOUND_IP_DNS64" >> $UNBOUND_CONFFILE

    modulestring="dns64 $modulestring"
  fi


  {
    # Print final module string
    echo "  module-config: \"$modulestring\""
    echo
  }  >> $UNBOUND_CONFFILE


  if [ "$UNBOUND_B_QRY_MINST" -gt 0 -a "$UNBOUND_B_QUERY_MIN" -gt 0 ] ; then
    {
      # Some query privacy but "strict" will break some name servers
      echo "  qname-minimisation: yes"
      echo "  qname-minimisation-strict: yes"
    } >> $UNBOUND_CONFFILE

  elif [ "$UNBOUND_B_QUERY_MIN" -gt 0 ] ; then
    # Minor improvement on query privacy
    echo "  qname-minimisation: yes" >> $UNBOUND_CONFFILE

  else
    echo "  qname-minimisation: no" >> $UNBOUND_CONFFILE
  fi


  case "$UNBOUND_D_RECURSION" in
    passive)
      {
        echo "  prefetch: no"
        echo "  prefetch-key: no"
        echo "  target-fetch-policy: \"0 0 0 0 0\""
        echo
      } >> $UNBOUND_CONFFILE
      ;;

    aggressive)
      {
        echo "  prefetch: yes"
        echo "  prefetch-key: yes"
        echo "  target-fetch-policy: \"3 2 1 0 0\""
        echo
      } >> $UNBOUND_CONFFILE
      ;;

    *)
      if [ ! -f "$UNBOUND_TIMEFILE" ] ; then
        logger -t unbound -s "default recursion configuration"
      fi
      ;;
  esac


  {
    # Reload records more than 10 hours old
    # DNSSEC 5 minute bogus cool down before retry
    # Adaptive infrastructure info kept for 15 minutes
    echo "  cache-min-ttl: $UNBOUND_TTL_MIN"
    echo "  cache-max-ttl: 36000"
    echo "  val-bogus-ttl: 300"
    echo "  infra-host-ttl: 900"
    echo
  } >> $UNBOUND_CONFFILE


  if [ "$UNBOUND_B_HIDE_BIND" -gt 0 ] ; then
    {
      # Block server id and version DNS TXT records
      echo "  hide-identity: yes"
      echo "  hide-version: yes"
      echo
    } >> $UNBOUND_CONFFILE
  fi


  if [ "$UNBOUND_B_PRIV_BLCK" -gt 0 ] ; then
    {
      # Remove _upstream_ or global reponses with private addresses.
      # Unbounds own "local zone" and "forward zone" may still use these.
      # RFC1918, RFC3927, RFC4291, RFC6598, RFC6890
      echo "  private-address: 10.0.0.0/8"
      echo "  private-address: 100.64.0.0/10"
      echo "  private-address: 169.254.0.0/16"
      echo "  private-address: 172.16.0.0/12"
      echo "  private-address: 192.168.0.0/16"
      echo "  private-address: fc00::/8"
      echo "  private-address: fd00::/8"
      echo "  private-address: fe80::/10"
    } >> $UNBOUND_CONFFILE
  fi


  if [ "$UNBOUND_B_LOCL_BLCK" -gt 0 ] ; then
    {
      # Remove DNS reponses from upstream with loopback IP
      # Black hole DNS method for ad blocking, so consider...
      echo "  private-address: 127.0.0.0/8"
      echo "  private-address: ::1/128"
      echo
    } >> $UNBOUND_CONFFILE

  else
    echo >> $UNBOUND_CONFFILE
  fi


  # Except and accept domains as insecure (DNSSEC); work around broken domains
  config_list_foreach "$cfg" "domain_insecure" create_domain_insecure
  echo >> $UNBOUND_CONFFILE
}

##############################################################################

unbound_access() {
  # TODO: Unbound 1.6.0 added "tags" and "views", so we can add tags to
  # each access-control IP block, and then divert access.
  # -- "guest" WIFI will not be allowed to see local zone data
  # -- "child" LAN can black whole a list of domains to http~deadpixel


  if [ "$UNBOUND_B_LOCL_SERV" -gt 0 ] ; then
    # Only respond to queries from which this device has an interface.
    # Prevent DNS amplification attacks by not responding to the universe.
    config_load network
    config_foreach create_access_control interface


    {
      echo "  access-control: 127.0.0.0/8 allow"
      echo "  access-control: ::1/128 allow"
      echo "  access-control: fe80::/10 allow"
      echo
    } >> $UNBOUND_CONFFILE

  else
    {
      echo "  access-control: 0.0.0.0/0 allow"
      echo "  access-control: ::0/0 allow"
      echo
    } >> $UNBOUND_CONFFILE
  fi


  {
    # Amend your own "server:" stuff here
    echo "  include: $UNBOUND_SRV_CONF"
    echo
  } >> $UNBOUND_CONFFILE
}

##############################################################################

unbound_adblock() {
  # TODO: Unbound 1.6.0 added "tags" and "views"; lets work with adblock team
  local adb_enabled adb_file

  if [ ! -x /usr/bin/adblock.sh -o ! -x /etc/init.d/adblock ] ; then
    adb_enabled=0
  else
    /etc/init.d/adblock enabled && adb_enabled=1 || adb_enabled=0
  fi


  if [ "$adb_enabled" -gt 0 ] ; then
    {
      # Pull in your selected openwrt/pacakges/net/adblock generated lists
      for adb_file in $UNBOUND_VARDIR/adb_list.* ; do
        echo "  include: $adb_file"
      done
      echo
    } >> $UNBOUND_CONFFILE
  fi
}

##############################################################################

unbound_hostname() {
  if [ -n "$UNBOUND_TXT_DOMAIN" ] ; then
    {
      # TODO: Unbound 1.6.0 added "tags" and "views" and we could make
      # domains by interface to prevent DNS from "guest" to "home"
      echo "  local-zone: $UNBOUND_TXT_DOMAIN. $UNBOUND_D_DOMAIN_TYPE"
      echo "  domain-insecure: $UNBOUND_TXT_DOMAIN"
      echo "  private-domain: $UNBOUND_TXT_DOMAIN"
      echo
      echo "  local-zone: $UNBOUND_TXT_HOSTNAME. $UNBOUND_D_DOMAIN_TYPE"
      echo "  domain-insecure: $UNBOUND_TXT_HOSTNAME"
      echo "  private-domain: $UNBOUND_TXT_HOSTNAME"
      echo
    } >> $UNBOUND_CONFFILE


    case "$UNBOUND_D_DOMAIN_TYPE" in
    deny|inform_deny|refuse|static)
      {
        # avoid upstream involvement in RFC6762 like responses (link only)
        echo "  local-zone: local. $UNBOUND_D_DOMAIN_TYPE"
        echo "  domain-insecure: local"
        echo "  private-domain: local"
        echo
      } >> $UNBOUND_CONFFILE
      ;;
    esac


    if [ "$UNBOUND_D_LAN_FQDN" -gt 0 -o "$UNBOUND_D_WAN_FQDN" -gt 0 ] ; then
      config_load dhcp
      config_foreach create_interface_dns dhcp
    fi


    if [ -f "$UNBOUND_DHCP_CONF" ] ; then
      {
        # Seed DHCP records because dhcp scripts trigger externally
        # Incremental Unbound restarts may drop unbound-control add records
        echo "  include: $UNBOUND_DHCP_CONF"
        echo
      } >> $UNBOUND_CONFFILE
    fi
  fi
}

##############################################################################

unbound_uci() {
  local cfg="$1"
  local dnsmasqpath hostnm

  hostnm="$(uci_get system.@system[0].hostname | awk '{print tolower($0)}')"
  UNBOUND_TXT_HOSTNAME=${hostnm:-thisrouter}

  config_get_bool UNBOUND_B_SLAAC6_MAC "$cfg" dhcp4_slaac6 0
  config_get_bool UNBOUND_B_DNS64      "$cfg" dns64 0
  config_get_bool UNBOUND_B_HIDE_BIND  "$cfg" hide_binddata 1
  config_get_bool UNBOUND_B_LOCL_SERV  "$cfg" localservice 1
  config_get_bool UNBOUND_B_MAN_CONF   "$cfg" manual_conf 0
  config_get_bool UNBOUND_B_QUERY_MIN  "$cfg" query_minimize 0
  config_get_bool UNBOUND_B_QRY_MINST  "$cfg" query_min_strict 0
  config_get_bool UNBOUND_B_PRIV_BLCK  "$cfg" rebind_protection 1
  config_get_bool UNBOUND_B_LOCL_BLCK  "$cfg" rebind_localhost 0
  config_get_bool UNBOUND_B_CONTROL    "$cfg" unbound_control 0
  config_get_bool UNBOUND_B_DNSSEC     "$cfg" validator 0
  config_get_bool UNBOUND_B_NTP_BOOT   "$cfg" validator_ntp 1

  config_get UNBOUND_IP_DNS64    "$cfg" dns64_prefix "64:ff9b::/96"

  config_get UNBOUND_N_EDNS_SIZE "$cfg" edns_size 1280
  config_get UNBOUND_N_RX_PORT   "$cfg" listen_port 53
  config_get UNBOUND_N_ROOT_AGE  "$cfg" root_age 9

  config_get UNBOUND_D_DOMAIN_TYPE "$cfg" domain_type static
  config_get UNBOUND_D_DHCP_LINK   "$cfg" dhcp_link none
  config_get UNBOUND_D_LAN_FQDN    "$cfg" add_local_fqdn 0
  config_get UNBOUND_D_PROTOCOL    "$cfg" protocol mixed
  config_get UNBOUND_D_RECURSION   "$cfg" recursion passive
  config_get UNBOUND_D_RESOURCE    "$cfg" resource small
  config_get UNBOUND_D_WAN_FQDN    "$cfg" add_wan_fqdn 0

  config_get UNBOUND_TTL_MIN     "$cfg" ttl_min 120
  config_get UNBOUND_TXT_DOMAIN  "$cfg" domain lan


  if [ "$UNBOUND_D_DHCP_LINK" = "none" ] ; then
    config_get_bool UNBOUND_B_DNSMASQ   "$cfg" dnsmasq_link_dns 0


    if [ "$UNBOUND_B_DNSMASQ" -gt 0 ] ; then
      UNBOUND_D_DHCP_LINK=dnsmasq
      
      
      if [ ! -f "$UNBOUND_TIMEFILE" ] ; then
        logger -t unbound -s "Please use 'dhcp_link' selector instead"
      fi
    fi
  fi


  if [ "$UNBOUND_D_DHCP_LINK" = "dnsmasq" ] ; then
    if [ ! -x /usr/sbin/dnsmasq -o ! -x /etc/init.d/dnsmasq ] ; then
      UNBOUND_D_DHCP_LINK=none
    else
      /etc/init.d/dnsmasq enabled || UNBOUND_D_DHCP_LINK=none
    fi


    if [ "$UNBOUND_D_DHCP_LINK" = "none" -a ! -f "$UNBOUND_TIMEFILE" ] ; then
      logger -t unbound -s "cannot forward to dnsmasq"
    fi
  fi


  if [ "$UNBOUND_D_DHCP_LINK" = "odhcpd" ] ; then
    if [ ! -x /usr/sbin/odhcpd -o ! -x /etc/init.d/odhcpd ] ; then
      UNBOUND_D_DHCP_LINK=none
    else
      /etc/init.d/odhcpd enabled || UNBOUND_D_DHCP_LINK=none
    fi


    if [ "$UNBOUND_D_DHCP_LINK" = "none" -a ! -f "$UNBOUND_TIMEFILE" ] ; then
      logger -t unbound -s "cannot receive records from odhcpd"
    fi
  fi


  if [ "$UNBOUND_N_EDNS_SIZE" -lt 512 \
    -o 4096 -lt "$UNBOUND_N_EDNS_SIZE" ] ; then
    # exceeds range, back to default
    UNBOUND_N_EDNS_SIZE=1280
  fi


  if [ "$UNBOUND_N_RX_PORT" -lt 1024 \
    -o 10240 -lt "$UNBOUND_N_RX_PORT" ] ; then
    # special port or in 5 digits, back to default
    UNBOUND_N_RX_PORT=53
  fi


  if [ "$UNBOUND_TTL_MIN" -gt 1800 ] ; then
    # that could have had awful side effects
    UNBOUND_TTL_MIN=300
  fi
}

##############################################################################

unbound_start() {
  config_load unbound
  config_foreach unbound_uci unbound
  unbound_mkdir


  if [ "$UNBOUND_B_MAN_CONF" -eq 0 ] ; then
    unbound_conf
    unbound_access
    unbound_adblock

    if [ "$UNBOUND_D_DHCP_LINK" = "dnsmasq" ] ; then
      dnsmasq_link
    else
      unbound_hostname
    fi

    unbound_control
  fi
}

##############################################################################

unbound_stop() {
  local resolvsym=0

  rootzone_update


  if [ ! -x /usr/sbin/dnsmasq -o ! -x /etc/init.d/dnsmasq ] ; then
    resolvsym=1
  else
    /etc/init.d/dnsmasq enabled || resolvsym=1
  fi


  if [ "$resolvsym" -gt 0 ] ; then
    # set resolver file to normal, but don't stomp on dnsmasq
    rm -f /tmp/resolv.conf
    ln -s /tmp/resolv.conf.auto /tmp/resolv.conf
  fi
}

##############################################################################

