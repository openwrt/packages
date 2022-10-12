#!/bin/sh
if command -v tailscale; then
    tailscale version | grep "$2" || exit 1
fi

if command -v tailscaled; then
    tailscaled -version | grep "$2"
fi
