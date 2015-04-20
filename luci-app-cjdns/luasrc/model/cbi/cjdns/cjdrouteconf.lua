m = Map("cjdns", translate("cjdns"),
  translate("Implements an encrypted IPv6 network using public-key \
    cryptography for address allocation and a distributed hash table for \
    routing. This provides near-zero-configuration networking, and prevents \
    many of the security and scalability issues that plague existing \
    networks."))

dkjson = require("dkjson")
cjdns = require("cjdns")
require("cjdns/uci")

local f = SimpleForm("cjdrouteconf", translate("Edit cjdroute.conf"),
	translate("JSON interface to what's /etc/cjdroute.conf on other systems. \
    Will be parsed and written to UCI by <code>cjdrouteconf set</code>."))

local o = f:field(Value, "_cjdrouteconf")
o.template = "cbi/tvalue"
o.rows = 25

function o.cfgvalue(self, section)
	return dkjson.encode(cjdns.uci.get(), { indent = true })
end

function o.write(self, section, value)
  local obj, pos, err = dkjson.decode(value, 1, nil)

  if obj then
    cjdns.uci.set(obj)
  end
end

return f
