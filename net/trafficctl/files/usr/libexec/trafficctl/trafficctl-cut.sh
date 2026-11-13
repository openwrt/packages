#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# shellcheck shell=dash
# Global internet cut — every device loses the internet, the LAN keeps working.
#
# Usage:
#   trafficctl-cut.sh engage <seconds|0> [persist]   0 seconds = indefinite
#   trafficctl-cut.sh release
#   trafficctl-cut.sh status
#   trafficctl-cut.sh restore          (boot path, from the ifup-lan hotplug)
#   trafficctl-cut.sh tick             (one keeper iteration)
#   trafficctl-cut.sh keeper           (the procd-supervised loop)
#
# ── Why an own table, not `inet fw4` ──────────────────────────────────────
#
# Per-device blocks insert into `inet fw4 forward`, and fw4 tears that table
# down and rebuilds it on every reload — a plain firewall config change from
# any other app is enough. The restore hook only fires on `ifup lan`, so a bare
# `fw4 reload` drops the rule with nothing to put it back. For per-device
# blocks that is a known wart; for a control whose whole purpose is "this
# device must not reach the internet while I set it up" it is the worst
# possible failure: the rule lapses, the toggle still reads ON, and the new TV
# is on the internet while the UI says it is not.
#
# So the cut lives in its own table (`inet tctl_cut`), the way port-forward
# control already uses `inet tctl_pfw` and the limiter uses `netdev
# tm_ratelimit`. fw4 deletes its own tables, not ours, so the rule survives a
# firewall rebuild structurally rather than by being noticed and re-added.
# The keeper below still re-asserts it, because a wholesale `nft flush ruleset`
# (or `fw4 flush`) takes every table with it.
#
# ── Why prerouting, not just forward ──────────────────────────────────────
#
# A forward-hook rule only sees traffic the router FORWARDS. On a router
# running a transparent proxy — podkop/sing-box, passwall, homeproxy — that is
# not where client traffic goes. TPROXY intercepts at prerouting and delivers
# the packet LOCALLY; the proxy then originates its own outbound connections
# from the router. Neither leg is forwarded: client→router is input,
# router→internet is output. A forward-only cut misses all of it, and on such a
# router that is the bulk of the traffic, not an edge case. The toggle would
# read ON, the rule would genuinely be present, and the new TV would keep
# browsing — the exact lie this feature exists to not tell.
#
# So the primary rule sits at prerouting priority -300, ahead of every hook
# anything else is likely to use, and catches traffic on the way in, before
# anything can divert it. The forward chain is kept as a second layer.
#
# Traffic the router originates ITSELF never traverses prerouting (it goes
# output→postrouting), so the proxy's own outbound path, the router's VPN
# tunnels and its DNS are untouched — only traffic arriving FROM a LAN device
# is considered.
#
# ── Why interface matching ────────────────────────────────────────────────
#
# Both chains say the same thing: "traffic from a LAN device that is not going
# to stay on the LAN is dropped". Interfaces, not addresses, because:
#
#   * IPv4 and IPv6 are both cut by the same rules. The per-device block
#     matches `ip saddr` and is v4-only; for a global cut a device holding a
#     SLAAC address would walk straight out over v6 while the UI claimed the
#     internet was off.
#   * LAN↔LAN keeps working, including between VLANs/bridges and out to
#     downstream routed subnets — those all resolve to a LAN device.
#   * Same-subnet traffic is bridged and reaches neither hook at all.
#
# At prerouting there is no `oifname` yet — the routing decision has not
# happened — so the equivalent question is asked of the FIB: `fib daddr . iif
# oifname` is the interface the packet would leave by. `fib daddr type local`
# answers the more important one first: is this addressed to the router? LuCI,
# SSH, DNS, DHCP and a VPN terminating ON the router all match it and are
# accepted before any of the LAN-device reasoning is consulted, so they survive
# even if that reasoning is wrong.
#
# Inbound flows (WAN→LAN through a port forward) are deliberately NOT cut:
# those exist only where the operator created a forward, this app already has
# a dedicated control for them, and killing them would remove yet another
# remote-admin path from an operator who is about to lose their LAN-hosted one.

. /usr/libexec/trafficctl/trafficctl-fw.sh

# Same priority as port-forward control: after DNAT, and before fw4's
# flowtable rule at filter priority 0 — otherwise an offloaded flow would
# bypass the drop entirely.
CUT_PRIO="-190"
# Earlier than any prerouting hook something else is likely to use: raw (-300)
# sits ahead of conntrack (-200), mangle (-150) and dstnat (-100). podkop /
# sing-box TPROXY at dstnat; passwall and homeproxy at mangle.
CUT_PRE_PRIO="-300"
CUT_COMMENT="tctl_cut"

# The engaged state lives in tmpfs, and that is the whole point: a reboot must
# clear it. This is the one control in the app that can lock out its own
# operator — anyone administering the router through a LAN host (Tailscale on a
# NAS, a Cloudflare tunnel from a LAN box, a jump host) loses that path when
# the cut goes on, and persistent state would mean a reboot does not bring it
# back either. The remedy would become "be physically present".
CUT_RUN_DIR="/var/run/trafficctl"
CUT_STATE="/var/run/trafficctl/cut.state"

# The opt-in copy. Written only when the operator ticks "keep after reboot",
# and deliberately NOT listed in lib/upgrade/keep.d/trafficctl: a cut that outlives a
# firmware upgrade is strictly worse than one that outlives a reboot.
CUT_PERSIST_STATE="/etc/trafficctl/cut.state"

CUT_INIT="/etc/init.d/trafficctl-cut"
CUT_TICK_SECS=5

# 0 means indefinite. Anything else is clamped to a sane window: a minute is
# the shortest cut worth the conntrack flush, a week the longest that still
# reads as "temporary".
CUT_MIN_SECS=60
CUT_MAX_SECS=604800

now() { date +%s; }

json_esc() { printf '%s' "$1" | sed 's/\\/\\\\/g;s/"/\\"/g'; }

fail() {
	printf '{"ok":false,"msg":"%s"}\n' "$(json_esc "$1")"
	exit 1
}

# ── LAN device set ─────────────────────────────────────────────────────────

# The devices whose traffic stays local. Empty is not an answer we can act on:
# "drop everything not leaving via a LAN device" with no LAN devices means
# "drop everything forwarded", which blackholes the LAN this feature promises
# to keep working. Callers must refuse rather than guess.
cut_lan_devices() {
	tctl_get_lan_devices
}

# nft anonymous set literal: { "br-lan", "br-guest" }
cut_lan_set() {
	local devs="$1" dev out=""
	for dev in $devs; do
		if [ -n "$out" ]; then
			out="$out, \"$dev\""
		else
			out="\"$dev\""
		fi
	done
	printf '{ %s }' "$out"
}

# ── nft plumbing ───────────────────────────────────────────────────────────

cut_supported() {
	[ "$TCTL_FW" = "nft" ]
}

# Live state, which is the only honest answer to "is the internet cut?".
# The full quoted comment is matched, not a substring: the codebase learned
# that lesson when unblocking 192.168.1.1 deleted the rule for 192.168.1.10.
cut_rule_present() {
	nft list table inet tctl_cut 2>/dev/null | grep -qF "\"$CUT_COMMENT\""
}

# "full" once the prerouting chain is in place, "forward" when only the
# forward chain could be installed. Read from the kernel, never remembered.
cut_coverage() {
	local dump
	dump=$(nft list table inet tctl_cut 2>/dev/null) || { echo none; return 1; }
	printf '%s' "$dump" | grep -qF "\"$CUT_COMMENT\"" || { echo none; return 1; }
	if printf '%s' "$dump" | grep -q "hook prerouting"; then
		echo full
	else
		echo forward
	fi
}

# Is something on this router intercepting traffic transparently?
#
# podkop/sing-box, passwall and homeproxy all TPROXY at prerouting and deliver
# the packet LOCALLY — it is never forwarded, so the forward hook never sees
# it. A forward-only cut on such a router misses the bulk of the traffic while
# the UI reports the internet as off, which is precisely the failure this
# feature exists to not have. Only consulted on the degraded path, because
# listing the whole ruleset is not something to do on every UI poll.
cut_proxy_intercept() {
	nft list ruleset 2>/dev/null | grep -q 'tproxy'
}

# The ruleset, emitted as one atomic `nft -f` transaction.
#
# Atomic matters more than it looks. Adding these rules one at a time would, on
# a kernel without nft_fib, apply the accepts that parse and the final drop —
# and a prerouting drop without its router-local escape hatch black-holes the
# LAN including LuCI. All-or-nothing means a kernel that cannot do this gets
# nothing at all, and we fall back deliberately instead of by accident.
#
# Rule order is a safety property, not a style choice. `fib daddr type local`
# comes FIRST, before anything that depends on the LAN device list being
# correct: whatever else is wrong, traffic addressed to the router — LuCI, SSH,
# DNS, DHCP, a VPN terminating here — is accepted.
cut_ruleset() {
	local devs="$1" mode="$2" set_expr pre=""
	set_expr=$(cut_lan_set "$devs")

	if [ "$mode" = "full" ]; then
		pre=$(cat <<EOF
	chain cut_prerouting {
		type filter hook prerouting priority $CUT_PRE_PRIO; policy accept;
		fib daddr type { local, broadcast, multicast } accept
		ip6 daddr fe80::/10 accept
		iifname != $set_expr accept
		fib daddr . iif oifname $set_expr accept
		counter drop comment "$CUT_COMMENT"
	}
EOF
)
	fi

	cat <<EOF
add table inet tctl_cut
delete table inet tctl_cut
table inet tctl_cut {
$pre
	chain cut_forward {
		type filter hook forward priority $CUT_PRIO; policy accept;
		oifname != $set_expr counter drop comment "$CUT_COMMENT"
	}
}
EOF
}

# The prerouting chain must actually carry its escape hatch. A chain that
# loaded without it would be a total LAN lockout, so it is checked rather than
# assumed, and torn down if it is not what was asked for.
cut_verify() {
	local mode="$1" dump
	dump=$(nft list table inet tctl_cut 2>/dev/null) || return 1
	printf '%s' "$dump" | grep -qF "\"$CUT_COMMENT\"" || return 1
	[ "$mode" = "full" ] || return 0
	printf '%s' "$dump" | grep -q "hook prerouting" || return 1
	printf '%s' "$dump" | grep -q "fib daddr type" || return 1
	return 0
}

cut_install_rule() {
	local devs="$1"

	# Preferred: catch traffic at prerouting, before anything can divert it.
	if cut_ruleset "$devs" full | nft -f - 2>/dev/null && cut_verify full; then
		return 0
	fi
	# The prerouting chain did not load — almost certainly a kernel without the
	# fib expression (nft_fib_inet). Fall back to forward-only, which is
	# correct on a plain router; do_engage decides whether that is good enough
	# on THIS router.
	nft delete table inet tctl_cut 2>/dev/null
	if cut_ruleset "$devs" forward | nft -f - 2>/dev/null && cut_verify forward; then
		return 0
	fi
	nft delete table inet tctl_cut 2>/dev/null
	return 1
}

cut_remove_rule() {
	nft delete table inet tctl_cut 2>/dev/null
	return 0
}

# Established flows survive a new drop rule — conntrack keeps them, and any
# flow already handed to the flowtable bypasses the forward hook altogether.
# Without this the toggle reads ON while the TV finishes its firmware download.
#
# Flushed per monitored subnet rather than with a global `conntrack -F`, which
# would also tear down the operator's own sessions to unrelated hosts.
cut_flush_conntrack() {
	local spec base block cidr mask bits

	# Whether the flush WORKED cannot be read off the exit status: `conntrack
	# -D` reports failure both when the tool is broken and when there was
	# simply nothing to delete, and on a quiet network the second is normal.
	# So capability is probed once instead — `-C` is a cheap count that fails
	# if the tool is missing or nf_conntrack is not loaded — and that is the
	# only thing the caller is told about.
	command -v conntrack >/dev/null 2>&1 || return 1
	conntrack -C >/dev/null 2>&1 || return 1

	# Iterated with `for` rather than a pipeline so the loop stays in this
	# shell; a `| while` body is a subshell and could report nothing back.
	for spec in $(tctl_monitored_subnets 2>/dev/null | awk '{print $2 ":" $3}'); do
		base=${spec%%:*}
		block=${spec##*:}
		[ -n "$base" ] && [ -n "$block" ] || continue
		# block = 2^(32-mask); turn it back into a prefix length.
		bits=0
		mask="$block"
		while [ "$mask" -gt 1 ] 2>/dev/null; do
			mask=$((mask / 2))
			bits=$((bits + 1))
		done
		cidr="$((base >> 24 & 255)).$((base >> 16 & 255)).$((base >> 8 & 255)).$((base & 255))/$((32 - bits))"
		conntrack -D -s "$cidr" >/dev/null 2>&1
		conntrack -D -d "$cidr" >/dev/null 2>&1
	done
	return 0
}

# ── state files ────────────────────────────────────────────────────────────

# Deliberately a plain key=value file and not uci: /etc/config survives a
# reboot, and the engaged state must not.
cut_state_write() {
	local file="$1" expires="$2" persist="$3" started="$4"
	mkdir -p "$(dirname "$file")" 2>/dev/null
	{
		printf 'expires_at=%s\n' "$expires"
		printf 'persist=%s\n' "$persist"
		printf 'started_at=%s\n' "$started"
	} > "$file.tmp" 2>/dev/null && mv "$file.tmp" "$file"
}

# Reads one field without sourcing the file — a state file is written by root
# but parsing it as shell would turn any future corruption into execution.
cut_state_get() {
	local file="$1" key="$2" val
	[ -f "$file" ] || return 1
	val=$(sed -n "s/^${key}=\\(.*\\)\$/\\1/p" "$file" 2>/dev/null | head -1)
	case "$val" in
		''|*[!0-9]*) return 1 ;;
	esac
	printf '%s' "$val"
}

cut_active() {
	[ -f "$CUT_STATE" ]
}

# Has a timed cut run out? An indefinite cut (expires_at=0) never has.
cut_expired() {
	local file="${1:-$CUT_STATE}" exp
	exp=$(cut_state_get "$file" expires_at) || return 1
	[ "$exp" = "0" ] && return 1
	[ "$(now)" -ge "$exp" ]
}

# ── keeper lifecycle ───────────────────────────────────────────────────────

cut_keeper_running() {
	pgrep -f "trafficctl-cut.sh keeper" >/dev/null 2>&1
}

cut_keeper_start() {
	[ -x "$CUT_INIT" ] || return 0
	cut_keeper_running && return 0
	"$CUT_INIT" start >/dev/null 2>&1
	return 0
}

cut_keeper_stop() {
	[ -x "$CUT_INIT" ] || return 0
	"$CUT_INIT" stop >/dev/null 2>&1
	return 0
}

# ── actions ────────────────────────────────────────────────────────────────

# secs: 0 (indefinite) or CUT_MIN_SECS..CUT_MAX_SECS
cut_validate_duration() {
	local secs="$1"
	case "$secs" in
		''|*[!0-9]*) return 1 ;;
	esac
	[ "$secs" = "0" ] && return 0
	[ "$secs" -ge "$CUT_MIN_SECS" ] && [ "$secs" -le "$CUT_MAX_SECS" ]
}

# expires_at is passed in as an ABSOLUTE deadline so the boot-restore path can
# reuse this without restarting the clock. Storing a remaining duration and
# counting down again from boot would silently extend every restored cut.
do_engage() {
	local expires="$1" persist="$2" quiet="$3"
	local devs

	cut_supported || fail "global cut needs nftables (fw4); this system is running iptables"

	devs=$(cut_lan_devices)
	if [ -z "$devs" ]; then
		fail "no LAN interfaces found — refusing, a cut with no LAN to spare would black-hole the LAN too"
	fi

	if ! cut_install_rule "$devs"; then
		cut_remove_rule
		fail "failed to install the cut rule"
	fi

	# Degraded coverage plus a transparent proxy is the one combination where
	# the cut would be a lie: the proxy intercepts at prerouting and delivers
	# locally, so a forward-only rule never sees the traffic it claims to be
	# stopping. Refusing, loudly, beats a switch that does nothing.
	if [ "$(cut_coverage)" = "forward" ] && cut_proxy_intercept; then
		cut_remove_rule
		fail "this router intercepts traffic with a transparent proxy (TPROXY — podkop/sing-box, passwall or similar), and the prerouting chain could not be installed on this kernel (no nft_fib?). A forward-only cut would miss proxied traffic while reporting success, so it is refused rather than faked."
	fi

	cut_state_write "$CUT_STATE" "$expires" "$persist" "$(now)"
	if [ "$persist" = "1" ]; then
		cut_state_write "$CUT_PERSIST_STATE" "$expires" "$persist" "$(now)"
	else
		rm -f "$CUT_PERSIST_STATE" 2>/dev/null
	fi

	local ct_msg=""
	cut_flush_conntrack || ct_msg=" (conntrack unavailable — connections opened before now may linger)"

	cut_keeper_start
	tctl_log "cut" "all" "expires=$expires persist=$persist" "${TCTL_VIA:-cli}" "${TCTL_SRC:-local}"

	[ "$quiet" = "quiet" ] && return 0
	emit_status "internet cut for all devices${ct_msg}"
}

# Removing the rule comes first and stopping the keeper last: the keeper may be
# the caller, and its own service stop arrives as a SIGTERM. Ordered this way an
# interrupted release still leaves the internet on, never off.
do_release() {
	local quiet="$1"
	cut_remove_rule
	rm -f "$CUT_STATE" "$CUT_PERSIST_STATE" 2>/dev/null
	tctl_log "uncut" "all" "" "${TCTL_VIA:-cli}" "${TCTL_SRC:-local}"
	cut_keeper_stop
	[ "$quiet" = "quiet" ] && return 0
	emit_status "internet restored for all devices"
}

# Boot path. Only a cut the operator explicitly asked to keep leaves a file in
# /etc, so the mere existence of one is the opt-in — the global persist_rules
# flag is NOT consulted, because somebody who enabled that so their rate limits
# survive a reboot must not inherit a persistent internet kill from it.
do_restore() {
	local exp persist
	[ -f "$CUT_PERSIST_STATE" ] || return 0
	persist=$(cut_state_get "$CUT_PERSIST_STATE" persist) || persist=0
	if [ "$persist" != "1" ]; then
		rm -f "$CUT_PERSIST_STATE" 2>/dev/null
		return 0
	fi
	exp=$(cut_state_get "$CUT_PERSIST_STATE" expires_at) || exp=0
	if cut_expired "$CUT_PERSIST_STATE"; then
		# The deadline passed while the router was down. Honour it rather than
		# starting the countdown again, which would extend the cut by a full
		# duration every reboot.
		rm -f "$CUT_PERSIST_STATE" 2>/dev/null
		logger -t trafficctl "global internet cut expired while down — not restored" 2>/dev/null
		return 0
	fi
	do_engage "$exp" 1 quiet
}

# One keeper iteration.
#   0 = still engaged, keep going
#   2 = nothing left to do, the keeper should stop
do_tick() {
	local devs
	if ! cut_active; then
		cut_rule_present && cut_remove_rule
		return 2
	fi
	if cut_expired; then
		do_release quiet
		logger -t trafficctl "global internet cut expired — internet restored" 2>/dev/null
		return 2
	fi
	if ! cut_rule_present; then
		# Something took the table with it — a `nft flush ruleset`, or an
		# `fw4 flush`. Put it back and say so, because a cut that lapsed even
		# briefly is worth a log line.
		devs=$(cut_lan_devices)
		if [ -n "$devs" ] && cut_install_rule "$devs"; then
			logger -t trafficctl "global internet cut re-asserted after the rule disappeared" 2>/dev/null
		fi
	fi
	return 0
}

# Supervised by procd, started on engage and stopped on release. No respawn:
# the loop is meant to end when the cut does, and a respawning keeper would
# restart into an empty state over and over. If it dies anyway, `status`
# notices (keeper_running=false), re-enforces the deadline itself and starts a
# fresh one — the UI polls it, so the auto-revert is not staked on one process.
do_keeper() {
	# The deadline is re-read from the clock on every pass rather than slept
	# through in one go: a router boots with a bogus clock until NTP lands, and
	# a single long sleep computed before the step would strand the cut.
	while :; do
		do_tick || break
		sleep "$CUT_TICK_SECS"
	done
	return 0
}

emit_status() {
	local msg="$1"
	local active=false present=false persist=false keeper=false supported=false
	local exp=0 remaining=0 started=0 devs coverage

	cut_supported && supported=true
	devs=$(cut_lan_devices | tr '\n' ' ' | sed 's/ *$//')

	if cut_active; then
		active=true
		exp=$(cut_state_get "$CUT_STATE" expires_at) || exp=0
		started=$(cut_state_get "$CUT_STATE" started_at) || started=0
		[ "$(cut_state_get "$CUT_STATE" persist)" = "1" ] && persist=true
		if [ "$exp" != "0" ]; then
			remaining=$((exp - $(now)))
			[ "$remaining" -lt 0 ] && remaining=0
		fi
	fi
	cut_rule_present && present=true
	cut_keeper_running && keeper=true

	# "full" = the prerouting chain is in place and transparently proxied
	# traffic is caught too; "forward" = only forwarded traffic is, which the
	# UI must surface rather than bury.
	coverage=$(cut_coverage)

	printf '{"ok":true,"active":%s,"rule_present":%s,"supported":%s,"coverage":"%s","expires_at":%s,"remaining":%s,"started_at":%s,"persist":%s,"keeper_running":%s,"lan_devices":"%s","default_duration":%s,"default_persist":%s,"msg":"%s"}\n' \
		"$active" "$present" "$supported" "$coverage" "$exp" "$remaining" "$started" \
		"$persist" "$keeper" "$(json_esc "$devs")" \
		"$(cut_default_duration)" \
		"$(cut_default_persist)" \
		"$(json_esc "$msg")"
}

cut_default_duration() {
	local d
	d=$(uci -q get trafficctl.cut.default_duration 2>/dev/null)
	case "$d" in
		''|*[!0-9]*) echo 0 ;;
		*) echo "$d" ;;
	esac
}

cut_default_persist() {
	[ "$(uci -q get trafficctl.cut.persist 2>/dev/null)" = "1" ] && echo true || echo false
}

# Reported state is reconciled first, and it is reconciled against the KERNEL,
# not against the state file. Two failures are being headed off:
#   * a timed cut whose keeper died would otherwise read ON forever;
#   * a state file left behind by a rule that lapsed would read ON while the
#     traffic flows. `rule_present` is reported separately for exactly that,
#     and the UI must never render ON without it.
do_status() {
	if cut_active && cut_expired; then
		do_release quiet
		emit_status "the cut expired and the internet was restored"
		return 0
	fi
	# A cut that is still on but has lost its keeper gets one back, so the
	# auto-revert does not depend on a single process staying alive.
	if cut_active && ! cut_keeper_running; then
		cut_keeper_start
	fi
	emit_status ""
}

case "$1" in
engage)
	SECS="${2:-0}"
	PERSIST="${3:-0}"
	cut_validate_duration "$SECS" || \
		fail "duration must be 0 (indefinite) or between $CUT_MIN_SECS and $CUT_MAX_SECS seconds"
	case "$PERSIST" in
		0|1) ;;
		*) fail "persist must be 0 or 1" ;;
	esac
	if [ "$SECS" = "0" ]; then
		EXPIRES=0
	else
		EXPIRES=$(( $(now) + SECS ))
	fi
	mkdir -p "$CUT_RUN_DIR" 2>/dev/null
	do_engage "$EXPIRES" "$PERSIST" ""
	;;
release)
	do_release ""
	;;
status)
	do_status
	;;
restore)
	do_restore
	;;
tick)
	do_tick
	;;
keeper)
	do_keeper
	;;
*)
	fail "usage: trafficctl-cut.sh engage <seconds|0> [persist] | release | status | restore"
	;;
esac
