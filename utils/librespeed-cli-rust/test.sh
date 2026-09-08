#!/bin/sh
set -e

# Everything here runs without network access, so it works the same in the
# build matrix as on a device.

# Help and the report header, which touch no I/O at all.
librespeed-cli --help > /dev/null
librespeed-cli --csv-header | grep '^Timestamp,Server Name,Address,Ping,Jitter,Download,Upload,Share,IP$'

# The version banner carries more than the version the generic check looks
# for; make sure the rest of it survives too.
librespeed-cli --version | grep 'github.com/BKPepe/speedtest-cli-rust'
librespeed-cli --version | grep 'GNU Lesser General Public License'

cat > /tmp/librespeed-servers.json <<'EOF'
[{"id":7,"name":"Example","server":"https://example.invalid","dlURL":"garbage.php","ulURL":"empty.php","pingURL":"empty.php","getIpURL":"getIP.php"}]
EOF

# Server list parsing and selection, offline.
librespeed-cli --local-json /tmp/librespeed-servers.json --list | grep '^7: Example'

# A malformed list has to be rejected rather than silently ignored.
echo 'nonsense' > /tmp/librespeed-bad.json
if librespeed-cli --local-json /tmp/librespeed-bad.json --list > /dev/null 2>&1; then
	echo "a malformed server list was accepted"
	exit 1
fi

cat > /tmp/librespeed-unreachable.json <<'EOF'
[{"id":1,"name":"local","server":"http://127.0.0.1:1","dlURL":"garbage.php","ulURL":"empty.php","pingURL":"empty.php","getIpURL":"getIP.php"}]
EOF

# Exercise the async runtime: pointed at a port nothing listens on, the client
# has to come back. What is being tested is that it returns at all — reaching
# the "not responding" verdict means the reactor delivered the connection
# error. One that never delivers readiness sits here forever, which is what
# the timeout catches. This found a real stall on powerpc_8548.
rc=0
timeout 30 librespeed-cli --local-json /tmp/librespeed-unreachable.json \
	--server 1 --no-icmp --timeout 5 > /tmp/librespeed-test.out 2>&1 || rc=$?

if [ "$rc" = 124 ]; then
	echo "librespeed-cli did not return within 30s against an unreachable server"
	cat /tmp/librespeed-test.out
	exit 1
fi
grep 'not responding' /tmp/librespeed-test.out

rm -f /tmp/librespeed-servers.json /tmp/librespeed-bad.json \
	/tmp/librespeed-unreachable.json /tmp/librespeed-test.out
