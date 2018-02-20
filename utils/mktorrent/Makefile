#
# Copyright (C) 2006-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mktorrent
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Rudde/$(PKG_NAME)/archive
PKG_HASH:=ab1c42a7fc9f136d4ebc5535d384d1a184cc77fe8054acd4c2f176f3a8c0dac7

include $(INCLUDE_DIR)/package.mk

define Package/mktorrent
  SUBMENU:=BitTorrent
  SECTION:=net
  CATEGORY:=Network
  TITLE:=mktorrent
  URL:=https://github.com/Rudde/mktorrent
endef

define Package/mktorrent/Description
 mktorrent is a simple command line utility to create BitTorrent metainfo files.
endef


define Package/mktorrent/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mktorrent $(1)/usr/bin
endef

$(eval $(call BuildPackage,mktorrent))
