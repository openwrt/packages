#!/bin/sh

curr_ver=0.4.7

# Copyright: antonk (antonk.d3v@gmail.com)
# github.com/friendly-bits

get_nft_family() {
	nft_family="${family%ipv4}"; nft_family="ip${nft_family#ipv}"
}

is_geochain_on() {
	get_matching_line "$(nft_get_chain "$base_geochain" "$1")" "*" "${geotag}_enable" "*" test; rv=$?
	return $rv
}

nft_get_geotable() {
	[ "$1" != "-f" ] && [ -n "$_geotable_cont" ] && { printf '%s\n' "$_geotable_cont"; return 0; }
	export _geotable_cont="$(nft -ta list ruleset inet | sed -n -e /"^table inet $geotable"/\{:1 -e n\;/^\}/q\;p\;b1 -e \})"
	[ -z "$_geotable_cont" ] && return 1 || { printf '%s\n' "$_geotable_cont"; return 0; }
}

nft_get_chain() {
	_chain_cont="$(nft_get_geotable "$2" | sed -n -e /"chain $1 {"/\{:1 -e n\;/"^[[:space:]]*}"/q\;p\;b1 -e \})"
	[ -z "$_chain_cont" ] && return 1 || { printf '%s\n' "$_chain_cont"; return 0; }
}

rm_all_georules() {
	printf %s "Removing firewall geoip rules... "
	nft_get_geotable -f 1>/dev/null 2>/dev/null || return 0
	nft delete table inet "$geotable" || { echolog -err -nolog "$FAIL delete table '$geotable'."; return 1; }
	export _geotable_cont=
	OK
}

mk_nft_rm_cmd() {
	chain="$1"; _chain_cont="$2"; shift 2
	[ ! "$chain" ] || [ ! "$*" ] && return 1
	for tag in "$@"; do
		printf '%s\n' "$_chain_cont" | sed -n "/$tag/"'s/^.* # handle/'"delete rule inet $geotable $chain handle"'/p' || return 1
	done
}

get_nft_list() {
	n=0; _res=
	[ "$1" = '!=' ] && { _res='!='; shift; n=$((n+1)); }
	case "$1" in
		'{')
			while true; do
				shift; n=$((n+1))
				[ "$1" = '}' ] && break
				_res="$_res$1"
			done ;;
		*) _res="$_res$1"
	esac
}

get_fwrules_iplists() {
	nft_get_geotable "$force_read" |
		sed -n "/saddr[[:space:]]*@.*${geotag}.*$nft_verdict/{s/.*@//;s/_.........._${geotag}.*//p}"
}

get_ipset_id() {
	list_id="${1%_"$geotag"}"
	list_id="${list_id%_*}"
	family="${list_id#*_}"
	case "$family" in
		ipv4|ipv6) return 0 ;;
		*) echolog -err "ip set name '$1' has unexpected format."
			unset family list_id
			return 1
	esac
}

get_ipsets() {
	nft -t list sets inet | grep -o "[a-zA-Z0-9_-]*_$geotag"
}

get_ipset_iplists() {
	nft -t list sets inet | sed -n "/$geotag/{s/.*set[[:space:]]*//;s/_.........._${geotag}.*//p}"
}

get_ipset_elements() {
    get_matching_line "$ipsets" "" "$1" "*" ipset
    [ "$ipset" ] && nft list set inet "$geotable" "$ipset" |
        sed -n -e /"elements[[:space:]]*=/{s/elements[[:space:]]*=[[:space:]]*{//;:1" -e "/}/{s/}//"\; -e p\; -e q\; -e \}\; -e p\; -e n\;b1 -e \}
}

cnt_ipset_elements() {
    get_matching_line "$ipsets" "" "$1" "*" ipset
    [ ! "$ipset" ] && { echo 0; return 1; }
    get_ipset_elements "$1" | wc -w
}

print_ipset_elements() {
	get_ipset_elements "$1" | awk '{gsub(",", "");$1=$1};1' ORS=' '
}

geotable="$geotag"
base_geochain="GEOIP-BASE"
