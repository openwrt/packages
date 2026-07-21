#!/bin/sh

case "$1" in
prometheus-node-exporter-ucode-nat_traffic)
	[ -f /proc/net/nf_conntrack ] && prometheus-node-exporter-ucode nat_traffic || :
	;;
*)
	prometheus-node-exporter-ucode time
	;;
esac
