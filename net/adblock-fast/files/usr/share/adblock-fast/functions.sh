#!/bin/sh
# Copyright 2023 MOSSDeF, Stan Grishin (stangri@melmac.ca)
# shellcheck disable=SC2018,SC2019,SC2034,SC3037,SC3043,SC3057,SC3060

readonly PKG_VERSION='dev-test'
readonly packageName='adblock-fast'
readonly serviceName="$packageName $PKG_VERSION"
readonly packageConfigFile="/etc/config/${packageName}"
readonly dnsmasqAddnhostsFile="/var/run/${packageName}/dnsmasq.addnhosts"
readonly dnsmasqAddnhostsCache="/var/run/${packageName}/dnsmasq.addnhosts.cache"
readonly dnsmasqAddnhostsGzip="${packageName}.dnsmasq.addnhosts.gz"
readonly dnsmasqAddnhostsFilter='s|^|127.0.0.1 |;s|$||'
readonly dnsmasqAddnhostsFilterIPv6='s|^|:: |;s|$||'
readonly dnsmasqConfFile="/tmp/dnsmasq.d/${packageName}"
readonly dnsmasqConfCache="/var/run/${packageName}/dnsmasq.conf.cache"
readonly dnsmasqConfGzip="${packageName}.dnsmasq.conf.gz"
readonly dnsmasqConfFilter='s|^|local=/|;s|$|/|'
readonly dnsmasqIpsetFile="/tmp/dnsmasq.d/${packageName}.ipset"
readonly dnsmasqIpsetCache="/var/run/${packageName}/dnsmasq.ipset.cache"
readonly dnsmasqIpsetGzip="${packageName}.dnsmasq.ipset.gz"
readonly dnsmasqIpsetFilter='s|^|ipset=/|;s|$|/adb|'
readonly dnsmasqNftsetFile="/tmp/dnsmasq.d/${packageName}.nftset"
readonly dnsmasqNftsetCache="/var/run/${packageName}/dnsmasq.nftset.cache"
readonly dnsmasqNftsetGzip="${packageName}.dnsmasq.nftset.gz"
readonly dnsmasqNftsetFilter='s|^|nftset=/|;s|$|/4#inet#fw4#adb4|'
readonly dnsmasqNftsetFilterIPv6='s|^|nftset=/|;s|$|/4#inet#fw4#adb4,6#inet#fw4#adb6|'
readonly dnsmasqServersFile="/var/run/${packageName}/dnsmasq.servers"
readonly dnsmasqServersCache="/var/run/${packageName}/dnsmasq.servers.cache"
readonly dnsmasqServersGzip="${packageName}.dnsmasq.servers.gz"
readonly dnsmasqServersFilter='s|^|server=/|;s|$|/|'
readonly unboundFile="/var/lib/unbound/adb_list.${packageName}"
readonly unboundCache="/var/run/${packageName}/unbound.cache"
readonly unboundGzip="${packageName}.unbound.gz"
readonly unboundFilter='s|^|local-zone: "|;s|$|" static|'
readonly A_TMP="/var/${packageName}.hosts.a.tmp"
readonly B_TMP="/var/${packageName}.hosts.b.tmp"
readonly jsonFile="/dev/shm/$packageName-status.json"
readonly sharedMemoryError="/dev/shm/$packageName-error"
readonly hostsFilter='/localhost/d;/^#/d;/^[^0-9]/d;s/^0\.0\.0\.0.//;s/^127\.0\.0\.1.//;s/[[:space:]]*#.*$//;s/[[:cntrl:]]$//;s/[[:space:]]//g;/[`~!@#\$%\^&\*()=+;:"'\'',<>?/\|[{}]/d;/]/d;/\./!d;/^$/d;/[^[:alnum:]_.-]/d;'
readonly domainsFilter='/^#/d;s/[[:space:]]*#.*$//;s/[[:space:]]*$//;s/[[:cntrl:]]$//;/[[:space:]]/d;/[`~!@#\$%\^&\*()=+;:"'\'',<>?/\|[{}]/d;/]/d;/\./!d;/^$/d;/[^[:alnum:]_.-]/d;'
readonly adBlockPlusFilter='/^#/d;/^!/d;s/[[:space:]]*#.*$//;s/^||//;s/\^$//;s/[[:space:]]*$//;s/[[:cntrl:]]$//;/[[:space:]]/d;/[`~!@#\$%\^&\*()=+;:"'\'',<>?/\|[{}]/d;/]/d;/\./!d;/^$/d;/[^[:alnum:]_.-]/d;'
readonly dnsmasqFileFilter='\|^server=/[[:alnum:]_.-].*/|!d;s|server=/||;s|/.*$||'
readonly dnsmasq2FileFilter='\|^local=/[[:alnum:]_.-].*/|!d;s|local=/||;s|/.*$||'
readonly dnsmasq3FileFilter='\|^address=/[[:alnum:]_.-].*/|!d;s|address=/||;s|/.*$||'
readonly _ERROR_='\033[0;31mERROR\033[0m'
readonly _OK_='\033[0;32m\xe2\x9c\x93\033[0m'
readonly _FAIL_='\033[0;31m\xe2\x9c\x97\033[0m'
readonly __OK__='\033[0;32m[\xe2\x9c\x93]\033[0m'
readonly __FAIL__='\033[0;31m[\xe2\x9c\x97]\033[0m'
readonly _WARNING_='\033[0;33mWARNING\033[0m'
# shellcheck disable=SC2155
readonly ipset="$(command -v ipset)"
# shellcheck disable=SC2155
readonly nft="$(command -v nft)"
readonly canaryDomainsMozilla='use-application-dns.net'
readonly canaryDomainsiCloud='mask.icloud.com mask-h2.icloud.com'

dl_command=
dl_flag=
isSSLSupported=
outputFilter=
outputFilterIPv6=
outputFile=
outputGzip=
outputCache=
awk='awk'
load_environment_flag=
allowed_url=
blocked_url=

# shellcheck disable=SC1091
. /lib/functions.sh
# shellcheck disable=SC1091
. /lib/functions/network.sh
# shellcheck disable=SC1091
. /usr/share/libubox/jshn.sh

check_ipset() { { command -v ipset && /usr/sbin/ipset help hash:net; } >/dev/null 2>&1; }
check_nft() { command -v nft >/dev/null 2>&1; }
check_dnsmasq() { command -v dnsmasq >/dev/null 2>&1; }
check_dnsmasq_ipset() {
	local o;
	check_dnsmasq || return 1
	o="$(dnsmasq -v 2>/dev/null)"
	check_ipset && ! echo "$o" | grep -q 'no-ipset' && echo "$o" | grep -q 'ipset'
}
check_dnsmasq_nftset() {
	local o;
	check_dnsmasq || return 1
	o="$(dnsmasq -v 2>/dev/null)"
	check_nft && ! echo "$o" | grep -q 'no-nftset' && echo "$o" | grep -q 'nftset'
}
check_unbound() { command -v unbound >/dev/null 2>&1; }
debug() { local i j; for i in "$@"; do eval "j=\$$i"; echo "${i}: ${j} "; done; }
dnsmasq_hup() { killall -q -s HUP dnsmasq; }
dnsmasq_kill() { killall -q -s KILL dnsmasq; }
dnsmasq_restart() { /etc/init.d/dnsmasq restart >/dev/null 2>&1; }
is_enabled() { uci -q get "${1}.config.enabled"; }
is_greater() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }
is_greater_or_equal() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" = "$2"; }
is_present() { command -v "$1" >/dev/null 2>&1; }
is_running() {
	local i j
	i="$(json 'get' 'status')"
	j="$(ubus_get_data 'status')"
	if [ "$i" = 'statusStopped' ] || [ -z "${i}${j}" ]; then
		return 1
	else
		return 0
	fi
}
ipset() { "$ipset" "$@" >/dev/null 2>&1; }
get_version() { grep -m1 -A2 -w "^Package: $1$" /usr/lib/opkg/status | sed -n 's/Version: //p'; }
led_on(){ if [ -n "${1}" ] && [ -e "${1}/trigger" ]; then echo 'default-on' > "${1}/trigger" 2>&1; fi; }
led_off(){ if [ -n "${1}" ] &&  [ -e "${1}/trigger" ]; then echo 'none' > "${1}/trigger" 2>&1; fi; }
logger() { /usr/bin/logger -t "$packageName" "$@"; }
nft() { "$nft" "$@" >/dev/null 2>&1; }
output_ok() { output 1 "$_OK_"; output 2 "$__OK__\\n"; }
output_okn() { output 1 "$_OK_\\n"; output 2 "$__OK__\\n"; }
output_fail() { output 1 "$_FAIL_"; output 2 "$__FAIL__\\n"; }
output_failn() { output 1 "$_FAIL_\\n"; output 2 "$__FAIL__\\n"; }
print_json_bool() { json_init; json_add_boolean "$1" "$2"; json_dump; json_cleanup; }
print_json_int() { json_init; json_add_int "$1" "$2"; json_dump; json_cleanup; }
print_json_string() { json_init; json_add_string "$1" "$2"; json_dump; json_cleanup; }
sanitize_dir() { [ -d "$(readlink -fn "$1")" ] && readlink -fn "$1"; }
str_contains() { test "$1" != "$(str_replace "$1" "$2" '')"; }
str_contains_word() { echo "$1" | grep -q -w "$2"; }
str_to_lower() { echo "$1" | tr 'A-Z' 'a-z'; }
str_to_upper() { echo "$1" | tr 'a-z' 'A-Z'; }
str_replace() { printf "%b" "$1" | sed -e "s/$(printf "%b" "$2")/$(printf "%b" "$3")/g"; }
ubus_get_data() { ubus call service list "{ 'name': '$packageName' }" | jsonfilter -e "@['${packageName}'].instances.main.data.${1}"; }
ubus_get_ports() { ubus call service list "{ 'name': '$packageName' }" | jsonfilter -e "@['${packageName}'].instances.main.data.firewall.*.dest_port"; }
unbound_restart() { /etc/init.d/unbound restart >/dev/null 2>&1; }

json() {
# shellcheck disable=SC2034
	local action="$1" param="$2" value="$3"
	shift 3
# shellcheck disable=SC2124
	local extras="$@" line
	local status message error stats
	local reload restart curReload curRestart ret i
	if [ -s "$jsonFile" ]; then
		json_load_file "$jsonFile" 2>/dev/null
		json_select 'data' 2>/dev/null
		for i in status message error stats reload restart; do
			json_get_var "$i" "$i" 2>/dev/null
		done
	fi
	case "$action" in
		get)
			case "$param" in
				triggers)
# shellcheck disable=SC2154
					curReload="$parallel_downloads $debug $download_timeout \
						$allowed_domain $blocked_domain $allowed_url $blocked_url $dns \
						$config_update_enabled $config_update_url $dnsmasq_config_file_url \
						$curl_additional_param $curl_max_file_size $curl_retry"
# shellcheck disable=SC2154
					curRestart="$compressed_cache $compressed_cache_dir $force_dns $led \
						$force_dns_port"
					if [ ! -s "$jsonFile" ]; then
						ret='on_boot'
					elif [ "$curReload" != "$reload" ]; then
						ret='download'
					elif [ "$curRestart" != "$restart" ]; then
						ret='restart'
					fi
					printf "%b" "$ret"
					return;;
				*)
					printf "%b" "$(eval echo "\$$param")"; return;;
			esac
		;;
		add)
			line="$(eval echo "\$$param")"
			eval "$param"='${line:+$line }${value}${extras:+|$extras}'
		;;
		del)
			case "$param" in
				all)
					unset status message error stats;;
				triggers) 
					unset reload restart;;
				*)
					unset "$param";;
			esac
		;;
		set)
			case "$param" in
				triggers) 
					reload="$parallel_downloads $debug $download_timeout \
						$allowed_domain $blocked_domain $allowed_url $blocked_url $dns \
						$config_update_enabled $config_update_url $dnsmasq_config_file_url \
						$curl_additional_param $curl_max_file_size $curl_retry"
					restart="$compressed_cache $compressed_cache_dir $force_dns $led \
						$force_dns_port"
				;;
				*)
					eval "$param"='${value}${extras:+|$extras}';;
			esac
		;;
	esac
	json_init
	json_add_object 'data'
	json_add_string version "$PKG_VERSION"
	json_add_string status "$status"
	json_add_string message "$message"
	json_add_string error "$error"
	json_add_string stats "$stats"
	json_add_string reload "$reload"
	json_add_string restart "$restart"
	json_close_object
	mkdir -p "$(dirname "$jsonFile")"
	json_dump > "$jsonFile"
	sync
}

get_local_filesize() {
	local file="$1" size
	[ -f "$file" ] || return 0
	if is_present stat; then
		size="$(stat -c%s "$file")"
	elif is_present wc; then
		size="$(wc -c < "$file")"
	fi
	echo -en "$size"
}

get_url_filesize() {
	local url="$1" size size_command
	[ -n "$url" ] || return 0
	is_present 'curl' || return 0
	size_command='curl --silent --insecure --fail --head --request GET'
	size="$($size_command "$url" | grep -Po '^[cC]ontent-[lL]ength: \K\w+')"
	echo -en "$size"
}

output() {
# Target verbosity level with the first parameter being an integer
	is_integer() {
		case "$1" in
			(*[!0123456789]*) return 1;;
			('')              return 1;;
			(*)               return 0;;
		esac
	}
	local msg memmsg logmsg text
	local sharedMemoryOutput="/dev/shm/$packageName-output"
	if [ -z "$verbosity" ] && [ -n "$packageName" ]; then
		verbosity="$(uci -q get "$packageName.config.verbosity")"
	fi
	verbosity="${verbosity:-2}"
	if [ $# -ne 1 ] && is_integer "$1"; then
		if [ $((verbosity & $1)) -gt 0 ] || [ "$verbosity" = "$1" ]; then shift; text="$*"; else return 0; fi
	fi
	text="${text:-$*}";
	[ -t 1 ] && printf "%b" "$text"
	msg="${text//$serviceName /service }";
	if [ "$(printf "%b" "$msg" | wc -l)" -gt 0 ]; then
		[ -s "$sharedMemoryOutput" ] && memmsg="$(cat "$sharedMemoryOutput")"
		logmsg="$(printf "%b" "${memmsg}${msg}" | sed 's/\x1b\[[0-9;]*m//g')"
		logger -t "${packageName:-service} [$$]" "$(printf "%b" "$logmsg")"
		rm -f "$sharedMemoryOutput"
	else
		printf "%b" "$msg" >> "$sharedMemoryOutput"
	fi
}

uci_add_list_if_new() {
	local PACKAGE="$1"
	local CONFIG="$2"
	local OPTION="$3"
	local VALUE="$4"
	local i
	[ -n "$PACKAGE" ] && [ -n "$CONFIG" ] && [ -n "$OPTION" ] && [ -n "$VALUE" ] || return 1
	for i in $(uci_get "$PACKAGE" "$CONFIG" "$OPTION"); do
		[ "$i" = "$VALUE" ] && return 0
	done
	uci_add_list "$PACKAGE" "$CONFIG" "$OPTION" "$VALUE"
}

uci_changes() {
	local PACKAGE="$1"
	local CONFIG="$2"
	local OPTION="$3"
	/sbin/uci ${UCI_CONFIG_DIR:+-c $UCI_CONFIG_DIR} changes "$PACKAGE${CONFIG:+.$CONFIG}${OPTION:+.$OPTION}"
}
