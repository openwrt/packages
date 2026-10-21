#
# Copyright (c) 2016-2026 Dirk Brenken (dev@brenken.org)
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=travelmate
PKG_VERSION:=3.0.0
PKG_RELEASE:=1
PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=Dirk Brenken <dev@brenken.org>

include $(INCLUDE_DIR)/package.mk

define Package/travelmate
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A wlan connection manager for travel router
  DEPENDS:=+ucode +ucode-mod-fs +ucode-mod-ubus +ucode-mod-uci +ucode-mod-log +ucode-mod-resolv \
	  +curl +ca-bundle +rpcd +rpcd-mod-rpcsys +rpcd-mod-iwinfo
  PKGARCH:=all
endef

define Package/travelmate/description
A wlan connection manager for travel router.
Please see https://github.com/openwrt/packages/blob/master/net/travelmate/README.md for further information.

endef

define Package/travelmate/conffiles
/etc/config/travelmate
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/travelmate/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/travelmate.uc $(1)/usr/sbin/travelmate

	$(INSTALL_DIR) $(1)/usr/share/ucode/travelmate
	$(INSTALL_DATA) ./src/*.uc $(1)/usr/share/ucode/travelmate/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/travelmate.init $(1)/etc/init.d/travelmate

	$(INSTALL_DIR) $(1)/etc/hotplug.d/ntp
	$(INSTALL_BIN) ./files/25-travelmate.hotplug $(1)/etc/hotplug.d/ntp/25-travelmate

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/travelmate.uci-defaults $(1)/etc/uci-defaults/95_travelmate

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/travelmate.conf $(1)/etc/config/travelmate

	$(INSTALL_DIR) $(1)/etc/travelmate
	$(INSTALL_BIN) ./files/login/*.uc $(1)/etc/travelmate
	$(INSTALL_CONF) ./files/mail.template $(1)/etc/travelmate
endef

$(eval $(call BuildPackage,travelmate))
