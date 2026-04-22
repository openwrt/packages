#!/bin/sh

case "$1" in
	fontconfig)
		# Rebuild cache (succeeds even if no fonts are installed)
		fc-cache 2>/dev/null
		# List fonts; empty output is valid when no fonts are present
		fc-list > /dev/null
		;;
esac
