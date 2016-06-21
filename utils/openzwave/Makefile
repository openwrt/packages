#
# Copyright (C) 2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openzwave
PKG_REV:=164
PKG_VERSION:=1.4.$(PKG_REV)
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_SOURCE_PROTO:=git
#PKG_SOURCE_URL:=https://github.com/OpenZWave/open-zwave.git
#PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
#PKG_MD5SUM:=1c8c1c7ed92daa9e464316dd62237188
PKG_SOURCE_URL:=http://old.openzwave.com/downloads
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_USE_MIPS16:=0 

include $(INCLUDE_DIR)/package.mk

define Package/openzwave
  SECTION:=irimi
  CATEGORY:=Utilities
  TITLE:=Open ZWave Library.
  URL:=http://openzwave.com
  DEPENDS:=+udev
  MAINTAINER:=irimi <irimi@gmx.de>
endef

define Package/openzwave/description
	open-zwave is a library interface for selected Z-Wave PC controllers
endef

define Package/openzwave/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libopenzwave.so* $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/libopenzwave.a $(STAGING_DIR)/usr/lib/
endef

$(eval $(call BuildPackage,openzwave))
