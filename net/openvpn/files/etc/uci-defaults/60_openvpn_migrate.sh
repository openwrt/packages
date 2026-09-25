#!/bin/sh

OPENVPN_PKG="/etc/config/openvpn"
NETWORK_PKG="/etc/config/network"

[ -f "$OPENVPN_PKG" ] || exit 0

awk '
function section_exists(name) {
	cmd = "uci -q get network." name " >/dev/null 2>&1"
	return (system(cmd) == 0)
}

BEGIN {
	in_section=0
	secname = ""
}

/^config[ \t]+openvpn[ \t]+/ {
	# get section name
	secname = $3
	gsub(/'\''/, "", secname)

	if (section_exists(secname)) {
		in_section=0
		next
	}

	in_section=1

	sub(/^config[ \t]+openvpn/, "config interface")
	print
	print "\toption proto '\''openvpn'\''"
	next
}

# Start of another section
/^config[ \t]+/ {
	in_section=0
}

# Inside openvpn section, rename proto
in_section && /^[ \t]*option[ \t]+proto[ \t]/ {
	sub(/option[ \t]+proto/, "option ovpnproto")
	print
	next
}

# Inside openvpn section; copy as-is
in_section {
	print
}
' "$OPENVPN_PKG" >> "$NETWORK_PKG"

exit 0