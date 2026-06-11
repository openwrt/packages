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
	local ca_cert client_cert private_key private_key_passwd dh_file subject_match
	local phase1 phase2 ca_cert2 client_cert2 private_key2 private_key_passwd2 dh_file2 subject_match2
	local eap_workaround
	json_get_vars eapol_version
	json_get_vars identity anonymous_identity password
	json_get_vars ca_cert client_cert private_key private_key_passwd dh_file subject_match
	json_get_vars phase1 phase2 ca_cert2 client_cert2 private_key2 private_key_passwd2 dh_file2 subject_match2
	json_get_vars eap_workaround

	# launch
	local _config _pid
	_wpa_supplicant_common "$ifname"

	cat > "${_config}" << EOF
${eapol_version:+eapol_version=${eapol_version}}
network={
	${identity:+identity=${identity}}
	${anonymous_identity:+anonymous_identity=${anonymous_identity}}
	${password:+password=${password}}
	${ca_cert:+ca_cert=${ca_cert}}
	${client_cert:+client_cert=${client_cert}}
	${private_key:+private_key=${private_key}}
	${private_key_passwd:+private_key_passwd=${private_key_passwd}}
	${dh_file:+dh_file=${dh_file}}
	${subject_match:+subject_match=${subject_match}}
	${phase1:+phase1=${phase1}}
	${phase2:+phase2=${phase2}}
	${ca_cert2:+ca_cert2=${ca_cert2}}
	${client_cert2:+client_cert2=${client_cert2}}
	${private_key2:+private_key2=${private_key2}}
	${private_key_passwd2:+private_key_passwd2=${private_key_passwd2}}
	${dh_file2:+dh_file2=${dh_file2}}
	${subject_match2:+subject_match2=${subject_match2}}
	${eap_workaround:+eap_workaround=1}
}
EOF
	ubus wait_for wpa_supplicant
	ubus call wpa_supplicant config_add "{ \"driver\":\"wired\", \"iface\": \"$ifname\", \"config\": \"$_config\" }"
}

proto_ieee8021xclient_teardown() {
	local ifname="$1"
	local errorstring=$(ieee8021xclient_exitcode_tostring $ERROR)

	case "$ERROR" in
		0)
		;;
		2)
			proto_notify_error "$ifname" "$errorstring"
			proto_block_restart "$ifname"
		;;
		*)
			proto_notify_error "$ifname" "$errorstring"
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
	proto_config_add_string 'client_cert:file'
	proto_config_add_string 'private_key:file'
	proto_config_add_string private_key_passwd
	proto_config_add_string 'dh_file:file'
	proto_config_add_string subject_match
	proto_config_add_string phase1
	proto_config_add_string phase2
	proto_config_add_string 'ca_cert2:file'
	proto_config_add_string 'client_cert2:file'
	proto_config_add_string 'private_key2:file'
	proto_config_add_string private_key_passwd2
	proto_config_add_string 'dh_file2:file'
	proto_config_add_string subject_match2
	proto_config_add_boolean eap_workaround
}

[ -n "$INCLUDE_ONLY" ] || add_protocol ieee8021xclient
