#
# Copyright (C) 2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nodogsplash
PKG_VERSION:=0.9_beta9.9.8
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk


define Package/nodogsplash
	SUBMENU:=Captive Portals
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+libpthread +iptables-mod-ipopt
	TITLE:=Open public network gateway daemon
	URL:=https://github.com/mwarning/nodogsplash
endef

define Package/nodogsplash/description
	Nodogsplash offers a simple way to open a free hotspot providing
	restricted access to an internet connection.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	git clone https://github.com/mwarning/nodogsplash.git $(PKG_BUILD_DIR)
endef

#for sources inside the package
#define Build/Prepare
#	mkdir -p $(PKG_BUILD_DIR)
#	$(CP) ./src/* $(PKG_BUILD_DIR)/
#endef

define Package/nodogsplash/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nodogsplash $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ndsctl $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/nodogsplash.init $(1)/etc/init.d/$(PKG_NAME)

	$(INSTALL_DIR) $(1)/etc/$(PKG_NAME)/htdocs/images
	$(CP) $(PKG_BUILD_DIR)/resources/nodogsplash.conf $(1)/etc/$(PKG_NAME)/
	$(CP) $(PKG_BUILD_DIR)/resources/splash.html $(1)/etc/$(PKG_NAME)/htdocs/
	$(CP) $(PKG_BUILD_DIR)/resources/infoskel.html $(1)/etc/$(PKG_NAME)/htdocs/
	$(CP) $(PKG_BUILD_DIR)/resources/splash.jpg $(1)/etc/$(PKG_NAME)/htdocs/images/
endef


$(eval $(call BuildPackage,nodogsplash))
