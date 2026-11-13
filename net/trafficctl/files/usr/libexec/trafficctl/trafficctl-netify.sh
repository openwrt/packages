#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck shell=dash
# Optional Netify Agent (netifyd) integration — DPI application labels per device.
#
# Entirely optional: every entry point degrades to an empty result when netifyd
# is not installed, not running, or no socket reader is available, so the rest
# of trafficctl behaves exactly as before.
#
# Usage:
#   trafficctl-netify.sh status          — availability probe (JSON object)
#   trafficctl-netify.sh collect [secs]  — sample the socket, refresh the cache
#   trafficctl-netify.sh list            — cached per-device app breakdown
#   trafficctl-netify.sh raw [secs]      — raw socket lines (debugging)
#
# Telemetry comes from the agent's socket SINK, not from netifyd.sock: in
# Agent v5 that unix socket is a request/response API which never pushes flow
# data, so connecting to it returns nothing at all. The sink's bind address is
# read from netify-sink-socket.json (typically tcp://127.0.0.1:1780).
#
# Two payload shapes are handled: the aggregator's {"stats":[...]} records
# (application_id/local_ip/download/upload) and raw per-flow records
# (detected_application_name/local_ip/total_bytes). Records are parsed by field
# extraction rather than strict JSON, which tolerates either framing.

. /usr/libexec/trafficctl/trafficctl-fw.sh

CACHE="/tmp/trafficctl_netify.json"
LOCK="/tmp/trafficctl_netify.lock"
DEFAULT_SOCKET="/var/run/netifyd/netifyd.sock"

netify_socket() {
    local s
    s=$(uci -q get trafficctl.main.netify_socket 2>/dev/null)
    [ -n "$s" ] && { echo "$s"; return; }
    echo "$DEFAULT_SOCKET"
}

# Where flow telemetry is actually published: an explicit override, else the
# first enabled socket-sink channel, else the legacy unix socket (Agent v4).
netify_endpoint() {
    local ep
    ep=$(uci -q get trafficctl.main.netify_endpoint 2>/dev/null)
    [ -n "$ep" ] && { echo "$ep"; return; }
    ep=$(sed -n 's/.*"bind_address\"[ \t]*:[ \t]*"\(tcp:\/\/[^"]*\)".*/\1/p' \
        /etc/netifyd/netify-sink-socket.json 2>/dev/null | head -1)
    [ -n "$ep" ] && { echo "$ep"; return; }
    echo "unix://$(netify_socket)"
}

netify_enabled() {
    [ "$(uci -q get trafficctl.main.netify_enabled 2>/dev/null)" != "0" ]
}

# Echo the command able to stream the socket, or nothing.
socket_reader() {
    if command -v socat >/dev/null 2>&1; then
        echo "socat"
    elif command -v nc >/dev/null 2>&1; then
        echo "nc"
    fi
}

read_socket() {
    local secs="$1" ep reader hostport path
    ep=$(netify_endpoint)
    reader=$(socket_reader)
    [ -n "$reader" ] || return 1

    case "$ep" in
        tcp://*)
            hostport=${ep#tcp://}
            case "$reader" in
                socat) timeout "$secs" socat -u "TCP-CONNECT:$hostport" - 2>/dev/null ;;
                nc)    timeout "$secs" nc "${hostport%%:*}" "${hostport##*:}" 2>/dev/null ;;
            esac
            ;;
        unix://*|/*)
            path=${ep#unix://}
            [ -S "$path" ] || return 1
            case "$reader" in
                socat) timeout "$secs" socat -u "UNIX-CONNECT:$path" - 2>/dev/null ;;
                nc)    timeout "$secs" nc -U "$path" 2>/dev/null ;;
            esac
            ;;
        *) return 1 ;;
    esac
    return 0
}

# Tests (and offline debugging) feed recorded agent output instead of a socket.
feed_lines() {
    if [ -n "$TCTL_NETIFY_FEED" ] && [ -f "$TCTL_NETIFY_FEED" ]; then
        cat "$TCTL_NETIFY_FEED"
    else
        read_socket "$1"
    fi
}

do_status() {
    local sock reader installed=false running=false readable=false age=-1 now mtime
    sock=$(netify_socket)
    reader=$(socket_reader)
    command -v netifyd >/dev/null 2>&1 && installed=true
    [ -S "$sock" ] && running=true
    [ -n "$reader" ] && readable=true
    if [ -f "$CACHE" ]; then
        now=$(date +%s)
        mtime=$(date -r "$CACHE" +%s 2>/dev/null || echo 0)
        age=$(( now - mtime ))
    fi
    printf '{"enabled":%s,"installed":%s,"running":%s,"socket":"%s","endpoint":"%s","reader":"%s","readable":%s,"cache_age":%d}\n' \
        "$(netify_enabled && echo true || echo false)" \
        "$installed" "$running" "$sock" "$(netify_endpoint)" "${reader:-none}" "$readable" "$age"
}

# Aggregate flow records into "per local IP → per application" totals.
#
# The agent re-emits a flow as its byte counters grow (flow, flow_dpi_update,
# flow_dpi_complete), so totals are tracked per flow digest and only summed at
# the end — adding every sighting would multiply-count the same traffic.
parse_flows() {
    # One JSON object per line so the field extractor sees one record at a
    # time — the aggregator packs every device into a single "stats" array.
    sed 's/},[ ]*{/}\n{/g' | awk '
    function field(line, key,   re, seg, v) {
        re = "\"" key "\"[ \t]*:[ \t]*"
        if (!match(line, re)) return ""
        seg = substr(line, RSTART + RLENGTH)
        if (substr(seg, 1, 1) == "\"") {
            seg = substr(seg, 2)
            if (!match(seg, /"/)) return ""
            return substr(seg, 1, RSTART - 1)
        }
        if (!match(seg, /^-?[0-9]+/)) return ""
        return substr(seg, RSTART, RLENGTH) + 0
    }
    {
        # Only flow-bearing records carry local_ip; skip status/hello lines.
        ip = field($0, "local_ip")
        if (ip !~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) next

        # Aggregator records name the app as "<id>.netify.<name>".
        app = field($0, "application_id")
        sub(/^[0-9]+\./, "", app)
        if (app == "") app = field($0, "detected_application_name")
        # Agent prefixes catalogued apps with "netify."; the bare name reads
        # better in a table.
        sub(/^netify\./, "", app)
        if (app == "" || app == "unknown") app = field($0, "detected_protocol_name")
        if (app == "" || app == "Unknown") {
            host = field($0, "host_server_name")
            if (host != "") app = host; else app = "unclassified"
        }
        gsub(/[^a-zA-Z0-9._ -]/, "", app)
        if (app == "") app = "unclassified"

        digest = field($0, "digest")
        # Aggregator: per-interval byte deltas, already summed per device+app.
        bytes = field($0, "download") + field($0, "upload")
        if (bytes == 0) bytes = field($0, "total_bytes")
        if (bytes == "" || bytes == 0) bytes = field($0, "local_bytes") + field($0, "other_bytes")
        if (digest == "") digest = ip "|" app "|" NR

        key = ip SUBSEP app
        # Last sighting of a digest carries its cumulative total.
        if (!(digest in seen)) { seen[digest] = key; flows[key]++ }
        dbytes[digest] = bytes + 0
    }
    END {
        for (d in seen) total[seen[d]] += dbytes[d]
        for (k in total) {
            split(k, p, SUBSEP)
            printf "%s %s %.0f %d\n", p[1], p[2], total[k], flows[k]
        }
    }'
}

do_collect() {
    # The aggregator publishes on an interval (~15s), so a short sample window
    # usually catches nothing at all — wait long enough to span one report.
    local secs="${1:-18}" raw parsed tmp
    case "$secs" in ''|*[!0-9]*) secs=18 ;; esac
    [ "$secs" -lt 1 ] && secs=1
    [ "$secs" -gt 60 ] && secs=60

    netify_enabled || { echo '{"ok":false,"msg":"netify integration disabled"}'; return 0; }

    # One collector at a time — overlapping samples would double the socket
    # load and race on the cache file.
    mkdir "$LOCK" 2>/dev/null || { echo '{"ok":false,"msg":"collection already running"}'; return 0; }
    # shellcheck disable=SC2064
    trap "rmdir '$LOCK' 2>/dev/null" EXIT INT TERM

    raw=$(feed_lines "$secs")
    if [ -z "$raw" ]; then
        echo '{"ok":false,"msg":"no data from netifyd socket"}'
        return 0
    fi

    parsed=$(printf '%s\n' "$raw" | parse_flows)
    tmp="${CACHE}.tmp"
    # Group by IP, apps sorted by bytes descending.
    printf '%s\n' "$parsed" | sort -k1,1 -k3,3nr | awk '
    BEGIN { printf "[" }
    NF >= 4 {
        if ($1 != cur) {
            if (cur != "") printf "]},"
            printf "{\"ip\":\"%s\",\"top\":\"%s\",\"apps\":[", $1, $2
            cur = $1
            first = 1
        }
        if (!first) printf ","
        printf "{\"name\":\"%s\",\"bytes\":%.0f,\"flows\":%d}", $2, $3, $4
        first = 0
    }
    END {
        if (cur != "") printf "]}"
        printf "]\n"
    }' > "$tmp"
    mv "$tmp" "$CACHE"

    printf '{"ok":true,"msg":"collected %s","devices":%d}\n' \
        "${secs}s" "$(printf '%s\n' "$parsed" | awk 'NF{print $1}' | sort -u | wc -l)"
}

do_list() {
    if [ -f "$CACHE" ]; then
        cat "$CACHE"
    else
        echo '[]'
    fi
}

do_raw() {
    local secs="${1:-18}"
    case "$secs" in ''|*[!0-9]*) secs=18 ;; esac
    [ "$secs" -gt 60 ] && secs=60
    feed_lines "$secs"
}

case "$1" in
    status)  do_status ;;
    collect) do_collect "$2" ;;
    list)    do_list ;;
    raw)     do_raw "$2" ;;
    *)       echo '{"ok":false,"msg":"usage: trafficctl-netify.sh status|collect [secs]|list|raw [secs]"}'; exit 1 ;;
esac
