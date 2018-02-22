#
# Copyright (C) 2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dht
PKG_VERSION:=0.25
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/jech/dht/archive
PKG_HASH:=68099eb95a0d3f34d796696a2b17439a46b3e3e30db0bfe9ff65ce281db0cfeb
PKG_MAINTAINER:=Rosen Penev <rosenp@gmail.com>
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENCE

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/dht
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=DHT Library
  URL:=https://www.irif.fr/~jch//software/bittorrent/
endef

define Package/dht/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libdht.so $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/libdht.so $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/include/dht
	$(CP) $(PKG_INSTALL_DIR)/usr/include/dht/dht.h $(1)/usr/include/dht/
endef

$(eval $(call BuildPackage,dht))
