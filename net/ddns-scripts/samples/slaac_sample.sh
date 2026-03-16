#!/bin/sh
#
# script to determine and return SLAAC ipv6 address using prefix from a locally configured interface and the MAC address of the device
# (c) 2018 Keve Mueller <keve at keve dot hu>
#
# activated inside /etc/config/ddns by setting
#
# option ip_source      'script'
# option ip_script      '/usr/lib/ddns/slaac_sample.sh br-lan AA:BB:CC:DD:EE:FF'
#
# the script is executed (not parsed) inside get_local_ip() function
# of /usr/lib/ddns/dynamic_dns_functions.sh
#
# useful when this box is the only DDNS client in the network and other clients use SLAAC
# so no need to install ddns client on every "internal" box
#
# NB: this will not catch the actual IPV6 used by the host when it is configured to use temporary addresses

#NB: we need a valid MAC address that is fully expanded with leading zeroes on all positions
format_eui_64() {
    local macaddr="$1"
    echo ${macaddr:0:1}$(echo ${macaddr:1:1}|tr 0123456789abcdefABCDEF 23016745ab89efcd89efcd)${macaddr:3:2}:${macaddr:6:2}ff:fe${macaddr:9:2}:${macaddr:12:2}${macaddr:15:2}
}

# expand :: in an ipv6 address specification to the appropriate series of 0:
# result will have 8 ipv6 fragments separated by single colon
# NB: input must be a valid IPv6 address, e.g. ::1
# NB: numbers are not prepended with leading zeroes
expand_ipv6_colons() {
    local ipv6=$1
# we need :: to be in the middle, so prepend a 0 if the input starts with : and append 0 if it ends with it
    if [ "${ipv6:0:1}" = ":" ]; then ipv6=0${ipv6}; fi
    if [ "${ipv6: -1:1}" = ":" ]; then ipv6=${ipv6}0; fi
# retain only the real colons
    local colons=${ipv6//::|[0123456789abcdefABCDEF]/}
# count them
    local num_colons=${#colons}
    local filler=":0:0:0:0:0:0:"
# replace the :: with the appropriate substring from filler
    local ipv6_x=${ipv6/::/${filler:0:(7-$num_colons)*2-1}}
    echo $ipv6_x
}

# obtain the first ipv6 address of the device passed in $1
addr_net=$(ip -6 -o addr show dev $1 scope global up | cut -d" " -f 7 | head -1)
#addr_net=$1
addr=${addr_net%/*}
# TODO: we assume /64 subnet
# get the first 64 bits of the address
prefix=$(expand_ipv6_colons $addr | cut -d: -f -4)
# compute the SLAAC 64 bits from the MAC
suffix=$(format_eui_64 "$2")

echo -n $prefix:$suffix
exit 0

#echo "Should never come here" >&2
#exit 2

