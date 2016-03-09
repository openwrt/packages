#
#.Distributed under the terms of the GNU General Public License (GPL) version 2.0
#
# script for sending updates to cloudflare.com
#.2014-2015 Christian Schoenebeck <christian dot schoenebeck at gmail dot com>
# many thanks to Paul for testing and feedback during development
#
# This script is parsed by dynamic_dns_functions.sh inside send_update() function
#
# using following options from /etc/config/ddns
# option username - your cloudflare e-mail
# option password - cloudflare api key, you can get it from cloudflare.com/my-account/
# option domain   - your full hostname to update, in cloudflare its subdomain.domain
#			i.e. myhost.example.com where myhost is the subdomain and example.com is your domain
#
# variable __IP already defined with the ip-address to use for update
#
[ $use_https -eq 0 ] && write_log 14 "Cloudflare only support updates via Secure HTTP (HTTPS). Please correct configuration!"
[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing 'username'"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing 'password'"

local __RECID __URL __KEY __KEYS __FOUND __SUBDOM __DOMAIN __TLD

# split given Host/Domain into TLD, registrable domain, and subdomain
split_FQDN $domain __TLD __DOMAIN __SUBDOM
[ $? -ne 0 -o -z "$__DOMAIN" ] && \
	write_log 14 "Wrong Host/Domain configuration ($domain). Please correct configuration!"

# put together what we need
__DOMAIN="$__DOMAIN.$__TLD"

# parse OpenWrt script with
# functions for parsing and generating json
. /usr/share/libubox/jshn.sh

# function copied from /usr/share/libubox/jshn.sh
# from BB14.09 for backward compatibility to AA12.09
grep -i "json_get_keys" /usr/share/libubox/jshn.sh >/dev/null 2>&1 || json_get_keys() {
	local __dest="$1"
	local _tbl_cur

	if [ -n "$2" ]; then
		json_get_var _tbl_cur "$2"
	else
		_json_get_var _tbl_cur JSON_CUR
	fi
	local __var="${JSON_PREFIX}KEYS_${_tbl_cur}"
	eval "export -- \"$__dest=\${$__var}\"; [ -n \"\${$__var+x}\" ]"
}

# function to "sed" unwanted string parts from DATFILE
cleanup() {
	# based on the sample output on cloudflare.com homepage we need to do some cleanup
	sed -i 's/^[ \t]*//;s/[ \t]*$//' $DATFILE	# remove invisible chars at beginning and end of lines
	sed -i '/^-$/d' $DATFILE			# remove lines with "-" (dash)
	sed -i '/^$/d' $DATFILE				# remove empty lines
	sed -i "#'##g" $DATFILE				# remove "'" (single quote)
}

[ -n "$rec_id" ] && __RECID="$rec_id" || {
	# build url according to cloudflare client api at https://www.cloudflare.com/docs/client-api.html
	# to "rec_load_all" to detect rec_id needed for update
	__URL="https://www.cloudflare.com/api_json.html"	# https://www.cloudflare.com/api_json.html
	__URL="${__URL}?a=rec_load_all"				#  -d 'a=rec_load_all'
	__URL="${__URL}&tkn=$password"				#  -d 'tkn=8afbe6dea02407989af4dd4c97bb6e25'
	__URL="${__URL}&email=$username"			#  -d 'email=sample@example.com'
	__URL="${__URL}&z=$__DOMAIN"				#  -d 'z=example.com'

	# lets request the data
	do_transfer "$__URL" || return 1

	cleanup				# cleanup dat file
	json_load "$(cat $DATFILE)"	# lets extract data
	__FOUND=0			# found record indicator
	json_get_var __RES "result"	# cloudflare result of last request
	json_get_var __MSG "msg"	# cloudflare error message
	[ "$__RES" != "success" ] && {
		write_log 4 "'rec_load_all' failed with error: \n$__MSG"
		return 1
	}

	json_select "response"
	json_select "recs"
	json_select "objs"
	json_get_keys __KEYS
	for __KEY in $__KEYS; do
		local __ZONE __DISPLAY __NAME __TYPE
		json_select "$__KEY"
	#	json_get_var __ZONE "zone_name"		# for debugging
	#	json_get_var __DISPLAY "display_name"	# for debugging
		json_get_var __NAME "name"
		json_get_var __TYPE "type"
		if [ "$__NAME" = "$domain" ]; then
			# we must verify IPv4 and IPv6 because there might be both for the same host
			[ \( $use_ipv6 -eq 0 -a "$__TYPE" = "A" \) -o \( $use_ipv6 -eq 1 -a "$__TYPE" = "AAAA" \) ] && {
				__FOUND=1	# mark found
				break		# found leave for loop
			}
		fi
		json_select ..
	done
	[ $__FOUND -eq 0 ] && {
		# we don't need to continue trying to update cloudflare because record to update does not exist
		# user has to setup record first outside ddns-scripts
		write_log 14 "No valid record found at Cloudflare setup. Please create first!"
	}
	json_get_var __RECID "rec_id"	# last thing to do get rec_id
	json_cleanup			# cleanup
	write_log 7 "rec_id '$__RECID' detected for host/domain '$domain'"
}

# build url according to cloudflare client api at https://www.cloudflare.com/docs/client-api.html
# for "rec_edit" to update IP address
__URL="https://www.cloudflare.com/api_json.html"	# https://www.cloudflare.com/api_json.html
__URL="${__URL}?a=rec_edit"				#  -d 'a=rec_edit'
__URL="${__URL}&tkn=$password"				#  -d 'tkn=8afbe6dea02407989af4dd4c97bb6e25'
__URL="${__URL}&id=$__RECID"				#  -d 'id=9001'
__URL="${__URL}&email=$username"			#  -d 'email=sample@example.com'
__URL="${__URL}&z=$__DOMAIN"				#  -d 'z=example.com'

[ $use_ipv6 -eq 0 ] && __URL="${__URL}&type=A"		#  -d 'type=A'		(IPv4)
[ $use_ipv6 -eq 1 ] && __URL="${__URL}&type=AAAA"	#  -d 'type=AAAA'	(IPv6)

# handle subdomain or domain record
[ -n "$__SUBDOM" ] && __URL="${__URL}&name=$__SUBDOM"	#  -d 'name=sub'	(HOST/SUBDOMAIN)
[ -z "$__SUBDOM" ] && __URL="${__URL}&name=$__DOMAIN"	#  -d 'name=example.com'(DOMAIN)

__URL="${__URL}&content=$__IP"				#  -d 'content=1.2.3.4'
__URL="${__URL}&service_mode=0"				#  -d 'service_mode=0'
__URL="${__URL}&ttl=1"					#  -d 'ttl=1'

# lets do the update
do_transfer "$__URL" || return 1

cleanup				# cleanup tmp file
json_load "$(cat $DATFILE)"	# lets extract data
json_get_var __RES "result"	# cloudflare result of last request
json_get_var __MSG "msg"	# cloudflare error message
[ "$__RES" != "success" ] && {
	write_log 4 "'rec_edit' failed with error:\n$__MSG"
	return 1
}
write_log 7 "Update of rec_id '$__RECID' successful"
return 0
