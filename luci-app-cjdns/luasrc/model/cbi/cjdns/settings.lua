m = Map("cjdns", translate("cjdns"),
  translate("Implements an encrypted IPv6 network using public-key \
    cryptography for address allocation and a distributed hash table for \
    routing. This provides near-zero-configuration networking, and prevents \
    many of the security and scalability issues that plague existing \
    networks."))

m.on_after_commit = function(self)
  os.execute("/etc/init.d/cjdns restart")
end

s = m:section(NamedSection, "cjdns", nil, translate("Settings"))
s.addremove = false

-- Identity
s:tab("identity", translate("Identity"))
node6 = s:taboption("identity", Value, "ipv6", translate("IPv6 address"),
      translate("This node's IPv6 address within the cjdns network."))
node6.datatype = "ip6addr"
pbkey = s:taboption("identity", Value, "public_key", translate("Public key"),
      translate("Used for packet encryption and authentication."))
pbkey.datatype = "string"
prkey = s:taboption("identity", Value, "private_key", translate("Private key"),
      translate("Keep this private. When compromised, generate a new keypair and IPv6."))
prkey.datatype = "string"

-- Admin Interface
s:tab("admin", translate("Admin API"), translate("The Admin API can be used by other applications or services to configure and inspect cjdns' routing and peering.<br/><br/>Documentation: <a href=\"https://github.com/cjdelisle/cjdns/tree/master/admin#cjdns-admin-api\">admin/README.md</a>"))
aip = s:taboption("admin", Value, "admin_address", translate("IP Address"),
      translate("IPv6 addresses should be entered like so: <code>[2001::1]</code>."))
apt = s:taboption("admin", Value, "admin_port", translate("Port"))
apt.datatype = "port"
apw = s:taboption("admin", Value, "admin_password", translate("Password"))
apw.datatype = "string"

-- Security
s:tab("security", translate("Security"), translate("Functionality related to hardening the cjdroute process."))
s:taboption("security", Flag, "seccomp", translate("SecComp sandboxing"))

-- UDP Interfaces
udp_interfaces = m:section(TypedSection, "udp_interface", translate("UDP Interfaces"),
  translate("These interfaces allow peering via public IP networks, such as the Internet, or many community-operated wireless networks. IPv6 addresses should be entered with square brackets, like so: <code>[2001::1]</code>."))
udp_interfaces.anonymous = true
udp_interfaces.addremove = true
udp_interfaces.template = "cbi/tblsection"

udp_address = udp_interfaces:option(Value, "address", translate("IP Address"))
udp_address.placeholder = "0.0.0.0"
udp_interfaces:option(Value, "port", translate("Port")).datatype = "portrange"

-- Ethernet Interfaces
eth_interfaces = m:section(TypedSection, "eth_interface", translate("Ethernet Interfaces"),
  translate("These interfaces allow peering via local Ethernet networks, such as home or office networks, or phone tethering. If an interface name is set to \"all\" each available device will be used."))
eth_interfaces.anonymous = true
eth_interfaces.addremove = true
eth_interfaces.template = "cbi/tblsection"

eth_bind = eth_interfaces:option(Value, "bind", translate("Network Interface"))
eth_bind.placeholder = "br-lan"
eth_beacon = eth_interfaces:option(Value, "beacon", translate("Beacon Mode"))
eth_beacon:value(0, translate("0 -- Disabled"))
eth_beacon:value(1, translate("1 -- Accept beacons"))
eth_beacon:value(2, translate("2 -- Accept and send beacons"))
eth_beacon.default = 2
eth_beacon.datatype = "integer(range(0,2))"

return m
