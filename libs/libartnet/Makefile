#
# Copyright (C) 2010-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libartnet
PKG_VERSION:=1.1.2
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/OpenLightingProject/libartnet/releases/download/1.1.2
PKG_HASH:=19cdda434e208a81ddd138377f11046364438e40e34542ae101d6aa3fcaec696

PKG_MAINTAINER:=Martijn Zilverschoon <martijn@friedzombie.com>
PKG_LICENSE:=GPL-2.1
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libartnet
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=Libartnet is an implementation of the ArtNet protocol.
	URL:=https://www.openlighting.org/libartnet-main/
endef

define Package/libartnet/description
	Libartnet is an implementation of the ArtNet protocol. ArtNet allows the
	transmission of DMX and related data over IP networks.
endef

define Build/InstallDev
	mkdir -p $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/artnet $(1)/usr/include/
	mkdir -p $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libartnet.{so,so.1,so.1.0.0} $(1)/usr/lib/
endef


define Package/libartnet/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libartnet.{so,so.1,so.1.0.0} $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libartnet))
