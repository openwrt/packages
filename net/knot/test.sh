#!/bin/sh
#
# Functional smoke tests for the knot subpackages.
#
# Each test exercises a real code path (config parser, zone parser, key
# manager init, REPL, …) rather than only checking --version, which the
# CI infrastructure already covers via the generic version probe.

set -e

case "$1" in
knot)
	# Exercise the knotd binary's argv parser. Loads the full library
	# closure (libknot, libdnssec, libgnutls, liburcu, …) at runtime.
	knotd -h >/dev/null
	;;

knot-dig)
	# Exercise kdig's CLI parser; verifies the binary and its libknot
	# / libgnutls runtime closure load.
	kdig -h >/dev/null
	;;

knot-host)
	# Exercise khost's CLI parser; same shape as knot-dig but covers
	# the khost binary's library closure.
	khost -h >/dev/null
	;;

knot-nsupdate)
	# Feed `quit` through the knsupdate REPL; exercises the
	# interactive parser and libknot / libedit runtime closure.
	printf 'quit\n' | knsupdate
	;;

knot-zonecheck)
	# Validate a minimal zone file for example.com — exercises the
	# zone parser and semantic-check pipeline end to end.
	tmp=$(mktemp -d)
	trap 'rm -rf "$tmp"' EXIT

	cat > "$tmp/example.com.zone" <<'EOF'
$ORIGIN example.com.
$TTL 3600
@   IN  SOA  ns1.example.com. admin.example.com. ( 1 7200 1800 1209600 3600 )
    IN  NS   ns1.example.com.
ns1 IN  A    192.0.2.1
EOF
	kzonecheck -o example.com. "$tmp/example.com.zone"
	;;

knot-keymgr)
	# Generate a TSIG key; exercises the libdnssec / libnettle /
	# libgnutls crypto stack.
	keymgr -t testkey hmac-sha256 >/dev/null
	;;

knot-libs|knot-libzscanner|knot-tests)
	# Pure-library / test-harness subpackages; the generic ELF /
	# SONAME / linked-libraries checks already cover them.
	;;

*)
	echo "test.sh: unknown subpackage '$1' — refusing to silently pass" >&2
	echo "test.sh: update net/knot/test.sh to cover this subpackage" >&2
	exit 1
	;;
esac
