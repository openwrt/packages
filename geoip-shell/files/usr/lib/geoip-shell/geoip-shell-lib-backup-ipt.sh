#!/bin/sh

curr_ver=0.4.7

# Copyright: antonk (antonk.d3v@gmail.com)
# github.com/friendly-bits

. "$_lib-ipt.sh" || die

restorebackup() {
	get_iptables_bk() {
		sed -n -e /"\[${p_name}_IPTABLES_$family\]"/\{:1 -e n\;/\\["${p_name}_IP"/q\;p\;b1 -e \} < "$tmp_file"
	}
	get_ipset_bk() { sed -n "/create .*${p_name}/,\$p" < "$tmp_file"; }

	printf '%s\n' "Restoring firewall state from backup... "

	bk_file="${bk_dir}/${p_name}_backup.${bk_ext:-bak}"
	[ -z "$bk_file" ] && die "Can not restore the firewall state: no backup found."
	[ ! -f "$bk_file" ] && die "Can not find the backup file '$bk_file'."

	tmp_file="/tmp/${p_name}_backup.tmp"
	$extract_cmd "$bk_file" > "$tmp_file" || rstr_failed "$FAIL extract backup file '$bk_file'."
	[ ! -s "$tmp_file" ] && rstr_failed "backup file '$bk_file' is empty or backup extraction failed."

	printf '%s\n\n' "Successfully read backup file: '$bk_file'."

	printf %s "Checking the iptables portion of the backup file... "

	for family in $families; do
		line_cnt=$(get_iptables_bk | wc -l)
		
		[ "$line_cnt" -lt 2 ] && rstr_failed "firewall $family backup appears to be empty or non-existing."
	done
	OK

	printf %s "Checking the ipset portion of the backup file... "
	get_ipset_bk | grep "add .*$p_name" 1>/dev/null || rstr_failed "ipset backup appears to be empty or non-existing."
	OK

	rm_all_georules || rstr_failed "$FAIL remove firewall rules and ipsets."

	for restoretgt in ipset iptables; do
		printf %s "Restoring $restoretgt state... "
		case "$restoretgt" in
			ipset) get_ipset_bk | ipset restore; rv=$? ;;
			iptables)
				rv=0
				for family in $families; do
					set_ipt_cmds
					get_iptables_bk | $ipt_restore_cmd; rv=$((rv+$?))
				done ;;
		esac

		case "$rv" in
			0) OK ;;
			*) FAIL; rstr_failed "$FAIL restore $restoretgt state from backup." reset
		esac
	done

	rm_rstr_tmp

	cp_conf restore || rstr_failed
	:
}

rm_rstr_tmp() {
	rm -f "$tmp_file" 2>/dev/null
}

rstr_failed() {
	rm_rstr_tmp
	main_config=
	[ "$1" ] && echolog -err "$1"
	[ "$2" = reset ] && {
		echolog -err "*** Geoip blocking is not working. Removing geoip firewall rules. ***"
		rm_all_georules
	}
	die
}

rm_bk_tmp() {
	rm -f "$tmp_file" "${bk_file}.new" 2>/dev/null
}

bk_failed() {
	rm_bk_tmp
	die "$1"
}

create_backup() {
	printf %s "Creating backup of current $p_name state... "

	bk_len=0
	for family in $families; do
		set_ipt_cmds
		printf '%s\n' "[${p_name}_IPTABLES_$family]" >> "$tmp_file" &&
		printf '%s\n' "*$ipt_table" >> "$tmp_file" &&
		$ipt_save_cmd | grep -i "$geotag" >> "$tmp_file" &&
		printf '%s\n' "COMMIT" >> "$tmp_file" || bk_failed "$FAIL back up $p_name state."
	done
	OK

	bk_len="$(wc -l < "$tmp_file")"
	printf '%s\n' "[${p_name}_IPSET]" >> "$tmp_file"

	for ipset in $(ipset list -n | grep $geotag); do
		printf %s "Creating backup of ipset '$ipset'... "

		ipset save "$ipset" >> "$tmp_file"; rv=$?

		bk_len_old=$(( bk_len + 1 ))
		bk_len="$(wc -l < "$tmp_file")"
		[ "$rv" != 0 ] || [ "$bk_len" -le "$bk_len_old" ] && bk_failed "$FAIL back up ipset '$ipset'."
		OK
	done

	printf %s "Compressing backup... "
	bk_file="${bk_dir}/${p_name}_backup.${bk_ext:-bak}"
	$compr_cmd < "$tmp_file" > "${bk_file}.new" &&  [ -s "${bk_file}.new" ] ||
		bk_failed "$FAIL compress firewall backup to file '${bk_file}.new'."

	mv "${bk_file}.new" "$bk_file" || bk_failed "$FAIL overwrite file '$bk_file'."
	OK

	:
}
