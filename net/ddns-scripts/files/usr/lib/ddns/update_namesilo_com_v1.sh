#!/bin/sh
#
# SPDX-License-Identifier: GPL-2.0-only
#
# Script for updating NameSilo DNS records
# 2026 Lin Fan <im dot linfan at gmail dot com>
#
# using following options from /etc/config/ddns
# username - sub domain
# password - api key
# domain   - domain
#
# optional parameters from /etc/config/ddns
# ttl - ttl in seconds (ex: ttl=7200, default '3600')
# pp  - proxy protocol (ex: pp=socks5h, default 'http')
#
# reference: https://www.namesilo.com/api-reference
#
# SECURITY NOTE:
# The NameSilo API requires the API key to be passed as a URL query parameter.
# This means the key may be exposed in shell history, process listings (ps),
# and system logs that record full command lines. Use a dedicated API key and
# protect access to this system and its logs accordingly.


# check curl
[ -z "$CURL" ] || [ -z "$CURL_SSL" ] && {
	write_log 14 "NameSilo script requires cURL with SSL support."
	return 1
}
[ -n "$proxy" ] && [ -z "$CURL_PROXY" ] && {
	write_log 14 "cURL: libcurl compiled without proxy support."
	return 1
}

# check xmlstarlet (optional)
XMLSTARLET=$(command -v xmlstarlet)
[ -z "$XMLSTARLET" ] && {
	write_log 7 "Suggestion: Install 'xmlstarlet' to parse response from NameSilo accurately."
}

# check options
[ -z "$username" ] && write_log 14 "NameSilo: 'username' (sub domain) not set" && return 1
[ -z "$password" ] && write_log 14 "NameSilo: 'password' (api key) not set" && return 1
[ -z "$domain" ] && write_log 14 "NameSilo: 'domain' not set" && return 1
[ "$use_ipv6" -eq 1 ] && type="AAAA" || type="A"

# parse optional parameters
[ -n "$param_opt" ] && {
	for pair in $param_opt ; do
		case $pair in
		ttl=*)
			param_opt_ttl=${pair#*=}
			;;
		pp=*)
			param_opt_pp=${pair#*=}
			;;
		*)
			# ignore others
			;;
		esac
	done
}
ttl="${param_opt_ttl:-3600}"

# curl command
CURL_CMD="$CURL -sSf -o $DATFILE --stderr $ERRFILE"
[ -n "$proxy" ] && {
	[ -z "$param_opt_pp" ] && {
		proxy_arg="--proxy ${proxy}"
	} || {
		proxy_arg="--proxy ${param_opt_pp}://${proxy}"
	}
	CURL_CMD="$CURL_CMD $proxy_arg"
}

# extract response code
get_code() {
	[ -n "$XMLSTARLET" ] && {
		# try xmlstarlet first
		$XMLSTARLET sel -t -v "/namesilo/reply/code" 2>/dev/null
	} || {
		# fallback to grep/sed
		grep -o '<code>.*</code>' | sed 's/<code>//;s/<\/code>//' 2>/dev/null
	}
}

# extract detail message
get_detail() {
	[ -n "$XMLSTARLET" ] && {
		# try xmlstarlet first
		$XMLSTARLET sel -t -v "/namesilo/reply/detail" 2>/dev/null
	} || {
		# fallback to grep/sed
		grep -o '<detail>.*</detail>' | sed 's/<detail>//;s/<\/detail>//' 2>/dev/null
	}
}

# extract rrid
get_rrid() {
	[ -n "$XMLSTARLET" ] && {
		# try xmlstarlet first
		$XMLSTARLET sel -t -v "/namesilo/reply/resource_record/record_id[../host='${username}'][../type='${type}']" 2>/dev/null
	} || {
		# fallback to grep/sed
		for record in $(sed "s/<resource_record>/\n<resource_record>/g" |
						grep -o "<resource_record>.*<host>$username</host>.*</resource_record>") ; do
			rectype=$(printf "%s\n" "$record" | sed  "s/.*<type>//;s/<\/type>.*//")
			[ "$rectype" == "$type" ] && {
				printf "%s\n" "$record" | sed "s/.*<record_id>//;s/<\/record_id>.*//"
				return
			}
		done
	}
}

# call domain api
call_api() {
	local endpoint="$1"
	local params="$2"
	local url="https://www.namesilo.com/api/${endpoint}?version=1&type=xml&key=${password}&${params}"

	# call api
	$CURL_CMD "$url"
	local rc=$?
	[ "$rc" -ne 0 ] && {
		write_log 3 "NameSilo: API request to '$endpoint' failed with exit code $rc"
		return 1
	}

	# check response
	local response=$(cat "$DATFILE")
	[ -z "$response" ] && {
		write_log 3 "NameSilo: Empty response from API '$endpoint'"
		return 1
	}

	# check reply code
	local code=$(printf "%s\n" "$response" | get_code)
	[ "$code" != "300" ] && {
		local detail=$(printf "%s\n" "$response" | get_detail)
		write_log 3 "NameSilo: API request to '$endpoint' returned with error '$code - $detail'"
		return 1
	}

	printf '%s\n' "$response"
	return 0
}

# get rrid
response=$(call_api dnsListRecords "domain=$domain")
[ -z "$response" ] && return 1
rrid=$(printf "%s\n" "$response" | get_rrid)
[ -z "$rrid" ] && {
	write_log 14 "NameSilo: No matching '$type' DNS record found for host '$username' in domain '$domain'"
	return 1
}

# update subdomain record
call_api dnsUpdateRecord "domain=$domain&rrid=$rrid&rrhost=$username&rrvalue=$__IP&rrttl=$ttl" && {
	write_log 7 "NameSilo: '$type' DNS record for '$username.$domain' updated successfully to IP '$__IP'"
	return 0
} || {
	write_log 3 "NameSilo: Failed to update '$type' DNS record for '$username.$domain' to IP '$__IP'"
	return 1
}
