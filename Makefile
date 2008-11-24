#
# Copyright (C) 2007 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id$

include $(TOPDIR)/rules.mk

PKG_NAME:=nodogsplash
PKG_VERSION:=0.9_beta9.9
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://kokoro.ucsd.edu/nodogsplash/ \
	http://kokoro.ucsd.edu/nodogsplash/old/
PKG_MD5SUM:=96e597977717610186ed09ebd7fa54cf

include $(INCLUDE_DIR)/package.mk

define Package/nodogsplash
  SUBMENU:=Captive Portals
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpthread
  TITLE:=Open public network gateway daemon
  URL:=http://kokoro.ucsd.edu/nodogsplash/
endef

define Package/nodogsplash/description
	Nodogsplash offers a simple way to open a free hotspot providing restricted access to an
	internet connection. It is intended for use on wireless access points running OpenWRT
	(but may also work on other Linux-based devices).
endef

define Build/Configure
	$(call Build/Configure/Default,\
		--enable-static \
		--enable-shared \
	)
endef

define Build/Compile	
	mkdir -p $(PKG_INSTALL_DIR)/usr/{share{,/doc/$(PKG_NAME)-$(PKG_VERSION)},lib,include{,/nodogsplash},bin,sbin}/
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		mkinstalldirs="$(SHELL) $(PKG_BUILD_DIR)/config/mkinstalldirs" \
		install
endef

define Package/nodogsplash/install	
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc/$(PKG_NAME)
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/$(PKG_NAME).conf $(1)/etc/$(PKG_NAME)/
	$(CP) $(PKG_BUILD_DIR)/htdocs $(1)/etc/$(PKG_NAME)/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/$(PKG_NAME).init $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,nodogsplash))
