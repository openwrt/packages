# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2026 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=readsb-wiedehopf
PKG_VERSION:=3.16.11
PKG_RELEASE:=1
PKG_SOURCE:=readsb-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/wiedehopf/readsb/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=ac0488a2deadd20b373a56928b7d297b5e9262566dd84ec9c72cffaedff2cc78

PKG_BUILD_DIR:=$(BUILD_DIR)/readsb-$(PKG_VERSION)

PKG_LICENSE:=GPL-3.0-or-later BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE COPYING

PKG_MAINTAINER:=Dr Bill Mcilhargey <contributor@mcilhargey.com>

PKG_BUILD_DEPENDS:=!USE_GLIBC:argp-standalone
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=gc-sections lto

include $(INCLUDE_DIR)/package.mk

define Package/readsb-wiedehopf/default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Mode-S/ADSB/TIS decoder (wiedehopf fork)
  URL:=https://github.com/wiedehopf/readsb
  DEPENDS:=+libncurses +librtlsdr +libzstd +zlib +jsonfilter +ca-bundle
endef

define Package/readsb-wiedehopf
  $(call Package/readsb-wiedehopf/default)
  TITLE+= (readsb)
  PROVIDES:=readsb
  CONFLICTS:=readsb
endef

define Package/readsb-wiedehopf/description
  readsb is a Mode-S/ADSB/TIS decoder for RTL-SDR and other SDR devices.
  This is the wiedehopf fork (https://github.com/wiedehopf/readsb), an
  actively maintained alternative to the `readsb` package (which tracks
  the now-archived Mictronics upstream). It adds many features used by
  aggregators (BeastReduce, UUIDs, globe history, heatmaps, JSON/binCraft
  outputs, http API) and is the upstream used by tar1090, adsb.lol,
  airplanes.live, adsb.fi and similar projects.

  Installs /usr/bin/readsb and conflicts with the readsb package; either
  can satisfy a `readsb` dependency.

  Interactive setup is provided by /usr/sbin/readsb-setup (full guided
  first-boot configuration: lat/lon, station UUID, aggregator feeders,
  apply). Per-area CLIs: readsb-uuid, readsb-geoip, readsb-feeder.

  Optional companion packages (not pulled in automatically):
    * adsbexchange-stats -- ranking-dashboard stats uploader for ADSBx.

  See https://github.com/openwrt/packages/blob/master/utils/readsb-wiedehopf/README.md
  for the full configuration reference, aggregator preset list, and
  operational notes.
endef

define Package/viewadsb-wiedehopf
  $(call Package/readsb-wiedehopf/default)
  TITLE+= (viewadsb)
  PROVIDES:=viewadsb
  CONFLICTS:=viewadsb
endef

define Package/viewadsb-wiedehopf/description
  Console viewer companion to readsb (wiedehopf fork). Connects to a
  running readsb instance over the network and displays an interactive
  list of received aircraft.
endef

# Drop -D_FORTIFY_SOURCE=* from TARGET_CFLAGS; upstream sets its own
# and builds with -Werror, so OpenWrt's default would clash.
READSB_OPTIMIZE_CFLAGS := $(filter-out -D_FORTIFY_SOURCE=%,$(TARGET_CFLAGS))

MAKE_FLAGS += \
	BLADERF=no \
	HACKRF=no \
	PLUTOSDR=no \
	SOAPYSDR=no \
	OPTIMIZE="$(READSB_OPTIMIZE_CFLAGS)" \
	RTLSDR=yes \
	UNAME="Linux"

TARGET_LDFLAGS += \
	$(if $(CONFIG_USE_GLIBC),,-largp) \
	-lncurses \
	-Wl,--as-needed

define Package/readsb-wiedehopf/conffiles
/etc/config/readsb
endef

define Package/readsb-wiedehopf/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d $(1)/etc/hotplug.d/usb $(1)/usr/bin $(1)/usr/lib/readsb $(1)/usr/sbin
	$(INSTALL_CONF) ./files/readsb.config $(1)/etc/config/readsb
	$(INSTALL_BIN) ./files/readsb.init $(1)/etc/init.d/readsb
	$(INSTALL_BIN) ./files/readsb.hotplug $(1)/etc/hotplug.d/usb/30-readsb
	$(INSTALL_DATA) ./files/readsb.functions.sh $(1)/usr/lib/readsb/functions.sh
	$(INSTALL_BIN) ./files/readsb.geoip $(1)/usr/sbin/readsb-geoip
	$(INSTALL_BIN) ./files/readsb.uuid $(1)/usr/sbin/readsb-uuid
	$(INSTALL_BIN) ./files/readsb.feeder $(1)/usr/sbin/readsb-feeder
	$(INSTALL_BIN) ./files/readsb.setup $(1)/usr/sbin/readsb-setup
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/readsb $(1)/usr/bin/readsb
endef

define Package/readsb-wiedehopf/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] && exit 0
/etc/init.d/readsb enable
/etc/init.d/readsb start
# Print the orientation banner so `opkg install` shows it on the console.
echo
echo "readsb-wiedehopf installed and started."
/usr/sbin/readsb-setup --help
logger -t readsb -p daemon.notice -- "installed; run 'readsb-setup' to configure (location, UUID, feeders)"
exit 0
endef

define Package/readsb-wiedehopf/prerm
#!/bin/sh
# Stop and disable readsb before opkg removes /etc/init.d/readsb.
# Both calls are best-effort: a stopped daemon, missing procd
# registration or ubus timeout must not surface a non-zero exit OR
# stream chatter to opkg. Some builds emit "Command failed: Not found"
# to stdout instead of stderr, so redirect both streams.
[ -n "$${IPKG_INSTROOT}" ] && exit 0
[ -x /etc/init.d/readsb ] && {
	/etc/init.d/readsb stop    >/dev/null 2>&1
	/etc/init.d/readsb disable >/dev/null 2>&1
}
exit 0
endef

define Package/readsb-wiedehopf/postrm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] && exit 0
rm -rf /var/run/readsb
exit 0
endef

define Package/viewadsb-wiedehopf/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/viewadsb $(1)/usr/bin/viewadsb
endef

$(eval $(call BuildPackage,readsb-wiedehopf))
$(eval $(call BuildPackage,viewadsb-wiedehopf))
