#!/bin/sh

next_port () {
	local port_start=$1
	local port_end=$2

	ports=$(wg show all listen-port | awk '{print $2}')

	for i in $(seq "$port_start" "$port_end"); do
		if ! echo "$ports" | grep -q "$i"; then
			echo "$i"
			return
		fi
	done
}

cleanup_wginterfaces() {
    check_wg_neighbors
}

delete_wg_interface() {
    ip link del dev "$1"
    [ -f "/tmp/run/wgserver/$1.key" ] && rm "/tmp/run/wgserver/$1.key"
    [ -f "/tmp/run/wgserver/$1.pub" ] && rm "/tmp/run/wgserver/$1.pub"
}

check_wg_neighbors() {
    wg_interfaces=$(ip link | grep wg | awk '{print $2}' | sed 's/://')
    for phy in $wg_interfaces; do
        linklocal=$(ip -6 addr list dev "$phy" | grep "scope link" | awk '{print $2}' | sed 's/\/64//') 2>/dev/null
        ips=$(ping ff02::1%"$phy" -w5 -W5 -c10 | awk '/from/{print($4)}' | sed 's/.$//') 2>/dev/null
        delete=1
        for ip in $ips; do
            if [ "$ip" != "$linklocal" ] && [ "$(owipcalc $ip linklocal)" -eq 1 ]; then
                delete=0
                break
            fi
        done
        if [ $delete -eq 1 ]; then
            delete_wg_interface "$phy"
        fi
    done
}

case $1 in
next_port|\
cleanup_wginterfaces)
    "$@"
    exit
    ;;
esac
