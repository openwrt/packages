#!/bin/sh
[ "$1" = python3-pyasn1-modules ] || exit 0

python3 - << 'EOF'
import pyasn1_modules
from pyasn1_modules import pem, rfc2314, rfc2459, rfc2986, rfc5280
from pyasn1.codec.der.decoder import decode as der_decode
from pyasn1.type import univ

# Basic OID parsing (common in ASN.1 modules)
oid = univ.ObjectIdentifier((1, 2, 840, 113549, 1, 1, 1))
assert str(oid) == '1.2.840.113549.1.1.1'

# Verify key RFC modules are importable and have expected attributes
assert hasattr(rfc2459, 'Certificate')
assert hasattr(rfc5280, 'Certificate')
assert hasattr(rfc2986, 'CertificationRequest')

print("pyasn1-modules OK")
EOF
