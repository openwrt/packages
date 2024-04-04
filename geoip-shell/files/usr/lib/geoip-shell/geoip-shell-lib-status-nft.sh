#!/bin/sh

curr_ver=0.4.7

# Copyright: antonk (antonk.d3v@gmail.com)
# github.com/friendly-bits

report_fw_state() {
	curr_geotable="$(nft_get_geotable)" ||
		{ printf '%s\n' "$FAIL read the firewall state or firewall table $geotable does not exist." >&2; incr_issues; }

	wl_rule="$(printf %s "$curr_geotable" | grep "drop comment \"${geotag}_whitelist_block\"")"

	is_geochain_on && chain_status="${green}enabled $_V" || { chain_status="${red}disabled $_X"; incr_issues; }
	printf '%s\n' "Geoip firewall chain: $chain_status"
	[ "$geomode" = whitelist ] && {
		case "$wl_rule" in
			'') wl_rule_status="$_X"; incr_issues ;;
			*) wl_rule_status="$_V"
		esac
		printf '%s\n' "Whitelist blocking rule: $wl_rule_status"
	}

	if [ "$verb_status" ]; then
		dashes="$(printf '%158s' ' ' | tr ' ' '-')"
		fmt_str="%-9s%-11s%-5s%-8s%-5s%-24s%-33s%s\n"
		printf "\n%s\n%s\n${fmt_str}%s\n" "${purple}Firewall rules in the $geochain chain${n_c}:" \
			"$dashes${blue}" packets bytes ipv verdict prot dports interfaces extra "$n_c$dashes"
		rules="$(nft_get_chain "$geochain" | sed 's/^[[:space:]]*//;s/ # handle.*//' | grep .)" ||
			{ printf '%s\n' "${red}None $_X"; incr_issues; }
		newifs "$_nl" rules
		for rule in $rules; do
			newifs ' "' wrds
			set -- $rule
			case "$families" in "ipv4 ipv6"|"ipv6 ipv4") dfam="both" ;; *) dfam="$families"; esac
			pkts='---'; bytes='---'; ipv="$dfam"; verd='---'; prot='all'; dports='all'; in='all'; line=''
			while [ -n "$1" ]; do
				case "$1" in
					iifname) shift; get_nft_list "$@"; in="$_res"; shift "$n" ;;
					ip) ipv="ipv4" ;;
					ip6) ipv="ipv6" ;;
					dport) shift; get_nft_list "$@"; dports="$_res"; shift "$n" ;;
					udp|tcp) prot="$1 " ;;
					packets) pkts=$(num2human $2); shift ;;
					bytes) bytes=$(num2human $2 bytes); shift ;;
					counter) ;;
					accept) verd="ACCEPT" ;;
					drop) verd="DROP  " ;;
					*) line="$line$1 "
				esac
				shift
			done
			printf "$fmt_str" "$pkts " "$bytes " "$ipv " "$verd " "$prot " "$dports " "$in " "${line% }"
		done
		oldifs rules
		echo
	fi
}
