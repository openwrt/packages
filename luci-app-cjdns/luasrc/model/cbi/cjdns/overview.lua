m = Map("cjdns", translate("cjdns"),
  translate("Implements an encrypted IPv6 network using public-key \
    cryptography for address allocation and a distributed hash table for \
    routing. This provides near-zero-configuration networking, and prevents \
    many of the security and scalability issues that plague existing \
    networks."))

m:section(SimpleSection).template  = "cjdns/status"

return m
