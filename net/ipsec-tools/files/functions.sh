#!/bin/sh
#
# Copyright (C) 2015 Vitaly Protsko <villy@sft.ru>

errno=0

get_fieldval() {
  local __data="$3"
  local __rest

  test -z "$1" && return

  while true ; do
    __rest=${__data#* }
    test "$__rest" = "$__data" && break

    if [ "${__data/ *}" = "$2" ]; then
      eval "$1=${__rest/ *}"
      break
    fi

    __data="$__rest"
  done
}

manage_fw() {
  local cmd=/usr/sbin/iptables
  local mode
  local item

  if [ -z "$4" ]; then
    $log "Bad usage of manage_fw"
    errno=3; return 3
  fi

  case "$1" in
    add|up|1) mode=A ;;
    del|down|0) mode=D ;;
    *) return 3 ;;
  esac

  for item in $4 ; do
    $cmd -$mode forwarding_$2_rule -s $item -j ACCEPT
    $cmd -$mode output_$3_rule -d $item -j ACCEPT
    $cmd -$mode forwarding_$3_rule -d $item -j ACCEPT
    $cmd -t nat -$mode postrouting_$3_rule -d $item -j ACCEPT
  done
}

manage_sa() {
  local spdcmd
  local rtcmd
  local gate
  local litem
  local ritem

  if [ -z "$4" ]; then
    $log "Bad usage of manage_sa"
    errno=3; return 3
  fi

  case "$1" in
    add|up|1) spdcmd=add; rtcmd=add ;;
    del|down|0) spdcmd=delete; rtcmd=del ;;
    *) errno=3; return 3 ;;
  esac

  get_fieldval gate src "$(/usr/sbin/ip route get $4)"
  if [ -z "$gate" ]; then
    $log "Can not find outbound IP for $4"
    errno=3; return 3
  fi


  for litem in $2 ; do
    for ritem in $3 ; do
      echo "
spd$spdcmd $litem $ritem any -P out ipsec esp/tunnel/$gate-$4/require;
spd$spdcmd $ritem $litem any -P in ipsec esp/tunnel/$4-$gate/require;
" | /usr/sbin/setkey -c 1>&2
    done
  done

  test -n "$5" && gate=$5

  for ritem in $3 ; do
    (sleep 3; /usr/sbin/ip route $rtcmd $ritem via $gate) &
  done
}

manage_nonesa() {
  local spdcmd
  local item
  local cout cin

  if [ -z "$4" ]; then
    $log "Bad usage of manage_nonesa"
    errno=3; return 3
  fi

  case "$1" in
    add|up|1) spdcmd=add ;;
    del|down|0) spdcmd=delete ;;
    *) errno=3; return 3 ;;
  esac

  case "$2" in
    local|remote) ;;
    *) errno=3; return 3 ;;
  esac

  for item in $3 ; do
    if [ "$2" = "local" ]; then
      cout="$4 $item"
      cin="$item $4"
    else
      cout="$item $4"
      cin="$4 $item"
    fi
    echo "
spd$spdcmd $cout any -P out none;
spd$spdcmd $cin any -P in none;
" | /usr/sbin/setkey -c 1>&2
  done
}

. /lib/functions/network.sh

get_zoneiflist() {
  local item
  local data
  local addr

  item=0
  data=$(uci get firewall.@zone[0].name)
  while [ -n "$data" ]; do
    test "$data" = "$1" && break
    let "item=$item+1"
    data=$(uci get firewall.@zone[$item].name)
  done

  if [ -z "$data" ]; then
    errno=1
    return $errno
  fi
  data=$(uci get firewall.@zone[$item].network)

  echo "$data"
}

get_zoneiplist() {
  local item
  local addr
  local data
  local result

  data=$(get_zoneiflist $1)
  test $? -gt 0 -o $errno -gt 0 -o -z "$data" && return $errno

  for item in $data ; do
    if network_is_up $item ; then
      network_get_ipaddrs addr $item
      test $? -eq 0 && result="$result $addr"
    fi
  done

  result=$(echo $result)
  echo "$result"
}


# EOF /etc/racoon/functions.sh
