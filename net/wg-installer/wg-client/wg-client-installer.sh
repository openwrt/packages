#!/bin/sh

. /usr/share/wginstaller/rpcd_ubus.sh
. /usr/share/wginstaller/wg.sh

DEFAULT_NAMESPACE=0

CMD=$1
shift

while true; do
	case "$1" in
	-h | --help)
		echo "help"
		shift 1
		;;
	--endpoint)
		ENDPOINT=$2
		shift 2
		;;
	--user)
		USER=$2
		shift 2
		;;
	--password)
		PASSWORD=$2
		shift 2
		;;
	--mtu)
		WG_MTU=$2
		shift 2
		;;
	--wg-key-file)
		WG_KEY_FILE=$2
		shift 2
		;;
	--lookup-default-namespace)
		DEFAULT_NAMESPACE=1
		shift 1
		;;
	'')
		break
		;;
	*)
		break
		;;
	esac
done

register_client_interface () {
	local endpoint=$2
	local mtu_client=$3
	local privkey=$4
	local pubkey=$5
	local gw_port=$6
	local def_namespace=$7

	port_start=$(uci get wgclient.@client[0].port_start)
	port_end=$(uci get wgclient.@client[0].port_end)

	if [ "$def_namespace" -eq "1" ]; then
		[ -f /var/run/netns/default ] || ln -s /proc/1/ns/net /var/run/netns/default
		port=$(ip netns exec default /usr/share/wginstaller/wg.sh next_port "$port_start" "$port_end")
	else
		port=$(next_port "$port_start" "$port_end")
	fi

	ifname="wg_$port"

	ip link add dev "$ifname" type wireguard
	ip -6 addr add dev "$ifname" fe80::2/64
	wg set "$ifname" listen-port "$port" private-key "$privkey" peer "$pubkey" allowed-ips 0.0.0.0/0,::0/0 endpoint "${endpoint}:${gw_port}"
	ip link set up dev "$ifname"
	ip link set mtu "$mtu_client" dev "$ifname"

	export "$1=$ifname"
}

# rpc login
token="$(request_token "$ENDPOINT" "$USER" "$PASSWORD")"
if [ $? -ne 0 ]; then
	logger -t "wg-client-installer" "Failed to register token!"
	exit 1
fi

# now call procedure
case $CMD in
"get_usage")
	wg_rpcd_get_usage "$token" "$ENDPOINT"
	;;
"register")

	if [ -n "$WG_KEY_FILE" ]; then
		wg_priv_key_file="$WG_KEY_FILE"
		wg_pub_key=$(wg pubkey < "$WG_KEY_FILE")
	fi

	wg_rpcd_register __gw_pubkey __gw_ipv4 __gw_ipv6 __gw_port "$token" "$ENDPOINT" "$WG_MTU" "$wg_pub_key"
	if [ $? -ne 0 ]; then
		logger -t "wg-client-installer" "Failed to Register!"
		exit 1
	fi

	register_client_interface __interface "$ENDPOINT" "$WG_MTU" "$wg_priv_key_file" "$__gw_pubkey" "$__gw_port" "$DEFAULT_NAMESPACE"
	logger -t "wg-client-installer" "Registered: $__interface"
	echo $__interface
	;;
*) echo "Usage: wg-client-installer [cmd] --endpoint [2001::1] --mtu 1500 --user wginstaller --password wginstaller" ;;
esac
