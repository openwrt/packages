#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=crconf
PKG_VERSION:=pre2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/crconf
PKG_HASH:=15d39b599acda93a50f473190e702d593ba13613b6ed31711f3584b5726b81b8

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/crconf
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Linux crypto layer configuraton tool
  URL:=https://sourceforge.net/projects/crconf
endef

define Package/crconf/description
  Linux crypto layer configuraton tool.
  Use this to manipulate kernel Crypto API/framework stuff,
  like drivers, templates, etc.
  Example: https://wiki.strongswan.org/projects/strongswan/wiki/Pcrypt
  Most interesting stuff you can find on https://wiki.strongswan.org
endef

define Package/crconf/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/sbin/crconf $(1)/sbin
endef

$(eval $(call BuildPackage,crconf))
