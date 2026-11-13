#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck shell=dash
# Remove device WiFi MAC filter (unblock from wifi deny list).
# Updates the uci maclist and the running hostapd ACL, so the client can
# reassociate without a wifi reload and other clients stay connected. Reports
# how far the runtime half got — see the enforcement words in trafficctl-fw.sh.
# Usage: trafficctl-macfilter-remove.sh <ip|mac>
#
# A MAC is accepted as well as an IP because the deny list is keyed on the MAC:
# a device that has been off the network long enough has no lease and no
# neighbour entry left, so looking it up by IP fails and its WiFi block could
# never be lifted (#128).

. /usr/libexec/trafficctl/trafficctl-fw.sh

IP="$1"
MAC=""

if [ -z "$IP" ]; then
    echo '{"ok":false,"msg":"usage: trafficctl-macfilter-remove.sh <ip|mac>"}'
    exit 1
fi

# The length check matters: grep matches line by line, so without it a MAC
# followed by a newline and anything else would pass and reach uci.
if [ "${#IP}" -eq 17 ] && printf '%s' "$IP" | grep -qE '^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$'; then
    MAC=$(echo "$IP" | tr 'A-F' 'a-f')
    # Only for the messages and the log; a MAC with no address left reads as
    # itself.
    IP=$(awk -v m="$MAC" 'tolower($2) == m { print $3; exit }' /tmp/dhcp.leases 2>/dev/null)
    [ -n "$IP" ] || IP="$MAC"
elif ! tctl_validate_ip "$IP"; then
    echo '{"ok":false,"msg":"invalid IP address"}'
    exit 1
fi

# Look up MAC from DHCP leases
if [ -z "$MAC" ] && [ -f /tmp/dhcp.leases ]; then
    MAC=$(awk -v ip="$IP" '$3 == ip {print toupper($2)}' /tmp/dhcp.leases | head -1)
fi

if [ -z "$MAC" ]; then
    MAC=$(ip neigh show "$IP" 2>/dev/null | grep -oE '[0-9a-fA-F:]{17}' | head -1 | tr 'a-f' 'A-F')
fi

if [ -z "$MAC" ]; then
    echo "{\"ok\":false,\"msg\":\"cannot find MAC for $IP\"}"
    exit 1
fi

# Normalize MAC to lowercase
MAC=$(echo "$MAC" | tr 'A-F' 'a-f')

# Remove MAC from maclist on all wifi interfaces
IFACES=$(tctl_get_wifi_interfaces)
if [ -z "$IFACES" ]; then
    echo '{"ok":false,"msg":"no wifi interfaces found"}'
    exit 1
fi

CHANGED=0
MODE="deny"
for iface in $IFACES; do
    iface_mode=$(tctl_get_wifi_filter_mode "$iface")
    [ "$iface_mode" = "allow" ] && MODE="allow"

    existing=$(uci -q get "wireless.${iface}.maclist")
    listed=0
    echo "$existing" | grep -qi "$MAC" && listed=1

    if [ "$iface_mode" = "allow" ]; then
        # Whitelist: unblocking means putting the MAC back on the allow-list.
        if [ "$listed" = "0" ]; then
            uci add_list "wireless.${iface}.maclist=$MAC"
            CHANGED=1
        fi
    else
        # Blacklist: unblocking means removing the MAC from the block-list.
        if [ "$listed" = "1" ]; then
            uci del_list "wireless.${iface}.maclist=$MAC"
            CHANGED=1
        fi
    fi
done

[ "$CHANGED" = "1" ] && uci commit wireless

# Unconditional for the same reason as the add path, and the stakes are higher
# here: a MAC that uci no longer lists but the radio still denies leaves a real
# person off the network while the UI says they are not blocked.
ENFORCE=$(tctl_hostapd_unblock_mac "$MAC" "$MODE")
BAN_MIN=$(( TCTL_WIFI_BAN_MS / 60000 ))

case "$ENFORCE" in
    acl)
        OK=true
        MSG="MAC $MAC removed from wifi filter for $IP"
        ;;
    no-radio)
        OK=true
        MSG="MAC $MAC removed from the wifi filter for $IP; no radio is running"
        ;;
    ban)
        OK=false
        MSG="MAC $MAC removed from the wifi filter, but hostapd still bans it for up to $BAN_MIN min. Restart wifi (drops all clients) to clear it now"
        ;;
    *)
        OK=false
        MSG="MAC $MAC removed from the wifi filter, but the radio ACL could not be read back: it may still be blocked. Install hostapd-utils, or restart wifi"
        ;;
esac

tctl_log "wifi_unblock" "$IP" "MAC=$MAC enforce=$ENFORCE" "${TCTL_VIA:-cli}" "${TCTL_SRC:-local}"
printf '{"ok":%s,"enforcement":"%s","msg":"%s"}\n' "$OK" "$ENFORCE" "$MSG"
