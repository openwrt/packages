# 
# Copyright (C) 2006-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# From tobiaswaldvogel/openwrt-addpack, modified to add binaries, too

include $(TOPDIR)/rules.mk

PKG_NAME:=keyutils
PKG_VERSION:=1.5.9
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://people.redhat.com/dhowells/keyutils/
PKG_MD5SUM:=

PKG_FIXUP:=libtool
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libkeyutils
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Key utilities library
  URL:=http://people.redhat.com/dhowells/keyutils/
endef

define Package/libkeyutils/description
  Key utilities library
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/libkeyutils.{a,so*} $(1)/usr/lib/
endef

define Package/libkeyutils/install
	$(INSTALL_DIR) $(1)/etc
	$(CP) $(PKG_BUILD_DIR)/request-key.conf $(1)/etc
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/keyctl $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/key.dns_resolver $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/request-key $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libkeyutils.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libkeyutils))
