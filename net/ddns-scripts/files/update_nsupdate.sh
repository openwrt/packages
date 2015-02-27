#!/bin/sh
[ $use_ipv6 -eq 1 ] && rrtype="AAAA" || rrtype="A"
cat <<EOF  | /usr/bin/nsupdate -y $username:$password
server $dns_server
update del $domain $rrtype 
update add $domain 60 $rrtype $__IP
send
EOF
