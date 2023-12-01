#!/bin/sh
# shellcheck disable=SC1091,SC3037,SC3043

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

proto_yggdrasil_init_config() {
	proto_config_add_string "private_key"
	available=1
}

proto_yggdrasil_setup_peer_if_non_interface() {
	local peer_config="$1"
	local peer_address
	local peer_interface
	config_get peer_address "$peer_config" "address"
	config_get peer_interface "$peer_config" "interface"
	[ -z "$peer_interface" ] && json_add_string "" "$peer_address"
}

proto_yggdrasil_dump_peer_interface() {
	local peer_config="$1"
	local peer_interface

	config_get peer_interface "$peer_config" "interface"

	peer_interfaces="${peer_interfaces}${peer_interface:+\n$peer_interface}"
}

proto_yggdrasil_setup_peer_if_interface() {
	local peer_config="$1"
	local peer_address
	local peer_interface
	config_get peer_interface "$peer_config" "interface"
	if [ "$peer_interface" = "$peer_interface_filter" ]; then
		config_get peer_address "$peer_config" "address"
		json_add_string "" "$peer_address"
	fi;
}

proto_yggdrasil_append_to_interface_regex() {
	regex="${regex:+$regex|}$1";
}

proto_yggdrasil_setup_multicast_interface() {
	local interface_config="$1"
	local beacon
	local listen
	local port
	local password
	local regex=

	config_get beacon   "$interface_config" "beacon"
	config_get listen   "$interface_config" "listen"
	config_get password "$interface_config" "password"
	config_get port     "$interface_config" "port" "0"

	json_add_object ""
	json_add_boolean "Beacon" "$beacon"
	json_add_boolean "Listen" "$listen"
	json_add_int "Port" "$port"
	[ -n "$password" ] && json_add_string "Password" "$password"
	config_list_foreach "$interface_config" interface proto_yggdrasil_append_to_interface_regex
	json_add_string "Regex" "^(${regex})\$"
	json_close_object
}

proto_yggdrasil_add_string() {
	json_add_string "" "$1"
}

proto_yggdrasil_generate_keypair() {
	local PrivateKey
	json_load "$(yggdrasil -genconf -json)"
	json_get_vars PrivateKey
	json_cleanup
	private_key="$PrivateKey"
	public_key="${PrivateKey:64}"
}

proto_yggdrasil_setup() {
	local config="$1"
	local device="$2"
	local ygg_dir="/tmp/yggdrasil"
	local ygg_cfg="${ygg_dir}/${config}.conf"
	local ygg_sock="unix://${ygg_dir}/${config}.sock"


	local private_key
	local public_key
	local mtu
	local listen_addresses
	local whitelisted_keys
	local node_info
	local node_info_privacy

	config_load network
	config_get private_key       "$config" "private_key"
	config_get public_key        "$config" "public_key"
	config_get mtu               "$config" "mtu"
	config_get node_info         "$config" "node_info"
	config_get node_info_privacy "$config" "node_info_privacy"

	[ -z "$private_key" ] && proto_yggdrasil_generate_keypair

	umask 077
	mkdir -p "$ygg_dir"

	if [ "$private_key" = "auto" ]; then
		proto_yggdrasil_generate_keypair
		uci -t "${ygg_dir}/.uci.${config}" batch <<EOF
			set network.${config}.private_key='${private_key}'
			set network.${config}.public_key='${public_key}'
EOF
		uci -t "${ygg_dir}/.uci.${config}" commit;
	fi;

	# Generate config file
	json_init
	json_add_string "IfName" "$config"
	json_add_string "AdminListen" "$ygg_sock"
	json_add_string "PrivateKey" "$private_key"
	json_add_string "PublicKey" "$public_key"
	[ -n "$mtu" ] && json_add_int "IfMTU" "$mtu"
	[ -n "$node_info" ] && json_add_string "NodeInfo" "%%_YGGDRASIL_NODEINFO_TEMPLATE_%%"
	json_add_boolean "NodeInfoPrivacy" "$node_info_privacy"

	# Peers
	json_add_array "Peers"
	config_foreach proto_yggdrasil_setup_peer_if_non_interface "yggdrasil_${config}_peer"
	json_close_array

	local peer_interfaces
	peer_interfaces=""
	config_foreach proto_yggdrasil_dump_peer_interface "yggdrasil_${config}_peer"
	peer_interfaces="$(echo -e "$peer_interfaces" | sort | uniq)"

	json_add_object "InterfacePeers"
	for peer_interface_filter in $peer_interfaces; do
		json_add_array "$peer_interface_filter"
		config_foreach proto_yggdrasil_setup_peer_if_interface "yggdrasil_${config}_peer"
		json_close_array
	done
	json_close_object

	json_add_array "AllowedPublicKeys"
	config_list_foreach "$config" allowed_public_key proto_yggdrasil_add_string
	json_close_array

	json_add_array "Listen"
	config_list_foreach "$config" listen_address proto_yggdrasil_add_string
	json_close_array

	json_add_array "MulticastInterfaces"
	config_foreach proto_yggdrasil_setup_multicast_interface "yggdrasil_${config}_interface"
	json_close_array

	json_dump > "${ygg_cfg}.1"
	awk -v s='"%%_YGGDRASIL_NODEINFO_TEMPLATE_%%"' -v r="$node_info" '{gsub(s, r)} 1' "${ygg_cfg}.1" > "$ygg_cfg"
	rm "${ygg_cfg}.1"

	proto_run_command "$config" /usr/sbin/yggdrasil -useconffile "${ygg_cfg}"
	proto_init_update "$config" 1
	proto_add_ipv6_address "$(yggdrasil -useconffile "$ygg_cfg" -address)" "7"
	proto_add_ipv6_prefix "$(yggdrasil -useconffile "$ygg_cfg" -subnet)"
	proto_send_update "$config"
}

proto_yggdrasil_teardown() {
	local interface="$1"
	proto_kill_command "$interface"
}

[ -n "$INCLUDE_ONLY" ] || {
	add_protocol yggdrasil
}
