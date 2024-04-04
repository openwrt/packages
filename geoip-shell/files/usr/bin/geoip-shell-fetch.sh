#!/bin/sh

curr_ver=0.4.7

# Copyright: antonk (antonk.d3v@gmail.com)
# github.com/friendly-bits

p_name="geoip-shell"
script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd -P)

geoinit="${p_name}-geoinit.sh"
for geoinit_path in "$script_dir/$geoinit" "/usr/bin/$geoinit"; do
	[ -f "$geoinit_path" ] && break
done

. "$geoinit_path" &&
. "$_lib-arrays.sh" || exit 1
. "$_lib-ip-regex.sh"

san_args "$@"
newifs "$delim"
set -- $_args; oldifs

usage() {
cat <<EOF

Usage: $me -l <"list_ids"> -p <path> [-o <output_file>] [-s <status_file>] [-u <"source">] [-f] [-d] [-V] [-h]

1) Fetches ip lists for given country codes from RIPE API or from ipdeny
	(supports any combination of ipv4 and ipv6 lists)

2) Parses, validates the downloaded lists, and saves each one to a separate file.

Options:
  -l $list_ids_usage
  -p <path>        : Path to directory where downloaded and compiled subnet lists will be stored.
  -o <output_file> : Path to output file where fetched list will be stored.
${sp16}${sp8}With this option, specify exactly 1 country code.
${sp16}${sp8}(use either '-p' or '-o' but not both)
  -s <status_file> : Path to a status file to register fetch results in.
  -u $sources_usage
 
  -r : Raw mode (outputs newline-delimited lists rather than nftables-ready ones)
  -f : Force using fetched lists even if list timestamp didn't change compared to existing list
  -d : Debug
  -V : Version
  -h : This help

EOF
}

while getopts ":l:p:o:s:u:rfdVh" opt; do
	case $opt in
		l) lists_arg=$OPTARG ;;
		p) iplist_dir_f=$OPTARG ;;
		s) status_file=$OPTARG ;;
		o) output_file=$OPTARG ;;
		u) source_arg=$OPTARG ;;

		r) raw_mode=1 ;;
		f) force_update=1 ;;
		d) ;;
		V) echo "$curr_ver"; exit 0 ;;
		h) usage; exit 0 ;;
		*) unknownopt
	esac
done
shift $((OPTIND-1))
extra_args "$@"





date_raw_to_compat() {
	[ -z "$1" ] && return 1
	mon_temp="${1#????}"
	eval "$2=\"${1%????}-${mon_temp%??}-${1#??????}\""
}

reg_server_date() {
	case "$1" in
		[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9] )
			set_a_arr_el server_dates_arr "$2=$1"
			 ;;
		*) 
	esac
}

get_src_dates_ipdeny() {
	tmp_file_path="/tmp/${p_name}_ipdeny"

	_res=
	for list_id in $valid_lists; do
		f="${list_id#*_}"; case "$_res" in *"$f"*) ;; *) _res="$_res$f "; esac
	done
	families="${_res% }"

	for family in $families; do
		case "$family" in
			ipv4) server_url="$ipdeny_ipv4_url" ;;
			ipv6) server_url="$ipdeny_ipv6_url"
		esac
		

		server_html_file="${tmp_file_path}_dl_page_${family}.tmp"
		server_plaintext_file="${tmp_file_path}_plaintext_${family}.tmp"
		$fetch_cmd_q "${http}://$server_url" > "$server_html_file"

		

		[ -f "$server_html_file" ] && awk '{gsub("<[^>]*>", "")} {$1=$1};1' "$server_html_file" > "$server_plaintext_file" ||
			echolog "failed to fetch server dates from the IPDENY server."
		rm "$server_html_file" 2>/dev/null
	done

	for list_id in $valid_lists; do
		curr_ccode="${list_id%%_*}"
		family="${list_id#*_}"
		server_plaintext_file="${tmp_file_path}_plaintext_${family}.tmp"
		[ -f "$server_plaintext_file" ] && server_date="$(
			awk -v c="$curr_ccode" '($1==tolower(c)"-aggregated.zone" && $2 ~ /^[0-3][0-9]-...-20[1-9][0-9]$/) {split($2,d,"-");
				$1 = sprintf("%04d%02d%02d", d[3],index("  JanFebMarAprMayJunJulAugSepOctNovDec",d[2])/3,d[1]); print $1}' \
				"$server_plaintext_file"
		)"

		reg_server_date "$server_date" "$list_id" "IPDENY"
	done

	for family in $families; do rm -f "${tmp_file_path}_plaintext_${family}.tmp" 2>/dev/null; done
}

get_src_dates_ripe() {
	server_html_file="/tmp/geoip-shell_server_dl_page.tmp"

	for registry in $registries; do
		tolower reg_lc "$registry"
		server_url="$ripe_url_stats/$reg_lc"

		
		[ ! "$server_url" ] && { echolog -err "get_src_dates_ripe(): $server_url variable should not be empty!"; return 1; }

		$fetch_cmd_q "${http}://$server_url" > "$server_html_file"

		
		server_date="$(grep -oE '\-[0-9]{8}\.md5' < "$server_html_file" | cut -b 2-9 | sort -V | tail -n1)"

		rm "$server_html_file" 2>/dev/null
		get_a_arr_val fetch_lists_arr "$registry" list_ids
		for list_id in $list_ids; do
			reg_server_date "$server_date" "$list_id" "RIPE"
		done
	done
}

parse_ripe_json() {
	in_list="$1" out_list="$2" family="$3"
	sed -n -e /"$family"/\{:1 -e n\;/]/q\;p\;b1 -e \} "$in_list" | cut -d\" -f2 > "$out_list"
	[ -s "$out_list" ]; return $?
}

group_lists_by_registry() {
	valid_lists=
	for registry in $all_registries; do
		list_ids=
		for list_id in $lists_arg; do
			ccode="${list_id%_*}"
			get_a_arr_val registry_ccodes_arr "$registry" ccodes
			case "$ccodes" in *" ${ccode} "*)
				add2list registries "$registry"
				add2list list_ids "$list_id"
				add2list valid_lists "$list_id"
			esac
		done
		set_a_arr_el fetch_lists_arr "$registry=$list_ids"
	done

	subtract_a_from_b "$valid_lists" "$lists_arg" invalid_lists
	[ "$invalid_lists" ] && {
		for invalid_list in $invalid_lists; do
			add2list invalid_ccodes "${invalid_list%_*}"
		done
		die "Invalid country codes: '$invalid_ccodes'."
	}
}

check_prev_list() {
	list_id="$1"
	unset prev_list_reg prev_date_raw prev_date_compat prev_s_cnt

	eval "prev_s_cnt=\"\$prev_ips_cnt_${list_id}\""
	case "$prev_s_cnt" in
		''|0)  prev_s_cnt='' ;;
		*)
			eval "prev_date_compat=\"\$prev_date_${list_id}\""
			if [ "$prev_date_compat" ]; then
				prev_list_reg=true
				p="$prev_date_compat"
				mon_temp="${p#?????}"
				prev_date_raw="${p%??????}${mon_temp%???}${p#????????}"
			else
				
				prev_s_cnt=
			fi
	esac
}

check_updates() {
	unset lists_need_update up_to_date_lists

	time_now="$(date +%s)"

	printf '\n%s\n\n' "Checking for ip list updates on the $dl_src_cap server..."

	case "$dl_src" in
		ipdeny) get_src_dates_ipdeny ;;
		ripe) get_src_dates_ripe ;;
		*) die "Unknown source: '$dl_src'."
	esac

	unset ccodes_need_update families
	for list_id in $valid_lists; do
		get_a_arr_val server_dates_arr "$list_id" date_src_raw
		date_raw_to_compat "$date_src_raw" date_src_compat

		if [ ! "$date_src_compat" ]; then
			echolog -warn "$FAIL get the timestamp from the server for list '$list_id'. Will try to fetch anyway."
			date_src_raw="$(date +%Y%m%d)"; force_update=1
			date_raw_to_compat "$date_src_raw" date_src_compat
		fi

		time_source="$(date -d "$date_src_compat" +%s)"

		time_diff=$(( time_now - time_source ))

		if [ "$time_diff" -gt 604800 ]; then
			msg1="Newest ip list for list '$list_id' on the $dl_src_cap server is dated '$date_src_compat' which is more than 7 days old."
			msg2="Either your clock is incorrect, or '$dl_src_cap' is not updating the list for '$list_id'."
			msg3="If it's the latter, please notify the developer."
			echolog -warn "$msg1" "$msg2" "$msg3"
		fi

		check_prev_list "$list_id"

		if [ "$prev_list_reg" ] && [ "$date_src_raw" -le "$prev_date_raw" ] && [ ! "$force_update" ] && [ ! "$manmode" ]; then
			add2list up_to_date_lists "$list_id"
		else
			add2list ccodes_need_update "${list_id%_*}"
			add2list families "${list_id##*_}"
		fi
	done

	[ "$up_to_date_lists" ] &&
		echolog "Ip lists '${purple}$up_to_date_lists${n_c}' are already ${green}up-to-date${n_c} with the $dl_src_cap server."
	:
}

rm_tmp_f() {
	rm -f "$fetched_list" "$parsed_list" "$valid_list" 2>/dev/null
}

list_failed() {
	rm_tmp_f
	add2list failed_lists "$list_id"
	[ "$1" ] && echolog -err "$1"
}

process_ccode() {

	curr_ccode="$1"; tolower curr_ccode_lc "$curr_ccode"
	unset prev_list_reg list_path fetched_list
	set +f; rm -f "/tmp/${p_name}_"*.tmp; set -f

	for family in $families; do
		list_id="${curr_ccode}_${family}"
		case "$dl_src" in
			ripe ) dl_url="${ripe_url_api}v4_format=prefix&resource=${curr_ccode}" ;;
			ipdeny )
				case "$family" in
					"ipv4" ) dl_url="${ipdeny_ipv4_url}/${curr_ccode_lc}-aggregated.zone" ;;
					* ) dl_url="${ipdeny_ipv6_url}/${curr_ccode_lc}-aggregated.zone"
				esac ;;
			* ) die "Unsupported source: '$dl_src'."
		esac

		list_path="${output_file:-$iplist_dir_f/$list_id.iplist}"

		parsed_list="/tmp/${p_name}_parsed-${list_id}.tmp"
		fetched_list="/tmp/${p_name}_fetched-$curr_ccode.tmp"

		valid_s_cnt=0
		failed_s_cnt=0

		check_prev_list "$list_id"

		if [ ! -s "$fetched_list" ]; then
			case "$dl_src" in
				ripe ) printf '%s\n' "Fetching ip list for country '${purple}$curr_ccode${n_c}' from $dl_src_cap..." ;;
				ipdeny ) printf '%s\n' "Fetching ip list for '${purple}$list_id${n_c}' from $dl_src_cap..."
			esac

			
			$fetch_cmd "${http}://$dl_url" > "$fetched_list" ||
				{ list_failed "$FAIL fetch the ip list for '$list_id' from the $dl_src_cap server."; continue; }
			printf '%s\n\n' "Fetch successful."
		fi

		case "$dl_src" in
			ripe)
				printf %s "Parsing ip list for '${purple}$list_id${n_c}'... "
				parse_ripe_json "$fetched_list" "$parsed_list" "$family" ||
					{ list_failed "$FAIL parse the ip list for '$list_id'."; continue; }
				OK ;;
			ipdeny) mv "$fetched_list" "$parsed_list"
		esac

		printf %s "Validating '$purple$list_id$n_c'... "
		validate_list "$list_id"
		rm -f "$parsed_list" 2>/dev/null

		[ "$failed_s_cnt" = 0 ] && OK || { FAIL; continue; }

		printf '%s\n\n' "Validated subnets for '$purple$list_id$n_c': $valid_s_cnt."
		check_subnets_cnt_drop "$list_id" || { list_failed; continue; }

		
		{ [ "$raw_mode" ] && cat "$valid_list" || {
				printf %s "elements={ "
				tr '\n' ',' < "$valid_list"
				printf '%s\n' "}"
			}
		} > "$list_path" || { list_failed "$FAIL overwrite the file '$list_path'"; continue; }

		touch -d "$date_src_compat" "$list_path"
		add2list fetched_lists "$list_id"
		set_a_arr_el subnets_cnt_arr "$list_id=$valid_s_cnt"
		set_a_arr_el list_date_arr "$list_id=$date_src_compat"

		rm -f "$valid_list" 2>/dev/null
	done

	rm -f "$fetched_list" 2>/dev/null
	:
}

validate_list() {
	list_id="$1"
	valid_list="/tmp/validated-${list_id}.tmp"
	family="${list_id#*_}"

	case "$family" in ipv4) subnet_regex="$subnet_regex_ipv4" ;; *) subnet_regex="$subnet_regex_ipv6"; esac
	grep -E "^$subnet_regex$" "$parsed_list" > "$valid_list"

	parsed_s_cnt=$(wc -w < "$parsed_list")
	valid_s_cnt=$(wc -w < "$valid_list")
	failed_s_cnt=$(( parsed_s_cnt - valid_s_cnt ))

	if [ "$failed_s_cnt" != 0 ]; then
		failed_s="$(grep -Ev  "$subnet_regex" "$parsed_list")"

		list_failed "${_nl}NOTE: out of $parsed_s_cnt subnets for ip list '${purple}$list_id${n_c}, $failed_s_cnt subnets ${red}failed validation${n_c}'."
		if [ $failed_s_cnt -gt 10 ]; then
				echo "First 10 failed subnets:"
				printf '%s\n' "$failed_s" | head -n10
				printf '\n'
		else
			printf '%s\n%s\n\n' "Following subnets failed validation:" "$failed_s"
		fi
	fi
}

check_subnets_cnt_drop() {
	list_id="$1"
	if [ "$valid_s_cnt" = 0 ]; then
		echolog -err "$WARN validated 0 subnets for list '$purple$list_id$n_c'. Perhaps the country code is incorrect?" >&2
		return 1
	fi

	if [ "$prev_list_reg" ]; then
		s_percents="$((valid_s_cnt * 100 / prev_s_cnt))"
		case $((s_percents < 90)) in
			1) echolog -err "$WARN validated subnets count '$valid_s_cnt' in the fetched list '$purple$list_id$n_c'" \
				"is ${s_percents}% of '$prev_s_cnt' subnets in the existing list dated '$prev_date_compat'." \
				"Not updating the list."
				return 1 ;;
			*) 
		esac
	fi
}

all_registries="ARIN RIPENCC APNIC AFRINIC LACNIC"

newifs "$_nl" cca
cca2_f="cca2.list"
for cca2_path in "$script_dir/$cca2_f" "$conf_dir/$cca2_f"; do
	[ -f "$cca2_path" ] && break
done

[ -f "$cca2_path" ] && cca2_list="$(cat "$cca2_path")" || die "$FAIL load the cca2 list."
set -- $cca2_list
for i in 1 2 3 4 5; do
	eval "c=\"\${$i}\""
	set_a_arr_el registry_ccodes_arr "$c"
done
oldifs cca

ucl_f_cmd="uclient-fetch -T 16"
curl_cmd="curl -L --retry 5 -f --fail-early --connect-timeout 7"

[ "$script_dir" = "$install_dir" ] && getconfig http
unset secure_util fetch_cmd
for util in curl wget uclient-fetch; do
	checkutil "$util" || continue
	case "$util" in
		curl)
			secure_util="curl"
			fetch_cmd="$curl_cmd --progress-bar"
			fetch_cmd_q="$curl_cmd -s"
			break ;;
		wget)
			if checkutil ubus && checkutil uci; then
				wget_cmd="wget -q --timeout=16"
				[ -s "/usr/lib/libustream-ssl.so" ] && { secure_util="wget"; break; }
			else
				wget_cmd="wget -q --max-redirect=10 --tries=5 --timeout=16"
				secure_util="wget"
				fetch_cmd="$wget_cmd --show-progress -O -"
				fetch_cmd_q="$wget_cmd -O -"
				break
			fi ;;
		uclient-fetch)
			[ -s "/usr/lib/libustream-ssl.so" ] && secure_util="uclient-fetch"
			fetch_cmd="$ucl_f_cmd -O -"
			fetch_cmd_q="$ucl_f_cmd -q -O -"
	esac
done

[ "$daemon_mode" ] && fetch_cmd="$fetch_cmd_q"

[ -z "$fetch_cmd" ] && die "Compatible download utilites unavailable."

if [ -z "$secure_util" ] && [ -z "$http" ]; then
	if [ "$nointeract" ]; then
		REPLY=y
	else
		[ ! "$manmode" ] && die "no fetch utility with SSL support available."
		printf '\n%s\n' "Can not find download utility with SSL support. Enable insecure downloads?"
		pick_opt "y|n"
	fi
	case "$REPLY" in
		n|N) die "No fetch utility available." ;;
		y|Y) http="http"; [ "$script_dir" = "$install_dir" ] && setconfig http
	esac
fi
: "${http:=https}"

valid_sources="ripe ipdeny"
default_source="ripe"

lists=
for list_id in $lists_arg; do
	case "$list_id" in
		*_*) toupper cc_up "${list_id%%_*}"; tolower fml_lo "_${list_id#*_}"; add2list lists "$cc_up$fml_lo" ;;
		*) die "invalid list id '$list_id'."
	esac
done
lists_arg="$lists"

tolower source_arg
dl_src="${source_arg:-"$default_source"}"
toupper dl_src_cap "$dl_src"

set -- $dl_src
case "$2" in *?*) die "Specify only one download source."; esac

[ ! "$dl_src" ] && die "'\$dl_src' variable should not be empty!"

subtract_a_from_b "$valid_sources" "$dl_src" invalid_source
case "$invalid_source" in *?*) die "Invalid source: '$invalid_source'"; esac

case "$dl_src" in
	ripe) dl_srv="${ripe_url_api%%/*}" ;;
	ipdeny) dl_srv="${ipdeny_ipv4_url%%/*}"
esac

[ ! "$iplist_dir_f" ] && [ ! "$output_file" ] &&
	die "Specify iplist directory with '-p <path-to-dir>' or output file with '-o <output_file>'."
[ "$iplist_dir_f" ] && [ "$output_file" ] && die "Use either '-p <path-to-dir>' or '-o <output_file>' but not both."

[ ! "$lists_arg" ] && die "Specify country code/s!"
fast_el_cnt "$lists_arg" " " lists_arg_cnt

[ "$output_file" ] && [ "$lists_arg_cnt" -gt 1 ] &&
	die "To fetch multiple lists, use '-p <path-to-dir>' instead of '-o <output_file>'."

[ "$iplist_dir_f" ] && [ ! -d "$iplist_dir_f" ] && die "Directory '$iplist_dir_f' doesn't exist!"
iplist_dir_f="${iplist_dir_f%/}"

printf '\n%s' "Checking connectivity... "
nslookup="nslookup -retry=1"
{
	eval "$nslookup" 127.0.0.1 || eval "$nslookup" ::1 || nslookup=nslookup
	for ns in "8.8.8.8" "208.68.222.222" "2001:4860:4860::8888" "2620:119:35::35"; do
		eval "$nslookup" "$dl_srv" "$ns" && break
	done
} 1>/dev/null 2>/dev/null || die "Machine appears to have no Internet connectivity or $dl_src_cap server is currently down."
OK

for f in "$status_file" "$output_file"; do
	[ "$f" ] && [ ! -f "$f" ] && { touch "$f" || die "$FAIL create file '$f'."; }
done

group_lists_by_registry

[ ! "$registries" ] && die "$FAIL determine relevant regions."

for list_id in $valid_lists; do
	unset "prev_ips_cnt_${list_id}"
done

if [ "$status_file" ] && [ -s "$status_file" ]; then
	getstatus "$status_file"
else
	
	:
fi
unset failed_lists fetched_lists

trap 'rm_tmp_f; rm -f "$server_html_file" 2>/dev/null
	for family in $families; do
		rm -f "${tmp_file_path}_plaintext_${family}.tmp" "${tmp_file_path}_dl_page_${family}.tmp" 2>/dev/null
	done; exit' INT TERM HUP QUIT

check_updates

for ccode in $ccodes_need_update; do
	process_ccode "$ccode"
done

if [ "$status_file" ]; then
	ips_cnt_str=
	get_a_arr_keys subnets_cnt_arr list_ids
	for list_id in $list_ids; do
		get_a_arr_val subnets_cnt_arr "$list_id" subnets_cnt
		ips_cnt_str="${ips_cnt_str}prev_ips_cnt_${list_id}=$subnets_cnt$_nl"
	done

	list_dates_str=
	get_a_arr_keys list_date_arr list_ids
	for list_id in $list_ids; do
		get_a_arr_val list_date_arr "$list_id" prev_date
		list_dates_str="${list_dates_str}prev_date_${list_id}=$prev_date$_nl"
	done

	setstatus "$status_file" "fetched_lists=$fetched_lists" "up_to_date_lists=$up_to_date_lists" \
		"failed_lists=$failed_lists" "$ips_cnt_str" "$list_dates_str" ||
			die "$FAIL write to the status file '$status_file'."
fi

:
