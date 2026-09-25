#!/bin/sh

[ "$1" = "privoxy" ] || exit 0

# Verify key filter and action files are installed
[ -f /etc/privoxy/default.filter ]
[ -f /etc/privoxy/match-all.action ]
[ -x /etc/init.d/privoxy ]

# Write a minimal config and verify privoxy starts and listens
cat > /tmp/privoxy-test.conf << 'EOF'
listen-address 127.0.0.1:18118
logdir /tmp
logfile privoxy-test.log
confdir /etc/privoxy
filterfile default.filter
actionsfile match-all.action
EOF

timeout 3 privoxy --no-daemon /tmp/privoxy-test.conf &
PRIVOXY_PID=$!
sleep 1
if kill -0 "$PRIVOXY_PID" 2>/dev/null; then
	echo "privoxy is running"
	kill "$PRIVOXY_PID"
	wait "$PRIVOXY_PID" 2>/dev/null || true
else
	echo "privoxy did not start"
	false
fi
