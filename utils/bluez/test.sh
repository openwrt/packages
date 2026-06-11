#!/bin/sh

case "$1" in
	bluez-daemon)
		# obexd does not implement --version; just verify it is present
		[ -x /usr/bin/obexd ] || exit 1
		;;
	bluez-utils)
		# these tools do not implement --version; verify they are present
		for bin in bdaddr ciptool hciattach hciconfig l2ping l2test rctest; do
			[ -x "/usr/bin/$bin" ] || exit 1
		done
		;;
	bluez-utils-extra)
		# gatttool does not implement --version; just verify it is present
		[ -x /usr/bin/gatttool ] || exit 1
		;;
esac
