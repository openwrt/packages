#!/bin/sh

. /usr/share/libubox/jshn.sh

query_gw () {
	local ip=$1
	local req=$2
	
	# first try https
	ret=$(curl https://"$ip"/ubus -d "$req") 2>/dev/null
	if [ $? -eq 0 ]; then
		echo "$ret"
		return 0
	fi

	# try with --insecure
	if [ "$(uci get wgclient.@client[0].try_insecure)" -eq '1' ]; then
		ret=$(curl --insecure https://"$ip"/ubus -d "$req") 2>/dev/null
		if [ $? -eq 0 ]; then
			echo "$ret"
			return 0
		fi
	fi

	# try with http
	if [ "$(uci get wgclient.@client[0].try_http)" -eq '1' ]; then
		ret=$(curl http://"$ip"/ubus -d "$req") 2>/dev/null
		if [ $? -eq 0 ]; then
			echo "$ret"
			return 0
		fi
	fi

	return 1
}

request_token () {
	local ip=$1
	local user=$2
	local password=$3

	json_init
	json_add_string "jsonrpc" "2.0"
	json_add_int "id" "1"
	json_add_string "method" "call"
	json_add_array "params"
	json_add_string "" "00000000000000000000000000000000"
	json_add_string "" "session"
	json_add_string "" "login"
	json_add_object
	json_add_string "username" "$user"
	json_add_string "password" "$password"
	json_close_object
	json_close_array
	req=$(json_dump)
	ret=$(query_gw "$ip" "$req") 2>/dev/null
	if [ $? -ne 0 ]; then
		return 1
	fi
	json_load "$ret"
	json_get_vars result result
	json_select result
	json_select 2
	json_get_var ubus_rpc_session ubus_rpc_session
	echo "$ubus_rpc_session"
}

wg_rpcd_get_usage () {
	local token=$1
	local ip=$2
	local secret=$3

	json_init
	json_add_string "jsonrpc" "2.0"
	json_add_int "id" "1"
	json_add_string "method" "call"
	json_add_array "params"
	json_add_string "" "$token"
	json_add_string "" "wginstaller"
	json_add_string "" "get_usage"
	json_add_object
	json_close_object
	json_close_array
	req=$(json_dump)
	ret=$(query_gw "$ip" "$req") 2>/dev/null
	if [ $? -ne 0 ]; then
		return 1
	fi
	# return values
	json_load "$ret"
	json_get_vars result result
	json_select result
	json_select 2
	json_get_var num_interfaces num_interfaces
	echo "num_interfaces: ${num_interfaces}"
}

wg_error_handling () {
	local response_code=$1

	case "$response_code" in
		1)	logger -t "wginstaller" "Server rejected request since the public key is already used!" ;;
		*)	logger -t "wginstaller" "Unknown Error Code!";;
	esac
}

wg_rpcd_register () {
	local token=$5
	local ip=$6
	local mtu=$7
	local public_key=$8

	json_init
	json_add_string "jsonrpc" "2.0"
	json_add_int "id" "1"
	json_add_string "method" "call"
	json_add_array "params"
	json_add_string "" "$token"
	json_add_string "" "wginstaller"
	json_add_string "" "register"
	json_add_object
	json_add_int "mtu" "$mtu"
	json_add_string "public_key" "$public_key"
	json_close_object
	json_close_array
	req=$(json_dump)
	ret=$(query_gw "$ip" "$req") 2>/dev/null
	if [ $? -ne 0 ]; then
		return 1
	fi
	json_load "$ret"
	json_get_vars result result
	json_select result
	json_select 2
	json_get_var response_code response_code
	if [ "$response_code" -ne 0 ]; then
		wg_error_handling "$response_code"
		return 1
	fi
	json_get_var gw_pubkey gw_pubkey
	json_get_var gw_ipv4 gw_ipv4
	json_get_var gw_ipv6 gw_ipv6
	json_get_var gw_port gw_port
	export "$1=$gw_pubkey"
	export "$2=$gw_ipv4"
	export "$3=$gw_ipv6"
	export "$4=$gw_port"
}
