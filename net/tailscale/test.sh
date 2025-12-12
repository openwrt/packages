#!/bin/sh

case "$1" in
	tailscale)
		tailscale version | grep "$2"
		;;
	tailscaled)
		tailscaled -version | grep "$2"
		;;
esac
