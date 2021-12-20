#!/bin/sh

if [ ! -d /etc/adguardhome ] && [ -f /etc/adguardhome.yaml ]; then
  mkdir -p /etc/adguardhome
  chown adguardhome:adguardhome /etc/adguardhome

  cp /etc/adguardhome.yaml /etc/adguardhome/AdGuardHome.yaml
  chown adguardhome:adguardhome /etc/adguardhome/AdGuardHome.yaml

  if /etc/init.d/adguardhome running; then
    /etc/init.d/adguardhome restart
  fi
fi
