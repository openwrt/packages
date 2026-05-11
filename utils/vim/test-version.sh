#!/bin/sh

# shellckeck shell=busybox

case "$PKG_NAME" in
vim|\
vim-full|\
vim-fuller)
	vim --version | grep -F "$PKG_VERSION"
	;;

vim-help|\
vim-runtime)
	exit 0
	;;

xxd)
	xxd --version 2>&1 | grep -F "${PKG_VERSION//./-}"
	;;

*)
	echo "Untested package: $PKG_NAME" >&2
	exit 1
	;;
esac
