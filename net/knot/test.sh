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
	# Parse a minimal server config with knotc conf-check (no daemon).
	tmp=$(mktemp -d)
	trap 'rm -rf "$tmp"' EXIT

	cat > "$tmp/knot.conf" <<EOF
server:
    listen: 127.0.0.1@5353

log:
  - target: stderr
    any: info
EOF
	knotc -c "$tmp/knot.conf" conf-check
	;;

knot-dig)
	# -h prints the kdig help text; verifies the CLI parser links and runs.
	kdig -h >/dev/null
	;;

knot-host)
	# Same idea for khost.
	khost -h >/dev/null
	;;

knot-nsupdate)
	# Feed a no-op script through the REPL.
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
	# Initialise a KASP database in a temp directory; exercises the
	# storage backend and DNSSEC bootstrap code paths.
	tmp=$(mktemp -d)
	trap 'rm -rf "$tmp"' EXIT
	keymgr -d "$tmp" init
	;;

knot-libs|knot-libzscanner|knot-tests)
	# Pure-library or test-harness subpackages; covered by generic CI.
	;;

*)
	;;
esac
