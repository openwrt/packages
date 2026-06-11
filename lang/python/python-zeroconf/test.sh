#!/bin/sh

[ "$1" = python3-zeroconf ] || exit 0

python3 - << 'EOF'
from zeroconf import Zeroconf, ServiceInfo, ServiceBrowser
import socket

# Verify core classes are importable and instantiable
info = ServiceInfo(
    "_http._tcp.local.",
    "Test._http._tcp.local.",
    addresses=[socket.inet_aton("127.0.0.1")],
    port=80,
)
assert info.port == 80
assert info.type == "_http._tcp.local."

print("python3-zeroconf OK")
EOF