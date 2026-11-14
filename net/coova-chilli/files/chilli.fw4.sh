# Runtime firewall4 fragments and post-apply synchronization for CoovaChilli.

CHILLI_FW4_DIR=/var/run/chilli/fw4
CHILLI_FW4_LOCS="input forward mangle_forward dstnat table"

chilli_fw4_warn() {
	logger -t chilli -p daemon.warn "$*"
}

chilli_fw4_err() {
	logger -t chilli -p daemon.err "$*"
}

chilli_fw4_ifname() {
	case "$1" in ''|*[!a-zA-Z0-9_.-]*) return 1;; esac
	[ "${#1}" -le 15 ]
}

chilli_fw4_kname() {
	case "$1" in *[!a-zA-Z0-9_.-]*) return 1;; esac
	[ "${#1}" -lt 200 ]
}

chilli_fw4_port() {
	case "$1" in [1-9]|[1-9][0-9]|[1-9][0-9][0-9]|[1-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9][0-9]) ;; *) return 1;; esac
	[ "$1" -le 65535 ]
}

chilli_fw4_ports() {
	local p
	for p; do
		case "$p" in
		*-*) chilli_fw4_port "${p%-*}" && chilli_fw4_port "${p#*-}" &&
			[ "${p%-*}" -le "${p#*-}" ] || return 1;;
		*) chilli_fw4_port "$p" || return 1;;
		esac
	done
}

# User-supplied values interpolated into the rules. chilli formats ADDR and
# the UAM ports itself; the scratch check covers anything left.
chilli_fw4_values() {
	chilli_fw4_ports $HS_UDP_PORTS $HS_TCP_PORTS || return 1
	[ -n "$KNAME" ] || [ -z "$HS_WANIF" ] || chilli_fw4_ifname "$HS_WANIF"
}

# Escape punctuation after escaping the escape character: collision-free for
# validated interface names, using only the base-system sed applet.
chilli_fw4_chain_name() {
	printf 'chilli_'
	printf '%s' "$1" | sed 's/_/_5f/g; s/\./_2e/g; s/-/_2d/g'
}

# /proc stat's comm may contain spaces; field 22 follows 19 fields after it.
chilli_fw4_starttime() (
	local stat
	read -r stat < "/proc/$1/stat" || exit 1
	stat="${stat##*) }"
	set -f
	set -- $stat
	[ "$#" -ge 20 ] || exit 1
	shift 19
	printf '%s\n' "$1"
)

# Fixed lines, never shell source or eval. The owner and ifindex prevent a dead
# daemon's registration from granting access to a subsequently reused tun name.
chilli_fw4_read_state() {
	local extra
	{
		read -r DHCPIF && read -r KNAME && read -r TUNTAP &&
		read -r CHILLI_PID && read -r CHILLI_START && read -r CHILLI_IFINDEX &&
		! read -r extra
	} < "$1" || return 1
	chilli_fw4_ifname "$DHCPIF" && chilli_fw4_ifname "$TUNTAP" &&
		chilli_fw4_kname "$KNAME" || return 1
	case "$CHILLI_PID:$CHILLI_START:$CHILLI_IFINDEX" in *[!0-9:]*|:*|*::*|*:) return 1;; esac
	[ "${1##*/}" = "$TUNTAP.state" ] || case "${1##*/}" in "$TUNTAP".*.retired) return 0;; *) return 1;; esac
}

chilli_fw4_alive() {
	local index
	[ "$(chilli_fw4_starttime "$CHILLI_PID")" = "$CHILLI_START" ] || return 1
	read -r index < "/sys/class/net/$TUNTAP/ifindex" || return 1
	[ "$index" = "$CHILLI_IFINDEX" ]
}

# All kname jumps precede all general tun accepts, including other instances.
# Input: clients reach the portal, DNS and DHCP through the tun; the kernel's
# own copy from DHCPIF is dropped, or it would reset portal TCP. Authorized
# kname clients bypass the tun, so their portal, DNS, ICMP and HS_* port
# traffic arrives on DHCPIF; the coova INPUT drop stops unauthorized
# clients there first. With ONLY8021Q, chilli serves only tagged clients,
# which never match DHCPIF itself: no DHCPIF rules, so untagged hosts keep
# their zone policy.
chilli_fw4_gen() {
	local tun="$1" loc="$2" c port
	c="comment \"chilli $tun\""
	if [ "$loc" = input ]; then
		[ "$LAYER3" != 1 ] || return 0
		if [ -n "$KNAME" ] && [ "$ONLY8021Q" != 1 ]; then
			echo "iifname \"$DHCPIF\" ip daddr $ADDR ip protocol icmp accept $c"
			echo "iifname \"$DHCPIF\" ip daddr $ADDR udp dport 53 accept $c"
			for port in $HS_UDP_PORTS; do
				echo "iifname \"$DHCPIF\" ip daddr $ADDR udp dport $port accept $c"
			done
			for port in $HS_TCP_PORTS; do
				echo "iifname \"$DHCPIF\" ip daddr $ADDR tcp dport $port accept $c"
			done
			[ -n "$UAMUIPORT" ] && [ "$UAMUIPORT" != 0 ] && echo "iifname \"$DHCPIF\" ip daddr $ADDR tcp dport $UAMUIPORT accept $c"
			[ -n "$UAMPORT" ] && [ "$UAMPORT" != 0 ] && echo "iifname \"$DHCPIF\" ip daddr $ADDR tcp dport $UAMPORT accept $c"
		fi
		[ "$ONLY8021Q" = 1 ] || echo "iifname \"$DHCPIF\" counter drop $c"
		echo "iifname \"$tun\" ip daddr $ADDR ip protocol icmp accept $c"
		echo "iifname \"$tun\" ip daddr $ADDR udp dport 53 accept $c"
		echo "iifname \"$tun\" ip daddr $ADDR udp dport 67-68 accept $c"
		echo "iifname \"$tun\" ip daddr 255.255.255.255 udp dport 67-68 accept $c"
		for port in $HS_UDP_PORTS; do
			echo "iifname \"$tun\" ip daddr $ADDR udp dport $port accept $c"
		done
		for port in $HS_TCP_PORTS; do
			echo "iifname \"$tun\" ip daddr $ADDR tcp dport $port accept $c"
		done
		[ -n "$UAMUIPORT" ] && [ "$UAMUIPORT" != 0 ] && echo "iifname \"$tun\" ip daddr $ADDR tcp dport $UAMUIPORT accept $c"
		[ -n "$UAMPORT" ] && [ "$UAMPORT" != 0 ] && echo "iifname \"$tun\" ip daddr $ADDR tcp dport $UAMPORT accept $c"
		echo "iifname \"$tun\" ip daddr $ADDR counter drop $c"
		return 0
	fi
	if [ -n "$KNAME" ]; then
		case "$loc" in
		table)
			[ "$ONLY8021Q" != 1 ] || return 0
			printf 'chain %s {\n' "$(chilli_fw4_chain_name "$tun")"
			printf 'oifname "%s" counter drop %s\n' "$DHCPIF" "$c"
			printf 'iifname "%s" counter drop %s\n}\n' "$DHCPIF" "$c"
			;;
		forward)
			printf 'oifname "%s" accept %s\niifname "%s" accept %s\n' "$tun" "$c" "$tun" "$c"
			;;
		esac
		return 0
	fi
	case "$loc" in
	forward)
		if [ -n "$HS_WANIF" ]; then
			echo "iifname \"$tun\" oifname \"$HS_WANIF\" accept $c"
			[ "$HS_LAN_ACCESS" != on ] && [ "$HS_LAN_ACCESS" != allow ] && echo "iifname \"$tun\" oifname != \"$HS_WANIF\" counter drop $c"
		fi
		echo "oifname \"$tun\" accept $c"
		echo "iifname \"$tun\" accept $c"
		if [ "$ONLY8021Q" != 1 ]; then
			echo "oifname \"$DHCPIF\" counter drop $c"
			echo "iifname \"$DHCPIF\" counter drop $c"
		fi
		;;
	mangle_forward)
		echo "iifname \"$tun\" tcp flags & (syn | rst) == syn tcp option maxseg size set rt mtu $c"
		echo "oifname \"$tun\" tcp flags & (syn | rst) == syn tcp option maxseg size set rt mtu $c"
		;;
	dstnat)
		[ "$HS_LOCAL_DNS" = on ] && echo "iifname \"$tun\" udp dport 53 dnat ip to $ADDR $c"
		;;
	esac
	return 0
}

# Called only with the chilli lock. Atomic renames keep nft from reading a
# partially written file; registrations survive a stopped or absent firewall.
# Returns 1 when the merged files are not published, 2 when they are but
# table inet chilli keeps its previous generation.
chilli_fw4_merge() {
	local loc f tun new
	for loc in $CHILLI_FW4_LOCS; do
		new="$CHILLI_FW4_DIR/$loc.new"
		{
			if [ "$loc" = forward ]; then
				for f in "$CHILLI_FW4_DIR"/*.table.nft; do
					[ -s "$f" ] || continue
					tun="${f##*/}"; tun="${tun%.table.nft}"
					printf 'jump %s comment "chilli %s"\n' "$(chilli_fw4_chain_name "$tun")" "$tun"
				done
			fi
			for f in "$CHILLI_FW4_DIR"/*."$loc".nft; do
				[ -f "$f" ] || continue
				cat "$f" || { rm -f "$new"; return 1; }
			done
		} > "$new" && mv -f "$new" "$CHILLI_FW4_DIR/$loc.nft" || { rm -f "$new"; return 1; }
	done
	chilli_fw4_guard || {
		chilli_fw4_warn 'cannot apply chilli DHCP interface drops'
		return 2
	}
}

# DHCPIF drops for instances without kname, outside table inet fw4: they
# stay loaded when an unrelated include makes fw4 reload fail. kname
# instances rely on their coova drops instead.
chilli_fw4_guard_gen() {
	local c="comment \"chilli $TUNTAP\""
	[ -z "$KNAME" ] && [ "$ONLY8021Q" != 1 ] || return 0
	[ "$LAYER3" = 1 ] || echo "add rule inet chilli input iifname \"$DHCPIF\" drop $c"
	echo "add rule inet chilli forward iifname \"$DHCPIF\" drop $c"
	echo "add rule inet chilli forward oifname \"$DHCPIF\" drop $c"
}

# Rebuild table inet chilli in one transaction; delete it when unused.
chilli_fw4_guard() {
	local f used=
	for f in "$CHILLI_FW4_DIR"/*.guard.nft; do
		[ ! -s "$f" ] || used=1
	done
	{
		echo 'table inet chilli'
		echo 'delete table inet chilli'
		if [ -n "$used" ]; then
			echo 'table inet chilli {'
			echo 'chain input { type filter hook input priority filter; }'
			echo 'chain forward { type filter hook forward priority filter; }'
			echo '}'
			cat "$CHILLI_FW4_DIR"/*.guard.nft
		fi
	} | nft -f -
}

# Check the candidate alone in a scratch table, so an unrelated broken
# ruleset can neither reject a valid candidate nor hide an invalid one.
chilli_fw4_check() {
	local s="$CHILLI_FW4_DIR/$1"
	{
		echo 'table inet chilli_check {'
		cat "$s.table.new"
		echo 'chain input { type filter hook input priority filter;'
		cat "$s.input.new"
		echo '}'
		echo 'chain forward { type filter hook forward priority filter;'
		[ ! -s "$s.table.new" ] || printf 'jump %s\n' "$(chilli_fw4_chain_name "$1")"
		cat "$s.forward.new"
		echo '}'
		echo 'chain mangle_forward { type filter hook forward priority mangle;'
		cat "$s.mangle_forward.new"
		echo '}'
		echo 'chain dstnat { type nat hook prerouting priority dstnat;'
		cat "$s.dstnat.new"
		echo '}'
		echo '}'
	} | nft -c -f - >/dev/null 2>&1
}

# Returns 1 when the registration state is not published; fragments without
# it are removed by the next unregister. Returns 2 when the state is
# published, so the next synchronization retries it, but merged files or
# this instance's drops are not loaded yet.
chilli_fw4_register() {
	local loc input rc n="$CHILLI_FW4_DIR/$TUNTAP"
	[ ! -f "$n.state" ] || return 1
	chilli_fw4_ifname "$TUNTAP" && chilli_fw4_ifname "$DHCPIF" &&
		chilli_fw4_kname "$KNAME" && chilli_fw4_values || return 1
	CHILLI_PID="$PPID"
	CHILLI_START="$(chilli_fw4_starttime "$CHILLI_PID")" || return 1
	read -r CHILLI_IFINDEX < "/sys/class/net/$TUNTAP/ifindex" || return 1
	mkdir -p "$CHILLI_FW4_DIR" || return 1
	chmod 700 "$CHILLI_FW4_DIR"
	for loc in $CHILLI_FW4_LOCS; do
		chilli_fw4_gen "$TUNTAP" "$loc" > "$n.$loc.new" || { rm -f "$n".*.new; return 1; }
	done
	chilli_fw4_guard_gen > "$n.guard.new" && chilli_fw4_check "$TUNTAP" || { rm -f "$n".*.new; return 1; }
	for loc in $CHILLI_FW4_LOCS guard; do
		mv -f "$n.$loc.new" "$n.$loc.nft" || { rm -f "$n".*.new; return 1; }
	done
	printf '%s\n' "$DHCPIF" "$KNAME" "$TUNTAP" "$CHILLI_PID" "$CHILLI_START" "$CHILLI_IFINDEX" > "$n.state.new" &&
		mv -f "$n.state.new" "$n.state" || { rm -f "$n.state.new"; return 1; }
	chilli_fw4_merge; rc=$?
	# A failed guard rebuild matters here only if this instance has guard drops.
	case "$rc" in 1) rc=2;; 2) [ -s "$n.guard.nft" ] || rc=0;; esac
	# Unauthenticated kname clients stay dropped even when fw4 cannot load.
	input=1; [ "$LAYER3" != 1 ] || input=0
	if [ -n "$KNAME" ] && [ "$ONLY8021Q" != 1 ] && ! { command -v iptables-nft >/dev/null 2>&1 && chilli_fw4_drops "$input"; }; then
		chilli_fw4_warn "cannot add coova drops for $KNAME on $DHCPIF"
		rc=2
	fi
	return "$rc"
}

# Whether this instance's DHCPIF drops are loaded. ONLY8021Q has none.
# kname: the coova drops, including INPUT, which keeps unauthorized clients
# off the DHCPIF accepts (its fw4 chain accepts once authorized). Otherwise:
# the guard rules or the fw4 forward drops.
chilli_fw4_guarded() {
	local c="comment \"chilli $TUNTAP\""
	[ "$ONLY8021Q" != 1 ] || return 0
	if [ -n "$KNAME" ]; then
		command -v iptables-nft >/dev/null 2>&1 &&
			chilli_fw4_drop -C FORWARD -i 2>/dev/null && chilli_fw4_drop -C FORWARD -o --dest 2>/dev/null &&
			{ [ "$LAYER3" = 1 ] || chilli_fw4_drop -C INPUT -i 2>/dev/null; }
		return
	fi
	nft list table inet chilli 2>/dev/null | grep -F "$c" | grep -qF "oifname \"$DHCPIF\" drop" ||
		nft list chain inet fw4 forward 2>/dev/null | grep -F "$c" | grep -qF "oifname \"$DHCPIF\" counter"
}

chilli_fw4_unregister() {
	local tun="$1"
	chilli_fw4_ifname "$tun" || return 1
	[ -d "$CHILLI_FW4_DIR" ] || return 0
	# Retired metadata can only remove drops; post-apply never authorizes it.
	[ ! -f "$CHILLI_FW4_DIR/$tun.state" ] || mv -f "$CHILLI_FW4_DIR/$tun.state" "$CHILLI_FW4_DIR/$tun.$$.retired" || return 1
	rm -f "$CHILLI_FW4_DIR/$tun".*.nft
	chilli_fw4_merge || [ "$?" = 2 ] || return 1
	chilli_fw4_prune "$tun"
}

# Unknown is not empty. Never start a deliberately stopped firewall.
chilli_fw4_table() {
	local tables
	tables="$(nft list tables 2>/dev/null)" || return 2
	printf '%s\n' "$tables" | grep -qx 'table inet fw4' || return 1
	nft list table inet fw4 2>/dev/null || return 2
}

# MUST be called without the chilli lock: fw4's post-include takes that lock.
chilli_fw4_reload() {
	local rc
	command -v fw4 >/dev/null 2>&1 && command -v nft >/dev/null 2>&1 || {
		chilli_fw4_warn 'fw4/nft unavailable; chilli firewall registration retained'
		return 1
	}
	chilli_fw4_table >/dev/null; rc=$?
	[ "$rc" != 1 ] || return 0
	[ "$rc" = 0 ] && fw4 -q check && fw4 -q reload || {
		chilli_fw4_warn 'cannot apply chilli firewall rules; registration retained'
		# A check/load failure may leave the old generation loaded and blocked.
		# Restore only registrations matching those live chains, without reload.
		{
			flock -x 8
			flock -x 9
			chilli_fw4_sync || chilli_fw4_warn 'cannot restore previous chilli firewall generation'
		} 8>/var/run/fw4.lock 9>/tmp/.chilli-flock
		return 1
	}
}

# chilli_fw4_drop <op> <chain> <direction> [--dest]
chilli_fw4_drop() {
	local op="$1" chain="$2" direction="$3"
	shift 3
	iptables-nft "$op" "$chain" "$direction" "$DHCPIF" -m coova ! --name "$KNAME" "$@" -j DROP
}

# chilli_fw4_drops <input>: input=1 also keeps unauthorized clients off the
# portal ports that fw4 opens on DHCPIF for authorized kname clients.
chilli_fw4_drops() {
	chilli_fw4_drop -C FORWARD -i 2>/dev/null || chilli_fw4_drop -I FORWARD -i || return 1
	chilli_fw4_drop -C FORWARD -o --dest 2>/dev/null || chilli_fw4_drop -I FORWARD -o --dest || return 1
	if [ "$1" = 1 ]; then
		chilli_fw4_drop -C INPUT -i 2>/dev/null || chilli_fw4_drop -I INPUT -i || return 1
		chilli_fw4_drop -C INPUT -i || return 1
	fi
	chilli_fw4_drop -C FORWARD -i && chilli_fw4_drop -C FORWARD -o --dest
}

# Flush/rebuild in ONE nft transaction: neither a flush-only interval nor a
# one-direction allow is visible. The static chain is always the blocked form.
chilli_fw4_chain() {
	local allow="$1" chain
	chain="$(chilli_fw4_chain_name "$TUNTAP")"
	{
		printf 'flush chain inet fw4 %s\n' "$chain"
		if [ "$allow" = 1 ]; then
			printf 'add rule inet fw4 %s meta nfproto ipv4 oifname "%s" accept comment "chilli %s"\n' "$chain" "$DHCPIF" "$TUNTAP"
			printf 'add rule inet fw4 %s meta nfproto ipv4 iifname "%s" accept comment "chilli %s"\n' "$chain" "$DHCPIF" "$TUNTAP"
		fi
		printf 'add rule inet fw4 %s oifname "%s" counter drop comment "chilli %s"\n' "$chain" "$DHCPIF" "$TUNTAP"
		printf 'add rule inet fw4 %s iifname "%s" counter drop comment "chilli %s"\n' "$chain" "$DHCPIF" "$TUNTAP"
	} | nft -f -
}

# fw4 may leave an unreferenced user chain behind. Remove this instance's
# exact-comment rules by handle, then its chain, in one transaction. Unknown
# rulesets or a failed transaction retain metadata and coova enforcement.
chilli_fw4_prune() {
	local tun="$1" live line word name rest current handle chain batch=
	chilli_fw4_ifname "$tun" || return 1
	live="$(nft -a list table inet fw4 2>/dev/null)" || {
		chilli_fw4_table >/dev/null
		[ "$?" = 1 ]
		return
	}
	chain="$(chilli_fw4_chain_name "$tun")"
	while IFS= read -r line; do
		read -r word name rest <<EOF
$line
EOF
		if [ "$word" = chain ]; then
			case "$name" in ''|*[!a-zA-Z0-9_./-]*) return 1;; esac
			current="$name"
		fi
		case "$line" in
		*"comment \"chilli $tun\""*" # handle "*)
			handle="${line##*# handle }"
			case "$handle" in ''|*[!0-9]*) return 1;; esac
			batch="${batch}delete rule inet fw4 $current handle $handle
"
			;;
		esac
	done <<EOF
$live
EOF
	case "$live" in *"chain $chain {"*) batch="${batch}delete chain inet fw4 $chain
";; esac
	[ -z "$batch" ] || printf '%s' "$batch" | nft -f -
}

chilli_fw4_cleanup() {
	local f live active shared active_dhcp active_kname
	local DHCPIF KNAME TUNTAP CHILLI_PID CHILLI_START CHILLI_IFINDEX
	live="$(chilli_fw4_table)" || {
		[ "$?" = 1 ] || return 1
		live=
	}
	for f in "$CHILLI_FW4_DIR"/*.retired; do
		[ -f "$f" ] || continue
		chilli_fw4_read_state "$f" || continue
		if [ ! -f "$CHILLI_FW4_DIR/$TUNTAP.state" ]; then
			chilli_fw4_prune "$TUNTAP" || continue
			live="$(chilli_fw4_table)" || {
				[ "$?" = 1 ] || return 1
				live=
			}
			# A failed removal must never release its coova enforcement.
			printf '%s\n' "$live" | grep -qF "comment \"chilli $TUNTAP\"" && continue
		fi
		shared=0
		for active in "$CHILLI_FW4_DIR"/*.state; do
			[ -f "$active" ] || continue
			# Compare the first two fixed lines, without changing this record.
			if { read -r active_dhcp; read -r active_kname; [ "$active_dhcp" = "$DHCPIF" ] && [ "$active_kname" = "$KNAME" ]; } < "$active"; then
				shared=1; break
			fi
		done
		[ "$shared" = 0 ] || continue
		if [ -n "$KNAME" ]; then
			command -v iptables-nft >/dev/null 2>&1 || continue
			while chilli_fw4_drop -C FORWARD -i 2>/dev/null; do chilli_fw4_drop -D FORWARD -i || return 1; done
			while chilli_fw4_drop -C FORWARD -o --dest 2>/dev/null; do chilli_fw4_drop -D FORWARD -o --dest || return 1; done
			while chilli_fw4_drop -C INPUT -i 2>/dev/null; do chilli_fw4_drop -D INPUT -i || return 1; done
		fi
		rm -f "$f"
	done
}

chilli_fw4_block() {
	local live chain word rest tun dhcp rules TUNTAP DHCPIF
	live="$(chilli_fw4_table)" || {
		[ "$?" = 1 ] && return 0
		chilli_fw4_warn 'cannot read nft ruleset; chilli state and coova drops retained'
		return 1
	}
	# Reset every loaded chain before attempting any instance restoration.
	while read -r word chain rest; do
		[ "$word" = chain ] || continue
		case "$chain" in chilli_*[!a-zA-Z0-9_]*|chilli_) continue;; chilli_*) ;; *) continue;; esac
		rules="$(nft list chain inet fw4 "$chain" 2>/dev/null)" || return 1
		tun="$(printf '%s\n' "$rules" | sed -n 's/^[[:space:]]*oifname ".*" counter .* drop comment "chilli \([a-zA-Z0-9_.-]*\)"$/\1/p')"
		chilli_fw4_ifname "$tun" && [ "$(chilli_fw4_chain_name "$tun")" = "$chain" ] || return 1
		dhcp="$(printf '%s\n' "$rules" | sed -n 's/^[[:space:]]*oifname "\([a-zA-Z0-9_.-]*\)" counter .* drop comment "chilli .*"$/\1/p')"
		chilli_fw4_ifname "$dhcp" || return 1
		TUNTAP="$tun" DHCPIF="$dhcp" chilli_fw4_chain 0 || return 1
	done <<EOF
$live
EOF
}

chilli_fw4_sync() {
	local live f rules input rc=0 DHCPIF KNAME TUNTAP CHILLI_PID CHILLI_START CHILLI_IFINDEX
	live="$(chilli_fw4_table)" || {
		[ "$?" = 1 ] && return 0
		chilli_fw4_warn 'cannot read nft ruleset; chilli state and coova drops retained'
		return 1
	}
	chilli_fw4_block || return 1
	# fw4 stop/start flushes every table, including inet chilli.
	chilli_fw4_guard || { chilli_fw4_warn 'cannot restore chilli DHCP interface drops'; rc=1; }
	for f in "$CHILLI_FW4_DIR"/*.state; do
		[ -f "$f" ] || continue
		if ! chilli_fw4_read_state "$f"; then
			chilli_fw4_warn "invalid chilli firewall registration $f"
			rc=1; continue
		fi
		if ! chilli_fw4_alive; then
			chilli_fw4_unregister "$TUNTAP"
			continue
		fi
		[ -n "$KNAME" ] || continue
		rules="$(nft list chain inet fw4 "$(chilli_fw4_chain_name "$TUNTAP")" 2>/dev/null)" || continue
		# Match both the chain and its loaded interface before granting access.
		printf '%s\n' "$rules" | grep -qF "oifname \"$DHCPIF\" counter" || continue
		printf '%s\n' "$rules" | grep -qF "iifname \"$DHCPIF\" counter" || continue
		# Loaded DHCPIF portal accepts need the coova INPUT drop.
		input=0
		printf '%s\n' "$live" | grep -F "comment \"chilli $TUNTAP\"" | grep -qF "iifname \"$DHCPIF\" ip daddr" && input=1
		if ! command -v iptables-nft >/dev/null 2>&1 || ! chilli_fw4_drops "$input" || ! chilli_fw4_chain 1; then
			chilli_fw4_warn "kname $KNAME on $DHCPIF remains blocked: coova/firewall synchronization failed"
			rc=1
		fi
	done
	chilli_fw4_cleanup || rc=1
	return "$rc"
}
