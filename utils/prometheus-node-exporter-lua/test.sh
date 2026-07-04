#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
prometheus-node-exporter-lua-openwrt)
	# call ubus outside scape, so skip the check
	exit 0
	;;

*)
	prometheus-node-exporter-lua | grep node_scrape_collector_success
	;;
esac
