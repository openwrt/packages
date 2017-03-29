
netowrt_discovery() {
	lua -l uci -e 'x = uci.cursor(nil, "/var/state");list = "{\"data\":[";x:foreach("network", "interface", function(s) list=list.."{\"{#IF}\":\""..s.ifname.."\", \"{#NET}\":\""..s[".name"].."\"}," end); list=string.gsub(list,",$",""); print(list.."]}")'
}

