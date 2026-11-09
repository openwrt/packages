#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck shell=dash
# Durable per-device traffic history, accumulated per accounting period.
#
# WHY THIS EXISTS (#89, #90)
#   trafficctl-totals.sh already computes correct lifetime totals, but its store
#   is /tmp/trafficctl_totals.state — tmpfs, deliberately: that file is
#   rewritten on every LuCI poll (2-10 s) and every metrics scrape, and that
#   write volume into flash would wear the device out. So the numbers existed
#   and had nowhere durable to go. Everything here is persistence and
#   windowing; no new accounting.
#
# ONE FILE PER PERIOD
#   <dir>/<period>.tsv, where period is 2026-10-09 / 2026-W41 / 2026-10. The
#   "reset every day/week/month" request is then a no-op — a new period is a
#   new filename — and retention is a file delete rather than a rewrite of
#   everything. A finished period's file is never touched again, which also
#   means a crash can only ever damage the current one.
#
# TSV, NOT JSON
#   An interrupted write to a JSON file costs the whole file; to a TSV, its
#   last line. This runs on a device that can lose power mid-write and whose
#   store may sit on a network mount. Rewrites still go through a temp file in
#   the SAME directory and a mv, because a temp file elsewhere plus a
#   cross-filesystem mv is not atomic — and "elsewhere" is exactly what
#   happens when dir points at a mount.
#
# DELTAS, NOT SNAPSHOTS
#   A flush folds in only the growth since the previous flush, tracked in a
#   tmpfs cursor. If the live total is BELOW the cursor the accumulator was
#   reset (reboot, counter source switch), so the flush rebaselines and adds
#   nothing rather than subtracting — a reboot costs at most one interval of
#   traffic instead of corrupting the period. The cursor lives in tmpfs on
#   purpose: it must die together with the accumulator it tracks, or the first
#   flush after a reboot would subtract a stale high-water mark from a
#   restarted counter.
#
# HOW ACCURATE THE STORED NUMBERS ARE
#   Three different answers, and the store has to say which one applies rather
#   than present all three as "bytes used".
#
#   1. UNCOUNTERED OFFLOAD — "degraded". With flow offloading on and no
#      counter-flagged flowtable, an offloaded flow's counters stop moving
#      while traffic continues; if the nft-map fallback is also unavailable,
#      there is nothing left that sees those packets. The total is then a LOWER
#      BOUND that can be arbitrarily far below reality, not an approximation
#      around it. trafficctl-bytes.sh flags this, totals keeps the flag STICKY
#      per device, and it is stored per row here — a consumer must label such a
#      row, never add it to a trustworthy sum.
#
#   2. CONNTRACK SOURCE — sampled, so short flows can be missed. Conntrack
#      reports what its CURRENTLY TRACKED flows have carried, which means a
#      flow that starts and finishes entirely between two samples was never
#      seen by any of them. At the dashboard's 2 s poll that is noise; at an
#      hourly flush it would be most of the traffic. That is why `sample` is a
#      subcommand of its own, driven at sample_interval (tmpfs only, no flash
#      writes), and why the flush interval is NOT the sampling interval.
#
#   3. NFT COUNTER MAPS — cumulative since the table was built, so independent
#      of sampling rate and exact. They cannot split TCP from UDP, which is why
#      those columns report -1 rather than 0.
#
#   Common to all three: the counters are read BEFORE the shaper, so they
#   describe what arrived for a device, not what was delivered to it.
#
# NEVER IN A REQUEST PATH
#   flush is driven by its own timer. A flash write triggered by somebody
#   having a browser tab open is the wrong coupling, and if dir is on a dead
#   NFS/CIFS mount the writer blocks — which must not be able to stall a device
#   poll. Writes are wrapped in a timeout where one is available and a failure
#   parks history in a visible error state instead of retrying silently.
#
# Usage:
#   trafficctl-history.sh sample           advance the live accumulator (tmpfs only)
#   trafficctl-history.sh flush            fold live totals into the current period
#   trafficctl-history.sh read [period]    JSON rows for one period (default: current)
#   trafficctl-history.sh read <a> <b>     JSON rows aggregated over a range
#   trafficctl-history.sh periods          JSON list of stored periods
#   trafficctl-history.sh prune            drop periods beyond the retention count
#   trafficctl-history.sh status           JSON: enabled, dir, writability, last error
#   trafficctl-history.sh keeper           the procd service loop (sample + flush)
#   trafficctl-history.sh validate-dir <p>  exit 0 if p is an allowed store dir

. /usr/libexec/trafficctl/trafficctl-fw.sh

# Named by absolute path, as they must be on the router; the tests sed these
# lines into their scratch directory rather than have the shipped script carry
# test-only overrides (same approach as trafficctl-totals.sh and the ledger
# paths in trafficctl-fw.sh). All four are tmpfs: see DELTAS, NOT SNAPSHOTS
# above for why the cursor in particular must not survive a reboot.
CURSOR="/tmp/trafficctl_history.cursor"
ERRFILE="/tmp/trafficctl_history.err"
STAMP="/tmp/trafficctl_history.stamp"
LOCKD="/tmp/trafficctl_history.lock.d"
TOTALS_STATE="/tmp/trafficctl_totals.state"
IFCURSOR="/tmp/trafficctl_history.ifcursor"
# Per-period, and suffixed with the period id so a period roll starts a fresh
# one instead of needing to be cleared. tmpfs: it is rebuilt from the durable
# file whenever it is missing, which is every boot.
IFACC="/tmp/trafficctl_history.ifacc"

# Row layout, tab-separated:
#   key  mac  ip  name  rx  tx  tcp  udp  first_seen  last_seen  degraded
# key is "mac:<mac>" or "ip:<addr>" (see hist_key). Fields are appended at the
# END in later versions so an older reader keeps working, same rule the
# shape/limit record formats follow.
FORMAT=1

hist_enabled() {
    [ "$(uci -q get trafficctl.history.enabled 2>/dev/null)" = "1" ]
}

# The store directory is both a mkdir -p target and a delete target (prune
# removes *.tsv inside it), so an unconstrained value would hand the write ACL
# arbitrary directory creation plus the removal of any .tsv on the filesystem.
# That is the same mistake tctl_validate_log_file exists to prevent, and it is
# enforced HERE as well as in the rpcd setter — a value that reached the config
# by another route must not be honoured either.
#
# The allowed roots cover the cases the feature is for: the package's own state
# directory, and the usual mount points, which is where a network share or a
# USB disk lands.
HIST_DIR_DEFAULT="/etc/trafficctl/history"

hist_validate_dir() {
    local d="$1"
    case "$d" in
        */../*|*/..|../*|..) return 1 ;;
        *[\'\"\$\`\|\;\&\<\>]*) return 1 ;;
        /etc/trafficctl/*|/mnt/*|/media/*|/srv/*|/tmp/*) ;;
        *) return 1 ;;
    esac
    # A bare root would make prune's delete set the whole of /mnt.
    case "$d" in
        /etc/trafficctl/|/mnt/|/media/|/srv/|/tmp/) return 1 ;;
    esac
    return 0
}

hist_dir() {
    local d
    d=$(uci -q get trafficctl.history.dir 2>/dev/null)
    d="${d%/}"
    # An absolute path inside an allowed root, or the default. A relative path
    # would resolve against whatever directory the caller happened to be in —
    # the procd service, rpcd and an interactive shell all differ — and
    # silently scatter period files.
    hist_validate_dir "$d" || d="$HIST_DIR_DEFAULT"
    printf '%s\n' "$d"
}

hist_period_kind() {
    case "$(uci -q get trafficctl.history.period 2>/dev/null)" in
        day) printf 'day\n' ;;
        week) printf 'week\n' ;;
        *) printf 'month\n' ;;
    esac
}

hist_keep() {
    local k
    k=$(uci -q get trafficctl.history.keep 2>/dev/null)
    case "$k" in
        ''|*[!0-9]*) k=12 ;;
    esac
    [ "$k" -lt 1 ] && k=1
    [ "$k" -gt 120 ] && k=120
    printf '%s\n' "$k"
}

hist_interval() {
    local i
    i=$(uci -q get trafficctl.history.interval 2>/dev/null)
    case "$i" in
        ''|*[!0-9]*) i=3600 ;;
    esac
    # Floor of 300 s. The point of this store is to stay off the flash write
    # path; a 10 s interval would reproduce exactly the problem that put the
    # live accumulator in tmpfs.
    [ "$i" -lt 300 ] && i=300
    printf '%s\n' "$i"
}

# How often the live accumulator is advanced. Separate from the flush interval
# and much shorter, because of accuracy note 2 above: with a conntrack source,
# anything that starts and ends between two samples is invisible. This costs a
# conntrack read and a tmpfs write, and never touches flash.
hist_sample_interval() {
    local i
    i=$(uci -q get trafficctl.history.sample_interval 2>/dev/null)
    case "$i" in
        ''|*[!0-9]*) i=60 ;;
    esac
    [ "$i" -lt 10 ] && i=10
    [ "$i" -gt 3600 ] && i=3600
    printf '%s\n' "$i"
}

# Period id for a timestamp. ISO week uses %G with %V, not %Y: in the days
# where the calendar year and the ISO week year disagree, %Y-%V names a week
# that belongs to the other year and two different weeks collide on one id.
hist_period_id() {
    local when="${1:-}" kind
    kind=$(hist_period_kind)
    case "$kind" in
        day)   set -- '+%Y-%m-%d' ;;
        week)  set -- '+%G-W%V' ;;
        *)     set -- '+%Y-%m' ;;
    esac
    if [ -n "$when" ]; then
        date -d "@$when" "$1" 2>/dev/null || date "$1"
    else
        date "$1"
    fi
}

hist_file() { printf '%s/%s.tsv\n' "$(hist_dir)" "$1"; }

# Interface totals live in their OWN file per period, not as an extra record
# type in the device file (#102).
#
# The issue proposed a type column. A separate file is better for the reason
# that matters here: hist_read emits every row it finds as a device, so an
# interface row sharing the file would be reported AS a device by any reader
# that predates the change — including the History tab as shipped in v1.22.0.
# A file the old reader never opens cannot be misread.
hist_iffile() { printf '%s/%s.if.tsv\n' "$(hist_dir)" "$1"; }

# Per-interface accumulation can be turned off on its own: on a single-WAN
# router it is a handful of rows nobody reads, and the point of the feature is
# multi-WAN.
hist_ifaces_enabled() {
    [ "$(uci -q get trafficctl.history.interfaces 2>/dev/null)" != "0" ]
}

hist_err_set() {
    printf '%s\t%s\n' "$(date +%s)" "$1" > "$ERRFILE" 2>/dev/null
    tctl_log config "history: $1" 2>/dev/null || true
}
hist_err_clear() { rm -f "$ERRFILE" 2>/dev/null; }

# Wrap a durable write so a hung mount cannot park this process for ever.
# BusyBox ships timeout, but not every build enables it, so its absence
# degrades to an unguarded call rather than to no write at all.
hist_guard() {
    if command -v timeout >/dev/null 2>&1; then
        timeout 15 "$@"
    else
        "$@"
    fi
}

# "mac:<mac>" where a MAC can be established, else "ip:<addr>".
#
# IP is the wrong key for history even though it is the right one for live
# monitoring: a device offline for a week comes back on a different lease, and
# its old address gets handed to something else — so IP-keyed history silently
# merges two devices. MAC is stable.
#
# It is not always available. Clients behind a downstream router and anything
# in extra_subnets have no lease and no neighbour entry here, and
# tctl_ip_is_nexthop deliberately refuses a router's own MAC (it is the source
# of every packet it forwards, so trusting it would collapse a whole subnet
# into one row). Those get an ip: key, marked as such, so the UI can say which
# history is stable and which is best-effort.
#
# A device that appears first without a MAC and later with one gets a SECOND
# row rather than having the first adopted. Adoption would be a guess that the
# two are the same device, and the case it would fix (a routed client moving
# onto the local LAN) is rare while the case it would break (an address reused
# by something else) silently merges unrelated traffic.
hist_key() {
    local ip="$1" mac
    mac=$(tctl_target_mac "$ip" 2>/dev/null) || mac=""
    if [ -n "$mac" ]; then
        printf 'mac:%s\t%s\n' "$mac" "$mac"
    else
        printf 'ip:%s\t-\n' "$ip"
    fi
}

# Name precedence: manual alias > DHCP lease > cached reverse DNS — the same
# order trafficctl-summary.sh applies. It is reimplemented here rather than
# shared because summary resolves names for every device in one awk pass on a
# 2 s poll, and this runs once an hour for a handful of changed rows; the
# ORDER is the part that must not diverge.
hist_name() {
    local ip="$1" n
    n=$(awk -v ip="$ip" -F'[ \t]+' '$1 == ip { $1 = ""; sub(/^[ \t]+/, ""); print; exit }' \
        /etc/trafficctl/names 2>/dev/null)
    [ -n "$n" ] && { printf '%s\n' "$n"; return 0; }
    n=$(awk -v ip="$ip" '$3 == ip && $4 != "*" { print $4; exit }' \
        "${TCTL_LEASES_FILE:-/tmp/dhcp.leases}" 2>/dev/null)
    [ -n "$n" ] && { printf '%s\n' "$n"; return 0; }
    n=$(awk -v ip="$ip" -F'\t' '$1 == ip && $2 != "-" { print $2; exit }' \
        /tmp/trafficctl_rdns_cache 2>/dev/null)
    [ -n "$n" ] && [ "$n" != "-" ] && { printf '%s\n' "$n"; return 0; }
    printf '\n'
}

# Tabs and newlines would corrupt the row format; a name comes from a DHCP
# lease or a PTR record, neither of which this script controls.
hist_sanitize() {
    printf '%s' "$1" | tr -d '\t\r\n' | cut -c1-64
}

hist_lock() {
    local tries=0
    while ! mkdir "$LOCKD" 2>/dev/null; do
        tries=$((tries + 1))
        if [ "$tries" -ge 50 ]; then
            # Steal rather than skip for ever: a stale lock from a killed
            # flush must not freeze history permanently. Losing one interval
            # to an interleaved write is the lesser failure.
            rmdir "$LOCKD" 2>/dev/null || true
            mkdir "$LOCKD" 2>/dev/null || return 1
            return 0
        fi
        sleep 0.1 2>/dev/null || sleep 1
    done
    return 0
}
hist_unlock() { rmdir "$LOCKD" 2>/dev/null || true; }

# ──────────────────────────────────────────────────────────────────────────────
# flush
# ──────────────────────────────────────────────────────────────────────────────
hist_flush() {
    local dir pid file tmp now sample keys ip line rc=0

    hist_enabled || { printf '{"ok":false,"reason":"disabled"}\n'; return 0; }

    dir=$(hist_dir)
    if ! hist_guard mkdir -p "$dir" 2>/dev/null; then
        hist_err_set "cannot create $dir"
        printf '{"ok":false,"reason":"mkdir failed","dir":"%s"}\n' "$dir"
        return 1
    fi
    if [ ! -w "$dir" ]; then
        hist_err_set "$dir is not writable"
        printf '{"ok":false,"reason":"not writable","dir":"%s"}\n' "$dir"
        return 1
    fi

    pid=$(hist_period_id)
    file=$(hist_file "$pid")
    now=$(date +%s)

    hist_lock || {
        printf '{"ok":false,"reason":"locked"}\n'
        return 1
    }
    # shellcheck disable=SC2064 # expand now, not at trap time
    trap "hist_unlock" EXIT INT TERM

    sample="/tmp/.trafficctl_history.sample.$$"
    tmp="$dir/.history.$pid.$$"
    # shellcheck disable=SC2064
    trap "rm -f '$sample' '$tmp'; hist_unlock" EXIT INT TERM

    # --all so a device whose last flow expired still reports the total it has
    # accumulated; without it a quiet device's growth would be dropped from
    # every flush it happened to be idle for.
    /usr/libexec/trafficctl/trafficctl-totals.sh --all 2>/dev/null \
        | sed 's/},{/}\n{/g' > "$sample"
    if [ ! -s "$sample" ]; then
        hist_err_set "totals produced nothing"
        printf '{"ok":false,"reason":"no sample"}\n'
        return 1
    fi

    # Resolve key/mac/name per address in the shell, where tctl_* lives, and
    # hand awk a plain table. Doing it the other way round would mean calling
    # out of awk per device.
    keys="/tmp/.trafficctl_history.keys.$$"
    # shellcheck disable=SC2064
    trap "rm -f '$sample' '$tmp' '$keys'; hist_unlock" EXIT INT TERM
    : > "$keys"
    while IFS= read -r line; do
        case "$line" in
            *'"ip":"'*) ;;
            *) continue ;;
        esac
        ip=${line#*\"ip\":\"}
        ip=${ip%%\"*}
        tctl_validate_ip "$ip" || continue
        printf '%s\t%s\t%s\n' "$ip" "$(hist_key "$ip")" "$(hist_sanitize "$(hist_name "$ip")")" >> "$keys"
    done < "$sample"

    awk -v sample="$sample" -v keys="$keys" -v cursor="$CURSOR" -v out="$tmp" \
        -v store="$file" -v now="$now" '
    function num(line, key,   re, seg) {
        re = "\"" key "\"[ \t]*:[ \t]*"
        if (!match(line, re)) return -1
        seg = substr(line, RSTART + RLENGTH)
        if (!match(seg, /^[0-9]+/)) return -1
        return substr(seg, RSTART, RLENGTH) + 0
    }
    BEGIN {
        FS = "\t"
        # Created unconditionally and up front. If this file did not exist on
        # a flush that nonetheless rewrote the period file, the mv below would
        # fail, the cursor would stay behind, and the NEXT flush would fold the
        # same growth in a second time.
        cf = cursor ".new"
        printf "" > cf
        while ((getline l < keys) > 0) {
            n = split(l, f, "\t")
            if (n < 3) continue
            kkey[f[1]] = f[2]; kmac[f[1]] = f[3]; kname[f[1]] = f[4]
        }
        close(keys)

        # Cursor: key -> what has already been folded in.
        while ((getline l < cursor) > 0) {
            n = split(l, f, "\t")
            if (n < 5) continue
            crx[f[1]] = f[2] + 0; ctx[f[1]] = f[3] + 0
            ctc[f[1]] = f[4] + 0; cud[f[1]] = f[5] + 0
            seen_cursor[f[1]] = 1
        }
        close(cursor)

        # Existing rows for this period.
        while ((getline l < store) > 0) {
            if (l ~ /^#/) continue
            n = split(l, f, "\t")
            if (n < 10) continue
            k = f[1]
            order[++norder] = k
            rmac[k] = f[2]; rip[k] = f[3]; rname[k] = f[4]
            rrx[k] = f[5] + 0; rtx[k] = f[6] + 0
            rtc[k] = f[7] + 0; rud[k] = f[8] + 0
            rfirst[k] = f[9] + 0; rlast[k] = f[10] + 0
            rdeg[k] = (n >= 11 ? f[11] : "false")
            have[k] = 1
        }
        close(store)

        while ((getline line < sample) > 0) {
            if (line !~ /"ip":"/) continue
            ip = line
            sub(/^.*"ip":"/, "", ip)
            sub(/".*$/, "", ip)
            if (!(ip in kkey)) continue
            k = kkey[ip]

            lrx = num(line, "bytes_in_total");  if (lrx < 0) lrx = 0
            ltx = num(line, "bytes_out_total"); if (ltx < 0) ltx = 0
            ltc = num(line, "bytes_tcp_total")
            lud = num(line, "bytes_udp_total")
            deg = "false"
            if (index(line, "\"degraded\":true") > 0) deg = "true"

            # Two addresses can map to ONE key within a flush (a device that
            # changed lease while the cursor still remembers both), so the
            # live reading for a key is the sum over its addresses, and the
            # cursor comparison happens once, after the loop.
            arx[k] += lrx; atx[k] += ltx
            if (ltc >= 0) { atc[k] += ltc; ktc[k] = 1 }
            if (lud >= 0) { aud[k] += lud; kud[k] = 1 }
            if (deg == "true") adeg[k] = "true"
            amac[k] = kmac[ip]; aip[k] = ip
            if (kname[ip] != "") aname[k] = kname[ip]
            touched[k] = 1
        }
        close(sample)

        for (k in touched) {
            lrx = arx[k] + 0; ltx = atx[k] + 0
            ltc = -1
            if (k in ktc) ltc = atc[k] + 0
            lud = -1
            if (k in kud) lud = aud[k] + 0

            # Growth only. A live value below the cursor means the accumulator
            # restarted; rebaseline and add nothing, because the bytes it is
            # now below by were already folded in.
            drx = lrx
            dtx = ltx
            if (seen_cursor[k]) {
                drx = 0
                dtx = 0
                if (lrx >= crx[k]) drx = lrx - crx[k]
                if (ltx >= ctx[k]) dtx = ltx - ctx[k]
            }
            dtc = -1; dud = -1
            if (ltc >= 0) {
                if (!seen_cursor[k] || ctc[k] < 0) dtc = ltc
                else dtc = (ltc >= ctc[k]) ? ltc - ctc[k] : 0
            }
            if (lud >= 0) {
                if (!seen_cursor[k] || cud[k] < 0) dud = lud
                else dud = (lud >= cud[k]) ? lud - cud[k] : 0
            }

            if (!(k in have)) {
                order[++norder] = k
                have[k] = 1
                rfirst[k] = now
                rrx[k] = 0; rtx[k] = 0; rtc[k] = 0; rud[k] = 0
                rdeg[k] = "false"
            }
            rrx[k] += drx; rtx[k] += dtx
            if (dtc >= 0) rtc[k] += dtc
            if (dud >= 0) rud[k] += dud
            if (amac[k] != "" && amac[k] != "-") rmac[k] = amac[k]
            rip[k] = aip[k]
            # Keep the last name we knew. A device that goes offline loses its
            # lease, so re-reading an empty name over a good one would erase
            # the only label its history will ever have.
            if (aname[k] != "") rname[k] = aname[k]
            if (adeg[k] == "true") rdeg[k] = "true"
            # Only movement counts as activity. A device sitting idle should
            # not keep refreshing last_seen for a whole month.
            if (drx > 0 || dtx > 0) rlast[k] = now
            else if (rlast[k] == 0) rlast[k] = now

            ncrx[k] = lrx; nctx[k] = ltx; nctc[k] = ltc; ncud[k] = lud
            written[k] = 1
        }

        printf "# trafficctl-history %d\n", 1 > out
        for (i = 1; i <= norder; i++) {
            k = order[i]
            if (!(k in have) || emitted[k]) continue
            emitted[k] = 1
            nm = rname[k]; if (nm == "") nm = "-"
            mc = rmac[k]; if (mc == "") mc = "-"
            dg = rdeg[k]; if (dg == "") dg = "false"
            printf "%s\t%s\t%s\t%s\t%.0f\t%.0f\t%.0f\t%.0f\t%d\t%d\t%s\n", \
                k, mc, rip[k], nm, rrx[k], rtx[k], rtc[k], rud[k], \
                rfirst[k], rlast[k], dg > out
        }
        close(out)

        # The cursor keeps keys that were NOT in this sample: a device absent
        # for one flush must not have its next reading treated as a fresh
        # baseline, or its whole lifetime total would be folded in twice.
        for (k in seen_cursor) {
            if (k in written) continue
            printf "%s\t%.0f\t%.0f\t%.0f\t%.0f\n", k, crx[k], ctx[k], ctc[k], cud[k] > cf
        }
        for (k in written) {
            printf "%s\t%.0f\t%.0f\t%.0f\t%.0f\n", k, ncrx[k], nctx[k], nctc[k], ncud[k] > cf
        }
        close(cf)
    }' </dev/null || rc=1

    if [ "$rc" != 0 ] || [ ! -f "$tmp" ]; then
        hist_err_set "flush computation failed"
        printf '{"ok":false,"reason":"compute failed"}\n'
        return 1
    fi

    # Temp file in the SAME directory, so this mv is a rename inside one
    # filesystem and therefore atomic. A reader never sees a half-written
    # period file.
    if ! hist_guard mv "$tmp" "$file" 2>/dev/null; then
        hist_err_set "cannot write $file"
        printf '{"ok":false,"reason":"write failed","file":"%s"}\n' "$file"
        return 1
    fi
    # The cursor advances ONLY after the period file is safely in place.
    # Advancing it first and then failing the write would discard the deltas
    # for good; this way the same growth is simply folded in next time.
    mv "$CURSOR.new" "$CURSOR" 2>/dev/null || true
    printf '%s\n' "$now" > "$STAMP" 2>/dev/null
    hist_err_clear

    # Only after the device file is safely in place. A failure here is not a
    # failure of the flush: the interface series is additive, and losing one
    # interval of it must not make the caller think the device totals did not
    # land.
    hist_if_flush || hist_err_set "interface totals could not be written"


    printf '{"ok":true,"period":"%s","devices":%s,"at":%s}\n' \
        "$pid" "$(grep -vc '^#' "$file" 2>/dev/null || echo 0)" "$now"
}

# ──────────────────────────────────────────────────────────────────────────────
# Interface totals (#102)
#
# A SECOND SERIES, not a breakdown of the device one, and the distinction is
# not pedantry:
#
#   * these bytes are the kernel's own interface counters, read by
#     trafficctl-ifaces.sh out of /proc/net/dev. They include the router's own
#     traffic, broadcast, and everything per-device accounting cannot
#     attribute, so they legitimately DISAGREE with the sum over devices.
#   * under flow offloading they are the MORE trustworthy of the two, because
#     they come from the driver rather than from conntrack — exactly inverted
#     from the device series, where offload is what degrades accuracy. Hence
#     hist_if_accuracy below, which must not inherit the device verdict.
#   * they answer a question the device series cannot: how much went out of
#     wan1 versus wan2 this month. A device's bytes carry no egress interface.
#
# rx/tx are relative to the INTERFACE, not to a client: rx on the WAN device
# is download, rx on br-lan is what the LAN sent upstream. Stored as read,
# with the role, so a consumer can label them rather than guess.
# ──────────────────────────────────────────────────────────────────────────────

# Interfaces whose bytes are already counted somewhere else, and would
# double-count if recorded:
#   enslaved — a bridge port; its traffic is in the bridge's own counters
#   lo       — loopback
#   the IFB  — a mirror of LAN ingress that the shaper creates, so every byte
#              on it is a byte already counted on the device it mirrors
hist_if_skip() {
    local dev="$1" enslaved="$2" ifb
    [ "$dev" = "lo" ] && return 0
    [ "$enslaved" = "true" ] && return 0
    ifb=$(uci -q get trafficctl.main.shape_ifb 2>/dev/null)
    [ -n "$ifb" ] && [ "$dev" = "$ifb" ] && return 0
    return 1
}

# What the interface series is worth. NOT the device verdict: an interface
# counter comes from the driver, so uncountered offload — the thing that makes
# the device totals a lower bound — does not touch it. Reporting "degraded"
# here would be its own kind of wrong.
hist_if_accuracy() {
    printf 'exact\n'
}

# Fold the interface counters into the current period, exactly as the device
# flush does: growth against a tmpfs cursor, and a live value below the cursor
# means the counter restarted rather than that traffic went backwards.
#
# An interface counter restarting is NOT an edge case here. It happens every
# time the link goes down, which on the multi-WAN box this feature is for is
# routine — so a flap costs one sampling interval instead of corrupting the
# month.
# Fold the growth since the last tick into the tmpfs accumulator and advance
# the cursor. Called on every sample tick, because a cursor that only moved at
# flush time lost up to a whole flush interval of a link's traffic whenever its
# counter restarted — an hour by default, on exactly the multi-WAN box with a
# flapping link this series exists for (#111). The accumulator is in tmpfs, so
# touching it every 60s costs no flash.
#
# The durable file is written by hist_if_flush alone. The accumulator is seeded
# from it when absent (every boot, and on a period roll), which is what makes
# the eventual copy-over safe rather than double-counting.
hist_if_accumulate() {
    local dir pid file tmp now sample acc rc=0
    hist_ifaces_enabled || return 0
    dir=$(hist_dir)
    pid=$(hist_period_id)
    file=$(hist_iffile "$pid")
    acc="$IFACC.$pid"
    now=$(date +%s)
    sample="/tmp/.trafficctl_history.ifsample.$$"
    tmp="$acc.$$"
    [ -f "$acc" ] && file="$acc"
    # shellcheck disable=SC2064
    trap "rm -f '$sample' '$tmp'" EXIT INT TERM

    /usr/libexec/trafficctl/trafficctl-ifaces.sh 2>/dev/null \
        | sed 's/},{/}\n{/g' > "$sample"
    [ -s "$sample" ] || return 0

    awk -v sample="$sample" -v cursor="$IFCURSOR" -v out="$tmp" -v store="$file" \
        -v now="$now" -v ifb="$(uci -q get trafficctl.main.shape_ifb 2>/dev/null)" '
    function num(line, key,   re, seg) {
        re = "\"" key "\"[ \t]*:[ \t]*"
        if (!match(line, re)) return -1
        seg = substr(line, RSTART + RLENGTH)
        if (!match(seg, /^[0-9]+/)) return -1
        return substr(seg, RSTART, RLENGTH) + 0
    }
    function str(line, key,   re, seg) {
        re = "\"" key "\"[ \t]*:[ \t]*\""
        if (!match(line, re)) return ""
        seg = substr(line, RSTART + RLENGTH)
        if (!match(seg, /"/)) return ""
        return substr(seg, 1, RSTART - 1)
    }
    BEGIN {
        FS = "\t"
        cf = cursor ".new"
        printf "" > cf
        while ((getline l < cursor) > 0) {
            n = split(l, f, "\t")
            if (n < 3) continue
            crx[f[1]] = f[2] + 0; ctx[f[1]] = f[3] + 0
            seen[f[1]] = 1
        }
        close(cursor)
        while ((getline l < store) > 0) {
            if (l ~ /^#/) continue
            n = split(l, f, "\t")
            if (n < 7) continue
            d = f[1]
            order[++norder] = d
            role[d] = f[2]; label[d] = f[3]
            rrx[d] = f[4] + 0; rtx[d] = f[5] + 0
            first[d] = f[6] + 0; last[d] = f[7] + 0
            have[d] = 1
        }
        close(store)

        while ((getline line < sample) > 0) {
            if (line !~ /"dev":"/) continue
            d = str(line, "dev")
            if (d == "") continue
            if (d == "lo") continue
            if (index(line, "\"enslaved\":true") > 0) continue
            if (ifb != "" && d == ifb) continue
            lrx = num(line, "rx_bytes"); if (lrx < 0) continue
            ltx = num(line, "tx_bytes"); if (ltx < 0) continue

            # A live counter BELOW the cursor has restarted: the link went
            # down and came back, or the driver reset it. The bytes carried
            # since then have never been counted by anything, because a
            # /proc/net/dev counter is monotonic for the lifetime of the
            # interface, so they are the delta.
            #
            # Adding nothing here is right for the DEVICE series, where the
            # live value is a conntrack sum that collapses when flows expire
            # and those bytes were already accumulated while the flows lived.
            # That premise does not transfer to an interface counter, and the
            # zero came across with the code (#111). It also made this branch
            # disagree with the unseen-interface case, which always took the
            # full counter: the same situation, a counter starting from zero,
            # handled two ways depending on whether the cursor happened to
            # remember the interface.
            drx = lrx; dtx = ltx
            if (lrx >= crx[d]) drx = lrx - crx[d]
            if (ltx >= ctx[d]) dtx = ltx - ctx[d]
            if (!(d in have)) {
                order[++norder] = d
                have[d] = 1
                first[d] = now
                rrx[d] = 0; rtx[d] = 0
            }
            rrx[d] += drx; rtx[d] += dtx
            r = str(line, "role"); if (r != "") role[d] = r
            lb = str(line, "label"); if (lb != "") label[d] = lb
            if (drx > 0 || dtx > 0) last[d] = now
            else if (last[d] == 0) last[d] = now
            ncrx[d] = lrx; nctx[d] = ltx
            written[d] = 1
        }
        close(sample)

        printf "# trafficctl-history-if 1\n" > out
        for (i = 1; i <= norder; i++) {
            d = order[i]
            if (!(d in have) || emitted[d]) continue
            emitted[d] = 1
            rl = role[d]; if (rl == "") rl = "?"
            lb = label[d]; if (lb == "") lb = "-"
            printf "%s\t%s\t%s\t%.0f\t%.0f\t%d\t%d\n", \
                d, rl, lb, rrx[d], rtx[d], first[d], last[d] > out
        }
        close(out)

        for (d in seen) if (!(d in written))
            printf "%s\t%.0f\t%.0f\n", d, crx[d], ctx[d] > cf
        for (d in written)
            printf "%s\t%.0f\t%.0f\n", d, ncrx[d], nctx[d] > cf
        close(cf)
    }' </dev/null || rc=1

    [ "$rc" = 0 ] && [ -f "$tmp" ] || return 1
    mv "$tmp" "$acc" 2>/dev/null || return 1
    # Only after the accumulator is in place, for the same reason the device
    # cursor waits for its period file: advancing first and then failing would
    # discard the growth for good, where this way it is folded in next tick.
    mv "$IFCURSOR.new" "$IFCURSOR" 2>/dev/null || true
    return 0
}

# Publish the accumulator to the durable per-period file. Picks up the final
# interval first, so no traffic is stranded in tmpfs at flush time.
hist_if_flush() {
    local pid acc file tmp
    hist_ifaces_enabled || return 0
    hist_if_accumulate || return 1
    pid=$(hist_period_id)
    acc="$IFACC.$pid"
    [ -f "$acc" ] || return 0
    file=$(hist_iffile "$pid")
    tmp="$(hist_dir)/.history-if.$pid.$$"
    # shellcheck disable=SC2064
    trap "rm -f '$tmp'" EXIT INT TERM
    hist_guard cp "$acc" "$tmp" 2>/dev/null || return 1
    hist_guard mv "$tmp" "$file" 2>/dev/null || return 1
    return 0
}

hist_if_read() {
    local dir from to files f p
    dir=$(hist_dir)
    from="$1"; to="$2"
    [ -z "$from" ] && from=$(hist_period_id)
    [ -z "$to" ] && to="$from"
    files=""
    for f in "$dir"/*.if.tsv; do
        [ -f "$f" ] || continue
        p=$(basename "$f" .if.tsv)
        [ "$p" \< "$from" ] && continue
        [ "$to" \< "$p" ] && continue
        files="$files $f"
    done
    # shellcheck disable=SC2086 # deliberate splitting over the file list
    awk -F'\t' '
    /^#/ { next }
    NF >= 7 {
        d = $1
        if (!(d in seen)) { order[++n] = d; seen[d] = 1; first[d] = $6 }
        role[d] = $2; label[d] = $3
        rx[d] += $4; tx[d] += $5
        if ($6 + 0 < first[d] + 0) first[d] = $6
        if ($7 + 0 > last[d] + 0) last[d] = $7
    }
    END {
        printf "["
        for (i = 1; i <= n; i++) {
            d = order[i]
            if (i > 1) printf ","
            printf "{\"dev\":\"%s\",\"role\":\"%s\",\"label\":\"%s\",\"bytes_in\":%.0f,\"bytes_out\":%.0f,\"first_seen\":%d,\"last_seen\":%d}", \
                d, role[d], label[d], rx[d], tx[d], first[d], last[d]
        }
        printf "]\n"
    }' $files </dev/null 2>/dev/null || printf '[]\n'
}

# ──────────────────────────────────────────────────────────────────────────────
# read / periods
# ──────────────────────────────────────────────────────────────────────────────
hist_read() {
    local dir from to files f
    dir=$(hist_dir)
    from="$1"; to="$2"
    [ -z "$from" ] && from=$(hist_period_id)
    [ -z "$to" ] && to="$from"

    files=""
    for f in "$dir"/*.tsv; do
        [ -f "$f" ] || continue
        # The interface totals are a separate series in their own file; reading
        # them here would report an interface as a device.
        case "$f" in *.if.tsv) continue ;; esac
        p=$(basename "$f" .tsv)
        # String comparison is the right one here: every period id this script
        # writes is fixed-width and zero-padded, so lexical order IS
        # chronological order. (That is why the day format is %Y-%m-%d and not
        # anything locale-shaped.)
        [ "$p" \< "$from" ] && continue
        [ "$to" \< "$p" ] && continue
        files="$files $f"
    done

    # shellcheck disable=SC2086 # deliberate word splitting over the file list
    awk -F'\t' '
    FNR == 1 { period = FILENAME; sub(/.*\//, "", period); sub(/\.tsv$/, "", period) }
    /^#/ { next }
    NF >= 10 {
        k = $1
        if (!(k in seen)) { order[++n] = k; seen[k] = 1; first[k] = $9 }
        mac[k] = ($2 != "-" ? $2 : mac[k])
        ip[k] = $3
        if ($4 != "-") name[k] = $4
        rx[k] += $5; tx[k] += $6; tc[k] += $7; ud[k] += $8
        if ($9 + 0 < first[k] + 0) first[k] = $9
        if ($10 + 0 > last[k] + 0) last[k] = $10
        if ($11 == "true") deg[k] = 1
        periods[k] = periods[k] (index(periods[k], "\"" period "\"") ? "" : (periods[k] == "" ? "" : ",") "\"" period "\"")
    }
    END {
        printf "["
        for (i = 1; i <= n; i++) {
            k = order[i]
            nm = ""
            if (k in name) nm = name[k]
            kind = "ip"
            if (k ~ /^mac:/) kind = "mac"
            if (i > 1) printf ","
            printf "{\"key\":\"%s\",\"key_kind\":\"%s\",\"mac\":\"%s\",\"ip\":\"%s\",\"name\":\"%s\",\"bytes_in\":%.0f,\"bytes_out\":%.0f,\"bytes_tcp\":%.0f,\"bytes_udp\":%.0f,\"first_seen\":%d,\"last_seen\":%d,\"degraded\":%s,\"periods\":[%s]}", \
                k, kind, (mac[k] == "" ? "-" : mac[k]), ip[k], nm, \
                rx[k], tx[k], tc[k], ud[k], first[k], last[k], \
                (k in deg ? "true" : "false"), periods[k]
        }
        printf "]\n"
    }' $files </dev/null 2>/dev/null || printf '[]\n'
}

hist_periods() {
    local dir f p
    dir=$(hist_dir)
    printf '['
    n=0
    for f in "$dir"/*.tsv; do
        [ -f "$f" ] || continue
        # Skip the interface companion: a period is listed once, by its device
        # file, or "2026-10" and "2026-10.if" would both appear as periods.
        case "$f" in *.if.tsv) continue ;; esac
        p=$(basename "$f" .tsv)
        [ "$n" -gt 0 ] && printf ','
        printf '{"period":"%s","devices":%s,"bytes":%s}' \
            "$p" \
            "$(grep -vc '^#' "$f" 2>/dev/null || echo 0)" \
            "$(awk -F'\t' '!/^#/ && NF >= 10 { s += $5 + $6 } END { printf "%.0f", s + 0 }' "$f" 2>/dev/null || echo 0)"
        n=$((n + 1))
    done
    printf ']\n'
}

hist_prune() {
    local dir keep pid total f dropped=0
    dir=$(hist_dir)
    keep=$(hist_keep)
    pid=$(hist_period_id)
    # The current period is never a retention candidate — it is still being
    # written to, and "keep 1" must not mean "delete the data you are
    # collecting right now".
    # A PERIOD is the unit of retention, and a period is now two files: the
    # device totals and the interface totals (#102). Listing *.tsv and
    # stripping .tsv would turn "2026-10.if.tsv" into a period called
    # "2026-10.if" — never equal to the current period id, so it would be
    # pruned as if it were ancient history while its device file survived.
    # Enumerate periods from the device files only, then drop both.
    # shellcheck disable=SC2046 # deliberate splitting: one word per period id
    set -- $(find "$dir" -name '*.tsv' -type f 2>/dev/null \
        | sed 's|.*/||' | grep -v '\.if\.tsv$' | sed 's|\.tsv$||' \
        | grep -vxF "$pid" | sort)
    total=$#
    while [ "$total" -gt "$keep" ] && [ "$#" -gt 0 ]; do
        rm -f "$dir/$1.tsv" 2>/dev/null && dropped=$((dropped + 1))
        rm -f "$dir/$1.if.tsv" 2>/dev/null
        total=$((total - 1))
        shift
    done
    printf '{"ok":true,"kept":%s,"dropped":%s}\n' "$keep" "$dropped"
}

# What the numbers in the store are worth right now, as one word, derived from
# the live offload mode. Reported so a consumer can label the view instead of
# presenting a lower bound as a measurement.
#
#   degraded — uncountered offload, no nft fallback: a LOWER BOUND
#   counter  — nft counter maps: exact, no protocol split
#   sampled  — conntrack: exact to within flows shorter than sample_interval
hist_accuracy() {
    local mode src
    mode=$(tctl_get_offload_mode 2>/dev/null)
    # What the sampler actually settled on last time it ran, which is the
    # authority on whether the nft fallback was available — the offload mode
    # alone cannot tell us that.
    src=$(awk '{ print $11; exit }' "$TOTALS_STATE" 2>/dev/null)
    case "$mode" in
        hardware|software)
            if [ "$src" = "nft" ]; then printf 'counter\n'; else printf 'degraded\n'; fi
            ;;
        *)
            if [ "$src" = "nft" ]; then printf 'counter\n'; else printf 'sampled\n'; fi
            ;;
    esac
}

hist_status() {
    local dir en pid last err errat w
    dir=$(hist_dir)
    en=false
    hist_enabled && en=true
    pid=$(hist_period_id)
    last=$(cat "$STAMP" 2>/dev/null)
    case "$last" in ''|*[!0-9]*) last=0 ;; esac
    err=""; errat=0
    if [ -f "$ERRFILE" ]; then
        errat=$(cut -f1 "$ERRFILE" 2>/dev/null)
        err=$(cut -f2- "$ERRFILE" 2>/dev/null)
        case "$errat" in ''|*[!0-9]*) errat=0 ;; esac
    fi
    w=false
    [ -d "$dir" ] && [ -w "$dir" ] && w=true
    printf '{"enabled":%s,"dir":"%s","writable":%s,"period":"%s","period_kind":"%s","interval":%s,"sample_interval":%s,"keep":%s,"format":%s,"last_flush":%s,"accuracy":"%s","offload":"%s","interfaces":%s,"iface_accuracy":"%s","error":"%s","error_at":%s}\n' \
        "$en" "$dir" "$w" "$pid" "$(hist_period_kind)" \
        "$(hist_interval)" "$(hist_sample_interval)" "$(hist_keep)" "$FORMAT" "$last" \
        "$(hist_accuracy)" "$(tctl_get_offload_mode 2>/dev/null)" \
        "$(hist_ifaces_enabled && echo true || echo false)" "$(hist_if_accuracy)" \
        "$(printf '%s' "$err" | tr -d '\042\134')" "$errat"
}

# The procd service loop. Two cadences in one process, which is the whole
# reason this is a service and not a cron line: sampling has to be frequent
# (accuracy note 2 — a conntrack flow shorter than the sample interval is
# invisible) and costs only a tmpfs write, while flushing is rare because it
# touches durable storage.
#
# Re-reads its own configuration every tick rather than caching it at start:
# changing the interval in the UI should take effect without the operator
# having to know there is a service to restart.
hist_keeper() {
    local last=0 now interval

    # Pick up where a previous run left off, so a restart does not reset the
    # flush clock and silently stretch the gap to the durable store.
    last=$(cat "$STAMP" 2>/dev/null)
    case "$last" in ''|*[!0-9]*) last=0 ;; esac

    while :; do
        if hist_enabled; then
            /usr/libexec/trafficctl/trafficctl-totals.sh --all >/dev/null 2>&1
            # Both series advance their tmpfs cursor on every tick. Only the
            # durable store waits for the flush interval below.
            hist_if_accumulate >/dev/null 2>&1
            now=$(date +%s)
            interval=$(hist_interval)
            # A clock that jumped backwards (NTP settling after boot, which is
            # the norm on a router with no RTC) would otherwise park the next
            # flush an interval into the past's future and stall the store.
            [ "$now" -lt "$last" ] && last=0
            if [ $((now - last)) -ge "$interval" ]; then
                hist_flush >/dev/null 2>&1
                hist_prune >/dev/null 2>&1
                last=$now
            fi
        fi
        sleep "$(hist_sample_interval)"
    done
}

case "$1" in
    sample)
        # Advance the accumulator and throw the JSON away. Cheap, tmpfs only,
        # and the thing that makes an hourly flush mean anything.
        hist_enabled || { printf '{"ok":false,"reason":"disabled"}\n'; exit 0; }
        /usr/libexec/trafficctl/trafficctl-totals.sh --all >/dev/null 2>&1
        # The interface series advances its own tmpfs cursor on the same tick.
        # Leaving it to the flush meant a counter that restarted in between
        # lost everything since the last flush, not since the last tick (#111).
        hist_if_accumulate >/dev/null 2>&1
        printf '{"ok":true,"at":%s}\n' "$(date +%s)"
        ;;
    flush)   hist_flush ;;
    keeper)  hist_keeper ;;
    # Exposed so the rpcd setter validates against THIS implementation rather
    # than a second copy of the rule that can drift away from it.
    validate-dir) hist_validate_dir "${2%/}" ;;
    read)    hist_read "$2" "$3" ;;
    read-ifaces) hist_if_read "$2" "$3" ;;
    periods) hist_periods ;;
    prune)   hist_prune ;;
    status)  hist_status ;;
    *)
        printf 'Usage: %s {sample|flush|keeper|validate-dir <path>|read [period [to]]|read-ifaces [period [to]]|periods|prune|status}\n' "$0" >&2
        exit 1
        ;;
esac
