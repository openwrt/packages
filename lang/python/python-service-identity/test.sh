#!/bin/sh
[ "$1" = python3-service-identity ] || exit 0
python3 - << 'EOF'
import service_identity
from service_identity.pyopenssl import verify_hostname, verify_ip_address
from service_identity._common import (
    DNS_ID, IP_Address_ID,
    DNSPattern, IPAddressPattern,
    verify_service_identity,
)

dns_id = DNS_ID("example.com")
assert dns_id.hostname == "example.com"

ip_id = IP_Address_ID("192.0.2.1")
assert str(ip_id.ip_address) == "192.0.2.1"
EOF
