#!/bin/sh
#
# Copyright (C) 2020 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See https://www.gnu.org/licenses/gpl-2.0.txt for more information.
#

. /lib/functions.sh

DDNS_PACKAGE_DIR="/usr/share/ddns"
URL="https://raw.githubusercontent.com/openwrt/packages/master/net/ddns-scripts/files"

usage() {
	local code="$1"
	local msg="$2"

	echo "$msg"
	echo ""
	echo "Usage: $(basename "$0") <command> <action> <service>"
	echo ""
	echo "Supported ddns <command>:"
	echo "  service:  Command for custom ddns service providers"
	echo ""
	echo "Supported ddns 'service' command <action>:"
	echo "  update:             Update local custom ddns service list"
	echo "  list-available:     List all available custom service providers"
	echo "  list-installed:     List all installed custom service providers"
	echo "  install <service>:  Install custom service provider"
	echo "  remove <service>:   Remove custom service provider"
	echo "  purge:              Remove local custom ddns services"

	exit "$code"
}

action_update() {
	local cacert

	config_load ddns
	config_get url global 'url' "${URL}${DDNS_PACKAGE_DIR}"
	config_get cacert global 'cacert' "IGNORE"
	url="${url}/list"

	mkdir -p "${DDNS_PACKAGE_DIR}"

	if [ "$cacert" = "IGNORE" ]; then
		uclient-fetch \
			--no-check-certificate \
			"$url" \
			-O "${DDNS_PACKAGE_DIR}/list"
	elif [ -f "$cacert" ]; then
		uclient-fetch \
			--ca-certificate="${cacert}" \
			"$url" \
			-O "${DDNS_PACKAGE_DIR}/list"
	elif [ -n "$cacert" ]; then
		echo "Certification file not found ($cacert)"
		exit 5
	fi
}

action_list_available() {
	if [ -f "${DDNS_PACKAGE_DIR}/list" ]; then
		cat "${DDNS_PACKAGE_DIR}/list"
	else
		echo "No custom service list file found. Please download first"
		exit 3
	fi
}

action_list_installed() {
	if [ -d "${DDNS_PACKAGE_DIR}/custom" ]; then
		ls "${DDNS_PACKAGE_DIR}/custom"
	else
		echo "No custom services installed"
		exit 4
	fi
}

action_install() {
	local service="$1"

	local url cacert

	config_load ddns
	config_get url global 'url' "${URL}${DDNS_PACKAGE_DIR}/default"
	config_get cacert global 'cacert' "IGNORE"
	url="${url}/${service}.json"

	if [ -z "$service" ]; then
		usage "4" "No custom service specified"
	fi

	mkdir -p "${DDNS_PACKAGE_DIR}/custom"

	if [ "$cacert" = "IGNORE" ]; then
		uclient-fetch \
			--no-check-certificate \
			"${url}" \
			-O "${DDNS_PACKAGE_DIR}/custom/${service}.json"
	elif [ -f "$cacert" ]; then
		uclient-fetch \
			--ca-certifcate="${cacert}" \
			"${url}" \
			-O "${DDNS_PACKAGE_DIR}/custom/${service}.json"
	elif [ -n "$cacert" ]; then
		echo "Certification file not found ($cacert)"
		exit 5
	fi
}

action_remove() {
	local service="$1"
	if [ -z "$service" ]; then
		usage "4" "No custom service specified"
	fi

	rm "${DDNS_PACKAGE_DIR}/custom/${service}.json"
}

action_purge() {
	rm -rf "${DDNS_PACKAGE_DIR}/custom"
	rm -rf "${DDNS_PACKAGE_DIR}/list"
}

sub_service() {
	local action="$1"
	local service="$2"

	case "$action" in
		update)
			action_update
			;;
		list-available)
			action_list_available
			;;
		list-installed)
			action_list_installed
			;;
		purge)
			action_purge
			;;
		install)
			action_install "$service"
			;;
		remove)
			action_remove "$service"
			;;
		*)
			usage "2" "Action not supported"
			;;
	esac
}

main() {
	local cmd="$1"
	local action="$2"
	local service="$3"

	[ "$#" -eq 0 ] && usage "1"

	case "${cmd}" in
		service)
			sub_service "${action}" "${service}"
			;;
		*)
			usage "1" "Command not supported"
			;;
	esac
}

main "$@"
