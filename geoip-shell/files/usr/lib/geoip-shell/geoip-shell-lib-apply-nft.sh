#!/bin/sh

curr_ver=0.4.7

# Copyright: antonk (antonk.d3v@gmail.com)
# github.com/friendly-bits

. "$_lib-nft.sh" || exit 1

die_a() {
	echolog -err "$*"
	echo "Destroying temporary ipsets..."
	for new_ipset in $new_ipsets; do
		nft delete set inet "$geotable" "$new_ipset" 1>/dev/null 2>/dev/null
	done
	die 254
}

case "$geomode" in
	whitelist) iplist_verdict="accept" ;;
	blacklist) iplist_verdict="drop" ;;
	*) die "Unknown firewall mode '$geomode'."
esac

: "${nft_perf:=memory}"

nft_get_geotable -f 1>/dev/null
geochain_on=
is_geochain_on && geochain_on=1
geochain_cont="$(nft_get_chain "$geochain")"
base_chain_cont="$(nft_get_chain "$base_geochain")"

case "$action" in
	off) [ -z "$geochain_on" ] && { echo "Geoip chain is already switched off."; exit 0; }
		printf %s "Removing the geoip enable rule... "
		mk_nft_rm_cmd "$base_geochain" "$base_chain_cont" "${geotag}_enable" | nft -f -; rv=$?
		[ $rv != 0 ] || is_geochain_on -f && { FAIL; die "$FAIL remove firewall rule."; }
		OK
		exit 0 ;;
	on) [ -n "$geochain_on" ] && { echo "Geoip chain is already switched on."; exit 0; }
		[ -z "$base_chain_cont" ] && missing_chain="base geoip"
		[ -z "$geochain_cont" ] && missing_chain="geoip"
		[ -n "$missing_chain" ] && { echo "Can't switch geoip on because $missing_chain chain is missing."; exit 1; }

		printf %s "Adding the geoip enable rule... "
		printf '%s\n' "add rule inet $geotable $base_geochain jump $geochain comment ${geotag}_enable" | nft -f -; rv=$?
		[ $rv != 0 ] || ! is_geochain_on -f && { FAIL; die "$FAIL add firewall rule."; }
		OK
		exit 0
esac

[ ! "$list_ids" ] && [ "$action" != update ] && {
	usage
	die 254 "Specify iplist id's!"
}

unset old_ipsets new_ipsets
curr_ipsets="$(nft -t list sets inet | grep "$geotag")"

getstatus "$status_file" || die "$FAIL read the status file '$status_file'."

for list_id in $list_ids; do
	case "$list_id" in *_*) ;; *) die "Invalid iplist id '$list_id'."; esac
	family="${list_id#*_}"
	iplist_file="${iplist_dir}/${list_id}.iplist"
	eval "list_date=\"\$prev_date_${list_id}\""
	[ ! "$list_date" ] && die "$FAIL read value for 'prev_date_${list_id}' from file '$status_file'."
	ipset="${list_id}_${list_date}_${geotag}"
	case "$curr_ipsets" in
		*"$ipset"* ) [ "$action" = add ] && { echo "Ip set for '$list_id' is already up-to-date."; continue; }
			old_ipsets="$old_ipsets$ipset " ;;
		*"$list_id"* )
			get_matching_line "$curr_ipsets" "*" "$list_id" "*" ipset_line
			n="${ipset_line#*set }"
			old_ipset="${n%"_$geotag"*}_$geotag"
			old_ipsets="$old_ipsets$old_ipset "
	esac
	[ "$action" = "add" ] && new_ipsets="$new_ipsets$ipset "
done

nft add table inet $geotable || die "$FAIL create table '$geotable'"

for new_ipset in $new_ipsets; do
	printf %s "Adding ip set '$new_ipset'... "
	get_ipset_id "$new_ipset" || die_a
	iplist_file="${iplist_dir}/${list_id}.iplist"
	[ ! -f "$iplist_file" ] && die_a "Can not find the iplist file '$iplist_file'."

	[ "$debugmode" ] && ip_cnt="$(tr ',' ' ' < "$iplist_file" | wc -w)"
	

	{
		printf %s "add set inet $geotable $new_ipset { type ${family}_addr; flags interval; auto-merge; policy $nft_perf; "
		cat "$iplist_file"
		printf '%s\n' "; }"
	} | nft -f - || die_a "$FAIL import the iplist from '$iplist_file' into ip set '$new_ipset'."
	OK

	
done

opt_ifaces=
[ "$ifaces" != all ] && opt_ifaces="iifname { $(printf '%s, ' $ifaces) }"
georule="rule inet $geotable $geochain $opt_ifaces"

printf %s "Assembling nftables commands... "
nft_cmd_chain="$(
	rv=0

	printf '%s\n%s\n' "add chain inet $geotable $base_geochain { type filter hook prerouting priority mangle; policy accept; }" \
		"add chain inet $geotable $geochain"

	mk_nft_rm_cmd "$geochain" "$geochain_cont" "${geotag}_whitelist_block" "${geotag_aux}" || exit 1

	mk_nft_rm_cmd "$base_geochain" "$base_chain_cont" "${geotag}_enable" || exit 1

	for old_ipset in $old_ipsets; do
		mk_nft_rm_cmd "$geochain" "$geochain_cont" "$old_ipset" || exit 1
		printf '%s\n' "delete set inet $geotable $old_ipset"
	done

	for family in $families; do
		nft_get_geotable | grep "trusted_${family}_${geotag}" >/dev/null &&
			printf '%s\n' "delete set inet $geotable trusted_${family}_${geotag}"
		eval "trusted=\"\$trusted_$family\""
		interval=
		case "${trusted%%":"*}" in net|ip)
			[ "${trusted%%":"*}" = net ] && interval="flags interval; auto-merge;"
			trusted="${trusted#*":"}"
		esac

		[ -n "$trusted" ] && {
			get_nft_family
			printf %s "add set inet $geotable trusted_${family}_${geotag} \
				{ type ${family}_addr; $interval elements={ "
			printf '%s,' $trusted
			printf '%s\n' " }; }"
			printf '%s\n' "insert $georule $nft_family saddr @trusted_${family}_${geotag} accept comment ${geotag_aux}_trusted"
		}
	done

	if [ "$geomode" = "whitelist" ]; then
		for family in $families; do
			if [ ! "$autodetect" ]; then
				eval "lan_ips=\"\$lan_ips_$family\""
			else
				a_d_failed=
				lan_ips="$(call_script "${i_script}-detect-lan.sh" -s -f "$family")" || a_d_failed=1
				[ ! "$lan_ips" ] || [ "$a_d_failed" ] && { echolog -err "$FAIL detect $family LAN subnets."; exit 1; }
				nl2sp lan_ips "net:$lan_ips"
				eval "lan_ips_$family=\"$lan_ips\""
			fi

			nft_get_geotable | grep "lan_ips_${family}_${geotag}" >/dev/null &&
				printf '%s\n' "delete set inet $geotable lan_ips_${family}_${geotag}"
			interval=
			[ "${lan_ips%%":"*}" = net ] && interval="flags interval; auto-merge;"
			lan_ips="${lan_ips#*":"}"
			[ -n "$lan_ips" ] && {
				get_nft_family
				printf %s "add set inet $geotable lan_ips_${family}_${geotag} \
					{ type ${family}_addr; $interval elements={ "
				printf '%s,' $lan_ips
				printf '%s\n' " }; }"
				printf '%s\n' "insert $georule $nft_family saddr @lan_ips_${family}_${geotag} accept comment ${geotag_aux}_lan"
			}
		done
		[ "$autodetect" ] && setconfig lan_ips_ipv4 lan_ips_ipv6
	fi

	[ "$geomode" = whitelist ] && [ "$ifaces" != all ] && {
		printf '%s\n' "insert $georule ip6 saddr fc00::/6 ip6 daddr fc00::/6 udp dport 546 counter accept comment ${geotag_aux}_DHCPv6"
		printf '%s\n' "insert $georule ip6 saddr fe80::/8 counter accept comment ${geotag_aux}_link-local"

	}

	for proto in tcp udp; do
		eval "ports_exp=\"\${${proto}_ports%:*}\" ports=\"\${${proto}_ports##*:}\""
		eval "proto_ports=\"\$${proto}_ports\""
		
		[ "$ports_exp" = skip ] && continue
		if [ "$ports_exp" = all ]; then
			ports_exp="meta l4proto $proto"
		else
			ports_exp="$proto $(printf %s "$ports_exp" | sed "s/multiport //;s/!dport/dport !=/") { $ports }"
		fi
		printf '%s\n' "insert $georule $ports_exp counter accept comment ${geotag_aux}_ports"
	done

	printf '%s\n' "insert $georule ct state established,related accept comment ${geotag_aux}_est-rel"

	[ "$geomode" = "whitelist" ] && [ "$ifaces" = all ] &&
		printf '%s\n' "insert rule inet $geotable $geochain iifname lo accept comment ${geotag_aux}-loopback"

	for new_ipset in $new_ipsets; do
		get_ipset_id "$new_ipset" || exit 1
		get_nft_family
		printf '%s\n' "add $georule $nft_family saddr @$new_ipset counter $iplist_verdict"
	done

	[ "$geomode" = whitelist ] && printf '%s\n' "add $georule counter drop comment ${geotag}_whitelist_block"

	[ -z "$noblock" ] && printf '%s\n' "add rule inet $geotable $base_geochain jump $geochain comment ${geotag}_enable"

	exit 0
)" || die_a 254 "$FAIL assemble nftables commands."
OK

printf %s "Applying new firewall rules... "
printf '%s\n' "$nft_cmd_chain" | nft -f - || die_a "$FAIL apply new firewall rules"
OK

[ -n "$noblock" ] && echolog -warn "Geoip blocking is disabled via config."

echo

:
