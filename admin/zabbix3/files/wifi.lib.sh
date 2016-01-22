
wifi_ifphylist() {
	local devs phys p ifname ifindex i
	json_load "$(ubus -S call network.wireless status)"
	json_get_keys phys
	for p in $phys; do
	  if [ "$1" = "phy" ]; then
	    echo $p
	    continue
	  fi
	  json_select "$p"
	  json_select "interfaces"
	  json_get_keys ifindex
	  for i in $ifindex; do
	    json_select $i
	    json_get_var ifname ifname
	    echo $ifname
	    json_select ..
	  done
	  json_select ..
	  json_select ..
	done
}

wifi_iflist(){
  wifi_ifphylist
}

wifi_phylist(){
  wifi_ifphylist phy
}

wifi_scan_dump(){
    wifi_maybe_scan $1 | tr '(' ' ' | \
     awk '/^BSS / { printf "'$1' %s ",$2} /freq:/ { printf "%s ",$2 } /signal:/ { printf "%s ",$2 } /SSID:/ { printf "%s\n",$2 } '
}

#iwinfo info (you need {#IF} as parameter, like 'wlan0')
wifi_iwinfo_channel() {
	lua -l iwinfo -e "print(iwinfo[iwinfo.type('$1')].channel('$1'))"
}

wifi_iwinfo_frequency() {
	lua -l iwinfo -e "print(iwinfo[iwinfo.type('$1')].frequency('$1'))"
}

wifi_iwinfo_txpower() {
	lua -l iwinfo -e "print(iwinfo[iwinfo.type('$1')].txpower('$1'))"
}

wifi_iwinfo_bitrate() {
	lua -l iwinfo -e "b = iwinfo[iwinfo.type('$1')].bitrate('$1'); print(b or '0')"
}

wifi_iwinfo_signal() {
	lua -l iwinfo -e "s = iwinfo[iwinfo.type('$1')].signal('$1'); print(s or '-255')"
}

wifi_iwinfo_noise() {
	lua -l iwinfo -e "print(iwinfo[iwinfo.type('$1')].noise('$1'))"
}

wifi_iwinfo_quality() {
	lua -l iwinfo -e "print(iwinfo[iwinfo.type('$1')].quality('$1'))"
}

wifi_iwinfo_quality_max() {
	lua -l iwinfo -e "print(iwinfo[iwinfo.type('$1')].quality_max('$1'))"
}

wifi_iwinfo_mode() {
	lua -l iwinfo -e "print(iwinfo[iwinfo.type('$1')].mode('$1'))"
}

wifi_iwinfo_ssid() {
	lua -l iwinfo -e "print(iwinfo[iwinfo.type('$1')].ssid('$1'))"
}

wifi_iwinfo_bssid() {
	lua -l iwinfo -e "print(iwinfo[iwinfo.type('$1')].bssid('$1'))"
}

wifi_iwinfo_country() {
	lua -l iwinfo -e "print(iwinfo[iwinfo.type('$1')].country('$1'))"
}

wifi_iwinfo_nbusers() {
	lua -l iwinfo -e "n = 0; for _,_ in pairs(iwinfo[iwinfo.type('$1')].assoclist('$1')) do n = n + 1 end; print(n)"
}

wifi_iwinfo_encryption() {
	lua -l iwinfo -e "e = iwinfo[iwinfo.type('$1')].encryption('$1'); print(e and e.description or 'None')"
}

wifi_iwinfo_hwmode() {
	lua -l iwinfo -e "x=iwinfo[iwinfo.type('$1')].hwmodelist('$1'); print((x.a and 'a' or '')..(x.b and 'b' or '')..(x.g and 'g' or '')..(x.n and 'n' or ''))"
}

wifi_maybe_scan() {
  local scanfile="/tmp/wifi_scan_$1"
  local now="$(date +%s)"
  
  if [ -f "$scanfile" ]; then
    mtime="$(date -r $scanfile +%s)"                                    
    if [ $(expr $now - $mtime) -lt "600" ]; then
      cat $scanfile
      return
    else
      iw dev "$1" scan >$scanfile
      cat $scanfile
      return
    fi
  else
    iw dev "$1" scan >$scanfile
    cat $scanfile
    return
  fi
}

wifi_channel_dump(){
     wifi_maybe_scan "$1" >/dev/null
     iw dev $1 survey dump | tr -s '\t ' | \
       awk '/frequency:/ { printf "'$1' %i ",$2 } /noise:/ {printf "%i ",$2 } /active time:/ {printf "%i ",$4 } /busy time:/ {printf "%i ",$4 } /receive time:/ {printf "%i ",$4 } /transmit time:/ {printf "%i \n",$4 }'
}

wifi_if_discovery(){                                                                                     
   wifi_iflist | grep '^[a-z].*' | discovery_stdin "{#IF}"
}                                                                                                             
                                                                         
wifi_phy_discovery(){                                                                                       
   wifi_phylist | grep '^[a-z].*' | discovery_stdin "{#DEV}"                                                 
}

wifi_channel_discovery(){
   local devs
   [ -n "$1" ] && devs="$1" || devs="$(wifi_iflist)"
   for dev in $devs; do wifi_channel_dump $dev 2>/dev/null; done | discovery_stdin "{#DEV}" "{#FREQ}" "{#NOISE}" 
}

wifi_neigh_discovery(){
   local devs
   [ -n "$1" ] && devs="$1" || devs="$(wifi_iflist)"
   for dev in $devs; do wifi_scan_dump $dev 2>/dev/null; done | discovery_stdin "{#DEV}" "{#BSS}" "{#FREQ}" "{#SIGNAL}" "{#SSID}"
}

wifi_channel_noise(){
    wifi_channel_dump $1 | grep "^$1 $2" | (read dev freq noise active busy receive transmit; echo $noise)
}

wifi_channel_activetime(){
    wifi_channel_dump $1 | grep "^$1 $2" | (read dev freq noise active busy receive transmit; echo $active)
}

wifi_channel_busytime(){
    wifi_channel_dump $1 | grep "^$1 $2" | (read dev freq noise active busy receive transmit; echo $busy)
}

wifi_channel_receivetime(){
    wifi_channel_dump $1 | grep "^$1 $2" | (read dev freq noise active busy receive transmit; echo $receive)
}

wifi_channel_transmittime(){
    wifi_channel_dump $1 | grep "^$1 $2" | (read dev freq noise active busy receive transmit; echo $transmit)
}

wifi_neigh_channel(){
     wifi_scan_dump $1 | grep "^$1 $2" | (read dev bss freq signal ssid; echo $freq)
}

wifi_neigh_signal(){
     wifi_scan_dump $1 | grep "^$1 $2" | (read dev bss freq signal ssid; echo $signal)
}

wifi_neigh_ssid(){
     wifi_scan_dump $1 | grep "^$1 $2" | (read dev bss freq signal ssid; echo $ssid)
}

wifi_clients(){
    iw dev $1 station dump | grep ^Station | wc -l
}

wifi_clients_dump(){
    iw dev $1 station dump | awk '/^Station / { printf "'$1' %s ",$2} /signal:/ { printf "%s ",$2 } /tx bitrate:/ { printf "%s ",$3 } /rx bitrate:/ { printf "%s\n",$3 } '
}

wifi_clients_discovery(){
   local devs
   [ -n "$1" ] && devs="$1" || devs="$(wifi_iflist)"
   for dev in $devs; do wifi_clients_dump $dev 2>/dev/null; done | discovery_stdin "{#DEV}" "{#STATION}" "{#SIGNAL}" "{#TXRATE}" "{#RXRATE}" 
}

wifi_client_signal(){
    wifi_clients_dump $1 | grep "^$1 $2" | (read dev station signal tx rx; echo $signal)
}

wifi_client_rxrate(){
    wifi_clients_dump $1 | grep "^$1 $2" | (read dev station signal tx rx; echo $rx)
}

wifi_client_txrate(){
    wifi_clients_dump $1 | grep "^$1 $2" | (read dev station signal tx rx; echo $tx)
}
