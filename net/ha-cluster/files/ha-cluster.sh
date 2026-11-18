#!/bin/sh
# SPDX-License-Identifier: MIT
# Copyright (c) 2025-2026 Pierre Gaufillet <pierre.gaufillet@bergamote.eu>
# Library functions for HA cluster management

. /lib/functions.sh
. /lib/config/uci.sh

HA_CLUSTER_CONFIG="/etc/config/ha-cluster"
# Separate from the standalone init scripts' /tmp/*.conf
HA_CLUSTER_RUN_DIR="/tmp/ha-cluster"
KEEPALIVED_CONF="${HA_CLUSTER_RUN_DIR}/keepalived.conf"
OWSYNC_CONF="${HA_CLUSTER_RUN_DIR}/owsync.conf"
LEASE_SYNC_CONF="${HA_CLUSTER_RUN_DIR}/lease-sync.conf"
OWSYNC_BIN="/usr/bin/owsync"
LEASE_SYNC_BIN="/usr/sbin/lease-sync"

HA_LOG_LEVEL_ERROR=0
HA_LOG_LEVEL_WARNING=1
HA_LOG_LEVEL_INFO=2
HA_LOG_LEVEL_DEBUG=3

HA_LOG_LEVEL="${HA_LOG_LEVEL:-2}"

ha_log_init() {
	config_load ha-cluster
	config_get HA_LOG_LEVEL advanced log_level "2"
}

ha_log_error() {
	logger -t ha-cluster -p daemon.err "$@"
}

ha_log_warning() {
	[ "$HA_LOG_LEVEL" -ge "$HA_LOG_LEVEL_WARNING" ] && \
		logger -t ha-cluster -p daemon.warning "$@"
}

ha_log_info() {
	[ "$HA_LOG_LEVEL" -ge "$HA_LOG_LEVEL_INFO" ] && \
		logger -t ha-cluster -p daemon.info "$@"
}

ha_log_debug() {
	[ "$HA_LOG_LEVEL" -ge "$HA_LOG_LEVEL_DEBUG" ] && \
		logger -t ha-cluster -p daemon.debug "$@"
}

ha_log() {
	ha_log_info "$@"
}

# Usage: _ha_list_result=""; config_list_foreach section option _ha_list_collect; myvar="$_ha_list_result"
_ha_list_result=""
_ha_list_collect() {
	_ha_list_result="$_ha_list_result $1"
}

# Usage: ha_conf_append "$file" "key" "$value" ["indent"]
# No-op if value is empty.
ha_conf_append() {
	local file="$1"
	local key="$2"
	local value="$3"
	local indent="${4:-    }"
	[ -n "$value" ] && echo "${indent}${key} ${value}" >> "$file"
}

# Usage: netmask_to_cidr "255.255.255.0" -> "24"
netmask_to_cidr() {
	local netmask="$1"
	local cidr=0

	for octet in $(echo "$netmask" | tr '.' ' '); do
		case "$octet" in
			255) cidr=$((cidr + 8)) ;;
			254) cidr=$((cidr + 7)) ;;
			252) cidr=$((cidr + 6)) ;;
			248) cidr=$((cidr + 5)) ;;
			240) cidr=$((cidr + 4)) ;;
			224) cidr=$((cidr + 3)) ;;
			192) cidr=$((cidr + 2)) ;;
			128) cidr=$((cidr + 1)) ;;
			0) ;;
			*) ha_log_error "Invalid netmask octet '$octet' in '$netmask'"; return 1 ;;
		esac
	done

	echo "$cidr"
}

# Usage: is_valid_ipv6 "fd00::1"
# Coarse syntax check only; LuCI validates on input, keepalived on load.
is_valid_ipv6() {
	local addr="$1"
	case "$addr" in
		*:*) ;;
		*) return 1 ;;
	esac
	# "::" to fully expanded form
	local len=${#addr}
	[ "$len" -lt 2 ] || [ "$len" -gt 39 ] && return 1
	case "$addr" in
		*[!0-9a-fA-F:]*) return 1 ;;
	esac
	return 0
}

ha_get_config() {
	local var="$1"
	local default="$2"
	config_load ha-cluster
	config_get value config "$var" "$default"
	echo "$value"
}

# Sets: _ha_peer_addresses (all peer addresses)
#       _ha_peer_source_address (first non-empty source_address)
_ha_peer_addresses=""
_ha_peer_source_address=""
_ha_collect_peer_address() {
	local section="$1"
	local address source_address

	config_get address "$section" address ""
	config_get source_address "$section" source_address ""

	[ -z "$address" ] && return 0

	_ha_peer_addresses="$_ha_peer_addresses $address"
	if [ -z "$_ha_peer_source_address" ] && [ -n "$source_address" ]; then
		_ha_peer_source_address="$source_address"
	fi
}

# Peers running ha-cluster (not VRRP-only) and having an address
_ha_sync_peer_count=0
_ha_count_sync_peer() {
	local section="$1"
	local address vrrp_only

	config_get_bool vrrp_only "$section" vrrp_only 0
	[ "$vrrp_only" -eq 1 ] && return 0

	config_get address "$section" address ""
	[ -n "$address" ] && _ha_sync_peer_count=$((_ha_sync_peer_count + 1))
}

# Usage: ha_has_sync_peer (ha-cluster config loaded)
ha_has_sync_peer() {
	_ha_sync_peer_count=0
	config_foreach _ha_count_sync_peer peer
	[ "$_ha_sync_peer_count" -gt 0 ]
}

_ha_include_count=0
_ha_count_include() {
	_ha_include_count=$((_ha_include_count + 1))
}

_ha_count_group_includes() {
	local section="$1"
	local enabled

	config_get_bool enabled "$section" enabled 1
	[ "$enabled" -eq 0 ] && return 0

	config_list_foreach "$section" config_files _ha_count_include
}

# Usage: ha_owsync_wanted (ha-cluster config loaded)
# An enabled sync group lists files and there is a peer to sync with.
ha_owsync_wanted() {
	_ha_include_count=0
	config_foreach _ha_count_group_includes sync_group
	[ "$_ha_include_count" -gt 0 ] && ha_has_sync_peer
}

# Usage: ha_lease_sync_wanted (ha-cluster config loaded)
# Lease sync is enabled and has a peer to sync with.
ha_lease_sync_wanted() {
	local lease_sync

	config_get_bool lease_sync config lease_sync 0
	[ "$lease_sync" -eq 1 ] && ha_has_sync_peer
}

# Usage: ha_lease_sync_active (ha-cluster config loaded)
# Gates the lease-sync config, the dhcp force check and the dnsmasq overlay.
ha_lease_sync_active() {
	ha_lease_sync_wanted && [ -x "$LEASE_SYNC_BIN" ]
}

ha_generate_keepalived_conf() {
	local node_name node_priority enable_notifications notification_email_from smtp_server
	local max_auto_priority
	local notification_emails=""

	config_load ha-cluster
	node_name="$(cat /proc/sys/kernel/hostname)"
	config_get node_priority config node_priority "100"
	config_get _ha_vrrp_transport config vrrp_transport "multicast"
	config_get max_auto_priority advanced max_auto_priority "0"
	config_get_bool enable_notifications advanced enable_notifications 0
	config_get notification_email_from advanced notification_email_from ""
	config_get smtp_server advanced smtp_server ""

	_ha_peer_addresses=""
	_ha_peer_source_address=""
	config_foreach _ha_collect_peer_address peer

	_ha_list_result=""
	config_list_foreach advanced notification_email _ha_list_collect
	notification_emails="$_ha_list_result"

	ha_log "Generating keepalived configuration for node: $node_name"

	# May contain auth_pass: restrict before writing
	: > "$KEEPALIVED_CONF"
	chmod 0600 "$KEEPALIVED_CONF"

	cat > "$KEEPALIVED_CONF" <<EOF
! Keepalived configuration - Generated by ha-cluster
! DO NOT EDIT - This file is auto-generated when HA cluster is enabled
! Edit /etc/config/ha-cluster instead

global_defs {
    router_id $node_name
    dynamic_interfaces
    script_user root
    enable_script_security
    max_auto_priority $max_auto_priority
EOF

	if [ "$enable_notifications" -eq 1 ]; then
		if [ -n "$notification_emails" ]; then
			cat >> "$KEEPALIVED_CONF" <<EOF
    notification_email {
EOF
			for email in $notification_emails; do
				echo "        $email" >> "$KEEPALIVED_CONF"
			done
			cat >> "$KEEPALIVED_CONF" <<EOF
    }
EOF
		fi
		ha_conf_append "$KEEPALIVED_CONF" "notification_email_from" "$notification_email_from"
		ha_conf_append "$KEEPALIVED_CONF" "smtp_server" "$smtp_server"
	fi

	echo "}" >> "$KEEPALIVED_CONF"
	echo "" >> "$KEEPALIVED_CONF"

	config_foreach ha_generate_vrrp_script script
	config_foreach ha_generate_vrrp_group vrrp_instance

	ha_log "Keepalived configuration generated at $KEEPALIVED_CONF"
	return 0
}

ha_generate_vrrp_script() {
	local section="$1"
	local script interval timeout weight rise fall user

	config_get script "$section" script
	[ -z "$script" ] && return 0

	config_get interval "$section" interval "5"
	config_get timeout "$section" timeout ""
	config_get weight "$section" weight ""
	config_get rise "$section" rise ""
	config_get fall "$section" fall ""
	config_get user "$section" user ""

	cat >> "$KEEPALIVED_CONF" <<EOF
vrrp_script ${section} {
    script "$script"
    interval $interval
EOF

	ha_conf_append "$KEEPALIVED_CONF" "timeout" "$timeout"
	ha_conf_append "$KEEPALIVED_CONF" "weight" "$weight"
	ha_conf_append "$KEEPALIVED_CONF" "rise" "$rise"
	ha_conf_append "$KEEPALIVED_CONF" "fall" "$fall"
	ha_conf_append "$KEEPALIVED_CONF" "user" "$user"

	echo "}" >> "$KEEPALIVED_CONF"
	echo "" >> "$KEEPALIVED_CONF"
}

# Options shared by the IPv4 and IPv6 instances.
# Uses parent-scope variables: nopreempt, preempt_delay, garp_master_delay,
# track_ifaces, track_scripts, auth_type, auth_pass, unicast_peers, unicast_src_ip
_ha_write_vrrp_instance_options() {
	local label="$1"

	if [ "$nopreempt" -eq 1 ]; then
		echo "    nopreempt" >> "$KEEPALIVED_CONF"
	elif [ -n "$preempt_delay" ]; then
		echo "    preempt_delay $preempt_delay" >> "$KEEPALIVED_CONF"
	fi

	ha_conf_append "$KEEPALIVED_CONF" "garp_master_delay" "$garp_master_delay"

	if [ -n "$track_ifaces" ]; then
		echo "    track_interface {" >> "$KEEPALIVED_CONF"
		for iface in $track_ifaces; do
			local resolved_iface
			if network_get_device resolved_iface "$iface" 2>/dev/null; then
				ha_log_debug "VIP $label: resolved track_interface '$iface' to device '$resolved_iface'"
				echo "        $resolved_iface" >> "$KEEPALIVED_CONF"
			else
				ha_log_debug "VIP $label: using track_interface '$iface' as-is"
				echo "        $iface" >> "$KEEPALIVED_CONF"
			fi
		done
		echo "    }" >> "$KEEPALIVED_CONF"
	fi

	if [ -n "$track_scripts" ]; then
		echo "    track_script {" >> "$KEEPALIVED_CONF"
		for script_name in $track_scripts; do
			echo "        $script_name" >> "$KEEPALIVED_CONF"
		done
		echo "    }" >> "$KEEPALIVED_CONF"
	fi

	if [ "$auth_type" != "none" ] && [ -n "$auth_pass" ]; then
		cat >> "$KEEPALIVED_CONF" <<EOF
    authentication {
        auth_type $auth_type
        auth_pass "$auth_pass"
    }
EOF
	fi

	if [ -n "$unicast_peers" ]; then
		if [ -n "$unicast_src_ip" ]; then
			ha_conf_append "$KEEPALIVED_CONF" "unicast_src_ip" "$unicast_src_ip"
		fi
		echo "    unicast_peer {" >> "$KEEPALIVED_CONF"
		for peer in $unicast_peers; do
			echo "        $peer" >> "$KEEPALIVED_CONF"
		done
		echo "    }" >> "$KEEPALIVED_CONF"
	fi
}

# Collects the enabled VIPs of $_ha_current_instance.
# Sets: _ha_vip_v4_addrs, _ha_vip_v6_addrs (newline-separated "addr dev iface" entries)
_ha_collect_vip_for_instance() {
	local vip_section="$1"
	local vip_enabled vip_instance vip_interface vip_interface_logical
	local vip_address vip_netmask vip_address6 vip_prefix6

	config_get_bool vip_enabled "$vip_section" enabled 1
	[ "$vip_enabled" -eq 0 ] && return 0

	config_get vip_instance "$vip_section" vrrp_instance ""
	[ "$vip_instance" != "$_ha_current_instance" ] && return 0

	config_get vip_interface_logical "$vip_section" interface ""
	config_get vip_address "$vip_section" address ""
	config_get vip_netmask "$vip_section" netmask "255.255.255.0"
	config_get vip_address6 "$vip_section" address6 ""
	config_get vip_prefix6 "$vip_section" prefix6 "64"

	[ -z "$vip_interface_logical" ] && { ha_log_warning "VIP $vip_section has no interface"; return 1; }
	[ -z "$vip_address" ] && [ -z "$vip_address6" ] && { ha_log_warning "VIP $vip_section has no address (IPv4 or IPv6)"; return 1; }

	. /lib/functions/network.sh
	local vip_iface_resolved
	if network_get_device vip_iface_resolved "$vip_interface_logical" 2>/dev/null; then
		ha_log_debug "VIP $vip_section: resolved interface '$vip_interface_logical' to device '$vip_iface_resolved'"
	else
		vip_iface_resolved="$vip_interface_logical"
		ha_log_debug "VIP $vip_section: using interface '$vip_iface_resolved' as-is"
	fi

	if [ -n "$vip_address" ]; then
		local cidr
		cidr=$(netmask_to_cidr "$vip_netmask") || {
			ha_log_error "VIP $vip_section: invalid netmask '$vip_netmask'"
			return 1
		}
		_ha_vip_v4_addrs="${_ha_vip_v4_addrs}        ${vip_address}/${cidr} dev ${vip_iface_resolved}
"
	fi

	if [ -n "$vip_address6" ]; then
		is_valid_ipv6 "$vip_address6" || { ha_log_error "VIP $vip_section: invalid IPv6 address (got: $vip_address6)"; return 1; }
		case "$vip_prefix6" in
			''|*[!0-9]*) ha_log_error "VIP $vip_section: prefix6 must be a number (got: $vip_prefix6)"; return 1 ;;
		esac
		[ "$vip_prefix6" -lt 1 ] || [ "$vip_prefix6" -gt 128 ] && { ha_log_error "VIP $vip_section: prefix6 must be 1-128 (got: $vip_prefix6)"; return 1; }
		_ha_vip_v6_addrs="${_ha_vip_v6_addrs}        ${vip_address6}/${vip_prefix6} dev ${vip_iface_resolved}
"
	fi
}

# Usage: _ha_ip_family "addr" -> "4" or "6"
_ha_ip_family() {
	case "$1" in
		*:*) echo 6 ;;
		*) echo 4 ;;
	esac
}

# Usage: _ha_write_vrrp_instance name vrid vips [evips]
# Uses parent-scope variables of ha_generate_vrrp_group.
_ha_write_vrrp_instance() {
	local name="$1"
	local inst_vrid="$2"
	local vips="$3"
	local evips="$4"

	cat >> "$KEEPALIVED_CONF" <<EOF
vrrp_instance ${name} {
    state BACKUP
    interface $interface
    virtual_router_id $inst_vrid
    priority $priority
    advert_int $advert_int
EOF

	_ha_write_vrrp_instance_options "$name"

	if [ -n "$vips" ]; then
		echo "    virtual_ipaddress {" >> "$KEEPALIVED_CONF"
		printf '%s' "$vips" >> "$KEEPALIVED_CONF"
		echo "    }" >> "$KEEPALIVED_CONF"
	else
		# Only excluded VIPs: fatal for VRRPv3 (IPv6) without it
		echo "    no_virtual_ipaddress" >> "$KEEPALIVED_CONF"
	fi
	if [ -n "$evips" ]; then
		echo "    virtual_ipaddress_excluded {" >> "$KEEPALIVED_CONF"
		printf '%s' "$evips" >> "$KEEPALIVED_CONF"
		echo "    }" >> "$KEEPALIVED_CONF"
	fi

	cat >> "$KEEPALIVED_CONF" <<EOF

    # Notify scripts for state changes
    notify_master "/bin/busybox env -i ACTION=MASTER TYPE=INSTANCE NAME=${name} /sbin/hotplug-call keepalived"
    notify_backup "/bin/busybox env -i ACTION=BACKUP TYPE=INSTANCE NAME=${name} /sbin/hotplug-call keepalived"
    notify_fault "/bin/busybox env -i ACTION=FAULT TYPE=INSTANCE NAME=${name} /sbin/hotplug-call keepalived"
}

EOF
}

# A VRRP instance advertises a single address family. Multicast: one
# keepalived vrrp_instance per UCI vrrp_instance for its IPv4 VIPs, plus a
# second one (VRID+128) for its IPv6 VIPs. Unicast: a single instance in
# the family of its unicast addresses, with the VIPs of the other family
# as excluded (not advertised) addresses.
ha_generate_vrrp_group() {
	local section="$1"
	local interface interface_logical vrid priority nopreempt track_interface
	local advert_int preempt_delay garp_master_delay auth_type auth_pass unicast_src_ip
	local track_ifaces="" track_scripts="" unicast_peers="" unicast_family=""
	local peer first_peer family_peers

	config_get interface_logical "$section" interface
	config_get vrid "$section" vrid
	config_get priority "$section" priority "$(ha_get_config node_priority 100)"
	config_get_bool nopreempt "$section" nopreempt 1
	config_get track_interface "$section" track_interface
	config_get advert_int "$section" advert_int "1"
	config_get preempt_delay "$section" preempt_delay ""
	config_get garp_master_delay "$section" garp_master_delay ""
	config_get auth_type "$section" auth_type "none"
	config_get auth_pass "$section" auth_pass ""
	config_get unicast_src_ip "$section" unicast_src_ip ""

	[ -z "$interface_logical" ] && { ha_log_warning "vrrp_instance $section has no interface"; return 1; }
	[ -z "$vrid" ] && { ha_log_warning "vrrp_instance $section has no VRID"; return 1; }

	. /lib/functions/network.sh
	if network_get_device interface "$interface_logical" 2>/dev/null; then
		ha_log_debug "vrrp_instance $section: resolved interface '$interface_logical' to device '$interface'"
	else
		interface="$interface_logical"
		ha_log_debug "vrrp_instance $section: using interface '$interface' as-is"
	fi

	# 128-255 are taken by the IPv6 instances (VRID+128)
	case "$vrid" in
		''|*[!0-9]*) ha_log_error "vrrp_instance $section: VRID must be a number (got: $vrid)"; return 1 ;;
	esac
	[ "$vrid" -lt 1 ] || [ "$vrid" -gt 127 ] && { ha_log_error "vrrp_instance $section: VRID must be 1-127 (got: $vrid)"; return 1; }

	case "$priority" in
		''|*[!0-9]*) ha_log_error "vrrp_instance $section: priority must be a number (got: $priority)"; return 1 ;;
	esac
	[ "$priority" -lt 1 ] || [ "$priority" -gt 255 ] && { ha_log_error "vrrp_instance $section: priority must be 1-255 (got: $priority)"; return 1; }

	case "$advert_int" in
		''|*[!0-9]*) ha_log_error "vrrp_instance $section: advert_int must be a number (got: $advert_int)"; return 1 ;;
	esac

	_ha_list_result=""
	config_list_foreach "$section" track_interface _ha_list_collect
	track_ifaces="$_ha_list_result"
	if [ -z "$track_ifaces" ] && [ -n "$track_interface" ]; then
		track_ifaces="$track_interface"
	fi

	_ha_list_result=""
	config_list_foreach "$section" track_script _ha_list_collect
	track_scripts="$_ha_list_result"

	case "$auth_type" in
		pass|PASS) auth_type="PASS" ;;
		ah|AH) auth_type="AH" ;;
	esac

	_ha_list_result=""
	config_list_foreach "$section" unicast_peer _ha_list_collect
	unicast_peers="$_ha_list_result"

	# Global unicast transport without a per-instance unicast_peer list:
	# derive peers and source address from the peer sections
	if [ "$_ha_vrrp_transport" = "unicast" ] && [ -z "$unicast_peers" ]; then
		unicast_peers="$_ha_peer_addresses"
		if [ -z "$unicast_src_ip" ] && [ -n "$_ha_peer_source_address" ]; then
			unicast_src_ip="$_ha_peer_source_address"
		fi
		ha_log_debug "vrrp_instance $section: unicast auto-derived from peer config"
	fi

	# keepalived takes the instance family from its first unicast address
	# and skips the addresses of the other family
	if [ -n "$unicast_peers" ]; then
		for first_peer in $unicast_peers; do break; done
		if [ -n "$unicast_src_ip" ]; then
			unicast_family=$(_ha_ip_family "$unicast_src_ip")
			for peer in $unicast_peers; do
				[ "$(_ha_ip_family "$peer")" = "$unicast_family" ] && break
			done
			if [ "$(_ha_ip_family "$peer")" != "$unicast_family" ]; then
				ha_log_error "vrrp_instance $section: no IPv$unicast_family unicast peer for unicast_src_ip $unicast_src_ip, ignoring it"
				unicast_src_ip=""
				unicast_family=$(_ha_ip_family "$first_peer")
			fi
		else
			ha_log_warning "vrrp_instance $section has unicast_peer but no unicast_src_ip"
			unicast_family=$(_ha_ip_family "$first_peer")
		fi
		family_peers=""
		for peer in $unicast_peers; do
			if [ "$(_ha_ip_family "$peer")" = "$unicast_family" ]; then
				family_peers="$family_peers $peer"
			else
				ha_log_warning "vrrp_instance $section: ignoring unicast peer $peer (not IPv$unicast_family)"
			fi
		done
		unicast_peers="$family_peers"
	fi

	_ha_current_instance="$section"
	_ha_vip_v4_addrs=""
	_ha_vip_v6_addrs=""
	config_foreach _ha_collect_vip_for_instance vip

	[ -z "$_ha_vip_v4_addrs" ] && [ -z "$_ha_vip_v6_addrs" ] && {
		ha_log_warning "vrrp_instance $section has no enabled VIPs"
		return 0
	}

	if [ -n "$unicast_peers" ]; then
		if [ "$unicast_family" = 6 ]; then
			_ha_write_vrrp_instance "$section" "$vrid" "$_ha_vip_v6_addrs" "$_ha_vip_v4_addrs"
		else
			_ha_write_vrrp_instance "$section" "$vrid" "$_ha_vip_v4_addrs" "$_ha_vip_v6_addrs"
		fi
		return 0
	fi

	if [ -n "$_ha_vip_v4_addrs" ]; then
		_ha_write_vrrp_instance "$section" "$vrid" "$_ha_vip_v4_addrs"
	fi

	if [ -n "$_ha_vip_v6_addrs" ]; then
		local vrid6=$((vrid + 128))
		if [ "$vrid6" -gt 255 ]; then
			ha_log_error "vrrp_instance $section: IPv6 VRID would be $vrid6 (VRID+128), exceeds 255"
			return 1
		fi

		_ha_write_vrrp_instance "${section}_v6" "$vrid6" "$_ha_vip_v6_addrs"
	fi
}

ha_generate_owsync_conf() {
	local encryption_key sync_port sync_dir sync_interval owsync_log_level bind_address

	config_load ha-cluster

	if ! ha_owsync_wanted; then
		ha_log_debug "Config sync: no enabled sync group or no peer to sync with"
		rm -f "$OWSYNC_CONF"
		return 0
	fi
	if [ ! -x "$OWSYNC_BIN" ]; then
		ha_log_warning "Config sync enabled but owsync is not installed"
		rm -f "$OWSYNC_CONF"
		return 0
	fi

	config_get encryption_key config encryption_key ""
	config_get sync_port config sync_port "4321"
	config_get sync_dir config sync_dir "/etc/config"
	config_get sync_interval advanced sync_interval "30"
	config_get owsync_log_level advanced owsync_log_level "2"
	config_get bind_address config bind_address ""

	ha_log "Generating owsync configuration"

	rm -f "$OWSYNC_CONF"
	touch "$OWSYNC_CONF"
	chmod 0600 "$OWSYNC_CONF"

	local owsync_bind="${bind_address:-::}"

	cat > "$OWSYNC_CONF" <<EOF
# Auto-generated by ha-cluster
# DO NOT EDIT - changes will be overwritten when HA cluster restarts
# Edit /etc/config/ha-cluster instead

# Network settings
bind_host=${owsync_bind}
port=${sync_port}

# Paths (OpenWrt-specific)
sync_dir=${sync_dir}
database=/etc/owsync/owsync.db

# Daemon settings
poll_interval=${sync_interval}
log_level=${owsync_log_level}

EOF

	if [ -n "$encryption_key" ]; then
		echo "# Security: PSK encryption enabled" >> "$OWSYNC_CONF"
		echo "encryption_key=${encryption_key}" >> "$OWSYNC_CONF"
	else
		ha_log_warning "No encryption_key set - owsync will run without encryption; set the same key on all nodes, generated in LuCI or with: hexdump -n 32 -v -e '1/1 \"%02x\"' /dev/urandom"
		echo "# Security: Plain mode (use only over secure VPN)" >> "$OWSYNC_CONF"
		echo "plain_mode=1" >> "$OWSYNC_CONF"
	fi
	echo "" >> "$OWSYNC_CONF"

	echo "# Peers" >> "$OWSYNC_CONF"
	config_foreach ha_add_owsync_peer_conf peer
	echo "" >> "$OWSYNC_CONF"

	echo "# Include patterns (sync these files)" >> "$OWSYNC_CONF"
	config_foreach ha_add_owsync_includes_conf sync_group

	echo "" >> "$OWSYNC_CONF"
	echo "# Exclude patterns (never sync these)" >> "$OWSYNC_CONF"
	config_foreach ha_add_owsync_excludes_conf exclude

	ha_log "owsync configuration generated at $OWSYNC_CONF"
	return 0
}

# vrrp_only=1 marks a peer not running ha-cluster
ha_add_owsync_peer_conf() {
	local section="$1"
	local address source_address vrrp_only

	config_get_bool vrrp_only "$section" vrrp_only 0
	[ "$vrrp_only" -eq 1 ] && return 0

	config_get address "$section" address
	config_get source_address "$section" source_address ""

	[ -z "$address" ] && return 0

	if [ -n "$source_address" ]; then
		echo "peer=${address},${source_address}" >> "$OWSYNC_CONF"
		ha_log_debug "owsync peer: $address (source: $source_address)"
	else
		echo "peer=${address}" >> "$OWSYNC_CONF"
		ha_log_debug "owsync peer: $address (no source specified)"
	fi
}

ha_add_owsync_includes_conf() {
	local section="$1"
	local enabled

	config_get_bool enabled "$section" enabled 1
	[ "$enabled" -eq 0 ] && return 0

	config_list_foreach "$section" config_files ha_add_owsync_include_conf
}

ha_add_owsync_include_conf() {
	echo "include=$1" >> "$OWSYNC_CONF"
}

ha_add_owsync_excludes_conf() {
	local section="$1"
	config_list_foreach "$section" file ha_add_owsync_exclude_conf
}

ha_add_owsync_exclude_conf() {
	echo "exclude=$1" >> "$OWSYNC_CONF"
}

ha_generate_lease_sync_conf() {
	local lease_sync_port encryption_key
	local sync_interval peer_timeout log_level node_name bind_address

	config_load ha-cluster

	config_get lease_sync_port advanced lease_sync_port "5378"
	config_get sync_interval advanced lease_sync_interval "30"
	config_get peer_timeout advanced lease_sync_peer_timeout "120"
	config_get log_level advanced lease_sync_log_level "2"
	config_get encryption_key config encryption_key ""
	config_get bind_address config bind_address ""
	node_name="$(cat /proc/sys/kernel/hostname)"

	if ! ha_lease_sync_wanted; then
		ha_log_debug "DHCP lease sync disabled or no peer to sync with"
		rm -f "$LEASE_SYNC_CONF"
		return 0
	fi
	if [ ! -x "$LEASE_SYNC_BIN" ]; then
		ha_log_warning "DHCP lease sync enabled but lease-sync is not installed"
		rm -f "$LEASE_SYNC_CONF"
		return 0
	fi

	ha_log "Generating lease-sync configuration"

	rm -f "$LEASE_SYNC_CONF"
	touch "$LEASE_SYNC_CONF"
	chmod 0600 "$LEASE_SYNC_CONF"

	cat > "$LEASE_SYNC_CONF" <<EOF
# Auto-generated by ha-cluster
# DO NOT EDIT - changes will be overwritten when HA cluster restarts
# Edit /etc/config/ha-cluster instead

node_id=${node_name}
sync_port=${lease_sync_port}
sync_interval=${sync_interval}
peer_timeout=${peer_timeout}
log_level=${log_level}
EOF

	# Keeps the VIP from being picked as source address
	if [ -n "$bind_address" ]; then
		echo "bind_address=${bind_address}" >> "$LEASE_SYNC_CONF"
		ha_log "lease-sync will bind to $bind_address"
	fi

	if [ -n "$encryption_key" ]; then
		cat >> "$LEASE_SYNC_CONF" <<EOF

# Security: AES-256-GCM PSK encryption enabled
security_mode=encrypted
psk_key=${encryption_key}
EOF
		ha_log "lease-sync will use AES-256-GCM encryption"
	else
		cat >> "$LEASE_SYNC_CONF" <<EOF

# Security: Plain mode (use only over secure VPN)
# WARNING: Ensure network-layer security (WireGuard/IPsec) is configured!
security_mode=plain
plain_mode_acknowledged=1
EOF
		ha_log_warning "lease-sync running in plain mode - ensure network-layer security"
	fi

	echo "" >> "$LEASE_SYNC_CONF"

	config_foreach ha_add_lease_sync_peer_flat peer

	ha_log "lease-sync configuration generated at $LEASE_SYNC_CONF"
	return 0
}

ha_add_lease_sync_peer_flat() {
	local section="$1"
	local address source_address vrrp_only

	config_get_bool vrrp_only "$section" vrrp_only 0
	[ "$vrrp_only" -eq 1 ] && return 0

	config_get address "$section" address
	config_get source_address "$section" source_address ""

	[ -z "$address" ] && return 0

	if [ -n "$source_address" ]; then
		echo "peer=${address},${source_address}" >> "$LEASE_SYNC_CONF"
		ha_log_debug "lease-sync peer: $address (source: $source_address)"
	else
		echo "peer=${address}" >> "$LEASE_SYNC_CONF"
		ha_log_debug "lease-sync peer: $address (no source specified)"
	fi
}

# Validate ha-cluster configuration
ha_validate_config() {
	local errors=0
	local vrid_list=""

	config_load ha-cluster

	config_get_bool enabled config enabled 0
	[ "$enabled" -eq 0 ] && return 0

	config_foreach ha_check_vrid_unique vrrp_instance

	# owsync is the only sync backend
	local sync_method
	config_get sync_method config sync_method "owsync"
	[ "$sync_method" != "owsync" ] && {
		ha_log_error "sync_method '$sync_method' is not supported (only 'owsync')"
		errors=$((errors + 1))
	}

	local peer_count=0
	config_foreach ha_count_peers peer
	[ "$peer_count" -eq 0 ] && {
		ha_log_warning "No peers configured - HA will not function"
	}

	# When lease sync is active, VIP interfaces need dhcp.*.force=1
	# so that dnsmasq initializes DHCP (required for ubus add_lease).
	# Without it, the BACKUP node cannot receive synced leases.
	if ha_lease_sync_active; then
		_ha_dhcp_force_checked=""
		config_foreach _ha_check_dhcp_force vip
	fi

	# Warn only: /etc/config/dhcp belongs to the user
	if ha_dhcp_authoritative_conflict; then
		ha_log_warning "dnsmasq is authoritative while several nodes serve DHCP: they NAK each other's clients"
		ha_log_warning "Set authoritative '0' in /etc/config/dhcp on every node"
	fi

	return $errors
}

_ha_dnsmasq_authoritative=0
_ha_check_dnsmasq_authoritative() {
	local authoritative

	config_get_bool authoritative "$1" authoritative 0
	[ "$authoritative" -eq 1 ] && _ha_dnsmasq_authoritative=1
}

# Usage: ha_dhcp_authoritative_conflict (ha-cluster config loaded, and
# reloaded on return)
# A dnsmasq section is authoritative while several nodes serve DHCP, as
# lease sync or the enabled dhcp sync group listing files implies: an
# authoritative dnsmasq NAKs every request carrying another node's
# server-id.
ha_dhcp_authoritative_conflict() {
	local group_type group_enabled group_files

	if ! ha_lease_sync_active; then
		[ -x "$OWSYNC_BIN" ] || return 1
		config_get group_type dhcp TYPE ""
		[ "$group_type" = "sync_group" ] || return 1
		config_get_bool group_enabled dhcp enabled 1
		config_get group_files dhcp config_files ""
		[ "$group_enabled" -eq 1 ] && [ -n "$group_files" ] &&
			ha_has_sync_peer || return 1
	fi

	_ha_dnsmasq_authoritative=0
	config_load dhcp
	config_foreach _ha_check_dnsmasq_authoritative dnsmasq
	config_load ha-cluster

	[ "$_ha_dnsmasq_authoritative" -eq 1 ]
}

_ha_dhcp_force_checked=""
_ha_check_dhcp_force() {
	local section="$1"
	local vip_enabled interface

	config_get_bool vip_enabled "$section" enabled 1
	[ "$vip_enabled" -eq 0 ] && return 0

	config_get interface "$section" interface ""
	[ -z "$interface" ] && return 0

	echo "$_ha_dhcp_force_checked" | grep -qw "$interface" && return 0
	_ha_dhcp_force_checked="$_ha_dhcp_force_checked $interface"

	# Only type=dhcp sections: dnsmasq sections also have an 'interface' option
	local dhcp_section force
	dhcp_section=""
	local _s
	for _s in $(uci show dhcp 2>/dev/null | grep '=dhcp$' | cut -d. -f2 | cut -d= -f1); do
		local _iface
		_iface=$(uci -q get "dhcp.$_s.interface")
		if [ "$_iface" = "$interface" ]; then
			dhcp_section="$_s"
			break
		fi
	done
	[ -z "$dhcp_section" ] && return 0

	force=$(uci -q get "dhcp.$dhcp_section.force")
	if [ "$force" != "1" ]; then
		ha_log_error "dhcp.$dhcp_section.force must be '1' for HA lease sync on interface '$interface'"
		ha_log_error "Set it with: uci set dhcp.$dhcp_section.force='1' && uci commit dhcp"
		errors=$((errors + 1))
	fi
}

ha_check_vrid_unique() {
	local section="$1"
	local vrid

	config_get vrid "$section" vrid
	[ -z "$vrid" ] && return 0

	case "$vrid" in
		''|*[!0-9]*) ha_log_error "vrrp_instance $section: VRID must be a number (got: $vrid)"; errors=$((errors + 1)); return 1 ;;
	esac
	[ "$vrid" -gt 127 ] && {
		ha_log_error "vrrp_instance $section: VRID must be 1-127 (got: $vrid, 128-255 reserved for IPv6)"
		errors=$((errors + 1))
		return 1
	}

	# Unique across all instances, even on different interfaces
	echo "$vrid_list" | grep -qw "$vrid" && {
		ha_log_error "Duplicate VRID $vrid in vrrp_instance section $section"
		errors=$((errors + 1))
		return 1
	}

	vrid_list="$vrid_list $vrid"
}

ha_count_peers() {
	peer_count=$((peer_count + 1))
}

# Usage: ha_manage_services take_over|release
# take_over stops and disables the standalone services, recording whether
# each was enabled; release re-enables and starts those that were.
ha_manage_services() {
	local action="$1"
	local state_file="/etc/ha-cluster/service_states"

	mkdir -p /etc/ha-cluster

	if [ "$action" = "take_over" ]; then
		ha_log "Taking over service management from standalone init scripts"

		# State already captured (e.g. on reload): the services are already
		# disabled, so re-capturing would record them as disabled and release
		# could no longer restore their original state.
		[ -f "$state_file" ] && return 0

		for service in keepalived owsync lease-sync; do
			if [ -x "/etc/init.d/$service" ]; then
				if /etc/init.d/$service enabled 2>/dev/null; then
					echo "$service=1" >> "$state_file"
				else
					echo "$service=0" >> "$state_file"
				fi

				/etc/init.d/$service stop 2>/dev/null
				/etc/init.d/$service disable 2>/dev/null
				ha_log "Disabled standalone service: $service"
			fi
		done

	elif [ "$action" = "release" ]; then
		ha_log "Releasing service management back to standalone init scripts"

		[ ! -f "$state_file" ] && return 0

		while IFS='=' read -r service was_enabled; do
			if [ -x "/etc/init.d/$service" ] && [ "$was_enabled" = "1" ]; then
				/etc/init.d/$service enable 2>/dev/null
				/etc/init.d/$service start 2>/dev/null
				ha_log "Restored standalone service: $service"
			fi
		done < "$state_file"

		rm -f "$state_file"
	fi
}

# Dropped into dnsmasq's conf-dir to enable HA-required options at runtime
# without modifying /etc/config/dhcp.
HA_DNSMASQ_OVERLAY_NAME="ha-cluster.conf"

# Same per-section default as dnsmasq's init script; first section wins.
_ha_dnsmasq_confdir=""
_ha_resolve_dnsmasq_confdir_cb() {
	local cfg="$1"
	[ -n "$_ha_dnsmasq_confdir" ] && return 0
	config_get _ha_dnsmasq_confdir "$cfg" confdir "/tmp/dnsmasq${cfg:+.$cfg}.d"
	# Strip a ",*.ext" filter suffix
	_ha_dnsmasq_confdir="${_ha_dnsmasq_confdir%%,*}"
}

ha_get_dnsmasq_confdir() {
	config_load dhcp
	_ha_dnsmasq_confdir=""
	config_foreach _ha_resolve_dnsmasq_confdir_cb dnsmasq
	echo "${_ha_dnsmasq_confdir:-/tmp/dnsmasq.d}"
}

ha_configure_dnsmasq() {
	local lease_sync_active=0 needs_restart=0
	local confdir overlay_path tmp_overlay

	config_load ha-cluster
	ha_lease_sync_active && lease_sync_active=1

	confdir="$(ha_get_dnsmasq_confdir)"
	overlay_path="$confdir/$HA_DNSMASQ_OVERLAY_NAME"

	if [ "$lease_sync_active" -eq 1 ]; then
		mkdir -p "$confdir"
		# Dot-prefixed so dnsmasq skips it if it (re)starts before the mv
		tmp_overlay="$confdir/.$HA_DNSMASQ_OVERLAY_NAME.new"
		cat > "$tmp_overlay" <<-'EOF'
			# Auto-generated by ha-cluster — do not edit
			# Call dhcp-script on lease renewals so lease-sync can track expiry changes
			script-on-renewal
		EOF
		# Restart only on change: a restart briefly drops DNS/DHCP
		if cmp -s "$tmp_overlay" "$overlay_path"; then
			rm -f "$tmp_overlay"
		else
			mv "$tmp_overlay" "$overlay_path"
			needs_restart=1
			ha_log "Wrote dnsmasq HA overlay to $overlay_path"
		fi
	elif [ -f "$overlay_path" ]; then
		# Left over from a run with lease sync active
		rm -f "$overlay_path"
		needs_restart=1
		ha_log "Removed stale dnsmasq HA overlay"
	fi

	[ "$needs_restart" -eq 1 ] && {
		/etc/init.d/dnsmasq restart 2>/dev/null
		ha_log "dnsmasq restarted"
	}
}

ha_release_dnsmasq() {
	local confdir overlay_path
	confdir="$(ha_get_dnsmasq_confdir)"
	overlay_path="$confdir/$HA_DNSMASQ_OVERLAY_NAME"

	[ ! -f "$overlay_path" ] && return 0

	ha_log "Removing dnsmasq HA overlay"
	rm -f "$overlay_path"
	/etc/init.d/dnsmasq restart 2>/dev/null
}

ha_apply_config() {
	ha_log "Applying HA cluster configuration"

	ha_validate_config || {
		ha_log_error "Configuration validation failed"
		return 1
	}

	ha_manage_services "take_over"
	ha_configure_dnsmasq

	# Services themselves are started by the init script
	ha_generate_keepalived_conf
	ha_generate_owsync_conf
	ha_generate_lease_sync_conf

	ha_log "HA cluster configuration applied successfully"
	return 0
}

