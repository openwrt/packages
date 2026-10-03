#!/bin/sh

# shellcheck shell=busybox

case "$PKG_NAME" in
strongswan-charon-cmd)
	charon-cmd --version 2>&1 | grep -F "$PKG_VERSION"
	;;

strongswan-ipsec)
	ipsec --version 2>&1 | grep -F "$PKG_VERSION"
	;;

strongswan-pki)
	pki --help 2>&1 | grep -F "$PKG_VERSION"
	;;

strongswan-swanctl)
	# --version is trying to connect to something
	swanctl --help 2>&1 | grep -F "$PKG_VERSION"
	;;

strongswan|\
strongswan-charon|\
strongswan-default|\
strongswan-full|\
strongswan-gencerts|\
strongswan-isakmp|\
strongswan-libtls|\
strongswan-minimal|\
strongswan-mod-addrblock|\
strongswan-mod-aes|\
strongswan-mod-af-alg|\
strongswan-mod-agent|\
strongswan-mod-attr|\
strongswan-mod-attr-sql|\
strongswan-mod-blowfish|\
strongswan-mod-ccm|\
strongswan-mod-chapoly|\
strongswan-mod-cmac|\
strongswan-mod-connmark|\
strongswan-mod-constraints|\
strongswan-mod-coupling|\
strongswan-mod-ctr|\
strongswan-mod-curl|\
strongswan-mod-curve25519|\
strongswan-mod-des|\
strongswan-mod-dhcp|\
strongswan-mod-dnskey|\
strongswan-mod-drbg|\
strongswan-mod-duplicheck|\
strongswan-mod-eap-dynamic|\
strongswan-mod-eap-identity|\
strongswan-mod-eap-md5|\
strongswan-mod-eap-mschapv2|\
strongswan-mod-eap-radius|\
strongswan-mod-eap-tls|\
strongswan-mod-farp|\
strongswan-mod-fips-prf|\
strongswan-mod-forecast|\
strongswan-mod-gcm|\
strongswan-mod-gcrypt|\
strongswan-mod-gmp|\
strongswan-mod-gmpdh|\
strongswan-mod-ha|\
strongswan-mod-hmac|\
strongswan-mod-kdf|\
strongswan-mod-kernel-libipsec|\
strongswan-mod-kernel-netlink|\
strongswan-mod-ldap|\
strongswan-mod-led|\
strongswan-mod-load-tester|\
strongswan-mod-lookip|\
strongswan-mod-md4|\
strongswan-mod-md5|\
strongswan-mod-mgf1|\
strongswan-mod-mysql|\
strongswan-mod-openssl|\
strongswan-mod-pem|\
strongswan-mod-pgp|\
strongswan-mod-pkcs1|\
strongswan-mod-pkcs11|\
strongswan-mod-pkcs12|\
strongswan-mod-pkcs7|\
strongswan-mod-pkcs8|\
strongswan-mod-pubkey|\
strongswan-mod-random|\
strongswan-mod-rc2|\
strongswan-mod-resolve|\
strongswan-mod-revocation|\
strongswan-mod-sha1|\
strongswan-mod-sha2|\
strongswan-mod-sha3|\
strongswan-mod-smp|\
strongswan-mod-socket-default|\
strongswan-mod-socket-dynamic|\
strongswan-mod-sql|\
strongswan-mod-sqlite|\
strongswan-mod-sshkey|\
strongswan-mod-stroke|\
strongswan-mod-test-vectors|\
strongswan-mod-unity|\
strongswan-mod-updown|\
strongswan-mod-vici|\
strongswan-mod-whitelist|\
strongswan-mod-wolfssl|\
strongswan-mod-x509|\
strongswan-mod-xauth-eap|\
strongswan-mod-xauth-generic|\
strongswan-mod-xcbc)
	exit 0
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
