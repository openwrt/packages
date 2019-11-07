#
# Copyright (C) 2019 CZ.NIC z.s.p.o. (http://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libmaxminddb
PKG_VERSION:=1.4.2
PKG_RELEASE=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/maxmind/libmaxminddb/releases/download/$(PKG_VERSION)/
PKG_HASH:=dd582aa971be23dee960ec33c67fb5fd38affba508e6f00ea75959dbd5aad156

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>

include $(INCLUDE_DIR)/package.mk

define Package/libmaxminddb
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A library for working with MaxMind DB files
  URL:=https://maxmind.github.io/libmaxminddb/
endef

define Package/libmaxminddb/description
 The libmaxminddb library provides functions for working MaxMind DB files.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmaxminddb.{a,so*} $(1)/usr/lib/
endef

define Package/libmaxminddb/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mmdblookup $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libmaxminddb.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libmaxminddb))
