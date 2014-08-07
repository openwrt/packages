# l2tp.sh - L2TPv3 tunnel backend
# Copyright (c) 2010 OpenWrt.org

l2tp_next_tunnel_id() {
	local max=0
	local val
	for val in $(
		local l
		l2tpv3tun show tunnel | while read l; do
			case "$l" in
				Tunnel*,*encap*) l="${l#Tunnel }"; echo "${l%%,*}";;
			esac
		done
	); do
		[ "$val" -gt "$max" ] && max="$val"
	done
	echo $((max + 1))
}

l2tp_next_session_id() {
	local tunnel="$1"
	local max=0
	local val
	for val in $(
		local l
		l2tpv3tun show session${tunnel:+ tunnel_id "$tunnel"} | while read l; do
			case "$l" in
				Session*in*) l="${l#Session }"; echo "${l%% *}";;
			esac
		done
	); do
		[ "$val" -gt "$max" ] && max="$val"
	done
	echo $((max + 1))
}

l2tp_tunnel_exists() {
	test -n "$(l2tpv3tun show tunnel tunnel_id "$1" 2>/dev/null)"
}

l2tp_session_exists() {
	test -n "$(l2tpv3tun show session tunnel_id "$1" session_id "$2" 2>/dev/null)"
}

l2tp_ifname() {
	l2tpv3tun show session tunnel_id "$1" session_id "$2" 2>/dev/null | \
		sed -ne 's/^.*interface name: //p'
}

l2tp_lock() {
	lock /var/lock/l2tp-setup
}

l2tp_unlock() {
	lock -u /var/lock/l2tp-setup
}

l2tp_log() {
	logger -t "ifup-l2tp" "$@"
}


# Hook into scan_interfaces() to synthesize a .device option
# This is needed for /sbin/ifup to properly dispatch control
# to setup_interface_l2tp() even if no .ifname is set in
# the configuration.
scan_l2tp() {
	local dev
	config_get dev "$1" device
	config_set "$1" device "${dev:+$dev }l2tp-$1"
}

coldplug_interface_l2tp() {
	setup_interface_l2tp "l2tp-$1" "$1"
}

setup_interface_l2tp() {
	local iface="$1"
	local cfg="$2"
	local link="l2tp-$cfg"

	l2tp_lock

	# prevent recursion
	local up="$(uci_get_state network "$cfg" up 0)"
	[ "$up" = 0 ] || {
		l2tp_unlock
		return 0
	}

	local tunnel_id
	config_get tunnel_id "$cfg" tunnel_id
	[ -n "$tunnel_id" ] || {
		tunnel_id="$(l2tp_next_tunnel_id)"
		uci_set_state network "$cfg" tunnel_id "$tunnel_id"
		l2tp_log "No tunnel ID specified, assuming $tunnel_id"
	}

	local peer_tunnel_id
	config_get peer_tunnel_id "$cfg" peer_tunnel_id
	[ -n "$peer_tunnel_id" ] || {
		peer_tunnel_id="$tunnel_id"
		uci_set_state network "$cfg" peer_tunnel_id "$peer_tunnel_id"
		l2tp_log "No peer tunnel ID specified, assuming $peer_tunnel_id"
	}

	local encap
	config_get encap "$cfg" encap udp

	local sport dport
	[ "$encap" = udp ] && {
		config_get sport "$cfg" sport 1701
		config_get dport "$cfg" dport 1701
	}

	local peeraddr
	config_get peeraddr "$cfg" peeraddr
	[ -z "$peeraddr" ] && config_get peeraddr "$cfg" peer6addr

	local localaddr
	case "$peeraddr" in
		*:*) config_get localaddr "$cfg" local6addr ;;
		*)   config_get localaddr "$cfg" localaddr  ;;
	esac

	[ -n "$localaddr" -a -n "$peeraddr" ] || {
		l2tp_log "Missing local or peer address for tunnel $cfg - skipping"
		return 1
	}

	(
		while ! l2tp_tunnel_exists "$tunnel_id"; do
			[ -n "$sport" ] && l2tpv3tun show tunnel 2>/dev/null | grep -q "ports: $sport/" && {
				l2tp_log "There already is a tunnel with src port $sport - skipping"
				l2tp_unlock
				return 1
			}

			l2tpv3tun add tunnel tunnel_id "$tunnel_id" peer_tunnel_id "$peer_tunnel_id" \
				encap "$encap" local "$localaddr" remote "$peeraddr" \
				${sport:+udp_sport "$sport"} ${dport:+udp_dport "$dport"}

			# Wait for tunnel
			sleep 1
		done


		local session_id
		config_get session_id "$cfg" session_id
		[ -n "$session_id" ] || {
			session_id="$(l2tp_next_session_id "$tunnel_id")"
			uci_set_state network "$cfg" session_id "$session_id"
			l2tp_log "No session ID specified, assuming $session_id"
		}

		local peer_session_id
		config_get peer_session_id "$cfg" peer_session_id
		[ -n "$peer_session_id" ] || {
			peer_session_id="$session_id"
			uci_set_state network "$cfg" peer_session_id "$peer_session_id"
			l2tp_log "No peer session ID specified, assuming $peer_session_id"
		}


		while ! l2tp_session_exists "$tunnel_id" "$session_id"; do
			l2tpv3tun add session ifname "$link" tunnel_id "$tunnel_id" \
				session_id "$session_id" peer_session_id "$peer_session_id"

			# Wait for session
			sleep 1
		done


		local dev
		config_get dev "$cfg" device

		local ifn
		config_get ifn "$cfg" ifname

		uci_set_state network "$cfg" ifname "${ifn:-$dev}"
		uci_set_state network "$cfg" device "$dev"

		local mtu
		config_get mtu "$cfg" mtu 1462

		local ttl
		config_get ttl "$cfg" ttl

		ip link set mtu "$mtu" ${ttl:+ ttl "$ttl"} dev "$link"

		# IP setup inherited from proto static
		prepare_interface "$link" "$cfg"
		setup_interface_static "${ifn:-$dev}" "$cfg"

		ip link set up dev "$link"

		uci_set_state network "$cfg" up 1
		l2tp_unlock
	) &
}

stop_interface_l2tp() {
	local cfg="$1"
	local link="l2tp-$cfg"

	local tunnel=$(uci_get_state network "$cfg" tunnel_id)
	local session=$(uci_get_state network "$cfg" session_id)

	[ -n "$tunnel" ] && [ -n "$session" ] && {
		l2tpv3tun del session tunnel_id "$tunnel" session_id "$session"
		l2tpv3tun del tunnel tunnel_id "$tunnel"
	}
}
