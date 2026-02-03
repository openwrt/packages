#
# Copyright (C) 2017 Daniel Engberg <daniel.engberg.lists@pyret.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pcsc-tools
PKG_VERSION:=1.7.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://pcsc-tools.apdu.fr
PKG_HASH:=c3b6d2b7a40bc066ebb8cd2512fb42e2b787a5c491a5715b8741743f4edb8cc2

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/pcsc-tools
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libpcsclite
  TITLE:=pcsc-tools
  URL:=https://pcsc-tools.apdu.fr/
endef

define Package/pcsc-tools/description
  Tools that are used to test a PC/SC driver, card or reader.
  Only includes pcsc_scan without ATR analysis for now.
endef

define Package/pcsc-tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/pcsc_scan $(1)/usr/bin
endef

$(eval $(call BuildPackage,pcsc-tools))
