# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2026 Dr Bill Mcilhargey
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Dual-license: OpenWrt packaging files (this Makefile, init script,
# helpers, patches) are GPL-2.0-only. The upstream json-status payload
# (ADSBexchange.com, (c) 2020) remains under its original MIT license.

include $(TOPDIR)/rules.mk

PKG_NAME:=adsbexchange-stats
PKG_VERSION:=2023-02-22
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ADSBexchange/adsbexchange-stats.git
PKG_SOURCE_VERSION:=11647f27de3eef51fb19bcb39f0dc0b8500a6671
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.xz
PKG_MIRROR_HASH:=b16c3c708daea4389f1d850aca1c899cfd9827785038c332c4bf28e541ae5992

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Dr Bill Mcilhargey <contributor@mcilhargey.com>

include $(INCLUDE_DIR)/package.mk

define Package/adsbexchange-stats
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Radio Devices
  TITLE:=ADSBexchange.com statistics uploader
  URL:=https://github.com/ADSBexchange/adsbexchange-stats
  # Hard-depends on readsb-wiedehopf: shares readsb.main.uuid, the
  # readsb-uuid CLI, and /usr/lib/readsb/functions.sh.
  # gzip is intentionally omitted -- BusyBox provides the `gzip` applet
  # which is what the upload path uses; +gzip would pull standalone GNU
  # gzip and break opkg dep resolution on stock feeds.
  DEPENDS:=+bash +jq +curl +coreutils-stat +readsb-wiedehopf
  PKGARCH:=all
endef

define Package/adsbexchange-stats/description
  ADSBexchange.com statistics uploader for OpenWrt.

  Periodically reads aircraft.json from readsb (via readsb-wiedehopf),
  aggregates per-aircraft RSSI and counts, and POSTs the result to
  https://adsbexchange.com identified by the station UUID stored at
  readsb.main.uuid -- shared with readsb's BEAST connectors so a single
  `readsb-uuid` configures both.

  Service knobs live in /etc/config/adsbexchange-stats.
  Manage the station UUID with `readsb-uuid`.

  Daemon control:
    service adsbexchange-stats {start|stop|restart|reload|status|enable|disable|showurl}
    logread -e adsbexchange-stats        -- uploader logs

  Extra (non-procd) actions:
    /etc/init.d/adsbexchange-stats showurl
                                         -- print the public per-station
                                            ADSBexchange stats URL
                                            (derived from readsb.main.uuid)
endef

# Pure shell payload; nothing to compile or stage-install.
Build/Configure:=:
Build/Compile:=:
Build/Install:=:

define Package/adsbexchange-stats/conffiles
/etc/config/adsbexchange-stats
endef

define Package/adsbexchange-stats/install
	$(INSTALL_DIR) \
		$(1)/etc/config \
		$(1)/etc/init.d \
		$(1)/usr/lib/adsbexchange-stats \
		$(1)/usr/share/adsbexchange-stats
	$(INSTALL_BIN)  $(PKG_BUILD_DIR)/json-status                 $(1)/usr/share/adsbexchange-stats/json-status
	$(INSTALL_CONF) ./files/adsbexchange-stats.config            $(1)/etc/config/adsbexchange-stats
	$(INSTALL_BIN)  ./files/adsbexchange-stats.init              $(1)/etc/init.d/adsbexchange-stats
	$(INSTALL_DATA) ./files/adsbexchange-stats.functions.sh      $(1)/usr/lib/adsbexchange-stats/functions.sh
	$(INSTALL_DATA) ./files/adsbexchange-stats.json-status-helpers.sh \
		                                                     $(1)/usr/lib/adsbexchange-stats/json-status-helpers.sh
	# Substitute @PKG_*@ placeholders in the init banner so values
	# stay sourced from this Makefile (PKG_VERSION/PKG_MAINTAINER/...).
	$(SED) 's,@PKG_VERSION@,$(PKG_VERSION)-$(PKG_RELEASE),g'                          $(1)/etc/init.d/adsbexchange-stats
	$(SED) 's,@PKG_LICENSE@,$(PKG_LICENSE),g'                                          $(1)/etc/init.d/adsbexchange-stats
	$(SED) 's,@PKG_URL@,https://github.com/ADSBexchange/adsbexchange-stats,g'          $(1)/etc/init.d/adsbexchange-stats
	$(SED) 's,@PKG_MAINTAINER@,$(PKG_MAINTAINER),g'                                    $(1)/etc/init.d/adsbexchange-stats
endef

define Package/adsbexchange-stats/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] && exit 0
/etc/init.d/adsbexchange-stats enable
if [ -n "$$(uci -q get readsb.main.uuid)" ]; then
	/etc/init.d/adsbexchange-stats start
else
	cat <<'EOF'
adsbexchange-stats: no UUID found in readsb.main.uuid -- service not started.
  Next steps:
    readsb-uuid                              # generate / set the station UUID
    /etc/init.d/adsbexchange-stats start     # start the uploader
    /etc/init.d/adsbexchange-stats showurl   # print this station's stats URL
    logread -e adsbexchange-stats            # tail uploader logs
EOF
fi
exit 0
endef

define Package/adsbexchange-stats/prerm
#!/bin/sh
# Stop and disable before opkg removes the init script. Output is
# silenced because procd's `service delete` ubus call emits a harmless
# "Command failed: Not found" when no live service entry exists.
[ -n "$${IPKG_INSTROOT}" ] && exit 0
{
	if [ -x /etc/init.d/adsbexchange-stats ]; then
		/etc/init.d/adsbexchange-stats running && \
			/etc/init.d/adsbexchange-stats stop
		/etc/init.d/adsbexchange-stats disable
	fi
} >/dev/null 2>&1
exit 0
endef

define Package/adsbexchange-stats/postrm
#!/bin/sh
# Tidy the runtime dir; /var/run is tmpfs and would clear at reboot
# anyway. Intentionally untouched: readsb.main.uuid (shared station
# identity) and /etc/config/adsbexchange-stats (opkg `conffiles`).
[ -n "$${IPKG_INSTROOT}" ] && exit 0
rm -rf /var/run/adsbexchange-stats
exit 0
endef

$(eval $(call BuildPackage,adsbexchange-stats))
