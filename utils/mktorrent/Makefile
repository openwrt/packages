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

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://downloads.sourceforge.net/$(PKG_NAME)/
PKG_HASH:=6f8e562af6366e0d9bde76e434f740b55722c6c3c555860dbe80083f9d1d119f

include $(INCLUDE_DIR)/package.mk

define Package/mktorrent
  SUBMENU:=BitTorrent
  SECTION:=net
  CATEGORY:=Network
  TITLE:=mktorrent
  URL:=http://mktorrent.sourceforge.net/
endef

define Package/mktorrent/Description
 mktorrent is a simple command line utility to create BitTorrent metainfo files.
endef


define Package/mktorrent/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mktorrent $(1)/usr/bin
endef

$(eval $(call BuildPackage,mktorrent))
