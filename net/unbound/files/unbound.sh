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
# Unbound is a full featured recursive server with many options. The UCI
# provided tries to simplify and bundle options. This should make Unbound
# easier to deploy. Even light duty routers may resolve recursively instead of
# depending on a stub with the ISP. The UCI also attempts to replicate dnsmasq
# features as used in base LEDE/OpenWrt. If there is a desire for more
# detailed tuning, then manual conf file overrides are also made available.
#
##############################################################################

UNBOUND_B_SLAAC6_MAC=0
UNBOUND_B_DNSSEC=0
UNBOUND_B_DNS64=0
UNBOUND_B_EXT_STATS=0
UNBOUND_B_GATE_NAME=0
UNBOUND_B_HIDE_BIND=1
UNBOUND_B_LOCL_BLCK=0
UNBOUND_B_LOCL_SERV=1
UNBOUND_B_MAN_CONF=0
UNBOUND_B_NTP_BOOT=1
UNBOUND_B_QUERY_MIN=0
UNBOUND_B_QRY_MINST=0

UNBOUND_D_CONTROL=0
UNBOUND_D_DOMAIN_TYPE=static
UNBOUND_D_DHCP_LINK=none
UNBOUND_D_EXTRA_DNS=0
UNBOUND_D_LAN_FQDN=0
UNBOUND_D_PRIV_BLCK=1
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

UNBOUND_LIST_FORWARD=""
UNBOUND_LIST_INSECURE=""
UNBOUND_LIST_PRV_SUBNET=""

##############################################################################

# keep track of local-domain: assignments during inserted resource records
UNBOUND_LIST_DOMAINS=""

##############################################################################

. /lib/functions.sh
. /lib/functions/network.sh

. /usr/lib/unbound/defaults.sh
. /usr/lib/unbound/dnsmasq.sh
. /usr/lib/unbound/iptools.sh
. /usr/lib/unbound/rootzone.sh

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
  addresses=$( $ipcommand | awk '/inet/{sub(/\/.*/,"",$4); print $4}' )
  ulaprefix=$( uci_get network.@globals[0].ula_prefix )
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

create_local_zone() {
  local target="$1"
  local partial domain found


  if [ -n "$UNBOUND_LIST_DOMAINS" ] ; then
    for domain in $UNBOUND_LIST_DOMAINS ; do
      case $target in
      *"${domain}")
        found=1
        break
        ;;

      [A-Za-z0-9]*.[A-Za-z0-9]*)
        found=0
        ;;

      *) # no dots
        found=1
        break
        ;;
      esac
    done
  else
    found=0
  fi


  if [ $found -eq 0 ] ; then
    # New Zone! Bundle local-zones: by first two name tiers "abcd.tld."
    partial=$( echo "$target" | awk -F. '{ j=NF ; i=j-1; print $i"."$j }' )
    UNBOUND_LIST_DOMAINS="$UNBOUND_LIST_DOMAINS $partial"
    echo "  local-zone: $partial. transparent" >> $UNBOUND_CONFFILE
  fi
}

##############################################################################

create_host_record() {
  local cfg="$1"
  local ip name

  # basefiles dhcp "domain" clause which means host A, AAAA, and PRT record
  config_get ip   "$cfg" ip
  config_get name "$cfg" name


  if [ -n "$name" -a -n "$ip" ] ; then
    create_local_zone "$name"

    {
      case $ip in
      fe80:*|169.254.*)
        echo "  # note link address $ip for host $name"
        ;;

      [1-9a-f]*:*[0-9a-f])
        echo "  local-data: \"$name. 120 IN AAAA $ip\""
        echo "  local-data-ptr: \"$ip 120 $name\""
        ;;

      [1-9]*.*[0-9])
        echo "  local-data: \"$name. 120 IN A $ip\""
        echo "  local-data-ptr: \"$ip 120 $name\""
        ;;
      esac
    } >> $UNBOUND_CONFFILE
  fi
}

##############################################################################

create_mx_record() {
  local cfg="$1"
  local domain relay pref

  # Insert a static MX record
  config_get domain "$cfg" domain
  config_get relay  "$cfg" relay
  config_get pref   "$cfg" pref 10


  if [ -n "$domain" -a -n "$relay" ] ; then
    create_local_zone "$domain"
    echo "  local-data: \"$domain. 120 IN MX $pref $relay.\"" \
          >> $UNBOUND_CONFFILE
  fi
}

##############################################################################

create_srv_record() {
  local cfg="$1"
  local srv target port class weight

  # Insert a static SRV record such as SIP server
  config_get srv    "$cfg" srv
  config_get target "$cfg" target
  config_get port   "$cfg" port
  config_get class  "$cfg" class 10
  config_get weight "$cfg" weight 10


  if [ -n "$srv" -a -n "$target" -a -n "$port" ] ; then
    create_local_zone "$srv"
    echo "  local-data: \"$srv. 120 IN SRV $class $weight $port $target.\"" \
          >> $UNBOUND_CONFFILE
  fi
}

##############################################################################

create_cname_record() {
  local cfg="$1"
  local cname target

  # Insert static CNAME record
  config_get cname  "$cfg" cname
  config_get target "$cfg" target


  if [ -n "$cname" -a -n "$target" ] ; then
    create_local_zone "$cname"
    echo "  local-data: \"$cname. 120 IN CNAME $target.\"" >> $UNBOUND_CONFFILE
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

bundle_domain_forward() {
  UNBOUND_LIST_FORWARD="$UNBOUND_LIST_FORWARD $1"
}

##############################################################################

bundle_domain_insecure() {
  UNBOUND_LIST_INSECURE="$UNBOUND_LIST_INSECURE $1"
}

##############################################################################

bundle_private_interface() {
  local ipcommand ifsubnet ifsubnets ifname

  network_get_device ifname $1

  if [ -n "$ifname" ] ; then
    ipcommand="ip -6 -o address show $ifname"
    ifsubnets=$( $ipcommand | awk '/inet6/{ print $4 }' )


    if [ -n "$ifsubnets" ] ; then
      for ifsubnet in $ifsubnets ; do
        case $ifsubnet in
        [1-9]*:*[0-9a-f])
          # Special GLA protection for local block; ULA protected as a catagory
          UNBOUND_LIST_PRV_SUBNET="$UNBOUND_LIST_PRV_SUBNET $ifsubnet" ;;
        esac
      done
    fi
  fi
}

##############################################################################

unbound_mkdir() {
  local dhcp_origin=$( uci_get dhcp.@odhcpd[0].leasefile )
  local dhcp_dir=$( dirname $dhcp_origin )
  local filestuff


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
  chmod 755 $UNBOUND_VARDIR
  chmod 644 $UNBOUND_VARDIR/*


  if [ -f $UNBOUND_CTLKEY_FILE -o -f $UNBOUND_CTLPEM_FILE \
    -o -f $UNBOUND_SRVKEY_FILE -o -f $UNBOUND_SRVPEM_FILE ] ; then
    # Keys (some) exist already; do not create new ones
    chmod 640 $UNBOUND_CTLKEY_FILE $UNBOUND_CTLPEM_FILE \
              $UNBOUND_SRVKEY_FILE $UNBOUND_SRVPEM_FILE

  elif [ -x /usr/sbin/unbound-control-setup ] ; then
    case "$UNBOUND_D_CONTROL" in
    [2-3])
      # unbound-control-setup for encrypt opt. 2 and 3, but not 4 "static"
      /usr/sbin/unbound-control-setup -d $UNBOUND_VARDIR

      chown -R unbound:unbound  $UNBOUND_CTLKEY_FILE $UNBOUND_CTLPEM_FILE \
                                $UNBOUND_SRVKEY_FILE $UNBOUND_SRVPEM_FILE

      chmod 640 $UNBOUND_CTLKEY_FILE $UNBOUND_CTLPEM_FILE \
                $UNBOUND_SRVKEY_FILE $UNBOUND_SRVPEM_FILE

      cp -p $UNBOUND_CTLKEY_FILE /etc/unbound/unbound_control.key
      cp -p $UNBOUND_CTLPEM_FILE /etc/unbound/unbound_control.pem
      cp -p $UNBOUND_SRVKEY_FILE /etc/unbound/unbound_server.key
      cp -p $UNBOUND_SRVPEM_FILE /etc/unbound/unbound_server.pem
      ;;
    esac
  fi
}

##############################################################################

unbound_control() {
  if [ "$UNBOUND_D_CONTROL" -gt 1 ] ; then
    if [ ! -f $UNBOUND_CTLKEY_FILE -o ! -f $UNBOUND_CTLPEM_FILE \
      -o ! -f $UNBOUND_SRVKEY_FILE -o ! -f $UNBOUND_SRVPEM_FILE ] ; then
      # Key files need to be present; if unbound-control-setup was found, then
      # they might have been made during unbound_makedir() above.
      UNBOUND_D_CONTROL=0
    fi
  fi


  case "$UNBOUND_D_CONTROL" in
  1)
    {
      # Local Host Only Unencrypted Remote Control
      echo "remote-control:"
      echo "  control-enable: yes"
      echo "  control-use-cert: no"
      echo "  control-interface: 127.0.0.1"
      echo "  control-interface: ::1"
      echo
    } >> $UNBOUND_CONFFILE
    ;;

  2)
    {
      # Local Host Only Encrypted Remote Control
      echo "remote-control:"
      echo "  control-enable: yes"
      echo "  control-use-cert: yes"
      echo "  control-interface: 127.0.0.1"
      echo "  control-interface: ::1"
      echo "  server-key-file: \"$UNBOUND_SRVKEY_FILE\""
      echo "  server-cert-file: \"$UNBOUND_SRVPEM_FILE\""
      echo "  control-key-file: \"$UNBOUND_CTLKEY_FILE\""
      echo "  control-cert-file: \"$UNBOUND_CTLPEM_FILE\""
      echo
    } >> $UNBOUND_CONFFILE
    ;;

  [3-4])
    {
      # Network Encrypted Remote Control
      # (3) may auto setup and (4) must have static key/pem files
      # TODO: add UCI list for interfaces to bind
      echo "remote-control:"
      echo "  control-enable: yes"
      echo "  control-use-cert: yes"
      echo "  control-interface: 0.0.0.0"
      echo "  control-interface: ::0"
      echo "  server-key-file: \"$UNBOUND_SRVKEY_FILE\""
      echo "  server-cert-file: \"$UNBOUND_SRVPEM_FILE\""
      echo "  control-key-file: \"$UNBOUND_CTLKEY_FILE\""
      echo "  control-cert-file: \"$UNBOUND_CTLPEM_FILE\""
      echo
    } >> $UNBOUND_CONFFILE
    ;;
  esac


  {
    # Amend your own extended clauses here like forward zones or disable
    # above (local, no encryption) and amend your own remote encrypted control
    echo
    echo "include: $UNBOUND_EXT_CONF" >> $UNBOUND_CONFFILE
    echo
  } >> $UNBOUND_CONFFILE
}

##############################################################################

unbound_forward() {
  local fdomain fresolver resolvers
  # Forward selected domains to the upstream (WAN) stub resolver. This may be
  # faster or local pool addresses to ISP service login page. This may keep
  # internal organization lookups, well, internal to the organization.


  if [ -n "$UNBOUND_LIST_FORWARD" ] ; then
    resolvers=$( grep nameserver /tmp/resolv.conf.auto | sed "s/nameserver//g" )


    if [ -n "$resolvers" ] ; then
      for fdomain in $UNBOUND_LIST_FORWARD ; do
        {
          echo "forward-zone:"
          echo "  name: \"$fdomain.\""
          for fresolver in $resolvers ; do
          echo "  forward-addr: $fresolver"
          done
          echo
        } >> $UNBOUND_CONFFILE
      done
    fi
  fi
}

##############################################################################

unbound_conf() {
  local rt_mem rt_conn modulestring domain ifsubnet

  # Make fresh conf file
  echo > $UNBOUND_CONFFILE


  {
    # Make fresh conf file
    echo "# $UNBOUND_CONFFILE generated by UCI $( date )"
    echo
    # No threading
    echo "server:"
    echo "  username: unbound"
    echo "  num-threads: 1"
    echo "  msg-cache-slabs: 1"
    echo "  rrset-cache-slabs: 1"
    echo "  infra-cache-slabs: 1"
    echo "  key-cache-slabs: 1"
    echo
    # Interface Wildcard (access contol handled by "option local_service")
    echo "  interface: 0.0.0.0"
    echo "  interface: ::0"
    echo "  outgoing-interface: 0.0.0.0"
    echo "  outgoing-interface: ::0"
    echo
    # Logging
    echo "  verbosity: 1"
    echo "  statistics-interval: 0"
    echo "  statistics-cumulative: no"
  } >> $UNBOUND_CONFFILE


  if [ "$UNBOUND_B_EXT_STATS" -gt 0 ] ; then
    {
      # Log More
      echo "  extended-statistics: yes"
      echo
    } >> $UNBOUND_CONFFILE

  else
    {
      # Log Less
      echo "  extended-statistics: no"
      echo
    } >> $UNBOUND_CONFFILE
  fi


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


  if [ "$UNBOUND_D_PRIV_BLCK" -gt 0 ] ; then
    {
      # Remove _upstream_ or global reponses with private addresses.
      # Unbounds own "local zone" and "forward zone" may still use these.
      # RFC1918, RFC3927, RFC4291, RFC6598, RFC6890
      echo "  private-address: 10.0.0.0/8"
      echo "  private-address: 100.64.0.0/10"
      echo "  private-address: 169.254.0.0/16"
      echo "  private-address: 172.16.0.0/12"
      echo "  private-address: 192.168.0.0/16"
      echo "  private-address: fc00::/7"
      echo "  private-address: fe80::/10"
      echo
    } >> $UNBOUND_CONFFILE
  fi


  if  [ -n "$UNBOUND_LIST_PRV_SUBNET" -a "$UNBOUND_D_PRIV_BLCK" -gt 1 ] ; then
    for ifsubnet in $UNBOUND_LIST_PRV_SUBNET ; do
      # Remove global DNS responses with your local network IP6 GLA
      echo "  private-address: $ifsubnet" >> $UNBOUND_CONFFILE
    done


    echo >> $UNBOUND_CONFFILE
  fi


  if [ "$UNBOUND_B_LOCL_BLCK" -gt 0 ] ; then
    {
      # Remove DNS reponses from upstream with loopback IP
      # Black hole DNS method for ad blocking, so consider...
      echo "  private-address: 127.0.0.0/8"
      echo "  private-address: ::1/128"
      echo
    } >> $UNBOUND_CONFFILE
  fi


  if  [ -n "$UNBOUND_LIST_INSECURE" ] ; then
    for domain in $UNBOUND_LIST_INSECURE ; do
      # Except and accept domains without (DNSSEC); work around broken domains
      echo "  domain-insecure: \"$domain\"" >> $UNBOUND_CONFFILE
    done


    echo >> $UNBOUND_CONFFILE
  fi
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

unbound_records() {
  if [ "$UNBOUND_D_EXTRA_DNS" -gt 0 ] ; then
    # Parasite from the uci.dhcp.domain clauses
    config_load dhcp
    config_foreach create_host_record domain
  fi


  if [ "$UNBOUND_D_EXTRA_DNS" -gt 1 ] ; then
    config_foreach create_srv_record srvhost
    config_foreach create_mx_record mxhost
  fi


  if [ "$UNBOUND_D_EXTRA_DNS" -gt 2 ] ; then
    config_foreach create_cname_record cname
  fi


  echo >> $UNBOUND_CONFFILE
}

##############################################################################

unbound_uci() {
  local cfg="$1"
  local dnsmasqpath hostnm

  hostnm=$( uci_get system.@system[0].hostname | awk '{print tolower($0)}' )
  UNBOUND_TXT_HOSTNAME=${hostnm:-thisrouter}

  config_get_bool UNBOUND_B_SLAAC6_MAC "$cfg" dhcp4_slaac6 0
  config_get_bool UNBOUND_B_DNS64      "$cfg" dns64 0
  config_get_bool UNBOUND_B_EXT_STATS  "$cfg" extended_stats 0
  config_get_bool UNBOUND_B_HIDE_BIND  "$cfg" hide_binddata 1
  config_get_bool UNBOUND_B_LOCL_SERV  "$cfg" localservice 1
  config_get_bool UNBOUND_B_MAN_CONF   "$cfg" manual_conf 0
  config_get_bool UNBOUND_B_QUERY_MIN  "$cfg" query_minimize 0
  config_get_bool UNBOUND_B_QRY_MINST  "$cfg" query_min_strict 0
  config_get_bool UNBOUND_B_LOCL_BLCK  "$cfg" rebind_localhost 0
  config_get_bool UNBOUND_B_DNSSEC     "$cfg" validator 0
  config_get_bool UNBOUND_B_NTP_BOOT   "$cfg" validator_ntp 1

  config_get UNBOUND_IP_DNS64    "$cfg" dns64_prefix "64:ff9b::/96"

  config_get UNBOUND_N_EDNS_SIZE "$cfg" edns_size 1280
  config_get UNBOUND_N_RX_PORT   "$cfg" listen_port 53
  config_get UNBOUND_N_ROOT_AGE  "$cfg" root_age 9

  config_get UNBOUND_D_CONTROL     "$cfg" unbound_control 0
  config_get UNBOUND_D_DOMAIN_TYPE "$cfg" domain_type static
  config_get UNBOUND_D_DHCP_LINK   "$cfg" dhcp_link none
  config_get UNBOUND_D_EXTRA_DNS   "$cfg" add_extra_dns 0
  config_get UNBOUND_D_LAN_FQDN    "$cfg" add_local_fqdn 0
  config_get UNBOUND_D_PRIV_BLCK   "$cfg" rebind_protection 1
  config_get UNBOUND_D_PROTOCOL    "$cfg" protocol mixed
  config_get UNBOUND_D_RECURSION   "$cfg" recursion passive
  config_get UNBOUND_D_RESOURCE    "$cfg" resource small
  config_get UNBOUND_D_WAN_FQDN    "$cfg" add_wan_fqdn 0

  config_get UNBOUND_TTL_MIN     "$cfg" ttl_min 120
  config_get UNBOUND_TXT_DOMAIN  "$cfg" domain lan

  config_list_foreach "$cfg" "domain_forward"   bundle_domain_forward
  config_list_foreach "$cfg" "domain_insecure"  bundle_domain_insecure
  config_list_foreach "$cfg" "rebind_interface" bundle_private_interface

  UNBOUND_LIST_DOMAINS="nowhere $UNBOUND_TXT_DOMAIN"

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
    logger -t unbound -s "edns_size exceeds range, using default"
    UNBOUND_N_EDNS_SIZE=1280
  fi


  if [ "$UNBOUND_N_RX_PORT" -ne 53 ] \
  && [ "$UNBOUND_N_RX_PORT" -lt 1024 -o 10240 -lt "$UNBOUND_N_RX_PORT" ] ; then
    logger -t unbound -s "privileged port or in 5 digits, using default"
    UNBOUND_N_RX_PORT=53
  fi


  if [ "$UNBOUND_TTL_MIN" -gt 1800 ] ; then
    logger -t unbound -s "ttl_min could have had awful side effects, using 300"
    UNBOUND_TTL_MIN=300
  fi
}

##############################################################################

_resolv_setup() {
  if [ "$UNBOUND_N_RX_PORT" != "53" ] ; then
    return
  fi

  if [ -x /etc/init.d/dnsmasq ] && /etc/init.d/dnsmasq enabled \
  && nslookup localhost 127.0.0.1#53 >/dev/null 2>&1 ; then
    # unbound is configured for port 53, but dnsmasq is enabled and a resolver
    #   listens on localhost:53, lets assume dnsmasq manages the resolver file.
    # TODO:
    #   really check if dnsmasq runs a local (main) resolver in stead of using
    #   nslookup that times out when no resolver listens on localhost:53.
    return
  fi

  # unbound is designated to listen on 127.0.0.1#53,
  #   set resolver file to local.
  rm -f /tmp/resolv.conf

  {
    echo "# /tmp/resolv.conf generated by Unbound UCI $( date )"
    echo "nameserver 127.0.0.1"
    echo "nameserver ::1"
    echo "search $UNBOUND_TXT_DOMAIN."
  } > /tmp/resolv.conf
}

##############################################################################

_resolv_teardown() {
  case $( cat /tmp/resolv.conf ) in
  *"generated by Unbound UCI"*)
    # our resolver file, reset to auto resolver file.
    rm -f /tmp/resolv.conf
    ln -s /tmp/resolv.conf.auto /tmp/resolv.conf
    ;;
  esac
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
      unbound_records
    fi


    unbound_forward
    unbound_control
  fi


  _resolv_setup
}

##############################################################################

unbound_stop() {
  _resolv_teardown


  rootzone_update
}

##############################################################################

