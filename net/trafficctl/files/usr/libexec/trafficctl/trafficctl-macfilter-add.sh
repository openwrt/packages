#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck shell=dash
# Block device WiFi access by adding its MAC to deny maclist on all interfaces.
# The uci maclist is the durable half; hostapd is then programmed at runtime so
# only the target client is kicked, with no wifi reload. Reports how far that
# runtime half actually got — see the enforcement words in trafficctl-fw.sh.
# Usage: trafficctl-macfilter-add.sh <ip>

. /usr/libexec/trafficctl/trafficctl-fw.sh

IP="$1"

if [ -z "$IP" ]; then
    echo '{"ok":false,"msg":"usage: trafficctl-macfilter-add.sh <ip>"}'
    exit 1
fi

if ! tctl_validate_ip "$IP"; then
    echo '{"ok":false,"msg":"invalid IP address"}'
    exit 1
fi

# Look up MAC from DHCP leases
MAC=""
if [ -f /tmp/dhcp.leases ]; then
    MAC=$(awk -v ip="$IP" '$3 == ip {print toupper($2)}' /tmp/dhcp.leases | head -1)
fi

if [ -z "$MAC" ]; then
    MAC=$(ip neigh show "$IP" 2>/dev/null | grep -oE '[0-9a-fA-F:]{17}' | head -1 | tr 'a-f' 'A-F')
fi

if [ -z "$MAC" ]; then
    echo "{\"ok\":false,\"msg\":\"cannot find MAC for $IP\"}"
    exit 1
fi

# Normalize MAC to lowercase (OpenWrt stores lowercase)
MAC=$(echo "$MAC" | tr 'A-F' 'a-f')

# Add MAC to maclist on all wifi interfaces
IFACES=$(tctl_get_wifi_interfaces)
if [ -z "$IFACES" ]; then
    echo '{"ok":false,"msg":"no wifi interfaces found"}'
    exit 1
fi

CHANGED=0
MODE="deny"
for iface in $IFACES; do
    # Respect the ACL policy the administrator configured. Forcing macfilter to
    # "deny" here used to invert an existing whitelist: the curated allow-list
    # would start being read as a block-list, letting in every device it was
    # meant to keep out and banning every device it listed.
    iface_mode=$(tctl_get_wifi_filter_mode "$iface")
    [ "$iface_mode" = "allow" ] && MODE="allow"

    existing=$(uci -q get "wireless.${iface}.maclist")
    listed=0
    echo "$existing" | grep -qi "$MAC" && listed=1

    if [ "$iface_mode" = "allow" ]; then
        # Whitelist: blocking means dropping the MAC from the allow-list.
        if [ "$listed" = "1" ]; then
            uci del_list "wireless.${iface}.maclist=$MAC"
            CHANGED=1
        fi
    else
        # Blacklist: blocking means adding the MAC, creating the list if needed.
        if [ -z "$(uci -q get "wireless.${iface}.macfilter")" ]; then
            uci set "wireless.${iface}.macfilter=deny"
            CHANGED=1
        fi
        if [ "$listed" = "0" ]; then
            uci add_list "wireless.${iface}.maclist=$MAC"
            CHANGED=1
        fi
    fi
done

[ "$CHANGED" = "1" ] && uci commit wireless

# Applied unconditionally, not just when uci needed editing. Config and runtime
# are two pieces of state: a router whose maclist already names the MAC but
# whose radio never got the ACL entry used to make this a no-op that still
# reported success, so pressing Block again — the obvious reaction to "it did
# not work" — could never recover it.
ENFORCE=$(tctl_hostapd_block_mac "$MAC" "$MODE")
BAN_MIN=$(( TCTL_WIFI_BAN_MS / 60000 ))

# The uci entry is kept even when the radio could not be programmed. It is the
# only durable record of the operator's intent and it does take effect at the
# next wifi restart, so discarding it would throw away the half that worked and
# leave the device unblocked forever. What made keeping it dangerous was the
# claim of success, not the entry — so the claim is what goes. A wifi reload
# would apply it now, but it disconnects every client on the radio, which is
# not something a per-device click should do behind the operator's back.
case "$ENFORCE" in
    acl)
        OK=true
        MSG="MAC $MAC blocked on wifi for $IP"
        ;;
    no-radio)
        OK=true
        MSG="MAC $MAC added to the wifi deny list for $IP; no radio is running, it applies when wifi starts"
        ;;
    ban)
        OK=false
        MSG="MAC $MAC is NOT permanently blocked: hostapd_cli is missing, so the block is temporary ($BAN_MIN min). Install hostapd-utils, or restart wifi (drops all clients)"
        ;;
    *)
        OK=false
        MSG="MAC $MAC saved to the wifi deny list but NOT applied to the radio, so the device stays online. Install hostapd-utils, or restart wifi (drops all clients)"
        ;;
esac

tctl_log "wifi_block" "$IP" "MAC=$MAC enforce=$ENFORCE" "${TCTL_VIA:-cli}" "${TCTL_SRC:-local}"
printf '{"ok":%s,"enforcement":"%s","msg":"%s"}\n' "$OK" "$ENFORCE" "$MSG"
