#!/bin/sh

[ "$1" = "radsecproxy" ] || exit 0

# Write a minimal config with a client so radsecproxy starts up
cat > /tmp/radsecproxy-test.conf << 'EOF'
LogLevel 3
LogDestination file:///tmp/radsecproxy-test.log
ListenUDP localhost:11812

client localhost {
    type udp
    secret testing123
}
EOF

rm -f /tmp/radsecproxy-test.log
timeout 2 radsecproxy -f -c /tmp/radsecproxy-test.conf 2>/dev/null || true

# Verify radsecproxy wrote to the log (proves it started and parsed the config)
[ -s /tmp/radsecproxy-test.log ] || {
	echo "radsecproxy did not write to log file"
	false
}
echo "radsecproxy started and logged OK"
