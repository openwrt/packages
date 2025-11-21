#!/bin/sh
# captive portal auto-login script for H-Reward Hotelss
# This is free software, licensed under the GNU General Public License v3.

# set (s)hellcheck exceptions
# shellcheck disable=1091,2039,3040
#
#
# Username and password can be passed to the script, to get fast wifi
# If not provided, the option with the slower wifi will be selected


. "/lib/functions.sh"


export LC_ALL=C
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"


# From https://stackoverflow.com/a/17336953/819367 converted to sh
rawurlencode() {
  string="$1"
  strlen=${#string}
  encoded=""
  pos=0
  c=""
  o=""

  while [ $pos -lt $strlen ]; do
    c=$(expr substr "$string" $((pos + 1)) 1)
    case "$c" in
      [-_.~a-zA-Z0-9] ) o="${c}" ;;
      * )               o=$(printf '%%%02x' "'$c")
    esac
    encoded="${encoded}${o}"
    pos=$((pos + 1))
  done

  echo "${encoded}"
}

user=$(rawurlencode "${1}")
password=$(rawurlencode "${2}")

successUrl="https://hrewards.com/en"
trm_useragent="$(uci_get travelmate global trm_useragent "Mozilla/5.0 (Linux x86_64; rv:90.0) Gecko/20100101 Firefox/90.0")"
trm_maxwait="$(uci_get travelmate global trm_maxwait "30")"

set -e


session_key="$(curl -sL --user-agent "${trm_useragent}" \
	 		--connect-timeout $((trm_maxwait / 6)) \
	 		"http://nossl.com/?cmd=redirect&arubalp=12345" \
	 		 | awk -F 'name="session_key" value="' 'NF>1{split($2,a,"\""); print a[1]; exit}')"

if [ -n "$user" ] && [ -n "$password" ]; then
	response="$(curl -sL --user-agent "${trm_useragent}" \
			--connect-timeout $((trm_maxwait / 6)) \
			-w %{url_effective} \
			-o /dev/null \
			--header "Content-Type:application/x-www-form-urlencoded" \
			--data "session_key=${session_key}&accept_terms=1&email=${user}&password=${password}&password_reset_form_email=&password_update_form_password=&password_update_form_password_repeat=&room_number=&last_name=&voucher=" \
			"https://cp.deutschehospitality.com/aruba/login?lang=en")"
else
	response="$(curl -sL --user-agent "${trm_useragent}" \
			--connect-timeout $((trm_maxwait / 6)) \
			-w %{url_effective} \
			-o /dev/null \
			--header "Content-Type:application/x-www-form-urlencoded" \
			--data "session_key=${session_key}&email=&password=&accept_terms=1&password_reset_form_email=&password_update_form_password=&password_update_form_password_repeat=&room_number=&last_name=&voucher=" \
			"https://cp.deutschehospitality.com/aruba/skip-registration?lang=en")"
fi

if [ "$response" != "$successUrl" ]; then
    exit 255
fi
