# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2026 OpenWrt.org
#
# shellcheck shell=sh
# Shared POSIX sh helpers for readsb-wiedehopf, sourced by every
# helper script. See `readsb-setup --help` for the user CLI map.

# --- logging ---------------------------------------------------------------
# Tag overridable via READSB_LOG_TAG. View: logread -e readsb
: "${READSB_LOG_TAG:=readsb}"
_log()    { logger -t "$READSB_LOG_TAG" -p daemon.info   -- "$@"; }
_notice() { logger -t "$READSB_LOG_TAG" -p daemon.notice -- "$@"; }
_warn()   { logger -t "$READSB_LOG_TAG" -p daemon.warn   -- "$@"; }
_err()    { logger -t "$READSB_LOG_TAG" -p daemon.err    -- "$@"; }
_debug()  { logger -t "$READSB_LOG_TAG" -p daemon.debug  -- "$@"; }

# --- USB SDR identification ------------------------------------------------
# RTL2832U USB IDs from librtlsdr's known_devices[]. To regenerate:
#   awk '/static rtlsdr_dongle_t known_devices/,/^};/' src/librtlsdr.c \
#     | awk -F'[ ,{}]+' '/0x[0-9a-fA-F]+, 0x[0-9a-fA-F]+/ \
#         { printf "%s:%s\n", substr($2,3), substr($3,3) }'
readsb_is_sdr_id() {
	case "$1" in
		0bda:2832|0bda:2838|\
		0413:6680|0413:6f0f|\
		0458:707f|\
		0ccd:00a9|0ccd:00b3|0ccd:00b4|0ccd:00b5|0ccd:00b7|0ccd:00b8|\
		0ccd:00b9|0ccd:00c0|0ccd:00c6|0ccd:00d3|0ccd:00d7|0ccd:00e0|\
		1209:2832|\
		1554:5020|\
		15f4:0131|15f4:0133|\
		185b:0620|185b:0650|185b:0680|\
		1b80:d393|1b80:d394|1b80:d395|1b80:d397|1b80:d398|1b80:d39d|\
		1b80:d3a4|1b80:d3a8|1b80:d3af|1b80:d3b0|\
		1d19:1101|1d19:1102|1d19:1103|1d19:1104|\
		1f4d:a803|1f4d:b803|1f4d:c803|1f4d:d286|1f4d:d803) return 0 ;;
	esac
	return 1
}

# Invoke <cb> <syspath> <vid> <pid> for each attached RTL-SDR.
readsb_for_each_sdr() {
	local cb=$1 d vid pid
	for d in /sys/bus/usb/devices/*; do
		[ -r "$d/idVendor" ] && [ -r "$d/idProduct" ] || continue
		read -r vid < "$d/idVendor"
		read -r pid < "$d/idProduct"
		readsb_is_sdr_id "$vid:$pid" || continue
		"$cb" "$d" "$vid" "$pid"
	done
}

# 0 on the first attached RTL-SDR (no full enumeration).
readsb_is_sdr_present() {
	local d vid pid
	for d in /sys/bus/usb/devices/*; do
		[ -r "$d/idVendor" ] && [ -r "$d/idProduct" ] || continue
		read -r vid < "$d/idVendor"
		read -r pid < "$d/idProduct"
		readsb_is_sdr_id "$vid:$pid" && return 0
	done
	return 1
}

# One line per attached RTL-SDR: serial, or "NOSERIAL" if missing.
readsb_list_sdrs() {
	readsb_for_each_sdr _readsb_emit_serial
}
_readsb_emit_serial() {
	local d=$1 ser="NOSERIAL" s
	if [ -r "$d/serial" ]; then
		read -r s < "$d/serial"
		[ -n "$s" ] && ser=$s
	fi
	echo "$ser"
}

# Integer count of attached RTL-SDRs.
readsb_count_sdrs() {
	_readsb_sdr_count=0
	readsb_for_each_sdr _readsb_inc_count
	echo "$_readsb_sdr_count"
}
_readsb_inc_count() { _readsb_sdr_count=$((_readsb_sdr_count + 1)); }

# Strip control bytes / whitespace from a librtlsdr serial.
readsb_sanitize_serial() {
	printf '%s' "$1" | tr -cd 'A-Za-z0-9_.:-'
}

# Normalize a UCI freq value to integer MHz. Accepts "1090",
# "1090MHz", "1090m", "1090000000". Empty -> "1090". Bad -> "".
readsb_freq_to_mhz() {
	local f=$1
	[ -n "$f" ] || { echo 1090; return 0; }
	f=$(printf '%s' "$f" | tr -d ' \t' | sed 's/[Mm][Hh]\{0,1\}[Zz]\{0,1\}$//')
	case "$f" in
		''|*[!0-9]*) echo ""; return 1 ;;
	esac
	if [ "$f" -ge 1000000 ]; then
		echo $((f / 1000000))
	else
		echo "$f"
	fi
}

# --- generic poll-with-timeout ---------------------------------------------
# readsb_wait_until <label> <timeout_s> <interval_s> <probe_cmd> [<probe_args>...]
# Returns 0 when probe_cmd succeeds, 1 on timeout.
readsb_wait_until() {
	local label=$1 timeout=$2 interval=$3
	shift 3
	local elapsed=0 attempt=1
	[ "$interval" -ge 1 ] 2>/dev/null || interval=1
	_log "waiting for $label (timeout=${timeout}s interval=${interval}s)"
	while : ; do
		if "$@"; then
			_notice "$label ready after ${elapsed}s (attempt $attempt)"
			return 0
		fi
		[ "$elapsed" -ge "$timeout" ] && break
		sleep "$interval"
		elapsed=$((elapsed + interval))
		attempt=$((attempt + 1))
	done
	_warn "$label not ready within ${timeout}s; continuing"
	return 1
}

# --- aggregator feeder presets --------------------------------------------
# Family A aggregators reachable with one outbound TCP connect plus a UUID.
# Output: "<host> <port> <protocol>". Returns nonzero on unknown preset.
readsb_feeder_preset() {
	case "$1" in
		adsblol)        echo "in.adsb.lol 30004 beast_reduce_plus_out" ;;
		airplaneslive)  echo "feed.airplanes.live 30004 beast_reduce_plus_out" ;;
		adsbfi)         echo "feed.adsb.fi 30004 beast_reduce_plus_out" ;;
		planespotters)  echo "feed.planespotters.net 30004 beast_reduce_plus_out" ;;
		theairtraffic)  echo "feed.theairtraffic.com 30004 beast_reduce_plus_out" ;;
		flyitaly)       echo "dati.flyitalyadsb.com 4905 beast_reduce_plus_out" ;;
		avdelphi)       echo "data.avdelphi.com 24999 beast_reduce_plus_out" ;;
		adsbexchange)   echo "feed1.adsbexchange.com 30004 beast_reduce_plus_out" ;;
		flyrealtraffic) echo "feed.flyrealtraffic.com 30004 beast_reduce_plus_out" ;;
		*) return 1 ;;
	esac
}

# Space-separated list of built-in preset names (excluding 'custom').
readsb_feeder_presets() {
	echo "adsblol airplaneslive adsbfi planespotters theairtraffic flyitaly avdelphi adsbexchange flyrealtraffic"
}

# 0 if <name> is a built-in preset (NOT 'custom').
readsb_is_preset() {
	local p
	for p in $(readsb_feeder_presets); do
		[ "$p" = "$1" ] && return 0
	done
	return 1
}

# RFC 4122 canonical 8-4-4-4-12 hex (any case).
readsb_is_uuid() {
	case "$1" in
		[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]-[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]-[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]-[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]-[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])
			return 0 ;;
	esac
	return 1
}

# Generate a fresh UUID. Echoes on success; rc 1 with no output if no
# entropy source is available.
readsb_gen_uuid() {
	local u
	if [ -r /proc/sys/kernel/random/uuid ]; then
		read -r u < /proc/sys/kernel/random/uuid
	elif command -v uuidgen >/dev/null 2>&1; then
		u=$(uuidgen)
	else
		return 1
	fi
	readsb_is_uuid "$u" || return 1
	echo "$u"
}

# 0 if `readsb.<name>` UCI section exists.
readsb_section_exists() {
	uci -q get "readsb.$1" >/dev/null 2>&1
}

# Echo integer count of `config feeder <name>` sections in /etc/config/readsb.
readsb_count_feeders() {
	uci -q show readsb 2>/dev/null \
		| awk -F. '/^readsb\.[^.]+=feeder$/ { n++ } END { print n+0 }'
}

# Resolve a `config feeder <name>` UCI section into a uniform set of
# globals. Used by the init script and by the readsb-feeder CLI; caller
# must have already run `config_load readsb`.
#
# Args:
#   $1 = section name
#   $2 = fallback UUID (used when the section has no `option uuid`)
#
# Output globals (always reset):
#   readsb_feeder_enabled  0|1
#   readsb_feeder_preset   preset name, or empty
#   readsb_feeder_host     resolved hostname
#   readsb_feeder_port     resolved TCP port
#   readsb_feeder_proto    resolved protocol token
#   readsb_feeder_uuid     section uuid, or fallback
#   readsb_feeder_error    short reason on failure
#
# Returns 0 on success, 1 on a malformed section.
readsb_feeder_resolve() {
	local fcfg=$1 fallback=$2

	readsb_feeder_enabled=0
	readsb_feeder_preset=
	readsb_feeder_host=
	readsb_feeder_port=
	readsb_feeder_proto=
	readsb_feeder_uuid=
	readsb_feeder_error=

	config_get_bool readsb_feeder_enabled "$fcfg" enabled 0
	config_get readsb_feeder_preset "$fcfg" preset
	if [ -z "$readsb_feeder_preset" ]; then
		readsb_feeder_error="has no preset"
		return 1
	fi

	if [ "$readsb_feeder_preset" = "custom" ]; then
		config_get readsb_feeder_host  "$fcfg" host
		config_get readsb_feeder_port  "$fcfg" port
		config_get readsb_feeder_proto "$fcfg" protocol
		[ -n "$readsb_feeder_proto" ] || readsb_feeder_proto=beast_reduce_plus_out
		if [ -z "$readsb_feeder_host" ] || [ -z "$readsb_feeder_port" ]; then
			readsb_feeder_error="(custom) missing host/port"
			return 1
		fi
	else
		# readsb_feeder_preset prints "host port proto"; word-split intentional.
		# shellcheck disable=SC2046
		set -- $(readsb_feeder_preset "$readsb_feeder_preset")
		if [ "$#" -ne 3 ]; then
			readsb_feeder_error="uses unknown preset '$readsb_feeder_preset'"
			return 1
		fi
		readsb_feeder_host=$1
		readsb_feeder_port=$2
		readsb_feeder_proto=$3
	fi

	config_get readsb_feeder_uuid "$fcfg" uuid
	[ -n "$readsb_feeder_uuid" ] || readsb_feeder_uuid=$fallback
	return 0
}

# Per-aggregator public status URL templates. Empty stdout + nonzero exit
# means no per-UUID lookup URL is documented for this preset.
readsb_feeder_status_url() {
	local preset=$1 uuid=$2
	case "$preset" in
		adsbexchange)
			[ -n "$uuid" ] || return 1
			echo "https://www.adsbexchange.com/api/feeders/?feed=$uuid"
			;;
		adsblol)
			echo "https://api.adsb.lol/0/my"
			;;
		*) return 1 ;;
	esac
}

# --- optional companion packages (per preset) -----------------------------
# Single source of truth for "this preset has a companion package". Used
# by the wizard and by `readsb-setup --status`.
#
# Returns space-separated opkg package names, empty for presets with none.
readsb_feeder_optional_pkgs() {
	case "$1" in
		adsbexchange) echo "adsbexchange-stats" ;;
		*) echo "" ;;
	esac
}

# Every optional companion package this build knows about, one per line.
# Keep in sync with readsb_feeder_optional_pkgs().
readsb_companion_pkgs_all() {
	cat <<'EOF'
adsbexchange-stats
EOF
}

# Short purpose string for an optional companion package.
readsb_pkg_purpose() {
	case "$1" in
		adsbexchange-stats)
			echo "reads readsb's aircraft.json, aggregates per-aircraft RSSI/counts, and POSTs to adsbexchange.com (identified by readsb.main.uuid); required only for the per-station web ranking"
			;;
		*) echo "" ;;
	esac
}

# Extra (non-procd) init-script actions a companion adds beyond the
# standard {start|stop|restart|reload|status|enable|disable} set. Keep
# in sync with each companion's `EXTRA_COMMANDS=` declaration.
readsb_pkg_extra_actions() {
	case "$1" in
		adsbexchange-stats) echo "showurl info" ;;
		*) echo "" ;;
	esac
}

# UCI config file owned by a companion (defaults to pkg name; override
# only when a companion deviates).
readsb_pkg_uci_config() {
	case "$1" in
		adsbexchange-stats) echo "adsbexchange-stats" ;;
		*) echo "" ;;
	esac
}

# 0 if the named opkg package is installed (reads metadata directly).
readsb_pkg_installed() {
	[ -n "$1" ] && [ -f "/usr/lib/opkg/info/$1.control" ]
}

# One init-script base name per line owned by <pkg>. rc 1 when none.
readsb_pkg_init_scripts() {
	local pkg=$1
	[ -n "$pkg" ] && [ -r "/usr/lib/opkg/info/$pkg.list" ] || return 1
	awk -F/ '$2=="etc" && $3=="init.d" && $4!="" { print $4; n++ }
		END { exit !(n>0) }' "/usr/lib/opkg/info/$pkg.list"
}

# Status token for an opkg package, optionally followed by an init script.
#   running <init> (rc 0) | no-service (rc 0) | stopped <init> (rc 2) | missing (rc 1)
readsb_pkg_status() {
	local pkg=$1 init
	if ! readsb_pkg_installed "$pkg"; then
		echo "missing"
		return 1
	fi
	init=$(readsb_pkg_init_scripts "$pkg" 2>/dev/null | awk 'NR==1{print; exit}')
	if [ -z "$init" ]; then
		echo "no-service"
		return 0
	fi
	if [ -x "/etc/init.d/$init" ] && /etc/init.d/"$init" running 2>/dev/null; then
		printf 'running %s\n' "$init"
		return 0
	fi
	printf 'stopped %s\n' "$init"
	return 2
}

# Print a multi-line recommendation block for the optional companion
# package(s) of <preset>.
#
#   readsb_recommend_optional_pkgs <preset> [<context-label>]
#
# Returns 0 if at least one package was reported, 1 if the preset has no
# companion packages.
readsb_recommend_optional_pkgs() {
	local preset=$1 ctx=${2:-} pkgs pkg purpose status init reported=0
	pkgs=$(readsb_feeder_optional_pkgs "$preset")
	[ -n "$pkgs" ] || return 1

	for pkg in $pkgs; do
		[ "$reported" = 0 ] && {
			if [ -n "$ctx" ]; then
				printf 'optional companion package(s) for preset %s (%s):\n' "'$preset'" "$ctx"
			else
				printf 'optional companion package(s) for preset %s:\n' "'$preset'"
			fi
		}
		reported=1
		purpose=$(readsb_pkg_purpose "$pkg")
		[ -n "$purpose" ] || purpose="(no description available)"

		# shellcheck disable=SC2046
		set -- $(readsb_pkg_status "$pkg" 2>/dev/null)
		status=${1:-missing}
		init=${2:-}

		case $status in
			missing)
				printf '  %s -- NOT INSTALLED\n' "$pkg"
				printf '    purpose : %s\n' "$purpose"
				printf '    install : opkg update && opkg install %s\n' "$pkg"
				;;
			stopped)
				printf '  %s -- installed but NOT RUNNING (init: %s)\n' "$pkg" "$init"
				printf '    purpose : %s\n' "$purpose"
				printf '    enable  : /etc/init.d/%s enable\n' "$init"
				printf '    start   : /etc/init.d/%s start\n' "$init"
				;;
			running)
				printf '  %s -- installed and running (init: %s)\n' "$pkg" "$init"
				;;
			no-service)
				printf '  %s -- installed (no service component)\n' "$pkg"
				;;
		esac
	done
	return 0
}

# Mirror missing/stopped companion warnings to syslog. Quiet for
# 'custom' presets and for presets with no companion packages.
readsb_warn_companions() {
	local preset=$1 section=$2 pkg state init
	[ -n "$preset" ] && [ "$preset" != custom ] || return 0
	for pkg in $(readsb_feeder_optional_pkgs "$preset"); do
		# shellcheck disable=SC2046
		set -- $(readsb_pkg_status "$pkg" 2>/dev/null)
		state=${1:-missing}
		init=${2:-}
		case $state in
			missing)
				_warn "feeder '$section' (preset $preset): optional companion package '$pkg' not installed -- run: opkg update && opkg install $pkg"
				;;
			stopped)
				_warn "feeder '$section' (preset $preset): companion package '$pkg' installed but not running -- run: /etc/init.d/$init enable && /etc/init.d/$init start"
				;;
		esac
	done
}

# Interactive: prompt the user via wiz_* helpers to install / start any
# missing companion packages for <preset>. Caller must already have a
# tty (wiz_available). Re-invocation is safe; one `opkg update` per
# shell, gated by _readsb_opkg_updated.
#   wiz_offer_install_companions <preset> [<context-label>]
# Returns 0 normally, 1 if the user aborts a prompt with EOF.
wiz_offer_install_companions() {
	local preset=$1 ctx=${2:-} pkgs pkg state init purpose ans
	[ -n "$preset" ] && [ "$preset" != custom ] || return 0
	pkgs=$(readsb_feeder_optional_pkgs "$preset")
	[ -n "$pkgs" ] || return 0

	for pkg in $pkgs; do
		# shellcheck disable=SC2046
		set -- $(readsb_pkg_status "$pkg" 2>/dev/null)
		state=${1:-missing}
		init=${2:-}
		purpose=$(readsb_pkg_purpose "$pkg")
		[ -n "$purpose" ] || purpose="(no description available)"

		case $state in
			missing)
				wiz_say ""
				if [ -n "$ctx" ]; then
					wiz_say "  '$pkg' is NOT INSTALLED ($ctx)."
				else
					wiz_say "  '$pkg' is NOT INSTALLED."
				fi
				wiz_say "    purpose: $purpose"
				wiz_yesno ans "  install '$pkg' now via opkg?" N || return 1
				if [ "$ans" = 1 ]; then
					if [ -z "${_readsb_opkg_updated:-}" ]; then
						wiz_say "  running 'opkg update' ..."
						opkg update >/dev/null 2>&1 \
							|| wiz_say "  (opkg update failed; trying install anyway)"
						_readsb_opkg_updated=1
					fi
					wiz_say "  running 'opkg install $pkg' ..."
					if opkg install "$pkg" >/dev/tty 2>&1; then
						_notice "installed companion package '$pkg' for preset $preset"
						wiz_say "  '$pkg' installed"
					else
						_warn "opkg install '$pkg' failed (preset $preset)"
						wiz_say "  install failed; check 'logread' or run manually:"
						wiz_say "    opkg update && opkg install $pkg"
					fi
				fi
				;;
			stopped)
				wiz_say ""
				if [ -n "$ctx" ]; then
					wiz_say "  '$pkg' is installed but NOT RUNNING (init: $init, $ctx)."
				else
					wiz_say "  '$pkg' is installed but NOT RUNNING (init: $init)."
				fi
				wiz_say "    purpose: $purpose"
				wiz_yesno ans "  enable & start '$init' now?" Y || return 1
				if [ "$ans" = 1 ]; then
					if /etc/init.d/"$init" enable 2>/dev/null \
					   && /etc/init.d/"$init" start 2>/dev/null; then
						_notice "enabled and started companion init '$init' for preset $preset"
						wiz_say "  '$init' enabled and started"
					else
						_warn "/etc/init.d/$init enable/start failed (preset $preset)"
						wiz_say "  enable/start failed; check 'logread'"
					fi
				fi
				;;
			running|no-service) ;;
		esac
	done
	return 0
}

# --- runtime health helpers -----------------------------------------------
# Used by `readsb-setup --health` and `readsb-feeder --health`. Read-only;
# all helpers degrade gracefully (empty / nonzero) when the daemon is not
# running or /proc / logread is unavailable.

# PID of the running readsb, empty when not running.
readsb_pid() {
	local p _pid
	for p in /var/run/readsb.pid /var/run/readsb/readsb.pid; do
		[ -r "$p" ] || continue
		read -r _pid _ < "$p" 2>/dev/null
		if [ -n "$_pid" ] && [ -d "/proc/$_pid" ]; then
			echo "$_pid"; return 0
		fi
	done
	pidof readsb 2>/dev/null | awk '{print $1}'
}

# Running readsb's argv as one space-separated line, rc 1 when down.
# Optional <pid> arg avoids re-resolving when the caller already has it.
readsb_cmdline() {
	local pid=${1:-}
	[ -n "$pid" ] || pid=$(readsb_pid)
	[ -n "$pid" ] && [ -r "/proc/$pid/cmdline" ] || return 1
	# /proc/PID/cmdline is NUL-separated.
	tr '\0\n' '  ' < "/proc/$pid/cmdline" | sed 's/ *$//'
}

# 0 if a `--net-connector=<host>,<port>,...` matching this <host> <port>
# pair appears in the live daemon's cmdline. Used by --health to tell
# UCI-configured-but-not-yet-loaded feeders apart from live ones.
readsb_connector_live() {
	local host=$1 port=$2 cmd
	cmd=$(readsb_cmdline) || return 1
	[ -n "$cmd" ] || return 1
	# Match "--net-connector=host,port" followed by ',', whitespace, or EOL.
	echo "$cmd" | tr ' ' '\n' | awk -v h="$host" -v p="$port" '
		BEGIN { tag = "--net-connector=" h "," p; tagl = length(tag) }
		{
			if (substr($0, 1, tagl) == tag) {
				suf = substr($0, tagl + 1)
				if (suf == "" || substr(suf, 1, 1) == ",") { found = 1; exit }
			}
		}
		END { exit !found }
	'
}

# 0 if the running readsb has at least one ESTABLISHED TCP socket whose
# REMOTE port matches <port> AND whose socket inode is owned by the
# readsb pid. The authoritative kernel-view answer to "is readsb
# actually connected to that endpoint" -- the simpler drive-by
# `_probe_tcp` (SYN+close) returns a false negative when the upstream
# firewall drops scan-style probes but accepts the persistent feeder
# stream (observed: feed1.adsbexchange.com:30004).
#
# Match is on remote PORT only -- aggregator DNS round-robins, and we
# don't always have a resolver. The inode-ownership check
# (/proc/$pid/fd) keeps that safe.
#
# Returns:
#   0  active socket found
#   1  no matching socket
#   2  cannot determine (no pid, /proc unavailable, bad port)
#
#   readsb_connector_active <host> <port> [<pid>]
readsb_connector_active() {
	local host=$1 port=$2 pid=${3:-}
	[ -n "$pid" ] || pid=$(readsb_pid)
	[ -n "$pid" ] || return 2
	[ -d "/proc/$pid/fd" ] || return 2

	# host arg reserved for future strict-mode use.
	: "$host"

	# /proc/net/tcp uses uppercase hex for ports.
	case $port in ''|*[!0-9]*) return 2 ;; esac
	local hexport
	hexport=$(printf '%04X' "$port" 2>/dev/null) || return 2

	# Snapshot socket inodes owned by the readsb pid. Each fd entry
	# /proc/PID/fd/N is a symlink; for sockets the target reads
	# "socket:[NNN]". A trailing-space-padded list lets us do the
	# membership test with `index(" ${list} ", " ${cand} ")`.
	local inodes='' f tgt n
	for f in /proc/$pid/fd/*; do
		[ -e "$f" ] || continue
		tgt=$(readlink "$f" 2>/dev/null) || continue
		case $tgt in
			socket:\[*\])
				n=${tgt#socket:[}; n=${n%]}
				inodes="$inodes $n"
				;;
		esac
	done
	[ -n "$inodes" ] || return 1

	# Walk /proc/net/tcp + /proc/net/tcp6 for ESTABLISHED rows (state=01)
	# whose remote port matches and whose inode is owned by readsb.
	awk -v hp="$hexport" -v inodes=" $inodes " '
		FNR == 1 { next }
		{
			n = split($3, ra, ":")
			if (n != 2 || ra[2] != hp) next
			if ($4 != "01") next
			if (index(inodes, " " $10 " ") > 0) { found = 1; exit }
		}
		END { exit !found }
	' /proc/net/tcp /proc/net/tcp6 2>/dev/null
}

# Up to <n> recent readsb-tagged syslog lines (default 200). rc 1 when
# logread is unavailable.
readsb_log_recent() {
	local n=${1:-200}
	command -v logread >/dev/null 2>&1 || return 1
	logread -e readsb 2>/dev/null | tail -n "$n"
}

# Count of recent error/warn-level events touching <host> <port>.
# Matches readsb's vocabulary: "Bad connection", "connection lost",
# "dropping data". Always echoes a single integer.
readsb_log_count_errors_for() {
	local host=$1 port=$2 buf c
	buf=$(readsb_log_recent 200) || { echo 0; return 0; }
	[ -n "$buf" ] || { echo 0; return 0; }
	# Awk avoids regex-escaping dots in hostnames.
	c=$(echo "$buf" | awk -v h="$host" -v p="$port" '
		index($0, h) && index($0, "port " p) &&
		(index($0, "Bad connection") || index($0, "connection lost") ||
		 index($0, "dropping data")) { n++ }
		END { print n+0 }
	')
	echo "$c"
}

# Most recent log line touching <host> <port> with one of the patterns
# above. Empty when no match.
readsb_log_last_error_for() {
	local host=$1 port=$2 buf
	buf=$(readsb_log_recent 200) || return 0
	[ -n "$buf" ] || return 0
	echo "$buf" | awk -v h="$host" -v p="$port" '
		index($0, h) && index($0, "port " p) &&
		(index($0, "Bad connection") || index($0, "connection lost") ||
		 index($0, "dropping data")) { last = $0 }
		END { if (last) print last }
	'
}

# Total recent error/warn events for readsb regardless of feeder.
# Always echoes a single integer.
#
# IMPORTANT: readsb writes ALL output to stderr (even harmless startup
# banners and "Connection established" messages); procd captures stderr
# as `daemon.err`, so a blanket `daemon\.err` match would falsely flag
# 15+ lines after every restart. We therefore match on:
#   * higher-than-err severities (warn/crit/alert/emerg);
#   * known error keywords (Bad connection / connection lost / dropping data);
#   * NON-ZERO `<N> samples (dropped|lost)` -- the periodic stats block
#     always contains "0 samples dropped" lines reporting NO loss; require
#     a non-zero leading digit so we only fire on real overflow events.
readsb_log_count_errors() {
	local buf
	buf=$(readsb_log_recent 200) || { echo 0; return 0; }
	[ -n "$buf" ] || { echo 0; return 0; }
	echo "$buf" | awk '
		/daemon\.warn|daemon\.crit|daemon\.alert|daemon\.emerg|Bad connection|connection lost|dropping data|[^0-9][1-9][0-9]* samples (dropped|lost)/ { n++ }
		END { print n+0 }
	'
}

# Most recent log line that looks like a readsb stats summary. Prefer
# the "Statistics: <start> - <end>" header (most informative single
# line); fall back to in-block markers only if the header was rotated
# out, so we never show a decontextualised sub-line.
readsb_log_last_stats() {
	local buf
	buf=$(readsb_log_recent 200) || return 0
	[ -n "$buf" ] || return 0
	echo "$buf" | awk '
		/Statistics:/                            { hdr  = $0 }
		/msgs\/sec|aircraft tracks|Mode-S|Mode A\/C/ { fallback = $0 }
		END {
			if (hdr)      print hdr
			else if (fallback) print fallback
		}
	'
}

# Most recent COMPLETE periodic stats block emitted by readsb. A block
# runs from a `Statistics: <start> - <end>` header through the trailing
# `<N> ms for network input and background tasks` line. Emits raw
# syslog lines (timestamp + tag prefix preserved). rc 1 when no
# complete block is buffered.
#
# Pulls a 400-line window because a single block can be 40+ lines and
# may share the buffer with helper-script chatter that would otherwise
# push the previous block off the end. Daemon-only filter
# (`readsb\[<pid>\]:`) drops lines from readsb-setup/-feeder/-uuid/-geoip
# that `logread -e readsb` substring-matched in.
readsb_log_last_stats_block() {
	local buf
	buf=$(readsb_log_recent 400) || return 1
	[ -n "$buf" ] || return 1
	echo "$buf" | awk '
		# 1 for daemon-tagged readsb lines, 0 otherwise -- drops chatter.
		function is_daemon(line) {
			return line ~ /readsb\[[0-9]+\]:/
		}
		# Strip "<...>readsb[NNN]: " prefix. May be empty (daemon emits
		# blank separator lines between stats sub-sections) -- callers
		# MUST gate on is_daemon() first.
		function payload(line,    s) {
			s = line
			sub(/.*readsb\[[0-9]+\]: ?/, "", s)
			return s
		}
		{
			if (!is_daemon($0)) {
				# Non-daemon line breaks an in-progress capture.
				capturing = 0
				next
			}
			p = payload($0)
			if (p ~ /^Statistics:/) {
				n = 1; block[1] = $0; capturing = 1
				next
			}
			if (!capturing) next
			block[++n] = $0
			if (p ~ /ms for network input and background tasks/) {
				stored_n = n
				for (i = 1; i <= n; i++) saved[i] = block[i]
				capturing = 0
			}
		}
		END {
			if (stored_n)
				for (i = 1; i <= stored_n; i++) print saved[i]
			else exit 1
		}
	'
}

# Echo a compact summary of the most recent readsb stats block as
# `key value` lines (one per line, single space separator). Empty stdout
# + rc 1 when no complete block is available (mirrors
# `readsb_log_last_stats_block`).
#
# Keys, in emit order:
#   window         <start - end string>           (header)
#   samples_proc   <int>
#   samples_drop   <int>
#   samples_lost   <int>
#   preambles      <int>      Mode-S preambles received (Local receiver)
#   crc_ok         <int>      accepted with correct CRC (Local receiver)
#   crc_repaired   <int>      accepted with 1-bit error repaired (Local rcv)
#   noise_dbfs     <float>
#   signal_dbfs    <float>    mean signal power
#   peak_dbfs      <float>    peak signal power
#   strong_msgs    <int>      messages above -3 dBFS
#   usable_msgs    <int>      total usable messages (post-decode)
#   pos_air        <int>      airborne position messages
# Compact summary of the most recent stats block as `key value` lines.
# rc 1 when no complete block is available.
#
# Keys (in emit order): window, samples_proc, samples_drop, samples_lost,
# preambles, crc_ok, crc_repaired, noise_dbfs, signal_dbfs, peak_dbfs,
# strong_msgs, usable_msgs, pos_air, pos_cpr_ok, tracks, tracks_one,
# cpu_pct. Missing keys are simply omitted; treat empty values as "n/a".
#
# CRC counters appear twice in the block (Local receiver + Network
# clients); we capture only the first -- the SDR reception, which is
# what operators care about.
readsb_log_stats_summary() {
	readsb_log_last_stats_block | awk '
		function payload(line,    s) {
			s = line
			sub(/.*readsb\[[0-9]+\]: ?/, "", s)
			sub(/^[ \t]+/, "", s)
			return s
		}
		function emit(k, v) { if (v != "") print k " " v }
		{
			p = payload($0)
			if (p ~ /^Statistics:/) {
				s = p; sub(/^Statistics: */, "", s)
				window = s
				next
			}
			# Numeric extractors. p+0 reads the leading number
			# (handles negative dBFS values too).
			n = p + 0
			if      (p ~ /samples processed$/)          samples_proc = n
			else if (p ~ /samples dropped$/)            samples_drop = n
			else if (p ~ /samples lost$/)               samples_lost = n
			else if (p ~ /Mode-S message preambles received$/) preambles = n
			else if (p ~ /accepted with correct CRC$/) {
				if (!got_crc_ok) { crc_ok = n; got_crc_ok = 1 }
			}
			else if (p ~ /accepted with 1-bit error repaired$/) {
				if (!got_crc_rp) { crc_repaired = n; got_crc_rp = 1 }
			}
			else if (p ~ /dBFS noise power$/)           noise_dbfs = n
			else if (p ~ /dBFS mean signal power$/)     signal_dbfs = n
			else if (p ~ /dBFS peak signal power$/)     peak_dbfs = n
			else if (p ~ /messages with signal power above -3dBFS$/) strong_msgs = n
			else if (p ~ /total usable messages$/)      usable_msgs = n
			else if (p ~ /airborne position messages received$/) pos_air = n
			else if (p ~ /global CPR attempts with valid positions$/) {
				if (!got_pos_cpr_ok) { pos_cpr_ok = n; got_pos_cpr_ok = 1 }
			}
			else if (p ~ /unique aircraft tracks$/)     tracks = n
			else if (p ~ /aircraft tracks where only one message was seen$/) tracks_one = n
			else if (p ~ /^CPU load:/) {
				v = p; sub(/^CPU load: */, "", v); sub(/%.*$/, "", v)
				cpu_pct = v
			}
		}
		END {
			emit("window",       window)
			emit("samples_proc", samples_proc)
			emit("samples_drop", samples_drop)
			emit("samples_lost", samples_lost)
			emit("preambles",    preambles)
			emit("crc_ok",       crc_ok)
			emit("crc_repaired", crc_repaired)
			emit("noise_dbfs",   noise_dbfs)
			emit("signal_dbfs",  signal_dbfs)
			emit("peak_dbfs",    peak_dbfs)
			emit("strong_msgs",  strong_msgs)
			emit("usable_msgs",  usable_msgs)
			emit("pos_air",      pos_air)
			emit("pos_cpr_ok",   pos_cpr_ok)
			emit("tracks",       tracks)
			emit("tracks_one",   tracks_one)
			emit("cpu_pct",      cpu_pct)
		}
	'
}

# Render the most recent stats block as one labelled metric per line,
# prefixed by the caller-supplied indent (default empty). Per-metric
# lines use prefix + two extra spaces.
#
# Side-effect global (always reset on entry):
#   readsb_stats_loss_seen  1 if the daemon reported non-zero
#                           samples_dropped/_lost in the most recent
#                           block, 0 otherwise. --health ORs this into
#                           its `degraded` flag.
#
# Returns 0 on rendered block, 1 when none is buffered.
readsb_render_stats_summary() {
	local _pfx=${1:-} _ipfx _kv
	_ipfx="${_pfx}  "

	readsb_stats_loss_seen=0

	_kv=$(readsb_log_stats_summary 2>/dev/null) || return 1
	[ -n "$_kv" ] || return 1

	# Hoist key=value pairs into local shell vars so the render block
	# stays linear. Missing keys leave the var empty -> rendered as (n/a).
	local st_window= st_proc= st_drop= st_lost= st_preambles=
	local st_crc_ok= st_crc_rp= st_noise= st_sig= st_peak=
	local st_strong= st_usable= st_pos_air= st_pos_cpr=
	local st_tracks= st_tracks_one= st_cpu=
	local _k _v
	while IFS=' ' read -r _k _v; do
		case $_k in
		window)       st_window=$_v ;;
		samples_proc) st_proc=$_v ;;
		samples_drop) st_drop=$_v ;;
		samples_lost) st_lost=$_v ;;
		preambles)    st_preambles=$_v ;;
		crc_ok)       st_crc_ok=$_v ;;
		crc_repaired) st_crc_rp=$_v ;;
		noise_dbfs)   st_noise=$_v ;;
		signal_dbfs)  st_sig=$_v ;;
		peak_dbfs)    st_peak=$_v ;;
		strong_msgs)  st_strong=$_v ;;
		usable_msgs)  st_usable=$_v ;;
		pos_air)      st_pos_air=$_v ;;
		pos_cpr_ok)   st_pos_cpr=$_v ;;
		tracks)       st_tracks=$_v ;;
		tracks_one)   st_tracks_one=$_v ;;
		cpu_pct)      st_cpu=$_v ;;
		esac
	done <<EOF
$_kv
EOF
	# `window` may contain multiple words; safe because we never
	# re-tokenise $_v after the initial single-space read.

	printf '%slast stats block:\n' "$_pfx"
	[ -n "$st_window" ] && \
		printf '%swindow         : %s\n' "$_ipfx" "$st_window"
	# Local SDR receiver -- demod numbers.
	if [ -n "$st_preambles$st_crc_ok$st_crc_rp" ]; then
		printf '%sMode-S preambl.: %s seen, %s good CRC, %s 1-bit repaired\n' \
			"$_ipfx" \
			"${st_preambles:-(n/a)}" \
			"${st_crc_ok:-(n/a)}" \
			"${st_crc_rp:-(n/a)}"
	fi
	# Signal levels (dBFS).
	if [ -n "$st_noise$st_sig$st_peak" ]; then
		printf '%ssignal (dBFS)  : noise %s / mean %s / peak %s\n' \
			"$_ipfx" \
			"${st_noise:-(n/a)}" \
			"${st_sig:-(n/a)}" \
			"${st_peak:-(n/a)}"
	fi
	[ -n "$st_strong" ] && \
		printf '%sstrong msgs    : %s above -3 dBFS (saturation indicator)\n' \
			"$_ipfx" "$st_strong"
	# Decoded output.
	[ -n "$st_usable" ] && \
		printf '%susable msgs    : %s\n' "$_ipfx" "$st_usable"
	if [ -n "$st_pos_air$st_pos_cpr" ]; then
		printf '%spositions      : %s airborne / %s good CPR\n' \
			"$_ipfx" \
			"${st_pos_air:-(n/a)}" \
			"${st_pos_cpr:-(n/a)}"
	fi
	if [ -n "$st_tracks$st_tracks_one" ]; then
		printf '%saircraft tracks: %s unique (%s seen once)\n' \
			"$_ipfx" \
			"${st_tracks:-(n/a)}" \
			"${st_tracks_one:-(n/a)}"
	fi
	[ -n "$st_cpu" ] && \
		printf '%sCPU load       : %s%%\n' "$_ipfx" "$st_cpu"
	# Sample loss is the daemon's own report of USB-side overruns.
	# Empty st_drop/st_lost is left alone (the existing error scan still
	# picks up the underlying syslog warning); non-zero on either flips
	# readsb_stats_loss_seen so callers can mark the run DEGRADED.
	if [ -n "$st_drop$st_lost" ]; then
		printf '%ssamples dropped: %s    samples lost: %s\n' \
			"$_ipfx" \
			"${st_drop:-(n/a)}" \
			"${st_lost:-(n/a)}"
		case $st_drop in ''|0) ;; *) readsb_stats_loss_seen=1 ;; esac
		case $st_lost in ''|0) ;; *) readsb_stats_loss_seen=1 ;; esac
	fi
}

# Syslog tag used by an optional companion package's services. Empty
# when the package has no log stream we know how to read.
readsb_pkg_log_tag() {
	case "$1" in
		adsbexchange-stats) echo "adsbexchange-stats" ;;
		*) echo "" ;;
	esac
}

# Up to <n> recent syslog lines tagged <tag> (default 200). rc 1 when
# logread is missing or tag is empty.
#
# `logread -e <tag>` is a SUBSTRING match against the whole line, so
# our own helper output (which mentions companion package names in
# status messages, e.g. "package 'adsbexchange-stats' installed but...")
# would otherwise leak into the count. Post-filter on the syslog tag
# field to drop lines emitted by readsb-setup/-feeder/-uuid/-geoip.
readsb_pkg_log_recent() {
	local tag=$1 n=${2:-200}
	[ -n "$tag" ] || return 1
	command -v logread >/dev/null 2>&1 || return 1
	logread -e "$tag" 2>/dev/null | awk '
		{
			# First field that looks like "name:" or "name[pid]:".
			for (i = 1; i <= NF; i++) {
				if ($i ~ /^[A-Za-z0-9._-]+(\[[0-9]+\])?:$/) {
					tag = $i
					sub(/\[[0-9]+\]:$/, "", tag)
					sub(/:$/, "", tag)
					# Drop chatter from our own helper CLIs.
					if (tag == "readsb-setup" ||
					    tag == "readsb-feeder" ||
					    tag == "readsb-uuid" ||
					    tag == "readsb-geoip")
						next
					break
				}
			}
			print
		}
	' | tail -n "$n"
}

# Total error/warn/crit syslog events for <tag>. Always a single integer.
# Generic vs `readsb_log_count_errors` (which adds readsb-specific
# substrings); companion packages don't share readsb's wording.
#
# Match: any daemon.{err,warn,crit,alert,emerg} severity, plus the
# common "ERROR:", "FATAL", "aborting" markers (caught when a script
# emits errors at daemon.info because procd captured stdout).
readsb_pkg_log_count_errors() {
	local tag=$1 buf
	buf=$(readsb_pkg_log_recent "$tag" 200) || { echo 0; return 0; }
	[ -n "$buf" ] || { echo 0; return 0; }
	echo "$buf" | awk '
		/daemon\.err|daemon\.warn|daemon\.crit|daemon\.alert|daemon\.emerg|ERROR:|FATAL[: ]|aborting/ { n++ }
		END { print n+0 }
	'
}

# Most recent log line for <tag>. Empty when no buffer.
readsb_pkg_log_last_line() {
	local tag=$1 buf
	buf=$(readsb_pkg_log_recent "$tag" 200) || return 0
	[ -n "$buf" ] || return 0
	echo "$buf" | tail -n 1
}

# Most recent error/warn line for <tag>. Pattern matches the count
# helper above so count > 0 always has a sample line to show.
readsb_pkg_log_last_error() {
	local tag=$1 buf
	buf=$(readsb_pkg_log_recent "$tag" 200) || return 0
	[ -n "$buf" ] || return 0
	echo "$buf" | awk '
		/daemon\.err|daemon\.warn|daemon\.crit|daemon\.alert|daemon\.emerg|ERROR:|FATAL[: ]|aborting/ { last = $0 }
		END { if (last) print last }
	'
}

# === interactive wizard helpers ============================================
# Shared by readsb-setup and readsb-feeder. Prompts read from /dev/tty,
# output goes to /dev/tty, and every helper returns non-zero on EOF (Ctrl-D).
# Caller passes the result variable name as $1 (POSIX, no namerefs).
#
# All wiz_* helpers prefix their locals with the helper's function name
# (e.g. __wask_* for wiz_ask, __wyn_* for wiz_yesno). REQUIRED because
# BusyBox ash's `local` is dynamically scoped: a generic local like
# `_ans` would shadow a caller-supplied output-variable name with the
# same spelling, and `eval "$_var=..."` would silently write to the
# helper's shadow instead of the caller's slot. Function-name prefixes
# guarantee uniqueness across the call stack.

# 0 if /dev/tty can be opened. Sub-shells so a failing redirection
# doesn't terminate the caller.
wiz_available() {
	( : >/dev/tty ) 2>/dev/null && ( : </dev/tty ) 2>/dev/null
}

# Print a message to the wizard's tty.
wiz_say() { printf '%s\n' "$*" >/dev/tty; }

# Recognize a literal user-typed abort token (q / quit / exit, any case).
# Returns 0 when matched (and prints a brief notice); rc 1 otherwise.
# Helpers call this on each read result and propagate rc 1 mirroring
# EOF behavior so callers see one consistent abort signal.
wiz_is_abort() {
	case ${1:-} in
		[Qq]|[Qq][Uu][Ii][Tt]|[Ee][Xx][Ii][Tt])
			printf '  (wizard aborted by user; no further prompts)\n' >/dev/tty
			return 0
			;;
	esac
	return 1
}

# Read a free-form line. Default value (if any) is offered in [brackets]
# and accepted on empty input.
#   wiz_ask <varname> <prompt> [<default>]
wiz_ask() {
	local __wask_var=$1 __wask_prompt=$2 __wask_def=${3:-} __wask_ans
	if [ -n "$__wask_def" ]; then
		printf '%s [%s]: ' "$__wask_prompt" "$__wask_def" >/dev/tty
	else
		printf '%s: ' "$__wask_prompt" >/dev/tty
	fi
	IFS= read -r __wask_ans </dev/tty || return 1
	wiz_is_abort "$__wask_ans" && return 1
	[ -n "$__wask_ans" ] || __wask_ans=$__wask_def
	eval "$__wask_var=\$__wask_ans"
}

# Yes/no prompt; default is N unless explicitly Y. Sets var to 1 or 0.
#   wiz_yesno <varname> <prompt> [Y|N]
wiz_yesno() {
	local __wyn_var=$1 __wyn_prompt=$2 __wyn_def=${3:-N} __wyn_hint __wyn_ans
	case $__wyn_def in [Yy]*) __wyn_hint='[Y/n]' ;; *) __wyn_hint='[y/N]' ;; esac
	while :; do
		printf '%s %s: ' "$__wyn_prompt" "$__wyn_hint" >/dev/tty
		IFS= read -r __wyn_ans </dev/tty || return 1
		wiz_is_abort "$__wyn_ans" && return 1
		[ -n "$__wyn_ans" ] || __wyn_ans=$__wyn_def
		case $__wyn_ans in
			[Yy]|[Yy][Ee][Ss]) eval "$__wyn_var=1"; return 0 ;;
			[Nn]|[Nn][Oo])     eval "$__wyn_var=0"; return 0 ;;
		esac
		printf '  please answer yes or no (or q/quit/exit to abort)\n' >/dev/tty
	done
}

# Numbered menu; rejects out-of-range and non-numeric input. Prints
# choices to /dev/tty as "1) name", returns the chosen string in var.
#   wiz_choose <varname> <prompt> <choice1> <choice2> ...
wiz_choose() {
	local __wch_var=$1 __wch_prompt=$2; shift 2
	local __wch_n=0 __wch_i __wch_ans __wch_c
	for __wch_c in "$@"; do
		__wch_n=$((__wch_n + 1))
		printf '  %d) %s\n' "$__wch_n" "$__wch_c" >/dev/tty
	done
	[ "$__wch_n" -gt 0 ] || return 1
	while :; do
		printf '%s [1-%d]: ' "$__wch_prompt" "$__wch_n" >/dev/tty
		IFS= read -r __wch_ans </dev/tty || return 1
		wiz_is_abort "$__wch_ans" && return 1
		case $__wch_ans in
			''|*[!0-9]*) printf '  enter a number 1-%d (or q/quit/exit to abort)\n' "$__wch_n" >/dev/tty; continue ;;
		esac
		if [ "$__wch_ans" -ge 1 ] && [ "$__wch_ans" -le "$__wch_n" ]; then
			__wch_i=0
			for __wch_c in "$@"; do
				__wch_i=$((__wch_i + 1))
				if [ "$__wch_i" -eq "$__wch_ans" ]; then
					eval "$__wch_var=\$__wch_c"
					return 0
				fi
			done
		fi
		printf '  out of range\n' >/dev/tty
	done
}

# Ask a value with validation -- caller supplies a function name that
# returns 0 on accept. The value is re-prompted until accepted or EOF.
#   wiz_ask_validated <varname> <prompt> <default> <validator-fn> [<errmsg>]
# The validator receives the candidate as $1 and may print its own error
# to /dev/tty. If <errmsg> is supplied, it's printed on rejection too.
wiz_ask_validated() {
	local __wav_var=$1 __wav_prompt=$2 __wav_def=$3 __wav_fn=$4 \
		__wav_err=${5:-'invalid input'} __wav_try
	while :; do
		wiz_ask __wav_try "$__wav_prompt" "$__wav_def" || return 1
		if "$__wav_fn" "$__wav_try"; then
			eval "$__wav_var=\$__wav_try"
			return 0
		fi
		printf '  %s\n' "$__wav_err" >/dev/tty
	done
}

# Final "apply or abort" gate. Default is YES so just hitting Enter
# commits; any No-leaning answer aborts with rc 1.
#   wiz_confirm <prompt>
wiz_confirm() {
	local __wcf_ans
	wiz_yesno __wcf_ans "${1:-apply changes?}" Y || return 1
	[ "$__wcf_ans" = 1 ]
}

# Validators usable as wiz_ask_validated <fn>. All return 0 on accept.
wiz_v_lat() {
	# -90.0 .. 90.0, optional sign, optional decimals.
	case $1 in
		''|*[!0-9.+-]*) return 1 ;;
		*) ;;
	esac
	# awk handles the float bounds without bringing in bc.
	awk -v v="$1" 'BEGIN{ exit !(v+0 >= -90 && v+0 <= 90) }'
}
wiz_v_lon() {
	case $1 in
		''|*[!0-9.+-]*) return 1 ;;
		*) ;;
	esac
	awk -v v="$1" 'BEGIN{ exit !(v+0 >= -180 && v+0 <= 180) }'
}
wiz_v_port() {
	case $1 in ''|*[!0-9]*) return 1 ;; esac
	[ "$1" -ge 1 ] && [ "$1" -le 65535 ]
}
wiz_v_uci_name() {
	case $1 in
		''|[!a-zA-Z]*) return 1 ;;
		*[!a-zA-Z0-9_]*) return 1 ;;
	esac
}
wiz_v_uuid() { readsb_is_uuid "$1"; }
wiz_v_host() {
	# Reject empty/whitespace; UCI doesn't validate DNS so anything else passes.
	case $1 in
		''|*[[:space:]]*) return 1 ;;
		*) return 0 ;;
	esac
}
# Gain: 'auto', 'max', or numeric 0..50 dB.
wiz_v_gain() {
	case $1 in
		auto|max) return 0 ;;
		''|*[!0-9.]*) return 1 ;;
	esac
	awk -v v="$1" 'BEGIN{ exit !(v+0 >= 0 && v+0 <= 50) }'
}
# PPM correction: integer or decimal in -100..100; bare '0' accepted fast.
wiz_v_ppm() {
	case $1 in
		''|0) return 0 ;;
		-*) case ${1#-} in ''|*[!0-9.]*) return 1 ;; esac ;;
		*[!0-9.]*) return 1 ;;
	esac
	awk -v v="$1" 'BEGIN{ exit !(v+0 >= -100 && v+0 <= 100) }'
}
