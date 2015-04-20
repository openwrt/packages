uci = require "luci.model.uci"
cursor = uci:cursor_state()

cjdns = require("cjdns")
require("cjdns/uci")

m = Map("cjdns", translate("cjdns"),
  translate("Implements an encrypted IPv6 network using public-key \
    cryptography for address allocation and a distributed hash table for \
    routing. This provides near-zero-configuration networking, and prevents \
    many of the security and scalability issues that plague existing \
    networks."))

m.on_after_commit = function(self)
  os.execute("/etc/init.d/cjdns restart")
end

-- Authorized Passwords
passwords = m:section(TypedSection, "password", translate("Authorized Passwords"),
  translate("Anyone offering one of the these passwords will be allowed to peer with you on the existing UDP and Ethernet interfaces."))
passwords.anonymous = true
passwords.addremove = true
passwords.template  = "cbi/tblsection"

passwords:option(Value, "user", translate("User/Name"),
  translate("Must be unique.")
).default = "user-" .. cjdns.uci.random_string(6)
passwords:option(Value, "contact", translate("Contact"), translate("Optional, for out-of-band communication."))
passwords:option(Value, "password", translate("Password"),
  translate("Hand out to your peer, in accordance with the peering best practices of the network.")
).default = cjdns.uci.random_string(32)

-- UDP Peers
udp_peers = m:section(TypedSection, "udp_peer", translate("Outgoing UDP Peers"),
  translate("For peering via public IP networks, the peer handed you their Public Key and IP address/port along with a password. IPv6 addresses should be entered with square brackets, like so: <code>[2001::1]</code>."))
udp_peers.anonymous = true
udp_peers.addremove = true
udp_peers.template  = "cbi/tblsection"
udp_peers:option(Value, "user", translate("User/Name")).datatype = "string"

udp_interface = udp_peers:option(Value, "interface", translate("UDP interface"))
local index = 1
for i,section in pairs(cursor:get_all("cjdns")) do
  if section[".type"] == "udp_interface" then
    udp_interface:value(index, section.address .. ":" .. section.port)
  end
end
udp_interface.default = 1
udp_peers:option(Value, "address", translate("IP address"))
udp_peers:option(Value, "port", translate("Port")).datatype = "portrange"
udp_peers:option(Value, "public_key", translate("Public key"))
udp_peers:option(Value, "password", translate("Password"))

-- Ethernet Peers
eth_peers = m:section(TypedSection, "eth_peer", translate("Outgoing Ethernet Peers"),
  translate("For peering via local Ethernet networks, the peer handed you their Public Key and MAC address along with a password."))
eth_peers.anonymous = true
eth_peers.addremove = true
eth_peers.template  = "cbi/tblsection"

eth_interface = eth_peers:option(Value, "interface", translate("Ethernet interface"))
local index = 1
for i,section in pairs(cursor:get_all("cjdns")) do
  if section[".type"] == "eth_interface" then
    eth_interface:value(index, section.bind)
  end
end
eth_interface.default = 1
eth_peers:option(Value, "address", translate("MAC address")).datatype = "macaddr"
eth_peers:option(Value, "public_key", translate("Public key"))
eth_peers:option(Value, "password", translate("Password"))

return m
