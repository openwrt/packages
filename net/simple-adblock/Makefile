# Copyright (c) 2017 Stan Grishin (stangri@melmac.net)
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=simple-adblock
PKG_VERSION:=1.0.0
PKG_RELEASE:=1
PKG_LICENSE:=GPL-3.0+
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.net>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Simple AdBlock Service
	PKGARCH:=all
	DEPENDS:=(+uclient-fetch (+libustream-cyassl || +libustream-openssl)) || (wget libopenssl)
	CONFLICTS:=libustream-mbedtls libustream-polarssl wget-nossl
endef

define Package/$(PKG_NAME)/description
This service provides dnsmasq-based ad blocking.
Please see the README for further information.

endef

define Package/$(PKG_NAME)/conffiles
/etc/config/simple-adblock
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/simple-adblock.init $(1)/etc/init.d/simple-adblock
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/simple-adblock.conf $(1)/etc/config/simple-adblock
endef

$(eval $(call BuildPackage,$(PKG_NAME)))