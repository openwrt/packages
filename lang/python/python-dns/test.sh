#!/bin/sh
[ "$1" = python3-dns ] || exit 0
python3 - << 'EOF'
import dns
import dns.name
import dns.rdatatype
import dns.rdata
import dns.rdataset
import dns.message
import dns.resolver

n = dns.name.from_text("www.example.com.")
assert str(n) == "www.example.com.", f"unexpected name: {n}"
assert n.is_absolute()

parent = dns.name.from_text("example.com.")
assert n.is_subdomain(parent)

rdtype = dns.rdatatype.from_text("A")
assert rdtype == dns.rdatatype.A
assert dns.rdatatype.to_text(rdtype) == "A"
EOF
