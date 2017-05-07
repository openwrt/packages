# Copyright (c) 2017 Stan Grishin (stangri@melmac.net)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=simple-adblock
PKG_VERSION:=1.5.7
PKG_RELEASE:=2
PKG_LICENSE:=GPL-3.0+
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.net>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Simple AdBlock Service
	PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
This service provides dnsmasq-based ad blocking.
Please see the README for further information.

endef

define Package/$(PKG_NAME)/conffiles
/etc/config/simple-adblock
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)/files/
	$(CP) ./files/simple-adblock.init $(PKG_BUILD_DIR)/files/simple-adblock.init
	sed -i "s|^\(PKG_VERSION\).*|\1='$(PKG_VERSION)-$(PKG_RELEASE)'|" $(PKG_BUILD_DIR)/files/simple-adblock.init
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/simple-adblock.init $(1)/etc/init.d/simple-adblock
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/simple-adblock.conf $(1)/etc/config/simple-adblock
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
