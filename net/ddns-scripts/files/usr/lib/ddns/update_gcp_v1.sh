#!/bin/sh
#
#.Distributed under the terms of the GNU General Public License (GPL) version 2.0
#.2022 Chris Barrick <chrisbarrick@google.com>
#
# This script sends DDNS updates using the Google Cloud DNS REST API.
# See: https://cloud.google.com/dns/docs/reference/v1
#
# This script uses a GCP service account. The user is responsible for creating
# the service account, ensuring it has permission to update DNS records, and
# for generating a service account key to be used by this script. The records
# to be updated must already exist.
#
# Arguments:
#
# - $username: The service account name.
#   Example: ddns-service-account@my-dns-project.iam.gserviceaccount.com
#
# - $password: The service account key. You can paste the key directly into the
#   "password" field or upload the key file to the router and set the field
#   equal to the file path. This script supports JSON keys or the raw private
#   key as a PEM file. P12 keys are not supported. File names must end with
#   `*.json` or `*.pem`.
#
# - $domain: The domain to update.
#
# - $param_enc: The additional required arguments, as form-urlencoded data,
#   i.e. `key1=value1&key2=value2&...`. The required arguments are:
#   - project: The name of the GCP project that owns the DNS records.
#   - zone: The DNS zone in the GCP API.
#   - Example: `project=my-dns-project&zone=my-dns-zone`
#
# - $param_opt: Optional TTL for the records, in seconds. Defaults to 3600 (1h).
#
# Dependencies:
# - ddns-scripts  (for the base functionality)
# - openssl-util  (for the authentication flow)
# - curl          (for the GCP REST API)

. /usr/share/libubox/jshn.sh


# Authentication
# ---------------------------------------------------------------------------
# The authentication flow works like this:
#
#   1. Construct a JWT claim for access to the DNS readwrite scope.
#   2. Sign the JWT with the service accout key, proving we have access.
#   3. Exchange the JWT for an access token, valid for 5m.
#   4. Use the access token for API calls.
#
# See https://developers.google.com/identity/protocols/oauth2/service-account

# A URL-safe variant of base64 encoding, used by JWTs.
base64_urlencode() {
	openssl base64 | tr '/+' '_-' | tr -d '=\n'
}

# Prints the service account private key in PEM format.
get_service_account_key() {
	# The "password" field provides us with the service account key.
	# We allow the user to provide it to us in a few different formats.
	#
	# 1. If $password is a string ending in `*.json`, it is a file path,
	#    pointing to a JSON service account key as downloaded from GCP.
	#
	# 2. If $password is a string ending with `*.pem`, it is a PEM private
	#    key, extracted from the JSON service account key.
	#
	# 3. If $password starts with `{`, then the JSON service account key
	#    was pasted directly into the password field.
	#
	# 4. If $password starts with `---`, then the PEM private key was pasted
	#    directly into the password field.
	#
	# We do not support P12 service account keys.
	case "${password}" in
	(*".json")
		jsonfilter -i "${password}" -e @.private_key
	;;
	(*".pem")
		cat "${password}"
	;;
	("{"*)
		jsonfilter -s "${password}" -e @.private_key
	;;
	("---"*)
		printf "%s" "${password}"
	;;
	(*)
		write_log 14 "Could not parse the service account key."
	;;
	esac
}

# Sign stdin using the service account key. Prints the signature.
# The input is the JWT header-payload. Used to construct a signed JWT.
sign() {
	# Dump the private key to a tmp file so openssl can get to it.
	local tmp_keyfile="$(mktemp -t gcp_dns_sak.pem.XXXXXX)"
	chmod 600 ${tmp_keyfile}
	get_service_account_key > ${tmp_keyfile}
	openssl dgst -binary -sha256 -sign ${tmp_keyfile}
	rm ${tmp_keyfile}
}

# Print the JWT header in JSON format.
# Currently, Google only supports RS256.
jwt_header() {
	json_init
	json_add_string "alg" "RS256"
	json_add_string "typ" "JWT"
	json_dump
}

# Prints the JWT claim-set in JSON format.
# The claim is for 5m of readwrite access to the Cloud DNS API.
jwt_claim_set() {
	local iat=$(date -u +%s)  # Current UNIX time, UTC.
	local exp=$(( iat + 300 ))  # Expiration is 5m in the future.

	json_init
	json_add_string "iss" "${username}"
	json_add_string "scope" "https://www.googleapis.com/auth/ndev.clouddns.readwrite"
	json_add_string "aud" "https://oauth2.googleapis.com/token"
	json_add_string "iat" "${iat}"
	json_add_string "exp" "${exp}"
	json_dump
}

# Generate a JWT signed by the service account key, which can be exchanged for
# a Google Cloud access token, authorized for Cloud DNS.
get_jwt() {
	local header=$(jwt_header | base64_urlencode)
	local payload=$(jwt_claim_set | base64_urlencode)
	local header_payload="${header}.${payload}"
	local signature=$(printf "%s" ${header_payload} | sign | base64_urlencode)
	echo "${header_payload}.${signature}"
}

# Request an access token for the Google Cloud service account.
get_access_token_raw() {
	local grant_type="urn:ietf:params:oauth:grant-type:jwt-bearer"
	local assertion=$(get_jwt)

	${CURL} -v https://oauth2.googleapis.com/token \
		--data-urlencode 'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer' \
		--data-urlencode "assertion=${assertion}" \
		| jsonfilter -e @.access_token
}

# Get the access token, stripping the trailing dots.
get_access_token() {
	# Since tokens may contain internal dots, we only trim the suffix if it
	# starts with at least 8 dots. (The access token has *many* trailing dots.)
	local access_token="$(get_access_token_raw)"
	echo "${access_token%%........*}"
}


# Google Cloud DNS API
# ---------------------------------------------------------------------------
# Cloud DNS offers a straight forward RESTful API.
#
# - The main class is a ResourceRecordSet. It's a collection of DNS records
#   that share the same domain, type, TTL, etc. Within a record set, the only
#   difference between the records are their values.
#
# - The record sets live under a ManagedZone, which in turn lives under a
#   Project. All we need to know about these are their names.
#
# - This implementation only makes PATCH requests to update existing record
#   sets. The user must have already created at least one A or AAAA record for
#   the domain they are updating. It's fine to start with a dummy, like 0.0.0.0.
#
# - The API requires SSL, and this implementation uses curl.

# Prints a ResourceRecordSet in JSON format.
format_record_set() {
	local domain="$1"
	local record_type="$2"
	local ttl="$3"
	shift 3 # The remaining arguments are the IP addresses for this record set.

	json_init
	json_add_string "kind" "dns#resourceRecordSet"
	json_add_string "name" "${domain}."  # trailing dot on the domain
	json_add_string "type" "${record_type}"
	json_add_string "ttl" "${ttl}"
	json_add_array "rrdatas"
	for value in $@; do
		json_add_string "" "${value}"
	done
	json_close_array
	json_dump
}

# Makes an HTTP PATCH request to the Cloud DNS API.
patch_record_set() {
	local access_token="$1"
	local project="$2"
	local zone="$3"
	local domain="$4"
	local record_type="$5"
	local ttl="$6"
	shift 6 # The remaining arguments are the IP addresses for this record set.

	# Note the trailing dot after the domain name. It's fully qualified.
	local url="https://dns.googleapis.com/dns/v1/projects/${project}/managedZones/${zone}/rrsets/${domain}./${record_type}"
	local record_set=$(format_record_set ${domain} ${record_type} ${ttl} $@)

	${CURL} -v ${url} \
		-X PATCH \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer ${access_token}" \
		-d "${record_set}"
}


# Main entrypoint
# ---------------------------------------------------------------------------

# Parse the $param_enc into project and zone variables.
# The arguments are the names for those variables.
parse_project_zone() {
	local project_var=$1
	local zone_var=$2

	IFS='&'
	for entry in $param_enc
	do
		case "${entry}" in
		('project='*)
			local project_val=$(echo "${entry}" | cut -d'=' -f2)
			eval "${project_var}=${project_val}"
		;;
		('zone='*)
			local zone_val=$(echo "${entry}" | cut -d'=' -f2)
			eval "${zone_var}=${zone_val}"
		;;
		esac
	done
	unset IFS
}

main() {
	local access_token project zone ttl record_type

	# Dependency checking
	[ -z "${CURL_SSL}" ] && write_log 14 "Google Cloud DNS requires cURL with SSL support"
	[ -z "$(openssl version)" ] && write_log 14 "Google Cloud DNS update requires openssl-utils"

	# Argument parsing
	[ -z ${param_opt} ] && ttl=3600 || ttl="${param_opt}"
	[ $use_ipv6 -ne 0 ] && record_type="AAAA" || record_type="A"
	parse_project_zone project zone

	# Sanity checks
	[ -z "${username}" ] && write_log 14 "Config is missing 'username' (service account name)"
	[ -z "${password}" ] && write_log 14 "Config is missing 'password' (service account key)"
	[ -z "${domain}" ] && write_log 14 "Config is missing 'domain'"
	[ -z "${project}" ] && write_log 14 "Could not parse project name from 'param_enc'"
	[ -z "${zone}" ] && write_log 14 "Could not parse zone name from 'param_enc'"
	[ -z "${ttl}" ] && write_log 14 "Could not parse TTL from 'param_opt'"
	[ -z "${record_type}" ] && write_log 14 "Could not determine the record type"

	# Push the record!
	access_token="$(get_access_token)"
	patch_record_set "${access_token}" "${project}" "${zone}" "${domain}" "${record_type}" "${ttl}" "${__IP}"
}

main $@
