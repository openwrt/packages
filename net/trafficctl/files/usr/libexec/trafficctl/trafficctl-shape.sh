#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck shell=dash
# Traffic shaping (tc/HTB) for per-device bandwidth control.
# Usage: trafficctl-shape.sh <add|remove|status> <ip> [rate_kbit] [label]

. /usr/libexec/trafficctl/trafficctl-fw.sh

SHAPES_FILE="/etc/trafficctl/shapes.json"
LAN_DEV=$(tctl_get_lan_device)
# Upload is shaped on the WAN device's egress — the only place LAN->WAN
# traffic can be queued. Shaping the LAN device alone (as this did originally)
# only ever touches the download direction.
# Upload is shaped on an IFB device fed from LAN-side ingress, NOT on the WAN
# device: by the time a packet reaches WAN egress, POSTROUTING has already
# masqueraded its source to the router's WAN address, so a per-client
# "match ip src" filter there matches nothing. Redirecting ingress into an IFB
# shapes it while the client's real source address is still intact — which is
# also what makes it work for routed/downstream clients.
IFB_DEV=$(uci -q get trafficctl.main.shape_ifb 2>/dev/null)
[ -z "$IFB_DEV" ] && IFB_DEV="tctl-ifb0"

ACTION="$1"
IP="$2"
RATE="$3"
# shellcheck disable=SC2034
LABEL="${4:-shape_$IP}"
# Upload ceiling. Appended as a fifth positional so every existing caller —
# the rpcd backend, the Telegram bot, the DHCP new-device hook and the boot
# restore — keeps working unchanged. Empty means "same as download", which is
# what shaping did before this existed; it is deliberately NOT treated as zero,
# since a zero ceiling is a total upload block that would report success.
RATE_UP="$5"
[ -z "$RATE_UP" ] && RATE_UP="$RATE"

# A classid minor is 16 bit and two values are already taken — 1:1 is the root
# class and 1:fffe the default one — so a minor cannot be derived from the
# address: 192.168.0.1 would land on the root class (deleting it tears down
# every other device's shape) and any x.x.255.254 on the default one. Addresses
# from different subnets that share their last two octets would also collide,
# and the app supports routed/downstream clients from other subnets. Minors are
# therefore allocated once per address and persisted alongside the rate.
CLASSID_MIN=2
CLASSID_MAX=65533

# Regex-quote a value used in a sed address or grep pattern: an unescaped dot
# matches any character, so 192.168.1.1 would also match 192.168.1x1.
re_quote() {
    echo "$1" | sed 's/[].[^$*\/]/\\&/g'
}

# Records are extracted by pattern, not parsed, so this expression decides what
# counts as a record at all. A record it does not match is not merely misread —
# it disappears from used_minors(), alloc_classid hands its minor to another
# device, and the two then share an HTB class: removing one tears down the
# other. The optional rate_kbit_up group is therefore at the TAIL, and every
# reader below tolerates both the old three-field form and the new one.
shapes_entries() {
    grep -oE '\{"ip":"[^"]+","rate_kbit":[0-9]+(,"classid":"1:[0-9a-f]+")?(,"rate_kbit_up":[0-9]+)?\}' \
        "$SHAPES_FILE" 2>/dev/null
}

# Minor of the classid recorded for this address, empty when not shaped yet.
lookup_classid() {
    local ip esc
    ip="$1"
    esc=$(re_quote "$ip")
    shapes_entries \
        | sed -n "s/^{\"ip\":\"$esc\",\"rate_kbit\":[0-9]*,\"classid\":\"\(1:[0-9a-f]*\)\"\(,\"rate_kbit_up\":[0-9]*\)\{0,1\}}$/\1/p" \
        | head -1
}

# Upload ceiling recorded for this address. Empty means the record predates
# asymmetric shaping, or was written symmetric — both mean "same as download",
# which is what every shape did before this existed.
lookup_rate_up() {
    local ip esc
    ip="$1"
    esc=$(re_quote "$ip")
    shapes_entries \
        | sed -n "s/^{\"ip\":\"$esc\",\"rate_kbit\":[0-9]*,\"classid\":\"1:[0-9a-f]*\",\"rate_kbit_up\":\([0-9]*\)}$/\1/p" \
        | head -1
}

used_minors() {
    shapes_entries \
        | sed -n 's/.*"classid":"1:\([0-9a-f]*\)".*/\1/p' \
        | while read -r h; do [ -n "$h" ] && printf '%d\n' "$((0x$h))"; done
    for dev in "$LAN_DEV" "$IFB_DEV"; do
        tc class show dev "$dev" 2>/dev/null \
            | sed -n 's/^class htb 1:\([0-9a-f]*\) .*/\1/p' \
            | while read -r h; do [ -n "$h" ] && printf '%d\n' "$((0x$h))"; done
    done
}

alloc_classid() {
    used_minors | sort -n -u | awk -v min="$CLASSID_MIN" -v max="$CLASSID_MAX" '
        BEGIN { free = min }
        { if ($1 + 0 == free) free++ }
        END {
            if (free > max) exit 1
            printf "1:%x\n", free
        }'
}

# Shapes persisted before minors were allocated carry no classid, so their class
# is still the one derived from the address. Only used to clean those up on
# removal, and never for the two reserved minors the derivation could produce.
legacy_classid() {
    local ip o3 o4 dec
    ip="$1"
    o3=$(echo "$ip" | cut -d. -f3)
    o4=$(echo "$ip" | cut -d. -f4)
    dec=$((o3 * 256 + o4))
    [ "$dec" -lt "$CLASSID_MIN" ] && return 1
    [ "$dec" -gt "$CLASSID_MAX" ] && return 1
    printf "1:%x\n" "$dec"
}

# Existing shapes keep their minor; a new one gets the lowest free value.
resolve_classid() {
    local ip cid
    ip="$1"
    cid=$(lookup_classid "$ip")
    if [ -n "$cid" ]; then
        echo "$cid"
        return 0
    fi
    alloc_classid
}

# Root qdiscs that OpenWrt or the kernel put there by default carry no
# configuration worth preserving. Anything else (cake from SQM, an HFSC or
# foreign HTB hierarchy) is somebody's QoS setup and must not be torn down
# silently — the caller reports that shaping is unavailable instead.
root_qdisc_replaceable() {
    local dev root kind
    dev="$1"
    root=$(tc qdisc show dev "$dev" 2>/dev/null | grep -m1 ' root ')
    [ -n "$root" ] || return 0
    kind=$(echo "$root" | awk '{print $2}')
    case "$kind" in
        pfifo_fast|fq_codel|fq|noqueue|mq|pfifo|bfifo|sfq|codel|htb) return 0 ;;
        *) return 1 ;;
    esac
}

ensure_root_qdisc() {
    local dev="${1:-$LAN_DEV}"
    # Set up root HTB hierarchy if not present
    tc class show dev "$dev" 2>/dev/null | grep -q "class htb 1:1 " && return 0
    root_qdisc_replaceable "$dev" || return 1
    tc qdisc del dev "$dev" root 2>/dev/null
    tc qdisc add dev "$dev" root handle 1: htb default fffe r2q 10
    tc class add dev "$dev" parent 1: classid 1:1 htb rate 1000mbit ceil 1000mbit burst 125000b cburst 125000b
    tc class add dev "$dev" parent 1:1 classid 1:fffe htb rate 1000mbit ceil 1000mbit burst 125000b cburst 125000b prio 0
    tc qdisc add dev "$dev" parent 1:fffe fq_codel 2>/dev/null
}

# Bring up the IFB device and mirror LAN-side ingress into it. Needs kmod-ifb
# and act_mirred; returns non-zero when either is missing so callers can report
# download-only shaping instead of pretending upload is limited.
ensure_ifb() {
    local dev
    if ! ip link show "$IFB_DEV" >/dev/null 2>&1; then
        ip link add name "$IFB_DEV" type ifb 2>/dev/null || return 1
    fi
    ip link set "$IFB_DEV" up 2>/dev/null || return 1
    ensure_root_qdisc "$IFB_DEV" || return 1

    for dev in $(tctl_ingress_devices); do
        tc qdisc show dev "$dev" ingress 2>/dev/null | grep -q 'qdisc ingress' || \
            tc qdisc add dev "$dev" handle ffff: ingress 2>/dev/null
        tc filter show dev "$dev" parent ffff: 2>/dev/null | grep -q mirred || \
            tc filter add dev "$dev" parent ffff: protocol ip prio 1 u32 \
                match u32 0 0 action mirred egress redirect dev "$IFB_DEV" 2>/dev/null
    done
    # Useless unless at least the IFB root exists.
    tc class show dev "$IFB_DEV" 2>/dev/null | grep -q "class htb 1:1 "
}

# Attach one shaping class on a device, matching the given IP in the given
# direction ("dst" on the LAN side for download, "src" on the WAN side for
# upload).
shape_attach() {
    local dev="$1" match="$2" ip="$3" classid="$4" rate="$5" burst="$6"

    tc filter del dev "$dev" parent 1:0 prio 10 protocol ip u32 match ip "$match" "$ip"/32 2>/dev/null
    tc qdisc del dev "$dev" parent "$classid" 2>/dev/null
    tc class del dev "$dev" classid "$classid" 2>/dev/null

    ensure_root_qdisc "$dev" || return 1
    tc class add dev "$dev" parent 1:1 classid "$classid" htb \
        rate "${rate}kbit" ceil "${rate}kbit" burst "${burst}b" cburst "${burst}b" 2>&1 || return 1
    tc qdisc add dev "$dev" parent "$classid" fq_codel 2>/dev/null
    tc filter add dev "$dev" parent 1:0 prio 10 protocol ip u32 \
        match ip "$match" "$ip"/32 flowid "$classid" 2>&1 || return 1
}

shape_detach() {
    local dev="$1" match="$2" ip="$3" classid="$4"
    tc filter del dev "$dev" parent 1:0 prio 10 protocol ip u32 match ip "$match" "$ip"/32 2>/dev/null
    tc qdisc del dev "$dev" parent "$classid" 2>/dev/null
    tc class del dev "$dev" classid "$classid" 2>/dev/null
}

save_shape() {
    local ip="$1" rate="$2" classid="$3" rate_up="$4"
    mkdir -p "$(dirname "$SHAPES_FILE")"
    [ ! -f "$SHAPES_FILE" ] && echo "[]" > "$SHAPES_FILE"

    local lockd="/tmp/trafficctl_shapes.lock.d"
    local tmpf="/tmp/shapes_rebuild.$$"

    # mkdir is atomic, so unlike a test-then-create lock file two writers cannot
    # both believe they hold it and lose one another's entry.
    local tries=0
    while ! mkdir "$lockd" 2>/dev/null; do
        tries=$((tries + 1))
        if [ "$tries" -ge 50 ]; then
            # A stale directory from a killed writer must not block shaping forever.
            rmdir "$lockd" 2>/dev/null || true
            mkdir "$lockd" 2>/dev/null || break
            break
        fi
        sleep 0.1 2>/dev/null || sleep 1
    done
    # shellcheck disable=SC2064
    trap "rm -f '$tmpf'; rmdir '$lockd' 2>/dev/null" EXIT

    # Portable: extract entries with grep, filter, rebuild JSON
    local old_entries esc
    old_entries=$(shapes_entries || true)
    esc=$(re_quote "$ip")
    local filtered
    filtered=$(echo "$old_entries" | grep -v "^{\"ip\":\"$esc\"," || true)
    if [ "$rate" -gt 0 ] 2>/dev/null; then
        # rate_kbit_up is written only when the two directions differ, so a
        # symmetric shape still produces exactly the record it always did.
        # Downgrading the package then keeps working for the common case.
        local up_field=""
        [ -n "$rate_up" ] && [ "$rate_up" != "$rate" ] && up_field=",\"rate_kbit_up\":$rate_up"
        local entry="{\"ip\":\"$ip\",\"rate_kbit\":$rate,\"classid\":\"$classid\"$up_field}"
        if [ -n "$filtered" ]; then
            filtered=$(printf "%s\n%s" "$filtered" "$entry")
        else
            filtered="$entry"
        fi
    fi
    printf "[" > "$tmpf"
    echo "$filtered" | awk 'NF{if(n++)printf ",";printf "%s",$0}' >> "$tmpf"
    printf "]" >> "$tmpf"

    mv "$tmpf" "$SHAPES_FILE"
    rmdir "$lockd" 2>/dev/null || true
}

remove_shape() {
    local ip="$1"
    save_shape "$ip" "0" ""
}

do_add() {
    local classid
    classid=$(resolve_classid "$IP")
    if [ -z "$classid" ]; then
        echo '{"ok":false,"msg":"no free shaping class available"}'
        return 1
    fi

    # Calculate burst: 10ms of data, minimum 1600 bytes
    local burst_bytes
    burst_bytes=$(( RATE * 125 / 100 ))
    [ "$burst_bytes" -lt 1600 ] && burst_bytes=1600

    # Download: queue on the LAN device, matching traffic destined to the client.
    if ! shape_attach "$LAN_DEV" dst "$IP" "$classid" "$RATE" "$burst_bytes"; then
        # Naming the cause matters here: declining to replace a foreign root
        # qdisc is deliberate (it is how an SQM/cake setup survives this app),
        # but "tc setup failed" reads as a bug and gives no way to act on it.
        # The rate limiter is a policer, owns no qdisc, and works alongside SQM.
        if ! root_qdisc_replaceable "$LAN_DEV"; then
            echo "{\"ok\":false,\"msg\":\"shaping declined on $LAN_DEV: another QoS setup (SQM/cake or a custom HTB tree) owns the root qdisc and will not be torn down. Use the limiter instead — it is a policer and coexists with SQM.\"}"
        else
            echo "{\"ok\":false,\"msg\":\"tc setup failed for $IP on $LAN_DEV\"}"
        fi
        return 1
    fi

    # Upload: shaped pre-NAT on the IFB device fed from LAN ingress.
    # Reported separately so a missing kmod-ifb doesn't look like total failure.
    # The two directions are already separate HTB classes on separate devices,
    # so giving them separate rates costs nothing beyond its own burst.
    local ul_burst
    ul_burst=$(( RATE_UP * 125 / 100 ))
    [ "$ul_burst" -lt 1600 ] && ul_burst=1600
    local ul_ok=1
    if ensure_ifb; then
        shape_attach "$IFB_DEV" src "$IP" "$classid" "$RATE_UP" "$ul_burst" || ul_ok=0
    else
        ul_ok=0
    fi

    save_shape "$IP" "$RATE" "$classid" "$RATE_UP"
    local rates="${RATE} kbit/s"
    [ "$RATE_UP" != "$RATE" ] && rates="${RATE} kbit/s down, ${RATE_UP} kbit/s up"
    # Linux HTB never gets to queue a flow the NSS firmware is forwarding, so
    # a shape on such a router is installed and inert (#81). NSS builds ship
    # their own qdiscs (nsshtb/nsstbl) which this does not yet use; until it
    # does, say so instead of reporting success.
    tctl_nss_defunct
    NSSNOTE="$(tctl_nss_note)"
    NSS="$(tctl_nss_status)"
    if [ "$ul_ok" = "1" ]; then
        echo "{\"ok\":true,\"nss\":\"$NSS\",\"msg\":\"shape $rates applied to $IP both directions (class $classid)$NSSNOTE\"}"
    elif [ "$RATE_UP" != "$RATE" ]; then
        # Saying "applied" here would be a lie about the half the operator
        # explicitly asked to differ.
        echo "{\"ok\":true,\"nss\":\"$NSS\",\"msg\":\"shape ${RATE} kbit/s applied to $IP for download only — the ${RATE_UP} kbit/s upload ceiling was NOT applied, it needs kmod-ifb: opkg/apk install kmod-ifb kmod-sched$NSSNOTE\"}"
    else
        echo "{\"ok\":true,\"nss\":\"$NSS\",\"msg\":\"shape ${RATE} kbit/s applied to $IP (download only — upload needs kmod-ifb: opkg/apk install kmod-ifb kmod-sched)$NSSNOTE\"}"
    fi
}

do_remove() {
    local classid
    classid=$(lookup_classid "$IP")
    [ -n "$classid" ] || classid=$(legacy_classid "$IP")

    if [ -n "$classid" ]; then
        shape_detach "$LAN_DEV" dst "$IP" "$classid"
        shape_detach "$IFB_DEV" src "$IP" "$classid"
    fi

    remove_shape "$IP"
    echo "{\"ok\":true,\"msg\":\"shape removed for $IP\"}"
}

do_status() {
    local classid
    classid=$(lookup_classid "$IP")
    if [ -z "$classid" ]; then
        echo "{\"ok\":true,\"ip\":\"$IP\",\"classid\":\"\",\"info\":\"no shape active\"}"
        return 0
    fi
    local info
    info=$(tc -s class show dev "$LAN_DEV" classid "$classid" 2>/dev/null)
    if [ -n "$info" ]; then
        local rate_val
        rate_val=$(echo "$info" | grep -oE 'rate [0-9]+[a-zA-Z]+' | head -1 | awk '{print $2}')
        echo "{\"ok\":true,\"ip\":\"$IP\",\"classid\":\"$classid\",\"info\":\"$rate_val\"}"
    else
        echo "{\"ok\":true,\"ip\":\"$IP\",\"classid\":\"$classid\",\"info\":\"no shape active\"}"
    fi
}

# Main
case "$ACTION" in
    add)
        if [ -z "$IP" ] || [ -z "$RATE" ]; then
            echo '{"ok":false,"msg":"usage: trafficctl-shape.sh add <ip> <rate_kbit> [label]"}'
            exit 1
        fi
        if ! tctl_validate_ip "$IP"; then
            echo '{"ok":false,"msg":"invalid IP address"}'
            exit 1
        fi
        do_add
        ;;
    remove)
        if [ -z "$IP" ]; then
            echo '{"ok":false,"msg":"usage: trafficctl-shape.sh remove <ip>"}'
            exit 1
        fi
        if ! tctl_validate_ip "$IP"; then
            echo '{"ok":false,"msg":"invalid IP address"}'
            exit 1
        fi
        do_remove
        ;;
    status)
        if [ -z "$IP" ]; then
            echo '{"ok":false,"msg":"usage: trafficctl-shape.sh status <ip>"}'
            exit 1
        fi
        if ! tctl_validate_ip "$IP"; then
            echo '{"ok":false,"msg":"invalid IP address"}'
            exit 1
        fi
        do_status
        ;;
    *)
        echo '{"ok":false,"msg":"usage: trafficctl-shape.sh <add|remove|status> <ip> [rate_kbit] [label]"}'
        exit 1
        ;;
esac
