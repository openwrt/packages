#!/bin/sh

_mpd_test() {
	# Version check
	mpd --version | grep -F "$2"

	# Confirm the binary reports at least one supported output plugin;
	# "null" is always compiled in and safe for testing.
	mpd --version | grep -i "null"

	# Test playlist_directory parsing logic from the init script:
	# explicit value
	_cfg=/tmp/mpd-pldtest.conf
	printf 'playlist_directory "/tmp/mpd-pld-explicit"\n' > "$_cfg"
	_pld=$(grep ^playlist_directory "$_cfg" | head -1 | cut -d '"' -f 2 | sed "s/~/\/root/g")
	[ -z "$_pld" ] && _pld="/tmp/mpd"
	[ "$_pld" = "/tmp/mpd-pld-explicit" ] || {
		echo "FAIL: pld='$_pld', expected /tmp/mpd-pld-explicit"
		rm -f "$_cfg"; exit 1
	}

	# Test default fallback when playlist_directory is absent
	printf '# playlist_directory commented out\n' > "$_cfg"
	_pld=$(grep ^playlist_directory "$_cfg" | head -1 | cut -d '"' -f 2 | sed "s/~/\/root/g")
	[ -z "$_pld" ] && _pld="/tmp/mpd"
	[ "$_pld" = "/tmp/mpd" ] || {
		echo "FAIL: pld='$_pld', expected /tmp/mpd default"
		rm -f "$_cfg"; exit 1
	}
	rm -f "$_cfg"

	# Set playlist_directory in the installed config so the init script
	# has a valid path to create on first service start.
	grep -q ^playlist_directory /etc/mpd.conf || \
		printf '\nplaylist_directory "/tmp/mpd"\n' >> /etc/mpd.conf
}

case "$1" in
mpd-full|mpd-mini)
	_mpd_test "$@"
	;;
esac
