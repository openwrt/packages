#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck shell=dash
# Block internet access for a device.
# Usage: trafficctl-block.sh <ip> [label]

. /usr/libexec/trafficctl/trafficctl-fw.sh

IP="$1"
LABEL="${2:-block_$IP}"

if [ -z "$IP" ]; then
    echo '{"ok":false,"msg":"usage: trafficctl-block.sh <ip> [label]"}'
    exit 1
fi

if ! tctl_validate_ip "$IP"; then
    echo '{"ok":false,"msg":"invalid IP address"}'
    exit 1
fi

ROUTER_IP=$(ip -4 addr show dev "$(tctl_get_lan_device)" 2>/dev/null | grep -oE 'inet [0-9.]+' | awk '{print $2}' | head -1)
if [ "$IP" = "$ROUTER_IP" ]; then
    echo '{"ok":false,"msg":"cannot block the router itself"}'
    exit 1
fi

COMMENT=$(tctl_block_comment "$IP")
SELF_BLOCK=false
if [ -n "$TCTL_SRC" ] && [ "$TCTL_SRC" = "$IP" ]; then
    SELF_BLOCK=true
fi

if tctl_is_blocked "$IP"; then
    echo "{\"ok\":true,\"msg\":\"$IP is already blocked\"}"
    exit 0
fi

TCTL_BLOCK_IPV6=0
if tctl_block_add "$IP" "$COMMENT"; then
    conntrack -D -s "$IP" >/dev/null 2>&1
    conntrack -D -d "$IP" >/dev/null 2>&1
    # The v4 flush above leaves every established IPv6 flow running, and with
    # flow offload those are never re-evaluated against the new rule — the
    # device would stay online over v6 indefinitely while the UI reads blocked.
    MAC=$(tctl_target_mac "$IP" 2>/dev/null) && tctl_conntrack_flush_v6 "$MAC"
    # Same problem one layer further out: a flow already accelerated by the
    # NSS firmware is not re-evaluated against this rule either.
    tctl_nss_defunct

    tctl_persist_enabled && tctl_persist_save "block" "$IP" "$LABEL"
    tctl_log "block" "$IP" "$LABEL" "${TCTL_VIA:-cli}" "${TCTL_SRC:-local}"

    # Say which families are actually covered. Reporting plain success while
    # half the traffic walks past the rule is the bug this fixes, so the
    # no-MAC case is stated rather than left to be discovered (same reasoning
    # as the half-applied-limit messages in trafficctl-ratelimit.sh).
    if [ "$TCTL_BLOCK_IPV6" = "1" ]; then
        NOTE=""
    elif tctl_ip_is_nexthop "$IP"; then
        NOTE=" — IPv4 only: $IP is a routed next hop, and a MAC-keyed IPv6 rule would also block everything behind it"
    else
        NOTE=" — IPv4 only: no MAC known for $IP (no DHCP lease, no neighbour entry), so IPv6 is not covered"
    fi
    NOTE="$NOTE$(tctl_nss_note)$(tctl_persist_note)"
    NSS="$(tctl_nss_status)"
    PERSIST=$(tctl_persist_enabled && echo true || echo false)
    if [ "$SELF_BLOCK" = "true" ]; then
        echo "{\"ok\":true,\"ipv6\":$([ "$TCTL_BLOCK_IPV6" = "1" ] && echo true || echo false),\"nss\":\"$NSS\",\"persist\":$PERSIST,\"msg\":\"internet blocked for $IP (your device — LuCI access preserved)$NOTE\"}"
    else
        echo "{\"ok\":true,\"ipv6\":$([ "$TCTL_BLOCK_IPV6" = "1" ] && echo true || echo false),\"nss\":\"$NSS\",\"persist\":$PERSIST,\"msg\":\"internet blocked for $IP$NOTE\"}"
    fi
else
    echo "{\"ok\":false,\"msg\":\"failed to block $IP\"}"
    exit 1
fi
