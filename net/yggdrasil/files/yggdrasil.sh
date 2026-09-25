#!/bin/sh


[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

proto_yggdrasil_init_config() {
	available=1

	# Yggdrasil
	proto_config_add_string "private_key"
	proto_config_add_boolean "allocate_listen_addresses"

	# Jumper
	proto_config_add_boolean "jumper_enable"
	proto_config_add_string "jumper_loglevel"
	proto_config_add_boolean "jumper_autofill_listen_addresses"
	proto_config_add_string "jumper_config"
}

proto_yggdrasil_setup_peer_if_non_interface() {
	local peer_config="$1"
	local peer_address
	local peer_interface
	config_get peer_address "${peer_config}" "address"
	config_get peer_interface "${peer_config}" "interface"
	if [ -z ${peer_interface} ]; then
		json_add_string "" ${peer_address}
	fi;
}

proto_yggdrasil_dump_peer_interface() {
	local peer_config="$1"
	local peer_interface

	config_get peer_interface "${peer_config}" "interface"

	if [ ! -z ${peer_interface} ]; then
		peer_interfaces="${peer_interfaces}\n${peer_interface}"
	fi;
}

proto_yggdrasil_setup_peer_if_interface() {
	local peer_config="$1"
	local peer_address
	local peer_interface
	config_get peer_interface "${peer_config}" "interface"
	if [ "${peer_interface}" = "${peer_interface_filter}" ]; then
		config_get peer_address "${peer_config}" "address"
		json_add_string "" ${peer_address}
	fi;
}

proto_yggdrasil_append_to_interface_regex() {
	if [ -z "${regex}" ]; then
		regex="$1"
	else
		regex="${regex}|$1";
	fi;
}

proto_yggdrasil_setup_multicast_interface() {
	local interface_config="$1"
	local beacon
	local listen
	local port=0
	local password
	local regex=""

	config_get beacon "${interface_config}" "beacon"
	config_get listen "${interface_config}" "listen"
	config_get port "${interface_config}" "port"
	config_get password "${interface_config}" "password"

	json_add_object ""
	json_add_boolean "Beacon" $beacon
	json_add_boolean "Listen" $listen
	if [ ! -z ${port} ]; then
		json_add_int "Port" $port
	else
		json_add_int "Port" 0
	fi;
	if [ ! -z ${password} ]; then
		json_add_string "Password" $password
	fi;

	config_list_foreach "${interface_config}" interface proto_yggdrasil_append_to_interface_regex

	json_add_string "Regex" "^(${regex})\$"

	json_close_object
}

proto_yggdrasil_add_string() {
	json_add_string "" $1
}

proto_yggdrasil_generate_keypair() {
	json_load "$(yggdrasil -genconf -json)"
	json_get_vars PrivateKey
	json_cleanup
	private_key=$PrivateKey
	public_key=${PrivateKey:64}
}

proto_yggdrasil_allocate_listen_addresses() {
	local config="$1"

	# Collect already defined protocols
	protocols=""
	_add_address_protocol() {
		protocols="${protocols}$(echo $1 | cut -d "://" -f1) "
	}
	config_list_foreach "$config" listen_address _add_address_protocol

	# Add new address for each previously unspecified protocol
	for protocol in "tls" "quic"; do
		if ! echo "$protocols" | grep "$protocol" &>/dev/null; then
			# By default linux dynamically alocates ports in the range 32768..60999
			# `sysctl net.ipv4.ip_local_port_range`
			random_port=$(( ($RANDOM + $RANDOM) % 22767 + 10000 ))
			proto_yggdrasil_add_string "${protocol}://127.0.0.1:${random_port}"
		fi
	done
}

proto_yggdrasil_generate_jumper_config() {
	local config="$1"
	local ygg_sock="$2"
	local ygg_cfg="$3"

	# Autofill Yggdrasil listeners
	config_get is_autofill_listeners "$config" "jumper_autofill_listen_addresses"
	if [ "$is_autofill_listeners" == "1" ]; then
		echo "yggdrasil_listen = ["
		_print_address() {
			echo "\"${1}\","
		}
		json_load_file "${ygg_cfg}"
		json_for_each_item _print_address "Listen"
		echo "]"
	fi

	# Print admin api socket
	echo "yggdrasil_admin_listen = [ \"${ygg_sock}\" ]"

	# Print extra config
	config_get jumper_config "$config" "jumper_config"
	echo "${jumper_config}"
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
	config_get private_key "${config}" "private_key"
	config_get public_key "${config}" "public_key"
	config_get mtu "${config}" "mtu"
	config_get node_info "${config}" "node_info"
	config_get node_info_privacy "${config}" "node_info_privacy"

	if [ -z $private_key ]; then
		proto_yggdrasil_generate_keypair
	fi;

	umask 077
	mkdir -p "${ygg_dir}"

	if [ $private_key = "auto" ]; then
		proto_yggdrasil_generate_keypair
		uci -t ${ygg_dir}/.uci.${config} batch <<EOF
			set network.${config}.private_key='${private_key}'
			set network.${config}.public_key='${public_key}'
EOF
		uci -t ${ygg_dir}/.uci.${config} commit;
	fi;

	# Generate config file
	json_init
	json_add_string "IfName" ${config}
	json_add_string "AdminListen" ${ygg_sock}

	json_add_string "PrivateKey" ${private_key}
	json_add_string "PublicKey" ${public_key}

	if [ ! -z $mtu ]; then
		json_add_int "IfMTU" ${mtu}
	fi;

	if [ ! -z $node_info ]; then
		json_add_string "NodeInfo" "%%_YGGDRASIL_NODEINFO_TEMPLATE_%%"
	fi;

	json_add_boolean "NodeInfoPrivacy" ${node_info_privacy}

	# Peers
	json_add_array "Peers"
	config_foreach proto_yggdrasil_setup_peer_if_non_interface "yggdrasil_${config}_peer"
	json_close_array

	local peer_interfaces
	peer_interfaces=""
	config_foreach proto_yggdrasil_dump_peer_interface "yggdrasil_${config}_peer"
	peer_interfaces=$(echo -e ${peer_interfaces} | sort | uniq)

	json_add_object "InterfacePeers"
	for peer_interface_filter in ${peer_interfaces}; do
		json_add_array "${peer_interface_filter}"
		config_foreach proto_yggdrasil_setup_peer_if_interface "yggdrasil_${config}_peer"
		json_close_array
	done
	json_close_object

	json_add_array "AllowedPublicKeys"
	config_list_foreach "$config" allowed_public_key proto_yggdrasil_add_string
	json_close_array

	json_add_array "Listen"
	config_list_foreach "$config" listen_address proto_yggdrasil_add_string

	# If needed, add new address for each previously unspecified protocol
	config_get is_jumper_enabled "$config" "jumper_enable"
	config_get allocate_listen_addresses "$config" "allocate_listen_addresses"
	if [ "$is_jumper_enabled" == "1" ] && [ "$allocate_listen_addresses" == "1" ]; then
		proto_yggdrasil_allocate_listen_addresses "$config"
	fi

	json_close_array

	json_add_array "MulticastInterfaces"
	config_foreach proto_yggdrasil_setup_multicast_interface "yggdrasil_${config}_interface"
	json_close_array

	json_dump > "${ygg_cfg}.1"
	awk -v s='"%%_YGGDRASIL_NODEINFO_TEMPLATE_%%"' -v r="${node_info}" '{gsub(s, r)} 1' "${ygg_cfg}.1" > ${ygg_cfg}
	rm "${ygg_cfg}.1"

	proto_run_command "$config" /usr/sbin/yggdrasil -useconffile "${ygg_cfg}"
	proto_init_update "$config" 1
	proto_add_ipv6_address "$(yggdrasil -useconffile "${ygg_cfg}" -address)" "7"
	proto_add_ipv6_prefix "$(yggdrasil -useconffile "${ygg_cfg}" -subnet)"
	proto_send_update "$config"

	# Start jumper if needed
	config_get is_jumper_enabled "$config" "jumper_enable"
	if [ "$is_jumper_enabled" == "1" ] && [ -f /usr/sbin/yggdrasil-jumper ]; then
		jumper_cfg="${ygg_dir}/${config}-jumper.conf"
		proto_yggdrasil_generate_jumper_config "$config" "$ygg_sock" "$ygg_cfg" > "$jumper_cfg"

		config_get jumper_loglevel "$config" "jumper_loglevel"
		sh -c "sleep 2 && exec /usr/sbin/yggdrasil-jumper --loglevel \"${jumper_loglevel:-info}\" --config \"$jumper_cfg\" 2&>1 | logger -t \"${config}-jumper\"" &
	fi
}

proto_yggdrasil_teardown() {
	local interface="$1"
	proto_kill_command "$interface"
}

[ -n "$INCLUDE_ONLY" ] || {
	add_protocol yggdrasil
}
