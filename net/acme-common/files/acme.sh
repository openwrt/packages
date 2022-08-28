#!/bin/sh
# Wrapper for acme.sh to work on openwrt.
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Authors: Toke Høiland-Jørgensen <toke@toke.dk>

export state_dir='/etc/acme'
export account_email=
export debug=0
export challenge_dir='/var/run/acme/challenge'
NFT_HANDLE=
HOOK=/usr/lib/acme/hook
LOG_TAG=acme

# shellcheck source=/dev/null
. /lib/functions.sh
# shellcheck source=net/acme/files/functions.sh
. /usr/lib/acme/functions.sh

cleanup() {
	log debug "cleaning up"
	if [ "$NFT_HANDLE" ]; then
		# $NFT_HANDLE contains the string 'handle XX' so pass it unquoted to nft
		nft delete rule inet fw4 input $NFT_HANDLE
	fi
}

load_options() {
	section=$1

	# compatibility for old option name
	config_get_bool use_staging "$section" staging
	if [ -z "$staging" ]; then
		config_get_bool staging "$section" staging 0
	fi
	export staging
	config_get calias "$section" calias
	export calias
	config_get dalias "$section" dalias
	export dalias
	config_get domains "$section" domains
	export domains
	export main_domain
	main_domain="$(first_arg $domains)"
	config_get keylength "$section" keylength ec-256
	export keylength
	config_get dns "$section" dns
	export dns
	config_get acme_server "$section" acme_server
	export acme_server
	config_get days "$section" days
	export days
	config_get standalone "$section" standalone 0
	export standalone

	config_get webroot "$section" webroot
	export webroot
	if [ "$webroot" ]; then
		log warn "Option \"webroot\" is deprecated, please remove it and change your web server's config so it serves ACME challenge requests from /var/run/acme/challenge."
	fi
}

first_arg() {
	echo "$1"
}

get_cert() {
	section=$1

	config_get_bool enabled "$section" enabled 1
	[ "$enabled" = 1 ] || return

	load_options "$section"
	if [ -z "$dns" ] && [ "$standalone" = 0 ]; then
		mkdir -p "$challenge_dir"
	fi

	if [ "$standalone" = 1 ] && [ -z "$NFT_HANDLE" ]; then
		if ! NFT_HANDLE=$(nft -a -e insert rule inet fw4 input tcp dport 80 counter accept comment ACME | grep -o 'handle [0-9]\+'); then
			return 1
		fi
		log debug "added nft rule: $NFT_HANDLE"
	fi

	load_credentials() {
		eval export "$1"
	}
	config_list_foreach "$section" credentials load_credentials

	"$HOOK" get
}

load_globals() {
	section=$1

	config_get account_email "$section" account_email
	if [ -z "$account_email" ]; then
		log err "account_email option is required"
		exit 1
	fi

	config_get state_dir "$section" state_dir "$state_dir"
	mkdir -p "$state_dir"

	config_get debug "$section" debug "$debug"

	# only look for the first acme section
	return 1
}

usage() {
	cat <<EOF
Usage: acme <command> [arguments]
Commands:
	get                issue or renew certificates
	cert <domain>      show certificate matching domain
EOF
	exit 1
}

if [ ! -x "$HOOK" ]; then
	log err "An ACME client like acme-acmesh or acme-uacme is required, which is not installed."
	exit 1
fi

case $1 in
get)
	config_load acme
	config_foreach load_globals acme

	mkdir -p /etc/ssl/acme
	trap cleanup EXIT
	config_foreach get_cert cert
	;;
*)
	usage
	;;
esac
