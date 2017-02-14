local map, section, net = ...
local ifc = net:get_interface()

local cfgcmd = "var Macaddr=document.getElementById(this.parentNode.parentNode.parentNode.id.replace('cbi', 'cbid').replace(/-/g, '.'));" ..
"function randomString(len,type){len=len||32;type=type||0;" ..
"var $chars='';" ..
"switch(type){case 1:$chars='13579bdf';break;" ..
"case 2:$chars='24680ace';break;" ..
"default:$chars='0123456789abcdef';break;}" ..
"var maxPos=$chars.length;var pwd='';" ..
"for(i = 0; i &lt; len; i++){pwd+=$chars.charAt(Math.floor(Math.random() * maxPos));}return pwd;};" ..
"Macaddr.value=randomString(1)+randomString(1,2)+':'+randomString(2)+':'+randomString(2)+':'+randomString(2)+':'+randomString(2)+':'+randomString(2);"

local cfgbtn = "&nbsp;<br/><input type=\"button\" id=\"test1\" value=\" " .. translate("Generate Randomly") .. " \" onclick=\"" .. cfgcmd .. "\"/>"

server = section:taboption("general", Value, "server", translate("Supernode server"))
server.datatype = "host"
server.rmempty = false

port = section:taboption("general", Value, "port", translate("Supernode port"))
port.datatype = "port"
port.rmempty = false

section:taboption("general", Flag, "_slave", translate("Enable slave supernode"))

server2 = section:taboption("general", Value, "server2", translate("Slave supernode server"))
server2:depends("_slave", 1)
server2.datatype = "host"

port2 = section:taboption("general", Value, "port2", translate("Slave supernode port"))
port2:depends("_slave", 1)
port2.datatype = "port"

community = section:taboption("general", Value, "community", translate("Community"))
community.rmempty = false

key = section:taboption("general", Value, "key", translate("Key"))
key.password = true

mode = section:taboption("general", ListValue, "mode", translate("Mode"))
mode:value("static", "Static")
mode:value("dhcp", "DHCP")
mode.default = "static"

ipaddr = section:taboption("general", Value, "ipaddr", translate("IPv4 address"))
ipaddr:depends("mode", "static")
ipaddr.datatype = "ip4addr"

netmask = section:taboption("general", Value, "netmask", translate("IPv4 netmask"))
netmask:depends("mode", "static")
netmask.datatype = "ip4addr"
netmask.placeholder = "255.255.255.0"

gateway = section:taboption("general", Value, "gateway", translate("IPv4 gateway"))
gateway:depends("mode", "static")
gateway.datatype = "ip4addr"

if luci.model.network:has_ipv6() then
  ip6addr = section:taboption("general", Value, "ip6addr", translate("IPv6 address"))
  ip6addr.datatype = "ip6addr"
  
  ip6prefixlen = section:taboption("general", Value, "ip6prefixlen", translate("IPv6 prefix length"))
  ip6prefixlen.placeholder = "64"
  ip6prefixlen.datatype = "max(128)"
  
  ip6gw = section:taboption("general", Value, "ip6gw", translate("IPv6 gateway"))
  ip6gw.datatype = "ip6addr"
end

section:taboption("advanced", Flag, "forwarding", translate("Forwarding"), translate("Enable packet forwarding through n2n community."))

section:taboption("advanced", Flag, "dynamic", translate("Periodically resolve supernode IP"), translate("When supernodes are running on dynamic IPs."))

section:taboption("advanced", Flag, "multicast", translate("Accept multicast"), translate("Accept multicast MAC addresses."))

luci.tools.proto.opt_macaddr(section, ifc, translate("Override MAC address"), cfgbtn)

mtu = section:taboption("advanced", Value, "mtu", translate("Override MTU"))
mtu.placeholder = "1440"
mtu.datatype = "max(9200)"

localport = section:taboption("advanced", Value, "localport", translate("Bind local port"))
localport.datatype = "port"

mgmtport = section:taboption("advanced", Value, "mgmtport", translate("Management port"))
mgmtport.datatype = "port"

section:taboption("advanced", Flag, "verbose", translate("Verbose"), translate("Make more verbose in syslog."))
