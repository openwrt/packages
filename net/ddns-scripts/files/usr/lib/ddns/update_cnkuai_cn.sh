# inside url we need domain, username and password
[ -z "$domain" ]   && write_log 14 "Service section not configured correctly! Missing 'domain'"
[ -z "$username" ] && write_log 14 "Service section not configured correctly! Missing 'username'"
[ -z "$password" ] && write_log 14 "Service section not configured correctly! Missing 'password'"

local urlCp='http://cp.cnkuai.cn/'
local urlLogin='http://cp.cnkuai.cn/userlogin.asp'
local urlCaptcha='http://cp.cnkuai.cn/inc/image.asp'
local urlDnsA='http://cp.cnkuai.cn/dns_a.asp'
local urlDnsAAAA='http://cp.cnkuai.cn/dns_ipv6.asp'
local urlDnsSave='http://cp.cnkuai.cn/dns_save.asp'

getPixel(){
  local filename=$1
  local x=$(($2*3))
  local y=$(($3*3))
  local width=48

  hexdump -s "$((x+width*y))" -n 3 -e '3/1 "%02X"' "$filename"
}

captchaChar(){
  local filename=$1
  local xoffset=$2

  if [ "$(getPixel "$filename" $((xoffset+2)) 5)" = '000000' ]; then
    echo '1'
  elif [ "$(getPixel "$filename" $((xoffset+5)) 7)" = '000000' ]; then
    echo '2'
  elif [ "$(getPixel "$filename" $((xoffset+4)) 3)" = '000000' ]; then
    echo '4'
  elif [ "$(getPixel "$filename" $((xoffset+6)) 4)" = '000000' ]; then
    echo '7'
  elif [ "$(getPixel "$filename" $((xoffset+5)) 8)" = '000000' ]; then
    echo '8'
  elif [ "$(getPixel "$filename" $((xoffset+6)) 8)" = '000000' ]; then
    echo '9'
  elif [ "$(getPixel "$filename" $((xoffset+5)) 6)" = '000000' ]; then
    echo '3'
  elif [ "$(getPixel "$filename" $((xoffset+0)) 4)" = '000000' ]; then
    echo '5'
  elif [ "$(getPixel "$filename" $((xoffset+1)) 5)" = '000000' ]; then
    echo '6'
  else
    echo '0'
  fi
}

captcha(){
  local str
  str=$(captchaChar "$1" 9)
  str=$str$(captchaChar "$1" 18)
  str=$str$(captchaChar "$1" 26)
  str=$str$(captchaChar "$1" 35)
  echo "$str"
}

#clean
rm /tmp/cnkuai.*
#login to cnkuai dns cp
curl -c '/tmp/cnkuai.cookiejar' "$urlCaptcha" | gif2rgb > /tmp/cnkuai.rgb || return 1
yzm=$(captcha "/tmp/cnkuai.rgb")
curl -b '/tmp/cnkuai.cookiejar' -c '/tmp/cnkuai.cookiejar' -H "Content-Type: application/x-www-form-urlencoded" -H "Referer: $urlCp" -d "userid=$URL_USER&password=$URL_PASS&yzm=$yzm&B1=%C8%B7%C8%CF%B5%C7%C2%BD&lx=0&userlx=3" -X POST "$urlLogin" > /dev/null || return 1

if [ "$use_ipv6" -eq 0 ]; then
  curl -b '/tmp/cnkuai.cookiejar' -c '/tmp/cnkuai.cookiejar' "$urlDnsA" > /tmp/cnkuai.html || return 1
else
  curl -b '/tmp/cnkuai.cookiejar' -c '/tmp/cnkuai.cookiejar' "$urlDnsAAAA" > /tmp/cnkuai.html || return 1
fi
local domainline
domainline=$(awk "/<td>$domain<\/td>/{ print NR; exit }" /tmp/cnkuai.html)
local domainid
domainid=$(awk "NR==$((domainline+3))" /tmp/cnkuai.html | sed 's/^.*name=\x27domainid\x27 value="//g' | sed 's/".*$//g')
local dnslistid
dnslistid=$(awk "NR==$((domainline+3))" /tmp/cnkuai.html | sed 's/^.*name=\x27dnslistid\x27 value="//g' | sed 's/".*$//g')

local data

if [ "$use_ipv6" -eq 0 ]; then
  data="T2=$__IP&T3=120&act=dns_a_edit&domainid=$domainid&dnslistid=$dnslistid&B1=%D0%DE%B8%C4"
else
  data="T2=$__IP&T3=120&act=dns_ipv6_edit&domainid=$domainid&dnslistid=$dnslistid&B1=%D0%DE%B8%C4"
fi
curl -b '/tmp/cnkuai.cookiejar' -c '/tmp/cnkuai.cookiejar' -H "Content-Type: application/x-www-form-urlencoded" -H "Referer: $urlDnsA" -d "$data" -X POST "$urlDnsSave" > /dev/null || return 1

return 0
