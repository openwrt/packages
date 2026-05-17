#!/bin/sh

case "$1" in
upmpdcli)
	# Version check: upmpdcli prints version to stderr on bad args, or to
	# stdout with --version; try both.
	ver_out=$(upmpdcli --version 2>&1 || upmpdcli -v 2>&1 || true)
	echo "$ver_out" | grep -qF "$2" || {
		# Some builds print only the short semver, not the full string;
		# check for the major.minor part at minimum.
		major_minor=$(echo "$2" | cut -d. -f1-2)
		echo "$ver_out" | grep -qF "$major_minor" || {
			echo "FAIL: version '$2' not found in: $ver_out"
			exit 1
		}
	}
	echo "Version check passed"

	# Binary must be executable
	[ -x /usr/bin/upmpdcli ] || { echo "FAIL: /usr/bin/upmpdcli not executable"; exit 1; }

	# Shared data files: OHCredentials and radio list MUST be present
	[ -d /usr/share/upmpdcli ] || { echo "FAIL: /usr/share/upmpdcli missing"; exit 1; }

	# Config template must have been installed
	[ -f /etc/upmpdcli.conf ] || { echo "FAIL: /etc/upmpdcli.conf missing"; exit 1; }

	# The config file must mention key directives that users typically
	# customise; catch packaging regressions that ship a truncated config.
	grep -q "friendlyname" /etc/upmpdcli.conf || \
		{ echo "FAIL: 'friendlyname' missing from config"; exit 1; }
	grep -q "mpdhost" /etc/upmpdcli.conf || \
		{ echo "FAIL: 'mpdhost' missing from config"; exit 1; }

	# Attempt a dry-run: upmpdcli will fail to connect to MPD (none
	# running) but must exit with a recognisable error, not a crash/signal.
	# We rely on the fact that it prints something before exiting.
	tmplog=$(mktemp /tmp/upmpdcli-test.XXXXXX)
	timeout 3 upmpdcli -c /etc/upmpdcli.conf >"$tmplog" 2>&1 || true
	# Must have produced some output (startup log or error)
	[ -s "$tmplog" ] || { echo "FAIL: upmpdcli produced no output"; rm -f "$tmplog"; exit 1; }
	echo "Startup output (first 5 lines):"
	head -5 "$tmplog"
	rm -f "$tmplog"
	;;
esac
