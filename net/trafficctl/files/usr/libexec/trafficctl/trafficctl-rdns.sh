#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck shell=dash
# Reverse DNS lookup for an IP address.
# Usage: trafficctl-rdns.sh <ip>
# Output: {"ip":"...","host":"..."}

. /usr/libexec/trafficctl/trafficctl-fw.sh

IP="$1"

if [ -z "$IP" ]; then
    echo '{"ip":"","host":""}'
    exit 1
fi

if ! tctl_validate_ip "$IP"; then
    echo "{\"ip\":\"$IP\",\"host\":\"\"}"
    exit 1
fi

HOST=""
# Try ubus network.rrdns (same resolver the LuCI frontend uses; always available via rpcd)
if command -v ubus >/dev/null 2>&1; then
    HOST=$(ubus call network.rrdns lookup \
        "{\"addrs\":[\"$IP\"],\"timeout\":2000,\"limit\":1}" 2>/dev/null \
        | jsonfilter -e "@[\"$IP\"]" 2>/dev/null)
fi
# Fallback: BusyBox nslookup (always available on OpenWrt)
if [ -z "$HOST" ] && command -v nslookup >/dev/null 2>&1; then
    HOST=$(nslookup "$IP" 2>/dev/null | sed -n 's/.*name = \(.*\)\.$/\1/p' | head -1)
fi

# Validate hostname (only allow safe chars)
case "$HOST" in
    *[!a-zA-Z0-9._-]*|"") HOST="" ;;
esac

if [ -z "$HOST" ]; then
    echo "{\"ip\":\"$IP\",\"host\":\"\"}"
else
    echo "{\"ip\":\"$IP\",\"host\":\"$HOST\"}"
fi
