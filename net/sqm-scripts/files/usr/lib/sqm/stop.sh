#!/bin/sh

. /usr/lib/sqm/functions.sh

# allow passing in the IFACE as first command line argument
[ ! -z ${1} ] && IFACE=${1}
sqm_logger "${0} Stopping ${IFACE}"

# make sure to only delete the ifb associated with the current interface
CUR_IFB=$( get_ifb_associated_with_if ${IFACE} )

sqm_stop() {
	tc qdisc del dev $IFACE ingress 2> /dev/null
	tc qdisc del dev $IFACE root 2> /dev/null
	[ ! -z "$CUR_IFB" ] && tc qdisc del dev $CUR_IFB root 2> /dev/null
        [ ! -z "$CUR_IFB" ] && sqm_logger "${CUR_IFB} shaper deleted"
}

ipt_stop() {
	[ ! -z "$CUR_IFB" ] && ipt -t mangle -D POSTROUTING -o $CUR_IFB -m mark --mark 0x00 -g QOS_MARK_${IFACE} 
	ipt -t mangle -D POSTROUTING -o $IFACE -m mark --mark 0x00 -g QOS_MARK_${IFACE} 
	ipt -t mangle -D PREROUTING -i vtun+ -p tcp -j MARK --set-mark 0x2
	ipt -t mangle -D OUTPUT -p udp -m multiport --ports 123,53 -j DSCP --set-dscp-class AF42
	ipt -t mangle -F QOS_MARK_${IFACE}
	ipt -t mangle -X QOS_MARK_${IFACE}
}


sqm_stop
ipt_stop
[ ! -z "$CUR_IFB" ] && ifconfig ${CUR_IFB} down
[ ! -z "$CUR_IFB" ] && ip link delete ${CUR_IFB} type ifb
[ ! -z "$CUR_IFB" ] && sqm_logger "${CUR_IFB} interface deleted"

exit 0