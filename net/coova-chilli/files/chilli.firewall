#!/bin/sh

chilli_firewall() {
    local cfg="$1"

    local network ifname tun

    config_get network "$cfg" network

    . /lib/functions/network.sh
    network_get_device ifname ${network:-lan}

    if [ "$ifname" = "" ]
    then
       config_get ifname "$cfg" dhcpif
    fi

    config_get tun "$cfg" tundev

    for n in ACCEPT DROP REJECT
    do
       iptables -F zone_${network}_${n}
       iptables -I zone_${network}_${n} -i $tun -j $n
       iptables -I zone_${network}_${n} -o $tun -j $n
    done

    iptables -D forward -i ${ifname} -j zone_${network}_forward
    iptables -A forward -i ${ifname} -j DROP
    iptables -A forward -i $tun -j zone_${network}_forward

    iptables -D input -i ${ifname} -j zone_${network}
    iptables -A input -i $tun -j zone_${network}

    iptables -I zone_${network} -p tcp --dport 3990 -j ACCEPT
    iptables -I zone_${network} -p tcp --dport 3991 -j ACCEPT
}

chilli_post_core_cb() {
    config_load chilli
    config_foreach chilli_firewall chilli
}
