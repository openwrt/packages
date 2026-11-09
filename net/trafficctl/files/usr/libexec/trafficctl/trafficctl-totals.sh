#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck shell=dash
# Monotonic per-device byte totals — the single accumulator behind both the
# LuCI "Bytes / TCP / UDP" columns and the trafficctl_device_bytes_total metric.
#
# WHY AN ACCUMULATOR AT ALL (issue #26)
#   Neither byte source is a lifetime total. conntrack reports what its
#   CURRENTLY TRACKED flows have carried, so a device's number collapses the
#   moment its flows age out — which is why the columns were reported showing
#   values like "2 bytes". The nft counter maps are cumulative, but only since
#   the table was created, and that table is rebuilt on upgrade and gone after
#   a reboot. A lifetime total has to be accumulated from deltas and persisted.
#
# ONE STORE, ONE IMPLEMENTATION
#   This logic used to live inline in trafficctl-metrics.sh. It was lifted out
#   rather than copied: a second accumulator with its own state file would let
#   the UI column and the Prometheus counter report different totals for the
#   same device, and that is a bug report nobody can reproduce.
#
# SOURCE SELECTION is delegated entirely to trafficctl-bytes.sh, which already
#   switches to nft counters when flow offload stops conntrack from counting —
#   so the total stays right on exactly the routers where the complaint arises.
#   That switch can happen at RUNTIME (offload toggled in the firewall config,
#   or trafficctl-bytes-nft.sh bouncing back to conntrack on a kernel without
#   dynamic counter maps), and the two sources have unrelated magnitudes. The
#   source is therefore recorded per device, and a change rebaselines instead
#   of accumulating the difference as if it were traffic.
#
# STORE: /tmp, i.e. tmpfs, so totals reset on reboot. Deliberate: this file is
#   rewritten on every LuCI poll (2–10 s) and every scrape, and that write
#   volume into flash would wear out the router. Surviving a reboot would mean
#   a periodic flush to /etc/trafficctl (kept across sysupgrade by
#   lib/upgrade/keep.d) at a much coarser interval — a separate decision.
#
# Usage: trafficctl-totals.sh [--all]
#   default : one element per device in the current sample (what the UI wants)
#   --all   : also emit devices that are no longer in the sample but still
#             carry a total, so a Prometheus series does not vanish and
#             reappear every time a quiet device's last flow expires.
#
# Output: the trafficctl-bytes.sh array, each element extended with
#   bytes_in_total / bytes_out_total / bytes_tcp_total / bytes_udp_total,
#   total_since (unix time accumulation began for that device) and live.
#   The proto totals are -1 when the active source cannot split by protocol.
#
# TRUST: "degraded" is carried through from the sampler and is STICKY per
#   device. It means the counters the total was built from are frozen for
#   offloaded flows (uncountered offload with no usable nft fallback), so the
#   total is a lower bound that stops growing while traffic continues. One
#   tainted sample understates the total for the rest of its life, so the flag
#   cannot be cleared just because the next sample looked healthy — that would
#   re-present the same understated number as trustworthy. Consumers must
#   refuse to show it as a total, exactly as they refuse to show -1 as 0.

. /usr/libexec/trafficctl/trafficctl-fw.sh

STATE="/tmp/trafficctl_totals.state"
LOCKD="/tmp/trafficctl_totals.lock.d"

ALL=0
[ "$1" = "--all" ] && ALL=1

SAMPLE="/tmp/.trafficctl_totals.sample.$$"
# Per-process, NOT a shared "$STATE.tmp". The lock below can be stolen after a
# timeout, so two writers coexisting is a reachable state rather than an
# impossible one; with a shared scratch name they would interleave lines into
# it and the surviving state file would be garbage. With one name each, the
# worst outcome is the benign one the lock is really for — a lost delta.
TMPF="/tmp/.trafficctl_totals.write.$$"
# shellcheck disable=SC2064 # expand the paths now, not at trap time
trap "rm -f '$SAMPLE' '$TMPF'" EXIT INT TERM

# Sample BEFORE taking the lock. Reading /proc/net/nf_conntrack on a busy
# router is by far the slowest thing here, and holding the lock across it would
# put every poll in a queue behind it: two browser tabs at a 2 s interval would
# then routinely hit the steal-on-timeout path below, which exists for a killed
# sampler, not for ordinary load. The file is in tmpfs and is streamed into
# awk, so this costs no more memory than the pipeline it replaces — and keeps
# the promise that no large value is ever held in a shell variable.
/usr/libexec/trafficctl/trafficctl-bytes.sh 2>/dev/null | sed 's/},{/}\n{/g' > "$SAMPLE"

# mkdir is atomic, so unlike a test-then-create lock file two samplers cannot
# both believe they hold it. Without this a LuCI poll and a metrics scrape
# landing together would read the same state, and the later writer would
# silently discard the earlier one's delta.
_tries=0
while ! mkdir "$LOCKD" 2>/dev/null; do
    _tries=$((_tries + 1))
    if [ "$_tries" -ge 30 ]; then
        # A stale directory from a killed sampler must not freeze the counters
        # for good; steal it rather than give up on accumulating.
        rmdir "$LOCKD" 2>/dev/null || true
        mkdir "$LOCKD" 2>/dev/null || break
        break
    fi
    sleep 0.1 2>/dev/null || sleep 1
done
# Re-armed only now that the lock is actually held: a signal arriving during
# the sample above must not make this process rmdir a lock it never took.
# shellcheck disable=SC2064 # expand the paths now, not at trap time
trap "rm -f '$SAMPLE' '$TMPF'; rmdir '$LOCKD' 2>/dev/null" EXIT INT TERM

NOW=$(date +%s)

# Everything from here to the end of awk is the critical section, and it is
# only a state-file read plus one pass over the sample — milliseconds.
awk -v state="$STATE" -v tmp="$TMPF" -v now="$NOW" -v all="$ALL" '
# Returns -1 for a missing key, an unparseable value, or an explicit -1 in the
# JSON — all three mean the same thing to every caller here: "not available".
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
    # State line: ip rx_acc tx_acc rx_last tx_last seen tcp_acc udp_acc
    #             tcp_last udp_last src since
    # The first six fields are byte-for-byte the layout the exporter used
    # before this script existed, so an old state file still loads.
    while ((getline l < state) > 0) {
        n = split(l, f, " ")
        if (n < 5) continue
        ip = f[1]
        rxa[ip] = f[2] + 0; txa[ip] = f[3] + 0
        rxl[ip] = f[4] + 0; txl[ip] = f[5] + 0
        known[ip] = 1
        seenat[ip] = (n >= 6 ? f[6] + 0 : now)
        if (n >= 10) {
            tca[ip] = f[7] + 0; uda[ip] = f[8] + 0
            tcl[ip] = f[9] + 0; udl[ip] = f[10] + 0
        } else {
            tcl[ip] = -1; udl[ip] = -1
        }
        srcof[ip] = (n >= 11 ? f[11] : "?")
        since[ip] = (n >= 12 ? f[12] + 0 : now)
        degof[ip] = (n >= 13 ? f[13] : "false")
    }
    close(state)
}
{
    ip = str($0, "ip")
    if (ip == "") next
    rx = num($0, "bytes_in");  if (rx < 0) rx = 0
    tx = num($0, "bytes_out"); if (tx < 0) tx = 0
    tcv = num($0, "bytes_tcp")   # -1 when the source cannot split by protocol
    udv = num($0, "bytes_udp")
    s = str($0, "src")
    if (s == "") s = "?"
    # Trust, not magnitude. Deliberately NOT folded into the source-switch test
    # below: conntrack counters are continuous across a change in trust, so
    # rebaselining on it would throw away a real delta for nothing.
    dg = "false"
    if (index($0, "\"degraded\":true") > 0) dg = "true"

    # A source switch swaps "bytes carried by live flows" for "bytes since the
    # nft table was built", or the reverse. Either way the jump is not traffic,
    # so this tick only re-establishes the baseline.
    switched = 0
    if ((ip in known) && srcof[ip] != "?" && s != "?" && srcof[ip] != s) switched = 1

    if ((ip in known) && !switched) {
        # Only upward movement is new traffic. A drop means flows expired, and
        # their bytes were already accumulated while they lived.
        if (rx > rxl[ip]) rxa[ip] += rx - rxl[ip]
        if (tx > txl[ip]) txa[ip] += tx - txl[ip]
    } else if (!switched) {
        # No baseline yet: the whole sample is the starting point, not a delta.
        rxa[ip] += rx; txa[ip] += tx
        since[ip] = now
    }
    rxl[ip] = rx; txl[ip] = tx

    if (tcv >= 0) {
        if ((ip in tcl) && tcl[ip] >= 0 && !switched) {
            if (tcv > tcl[ip]) tca[ip] += tcv - tcl[ip]
        } else if (!switched) {
            tca[ip] += tcv
        }
        tcl[ip] = tcv
    } else {
        # Gone unavailable (offload turned on mid-life). Forget the baseline so
        # that when it returns the stale value is not differenced against the
        # new one — hours of frozen counter would land as one fake delta.
        tcl[ip] = -1
    }
    if (udv >= 0) {
        if ((ip in udl) && udl[ip] >= 0 && !switched) {
            if (udv > udl[ip]) uda[ip] += udv - udl[ip]
        } else if (!switched) {
            uda[ip] += udv
        }
        udl[ip] = udv
    } else {
        udl[ip] = -1
    }

    known[ip] = 1
    srcof[ip] = s
    # Sticky: a total accumulated from frozen counters stays understated for
    # the rest of its life, so one degraded sample taints it until the counter
    # is reset. Clearing the flag as soon as the next sample looked healthy
    # would quietly re-present that same understated number as trustworthy.
    if (dg == "true") degof[ip] = "true"
    else if (!(ip in degof)) degof[ip] = "false"
    seenat[ip] = now
    live[ip] = 1
    srx[ip] = rx; stx[ip] = tx; stc[ip] = tcv; sud[ip] = udv
}
END {
    for (ip in rxl) {
        # Drop devices that have gone quiet AND carry no total, so the state
        # file cannot grow without bound on a busy network.
        if (!(ip in live) && rxa[ip] + txa[ip] + tca[ip] + uda[ip] == 0) continue
        sv = srcof[ip]; if (sv == "") sv = "?"
        dv = degof[ip]; if (dv == "") dv = "false"
        printf "%s %.0f %.0f %.0f %.0f %d %.0f %.0f %.0f %.0f %s %d %s\n", \
            ip, rxa[ip], txa[ip], rxl[ip], txl[ip], seenat[ip], \
            tca[ip]+0, uda[ip]+0, tcl[ip], udl[ip], sv, since[ip], dv > tmp
    }
    close(tmp)
    system("mv " tmp " " state " 2>/dev/null")

    printf "["
    n = 0
    for (ip in rxl) {
        islive = 0
        if (ip in live) islive = 1
        if (!islive && !all) continue

        # A device absent from this sample has no CURRENT reading at all.
        # Re-emitting its last one would hand a consumer a frozen number that
        # looks live, with only the "live" flag to give it away — so the raw
        # fields report -1, "not sampled", the same sentinel the protocol split
        # uses. The accumulated totals below are unaffected: those are real
        # history and stay exact.
        crx = -1; ctx = -1; ctc = -1; cud = -1
        if (islive) { crx = srx[ip]; ctx = stx[ip]; ctc = stc[ip]; cud = sud[ip] }

        # -1, never 0, when the source cannot split by protocol: a UI that
        # printed 0 would be claiming the device sent no TCP. Keyed off the
        # stored baseline rather than this sample, so a quiet device under
        # --all still reports the protocol history it does have.
        #
        # These MUST stay value tests. `(ip in tcl)` would be true for every
        # device by the time control reaches here: the state-writing loop above
        # reads tcl[ip] and tca[ip] by subscript, and merely referencing an awk
        # array element creates it. A membership test would then report 0 bytes
        # of TCP — a confident wrong answer — for devices that never had a
        # protocol reading at all.
        tt = -1; if (tcl[ip] >= 0) tt = tca[ip] + 0
        ut = -1; if (udl[ip] >= 0) ut = uda[ip] + 0
        # Hoisted out of the printf argument list rather than inlined as
        # ternaries: BusyBox awk is the interpreter on the target and has been
        # seen to mis-parse expressions in call arguments (see the note in
        # trafficctl-metrics.sh), and a silently dropped statement here would
        # corrupt the JSON for every consumer.
        sv = srcof[ip]; if (sv == "") sv = "?"
        lv = "false"; if (islive) lv = "true"
        dv = degof[ip]; if (dv == "") dv = "false"
        if (n > 0) printf ","
        printf "{\"ip\":\"%s\",\"bytes_in\":%.0f,\"bytes_out\":%.0f,\"bytes_tcp\":%.0f,\"bytes_udp\":%.0f,\"src\":\"%s\",\"degraded\":%s,\"bytes_in_total\":%.0f,\"bytes_out_total\":%.0f,\"bytes_tcp_total\":%.0f,\"bytes_udp_total\":%.0f,\"total_since\":%d,\"live\":%s}", \
            ip, crx, ctx, ctc, cud, sv, dv, \
            rxa[ip], txa[ip], tt, ut, since[ip], lv
        n++
    }
    printf "]\n"
}' "$SAMPLE"
