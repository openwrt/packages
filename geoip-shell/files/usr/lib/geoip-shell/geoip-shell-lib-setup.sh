#!/bin/sh

curr_ver=0.4.7

# Copyright: antonk (antonk.d3v@gmail.com)
# github.com/friendly-bits

. "$_lib-ip-regex.sh"

validate_arg_ccodes() {
	bad_ccodes=
	for ccode in $ccodes_arg; do
		validate_ccode "$ccode"
		case $? in
			1) die "Internal error while validating country codes." ;;
			2) bad_ccodes="$bad_ccodes$ccode "
		esac
	done
	[ "$bad_ccodes" ] && die "Invalid 2-letters country codes: '${bad_ccodes% }'."
}

pick_user_ccode() {
	[ "$user_ccode_arg" = none ] || { [ "$nointeract" ] && [ ! "$user_ccode_arg" ]; } && { user_ccode=none; return 0; }

	[ ! "$user_ccode_arg" ] && printf '\n%s\n%s\n' "${blue}Please enter your country code.$n_c" \
		"It will be used to check if your geoip settings may block your own country and warn you if so."
	REPLY="$user_ccode_arg"
	while true; do
		[ ! "$REPLY" ] && {
			printf %s "Country code (2 letters)/Enter to skip: "
			read -r REPLY
		}
		case "$REPLY" in
			'') printf '%s\n\n' "Skipped."; user_ccode=none; return 0 ;;
			*)
				is_alphanum "$REPLY" || {
					REPLY=
					[ "$nointeract" ] && die 1
					continue
				}
				toupper REPLY
				validate_ccode "$REPLY"; rv=$?
				case "$rv" in
					0)  user_ccode="$REPLY"; break ;;
					1)  die "Internal error while trying to validate country codes." ;;
					2)  printf '\n%s\n' "'$REPLY' is not a valid 2-letter country code."
						[ "$nointeract" ] && die 1
						printf '%s\n\n' "Try again or press Enter to skip this check."
						REPLY=
				esac
		esac
	done
}

pick_ccodes() {
	[ "$nointeract" ] && [ ! "$ccodes_arg" ] && die "Specify country codes with '-c <\"country_codes\">'."
	[ ! "$ccodes_arg" ] && printf '\n%s\n' "${blue}Please enter country codes to include in geoip $geomode.$n_c"
	REPLY="$ccodes_arg"
	while true; do
		unset bad_ccodes ok_ccodes
		[ ! "$REPLY" ] && {
			printf %s "Country codes (2 letters) or [a] to abort: "
			read -r REPLY
		}
		case "$REPLY" in *[!A-Za-z\ ,\;]*)
			printf '%s\n' "Invalid country codes '$REPLY'" >&2
			REPLY=
			[ "$nointeract" ] && die 1
			continue
		esac
		toupper REPLY
		trimsp REPLY
		case "$REPLY" in
			a|A) die 0 ;;
			*)
				newifs ' ;,' pcc
				for ccode in $REPLY; do
					[ "$ccode" ] && {
						validate_ccode "$ccode" && ok_ccodes="$ok_ccodes$ccode " ||
							bad_ccodes="$bad_ccodes$ccode "
					}
				done
				oldifs pcc
				[ "$bad_ccodes" ] && {
					printf '%s\n' "Invalid 2-letter country codes: '${bad_ccodes% }'."
					[ "$nointeract" ] && die 1
					REPLY=
					continue
				}
				[ ! "$ok_ccodes" ] && {
					printf '%s\n' "No country codes detected in '$REPLY'."
					[ "$nointeract" ] && die 1
					REPLY=
					continue
				}
				ccodes="${ok_ccodes% }"; break
		esac
	done
}

pick_geomode() {
	printf '\n%s\n' "${blue}Select geoip blocking mode:$n_c [w]hitelist or [b]lacklist, or [a] to abort."
	pick_opt "w|b|a"
	case "$REPLY" in
		w|W) geomode=whitelist ;;
		b|B) geomode=blacklist ;;
		a|A) die 0
	esac
}

pick_ifaces() {
	all_ifaces="$(detect_ifaces)" || die "$FAIL detect network interfaces."

	[ ! "$ifaces_arg" ] && {
		auto_ifaces=
		[ "$_OWRTFW" ] && auto_ifaces="$(fw$_OWRTFW zone wan)"

		[ ! "$auto_ifaces" ] && auto_ifaces="$({ ip r get 1; ip -6 r get 1::; } 2>/dev/null |
			sed 's/.*[[:space:]]dev[[:space:]][[:space:]]*//;s/[[:space:]].*//' | grep -vx 'lo')"
		san_str -n auto_ifaces
		get_intersection "$auto_ifaces" "$all_ifaces" auto_ifaces "$_nl"
		nl2sp auto_ifaces
	}

	nl2sp all_ifaces
	printf '\n%s\n' "${yellow}*NOTE*: ${blue}Geoip firewall rules will be applied to specific network interfaces of this machine.$n_c"
	[ ! "$ifaces_arg" ] && [ "$auto_ifaces" ] && {
		printf '%s\n%s\n' "All found network interfaces: $all_ifaces" \
			"Autodetected WAN interfaces: $blue$auto_ifaces$n_c"
		[ "$1" = "-a" ] && { ifaces="$auto_ifaces"; return; }
		printf '%s\n' "[c]onfirm, c[h]ange, or [a]bort?"
		pick_opt "c|h|a"
		case "$REPLY" in
			c|C) ifaces="$auto_ifaces"; return ;;
			a|A) die 0
		esac
	}

	REPLY="$ifaces_arg"
	while true; do
		u_ifaces=
		printf '\n%s\n' "All found network interfaces: $all_ifaces"
		[ ! "$REPLY" ] && {
			printf '%s\n' "Type in WAN network interface names, or [a] to abort."
			read -r REPLY
			case "$REPLY" in a|A) die 0; esac
		}
		is_alphanum "$REPLY" || {
				REPLY=
				[ "$nointeract" ] && die
				continue
		}
		san_str u_ifaces "$REPLY"
		[ -z "$u_ifaces" ] && {
			printf '%s\n' "No interface names detected in '$REPLY'." >&2
			REPLY=
			[ "$nointeract" ] && die
			continue
		}
		subtract_a_from_b "$all_ifaces" "$u_ifaces" bad_ifaces
		[ -z "$bad_ifaces" ] && break
		echolog -err "Network interfaces '$bad_ifaces' do not exist in this system."
		echo
		[ "$nointeract" ] && die
		REPLY=
	done
	ifaces="$u_ifaces"
	printf '%s\n' "Selected interfaces: '$ifaces'."
}

validate_arg_ips() {
	va_ips_a=
	sp2nl va_ips_i "$1"
	san_str -n va_ips_i
	[ ! "$va_ips_i" ] && { echolog -err "No ip's detected in '$1'."; return 1; }
	for f in $families; do
		unset "va_$f" ipset_type
		eval "ip_regex=\"\$${f}_regex\" mb_regex=\"\$maskbits_regex_$f\""
		va_ips_f="$(printf '%s\n' "$va_ips_i" | grep -E "^${ip_regex}(/$mb_regex){0,1}$")"
		[ "$va_ips_f" ] && {
			validate_ip "$va_ips_f" "$f" || return 1
			nl2sp "va_$f" "$ipset_type:$va_ips_f"
		}
		va_ips_a="$va_ips_a$va_ips_f$_nl"
	done
	subtract_a_from_b "$va_ips_a" "$va_ips_i" bad_ips "$_nl" ||
		{ nl2sp bad_ips; echolog -err "Invalid ip's: '$bad_ips'"; return 1; }

	for f in $families; do
		eval "${2}_$f=\"\$va_$f\""
	done
	:
}

pick_lan_ips() {
	confirm_ips() { eval "lan_ips_$family=\"$ipset_type:$u_ips\""; }

	lan_picked=1
	unset autodetect ipset_type u_ips lan_ips_ipv4 lan_ips_ipv6
	case "$lan_ips_arg" in
		none) return 0 ;;
		auto) lan_ips_arg=''; autodetect=1
	esac

	[ "$lan_ips_arg" ] && validate_arg_ips "$lan_ips_arg" lan_ips && return 0

	[ "$nointeract" ] && [ ! "$autodetect" ] && die "Specify lan ip's with '-l <\"lan_ips\"|auto|none>'."

	[ ! "$nointeract" ] && {
		[ ! "$autodetect" ] && echo "You can specify LAN subnets and/or individual ip's to allow."
	}

	for family in $families; do
		printf '\n%s\n' "Detecting $family LAN subnets..."
		u_ips="$(call_script "$_script-detect-lan.sh" -s -f "$family")" || {
			echolog -err "$FAIL detect $family LAN subnets."
			[ "$nointeract" ] && die
		}

		[ -n "$u_ips" ] && {
			nl2sp u_ips
			ipset_type="net"
			printf '\n%s\n' "Autodetected $family LAN subnets: '$blue$u_ips$n_c'."
			[ "$autodetect" ] && { confirm_ips; continue; }
			printf '%s\n%s\n' "[c]onfirm, c[h]ange, [s]kip or [a]bort?" \
				"Verify that correct LAN subnets have been detected in order to avoid accidental lockout or other problems."
			pick_opt "c|h|s|a"
			case "$REPLY" in
				c|C) confirm_ips; continue ;;
				s|S) continue ;;
				h|H) autodetect_off=1 ;;
				a|A) die 0
			esac
		}

		while true; do
			unset REPLY u_ips
			ipset_type=ip
			[ ! "$nointeract" ] && {
				printf '\n%s\n' "Type in $family LAN ip addresses and/or subnets, [s] to skip or [a] to abort."
				read -r REPLY
				case "$REPLY" in
					s|S) break ;;
					a|A) die 0
				esac
			}
			case "$REPLY" in *[!A-Za-z0-9.:/\ ]*)
				printf '%s\n' "Invalid ip's '$REPLY'"
				REPLY=
				[ "$nointeract" ] && die
				continue
			esac
			san_str u_ips "$REPLY"
			[ -z "$u_ips" ] && { [ "$nointeract" ] && die; continue; }
			validate_ip "$u_ips" "$family" && break
		done
		confirm_ips
	done

	[ "$autodetect" ] || [ "$autodetect_off" ] && return
	printf '\n%s\n' "${blue}A[u]to-detect LAN subnets when updating ip lists or keep this config c[o]nstant?$n_c"
	pick_opt "u|o"
	case "$REPLY" in u|U) autodetect="1"; esac
}

invalid_str() { echolog -err "Invalid string '$1'."; }

check_edge_chars() {
	[ "${1%"${1#?}"}" = "$2" ] && { invalid_str "$1"; return 1; }
	[ "${1#"${1%?}"}" = "$2" ] && { invalid_str "$1"; return 1; }
	:
}

parse_ports() {
	check_edge_chars "$_ranges" "," || return 1
	ranges_cnt=0
	IFS=","
	for _range in $_ranges; do
		ranges_cnt=$((ranges_cnt+1))
		trimsp _range
		check_edge_chars "$_range" "-" || return 1
		case "${_range#*-}" in *-*) invalid_str "$_range"; return 1; esac
		IFS="-"
		for _port in $_range; do
			trimsp _port
			case "$_port" in *[!0-9]*) invalid_str "$_port"; return 1; esac
			_ports="$_ports$_port$p_delim"
		done
		_ports="${_ports%"$p_delim"},"
		case "$_range" in *-*) [ "${_range%-*}" -ge "${_range##*-}" ] && { invalid_str "$_range"; return 1; }; esac
	done
	[ "$ranges_cnt" = 0 ] && { echolog -err "No ports specified for protocol $_proto."; return 1; }
	_ports=":${_ports%,}"

	[ "$_fw_backend" = ipt ] && [ "$ranges_cnt" -gt 1 ] && mp="multiport"
	:
}

setports() {
	tolower _lines "$1"
	newifs "$_nl" sp
	for _line in $_lines; do
		unset ranges _ports neg mp skip
		trimsp _line
		check_edge_chars "$_line" ":" || return 1
		IFS=':'
		set -- $_line
		[ $# != 3 ] && { echolog -err "Invalid syntax '$_line'"; return 1; }
		_proto="$1"
		p_delim='-'
		proto_act="$2"
		_ranges="$3"
		trimsp _ranges
		trimsp _proto
		trimsp proto_act
		case "$proto_act" in
			allow) neg='' ;;
			block) neg='!' ;;
			*) { echolog -err "Expected 'allow' or 'block' instead of '$proto_act'"; return 1; }
		esac
		case $_proto in
			udp|tcp) case "$reg_proto" in *"$_proto"*) echolog -err "Can't add protocol '$_proto' twice"; return 1; esac
				reg_proto="$reg_proto$_proto " ;;
			*) echolog -err "Unsupported protocol '$_proto'."; return 1
		esac

		if [ "$_ranges" = all ]; then
			_ports=
			[ "$neg" ] && ports_exp=skip || ports_exp=all
		else
			parse_ports || return 1
			ports_exp="$mp ${neg}dport"
		fi
		trimsp ports_exp
		eval "${_proto}_ports=\"$ports_exp$_ports\""
		
	done
	oldifs sp
}

warn_lockout() {
	printf '\n\n%s\n' \
	"${yellow}*NOTE*${n_c}: ${blue}In whitelist mode, traffic from your LAN subnets will be blocked, unless you whitelist them.$n_c"
}

set_defaults() {
	if [ "$_OWRTFW" ]; then
		geosource_def=ipdeny datadir_def="/tmp/$p_name-data" nobackup_def=true
		case "$_OWRTFW" in
			3) _fw_backend=ipt ;;
			4) _fw_backend=nft
		esac
	else
		geosource_def=ripe datadir_def="/var/lib/$p_name" nobackup_def=false
		. "$_lib-check-compat.sh" || exit 1
		[ ! "$_fw_backend_arg" ] && {
			if check_fw_backend nft; then
				_fw_backend_def=nft
			elif check_fw_backend ipt; then
				_fw_backend_def=ipt
			fi
		} 2>/dev/null
	fi

	: "${nobackup:="$nobackup_def"}"
	: "${datadir:="$datadir_def"}"
	: "${schedule:="15 4 * * *"}"
	: "${families:="ipv4 ipv6"}"
	: "${geosource:="$geosource_def"}"
	: "${_fw_backend:="$_fw_backend_def"}"
	: "${tcp_ports:=skip}"
	: "${udp_ports:=skip}"
	: "${nft_perf:=memory}"
	: "${reboot_sleep:=30}"
	: "${max_attempts:=30}"
}

get_prefs() {
	set_defaults

	[ "$_fw_backend_arg" ] && [ "$_OWRTFW" ] && die "Changing the firewall backend is unsupported on OpenWrt."
	[ ! "$_OWRTFW" ] && {
		_fw_backend="${_fw_backend_arg:-$_fw_backend}"
		[ ! "$_fw_backend" ] && die "Neither nftables nor iptables+ipset found."
		check_fw_backend "$_fw_backend" || die
	}

	[ "$nft_perf_arg" ] && {
		[ "$_fw_backend" = ipt ] && die "Option -O does not work with iptables+ipset."
		tolower nft_perf_arg
	}
	case "$nft_perf_arg" in
		''|performance|memory) ;;
		*) die "Invalid value for option '-O': '$nft_perf_arg'."
	esac
	nft_perf="${nft_perf_arg:=$nft_perf}"

	[ "$nobackup_arg" ] && tolower nobackup_arg
	case "$nobackup_arg" in
		''|true|false) ;;
		*) die "Invalid value for option '-o': '$nobackup_arg'."
	esac
	nobackup="${nobackup_arg:=$nobackup}"

	[ "$datadir_arg" ] && {
		datadir_new="${datadir_arg%/}"
		[ ! "$datadir_new" ] && die "Invalid directory '$datadir_arg'."
		case "$datadir_new" in */*) ;; *) die "Invalid directory '$datadir_arg'."; esac
		[ "$datadir_new" != "$datadir" ] && {
			{ find "$datadir_new" -mindepth 1 -maxdepth 1 | grep .; } 1>/dev/null 2>/dev/null &&
				die "Can not create '$datadir_arg': it exists and is not empty."
		}
		parent_dir="${datadir_new%/*}/"
		[ ! -d "$parent_dir" ] && die "Can not create '$datadir_arg': parent directory '$parent_dir' doesn't exist."
	}
	datadir="${datadir_new:-"$datadir"}"

	schedule="${schedule_arg:-"$schedule"}"

	check_cron_compat
	[ "$schedule_arg" ] && [ "$schedule_arg" != disable ] && {
		call_script "$_script-cronsetup.sh" -x "$schedule_arg" || die "$FAIL validate cron schedule '$schedule_arg'."
	}

	[ "$families_arg" ] && tolower families_arg
	case "$families_arg" in
		'') ;;
		inet|ipv4) families_arg=ipv4 ;;
		inet6|ipv6) families_arg=ipv6 ;;
		'inet inet6'|'inet6 inet'|'ipv4 ipv6'|'ipv6 ipv4') families_arg="ipv4 ipv6" ;;
		*) die "Invalid family '$families_arg'."
	esac
	families="${families_arg:-"$families"}"

	[ "$geosource_arg" ] && tolower geosource_arg
	case "$geosource_arg" in ''|ripe|ipdeny) ;; *) die "Unsupported source: '$geosource_arg'."; esac
	geosource="${geosource_arg:-$geosource}"

	case "$trusted_arg" in
		none) unset trusted_ipv4 trusted_ipv6 ;;
		'') ;;
		*) validate_arg_ips "$trusted_arg" trusted || die
	esac

	[ "$ports_arg" ] && { setports "${ports_arg%"$_nl"}" || die; }

	[ "$geomode_arg" ] || [ ! "$geomode" ] && {
		tolower geomode_arg
		case "$geomode_arg" in
			whitelist|blacklist) geomode="$geomode_arg" ;;
			'') [ "$nointeract" ] && die "Specify geoip blocking mode with -m <whitelist|blacklist>"; pick_geomode ;;
			*) [ "$nointeract" ] && die "Unrecognized geoip mode '$geomode_arg'!"; pick_geomode
		esac
		[ "$geomode" = blacklist ] && unset lan_ips_ipv4 lan_ips_ipv6
	}

	[ "$lan_ips_arg" ] && [ "$lan_ips_arg" != none ] && [ "$geomode" = blacklist ] &&
		die "Option '-l' is incompatible with mode 'blacklist'."

	{ [ ! "$ccodes" ] && [ ! "$iplists" ]; } || [ "$geomode_change" ] || [ "$ccodes_arg" ] && pick_ccodes
	[ ! "$user_ccode" ] || [ "$user_ccode_arg" ] && pick_user_ccode

	lan_picked=

	if [ ! "$ifaces" ] && [ -z "$ifaces_arg" ]; then
		[ "$nointeract" ] && die "Specify interfaces with -i <\"ifaces\"|auto|all>."
		printf '\n%s\n%s\n%s\n%s\n' "${blue}Does this machine have dedicated WAN network interface(s)?$n_c [y|n] or [a] to abort." \
			"For example, a router or a virtual private server may have it." \
			"A machine connected to a LAN behind a router is unlikely to have it." \
			"It is important to answer this question correctly."
		pick_opt "y|n|a"
		case "$REPLY" in
			a|A) die 0 ;;
			y|Y) pick_ifaces ;;
			n|N) ifaces=all; [ "$geomode" = whitelist ] && { warn_lockout; pick_lan_ips; }
		esac
	elif [ "$ifaces_arg" ]; then
		ifaces=
		case "$ifaces_arg" in
			all) ifaces=all
				[ "$geomode" = whitelist ] && { [ "$in_install" ] || [ "$first_setup" ] || [ "$geomode_change" ] ||
						[ "$ifaces_change" ]; } &&
					{ warn_lockout; pick_lan_ips; } ;;
			auto) ifaces_arg=''; pick_ifaces -a ;;
			*) pick_ifaces
		esac
	elif [ "$geomode_change" ] && [ "$geomode" = whitelist ] && [ ! "$ifaces" ]; then
		warn_lockout; pick_lan_ips
	fi

	[ "$lan_ips_arg" ] &&  [ ! "$lan_picked" ] && pick_lan_ips

	[ "$_OWRTFW" ] && [ ! "$autodetect" ] && detect_lan=
	:
}

[ "$script_dir" = "$install_dir" ] && _script="$i_script" || _script="$p_script"

mode_syn="<whitelist|blacklist>"
geomode_usage="$mode_syn : Geoip blocking mode: whitelist or blacklist."

if_syn="<\"[ifaces]\"|auto|all>"
ifaces_usage="$if_syn :
${sp8}Changes which network interface(s) geoip firewall rules will be applied to.
${sp8}'all' will apply geoip to all network interfaces.
${sp8}'auto' will automatically detect WAN interfaces (this may cause problems if the machine has no direct WAN connection).
${sp8}Generally, if the machine has dedicated WAN interfaces, specify them, otherwise pick 'all'."

lan_syn="<\"[lan_ips]\"|auto|none>"
lan_ips_usage="$lan_syn :
${sp8}Specifies LAN ip's or subnets to exclude from geoip blocking (both ipv4 and ipv6).
${sp8}Only compatible with whitelist mode.
${sp8}Generally, in whitelist mode, if the machine has no dedicated WAN interfaces,
${sp8}specify LAN ip's or subnets to avoid blocking them. Otherwise you probably don't need this.
${sp8}'auto' will automatically detect LAN subnets during installation and at every update of the ip lists.
${sp8}'none' removes previously set LAN ip's and disables the automatic detection.
${sp8}*Don't use 'auto' if the machine has a dedicated WAN interface*"

tr_syn="<\"[trusted_ips]\"|none>"
trusted_ips_usage="$tr_syn :
${sp8}Specifies trusted ip's or subnets to exclude from geoip blocking (both ipv4 and ipv6).
${sp8}This option is independent from the above LAN ip's option.
${sp8}Works both in whitelist and blacklist mode.
${sp8}'none' removes previously set trusted ip's"

ports_syn="<[tcp|udp]:[allow|block]:[all|<ports>]>"
ports_usage="$ports_syn :
${sp8}For given protocol (tcp/udp), use 'block' to only geoblock incoming traffic on specific ports,
${sp8}or use 'allow' to geoblock all incoming traffic except on specific ports.
${sp8}To specify ports for both tcp and udp in one command, use the '-p' option twice."

sch_syn="<\"[expression]\"|disable>"
schedule_usage="$sch_syn :
${sp8}Schedule expression for the periodic cron job implementing automatic update of the ip lists, must be inside double quotes.
${sp8}Default schedule is \"15 4 * * *\" (at 4:15 [am] every day)
${sp8}'disable' will disable automatic updates of the ip lists."

user_ccode_syn="<[user_country_code]|none>"
user_ccode_usage="$user_ccode_syn :
${sp8}Specify user's country code. Used to prevent accidental lockout of a remote machine.
${sp8}'none' disables this feature."

fw_be_syn="<ipt|nft>"
fw_be_usage="$fw_be_syn :
${sp8}Specify firewall backend to use with $p_name. 'ipt' for iptables, 'nft' for nftables.
${sp8}Default is nftables if present in the system."

nft_p_syn="<memory|performance>"
nft_perf_usage="$nft_p_syn :
${sp8}Optimization policy for nftables sets. By default optimizes for low memory consumption. Doesn't work with iptables."

nointeract_usage="Non-interactive setup. Will not ask any questions. Will fail if required options are not specified or invalid."

nobackup_usage="<true|false> :
${sp8}No backup. If set to 'true', $p_name will not create a backup of ip lists and firewall rules state after applying changes,
${sp8}and will automatically re-fetch ip lists after each reboot.
${sp8}Default is 'true' for OpenWrt, 'false' for all other systems."

datadir_usage="<\"path\"> :
${sp8}Set custom path to directory where backups and the status file will be stored.
${sp8}Default is '/tmp/geoip-shell-data' for OpenWrt, '/var/lib/$p_name' for all other systems."

:
