#
# Copyright (C) 2010-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libartnet
PKG_VERSION:=1.1.2
PKG_RELEASE:=1.1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/OpenLightingProject/libartnet/releases/download/1.1.2
PKG_MD5SUM:=dcceab3efe3dae4c18fa549dbd198e71

PKG_MAINTAINER:=Martijn Zilverschoon <martijn@friedzombie.com>

PKG_LICENSE:=GPL-2.1
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/libartnet
	SECTION:=libs
	CATEGORY:=Libraries
	TITLE:=Libartnet is an implementation of the ArtNet protocol.
	URL:=http://www.openlighting.org/libartnet-main/
endef

define Package/libartnet/description
	Libartnet is an implementation of the ArtNet protocol. ArtNet allows the
	transmission of DMX and related data over IP networks.
endef

define Build/Configure
	$(call Build/Configure/Default)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
	DESTDIR="$(PKG_INSTALL_DIR)" \
	all install
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
