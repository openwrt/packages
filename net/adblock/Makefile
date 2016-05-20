#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=adblock
PKG_VERSION:=1.1.11
PKG_RELEASE:=1
PKG_LICENSE:=GPL-3.0+
PKG_MAINTAINER:=Dirk Brenken <dev@brenken.org>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Powerful adblock script to block ad/abuse domains
	DEPENDS:=+wget
	PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
Powerful adblock script to block ad/abuse domains.
Currently the script supports 19 domain blacklist sites plus manual black- and whitelist overrides.
Please see https://github.com/openwrt/packages/blob/master/net/adblock/files/README.md for further information.

endef

define Package/$(PKG_NAME)/conffiles
/etc/config/adblock
/etc/adblock/adblock.whitelist
/etc/adblock/adblock.blacklist
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/adblock-update.sh $(1)/usr/bin/
	$(INSTALL_DATA) ./files/adblock-helper.sh $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/adblock.hotplug $(1)/etc/hotplug.d/iface/99-adblock

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/adblock.init $(1)/etc/init.d/adblock

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/adblock.conf $(1)/etc/config/adblock

	$(INSTALL_DIR) $(1)/etc/adblock
	$(INSTALL_CONF) ./files/adblock.conf $(1)/etc/adblock/adblock.conf.default
	$(INSTALL_CONF) ./files/adblock.blacklist $(1)/etc/adblock/
	$(INSTALL_CONF) ./files/adblock.whitelist $(1)/etc/adblock/

	$(INSTALL_DIR) $(1)/www/adblock
	$(INSTALL_DATA) ./files/www/adblock/* $(1)/www/adblock/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
