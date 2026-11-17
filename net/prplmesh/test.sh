#!/bin/sh

# shellcheck shell=busybox

set -eu

case "$PKG_NAME" in
prplmesh)
	for config in \
		/usr/share/prplmesh/config/beerocks_agent.conf \
		/usr/share/prplmesh/config/beerocks_controller.conf; do
		grep -Fx 'log_global_levels=error,info,warning,fatal' "$config"
		grep -Fx 'log_global_syslog_levels=error,info,warning,fatal' "$config"
	done
	# -h reaches "usage; exit 0" only after main()'s platform guard has
	# accepted TARGET_PLATFORM=openwrt; an unpatched helper exits 1 with
	# "Unsupported platform: openwrt" instead, so this self-tests patch
	# 161.
	/usr/libexec/prplmesh/scripts/prplmesh_utils.sh -h
	;;
*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
