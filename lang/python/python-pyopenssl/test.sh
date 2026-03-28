#!/bin/sh

[ "$1" = python3-pyopenssl ] || exit 0

# Basic sanity check (prints linked OpenSSL version info)
python3 -m OpenSSL.debug || exit 1

python3 - << EOF
import sys
import importlib.metadata

version = importlib.metadata.version("pyOpenSSL")
if version != "$2":
    print("Wrong version: " + version)
    sys.exit(1)

from OpenSSL import SSL, crypto
from OpenSSL.crypto import (
    PKey, TYPE_RSA, TYPE_EC,
    X509, X509Req, X509Store, X509StoreContext,
    dump_certificate, dump_privatekey, load_certificate, load_privatekey,
    dump_certificate_request,
    FILETYPE_PEM,
)

# --- Key generation ---

rsa_key = PKey()
rsa_key.generate_key(TYPE_RSA, 2048)
assert rsa_key.bits() == 2048
assert rsa_key.type() == TYPE_RSA

ec_key = PKey()
ec_key.generate_key(TYPE_EC, 256)
assert ec_key.type() == TYPE_EC

# --- Self-signed certificate ---

cert = X509()
cert.get_subject().CN = "test.example.com"
cert.get_subject().O = "Test Org"
cert.set_serial_number(1)
cert.gmtime_adj_notBefore(0)
cert.gmtime_adj_notAfter(365 * 24 * 60 * 60)
cert.set_issuer(cert.get_subject())
cert.set_pubkey(rsa_key)
cert.sign(rsa_key, "sha256")

assert cert.get_subject().CN == "test.example.com"
assert cert.get_serial_number() == 1
assert not cert.has_expired()

# --- PEM round-trip (cert) ---

pem = dump_certificate(FILETYPE_PEM, cert)
assert pem.startswith(b"-----BEGIN CERTIFICATE-----")
cert2 = load_certificate(FILETYPE_PEM, pem)
assert cert2.get_subject().CN == "test.example.com"

# --- PEM round-trip (private key) ---

key_pem = dump_privatekey(FILETYPE_PEM, rsa_key)
assert key_pem.startswith(b"-----BEGIN")
key2 = load_privatekey(FILETYPE_PEM, key_pem)
assert key2.bits() == 2048

# --- Certificate signing request ---

req = X509Req()
req.get_subject().CN = "csr.example.com"
req.set_pubkey(rsa_key)
req.sign(rsa_key, "sha256")
assert req.verify(rsa_key)
csr_pem = dump_certificate_request(FILETYPE_PEM, req)
assert csr_pem.startswith(b"-----BEGIN CERTIFICATE REQUEST-----")

# --- X509Store verification ---

store = X509Store()
store.add_cert(cert)
ctx = X509StoreContext(store, cert)
ctx.verify_certificate()  # raises if invalid

sys.exit(0)
EOF
