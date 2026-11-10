#!/bin/sh

case "$1" in
mitmproxy)
	mitmdump --version 2>&1 | grep "$2"
	python3 -c 'import mitmproxy.tools.web.master' && echo "mitmweb imports OK"
	;;
esac
