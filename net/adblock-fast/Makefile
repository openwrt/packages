# Copyright 2023 Stan Grishin (stangri@melmac.ca)
# TLD optimization written by Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=adblock-fast
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>
PKG_LICENSE:=GPL-3.0-or-later

include $(INCLUDE_DIR)/package.mk

define Package/adblock-fast
  SECTION:=net
  CATEGORY:=Network
  TITLE:=AdBlock Fast Service
  URL:=https://docs.openwrt.melmac.net/adblock-fast/
  DEPENDS:=+jshn +curl
  CONFLICTS:=simple-adblock
  PROVIDES:=simple-adblock
  PKGARCH:=all
endef

define Package/adblock-fast/description
Fast AdBlocking script to block ad or abuse/malware domains with DNSMASQ or Unbound.
Script supports local/remote list of domains and hosts-files for both block-listing and allow-listing.
Please see https://docs.openwrt.melmac.net/adblock-fast/ for more information.
endef

define Package/adblock-fast/conffiles
/etc/config/adblock-fast
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/adblock-fast/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/adblock-fast $(1)/etc/init.d/adblock-fast
	$(SED) "s|^\(readonly PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(1)/etc/init.d/adblock-fast
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/adblock-fast $(1)/etc/config/adblock-fast
	$(INSTALL_DIR) $(1)/tmp
	$(INSTALL_DATA) ./files/adblock-fast.config.update $(1)/tmp/adblock-fast.config.update
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN)  ./files/etc/uci-defaults/90-adblock-fast $(1)/etc/uci-defaults/90-adblock-fast
endef

define Package/adblock-fast/postinst
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		sed -f /tmp/adblock-fast.config.update -i /etc/config/adblock-fast || true
		/etc/init.d/adblock-fast enable
	fi
	exit 0
endef

define Package/adblock-fast/prerm
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo "Stopping service and removing rc.d symlink for adblock-fast"
		/etc/init.d/adblock-fast stop || true
		/etc/init.d/adblock-fast killcache || true
		/etc/init.d/adblock-fast disable || true
	fi
	exit 0
endef

$(eval $(call BuildPackage,adblock-fast))
