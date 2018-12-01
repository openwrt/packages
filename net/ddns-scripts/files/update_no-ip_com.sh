#.Distributed under the terms of the GNU General Public License (GPL) version 2.0
#.2014-2015 Christian Schoenebeck <christian dot schoenebeck at gmail dot com>
# modified 11-2018 - Matt Bodholdt to use curl and https
# requires curl and ca-bundle to function over https, otherwise will fall back to the old method and use http
#
# This script is parsed by dynamic_dns_functions.sh inside send_update() function
#
# no-ip does not reactivate records if the ip doesn't change often
# so we send a dummy (localhost) and a seconds later we send the correct IP addr

local __DUMMY
local __UPDURL="http://[USERNAME]:[PASSWORD]@dynupdate.no-ip.com/nic/update?hostname=[DOMAIN]&myip=[IP]"
[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing 'username'"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing 'password'"

# if curl and ca-bundle packages are installed on the system use those and use https
if [ -x /usr/bin/curl ] && ls /etc/ssl/certs/ca-certificates.crt > /dev/null 2>&1 ; then
  write_log 5 "using https to update 'no-ip.com'"
  use_https=1

  # set IP version dependend dummy (localhost)
  [ $use_ipv6 -eq 0 ] && __DUMMY="127.0.0.1" || __DUMMY="::1"

  # dummy request
  write_log 7 "sending dummy IP to 'no-ip.com' using curl"
  __URL=$(echo $__UPDURL | sed -e "s#\[USERNAME\]#$URL_USER#g" -e "s#\[PASSWORD\]#$URL_PASS#g" -e "s#\[DOMAIN\]#$domain#g" -e "s#\[IP\]#$__DUMMY#g")
  [ $use_https -ne 0 ] && __URL=$(echo $__URL | sed -e 's#^http:#https:#')
  __response=$(/usr/bin/curl -s -A "ddns-scripts/v$VERSION contact@openwrt.org" "$__URL")
  if echo $__response | grep -E "good|nochg" ; then
      write_log 7 $(echo "'no-ip.com' answered dummy request $__DUMMY, res: $__response")
    else
      write_log 7 $(echo "error updating 'no-ip.com' dummy request $__DUMMY, res: $__response")
      return 1
    fi

  sleep 1

  # send proper address
  __response=""
  write_log 7 "sending real IP to 'no-ip.com' using curl"
  __URL=$(echo $__UPDURL | sed -e "s#\[USERNAME\]#$URL_USER#g" -e "s#\[PASSWORD\]#$URL_PASS#g" -e "s#\[DOMAIN\]#$domain#g" -e "s#\[IP\]#$__IP#g")
  [ $use_https -ne 0 ] && __URL=$(echo $__URL | sed -e 's#^http:#https:#')
  __response=$(/usr/bin/curl -s -A "ddns-scripts/v$VERSION contact@openwrt.org" "$__URL")
if echo $__response | grep -E "good|nochg" ; then
    write_log 7 $(echo "'no-ip.com' answered request $__IP, res: $__response")
    return $?
  else
    write_log 7 $(echo "error 'no-ip.com' request $__IP, res: $__response")
    return 1
  fi

else
  write_log 5 "using http to update 'no-ip.com', to use https install curl and ca-bundle"
  use_https=0
  #this is what it was before, doesn't support https
  [ $use_ipv6 -eq 0 ] && __DUMMY="127.0.0.1" || __DUMMY="::1"

  # lets do DUMMY transfer
  write_log 7 "sending dummy IP to 'no-ip.com'"
  __URL=$(echo $__UPDURL | sed -e "s#\[USERNAME\]#$URL_USER#g" -e "s#\[PASSWORD\]#$URL_PASS#g" -e "s#\[DOMAIN\]#$domain#g" -e "s#\[IP\]#$__DUMMY#g")
  [ $use_https -ne 0 ] && __URL=$(echo $__URL | sed -e 's#^http:#https:#')

  do_transfer "$__URL" || return 1

  write_log 7 "'no-ip.com' answered:${N}$(cat $DATFILE)"
  grep -E "good|nochg" $DATFILE >/dev/null 2>&1 || return 1

  sleep 1

  # now send the correct data
  write_log 7 "sending real IP to 'no-ip.com'"
  __URL=$(echo $__UPDURL | sed -e "s#\[USERNAME\]#$URL_USER#g" -e "s#\[PASSWORD\]#$URL_PASS#g" -e "s#\[DOMAIN\]#$domain#g" -e "s#\[IP\]#$__IP#g")
  [ $use_https -ne 0 ] && __URL=$(echo $__URL | sed -e 's#^http:#https:#')

  do_transfer "$__URL" || return 1

  write_log 7 "'no-ip.com' answered:${N}$(cat $DATFILE)"

  grep -E "good|nochg" $DATFILE >/dev/null 2>&1
  return $?	# "0" if "good" or "nochg" found
fi
