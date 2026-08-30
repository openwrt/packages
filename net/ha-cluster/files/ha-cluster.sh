#!/bin/sh
# SPDX-License-Identifier: MIT
# Copyright (c) 2025-2026 Pierre Gaufillet <pierre.gaufillet@bergamote.eu>
# /usr/lib/ha-cluster/ha-cluster.sh
# Library functions for HA cluster management

. /lib/functions.sh
. /lib/config/uci.sh

HA_CLUSTER_CONFIG="/etc/config/ha-cluster"
# Generated configs are placed in a dedicated directory to avoid conflicts
# with standalone service init scripts (which use /tmp/*.conf)
HA_CLUSTER_RUN_DIR="/tmp/ha-cluster"
KEEPALIVED_CONF="${HA_CLUSTER_RUN_DIR}/keepalived.conf"
OWSYNC_CONF="${HA_CLUSTER_RUN_DIR}/owsync.conf"
LEASE_SYNC_CONF="${HA_CLUSTER_RUN_DIR}/lease-sync.conf"

# Log level constants (matches syslog priorities)
HA_LOG_LEVEL_ERROR=0
HA_LOG_LEVEL_WARNING=1
HA_LOG_LEVEL_INFO=2
HA_LOG_LEVEL_DEBUG=3

# Current log level (default: INFO)
HA_LOG_LEVEL="${HA_LOG_LEVEL:-2}"

# Initialize log level from UCI (call once at start)
ha_log_init() {
	config_load ha-cluster
	config_get HA_LOG_LEVEL advanced log_level "2"
}

# Log error (always logged)
ha_log_error() {
	logger -t ha-cluster -p daemon.err "$@"
}

# Log warning (level >= 1)
ha_log_warning() {
	[ "$HA_LOG_LEVEL" -ge "$HA_LOG_LEVEL_WARNING" ] && \
		logger -t ha-cluster -p daemon.warning "$@"
}

# Log info (level >= 2)
ha_log_info() {
	[ "$HA_LOG_LEVEL" -ge "$HA_LOG_LEVEL_INFO" ] && \
		logger -t ha-cluster -p daemon.info "$@"
}

# Log debug (level >= 3)
ha_log_debug() {
	[ "$HA_LOG_LEVEL" -ge "$HA_LOG_LEVEL_DEBUG" ] && \
		logger -t ha-cluster -p daemon.debug "$@"
}

# Convenience wrapper (maps to info level)
ha_log() {
	ha_log_info "$@"
}

# ============================================
# Helper Functions to Reduce Code Duplication
# ============================================

# Generic list collector for config_list_foreach
# Usage: _ha_list_result=""; config_list_foreach section option _ha_list_collect; myvar="$_ha_list_result"
_ha_list_result=""
_ha_list_collect() {
	_ha_list_result="$_ha_list_result $1"
}

# Conditional append to config file
# Usage: ha_conf_append "$file" "key" "$value" ["indent"]
# Only appends if value is non-empty
ha_conf_append() {
	local file="$1"
	local key="$2"
	local value="$3"
	local indent="${4:-    }"
	[ -n "$value" ] && echo "${indent}${key} ${value}" >> "$file"
}

# Convert netmask to CIDR prefix length
# Usage: netmask_to_cidr "255.255.255.0" -> "24"
netmask_to_cidr() {
	local netmask="$1"
	local cidr=0

	# Convert each octet
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

# Validate IPv6 address format (basic check)
# Defense-in-depth: LuCI validates on input, keepalived validates on load
# Usage: is_valid_ipv6 "fd00::1" -> returns 0 (valid) or 1 (invalid)
is_valid_ipv6() {
	local addr="$1"
	# Must contain at least one colon
	case "$addr" in
		*:*) ;;
		*) return 1 ;;
	esac
	# Length check: 2 (::) to 39 (full form)
	local len=${#addr}
	[ "$len" -lt 2 ] || [ "$len" -gt 39 ] && return 1
	# Only hex digits and colons allowed
	case "$addr" in
		*[!0-9a-fA-F:]*) return 1 ;;
	esac
	return 0
}

# Get global config value
ha_get_config() {
	local var="$1"
	local default="$2"
	config_load ha-cluster
	config_get value config "$var" "$default"
	echo "$value"
}

# Collect peer addresses for unicast auto-derivation
# Sets: _ha_peer_addresses (all peer address values)
#        _ha_peer_source_address (first non-empty source_address found)
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

# Generate keepalived configuration
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

	# Collect peer addresses for unicast auto-derivation
	_ha_peer_addresses=""
	_ha_peer_source_address=""
	config_foreach _ha_collect_peer_address peer

	_ha_list_result=""
	config_list_foreach advanced notification_email _ha_list_collect
	notification_emails="$_ha_list_result"

	ha_log "Generating keepalived configuration for node: $node_name"

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

	# Generate VRRP scripts (health checks)
	config_foreach ha_generate_vrrp_script script

	# Generate VRRP instances (grouped by vrrp_instance section)
	config_foreach ha_generate_vrrp_group vrrp_instance

	ha_log "Keepalived configuration generated at $KEEPALIVED_CONF"
	return 0
}

# Generate a VRRP script block
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

# Write common VRRP instance options (shared between IPv4 and IPv6 instances)
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

	# Track interfaces
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

	# Track scripts
	if [ -n "$track_scripts" ]; then
		echo "    track_script {" >> "$KEEPALIVED_CONF"
		for script_name in $track_scripts; do
			echo "        $script_name" >> "$KEEPALIVED_CONF"
		done
		echo "    }" >> "$KEEPALIVED_CONF"
	fi

	# Authentication
	if [ "$auth_type" != "none" ] && [ -n "$auth_pass" ]; then
		cat >> "$KEEPALIVED_CONF" <<EOF
    authentication {
        auth_type $auth_type
        auth_pass "$auth_pass"
    }
EOF
	fi

	# Unicast peers
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

# Callback to collect VIPs belonging to a specific vrrp_instance
# Sets: _ha_vip_v4_addrs, _ha_vip_v6_addrs (space-separated "addr dev iface" entries)
_ha_collect_vip_for_instance() {
	local vip_section="$1"
	local vip_enabled vip_instance vip_interface vip_interface_logical
	local vip_address vip_netmask vip_address6 vip_prefix6

	config_get_bool vip_enabled "$vip_section" enabled 0
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

	# Resolve interface name
	. /lib/functions/network.sh
	local vip_iface_resolved
	if network_get_device vip_iface_resolved "$vip_interface_logical" 2>/dev/null; then
		ha_log_debug "VIP $vip_section: resolved interface '$vip_interface_logical' to device '$vip_iface_resolved'"
	else
		vip_iface_resolved="$vip_interface_logical"
		ha_log_debug "VIP $vip_section: using interface '$vip_iface_resolved' as-is"
	fi

	# Collect IPv4 address
	if [ -n "$vip_address" ]; then
		local cidr
		cidr=$(netmask_to_cidr "$vip_netmask") || {
			ha_log_error "VIP $vip_section: invalid netmask '$vip_netmask'"
			return 1
		}
		_ha_vip_v4_addrs="${_ha_vip_v4_addrs}        ${vip_address}/${cidr} dev ${vip_iface_resolved}
"
	fi

	# Collect IPv6 address
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

# Generate a VRRP group from a vrrp_instance section
# Collects all enabled VIPs referencing this instance and generates
# one keepalived vrrp_instance with all IPv4 addresses, plus a second
# vrrp_instance (VRID+128) if any VIP has IPv6.
ha_generate_vrrp_group() {
	local section="$1"
	local interface interface_logical vrid priority nopreempt track_interface
	local advert_int preempt_delay garp_master_delay auth_type auth_pass unicast_src_ip
	local track_ifaces="" track_scripts="" unicast_peers=""

	# Get instance-level options
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

	# Resolve primary interface
	. /lib/functions/network.sh
	if network_get_device interface "$interface_logical" 2>/dev/null; then
		ha_log_debug "vrrp_instance $section: resolved interface '$interface_logical' to device '$interface'"
	else
		interface="$interface_logical"
		ha_log_debug "vrrp_instance $section: using interface '$interface' as-is"
	fi

	# Validate VRID (1-127, 128+ reserved for IPv6)
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

	# Collect track interfaces (list or single)
	_ha_list_result=""
	config_list_foreach "$section" track_interface _ha_list_collect
	track_ifaces="$_ha_list_result"
	if [ -z "$track_ifaces" ] && [ -n "$track_interface" ]; then
		track_ifaces="$track_interface"
	fi

	# Collect track scripts
	_ha_list_result=""
	config_list_foreach "$section" track_script _ha_list_collect
	track_scripts="$_ha_list_result"

	# Normalize auth_type
	case "$auth_type" in
		pass|PASS) auth_type="PASS" ;;
		ah|AH) auth_type="AH" ;;
	esac

	# Collect unicast peers (per-instance explicit config)
	_ha_list_result=""
	config_list_foreach "$section" unicast_peer _ha_list_collect
	unicast_peers="$_ha_list_result"

	# Unicast auto-derivation: when vrrp_transport=unicast and no per-instance override,
	# derive unicast_src_ip from peer source_address and unicast_peer from peer addresses
	if [ "$_ha_vrrp_transport" = "unicast" ] && [ -z "$unicast_peers" ]; then
		unicast_peers="$_ha_peer_addresses"
		if [ -z "$unicast_src_ip" ] && [ -n "$_ha_peer_source_address" ]; then
			unicast_src_ip="$_ha_peer_source_address"
		fi
		ha_log_debug "vrrp_instance $section: unicast auto-derived from peer config"
	fi

	if [ -n "$unicast_peers" ] && [ -z "$unicast_src_ip" ]; then
		ha_log_warning "vrrp_instance $section has unicast_peer but no unicast_src_ip"
	fi

	# Collect all VIPs belonging to this instance
	_ha_current_instance="$section"
	_ha_vip_v4_addrs=""
	_ha_vip_v6_addrs=""
	config_foreach _ha_collect_vip_for_instance vip

	# Must have at least one VIP
	[ -z "$_ha_vip_v4_addrs" ] && [ -z "$_ha_vip_v6_addrs" ] && {
		ha_log_warning "vrrp_instance $section has no enabled VIPs"
		return 0
	}

	# Write IPv4 VRRP instance (if any IPv4 VIPs)
	if [ -n "$_ha_vip_v4_addrs" ]; then
		cat >> "$KEEPALIVED_CONF" <<EOF
vrrp_instance ${section} {
    state BACKUP
    interface $interface
    virtual_router_id $vrid
    priority $priority
    advert_int $advert_int
EOF

		_ha_write_vrrp_instance_options "$section"

		echo "    virtual_ipaddress {" >> "$KEEPALIVED_CONF"
		printf '%s' "$_ha_vip_v4_addrs" >> "$KEEPALIVED_CONF"
		cat >> "$KEEPALIVED_CONF" <<EOF
    }

    # Notify scripts for state changes
    notify_master "/bin/busybox env -i ACTION=MASTER TYPE=INSTANCE NAME=${section} /sbin/hotplug-call keepalived"
    notify_backup "/bin/busybox env -i ACTION=BACKUP TYPE=INSTANCE NAME=${section} /sbin/hotplug-call keepalived"
    notify_fault "/bin/busybox env -i ACTION=FAULT TYPE=INSTANCE NAME=${section} /sbin/hotplug-call keepalived"
}

EOF
	fi

	# Write IPv6 VRRP instance (if any IPv6 VIPs)
	if [ -n "$_ha_vip_v6_addrs" ]; then
		local vrid6=$((vrid + 128))
		if [ "$vrid6" -gt 255 ]; then
			ha_log_error "vrrp_instance $section: IPv6 VRID would be $vrid6 (VRID+128), exceeds 255"
			return 1
		fi

		cat >> "$KEEPALIVED_CONF" <<EOF
vrrp_instance ${section}_v6 {
    state BACKUP
    interface $interface
    virtual_router_id $vrid6
    priority $priority
    advert_int $advert_int
EOF

		_ha_write_vrrp_instance_options "${section}_v6"

		echo "    virtual_ipaddress {" >> "$KEEPALIVED_CONF"
		printf '%s' "$_ha_vip_v6_addrs" >> "$KEEPALIVED_CONF"
		cat >> "$KEEPALIVED_CONF" <<EOF
    }

    # Notify scripts for state changes
    notify_master "/bin/busybox env -i ACTION=MASTER TYPE=INSTANCE NAME=${section}_v6 /sbin/hotplug-call keepalived"
    notify_backup "/bin/busybox env -i ACTION=BACKUP TYPE=INSTANCE NAME=${section}_v6 /sbin/hotplug-call keepalived"
    notify_fault "/bin/busybox env -i ACTION=FAULT TYPE=INSTANCE NAME=${section}_v6 /sbin/hotplug-call keepalived"
}

EOF
	fi
}

# Generate owsync configuration file
ha_generate_owsync_conf() {
	local sync_method encryption_key sync_port sync_dir sync_interval owsync_log_level bind_address

	config_load ha-cluster
	config_get sync_method config sync_method "owsync"

	[ "$sync_method" != "owsync" ] && {
		rm -f "$OWSYNC_CONF"
		return 0
	}

	config_get encryption_key config encryption_key ""
	config_get sync_port config sync_port "4321"
	config_get sync_dir config sync_dir "/etc/config"
	config_get sync_interval advanced sync_interval "30"
	config_get owsync_log_level advanced owsync_log_level "2"
	config_get bind_address config bind_address ""

	ha_log "Generating owsync configuration"

	# Generate config file with secure permissions
	rm -f "$OWSYNC_CONF"
	touch "$OWSYNC_CONF"
	chmod 0600 "$OWSYNC_CONF"

	# Use bind_address if configured, otherwise default to :: for dual-stack
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

	# Security settings
	if [ -n "$encryption_key" ]; then
		echo "# Security: PSK encryption enabled" >> "$OWSYNC_CONF"
		echo "encryption_key=${encryption_key}" >> "$OWSYNC_CONF"
	else
		ha_log_warning "No encryption_key set - owsync will run without encryption"
		ha_log_warning "For production: Generate a key with 'owsync genkey' and set it in both nodes"
		ha_log_warning "Add to /etc/config/ha-cluster: option encryption_key '<your-key>'"
		echo "# Security: Plain mode (use only over secure VPN)" >> "$OWSYNC_CONF"
		echo "plain_mode=1" >> "$OWSYNC_CONF"
	fi
	echo "" >> "$OWSYNC_CONF"

	# Add peers
	echo "# Peers" >> "$OWSYNC_CONF"
	config_foreach ha_add_owsync_peer_conf peer
	echo "" >> "$OWSYNC_CONF"

	# Add includes (files to sync based on enabled services)
	echo "# Include patterns (sync these files)" >> "$OWSYNC_CONF"
	config_foreach ha_add_owsync_includes_conf service

	# Add excludes
	echo "" >> "$OWSYNC_CONF"
	echo "# Exclude patterns (never sync these)" >> "$OWSYNC_CONF"
	config_foreach ha_add_owsync_excludes_conf exclude

	ha_log "owsync configuration generated at $OWSYNC_CONF"
	return 0
}

# Add peer to owsync config (uses global port from config)
# Supports per-peer source_address for source address selection
# Skips peers with sync_enabled=0 (non-OpenWrt peers)
ha_add_owsync_peer_conf() {
	local section="$1"
	local address source_address sync_enabled

	config_get_bool sync_enabled "$section" sync_enabled 1
	[ "$sync_enabled" -eq 0 ] && return 0

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

# Add includes from enabled services
ha_add_owsync_includes_conf() {
	local section="$1"
	local enabled

	config_get_bool enabled "$section" enabled 0
	[ "$enabled" -eq 0 ] && return 0

	config_list_foreach "$section" config_files ha_add_owsync_include_conf
}

ha_add_owsync_include_conf() {
	echo "include=$1" >> "$OWSYNC_CONF"
}

# Add excludes
ha_add_owsync_excludes_conf() {
	local section="$1"
	config_list_foreach "$section" file ha_add_owsync_exclude_conf
}

ha_add_owsync_exclude_conf() {
	echo "exclude=$1" >> "$OWSYNC_CONF"
}


# Generate lease-sync configuration (flat file for managed mode)
ha_generate_lease_sync_conf() {
	local dhcp_service_enabled lease_sync_enabled lease_sync_port encryption_key
	local sync_interval peer_timeout persist_interval log_level node_name bind_address

	config_load ha-cluster

	# Check if DHCP service has lease sync enabled
	config_get_bool dhcp_service_enabled dhcp enabled 0
	config_get_bool lease_sync_enabled dhcp sync_leases 0
	config_get lease_sync_port advanced lease_sync_port "5378"
	config_get sync_interval advanced lease_sync_interval "30"
	config_get peer_timeout advanced lease_sync_peer_timeout "120"
	config_get persist_interval advanced lease_sync_persist_interval "60"
	config_get log_level advanced lease_sync_log_level "2"
	config_get encryption_key config encryption_key ""
	config_get bind_address config bind_address ""
	node_name="$(cat /proc/sys/kernel/hostname)"

	[ "$dhcp_service_enabled" -eq 0 ] || [ "$lease_sync_enabled" -eq 0 ] && {
		ha_log_debug "DHCP lease sync disabled"
		rm -f "$LEASE_SYNC_CONF"
		return 0
	}

	ha_log "Generating lease-sync configuration"

	# Generate config file with secure permissions (for encryption key)
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
persist_interval=${persist_interval}
log_level=${log_level}
EOF

	# Add bind_address if configured (prevents VIP from being used as source)
	if [ -n "$bind_address" ]; then
		echo "bind_address=${bind_address}" >> "$LEASE_SYNC_CONF"
		ha_log "lease-sync will bind to $bind_address"
	fi

	# Security settings: use encryption if key is available, otherwise plain mode
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

	# Add peers
	config_foreach ha_add_lease_sync_peer_flat peer

	ha_log "lease-sync configuration generated at $LEASE_SYNC_CONF"
	return 0
}

# Supports per-peer source_address for source address selection
# Skips peers with sync_enabled=0 (non-OpenWrt peers)
ha_add_lease_sync_peer_flat() {
	local section="$1"
	local address source_address sync_enabled

	config_get_bool sync_enabled "$section" sync_enabled 1
	[ "$sync_enabled" -eq 0 ] && return 0

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

	# Check if enabled
	config_get_bool enabled config enabled 0
	[ "$enabled" -eq 0 ] && return 0

	# Validate VRIDs are unique across vrrp_instance sections
	config_foreach ha_check_vrid_unique vrrp_instance

	# Check for peer configuration
	local peer_count=0
	config_foreach ha_count_peers peer
	[ "$peer_count" -eq 0 ] && {
		ha_log_warning "No peers configured - HA will not function"
	}

	# When lease sync is enabled, VIP interfaces need dhcp.*.force=1
	# so that dnsmasq initializes DHCP (required for ubus add_lease).
	# Without it, the BACKUP node cannot receive synced leases.
	local lease_sync_enabled
	config_get_bool lease_sync_enabled dhcp sync_leases 0
	if [ "$lease_sync_enabled" -eq 1 ]; then
		_ha_dhcp_force_checked=""
		config_foreach _ha_check_dhcp_force vip
	fi

	return $errors
}

# Check that each enabled VIP interface has force=1 in its dhcp section
_ha_dhcp_force_checked=""
_ha_check_dhcp_force() {
	local section="$1"
	local vip_enabled interface

	config_get_bool vip_enabled "$section" enabled 0
	[ "$vip_enabled" -eq 0 ] && return 0

	config_get interface "$section" interface ""
	[ -z "$interface" ] && return 0

	# Skip already-checked interfaces (multiple VIPs on same interface)
	echo "$_ha_dhcp_force_checked" | grep -qw "$interface" && return 0
	_ha_dhcp_force_checked="$_ha_dhcp_force_checked $interface"

	# Find the dhcp pool section (type=dhcp) for this interface.
	# Must exclude dnsmasq sections which also have an 'interface' option.
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
	[ -z "$dhcp_section" ] && return 0  # No DHCP pool on this interface, nothing to check

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

	# Validate VRID range (1-127, 128+ reserved for IPv6)
	case "$vrid" in
		''|*[!0-9]*) ha_log_error "vrrp_instance $section: VRID must be a number (got: $vrid)"; errors=$((errors + 1)); return 1 ;;
	esac
	[ "$vrid" -gt 127 ] && {
		ha_log_error "vrrp_instance $section: VRID must be 1-127 (got: $vrid, 128-255 reserved for IPv6)"
		errors=$((errors + 1))
		return 1
	}

	# Check uniqueness (global, not per-interface — instances are global)
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

# Manage standalone services (disable/enable)
ha_manage_services() {
	local action="$1"  # "take_over" or "release"
	local state_file="/etc/ha-cluster/service_states"

	mkdir -p /etc/ha-cluster

	if [ "$action" = "take_over" ]; then
		# Save current state and disable standalone services
		ha_log "Taking over service management from standalone init scripts"

		# Clear previous state file
		rm -f "$state_file"

		for service in keepalived owsync lease-sync; do
			if [ -x "/etc/init.d/$service" ]; then
				# Save enabled state
				if /etc/init.d/$service enabled 2>/dev/null; then
					echo "$service=1" >> "$state_file"
				else
					echo "$service=0" >> "$state_file"
				fi

				# Stop and disable
				/etc/init.d/$service stop 2>/dev/null
				/etc/init.d/$service disable 2>/dev/null
				ha_log "Disabled standalone service: $service"
			fi
		done

	elif [ "$action" = "release" ]; then
		# Restore previous state
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

# dnsmasq conf-dir overlay for HA operation
# ha-cluster drops a config file into dnsmasq's conf-dir to enable HA-required
# options at runtime, without modifying /etc/config/dhcp.
# dnsmasq's init script detects this file and skips the dhcp_check probe,
# allowing both HA nodes to serve DHCP simultaneously.
HA_DNSMASQ_OVERLAY_NAME="ha-cluster.conf"

# Resolve dnsmasq's conf-dir path from UCI
# The conf-dir path depends on the dnsmasq section name (e.g., cfg01411c)
# matching the logic in dnsmasq's init script.
_ha_dnsmasq_confdir=""
_ha_resolve_dnsmasq_confdir_cb() {
	local cfg="$1"
	[ -n "$_ha_dnsmasq_confdir" ] && return 0
	config_get _ha_dnsmasq_confdir "$cfg" confdir "/tmp/dnsmasq${cfg:+.$cfg}.d"
	# Strip any filter suffixes (confdir supports ",*.ext" filters)
	_ha_dnsmasq_confdir="${_ha_dnsmasq_confdir%%,*}"
}

ha_get_dnsmasq_confdir() {
	config_load dhcp
	_ha_dnsmasq_confdir=""
	config_foreach _ha_resolve_dnsmasq_confdir_cb dnsmasq
	echo "${_ha_dnsmasq_confdir:-/tmp/dnsmasq.d}"
}

# Writes the dnsmasq conf-dir overlay and restarts dnsmasq (at most once)
ha_configure_dnsmasq() {
	local lease_sync_enabled needs_restart=0
	local confdir overlay_path

	config_load ha-cluster
	config_get_bool lease_sync_enabled dhcp sync_leases 0

	confdir="$(ha_get_dnsmasq_confdir)"
	overlay_path="$confdir/$HA_DNSMASQ_OVERLAY_NAME"

	if [ "$lease_sync_enabled" -eq 1 ]; then
		mkdir -p "$confdir"
		cat > "$overlay_path" <<-'EOF'
			# Auto-generated by ha-cluster — do not edit
			# Call dhcp-script on lease renewals so lease-sync can track expiry changes
			script-on-renewal
		EOF
		needs_restart=1
		ha_log "Wrote dnsmasq HA overlay to $overlay_path"
	elif [ -f "$overlay_path" ]; then
		# sync_leases disabled but stale overlay exists (reload or crash recovery)
		rm -f "$overlay_path"
		needs_restart=1
		ha_log "Removed stale dnsmasq HA overlay"
	fi

	[ "$needs_restart" -eq 1 ] && {
		/etc/init.d/dnsmasq restart 2>/dev/null
		ha_log "dnsmasq restarted"
	}
}

# Removes the dnsmasq conf-dir overlay and restarts dnsmasq
ha_release_dnsmasq() {
	local confdir overlay_path
	confdir="$(ha_get_dnsmasq_confdir)"
	overlay_path="$confdir/$HA_DNSMASQ_OVERLAY_NAME"

	[ ! -f "$overlay_path" ] && return 0

	ha_log "Removing dnsmasq HA overlay"
	rm -f "$overlay_path"
	/etc/init.d/dnsmasq restart 2>/dev/null
}

# Apply all configurations
ha_apply_config() {
	ha_log "Applying HA cluster configuration"

	# Validate first
	ha_validate_config || {
		ha_log_error "Configuration validation failed"
		return 1
	}

	# Take over service management from standalone init scripts
	ha_manage_services "take_over"

	# Configure dnsmasq for HA operation (conf-dir overlay + restart)
	ha_configure_dnsmasq

	# Generate configs - services will be started by ha-cluster init
	ha_generate_keepalived_conf
	ha_generate_owsync_conf
	ha_generate_lease_sync_conf

	ha_log "HA cluster configuration applied successfully"
	return 0
}
