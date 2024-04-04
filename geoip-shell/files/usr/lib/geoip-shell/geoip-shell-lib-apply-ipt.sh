#!/bin/sh

curr_ver=0.4.7

# Copyright: antonk (antonk.d3v@gmail.com)
# github.com/friendly-bits

. "$_lib-ipt.sh" || exit 1

die_a() {
	destroy_tmp_ipsets
	set +f; rm "$iplist_dir/"*.iplist 2>/dev/null; set -f
	die "$@"
}

critical() {
	echo "Failed." >&2
	echolog -err "Removing geoip rules..."
	rm_all_georules
	set +f; rm "$iplist_dir/"*.iplist 2>/dev/null; set -f
	die "$1"
}

destroy_tmp_ipsets() {
	echolog -err "Destroying temporary ipsets..."
	for tmp_ipset in $(ipset list -n | grep "$p_name" | grep "temp"); do
		ipset destroy "$tmp_ipset" 1>/dev/null 2>/dev/null
	done
}

enable_geoip() {
	[ "$ifaces" != all ] && first_chain="$iface_chain" || first_chain="$geochain"
	for family in $families; do
		set_ipt_cmds || die_a
		enable_rule="$(eval "$ipt_save_cmd" | grep "${geotag}_enable")"
		[ ! "$enable_rule" ] && {
			printf %s "Inserting the enable geoip $family rule... "
			eval "$ipt_cmd" -I PREROUTING -j "$first_chain" $ipt_comm "${geotag}_enable" || critical "$insert_failed"
			OK
		} || printf '%s\n' "Geoip is already enabled for $family."
	done
}

mk_ipt_rm_cmd() {
	for tag in "$@"; do
		printf '%s\n' "$curr_ipt"  | sed -n "/$tag/"'s/^-A /-D /p' || return 1
	done
}

add_ipset() {
	perm_ipset="$1"; tmp_ipset="${1}_temp"; iplist_file="$2"; ipset_type="$3"
	[ ! -f "$iplist_file" ] && critical "Can not find the iplist file in path: '$iplist_file'."

	ipset destroy "$tmp_ipset" 1>/dev/null 2>/dev/null

	ip_cnt=$(wc -w < "$iplist_file")

	ipset_hs=$((ip_cnt / 2))
	[ $ipset_hs -lt 1024 ] && ipset_hs=1024
	

	
	ipset create "$tmp_ipset" hash:$ipset_type family "$family" hashsize "$ipset_hs" maxelem "$ip_cnt" ||
		crtical "$FAIL create ipset '$tmp_ipset'."
	

	
	sed "s/^/add \"$tmp_ipset\" /" "$iplist_file" | ipset restore -exist ||
		critical "$FAIL import the iplist from '$iplist_file' into ipset '$tmp_ipset'."
	

	

	
	ipset swap "$tmp_ipset" "$perm_ipset" || critical "$FAIL swap temporary and permanent ipsets."
	
	rm "$iplist_file"
}

mk_perm_ipset() {
	perm_ipset="$1"; ipset_type="$2"; tmp_ipset="${perm_ipset}_temp"
	case "$curr_ipsets" in *"$perm_ipset"* ) ;; *)
		
		ipset create "$perm_ipset" hash:$ipset_type family "$family" hashsize 1 maxelem 1 ||
			die_a "$FAIL create ipset '$perm_ipset'."
		
	esac
}

get_curr_ipsets() {
	curr_ipsets="$(ipset list -n | grep "$p_name")"
}

rm_ipset() {
	[ ! "$1" ] && return 0
	case "$curr_ipsets" in
		*"$1"* )
			
			ipset destroy "$1"; rv=$?
			case "$rv" in
				0)  ;;
				*) 
			esac
	esac
}

case "$geomode" in
	whitelist) fw_target=ACCEPT ;;
	blacklist) fw_target=DROP ;;
	*) die "Unknown firewall mode '$geomode'."
esac

retval=0

insert_failed="$FAIL insert a firewall rule."
ipt_comm="-m comment --comment"

ipsets_to_rm=

case "$action" in
	off)
		for family in $families; do
			set_ipt_cmds || die
			enable_rule="$(eval "$ipt_save_cmd" | grep "${geotag}_enable")"
			if [ "$enable_rule" ]; then
				rm_ipt_rules "${geotag}_enable" || critical
			else
				printf '%s\n' "Geoip is already disabled for $family."
			fi
		done
		exit 0 ;;
	on) enable_geoip; exit 0
esac

[ ! "$list_ids" ] && [ "$action" != update ] && {
	usage
	die 254 "Specify iplist id's!"
}

get_curr_ipsets

for family in $families; do
	set_ipt_cmds || die_a
	curr_ipt="$(eval "$ipt_save_cmd")" || die_a "$FAIL read iptables rules."

	t_ipset="trusted_${family}_${geotag}"
	lan_ipset="lan_ips_${family}_${geotag}"
	rm_ipt_rules "$t_ipset" >/dev/null
	rm_ipt_rules "$lan_ipset" >/dev/null
	unisleep
	rm_ipset "$t_ipset"
	rm_ipset "$lan_ipset"

	get_curr_ipsets
	curr_ipt="$(eval "$ipt_save_cmd")" || die_a "$FAIL read iptables rules."

	ipsets_to_add=

	for list_id in $list_ids; do
		case "$list_id" in *_*) ;; *) die_a "Invalid iplist id '$list_id'."; esac
		[ "${list_id#*_}" != "$family" ] && continue
		perm_ipset="${list_id}_$geotag"
		if [ "$action" = add ]; then
			iplist_file="${iplist_dir}/${list_id}.iplist"
			mk_perm_ipset "$perm_ipset" net
			ipsets_to_add="$ipsets_to_add$perm_ipset $iplist_file$_nl"
		elif [ "$action" = remove ]; then
			ipsets_to_rm="$ipsets_to_rm$perm_ipset "
		fi
	done

	eval "trusted=\"\$trusted_$family\""
	ipset_type=net
	case "${trusted%%":"*}" in net|ip)
		ipset_type="${trusted%%":"*}"
		trusted="${trusted#*":"}"
	esac

	[ -n "$trusted" ] && {
		iplist_file="$iplist_dir/$t_ipset.iplist"
		sp2nl trusted
		printf '%s\n' "$trusted" > "$iplist_file" || die_a "$FAIL write to file '$iplist_file'"
		mk_perm_ipset "$t_ipset" "$ipset_type"
		ipsets_to_add="$ipsets_to_add$ipset_type:$t_ipset $iplist_file$_nl"
	}

	[ "$geomode" = whitelist ] && {
		if [ ! "$autodetect" ]; then
			eval "lan_ips=\"\$lan_ips_$family\""
			sp2nl lan_ips
		else
			a_d_failed=
			lan_ips="$(call_script "${i_script}-detect-lan.sh" -s -f "$family")" || a_d_failed=1
			[ ! "$lan_ips" ] || [ "$a_d_failed" ] && { echolog -err "$FAIL detect $family LAN subnets."; exit 1; }
			lan_ips="net:$lan_ips"
			nl2sp "lan_ips_$family" "$lan_ips"
		fi

		ipset_type="${lan_ips%%":"*}"
		lan_ips="${lan_ips#*":"}"
		[ -n "$lan_ips" ] && {
			iplist_file="$iplist_dir/$lan_ipset.iplist"
			printf '%s\n' "$lan_ips" > "$iplist_file" || die_a "$FAIL write to file '$iplist_file'"
			mk_perm_ipset "$lan_ipset" "$ipset_type"
			ipsets_to_add="$ipsets_to_add$ipset_type:$lan_ipset $iplist_file$_nl"
		}
	}

	printf %s "Assembling new $family firewall rules... "
	set_ipt_cmds || die_a

	iptr_cmd_chain="$(
		rv=0

		printf '%s\n' "*$ipt_table"

		mk_ipt_rm_cmd "${geotag}_enable" "${geotag_aux}" "${geotag}_whitelist_block" "${geotag}_iface_filter" || rv=1

		for list_id in $list_ids; do
			[ "$family" != "${list_id#*_}" ] && continue
			list_tag="${list_id}_${geotag}"
			mk_ipt_rm_cmd "$list_tag" || rv=1
		done

		case "$curr_ipt" in *":$geochain "*) ;; *) printf '%s\n' ":$geochain -"; esac

		if [ "$ifaces" != all ]; then
			case "$curr_ipt" in *":$iface_chain "*) ;; *) printf '%s\n' ":$iface_chain -"; esac
			for _iface in $ifaces; do
				printf '%s\n' "-i $_iface -I $iface_chain -j $geochain $ipt_comm ${geotag}_iface_filter"
			done
		fi

		[ "$trusted" ] &&
			printf '%s\n' "-I $geochain -m set --match-set trusted_${family}_${geotag} src $ipt_comm trusted_${family}_${geotag_aux} -j ACCEPT"

		[ "$geomode" = whitelist ] && [ "$lan_ips" ] &&
			printf '%s\n' "-I $geochain -m set --match-set lan_ips_${family}_${geotag} src $ipt_comm lan_ips_${family}_${geotag_aux} -j ACCEPT"

		[ "$geomode" = whitelist ] && [ "$ifaces" != all ] && {
			if [ "$family" = ipv6 ]; then
				printf '%s\n' "-I $geochain -s fc00::/6 -d fc00::/6 -p udp -m udp --dport 546 $ipt_comm ${geotag_aux}_DHCPv6 -j ACCEPT"
				printf '%s\n' "-I $geochain -s fe80::/8 $ipt_comm ${geotag_aux}_link-local -j ACCEPT"
			fi
		}

		for proto in tcp udp; do
			eval "ports_exp=\"\${${proto}_ports%:*}\" ports=\"\${${proto}_ports##*:}\""
			[ "$ports_exp" = skip ] && continue
			if [ "$ports_exp" = all ]; then
				ports_exp=
			else
				dport='--dport'
				case "$ports_exp" in *multiport*) dport='--dports'; esac
				ports="$(printf %s "$ports" | sed 's/-/:/g')"
				ports_exp="$(printf %s "$ports_exp" | sed "s/all//;s/multiport/-m multiport/;s/!/! /;s/dport/$dport/") $ports"
			fi
			printf '%s\n' "-I $geochain -p $proto $ports_exp -j ACCEPT $ipt_comm ${geotag_aux}_ports"
		done

		printf '%s\n' "-I $geochain -m conntrack --ctstate RELATED,ESTABLISHED $ipt_comm ${geotag_aux}_rel-est -j ACCEPT"

		[ "$geomode" = whitelist ] && [ "$ifaces" = all ] &&
			printf '%s\n' "-I $geochain -i lo $ipt_comm ${geotag_aux}-lo -j ACCEPT"

		if [ "$action" = add ]; then
			for list_id in $list_ids; do
				[ "$family" != "${list_id#*_}" ] && continue
				perm_ipset="${list_id}_${geotag}"
				list_tag="${list_id}_${geotag}"
				printf '%s\n' "-A $geochain -m set --match-set $perm_ipset src $ipt_comm $list_tag -j $fw_target"
			done
		fi

		[ "$geomode" = whitelist ] && printf '%s\n' "-A $geochain $ipt_comm ${geotag}_whitelist_block -j DROP"

		echo "COMMIT"
		exit "$rv"
	)" || die_a "$FAIL assemble commands for iptables-restore"
	OK

	printf %s "Applying new $family firewall rules... "
	printf '%s\n' "$iptr_cmd_chain" | eval "$ipt_restore_cmd" || critical "$FAIL apply new iptables rules"
	OK

	[ -n "$ipsets_to_add" ] && {
		printf %s "Adding $family ipsets... "
		newifs "$_nl" apply
		for entry in ${ipsets_to_add%"$_nl"}; do
			ipset_type=net
			case "$entry" in "ip:"*|"net:"*) ipset_type="${entry%%":"*}"; entry="${entry#*":"}"; esac
			add_ipset "${entry%% *}" "${entry#* }" "$ipset_type"
			ipsets_to_rm="$ipsets_to_rm${entry%% *}_temp "
		done
		oldifs apply
		OK; echo
	}
done

[ -n "$ipsets_to_rm" ] && {
	printf %s "Removing old ipsets... "
	get_curr_ipsets
	unisleep
	for ipset in $ipsets_to_rm; do
		rm_ipset "$ipset"
	done
	[ "$retval" = 0 ] && OK
	echo
}

case "$noblock" in
	'') enable_geoip ;;
	*) echolog -warn "Geoip blocking is disabled via config."
esac

[ "$autodetect" ] && setconfig lan_ips_ipv4 lan_ips_ipv6

echo

return "$retval"
