#!/bin/sh
# Copyright 2016 Dan Luedtke <mail@danrl.com>
# Licensed to the public under the Apache License 2.0.


WG=/usr/bin/wg
if [ ! -x $WG ]; then
  logger -t "wireguard" "error: missing wireguard-tools ($WG)"
  exit 0
fi

[ -n "$INCLUDE_ONLY" ] || {
  . /lib/functions.sh
  . ../netifd-proto.sh
  init_proto "$@"
}

proto_wireguard_init_config() {
  available=1
  no_proto_task=1
}

proto_wireguard_setup() {
  local config="$1"
  local iface="wg-${config}"
  local wg_dir="/tmp/wireguard/"
  local wg_cfg="${wg_dir}${config}"

  local private_key
  local listen_port
  local addresses
  local mtu
  local preshared_key

  # check for kernel module
  if ! grep -q wireguard /proc/modules; then
    echo "loading kernel module"
    if ! insmod wireguard; then
      echo "error: loading kernel module failed"
      proto_setup_failed "$config"
      exit 1
    fi
  fi

  # load configuration
  config_load network

  # get interface configuration
  config_get private_key   "${config}" "private_key"
  config_get listen_port   "${config}" "listen_port"
  config_get addresses     "${config}" "addresses"
  config_get mtu           "${config}" "mtu"
  config_get preshared_key "${config}" "preshared_key"

  # create interface
  ip link del dev "${iface}" 2>/dev/null
  ip link add dev "${iface}" type wireguard
  if [ "${mtu}" ]; then
    ip link set mtu "${mtu}" dev "${iface}"
  fi

  # create wireguard configuration
  umask 077
  mkdir -p "${wg_dir}"
  echo "[Interface]" > "${wg_cfg}"
  echo "PrivateKey=${private_key}" >> "${wg_cfg}"
  if [ "${listen_port}" ]; then
    echo "ListenPort=${listen_port}" >> "${wg_cfg}"
  fi
  if [ "${preshared_key}" ]; then
    echo "PresharedKey=${preshared_key}" >> "${wg_cfg}"
  fi

  configure_peer() {
    local peer_config="$1"
    local public_key
    local allowed_ips
    local route_allowed_ips
    local endpoint_host
    local endpoint_port
    local persistent_keepalive

    config_get public_key           "${peer_config}" "public_key"
    config_get allowed_ips          "${peer_config}" "allowed_ips"
    config_get route_allowed_ips    "${peer_config}" "route_allowed_ips"
    config_get endpoint_host        "${peer_config}" "endpoint_host"
    config_get endpoint_port        "${peer_config}" "endpoint_port"
    config_get persistent_keepalive "${peer_config}" "persistent_keepalive"

    # peer configuration
    echo "[Peer]" >> "${wg_cfg}"
    echo "PublicKey=${public_key}" >> "${wg_cfg}"
    for allowed_ip in $allowed_ips; do
      echo "AllowedIPs=${allowed_ip}" >> "${wg_cfg}"
    done
    if [ "${endpoint_host}" ]; then
      case "${endpoint_host}" in
        *:*)
          endpoint="[${endpoint_host}]"
        ;;
        *)
          endpoint="${endpoint_host}"
        ;;
      esac
      if [ "${endpoint_port}" ]; then
        endpoint="${endpoint}:${endpoint_port}"
      else
        endpoint="${endpoint}:51820"
      fi
      echo "Endpoint=${endpoint}" >> "${wg_cfg}"
    fi
    if [ "${persistent_keepalive}" ]; then
      echo "PersistentKeepalive=${persistent_keepalive}"  >> "${wg_cfg}"
    fi

    # add routes for allowed ips
    if [ "${route_allowed_ips}" = "enabled" ]; then
      for allowed_ip in $allowed_ips; do
        proto_init_update "${iface}" 1
        proto_set_keep 1
        route="$(echo $allowed_ip | tr '/' ' ')"
        case "${allowed_ip}" in
          *:*/*)
            proto_add_ipv6_route $route
          ;;
          */*)
            proto_add_ipv4_route $route
          ;;
        esac
        proto_send_update "${config}"
      done
    fi

    # ensure endpoint reachability
    if [ "${endpoint_host}" ]; then
      added_dependency="false"
      for ip in $(resolveip -t 5 "${endpoint_host}"); do
        ( proto_add_host_dependency "${config}" "${ip}" )
        added_dependency="true"
      done
      if [ "${added_dependency}" = "false" ]; then
        echo "Error resolving ${endpoint_host}!"
        sleep 5
        proto_setup_failed "${config}"
        exit 1
      fi
    fi
  }
  config_foreach configure_peer "wireguard_${config}"

  # apply configuration
  $WG setconf ${iface} "${wg_cfg}"

  # delete configuration
  rm -f "${wg_cfg}"

  # assign addresses
  for address in ${addresses}; do
    proto_init_update "${iface}" 1
    proto_set_keep 1
    address_plen="$(echo $address | tr '/' ' ')"
    case "${address}" in
      *:*)
        proto_add_ipv6_address $address_plen
      ;;
      *)
        proto_add_ipv4_address $address_plen
      ;;
    esac
    proto_send_update "${config}"
  done
}

proto_wireguard_teardown() {
  local config="$1"
  local iface="wg-${config}"
  ip link del dev "${iface}" >/dev/null 2>&1
}

[ -n "$INCLUDE_ONLY" ] || {
  add_protocol wireguard
}
