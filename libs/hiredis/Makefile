#
# Copyright (C) 2010-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=hiredis
PKG_VERSION:=0.13.3
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/redis/hiredis.git
PKG_SOURCE_VERSION:=010756025e8cefd1bc66c6d4ed3b1648ef6f1f95
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libhiredis
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=Minimalistic C client for Redis
	URL:=https://github.com/redis/hiredis
endef

define Package/libhiredis/description
	Hiredis is a minimalistic C client library for the Redis database.
endef

MAKE_FLAGS += ARCH="" DEBUG="" PREFIX="/usr"

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/hiredis/adapters
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/hiredis/adapters/* $(1)/usr/include/hiredis/adapters
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/hiredis/*.h $(1)/usr/include/hiredis/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libhiredis.{so*,a} $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/hiredis.pc $(1)/usr/lib/pkgconfig
endef

define Package/libhiredis/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libhiredis.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libhiredis))
