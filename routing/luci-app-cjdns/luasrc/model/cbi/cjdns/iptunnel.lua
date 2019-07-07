uci = require "luci.model.uci"
cursor = uci:cursor_state()

m = Map("cjdns", translate("cjdns"),
  translate("Implements an encrypted IPv6 network using public-key \
    cryptography for address allocation and a distributed hash table for \
    routing. This provides near-zero-configuration networking, and prevents \
    many of the security and scalability issues that plague existing \
    networks."))

m.on_after_commit = function(self)
  os.execute("/etc/init.d/cjdns restart")
end

-- Outgoing
outgoing = m:section(TypedSection, "iptunnel_outgoing", translate("Outgoing IP Tunnel Connections"),
  translate("Enter the public keys of the nodes that will provide Internet access."))
outgoing.anonymous = true
outgoing.addremove = true
outgoing.template  = "cbi/tblsection"

outgoing:option(Value, "public_key", translate("Public Key")).size = 55

-- Allowed
allowed = m:section(TypedSection, "iptunnel_allowed", translate("Allowed IP Tunnel Connections"),
  translate("Enter the public key of the node you will provide Internet access to, along with the \
             IPv4 and/or IPv6 address you will assign them."))
allowed.anonymous = true
allowed.addremove = true

public_key = allowed:option(Value, "public_key", translate("Public Key"))
public_key.template = "cjdns/value"
public_key.size = 55

ipv4 = allowed:option(Value, "ipv4", translate("IPv4"))
ipv4.template = "cjdns/value"
ipv4.datatype = 'ipaddr'
ipv4.size = 55

ipv6 = allowed:option(Value, "ipv6", translate("IPv6"),
  translate("IPv6 addresses should be entered <em>without</em> brackets here, e.g. <code>2001:123:ab::10</code>."))
ipv6.template = "cjdns/value"
ipv6.datatype = 'ip6addr'
ipv6.size = 55

return m
