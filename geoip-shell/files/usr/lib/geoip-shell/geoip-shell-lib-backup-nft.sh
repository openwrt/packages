#!/bin/sh

curr_ver=0.4.7

# Copyright: antonk (antonk.d3v@gmail.com)
# github.com/friendly-bits

. "$_lib-nft.sh" || die

restorebackup() {
	printf %s "Restoring ip lists from backup... "
	for list_id in $iplists; do
		bk_file="$bk_dir/$list_id.$bk_ext"
		iplist_file="$iplist_dir/${list_id}.iplist"

		[ ! -s "$bk_file" ] && rstr_failed "'$bk_file' is empty or doesn't exist."

		$extract_cmd "$bk_file" > "$iplist_file" || rstr_failed "$FAIL extract backup file '$bk_file'."
		[ ! -s "$iplist_file" ] && rstr_failed "$FAIL extract ip list for $list_id."
		line_cnt=$(wc -l < "$iplist_file")
		
	done
	OK

	cp_conf restore || rstr_failed
	main_config=

	rm_all_georules || rstr_failed "$FAIL remove firewall rules."

	call_script "${i_script}-apply.sh" add -l "$iplists"; apply_rv=$?
	rm "$iplist_dir/"*.iplist 2>/dev/null
	[ "$apply_rv" != 0 ] && rstr_failed "$FAIL restore the firewall state from backup." "reset"
	:
}

rm_rstr_tmp() {
	rm "$iplist_dir/"*.iplist 2>/dev/null
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
	rm -f "$tmp_file" "$bk_dir/"*.new 2>/dev/null
}

bk_failed() {
	rm_bk_tmp
	die "$FAIL back up $p_name ip sets."
}

create_backup() {
	printf %s "Creating backup of $p_name ip sets... "
	getstatus "$status_file" || bk_failed
	for list_id in $iplists; do
		bk_file="${bk_dir}/${list_id}.${bk_ext:-bak}"
		iplist_file="$iplist_dir/${list_id}.iplist"
		eval "list_date=\"\$prev_date_${list_id}\""
		[ -z "$list_date" ] && bk_failed
		ipset="${list_id}_${list_date}_${geotag}"

		rm -f "$tmp_file" 2>/dev/null
		nft list set inet "$geotable" "$ipset" |
			sed -n -e /"elements[[:space:]]*=[[:space:]]*{"/\{ -e p\;:1 -e n\; -e p\; -e /\}/q\;b1 -e \} > "$tmp_file"
		[ ! -s "$tmp_file" ] && bk_failed

		[ "$debugmode" ] && bk_len="$(wc -l < "$tmp_file")"
		

		$compr_cmd < "$tmp_file" > "${bk_file}.new"; rv=$?
		[ "$rv" != 0 ] || [ ! -s "${bk_file}.new" ] && bk_failed
	done
	OK

	for f in "${bk_dir}"/*.new; do
		mv -- "$f" "${f%.new}" || bk_failed
	done
	:
}
