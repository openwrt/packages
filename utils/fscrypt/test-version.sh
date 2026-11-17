#!/bin/sh
#
# Version check override for the fscrypt package.
#
# fscrypt does not support --version, -V, or --help flags for reporting its
# version; it only prints the version via the "fscrypt version" subcommand.
# pam_fscrypt.so is a PAM module, not a standalone executable, so it has no
# version output either.

case "$1" in
fscrypt)
	fscrypt --version 2>&1 | grep -F "$2"
	;;
*)
	echo "Untested package: $1" >&2
	exit 1
	;;
esac
