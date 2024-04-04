#!/bin/sh

curr_ver=0.4.7

# Copyright: antonk (antonk.d3v@gmail.com)
# github.com/friendly-bits


set_ansi() {
	set -- $(printf '\033[0;31m \033[0;32m \033[1;34m \033[1;33m \033[0;35m \033[0m \35 \342\234\224 \342\234\230 \t')
	export red="$1" green="$2" blue="$3" yellow="$4" purple="$5" n_c="$6" delim="$7" _V="$8" _X="$9" trim_IFS=" ${10}"
	export _V="$green$_V$n_c" _X="$red$_X$n_c"
}

newifs() {
	eval "IFS_OLD_$2"='$IFS'; IFS="$1"
}

oldifs() {
	eval "IFS=\"\$IFS_OLD_$1\""
}

is_root_ok() {
	[ "$root_ok" ] && return 0
	rv=1
	[ "$manualmode" ] && { rv=0; tip=" For usage, run '$me -h'."; }
	die $rv "$me needs to be run as root.$tip"
}

extra_args() {
	[ "$*" ] && die "Invalid arguments. First unexpected argument: '$1'."
}

checkutil() {
	command -v "$1" 1>/dev/null
}

unknownopt() {
	usage; die "Unknown option '-$OPTARG' or it requires an argument."
}

statustip() {
	printf '\n%s\n\n' "View geoip status with '${blue}${p_name} status${n_c}' (may require 'sudo')."
}

report_lists() {
	get_active_iplists verified_lists
	nl2sp verified_lists
	printf '\n%s\n' "Ip lists in the final $geomode: '${blue}$verified_lists${n_c}'."
}

unknownact() {
	specifyact="Specify action in the 1st argument!"
	case "$action" in
		-V|-h) ;;
		'') usage; die "$specifyact" ;;
		*) usage; die "Unknown action: '$action'." "$specifyact"
	esac
}

pick_opt() {
	toupper U_1 "$1"
	_opts="$1|$U_1"
	while true; do
		printf %s "$1: "
		read -r REPLY
		is_alphanum "$REPLY" || { printf '\n%s\n\n' "Please enter $1"; continue; }
		eval "case \"$REPLY\" in
				$_opts) return ;;
				*) printf '\n%s\n\n' \"Please enter $1\"
			esac"
	done
}

add2config_entry() {
	getconfig "$1" a2c_e
	is_included "$2" "$a2c_e" && return 0
	add2list a2c_e "$2"
	setconfig "$1" "$a2c_e"
}

is_alphanum() {
	case "$1" in *[!A-Za-z0-9_]* )
		[ "$2" != '-n' ] && echolog -err "Invalid string '$1'. Use alphanumerics and underlines."
		return 1
	esac
	:
}

fast_el_cnt() {
	el_cnt_var="$3"
	newifs "$2" cnt
	set -- $1
	eval "$el_cnt_var"='$#'
	oldifs cnt
}

conv_case() {
	outvar_cc="$1"
	case "$2" in
		toupper) tr_1='a-z' tr_2='A-Z' ;;
		tolower) tr_1='A-Z' tr_2='a-z'
	esac
	newifs "$default_IFS" conv
	case "$3" in
		*[$tr_1]*) conv_res="$(printf %s "$3" | tr "$tr_1" "$tr_2")" ;;
		*) conv_res="$3"
	esac
	eval "$outvar_cc=\"$conv_res\""
	oldifs conv
}

tolower() {
	in_cc="$2"
	[ $# = 1 ] && eval "in_cc=\"\$$1\""
	conv_case "$1" tolower "$in_cc"
}

toupper() {
	in_cc="$2"
	[ $# = 1 ] && eval "in_cc=\"\$$1\""
	conv_case "$1" toupper "$in_cc"
}

call_script() {
	[ "$1" = '-l' ] && { use_lock=1; shift; }
	script_to_call="$1"
	shift

	: "${use_shell:=$curr_sh_g}"
	: "${use_shell:=sh}"

	[ ! "$script_to_call" ] && { echolog -err "call_script: received empty string."; return 1 ; }

	[ "$use_lock" ] && rm_lock
	$use_shell "$script_to_call" "$@"; call_rv=$?; unset main_config

	[ "$use_lock" ] && mk_lock -f
	use_lock=
	return "$call_rv"
}

check_deps() {
	missing_deps=
	for dep; do ! checkutil "$dep" && missing_deps="${missing_deps}'$dep', "; done
	[ "$missing_deps" ] && { echolog -err "Missing dependencies: ${missing_deps%, }"; return 1; }
	:
}

get_json_lines() {
	sed -n -e /"$1"/\{:1 -e n\;/"$2"/q\;p\;b1 -e \}
}

echolog() {
	unset msg_args __nl msg_prefix o_nolog

	highlight="$blue"; err_l=info
	for arg in "$@"; do
		case "$arg" in
			"-err" ) highlight="$red"; err_l=err; msg_prefix="$ERR " ;;
			"-warn" ) highlight="$yellow"; err_l=warn; msg_prefix="$WARN " ;;
			"-nolog" ) o_nolog=1 ;;
			'') ;;
			* ) msg_args="$msg_args$arg$delim"
		esac
	done

	case "$msg_args" in "$_nl"* )
		__nl="$_nl"
		msg_args="${msg_args#"$_nl"}"
	esac

	newifs "$delim" ecl
	set -- $msg_args; oldifs ecl

	for arg in "$@"; do
		[ ! "$noecho" ] && {
			_msg="${__nl}$highlight$me_short$n_c: $msg_prefix$arg"
			case "$err_l" in
				info) printf '%s\n' "$_msg" ;;
				err|warn) printf '%s\n' "$_msg" >&2
			esac
			unset __nl msg_prefix
		}
		[ ! "$nolog" ] && [ ! "$o_nolog" ] &&
			logger -t "$me" -p user."$err_l" "$(printf %s "$msg_prefix$arg" | awk '{gsub(/\033\[[0-9;]*m/,"")};1' ORS=' ')"
	done
}

die() {
	case "$1" in
		''|*[!0-9]* ) die_rv="1" ;;
		* ) die_rv="$1"; shift
	esac

	unset msg_type die_args
	case "$die_rv" in
		0) _err_l=notice ;;
		254) _err_l=warn; msg_type="-warn" ;;
		*) _err_l=err; msg_type="-err"
	esac

	for die_arg in "$@"; do
		case "$die_arg" in
			-nolog) nolog="1" ;;
			'') ;;
			*) die_args="$die_args$die_arg$delim"
		esac
	done

	[ "$die_unlock" ] && rm_lock

	[ "$die_args" ] && {
		newifs "$delim" die
		for arg in $die_args; do
			echolog "$msg_type" "$arg"
			msg_type=
		done
		oldifs die
	}
	exit "$die_rv"
}

num2human() {
	i=${1:-0} s=0 d=0
	case "$2" in bytes) m=1024 ;; '') m=1000 ;; *) return 1; esac
	case "$i" in *[!0-9]*) echolog -err "num2human: Invalid unsigned integer '$i'."; return 1; esac
	for S in B KiB MiB TiB PiB; do
		[ $((i > m && s < 4)) = 0 ] && break
		d=$i
		i=$((i/m))
		s=$((s+1))
	done
	[ -z "$2" ] && { S=${S%B}; S=${S%i}; [ "$S" = P ] && S=Q; }
	d=$((d % m * 100 / m))
	case $d in
		0) printf "%s%s\n" "$i" "$S"; return ;;
		[1-9]) fp="02" ;;
		*0) d=${d%0}; fp="01"
	esac
	printf "%s.%${fp}d%s\n" "$i" "$d" "$S"
}

get_matching_line() {
	newifs "$_nl" gml
	_rv=1; _res=
	for _line in $1; do
		case "$_line" in $2"$3"$4) _res="$_line"; _rv=0; break; esac
	done
	[ "$5" ] && eval "$5"='$_res'
	oldifs gml
	return $_rv
}

getconfig() {
	key_conf="$1"
	[ $# -gt 1 ] && key_conf="$2"
	target_file="${3:-$conf_file}"
	[ "$1" ] && [ "$target_file" ] &&
	getallconf conf "$target_file" &&
	get_matching_line "$conf" "" "$key_conf=" "*" "conf_line" || {
		eval "$1="
		[ ! "$nodie" ] && die "$FAIL read value for '$key_conf' from file '$target_file'."
		return 2
	}
	eval "$1"='${conf_line#"${key_conf}"=}'
	:
}

getallconf() {
	[ ! "$1" ] && return 1
	[ ! -f "$2" ] && { echolog -err "Config/status file '$2' is missing!"; return 1; }

	conf_gac=
	[ "$2" = "$conf_file" ] && conf_gac="$main_config"
	[ -z "$conf_gac" ] && {
		conf_gac="$(cat "$2")"
		[ "$2" = "$conf_file" ] && export main_config="$conf_gac"
	}
	eval "$1=\"$conf_gac\""
	:
}

get_config_vars() {
	inval_e() {
		echolog -err "Invalid entry '$entry' in config."
		[ ! "$nodie" ] && die
	}

	target_f_gcv="${1:-"$conf_file"}"

	getallconf all_config "$target_f_gcv" || {
		echolog -err "$FAIL get config from '$target_f_gcv'."
		[ ! "$nodie" ] && die
		return 1
	}

	newifs "$_nl" gcv
	for entry in $all_config; do
		case "$entry" in
			'') continue ;;
			*=*=*) { inval_e; return 1; } ;;
			*=*) ;;
			*) { inval_e; return 1; } ;;
		esac
		key_conf="${entry%=*}"
		is_alphanum "$key_conf" || { inval_e; return 1; }
		eval "$key_conf"='${entry#${key_conf}=}'
	done
	oldifs gcv
	:
}

setconfig() {
	unset args_lines args_target_file keys_test_str newconfig
	newifs "$_nl" sc
	for argument_conf in "$@"; do
		for line in $argument_conf; do
			[ ! "$line" ] && continue
			case "$line" in
				'') continue ;;
				*[!A-Za-z0-9_]*=*) sc_failed "bad config line '$line'." ;;
				*=*) key_conf="${line%%=*}"; value_conf="${line#*=}" ;;
				*) key_conf="$line"; eval "value_conf=\"\$$line\"" || sc_failed "bad key '$line'."
			esac
			case "$key_conf" in
				'') ;;
				target_file) args_target_file="$value_conf" ;;
				*) args_lines="${args_lines}${key_conf}=$value_conf$_nl"
					keys_test_str="${keys_test_str}\"${key_conf}=\"*|"
			esac
		done
	done
	keys_test_str="${keys_test_str%\|}"
	[ ! "$keys_test_str" ] && { sc_failed "no valid args passed."; return 1; }
	target_file="${args_target_file:-$inst_root_gs$conf_file}"

	[ ! "$target_file" ] && { sc_failed "'\$target_file' variable is not set."; return 1; }

	[ -f "$target_file" ] && {
		getallconf oldconfig "$target_file" || { sc_failed "$FAIL read '$target_file'."; return 1; }
	}
	for config_line in $oldconfig; do
		eval "case \"$config_line\" in
				''|$keys_test_str) ;;
				*) newconfig=\"$newconfig$config_line$_nl\"
			esac"
	done
	oldifs sc

	newconfig="$newconfig$args_lines"
	[ -f "$target_file" ] && compare_file2str "$target_file" "$newconfig" && return 0
	printf %s "$newconfig" > "$target_file" || { sc_failed "$FAIL write to '$target_file'"; return 1; }
	[ "$target_file" = "$conf_file" ] && export main_config="$newconfig"
	:
}

sc_failed() {
	oldifs sc
	echolog -err "setconfig: $1"
	[ ! "$nodie" ] && die
}

getstatus() {
	[ ! "$1" ] && {
		echolog -err "getstatus: target file not specified!"
		[ ! "$nodie" ] && die
		return 1
	}
	nodie=1 get_config_vars "$1"
}

setstatus() {
	target_file="$1"
	shift 1
	[ ! "$target_file" ] && { echolog -err "setstatus: target file not specified!"; [ ! "$nodie" ] && die; return 1; }
	[ ! -d "${target_file%/*}" ] && mkdir -p "${target_file%/*}"
	[ ! -f "$target_file" ] && touch "$target_file"
	setconfig target_file "$@"
}

awk_cmp() {
	awk 'NF==0{next} NR==FNR {A[$0]=1;a++;next} {b++} !A[$0]{r=1;exit} END{if(!a&&!b){exit 0};if(!a||!b){exit 1};exit r}' r=0 "$1" "$2"
}

compare_files() {
	[ -f "$1" ] && [ -f "$2" ] || { echolog -err "compare_conf: file '$1' or '$2' does not exist."; return 2; }
	awk_cmp "$1" "$2" && awk_cmp "$2" "$1"
}

compare_file2str() {
	[ -f "$1" ] || { echolog -err "compare_file2str: file '$1' does not exist."; return 2; }
	printf '%s\n' "$2" | awk_cmp - "$1" && printf '%s\n' "$2" | awk_cmp "$1" -
}

trimsp() {
	trim_var="$1"
	newifs "$trim_IFS" trim
	case "$#" in 1) eval "set -- \$$1" ;; *) set -- $2; esac
	eval "$trim_var"='$*'
	oldifs trim
}

is_included() {
	_fs_ii="${3:- }"
	case "$2" in "$1"|"$1$_fs_ii"*|*"$_fs_ii$1"|*"$_fs_ii$1$_fs_ii"*) return 0 ;; *) return 1; esac
}

add2list() {
	is_alphanum "$1" || return 1
	a2l_fs="${3:- }"
	eval "_curr_list=\"\$$1\""
	is_included "$2" "$_curr_list" "$a2l_fs" && return 2
	eval "$1=\"\${$1}$a2l_fs$2\"; $1=\"\${$1#$a2l_fs}\""
	return 0
}

san_str() {
	[ "$1" = '-n' ] && { _del="$_nl"; shift; } || _del=' '
	[ "$2" ] && inp_str="$2" || eval "inp_str=\"\$$1\""

	_sid="${3:-"$_del"}"
	_sod="${4:-"$_del"}"
	_words=
	newifs "$_sid" san
	for _w in $inp_str; do
		add2list _words "$_w" "$_sod"
	done
	eval "$1"='$_words'
	oldifs san
}

get_intersection() {
	gi_out="${3:-___dummy}"
	[ ! "$1" ] || [ ! "$2" ] && { unset "$gi_out"; return 1; }
	_fs_gi="${4:-" "}"
	_isect=
	newifs "$_fs_gi" _fs_gi
	for e in $2; do
		is_included "$e" "$1" "$_fs_gi" && add2list _isect "$e" "$_fs_gi"
	done
	eval "$gi_out"='$_isect'
	oldifs _fs_gi
}

get_difference() {
	gd_out="${3:-___dummy}"
	case "$1" in
		'') case "$2" in '') unset "$gd_out"; return 0 ;; *) eval "$gd_out"='$2'; return 1; esac ;;
		*) case "$2" in '') eval "$gd_out"='$1'; return 1; esac
	esac
	_fs_gd="${4:-" "}"
	subtract_a_from_b "$1" "$2" _diff1 "$_fs_gd"
	subtract_a_from_b "$2" "$1" _diff2 "$_fs_gd"
	_diff="$_diff1$_fs_gd$_diff2"
	_diff="${_diff#"$_fs_gd"}"
	eval "$gd_out"='${_diff%$_fs_gd}'
	[ "$_diff1$_diff2" ] && return 1 || return 0
}

subtract_a_from_b() {
	sab_out="${3:-___dummy}"
	case "$2" in '') unset "$sab_out"; return 0; esac
	case "$1" in '') eval "$sab_out"='$2'; [ ! "$2" ]; return; esac
	_fs_su="${4:-" "}"
	rv_su=0 _subt=
	newifs "$_fs_su" _fs_su
	for e in $2; do
		is_included "$e" "$1" "$_fs_su" || { add2list _subt "$e" "$_fs_su"; rv_su=1; }
	done
	eval "$sab_out"='$_subt'
	oldifs _fs_su
	return $rv_su
}

sp2nl() {
	var_stn="$1"
	[ $# = 2 ] && _inp="$2" || eval "_inp=\"\$$1\""
	newifs "$trim_IFS" stn
	set -- $_inp
	IFS="$_nl"
	eval "$var_stn"='$*'
	oldifs stn
}

nl2sp() {
	var_nts="$1"
	[ $# = 2 ] && _inp="$2" || eval "_inp=\"\$$1\""
	newifs "$_nl" nts
	set -- $_inp
	IFS=' '
	eval "$var_nts"='$*'
	oldifs nts
}

san_args() {
	_args=
	for arg in "$@"; do
		trimsp arg
		[ "$arg" ] && _args="$_args$arg$delim"
	done
}

r_no_l() { nolog="$_no_l"; }

get_active_iplists() {
	unset force_read iplists_incoherent
	[ "$1" = "-f" ] && { force_read="-f"; shift; }
	case "$geomode" in
		whitelist) ipt_target=ACCEPT nft_verdict=accept ;;
		blacklist) ipt_target=DROP nft_verdict=drop ;;
		*) die "get_active_iplists: unexpected geoip mode '$geomode'."
	esac

	ipset_iplists="$(get_ipset_iplists)"
	fwrules_iplists="$(get_fwrules_iplists)"

	get_difference "$ipset_iplists" "$fwrules_iplists" lists_difference "$_nl"
	get_intersection "$ipset_iplists" "$fwrules_iplists" "active_iplists_nl" "$_nl"
	nl2sp "$1" "$active_iplists_nl"

	case "$lists_difference" in
		'') return 0 ;;
		*) iplists_incoherent=1; return 1
	esac
}

check_lists_coherence() {
	_no_l="$nolog"
	[ "$1" = '-n' ] && nolog=1
	

	case "$geomode" in whitelist|blacklist) ;; *) r_no_l; echolog -err "Unexpected geoip mode '$geomode'!"; return 1; esac

	unset unexp_lists missing_lists
	getconfig iplists

	get_active_iplists -f active_lists || {
		nl2sp ips_l_str "$ipset_iplists"; nl2sp ipr_l_str "$fwrules_iplists"
		echolog -warn "ip sets ($ips_l_str) differ from iprules lists ($ipr_l_str)."
		report_incoherence
		r_no_l
		return 1
	}

	get_difference "$active_lists" "$iplists" lists_difference
	case "$lists_difference" in
		'')  rv_clc=0 ;;
		*)
			echolog -err "$_nl$FAIL verify ip lists coherence." "Firewall ip lists: '$active_lists'" "Config ip lists: '$iplists'"
			subtract_a_from_b "$iplists" "$active_lists" unexpected_lists
			subtract_a_from_b "$active_lists" "$iplists" missing_lists
			report_incoherence
			rv_clc=1
	esac
	r_no_l
	return $rv_clc
}

report_incoherence() {
	discr="Discrepancy detected between"
	[ "$iplists_incoherent" ] && echolog -warn "$discr geoip ipsets and geoip firewall rules!"
	echolog -warn "$discr the firewall state and the config file."
	for opt_ri in unexpected missing; do
		eval "[ \"\$${opt_ri}_lists\" ] && echolog -warn \"$opt_ri ip lists in the firewall: '\$${opt_ri}_lists'\""
	done
}

validate_ccode() {
	cca2_path="$conf_dir/cca2.list"
	[ ! -s "$cca2_path" ] && cca2_path="$script_dir/cca2.list"
	[ -s "$cca2_path" ] && export ccode_list="${ccode_list:-"$(cat "$cca2_path")"}"
	case "$ccode_list" in
		'') die "\$ccode_list variable is empty. Perhaps cca2.list is missing?" ;;
		*" $1 "*) return 0 ;;
		*) return 2
	esac
}

detect_ifaces() {
	[ -r "/proc/net/dev" ] && sed -n '/^[[:space:]]*[^[:space:]]*:/{s/^[[:space:]]*//;s/:.*//p}' < /proc/net/dev | grep -vx 'lo'
}

check_cron() {
	[ "$cron_rv" ] && return "$cron_rv"
	unset cron_reboot cron_path
	cron_rv=1
	for cron_cmd in cron crond; do
		pidof "$cron_cmd" 1>/dev/null && cron_path="$(command -v "$cron_cmd")" && {
			cron_rl_path="$(ls -l "$cron_path")" || continue
			case "$cron_rl_path" in *busybox*) ;; *) export cron_reboot=1; esac
			cron_rv=0
			[ ! "$cron_reboot" ] && [ ! "$no_persist" ] && [ ! "$no_cr_persist" ] && continue
			break
		}
	done
	export cron_rv
	return "$cron_rv"
}

check_cron_compat() {
	unset no_cr_persist cr_p1 cr_p2
	[ ! "$_OWRTFW" ] && { cr_p1="s '-n'"; cr_p2="persistence and "; }
	[ "$no_persist" ] || [ "$_OWRTFW" ] && no_cr_persist=1
	if [ "$schedule" != disable ] || [ ! "$no_cr_persist" ] ; then
		for i in 1 2; do
			cron_rv=
			check_cron && {
				[ $i = 2 ] && {
					OK
					printf '%s\n%s\n%s' "Please restart the device after setup." \
						"Then run '$p_name configure' and $p_name will check the cron service again." "Press Enter to continue "
					read -r dummy
				}
				break
			}
			[ $i = 2 ] && { FAIL; die; }
			echolog -err "cron is not running." \
				"The cron service needs to be enabled and started in order for ${cr_p2}automatic ip list updates to work." \
				"If you want to use $p_name without ${cr_p2}automatic ip list updates," \
				"install/configure $p_name with option$cr_p1 '-s disable'."
			[ "$nointeract" ] && {
				[ "$_OWRTFW" ] && echolog "Please run '$p_name configure' in order to have $p_name enable the cron service for you."
				die
			}

			printf '\n%s\n' "Would you like $p_name to enable and start the cron service on this device? [y|n]."
			pick_opt "y|n"
			[ "$REPLY" = n ] && die
			printf '\n%s' "Attempting to enable and start cron... "
			for cron_cmd in cron crond; do
				case "$initsys" in
					systemd) systemctl status $cron_cmd; [ $? = 4 ] && continue
							systemctl is-enabled "$cron_cmd" || systemctl enable "$cron_cmd"
							systemctl start "$cron_cmd" ;;
					sysvinit) checkutil update-rc.d && {
								update-rc.d $cron_cmd enable
								service $cron_cmd start; }
							checkutil chkconfig && {
								chkconfig $cron_cmd on
								service $cron_cmd start; } ;;
					upstart) rm -f "/etc/init/$cron_cmd.override"
				esac

				[ -f "/etc/init.d/$cron_cmd" ] && {
					/etc/init.d/$cron_cmd enable
					/etc/init.d/$cron_cmd start
				}
			done 1>/dev/null 2>/dev/null
		done
		[ ! "$cron_reboot" ] && [ ! "$no_persist" ] && [ ! "$_OWRTFW" ] &&
			die "cron-based persistence doesn't work with Busybox cron." \
			"If you want to install without persistence support, install with option '-n'"
	fi
}

OK() { printf '%s\n' "${green}Ok${n_c}."; }
FAIL() { printf '%s\n' "${red}Failed${n_c}." >&2; }

mk_lock() {
	[ "$1" != '-f' ] && check_lock
	[ "$lock_file" ] && echo "$$" > "$lock_file" || die "$FAIL set lock '$lock_file'"
	nodie=1
	die_unlock=1
}

rm_lock() {
	[ -f "$lock_file" ] && { rm -f "$lock_file" 2>/dev/null; unset nodie die_unlock; }
}

check_lock() {
	[ ! -f "$lock_file" ] && return 0
	[ ! "$lock_file" ] && die "The \$lock_file var is unset!"
	used_pid="$(cat "${lock_file}")"
	[ "$used_pid" ] && kill -0 "$used_pid" 2>/dev/null &&
	die 0 "Lock file $lock_file claims that $p_name (PID $used_pid) is doing something in the background. Refusing to open another instance."
	echolog "Removing stale lock file ${lock_file}."
	rm_lock
	return 0
}

validate_ip() {
	[ ! "$1" ] && { echolog -err "validate_ip: received an empty string."; return 1; }
	ipset_type=ip; family="$2"; o_ips=
	sp2nl i_ips "$1"
	case "$family" in
		inet|ipv4) family=ipv4 ip_len=32 ;;
		inet6|ipv6) family=ipv6 ip_len=128 ;;
		*) echolog -err "Invalid family '$family'."; return 1
	esac
	eval "ip_regex=\"\$${family}_regex\""

	newifs "$_nl"
	for i_ip in $i_ips; do
		case "$i_ip" in */*)
			ipset_type=net
			_mb="${i_ip#*/}"
			case "$_mb" in ''|*[!0-9]*)
				echolog -err "Invalid mask bits '$_mb' in subnet '$i_ip'."; oldifs; return 1; esac
			i_ip="${i_ip%%/*}"
			case $(( (_mb<8) | (_mb>ip_len) )) in 1) echolog -err "Invalid $family mask bits '$_mb'."; oldifs; return 1; esac
		esac

		ip route get "$i_ip" 1>/dev/null 2>/dev/null
		case $? in 0|2) ;; *) echolog -err "ip address '$i_ip' failed kernel validation."; oldifs; return 1; esac
		o_ips="$o_ips$i_ip$_nl"
	done
	oldifs
	printf '%s\n' "${o_ips%"$_nl"}" | grep -vE "^$ip_regex$" > /dev/null
	[ $? != 1 ] && { echolog -err "'$i_ips' failed regex validation."; return 1; }
	:
}

unisleep() {
	sleep 0.1 2>/dev/null || sleep 1
}

valid_sources="ripe ipdeny"
valid_families="ipv4 ipv6"

ripe_url_stats="ftp.ripe.net/pub/stats"
ripe_url_api="stat.ripe.net/data/country-resource-list/data.json?"
ipdeny_ipv4_url="www.ipdeny.com/ipblocks/data/aggregated"
ipdeny_ipv6_url="www.ipdeny.com/ipv6/ipaddresses/aggregated"

: "${me:="${0##*/}"}"
me_short="${me#"${p_name}-"}"
me_short="${me_short%.sh}"

trap_args_unlock='[ -f $lock_file ] && [ $$ = $(cat $lock_file 2>/dev/null) ] && rm -f $lock_file 2>/dev/null; exit;'

sp8="        "
sp16="$sp8$sp8"
ccodes_syn="<\"country_codes\">"
ccodes_usage="$ccodes_syn : 2-letter country codes to include in whitelist/blacklist. If passing multiple country codes, use double quotes."
srcs_syn="<ripe|ipdeny>"
sources_usage="$srcs_syn : Use this ip list source for download. Supported sources: ripe, ipdeny."
fam_syn="<ipv4|ipv6|\"ipv4 ipv6\">"
families_usage="$fam_syn : Families (defaults to 'ipv4 ipv6'). Use double quotes for multiple families."
list_ids_usage="<\"list_ids\">  : iplist id's in the format <country_code>_<family> (if specifying multiple list id's, use double quotes)"

set -f

if [ -z "$geotag" ]; then
	set_ansi
	export WARN="${yellow}Warning${n_c}:" ERR="${red}Error${n_c}:" FAIL="${red}Failed${n_c} to" IFS="$default_IFS"
	[ ! "$in_install" ] && [ "$conf_file" ] && [ -s "$conf_file" ] && [ "$root_ok" ] && {
		getconfig datadir
		export datadir status_file="$datadir/status"
	}
	geotag="$p_name"
	toupper geochain "$geotag"
	export geotag geochain
fi

:
