#!/bin/sh

[ "$1" = python3-service-identity ] || exit 0

python3 - << 'EOF'
from service_identity import VerificationError
from service_identity.pyopenssl import verify_hostname, verify_ip_address

# Just verify the module imports and key symbols are present
assert callable(verify_hostname)
assert callable(verify_ip_address)
assert issubclass(VerificationError, Exception)

print("python3-service-identity OK")
EOF