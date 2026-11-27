#!/bin/sh

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. /lib/functions/network.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

IEEE8021X_WPA_WAIT_SECS=15

_ieee8021xclient_log() {
	logger -t ieee8021xclient "$@"
}

# $1 must be the device setup registered; netifd may pass another one to
# teardown.
_ieee8021xclient_config_remove() {
	local ifname="$1"

	if ! ubus call wpa_supplicant config_remove "{\"iface\":\"$ifname\"}" >/dev/null 2>&1; then
		return 1
	fi

	rm -f "/var/run/wpa_supplicant-$ifname.conf"
	return 0
}

# Only remove the config file this run installed: a failed config_remove
# must keep the previous one, together with the mapping, for a retry.
_ieee8021xclient_setup_failed() {
	local cfg="$1"
	local code="$2"

	shift 2
	[ -n "$_tmp" ] && rm -f "$_tmp"
	[ "${_installed:-0}" = 1 ] && rm -f "$_config"
	_ieee8021xclient_log "$*"
	proto_notify_error "$cfg" "$code"
	proto_setup_failed "$cfg"
}

ieee8021xclient_wait_wpa_supplicant() {
	ubus -t "$IEEE8021X_WPA_WAIT_SECS" wait_for wpa_supplicant >/dev/null 2>&1
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

_wpa_supplicant_common() {
	local ifname="$1"

	_config="/var/run/wpa_supplicant-$ifname.conf"
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
	local _config _tmp write_status recorded
	local old_umask
	local _installed=0

	_wpa_supplicant_common "$ifname"

	# Fail before writing any credentials if the supplicant is absent.
	if ! ieee8021xclient_wait_wpa_supplicant; then
		_ieee8021xclient_setup_failed "$cfg" 'WPA_SUPPLICANT_UNAVAILABLE' \
			"wpa_supplicant unavailable (interface $cfg, device $ifname)"
		return 1
	fi

	# netifd may run setup again without a teardown. Drop the previous
	# registration and its mapping; keep both on failure for a retry.
	recorded=$(cat "/var/run/ieee8021xclient-$cfg.ifname" 2>/dev/null)
	if [ -n "$recorded" ]; then
		if ! _ieee8021xclient_config_remove "$recorded"; then
			_ieee8021xclient_setup_failed "$cfg" 'CONFIG_REMOVE_FAILED' \
				"cannot remove the previous supplicant interface $recorded (interface $cfg)"
			return 1
		fi
		rm -f "/var/run/ieee8021xclient-$cfg.ifname"
	fi

	# Replace the target so a stale file with loose permissions is not rewritten.
	old_umask=$(umask)
	umask 077
	_tmp=$(mktemp "/var/run/ieee8021xclient-$ifname.XXXXXX")
	if [ -z "$_tmp" ]; then
		umask "$old_umask"
		_ieee8021xclient_setup_failed "$cfg" 'CONFIG_WRITE_FAILED' \
			"cannot create a temporary file (interface $cfg, device $ifname)"
		return 1
	fi

	# set -e: a plain command group only reports the last printf's status.
	(
		set -e
		if [ -n "$eapol_version" ]; then
			printf 'eapol_version=%s\n' "$eapol_version"
		fi
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
		if [ -n "$eap_workaround" ]; then
			printf '\teap_workaround=%s\n' "$eap_workaround"
		fi
		printf '}\n'
	) > "$_tmp"
	write_status=$?
	umask "$old_umask"

	if [ "$write_status" -ne 0 ]; then
		_ieee8021xclient_setup_failed "$cfg" 'CONFIG_WRITE_FAILED' \
			"cannot write the supplicant config (interface $cfg, device $ifname)"
		return 1
	fi

	# The file carries the 802.1X identity and password, so keep it private.
	# wpa_supplicant drops privileges and runs as the "network" user since
	# OpenWrt 21.02, so hand the file to that user instead of making it
	# world readable.
	if ! chown network:network "$_tmp" ||
	   ! chmod 600 "$_tmp" ||
	   ! mv -f "$_tmp" "$_config"; then
		_ieee8021xclient_setup_failed "$cfg" 'CONFIG_WRITE_FAILED' \
			"cannot install the supplicant config (interface $cfg, device $ifname)"
		return 1
	fi
	_installed=1

	if ! ubus call wpa_supplicant config_add "{ \"driver\":\"wired\", \"iface\": \"$ifname\", \"config\": \"$_config\" }" >/dev/null 2>&1; then
		# config_add may have added the interface before failing.
		_ieee8021xclient_config_remove "$ifname" ||
			_ieee8021xclient_log "cannot remove $ifname after a failed config_add (interface $cfg)"
		_ieee8021xclient_setup_failed "$cfg" 'CONFIG_ADD_FAILED' \
			"config_add failed (interface $cfg, device $ifname)"
		return 1
	fi

	# Record the device only after everything succeeded.
	if [ -n "$cfg" ]; then
		echo "$ifname" > "/var/run/ieee8021xclient-$cfg.ifname"
	fi
}

proto_ieee8021xclient_teardown() {
	local interface="$1"
	local ifname="$2"
	local recorded

	# no_proto_task: netifd never sets $ERROR here.

	# Prefer the registered device; netifd may pass a different one.
	recorded=$(cat "/var/run/ieee8021xclient-$interface.ifname" 2>/dev/null)
	[ -n "$recorded" ] || recorded="$ifname"
	[ -n "$recorded" ] || recorded="$interface"

	if ! _ieee8021xclient_config_remove "$recorded"; then
		# netifd does not retry teardown; the next setup will.
		_ieee8021xclient_log "config_remove failed (interface $interface, device $recorded)"
		return 0
	fi

	# The supplicant can still hold the previous device as well.
	if [ -n "$ifname" ] && [ "$ifname" != "$recorded" ]; then
		_ieee8021xclient_config_remove "$ifname" ||
			_ieee8021xclient_log "config_remove failed (interface $interface, device $ifname)"
	fi

	rm -f "/var/run/ieee8021xclient-$interface.ifname"
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
