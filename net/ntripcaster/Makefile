#
# Copyright (C) 2011 segal.ubi.pt
# Copyright (C) 2010-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ntripcaster
PKG_VERSION:=0.1.5

PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/nunojpg/ntripcaster.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=03878920195cf854b38a1ea424f1cae57353fa87
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_MIRROR_HASH:=264656e5f9f9583c477208f005371124bfcbb7ba548f418eb5f1215059d1294b

PKG_LICENSE:=GPL-2.0+

PKG_MAINTAINER:=Nuno Goncalves <nunojpg@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/ntripcaster
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=NTRIP
  TITLE:=Standard Ntrip Broadcaster
  URL:=http://igs.bkg.bund.de/ntrip/download
  DEPENDS:=+libpthread
endef

define Package/ntripcaster/description
  BKG Standard Ntrip Broadcaster
endef

define Package/ntripcaster/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ntripcaster $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/share/ntripcaster/conf
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/conf/ntripcaster.conf.dist $(1)/usr/share/ntripcaster/conf/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/conf/sourcetable.dat.dist $(1)/usr/share/ntripcaster/conf/
endef

$(eval $(call BuildPackage,ntripcaster))
