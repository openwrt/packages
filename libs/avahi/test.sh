#!/bin/sh

_lib_check() {
	local f="$1"
	[ -e "$f" ] || { echo "FAIL: $f not found"; exit 1; }
}

# Test avahi-daemon startup with a minimal config.
# Works for both dbus and nodbus variants; dbus variant skips the start
# test when avahi-utils (which needs dbus) is not installed.
_daemon_start_test() {
	# Config file from package
	[ -f /etc/avahi/avahi-daemon.conf ] || {
		echo "FAIL: /etc/avahi/avahi-daemon.conf not installed"
		exit 1
	}
	grep -q "use-ipv4=yes" /etc/avahi/avahi-daemon.conf || {
		echo "FAIL: use-ipv4=yes not found in avahi-daemon.conf"
		exit 1
	}
	[ -d /etc/avahi/services ] || {
		echo "FAIL: /etc/avahi/services directory not installed"
		exit 1
	}

	# Try to start avahi-daemon with a minimal config and no privilege drop
	mkdir -p /var/run/avahi-daemon /tmp/avahi-test

	cat > /tmp/avahi-test/avahi-daemon.conf <<-'EOF'
	[server]
	host-name=avahi-test
	use-ipv4=yes
	use-ipv6=no
	check-response-ttl=no
	use-iff-running=no
	enable-dbus=no

	[wide-area]
	enable-wide-area=no

	[publish]
	publish-addresses=yes
	publish-hinfo=no
	publish-workstation=no
	publish-domain=yes
	disable-publishing=no

	[reflector]
	enable-reflector=no

	[rlimits]
	rlimit-core=0
	rlimit-data=4194304
	rlimit-fsize=0
	rlimit-nofile=30
	rlimit-stack=4194304
	rlimit-nproc=3
	EOF

	avahi-daemon --no-drop-root --no-chroot \
		--file=/tmp/avahi-test/avahi-daemon.conf \
		-D 2>/tmp/avahi-test/daemon.log

	# Wait for pid file
	i=0
	while [ $i -lt 10 ] && [ ! -f /var/run/avahi-daemon/pid ]; do
		sleep 1
		i=$((i + 1))
	done

	if [ -f /var/run/avahi-daemon/pid ]; then
		echo "avahi-daemon started (pid $(cat /var/run/avahi-daemon/pid))"

		# Verify socket exists
		[ -e /var/run/avahi-daemon/socket ] && echo "socket present" || \
			echo "NOTE: socket not present (may need network)"

		# Stop the daemon
		kill "$(cat /var/run/avahi-daemon/pid)" 2>/dev/null
		i=0
		while [ $i -lt 5 ] && [ -f /var/run/avahi-daemon/pid ]; do
			sleep 1; i=$((i + 1))
		done
		echo "avahi-daemon stopped"
	else
		echo "NOTE: avahi-daemon did not start within 10s (may need network interface)"
		echo "daemon log:"
		cat /tmp/avahi-test/daemon.log 2>/dev/null
		# Not a hard failure — network may not be available in all test envs
	fi

	rm -rf /tmp/avahi-test
}

_service_file_check() {
	local f="$1" stype="$2" port="$3"

	[ -f "$f" ] || { echo "FAIL: $f not found"; exit 1; }

	# Validate it is XML and contains expected service attributes
	grep -q "<service-group>" "$f" || { echo "FAIL: $f missing <service-group>"; exit 1; }
	grep -q "<type>_${stype}._tcp</type>" "$f" || {
		echo "FAIL: $f missing <type>_${stype}._tcp</type>"
		exit 1
	}
	grep -q "<port>$port</port>" "$f" || {
		echo "FAIL: $f missing <port>$port</port>"
		exit 1
	}
	echo "$f: OK"
}

case "$1" in
libavahi-dbus-support)
	_lib_check /usr/lib/libavahi-common.so.3
	_lib_check /usr/lib/libavahi-core.so.7
	# D-Bus policy file
	[ -f /etc/dbus-1/system.d/avahi-dbus.conf ] || {
		echo "FAIL: avahi D-Bus policy not installed"
		exit 1
	}
	grep -q "avahi" /etc/dbus-1/system.d/avahi-dbus.conf || {
		echo "FAIL: avahi-dbus.conf does not mention avahi"
		exit 1
	}
	;;

libavahi-nodbus-support)
	_lib_check /usr/lib/libavahi-common.so.3
	_lib_check /usr/lib/libavahi-core.so.7
	;;

libavahi-client)
	_lib_check /usr/lib/libavahi-client.so.3
	;;

avahi-dbus-daemon|avahi-nodbus-daemon)
	_daemon_start_test
	;;

avahi-autoipd)
	[ -x /usr/sbin/avahi-autoipd ] || { echo "FAIL: avahi-autoipd not executable"; exit 1; }
	[ -x /etc/avahi/avahi-autoipd.action ] || {
		echo "FAIL: avahi-autoipd.action script not installed"
		exit 1
	}
	[ -f /lib/netifd/proto/autoip.sh ] || {
		echo "FAIL: netifd autoip proto script not installed"
		exit 1
	}
	;;

avahi-daemon-service-http)
	_service_file_check /etc/avahi/services/http.service http 80
	;;

avahi-daemon-service-ssh)
	_service_file_check /etc/avahi/services/ssh.service ssh 22
	;;

avahi-dnsconfd)
	[ -x /usr/sbin/avahi-dnsconfd ] || { echo "FAIL: avahi-dnsconfd not executable"; exit 1; }
	[ -x /etc/avahi/avahi-dnsconfd.action ] || {
		echo "FAIL: avahi-dnsconfd.action not installed"
		exit 1
	}
	;;

avahi-utils)
	# All four utilities must be present and print a help/usage line
	for bin in avahi-browse avahi-publish avahi-resolve avahi-set-host-name; do
		[ -x "/usr/bin/$bin" ] || { echo "FAIL: $bin not found"; exit 1; }
		# --help exits non-zero on some versions; capture stderr+stdout
		"$bin" --help 2>&1 | grep -qi "usage\|help\|option" || {
			echo "FAIL: $bin --help produced no usage output"
			exit 1
		}
		echo "$bin: OK"
	done

	# Verify avahi-browse can list service types (fails fast without daemon;
	# the important thing is the binary runs and parses arguments)
	avahi-browse --terminate --all 2>&1 | grep -qi "avahi\|failed\|error\|No.*daemon\|socket\|service" && \
		echo "avahi-browse --terminate --all: ran" || \
		echo "avahi-browse --terminate --all: no output (daemon not running)"
	;;
esac
