#!/bin/sh

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. /lib/functions/network.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

cfg_format() {
	echo "$1" | sed -r 's/^[[:blank:]]+//;/^[[:space:]]*$/d'
}

_ieee8021xclient_field() {
	local key="$1"
	local value="$2"
	local escaped

	[ -n "$value" ] || return 0

	escaped=$(printf '%s' "$value" | tr -d '\r\n' | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')
	# P"..." makes wpa_supplicant decode backslash escapes.
	printf '\t%s=P"%s"\n' "$key" "$escaped"
}

# eap is a space separated list; refuse characters outside the method
# name alphabet so a typo such as P@EAP cannot silently become PEAP.
_ieee8021xclient_eaplist() {
	local key="$1"
	local value="$2"
	local clean invalid

	[ -n "$value" ] || return 0

	invalid=$(printf '%s' "$value" | tr -d ',;\t\r\n' | tr -d "A-Za-z0-9 _.'-")
	if [ -n "$invalid" ]; then
		_ieee8021xclient_log "invalid character in $key: $value"
		return 1
	fi

	clean=$(printf '%s' "$value" | tr ',;\t\r\n' '     ' |
		tr -s ' ' | sed -e 's/^ //' -e 's/ $//')
	[ -n "$clean" ] || return 1

	printf '\t%s=%s\n' "$key" "$clean"
}

# wpa_supplicant reads hash:/ext: from the raw value before string parsing,
# so P"..." would turn the prefix into a literal password. ext: also needs
# CONFIG_EXT_PASSWORD (off in OpenWrt). Malformed prefixes are rejected.
_ieee8021xclient_password() {
	local value="$1"

	case "$value" in
	hash:?*)
		case "${value#hash:}" in
		*[!0-9a-fA-F]*)
			_ieee8021xclient_log "password: hash: form is not a hex string"
			return 1
			;;
		esac
		printf '\tpassword=%s\n' "$value"
		return $?
		;;
	ext:?*)
		# ext: names are stored verbatim; only control characters matter.
		case "${value#ext:}" in
		*[[:cntrl:]]*)
			_ieee8021xclient_log "password: ext: name has a control character"
			return 1
			;;
		esac
		printf '\tpassword=%s\n' "$value"
		return $?
		;;
	hash:*|ext:*)
		_ieee8021xclient_log "password: empty hash: or ext: form"
		return 1
		;;
	esac

	_ieee8021xclient_field password "$value"
}

ieee8021xclient_exitcode_tostring() {
	local errorcode=$1
	[ -n "$errorcode" ] || errorcode=5

	case "$errorcode" in
		0) echo "OK" ;;
		1) echo "FATAL_ERROR" ;;
		5) echo "USER_REQUEST" ;;
		*) echo "UNKNOWN_ERROR" ;;
	esac
}

_wpa_supplicant_common() {
	local ifname="$1"

	_config="/var/run/wpa_supplicant-$ifname.conf"
	_pid="/var/run/wpa_supplicant-$ifname.pid"
}

proto_ieee8021xclient_setup() {
	local cfg="$1"
	local ifname="$2"

	local eapol_version
	local identity anonymous_identity password
	local ca_cert ca_path client_cert private_key private_key_passwd dh_file
	local subject_match altsubject_match domain_suffix_match domain_match
	local phase1 phase2 ca_cert2 ca_path2 client_cert2 private_key2 private_key_passwd2
	local dh_file2 subject_match2 altsubject_match2 domain_suffix_match2 domain_match2
	local eap
	local eap_workaround
	json_get_vars eapol_version
	json_get_vars identity anonymous_identity password
	json_get_vars ca_cert ca_path client_cert private_key private_key_passwd dh_file
	json_get_vars subject_match altsubject_match domain_suffix_match domain_match
	json_get_vars phase1 phase2 ca_cert2 ca_path2 client_cert2 private_key2 private_key_passwd2
	json_get_vars dh_file2 subject_match2 altsubject_match2 domain_suffix_match2 domain_match2
	json_get_vars eap eap_workaround

	# launch
	local _config _pid
	local old_umask
	_wpa_supplicant_common "$ifname"

	old_umask=$(umask)
	umask 077
	{
		[ -n "$eapol_version" ] && printf 'eapol_version=%s\n' "$eapol_version"
		printf 'ap_scan=0\n'
		printf 'network={\n'
		printf '\tkey_mgmt=IEEE8021X\n'
		printf '\teapol_flags=0\n'
		_ieee8021xclient_field identity "$identity"
		_ieee8021xclient_field anonymous_identity "$anonymous_identity"
		_ieee8021xclient_password "$password"
		_ieee8021xclient_field ca_cert "$ca_cert"
		_ieee8021xclient_field ca_path "$ca_path"
		_ieee8021xclient_field client_cert "$client_cert"
		_ieee8021xclient_field private_key "$private_key"
		_ieee8021xclient_field private_key_passwd "$private_key_passwd"
		_ieee8021xclient_field dh_file "$dh_file"
		_ieee8021xclient_field subject_match "$subject_match"
		_ieee8021xclient_field altsubject_match "$altsubject_match"
		_ieee8021xclient_field domain_suffix_match "$domain_suffix_match"
		_ieee8021xclient_field domain_match "$domain_match"
		_ieee8021xclient_field phase1 "$phase1"
		_ieee8021xclient_field phase2 "$phase2"
		_ieee8021xclient_field ca_cert2 "$ca_cert2"
		_ieee8021xclient_field ca_path2 "$ca_path2"
		_ieee8021xclient_field client_cert2 "$client_cert2"
		_ieee8021xclient_field private_key2 "$private_key2"
		_ieee8021xclient_field private_key2_passwd "$private_key_passwd2"
		_ieee8021xclient_field dh_file2 "$dh_file2"
		_ieee8021xclient_field subject_match2 "$subject_match2"
		_ieee8021xclient_field altsubject_match2 "$altsubject_match2"
		_ieee8021xclient_field domain_suffix_match2 "$domain_suffix_match2"
		_ieee8021xclient_field domain_match2 "$domain_match2"
		_ieee8021xclient_eaplist eap "$eap"
		[ -n "$eap_workaround" ] && printf '\teap_workaround=%s\n' "$eap_workaround"
		printf '}\n'
	} > "$_config" || { rm -f "$_config"; umask "$old_umask"; return 1; }
	umask "$old_umask"

	# The file carries the 802.1X identity and password, so keep it private.
	# wpa_supplicant drops privileges and runs as the "network" user since
	# OpenWrt 21.02, so hand the file to that user instead of making it
	# world readable.
	chown network:network "$_config"
	chmod 600 "$_config"

	ubus wait_for wpa_supplicant
	ubus call wpa_supplicant config_add "{ \"driver\":\"wired\", \"iface\": \"$ifname\", \"config\": \"$_config\" }"
}

proto_ieee8021xclient_teardown() {
	local interface="$1"
	local ifname="$2"
	local errorstring=$(ieee8021xclient_exitcode_tostring $ERROR)

	# netifd passes the interface name first and the device name second.
	# The supplicant is registered under the device name, so config_remove
	# needs the second argument; using the interface name left a stale
	# section behind whenever the two differed.
	[ -n "$ifname" ] || ifname="$interface"

	case "$ERROR" in
		0)
		;;
		2)
			proto_notify_error "$interface" "$errorstring"
			proto_block_restart "$interface"
		;;
		*)
			proto_notify_error "$interface" "$errorstring"
		;;
	esac

	ubus call wpa_supplicant config_remove "{\"iface\":\"$ifname\"}"
}

proto_ieee8021xclient_init_config() {
	proto_config_add_int eapol_version
	proto_config_add_string identity
	proto_config_add_string anonymous_identity
	proto_config_add_string password
	proto_config_add_string 'ca_cert:file'
	proto_config_add_string ca_path
	proto_config_add_string 'client_cert:file'
	proto_config_add_string 'private_key:file'
	proto_config_add_string private_key_passwd
	proto_config_add_string 'dh_file:file'
	proto_config_add_string subject_match
	proto_config_add_string altsubject_match
	proto_config_add_string domain_suffix_match
	proto_config_add_string domain_match
	proto_config_add_string phase1
	proto_config_add_string phase2
	proto_config_add_string 'ca_cert2:file'
	proto_config_add_string ca_path2
	proto_config_add_string 'client_cert2:file'
	proto_config_add_string 'private_key2:file'
	proto_config_add_string private_key_passwd2
	proto_config_add_string 'dh_file2:file'
	proto_config_add_string subject_match2
	proto_config_add_string altsubject_match2
	proto_config_add_string domain_suffix_match2
	proto_config_add_string domain_match2
	proto_config_add_string eap
	proto_config_add_boolean eap_workaround

	# setup only calls ubus and starts no proto task.
	no_proto_task=1
}

[ -n "$INCLUDE_ONLY" ] || add_protocol ieee8021xclient
