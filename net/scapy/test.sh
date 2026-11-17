#!/bin/sh

[ "$1" = scapy ] || exit 0

python3 - <<'EOF'
import scapy
from scapy.packet import Packet, Raw
from scapy.fields import ByteField, ShortField

# Test basic packet creation
pkt = Raw(load=b"hello")
assert pkt.load == b"hello", f"unexpected: {pkt.load!r}"

# Test that layers are importable
from scapy.layers.inet import IP, TCP, UDP
ip = IP(src="192.168.1.1", dst="192.168.1.2")
assert ip.src == "192.168.1.1"
assert ip.dst == "192.168.1.2"

# Test packet building
tcp = TCP(sport=1234, dport=80)
assert tcp.sport == 1234
assert tcp.dport == 80

print("scapy OK")
EOF
