#!/bin/sh

# This script sends DNS updates using the Scaleway DNS API.
# See https://www.scaleway.com/en/developers/api/domains-and-dns/
#
# This script uses an API token created in the Scaleway Console.
# The user is responsible for creating the token, ensuring it has the
# DomainsDNSFullAccess permission set. The records to be updated
# may already exist, but will be created if not.
#
# Arguments:
#
# - $username: The zone in which the RR is to be set.
#   Example: example.org
#
# - $password: The API token.
#
# - $domain: The domain to update.
#
# - $param_opt: Optional TTL for the records, in seconds. Defaults to 300 (5m).
#
# Dependencies:
# - ddns-scripts  (for the base functionality)
# - curl          (for the Scaleway DNS API)

. /usr/share/libubox/jshn.sh

format_record_set() {
	local domain="$1"
	local record_type="$2"
	local ttl="$3"
	shift 3 # The remaining arguments are the IP addresses for this record set.

	json_init
	json_add_array "changes"
	json_add_object ""
	json_add_object "set"

	json_add_object "id_fields"
	json_add_string "name" "${domain}"
	json_add_string "type" "${record_type}"
	json_close_object

	json_add_array "records"
	for value in "$@"; do
		json_add_object ""
		json_add_string "data" "${value}"
		json_add_string "name" "${domain}"
		json_add_string "type" "${record_type}"
		json_add_int "ttl" "${ttl}"
		json_close_object
	done
	json_close_array

	json_close_object
	json_close_object
	json_close_array
	json_dump
}

patch_record_set() {
	local access_token="$1"
	local zone="$2"
	local domain="$3"
	local record_type="$4"
	local ttl="$5"
	shift 5 # The remaining arguments are the IP addresses for this record set.

	local url="https://api.scaleway.com/domain/v2beta1/dns-zones/${zone}/records"
	local payload
	payload=$(format_record_set ${domain} ${record_type} ${ttl} "$@")
	write_log 7 "cURL request payload: ${payload}"

	${CURL} ${url} \
		--show-error --silent --fail-with-body \
		--request   PATCH \
		--header    "X-Auth-Token: ${access_token}" \
		--json      "${payload}" \
		--write-out "%{response_code}" \
		--output $DATFILE 2> $ERRFILE

	if [ $? -ne 0 ]; then
		write_log 3 "cURL failed: $(cat $ERRFILE) \nscaleway.com response: $(cat $DATFILE)"
		return 1
	fi
}

main() {
	local ttl record_type

	# Dependency checking
	[ -z "${CURL_SSL}" ] && write_log 13 "Scaleway DNS requires cURL with SSL support"

	# Argument parsing
	[ -z ${param_opt} ] && ttl=300 || ttl="${param_opt}"
	[ ${use_ipv6} -ne 0 ] && record_type="AAAA" || record_type="A"

	# Sanity checks
	[ -z "${password}" ] && write_log 13 "Config is missing 'password' (API token)"
	[ -z "${domain}" ] && write_log 13 "Config is missing 'domain'"
	[ -z "${username}" ] && write_log 13 "Config is missing 'username' (DNS zone)"
	[ -z "${ttl}" ] && write_log 13 "Could not parse TTL"
	[ -z "${record_type}" ] && write_log 13 "Could not determine the record type"

	patch_record_set "${password}" "${username}" "${domain}" "${record_type}" "${ttl}" "${__IP}"
}

main "$@"
