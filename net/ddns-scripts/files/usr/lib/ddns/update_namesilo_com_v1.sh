#
# SPDX-License-Identifier: GPL-2.0-only
#
# using following options from /etc/config/ddns
# option username   - sub domain
# option password   - api key
# option domain     - domain
#
# variable __IP already defined with the ip-address to use for update
#

__TTL=3600

# wrap some routines
call_api() {
	wget -q -O- "https://www.namesilo.com/api/$1?version=1&type=xml&key=$password&$2"
}
get_rrid() {
	grep -o "<record_id>.*$username</host>" | sed 's/.*<record_id>//g;s/<.*//g'
}

# update subdomain record
rrid=$(call_api dnsListRecords "domain=$domain" | get_rrid)
call_api dnsUpdateRecord "domain=$domain&rrid=$rrid&rrhost=$username&rrvalue=$__IP&rrttl=$__TTL" | grep success
