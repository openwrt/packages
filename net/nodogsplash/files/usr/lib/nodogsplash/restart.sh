#!/bin/sh

# Check if nodogsplash is running
if ndsctl status >/dev/null 2>&1; then
  if [ "$(uci -q get nodogsplash.@nodogsplash[0].fwhook_enabled)" = "1" ]; then
    /etc/init.d/nodogsplash restart
  fi
fi
