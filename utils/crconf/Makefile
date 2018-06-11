#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_SOURCE_VERSION:=8bd996400d087028ba56b724abc1f5b378eaa77f

PKG_NAME:=crconf
PKG_VERSION:=pre2-$(PKG_SOURCE_VERSION)
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://git.code.sf.net/p/crconf/code
PKG_MIRROR_HASH:=f772306c0b005c18f481b73e3be193dba5ebb9f6f3bf20cb3f67c4a80dac0613

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
