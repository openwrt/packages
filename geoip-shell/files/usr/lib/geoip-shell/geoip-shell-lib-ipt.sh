#!/bin/sh

curr_ver=0.4.7

# Copyright: antonk (antonk.d3v@gmail.com)
# github.com/friendly-bits

set_ipt_cmds() {
	case "$family" in ipv4) f='' ;; ipv6) f=6 ;; *) echolog -err "set_ipt_cmds: Unexpected family '$family'."; return 1; esac
	ipt_cmd="ip${f}tables -t $ipt_table"; ipt_save_cmd="ip${f}tables-save -t $ipt_table"; ipt_restore_cmd="ip${f}tables-restore -n"
}

filter_ipt_rules() {
	grep "$1" | grep -o "$2.* \*/"
}

get_ipsets() {
	ipset list -t
}

print_ipset_elements() {
	get_matching_line "$ipsets" "*" "$1" "*" ipset &&
		ipset list "${1}_$geotag" | sed -n -e /"Members:"/\{:1 -e n\; -e p\; -e b1\; -e \} | tr '\n' ' '
}

cnt_ipset_elements() {
	printf %s "$ipsets" |
		sed -n -e /"$1"/\{:1 -e n\;/maxelem/\{s/.*maxelem\ //\; -e s/\ .*//\; -e p\; -e q\; -e \}\;b1 -e \} |
			grep . || echo 0
}

rm_ipt_rules() {
	printf %s "Removing $family iptables rules tagged '$1'... "
	set_ipt_cmds

	{ echo "*$ipt_table"; eval "$ipt_save_cmd" | sed -n "/$1/"'s/^-A /-D /p'; echo "COMMIT"; } |
		eval "$ipt_restore_cmd" ||
		{ FAIL; echolog -err "rm_ipt_rules: $FAIL remove firewall rules tagged '$1'."; return 1; }
	OK
}

rm_all_georules() {
	for family in ipv4 ipv6; do
		rm_ipt_rules "${geotag}_enable"
		ipt_state="$(eval "$ipt_save_cmd")"
		printf '%s\n' "$ipt_state" | grep "$iface_chain" >/dev/null && {
			printf %s "Removing $family chain '$iface_chain'... "
			printf '%s\n%s\n%s\n%s\n' "*$ipt_table" "-F $iface_chain" "-X $iface_chain" "COMMIT" |
				eval "$ipt_restore_cmd" && OK || { FAIL; return 1; }
		}
		printf '%s\n' "$ipt_state" | grep "$geochain" >/dev/null && {
			printf %s "Removing $family chain '$geochain'... "
			printf '%s\n%s\n%s\n%s\n' "*$ipt_table" "-F $geochain" "-X $geochain" "COMMIT" | eval "$ipt_restore_cmd" && OK ||
				{ FAIL; return 1; }
		}
	done
	rm_ipsets_rv=0
	unisleep
	printf %s "Destroying ipsets tagged '$geotag'... "
	for ipset in $(ipset list -n | grep "$geotag"); do
		ipset destroy "$ipset" || rm_ipsets_rv=1
	done
	[ "$rm_ipsets_rv" = 0 ] && OK || FAIL
	return "$rm_ipsets_rv"
}

get_fwrules_iplists() {
	p="$p_name" t="$ipt_target"
	{ iptables-save -t "$ipt_table"; ip6tables-save -t "$ipt_table"; } |
		sed -n "/match-set .*$p.* -j $t/{s/.*match-set //;s/_$p.*//;p}" | grep -vE "(lan_ips_|trusted_)"
}

get_ipset_iplists() {
	get_ipsets | sed -n /"$geotag"/\{s/_"$geotag"//\;s/^Name:\ //\;p\} | grep -vE "(lan_ips_|trusted_)"
}

ipt_table=mangle
iface_chain="${geochain}_WAN"
